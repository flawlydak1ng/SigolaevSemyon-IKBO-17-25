#!/usr/bin/env bash
# Задача 4: все уникальные идентификаторы (правила C/C++/Java) в файле.
# Идентификатор: [A-Za-z_][A-Za-z0-9_]*, границы слова не дают
# "выкусить" имя из числового литерала (0x1F).
# Использование: ./task4.sh hello.c
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    echo "Использование: $0 ФАЙЛ" >&2
    exit 1
fi

{ grep -oE '\b[A-Za-z_][A-Za-z0-9_]*\b' -- "$1" || true; } \
    | LC_ALL=C sort -u \
    | paste -sd' ' -
