#!/usr/bin/env bash
# Задача 3: banner - вывод текста в рамке (размер рамки зависит от текста).
# Использование: ./banner.sh "Hello from RTU MIREA!"
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Использование: $0 ТЕКСТ" >&2
    exit 1
fi

# длина считается в символах, а не в байтах (важно для кириллицы)
if [ "$(locale charmap)" != "UTF-8" ]; then
    export LC_ALL=C.UTF-8
fi

text="$*"
line="$(printf '%*s' $(( ${#text} + 2 )) '' | tr ' ' '-')"

printf '+%s+\n' "$line"
printf '| %s |\n' "$text"
printf '+%s+\n' "$line"
