#!/usr/bin/env bash
# Задача 1: отсортированный список имён пользователей из /etc/passwd.
# Имя пользователя - первое поле строки (до первого двоеточия).
set -euo pipefail

grep -o '^[^:]*' /etc/passwd | LC_ALL=C sort
