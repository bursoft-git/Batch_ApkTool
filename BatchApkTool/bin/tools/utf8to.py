import os
import sys

str_codepage = os.environ.get("str_codepage")

if str_codepage:
    str_codepage = f"cp{str_codepage}"
else:
    str_codepage = "utf-8"

sys.stdin.reconfigure(encoding='utf-8', errors='replace')
sys.stdout.reconfigure(encoding=str_codepage, errors='replace')

for line in sys.stdin:
    line = line.strip()
    print(line)
