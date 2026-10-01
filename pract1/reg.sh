#!/usr/bin/env bash
# Задача 5: регистрация пользовательской команды.
# Задаёт права rwxr-xr-x и копирует файл в /usr/local/bin
# (каталог можно переопределить переменной REG_DEST - удобно для тестов).
# Использование: sudo ./reg.sh banner
set -euo pipefail

dest="${REG_DEST:-/usr/local/bin}"

if [ "$#" -ne 1 ]; then
    echo "Использование: $0 ФАЙЛ" >&2
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "Ошибка: '$1' не найден или не является обычным файлом" >&2
    exit 1
fi
if [ ! -d "$dest" ] || [ ! -w "$dest" ]; then
    echo "Ошибка: нет доступа на запись в '$dest' (нужен sudo?)" >&2
    exit 1
fi

name="$(basename -- "$1")"
install -m 0755 -- "$1" "$dest/$name"
echo "Команда '$name' зарегистрирована: $dest/$name"
