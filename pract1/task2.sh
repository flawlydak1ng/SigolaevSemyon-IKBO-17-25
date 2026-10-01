#!/usr/bin/env bash
# Задача 2: 5 протоколов с наибольшими номерами из /etc/protocols.
# Формат строки файла:  имя  номер  АЛИАС  # комментарий
# Вывод:                номер имя   (по убыванию номера)
set -euo pipefail

grep -v '^[[:space:]]*#' /etc/protocols \
    | awk 'NF >= 2 { print $2, $1 }' \
    | sort -rn \
    | head -n 5
