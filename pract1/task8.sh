#!/usr/bin/env bash
# Задача 8: найти в каталоге (с подкаталогами) все файлы с заданным
# расширением и упаковать их в tar-архив.
# Использование: ./task8.sh КАТАЛОГ РАСШИРЕНИЕ [ИМЯ_АРХИВА]
#   ./task8.sh ~/src c            -> ./c_files.tar
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Использование: $0 КАТАЛОГ РАСШИРЕНИЕ [ИМЯ_АРХИВА]" >&2
    exit 1
fi

dir="$1"
ext="${2#.}"                      # допускаем и "c", и ".c"
out="${3:-${ext}_files.tar}"

if [ ! -d "$dir" ]; then
    echo "Ошибка: '$dir' - не каталог" >&2
    exit 1
fi

# абсолютный путь архива, чтобы он не попал внутрь самого себя
out_abs="$(realpath -m -- "$out")"

count="$(find "$dir" -type f -name "*.$ext" ! -path "$out_abs" -printf '.' | wc -c)"
if [ "$count" -eq 0 ]; then
    echo "Файлов с расширением .$ext в '$dir' не найдено" >&2
    exit 1
fi

( cd "$dir" && find . -type f -name "*.$ext" ! -path "$out_abs" -print0 \
    | tar --null -cf "$out_abs" -T - )

echo "Упаковано файлов: $count -> $out_abs"
