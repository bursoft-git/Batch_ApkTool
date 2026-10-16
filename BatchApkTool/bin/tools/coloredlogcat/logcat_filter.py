import os
import sys
import argparse
import subprocess
import re
import time

START_PROC_PATTERN = re.compile(r"Start proc\s+(\d+):")
LOG_PARSE_PATTERN = re.compile(r"([FEWIDV])/([\s\S]+?)(?:\(\s*(\d+)\s*\))?:\s*(.*)$")
ANSI_ESCAPE_PATTERN = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')

script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

try:
    import color_console as color
except ImportError:
    print(f"[*] Файл color_console.py не найден в папке {script_dir}!", file=sys.stderr)
    sys.exit(1)

def get_pids_by_package(package_name):
    found_pids = set()
    
    try:
        result = subprocess.run(
            ["adb", "shell", "pidof", package_name],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=3
        )
        if result.returncode == 0 and result.stdout.strip():
            if "not found" not in result.stdout and "not found" not in result.stderr:
                for pid in result.stdout.strip().split():
                    if pid.isdigit():
                        found_pids.add(pid)
                if found_pids:
                    return found_pids, "pidof"
    except Exception:
        pass
    
    try:
        result = subprocess.run(
            ["adb", "shell", "dumpsys", "meminfo", package_name],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=5
        )
        if result.returncode == 0:
            for match in re.finditer(r"in\s+pid\s+(\d+)", result.stdout, re.IGNORECASE):
                found_pids.add(match.group(1))
            if found_pids:
                return found_pids, "dumpsys"
    except Exception:
        pass
    
    return found_pids, "none"

def clean_ansi_and_tabs(text):
    text = text.expandtabs(4)
    if '\x1B' in text:
        text = ANSI_ESCAPE_PATTERN.sub('', text)
    return text

def safe_print_message(message, max_width, indent_spaces):
    if not message:
        sys.stdout.write(" \n")
        sys.stdout.flush()
        return
    
    if max_width <= 0:
        max_width = 30 
    
    lines = message.split('\n')
    for i, sub_line in enumerate(lines):
        if i > 0:
            sys.stdout.write(indent_spaces)
        
        if not sub_line:
            sys.stdout.write(" \n" if i == 0 else "\n")
            sys.stdout.flush()
            continue
        
        current_pos = 0
        while current_pos < len(sub_line):
            chunk = sub_line[current_pos:current_pos + max_width]
            if current_pos == 0 and i == 0:
                sys.stdout.write(f" {chunk}\n")
            else:
                sys.stdout.write(f"{indent_spaces}{chunk}\n")
            sys.stdout.flush()
            
            current_pos += len(chunk) if chunk else max_width

