#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.10"
# dependencies = ["qrcode>=7"]
# ///
"""Pair an Android device for wireless ADB by scanning a QR code in the terminal.

Like Android Studio's "Pair device with QR code", but for the CLI:

  1. Show a QR encoding ``WIFI:T:ADB;S:<name>;P:<password>;;``
  2. The phone scans it (Developer options > Wireless debugging > Pair device
     with QR code) and starts advertising an ``_adb-tls-pairing._tcp`` mDNS
     service named ``<name>``.
  3. We discover it and run ``adb pair ip:port password``.
  4. We find the device's ``_adb-tls-connect._tcp`` service (or let adb's
     auto-connect kick in) and ``adb connect``.

Unlike other QR-pairing tools, discovery is delegated to the adb server
itself (``adb mdns services``) instead of an in-process zeroconf listener.
That makes it work in places where LAN multicast never reaches the tool --
WSL2, containers, VMs -- as long as the adb server runs somewhere with real
network visibility (on WSL2: the Windows adb.exe).
"""

from __future__ import annotations

__version__ = "0.1.0"

import argparse
import glob
import os
import secrets
import shutil
import string
import subprocess
import sys
import time

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
import qrcode

PAIR_SVC = "_adb-tls-pairing"
CONNECT_SVC = "_adb-tls-connect"
WIN_ADB_GLOB = "/mnt/c/Users/*/AppData/Local/Android/Sdk/platform-tools/adb.exe"


def is_wsl() -> bool:
    try:
        with open("/proc/version") as f:
            return "microsoft" in f.read().lower()
    except OSError:
        return False


def find_adb(override: str | None) -> str:
    if override:
        return override
    if os.environ.get("ADB"):
        return os.environ["ADB"]
    if is_wsl():
        # Prefer the Windows adb: its server runs on the Windows side, where
        # LAN multicast is visible. A Linux adb inside WSL2 sits behind NAT
        # and its mDNS discovery comes up empty.
        exe = shutil.which("adb.exe") or next(iter(glob.glob(WIN_ADB_GLOB)), None)
        if exe:
            return exe
        linux_adb = shutil.which("adb")
        if linux_adb:
            print(
                "warning: no Windows adb.exe found, falling back to Linux adb -- "
                "mDNS discovery will likely fail inside WSL2. Install "
                "platform-tools on the Windows side for reliable pairing.",
                file=sys.stderr,
            )
            return linux_adb
    else:
        found = shutil.which("adb")
        if found:
            return found
        home = os.path.expanduser("~")
        candidates = [
            os.path.join(home, "Library", "Android", "sdk", "platform-tools", "adb"),
            os.path.join(home, "Android", "Sdk", "platform-tools", "adb"),
        ]
        if os.environ.get("LOCALAPPDATA"):
            candidates.append(
                os.path.join(
                    os.environ["LOCALAPPDATA"],
                    "Android", "Sdk", "platform-tools", "adb.exe",
                )
            )
        for p in candidates:
            if os.path.exists(p):
                return p
    sys.exit("adb not found -- install Android platform-tools or pass --adb /path/to/adb")


def adb_env() -> dict[str, str]:
    # ADB_MDNS_OPENSCREEN=1 forces the built-in mdns backend on older
    # platform-tools; harmless on recent versions where it is the default.
    env = {**os.environ, "ADB_MDNS_OPENSCREEN": "1"}
    if is_wsl():
        # WSLENV makes the variable cross the WSL->Windows interop boundary,
        # so the adb *server* (a Windows process) actually sees it.
        env["WSLENV"] = (os.environ.get("WSLENV", "") + ":ADB_MDNS_OPENSCREEN/u").lstrip(":")
    return env


def run_adb(adb_path: str, *args: str, timeout: int = 60) -> subprocess.CompletedProcess:
    return subprocess.run(
        [adb_path, *args], capture_output=True, text=True, env=adb_env(), timeout=timeout
    )


def mdns_services(adb_path: str) -> list[tuple[str, str, str, int]]:
    """Parse `adb mdns services` into (instance, service_type, ip, port) rows."""
    out = run_adb(adb_path, "mdns", "services").stdout
    rows = []
    for line in out.splitlines():
        line = line.rstrip("\r")
        parts = line.split("\t") if "\t" in line else line.split()
        if len(parts) < 3 or not parts[1].startswith("_adb-tls-"):
            continue
        instance, svc, endpoint = parts[0], parts[1], parts[2]
        ip, _, port = endpoint.rpartition(":")
        if ip and port.isdigit():
            rows.append((instance, svc, ip, int(port)))
    return rows


