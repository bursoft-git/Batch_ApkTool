import os
import sys

# Переменная %apps_source% указывает источник данных для списка приложений:
# 1. apm читает файл apps-info.txt в формате app_manager
# 2. adb читает файлы apps_system.txt, apps-system.txt, apps_user.txt, apps_disabled.txt в формате adb, также подгружает названия из файла app-labels-%str_bat_lang%.txt
# Переменная %pkg_filter% фильтрует список приложений по критериям (ALL, SYSTEM, USER, DISABLED, UNINSTALLED), либо по списку из файла apps-file.txt (FILE), либо по имени пакета
# Кодировка вывода указывается в %app_list_enc%: utf-8 или cp%str_codepage%

apps_source = os.environ.get("apps_source", "apm")
pkg_filter = os.environ.get("pkg_filter", "ALL")
str_bat_lang = os.environ.get("str_bat_lang", "en")
app_list_enc = os.environ.get("app_list_enc", "utf-8")
sys.stdin.reconfigure(encoding='utf-8', errors='replace')
sys.stdout.reconfigure(encoding=app_list_enc, errors='replace')

script_dir = os.path.dirname(os.path.abspath(__file__))
bindir =  os.environ.get("bindir")

if apps_source == 'apm':
    apps_info_file = os.path.join(bindir, "temp", "apps-info.txt")
    
    apps_list = {}
    if os.path.isfile(apps_info_file):
        with open(apps_info_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                parts = line.split(":", maxsplit=5)
                if len(parts) == 6:
                    apps_list[parts[3]] = {
                        "pkg_status": parts[0],
                        "pkg_user": parts[1],
                        "pkg_name": parts[3],
                        "pkg_label": parts[-1],
                    }
    
    if pkg_filter in ('ALL', 'SYSTEM', 'USER', 'DISABLED', 'UNINSTALLED'):
        for pkg_name in sorted(apps_list.keys()):
            info = apps_list[pkg_name]
            
            color = ""
            nocolor = ""
            if app_list_enc == 'utf-8':
                color = "\033[90m"
                nocolor = "\033[0m"
                if info['pkg_user'] == 'SYSTEM':
                    color = "\033[32m"
                if info['pkg_user'] == 'USER':
                    color = "\033[33m"
                if info['pkg_status'] == 'DISABLED':
                    color = "\033[36m"
                if info['pkg_status'] == 'UNINSTALLED':
                    color = "\033[31m"
            
            if info["pkg_label"] == pkg_name:
                line_print = f"{info['pkg_status']} {info['pkg_user']} {color}{pkg_name}{nocolor}"
            else:
                line_print = f"{info['pkg_status']} {info['pkg_user']} {color}{pkg_name}{nocolor} {info['pkg_label']}"
            
            if pkg_filter == "ALL":
                print(line_print)
            elif pkg_filter == "SYSTEM":
                if info['pkg_user'] == 'SYSTEM':
                    print(line_print)
            elif pkg_filter == "USER":
                if info['pkg_user'] == 'USER':
                    print(line_print)
            elif pkg_filter == "DISABLED":
                if info['pkg_status'] == 'DISABLED':
                    print(line_print)
            elif pkg_filter == "UNINSTALLED":
                if info['pkg_status'] == 'UNINSTALLED':
                    print(line_print)
    elif pkg_filter == "FILE":
        apps_file_file = os.path.join(bindir, "temp", "apps-file.txt")
        apps_file = {}
        if os.path.isfile(apps_file_file):
            with open(apps_file_file, 'r', encoding='utf-8', errors='ignore') as f2:
                for line in f2:
                    line = line.strip()
                    if not line or line.startswith((";", "#")):
                        continue
                    if line.startswith("package:"):
                        line = line[8:]
                    parts = line.split(maxsplit=1)
                    if len(parts) == 1:
                        apps_file[parts[0]] = ""
                    else:
                        apps_file[parts[0]] = parts[1]
            
            for pkg_name in (apps_file):
                color = ""
                nocolor = ""
                if app_list_enc == 'utf-8':
                    color = "\033[90m"
                    nocolor = "\033[0m"
                app_data = apps_list.get(pkg_name, {})
                if app_data:
                    if app_list_enc == 'utf-8':
                        if app_data['pkg_user'] == 'SYSTEM':
                            color = "\033[32m"
                        if app_data['pkg_user'] == 'USER':
                            color = "\033[33m"
                        if app_data['pkg_status'] == 'DISABLED':
                            color = "\033[36m"
                        if app_data['pkg_status'] == 'UNINSTALLED':
                            color = "\033[31m"
                    if apps_file[pkg_name]:
                        print(f"{app_data['pkg_status']} {app_data['pkg_user']} {color}{pkg_name}{nocolor} {apps_file[pkg_name]}")
                    else:
                        if app_data['pkg_label'] == pkg_name:
                            print(f"{app_data['pkg_status']} {app_data['pkg_user']} {color}{pkg_name}{nocolor}")
                        else:
                            print(f"{app_data['pkg_status']} {app_data['pkg_user']} {color}{pkg_name}{nocolor} {app_data['pkg_label']}")
                else:
                    print(f"NOT_FOUND NOT_FOUND {color}{pkg_name}{nocolor} {apps_file[pkg_name]}")
    else:
        pkg_name = pkg_filter
        app_data = apps_list.get(pkg_name, {})
        if app_data:
            print(f"{app_data['pkg_status']} {app_data['pkg_user']} {pkg_name} {app_data['pkg_label']}")
        else:
            print(f"NOT_FOUND NOT_FOUND {pkg_name}")

else:
    apps_system_file = os.path.join(bindir, "temp", "apps_system.txt")
    apps_system2_file = os.path.join(bindir, "temp", "apps-system.txt")
    apps_user_file = os.path.join(bindir, "temp", "apps_user.txt")
    apps_disabled_file = os.path.join(bindir, "temp", "apps_disabled.txt")
    labels_file = os.path.join(script_dir, f"app-labels-{str_bat_lang}.txt")
    
    apps_system = set()
    if os.path.isfile(apps_system_file):
        with open(apps_system_file, 'r', encoding='utf-8', errors='ignore') as f2:
            for line in f2:
                if line.strip():
                    apps_system.add(line.strip()[8:])
    
    apps_system2 = set()
    if os.path.isfile(apps_system2_file):
        with open(apps_system2_file, 'r', encoding='utf-8', errors='ignore') as f2:
            for line in f2:
                if line.strip():
                    apps_system2.add(line.strip()[8:])
    
    apps_user = set()
    if os.path.isfile(apps_user_file):
        with open(apps_user_file, 'r', encoding='utf-8', errors='ignore') as f2:
            for line in f2:
                if line.strip():
                    apps_user.add(line.strip()[8:])
    
    apps_disabled = set()
    if os.path.isfile(apps_disabled_file):
        with open(apps_disabled_file, 'r', encoding='utf-8', errors='ignore') as f2:
            for line in f2:
                if line.strip():
                    apps_disabled.add(line.strip()[8:])
    
    labels = {}
    if os.path.isfile(labels_file):
        with open(labels_file, 'r', encoding='utf-8', errors='ignore') as f2:
            for line in f2:
                parts = line.strip().split(maxsplit=1)
                if len(parts) == 2:
                    labels[parts[0]] = parts[1]
    
    apps_all = apps_system | apps_user
    apps_deleted = apps_system - apps_system2
    
    if pkg_filter in ('ALL', 'SYSTEM', 'USER', 'DISABLED', 'UNINSTALLED'):
        for pkg_name in sorted(apps_all):
            color = ""
            nocolor = ""
            if app_list_enc == 'utf-8':
                color = "\033[90m"
                nocolor = "\033[0m"
                if pkg_name in apps_system:
                    color = "\033[32m"
                if pkg_name in apps_user:
                    color = "\033[33m"
                if pkg_name in apps_disabled:
                    color = "\033[36m"
                if pkg_name in apps_deleted:
                    color = "\033[31m"
            
            if pkg_name in apps_system:
                pkg_user = "SYSTEM"
            elif pkg_name in apps_user:
                pkg_user = "USER"
            
            if pkg_name in apps_disabled:
                pkg_status = "DISABLED"
            elif pkg_name in apps_deleted:
                pkg_status = "UNINSTALLED"
            elif pkg_name in apps_all:
                pkg_status = "ENABLED"
            
            if pkg_name in labels:
                line_print = f"{pkg_status} {pkg_user} {color}{pkg_name}{nocolor} {labels[pkg_name]}"
            else:
                line_print = f"{pkg_status} {pkg_user} {color}{pkg_name}{nocolor}"
            
            if pkg_filter == "ALL":
                print(line_print)
            elif pkg_filter == "SYSTEM":
                if pkg_user == 'SYSTEM':
                    print(line_print)
            elif pkg_filter == "USER":
                if pkg_user == 'USER':
                    print(line_print)
            elif pkg_filter == "DISABLED":
                if pkg_status == 'DISABLED':
                    print(line_print)
            elif pkg_filter == "UNINSTALLED":
                if pkg_status == 'UNINSTALLED':
                    print(line_print)
    elif pkg_filter == "FILE":
        apps_file_file = os.path.join(bindir, "temp", "apps-file.txt")
        apps_file = {}
        if os.path.isfile(apps_file_file):
            with open(apps_file_file, 'r', encoding='utf-8', errors='ignore') as f2:
                for line in f2:
                    line = line.strip()
                    if not line or line.startswith((";", "#")):
                        continue
                    if line.startswith("package:"):
                        line = line[8:]
                    parts = line.split(maxsplit=1)
                    if len(parts) == 1:
                        apps_file[parts[0]] = ""
                    else:
                        apps_file[parts[0]] = parts[1]
            
            for pkg_name in (apps_file):
                pkg_user = "NOT_FOUND"
                pkg_status = "NOT_FOUND"
                color = ""
                nocolor = ""
                if app_list_enc == 'utf-8':
                    color = "\033[90m"
                    nocolor = "\033[0m"
                    if pkg_name in apps_system:
                        color = "\033[32m"
                    if pkg_name in apps_user:
                        color = "\033[33m"
                    if pkg_name in apps_disabled:
                        color = "\033[36m"
                    if pkg_name in apps_deleted:
                        color = "\033[31m"
                
                if pkg_name in apps_system:
                    pkg_user = "SYSTEM"
                elif pkg_name in apps_user:
                    pkg_user = "USER"
                
                if pkg_name in apps_disabled:
                    pkg_status = "DISABLED"
                elif pkg_name in apps_deleted:
                    pkg_status = "UNINSTALLED"
                elif pkg_name in apps_all:
                    pkg_status = "ENABLED"
                
                if pkg_name in labels:
                    print(f"{pkg_status} {pkg_user} {color}{pkg_name}{nocolor} {labels[pkg_name]}")
                else:
                    print(f"{pkg_status} {pkg_user} {color}{pkg_name}{nocolor} {apps_file[pkg_name]}")
    else:
        pkg_name = pkg_filter
        pkg_user = "NOT_FOUND"
        pkg_status = "NOT_FOUND"
        
        if pkg_name in apps_system:
            pkg_user = "SYSTEM"
        elif pkg_name in apps_user:
            pkg_user = "USER"
        
        if pkg_name in apps_disabled:
            pkg_status = "DISABLED"
        elif pkg_name in apps_deleted:
            pkg_status = "UNINSTALLED"
        elif pkg_name in apps_all:
            pkg_status = "ENABLED"
        
        if pkg_name in labels:
            print(f"{pkg_status} {pkg_user} {pkg_name} {labels[pkg_name]}")
        else:
            print(f"{pkg_status} {pkg_user} {pkg_name}")