def main():
    sys.stdin = open(sys.stdin.fileno(), mode='r', encoding='utf-8', errors='replace', closefd=False)
    sys.stdout = open(sys.stdout.fileno(), mode='w', encoding='utf-8', errors='replace', closefd=False)
    
    parser = argparse.ArgumentParser(description="Фильтрация и раскраска логов Android.")
    parser.add_argument("-p", "--package", help="Имя пакета для фильтрации")
    parser.add_argument("-o", "--output", help="Путь к файлу для сохранения результатов")
    
    args = parser.parse_args()
    package = args.package
    pids = set()
    
    default_colors = color.get_text_attr()
    current_bg = default_colors & 0x00F0
    
    TEXT_BLACK = 0x0000
    TEXT_WHITE = color.FOREGROUND_RED | color.FOREGROUND_GREEN | color.FOREGROUND_BLUE | color.FOREGROUND_INTENSITY
    
    log_colors = {
        "F": color.BACKGROUND_RED | color.BACKGROUND_INTENSITY | TEXT_WHITE,
        "E": color.BACKGROUND_RED | color.BACKGROUND_INTENSITY | TEXT_BLACK,
        "W": color.BACKGROUND_GREEN | color.BACKGROUND_RED | color.BACKGROUND_INTENSITY | TEXT_BLACK,
        "I": color.BACKGROUND_GREEN | color.BACKGROUND_INTENSITY | TEXT_BLACK,
        "D": color.BACKGROUND_GREEN | color.BACKGROUND_BLUE | color.BACKGROUND_INTENSITY | TEXT_BLACK,
        "V": color.BACKGROUND_BLUE | color.BACKGROUND_INTENSITY | TEXT_BLACK,
    }
    
    if package:
        pids, method = get_pids_by_package(package)
        color.set_text_attr(current_bg | color.FOREGROUND_YELLOW)
        if pids:
            print(f"[*] Найден процесс пакета '{package}' [{method}]: {', '.join(pids)}", file=sys.stderr)
        else:
            print(f"[*] Не найдены работающие процессы пакета '{package}', ждём запуска..", file=sys.stderr)
        color.set_text_attr(default_colors)
    
    out_file = open(args.output, "w", encoding="utf-8", errors="replace") if args.output else None
    
    TAG_WIDTH = 20
    left_indent_size = TAG_WIDTH + 5 
    indent_spaces = " " * left_indent_size
    
    def update_console_sizes():
        try:
            w = os.get_terminal_size().columns - 3
        except OSError:
            w = 117
        return max(30, w - left_indent_size)
    
    max_chunk_size = update_console_sizes()
    last_size_check_time = time.time()
    CHECK_INTERVAL = 1.0
    
    try:
        for line in sys.stdin:
            clean_line = line.strip()
            if not clean_line:
                continue
            
            current_time = time.time()
            if current_time - last_size_check_time >= CHECK_INTERVAL:
                max_chunk_size = update_console_sizes()
                last_size_check_time = current_time
            
            parsed = LOG_PARSE_PATTERN.search(clean_line)
            
            if parsed:
                letter = parsed.group(1)
                tag = parsed.group(2).strip()
                line_pid = parsed.group(3)
                raw_message = parsed.group(4)
                is_system = False
            else:
                letter = "."
                tag = "SYSTEM"
                line_pid = None
                raw_message = clean_line
                is_system = True
            
            if package and "Start proc" in clean_line and package in clean_line:
                match = START_PROC_PATTERN.search(clean_line)
                if match:
                    extracted_pid = match.group(1)
                    if extracted_pid not in pids:
                        pids.add(extracted_pid)
                        color.set_text_attr(current_bg | color.FOREGROUND_YELLOW)
                        print(f"\n[*] Обнаружен запуск нового процесса пакета! Добавлен PID: {extracted_pid} (Всего: {len(pids)}) \n", file=sys.stderr)
                        color.set_text_attr(default_colors)
            
            show_line = (not package) or \
                        (line_pid and line_pid in pids) or \
                        (package in clean_line) or \
                        (pids and any(pid in clean_line for pid in pids))
            
            if show_line:
                message = clean_ansi_and_tabs(raw_message)
                
                if len(tag) > TAG_WIDTH:
                    formatted_tag = "..." + tag[-(TAG_WIDTH-3):]
                else:
                    formatted_tag = tag.rjust(TAG_WIDTH)
                
                sys.stdout.write(f"{formatted_tag} ")
                sys.stdout.flush()
                
                if is_system:
                    color.set_text_attr(current_bg | color.FOREGROUND_GREY)
                    sys.stdout.write(" . ")
                else:
                    if letter in log_colors:
                        color.set_text_attr(log_colors[letter])
                    sys.stdout.write(f" {letter} ")
                sys.stdout.flush()
                
                color.set_text_attr(default_colors)
                safe_print_message(message, max_chunk_size, indent_spaces)
                
                if out_file:
                    out_file.write(line)
                    out_file.flush()

    except KeyboardInterrupt:
        color.set_text_attr(current_bg | color.FOREGROUND_YELLOW)
        print("\n[*] Фильтрация остановлена", file=sys.stderr)
    finally:
        color.set_text_attr(default_colors)
        if out_file:
            out_file.close()

if __name__ == "__main__":
    main()
