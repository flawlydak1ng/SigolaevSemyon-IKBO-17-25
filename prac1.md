# Практическое занятие №1. Командная строка

## Задача 1

```bash
#!/usr/bin/env bash
# Задача 1: отсортированный список имён пользователей из /etc/passwd.
# Имя пользователя - первое поле строки (до первого двоеточия).
set -euo pipefail

grep -o '^[^:]*' /etc/passwd | LC_ALL=C sort
```

```bash
./task1.sh
```


## Задача 2

```bash
#!/usr/bin/env bash
# Задача 2: 5 протоколов с наибольшими номерами из /etc/protocols.
# Формат строки файла:  имя  номер  АЛИАС  # комментарий
# Вывод:                номер имя   (по убыванию номера)
set -euo pipefail

grep -v '^[[:space:]]*#' /etc/protocols \
    | awk 'NF >= 2 { print $2, $1 }' \
    | sort -rn \
    | head -n 5
```

```bash
./task2.sh
```

```text
262 mptcp
143 ethernet
142 rohc
141 wesp
140 shim6
```

## Задача 3

```bash
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
```

```bash
./banner.sh 'Hello from RTU MIREA!'
```

```text
+-----------------------+
| Hello from RTU MIREA! |
+-----------------------+
```

## Задача 4

```bash
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
```

```bash
./task4.sh hello.c
```

```text
h hello include int main n printf return stdio void world
```

## Задача 5

```bash
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
```

```bash
sudo ./reg.sh banner
```

```text
Команда 'banner' зарегистрирована: /usr/local/bin/banner
```

## Задача 6

```bash
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
```

```bash
./task6.sh .
```


## Задача 7

```bash
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
```

```bash
./task7.sh .
```


## Задача 8

```bash
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
```

```bash
./task8.sh . c out.tar
```


## Задача 9

```bash
#!/usr/bin/env bash
# Задача 9: замена каждой последовательности из 4 пробелов на табуляцию.
# Использование: ./task9.sh ВХОДНОЙ_ФАЙЛ ВЫХОДНОЙ_ФАЙЛ
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Использование: $0 ВХОДНОЙ_ФАЙЛ ВЫХОДНОЙ_ФАЙЛ" >&2
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "Ошибка: входной файл '$1' не найден" >&2
    exit 1
fi
if [ "$1" -ef "$2" ]; then
    echo "Ошибка: входной и выходной файлы должны различаться" >&2
    exit 1
fi

tab="$(printf '\t')"
sed "s/ \{4\}/${tab}/g" -- "$1" > "$2"
```

```bash
./task9.sh input.txt output.txt
```


## Задача 10

```bash
#!/usr/bin/env bash
# Задача 10: имена всех пустых текстовых файлов (*.txt) в каталоге
# (включая подкаталоги). Каталог передаётся параметром.
# Необязательный 2-й параметр - маска имён (по умолчанию '*.txt').
# Использование: ./task10.sh КАТАЛОГ [МАСКА]
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ] || [ ! -d "$1" ]; then
    echo "Использование: $0 КАТАЛОГ [МАСКА]" >&2
    exit 1
fi

find "$1" -type f -empty -name "${2:-*.txt}" | sort
```

```bash
./task10.sh .
```
