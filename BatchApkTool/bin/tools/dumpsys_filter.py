import os
import sys

str_codepage = os.environ.get("str_codepage")
pkg_name = os.environ.get("pkg_name", "not_found")

if str_codepage:
    str_codepage = f"cp{str_codepage}"
else:
    str_codepage = "utf-8"

sys.stdin.reconfigure(encoding='utf-8', errors='replace')
sys.stdout.reconfigure(encoding=str_codepage, errors='replace')

appId = userId = versionName = versionCode = minSdk = targetSdk = firstInstallTime = lastUpdateTime = codePath = splits = path = None

for line in sys.stdin:
    line = line.rstrip()
    if line and not line[0].isspace():
        section1 = line
    if len(line) >= 3 and line[:2].isspace() and line[2] != " ":
        section2 = line[2:]
    if section1 == "Packages:" and section2.startswith(f"Package [{pkg_name}]"):
        line = line.lstrip()
        if line.startswith("appId="):
            if not appId:
                appId = line
                print(line)
        if line.startswith("userId="):
            if not userId:
                userId = line
                print(line)
        if line.startswith("versionName="):
            if not versionName:
                versionName = line
                print(line)
        if line.startswith("versionCode="):
            if not versionCode:
                versionCode = line
                print(line)
        if line.startswith("minSdk="):
            if not minSdk:
                minSdk = line
                print(line)
        if line.startswith("targetSdk="):
            if not targetSdk:
                targetSdk = line
                print(line)
        if line.startswith("firstInstallTime="):
            if not firstInstallTime:
                firstInstallTime = line
                print(line)
        if line.startswith("lastUpdateTime="):
            if not lastUpdateTime:
                lastUpdateTime = line
                print(line)
        if line.startswith("codePath="):
            if not codePath:
                codePath = line
                print(line)
        if line.startswith("splits="):
            if not splits:
                splits = line
                print(line)
    if section1 == "Dexopt state:" and section2 == f"[{pkg_name}]":
        line = line.lstrip()
        if line.startswith("path: "):
            if not path:
                path = f"path={line[6:]}"
                print(path)