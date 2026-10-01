# Практическое занятие №1. Командная строка

## Задача 1

`task1.sh`:

```bash
#!/bin/bash
# Берём первое поле каждой строки (до ':') и сортируем
grep -o '^[^:]*' /etc/passwd | sort
```

```bash
bash task1.sh
```

## Задача 2

`task2.sh`:

```bash
#!/bin/bash
# Меняем столбцы местами (номер, имя), сортируем по номеру по убыванию, берём 5
awk '!/^#/ && NF {print $2, $1}' /etc/protocols | sort -nr | head -5
```

```bash
bash task2.sh
```

```text
262 mptcp
143 ethernet
142 rohc
141 wesp
140 shim6
```

## Задача 3

`banner.sh`:

```bash
#!/bin/bash
# Длина рамки = длина текста + 2: строим строку из пробелов и заменяем их на '-'
text="$*"
line=$(printf '%*s' $((${#text} + 2)) '' | tr ' ' '-')
echo "+$line+"
echo "| $text |"
echo "+$line+"
```

```bash
bash banner.sh 'Hello from RTU MIREA!'
```

```text
+-----------------------+
| Hello from RTU MIREA! |
+-----------------------+
```

## Задача 4

`task4.sh`:

```bash
#!/bin/bash
# Находим все слова вида [буква или _][буквы, цифры, _], убираем повторы
grep -oE '[A-Za-z_][A-Za-z0-9_]*' "$1" | sort -u | xargs
```

```bash
bash task4.sh hello.c
```

```text
h hello include int main n printf return stdio void world
```

## Задача 5

`reg.sh`:

```bash
#!/bin/bash
# Даём права на запуск (rwxr-xr-x) и копируем команду в /usr/local/bin
chmod 755 "$1"
cp "$1" /usr/local/bin/
```

```bash
sudo bash reg.sh banner
```

## Задача 6

`task6.sh`:

```bash
#!/bin/bash
# Для каждого .c/.js/.py файла проверяем, что первая строка - комментарий
find "$1" -name '*.c' -o -name '*.js' -o -name '*.py' | while read -r f; do
    case "$f" in
        *.py) mark='^#' ;;
        *)    mark='^(//|/\*)' ;;
    esac
    if head -n 1 "$f" | grep -qE "$mark"; then
        echo "есть комментарий: $f"
    else
        echo "НЕТ комментария: $f"
    fi
done
```

```bash
bash task6.sh .
```

## Задача 7

`task7.sh`:

```bash
#!/bin/bash
# Считаем md5 каждого файла: одинаковый хеш = одинаковое содержимое (дубликаты)
find "$1" -type f -exec md5sum {} + | sort | uniq -w32 -D
```

```bash
bash task7.sh .
```

## Задача 8

`task8.sh`:

```bash
#!/bin/bash
# Ищем файлы с расширением $2 в каталоге $1 и упаковываем их в files.tar
find "$1" -name "*.$2" | tar -cf files.tar -T -
```

```bash
bash task8.sh . c
```

## Задача 9

`task9.sh`:

```bash
#!/bin/bash
# Заменяем каждые 4 пробела на табуляцию: из файла $1 в файл $2
sed 's/ \{4\}/\t/g' "$1" > "$2"
```

```bash
bash task9.sh input.txt output.txt
```

## Задача 10

`task10.sh`:

```bash
#!/bin/bash
# Ищем пустые (-empty) файлы с расширением .txt в каталоге $1
find "$1" -type f -name '*.txt' -empty
```

```bash
bash task10.sh .
```
