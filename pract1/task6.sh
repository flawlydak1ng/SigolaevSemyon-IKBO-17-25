#!/usr/bin/env bash
# Задача 6: проверка наличия комментария в первой строке файлов .c, .js, .py
# (поиск рекурсивный). Для c/js комментарий начинается с // или /*,
# для py - с # (shebang '#!' тоже считается комментарием).
# Код возврата: 0 - у всех есть, 1 - есть файлы без комментария.
# Использование: ./task6.sh [КАТАЛОГ]
set -euo pipefail

dir="${1:-.}"
missing=0

while IFS= read -r -d '' f; do
    first=""
    IFS= read -r first < "$f" || true
    first="${first#"${first%%[![:space:]]*}"}"   # убрать ведущие пробелы
    ok=0
    case "$f" in
        *.py)     if [[ "$first" == '#'* ]]; then ok=1; fi ;;
        *.c|*.js) if [[ "$first" == '//'* || "$first" == '/*'* ]]; then ok=1; fi ;;
    esac
    if [ "$ok" -eq 1 ]; then
        echo "OK   $f"
    else
        echo "NO   $f"
        missing=1
    fi
done < <(find "$dir" -type f \( -name '*.c' -o -name '*.js' -o -name '*.py' \) -print0 | sort -z)

exit "$missing"
