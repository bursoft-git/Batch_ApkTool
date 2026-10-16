import os
import re
import sys

# Читаем путь из переменной окружения %smali_dir%
smali_dir = os.environ.get("smali_dir")

if not smali_dir:
    print("Ошибка: переменная окружения %smali_dir% не задана.")
    sys.exit(1)

if not os.path.isdir(smali_dir):
    print(f"Ошибка: путь '{smali_dir}' не существует или не является папкой.")
    sys.exit(1)

# Захватываем все идущие подряд слэши перед \u
unicode_escape_re = re.compile(r"(\\*)(?:\\u[0-9a-fA-F]{4})+")

FORBIDDEN_CHARS = {0x000A, 0x000D, 0x0022, 0x0027, 0x005C}

def decode_chain(match):
    slashes = match.group(1)
    # Если количество слэшей нечетное, значит \u экранирован. Не трогаем его.
    if len(slashes) % 2 != 0:
        return match.group(0)
    
    # Отрезаем слэши от общей строки, чтобы обработать только \u...
    full_str = match.group(0)[len(slashes):]
    
    hex_list = re.findall(r"[0-9a-fA-F]{4}", full_str)
    codes = [int(h, 16) for h in hex_list]
    
    res = [slashes] # Возвращаем ведущие слэши на место
    i = 0
    while i < len(codes):
        # Проверяем, образуют ли текущий и следующий код валидную суррогатную пару
        # (High surrogate: 0xD800-0xDBFF, Low surrogate: 0xDC00-0xDFFF)
        if i + 1 < len(codes) and (0xD800 <= codes[i] <= 0xDBFF) and (0xDC00 <= codes[i+1] <= 0xDFFF):
            pair_bytes = bytes.fromhex(hex_list[i] + hex_list[i+1])
            res.append(pair_bytes.decode("utf-16-be"))
            i += 2  # Шагаем сразу через два кода
        else:
            # Если это одиночный символ
            code = codes[i]
            # Проверяем на запрещенные символы или сломанные одиночные суррогаты
            if code in FORBIDDEN_CHARS or code < 0x0020 or (0xD800 <= code <= 0xDFFF):
                res.append(f"\\u{hex_list[i]}")  # Оставляем исходный текст
            else:
                res.append(chr(code))
            i += 1  # Шагаем к следующему коду
            
    return "".join(res)

count = 0

for root, dirs, files in os.walk(smali_dir):
    for file in files:
        if file.endswith(".smali"):
            file_path = os.path.join(root, file)

            # Читаем содержимое файла с кодировкой UTF-8
            try:
                with open(file_path, "r", encoding="utf-8", errors="surrogateescape") as f:
                    content = f.read()

                # Декодируем unicode escapes
                new_content = unicode_escape_re.sub(decode_chain, content)

                # Если были изменения, перезаписываем файл
                if new_content != content:
                    temp_path = file_path + ".tmp"
                    try:
                        with open(temp_path, "w", encoding="utf-8", errors="surrogateescape") as f:
                            f.write(new_content)
                        
                        os.replace(temp_path, file_path)
                        # print(f"Обновлен: {file_path}")
                        count += 1
                    except Exception as e:
                        print(f"Ошибка записи в {file_path}: {e}")
                        if os.path.exists(temp_path):
                            os.remove(temp_path)

            except Exception as e:
                print(f"Ошибка при обработке {file_path}: {e}")

print(f"{count} файлов")
