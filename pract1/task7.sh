#!/usr/bin/env bash
# Задача 7: поиск файлов-дубликатов (одинаковое содержимое) в каталоге
# и подкаталогах. Файлы сравниваются по SHA-256. Каждая группа дубликатов
# выводится отдельным блоком.
# Использование: ./task7.sh [КАТАЛОГ]
set -euo pipefail

dir="${1:-.}"
if [ ! -d "$dir" ]; then
    echo "Ошибка: '$dir' - не каталог" >&2
    exit 1
fi

find "$dir" -type f -print0 \
    | xargs -0 -r sha256sum \
    | LC_ALL=C sort \
    | awk '
        {
            hash = substr($0, 1, 64)
            file = substr($0, 67)        # формат: "<hash>  <путь>"
            if (hash != prev) { flush(); prev = hash; n = 0 }
            files[++n] = file
        }
        function flush(   i) {
            if (n > 1) {
                printf "Дубликаты (%d копий, sha256 %s...):\n", n, substr(prev, 1, 12)
                for (i = 1; i <= n; i++) print "  " files[i]
                found = 1
            }
        }
        END { flush(); if (!found) print "Дубликатов не найдено." }
    '