def ensure_mdns(adb_path: str) -> None:
    check = run_adb(adb_path, "mdns", "check")
    if "daemon version" in check.stdout:
        return
    # The server may have been started without mdns enabled; restart it with
    # our environment and try once more.
    run_adb(adb_path, "kill-server")
    check = run_adb(adb_path, "mdns", "check")
    if "daemon version" in check.stdout:
        return
    msg = (check.stdout + check.stderr).strip()
    if "unknown command" in msg or "usage:" in msg.lower():
        sys.exit(
            "this adb is too old for `adb mdns services` -- update Android "
            "platform-tools (31+): https://developer.android.com/tools/releases/platform-tools"
        )
    sys.exit(f"adb mdns unavailable: {msg}")


def print_qr(text: str, invert: bool) -> None:
    qr = qrcode.QRCode(border=2)
    qr.add_data(text)
    qr.print_ascii(invert=invert)


def main() -> int:
    ap = argparse.ArgumentParser(
        prog="adb-qr",
        description="Pair (and connect) an Android device over wireless ADB by QR code.",
    )
    ap.add_argument("--adb", help="path to the adb binary (default: autodetect; env ADB also works)")
    ap.add_argument("--timeout", type=int, default=120, metavar="SECONDS",
                    help="how long to wait for the phone to scan (default: 120)")
    ap.add_argument("--pair-only", action="store_true",
                    help="stop after pairing; don't wait for a connection")
    ap.add_argument("--no-invert", action="store_true",
                    help="flip QR colors if your scanner struggles on this terminal background")
    ap.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    args = ap.parse_args()

    adb_path = find_adb(args.adb)
    ensure_mdns(adb_path)

    name = f"adbqr-{secrets.token_hex(4)}"
    alphabet = string.ascii_letters + string.digits
    password = "".join(secrets.choice(alphabet) for _ in range(12))

    print_qr(f"WIFI:T:ADB;S:{name};P:{password};;", invert=not args.no_invert)
    print("On the phone: Developer options >\n > Wireless debugging >\n > Pair device with QR code\n(Press Ctrl+C to exit)")
    print(f"Waiting for scan (up to {args.timeout}s)... ", end="", flush=True)

    # Phase 1: after scanning, the phone advertises _adb-tls-pairing named
    # after the QR's S: field. Match on that; if some device doesn't echo the
    # name back, fall back to a lone pairing service (the password still
    # guards against pairing with the wrong device).
    pair_ip = pair_port = None
    deadline = time.monotonic() + args.timeout
    try:
        while time.monotonic() < deadline:
            pairing = [r for r in mdns_services(adb_path) if r[1].startswith(PAIR_SVC)]
            match = [r for r in pairing if r[0] == name] or (
                pairing if len(pairing) == 1 else []
            )
            if match:
                _, _, pair_ip, pair_port = match[0]
                break
            time.sleep(1)
    except KeyboardInterrupt:
        print("\ninterrupted")
        return 130
    if not pair_ip:
        print("\nTimed out: the phone never appeared in `adb mdns services`.")
        print("Make sure it is on the same network as the machine running the adb")
        print("server (on WSL2 that's Windows, not the WSL VM) and try again.")
        return 1
    print(f"found {pair_ip}:{pair_port}")

    res = run_adb(adb_path, "pair", f"{pair_ip}:{pair_port}", password)
    if "Successfully paired" not in res.stdout:
        print(f"Pairing failed: {(res.stdout + res.stderr).strip()}", file=sys.stderr)
        return 1
    print(res.stdout.strip())
    tempdir = os.getenv('tempdir')
    tempdir = os.path.join(tempdir, "adb_qr.txt")
    with open(tempdir, "w", encoding="utf-8") as file:
        file.write(res.stdout.strip())
    if args.pair_only:
        return 0

    # Phase 2: connect. Recent adb auto-connects to paired devices it sees
    # via mDNS, so watch `adb devices` while also trying an explicit connect
    # against the device's _adb-tls-connect service.
    deadline = time.monotonic() + 30
    try:
        while time.monotonic() < deadline:
            devices = run_adb(adb_path, "devices").stdout
            connected = [
                line for line in devices.splitlines()
                if line.strip().endswith("device") and (pair_ip in line or CONNECT_SVC in line)
            ]
            if connected:
                print(f"Connected: {connected[0].split()[0]}")
                return 0
            for _, svc, ip, port in mdns_services(adb_path):
                if svc.startswith(CONNECT_SVC) and ip == pair_ip:
                    res = run_adb(adb_path, "connect", f"{ip}:{port}")
                    print(res.stdout.strip())
            time.sleep(1)
    except KeyboardInterrupt:
        print("\ninterrupted (already paired -- `adb connect` manually if needed)")
        return 130

    print("Paired, but no connection after 30s -- run `adb connect <ip>:<port>` with")
    print("the port shown on the phone's Wireless debugging screen.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
