#!/usr/bin/env bash

set -o pipefail

usage() {
    echo "Использование:"
    echo "  $0 <каталог> <ERROR|WARN> [--top N]"
    echo
    echo "Пример:"
    echo "  $0 ./logs ERROR"
    echo "  $0 ./logs WARN --top 3"
}

# Проверяем наличие обязательных аргументов
if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

DIR="$1"
LEVEL="$2"
TOP=0

# Проверяем уровень сообщений
if [[ "$LEVEL" != "ERROR" && "$LEVEL" != "WARN" ]]; then
    echo "Ошибка: уровень должен быть ERROR или WARN."
    usage
    exit 1
fi

# Обрабатываем дополнительные аргументы
shift 2

while [[ $# -gt 0 ]]; do
    case "$1" in
        --top)
            if [[ $# -lt 2 ]]; then
                echo "Ошибка: после --top необходимо указать число."
                exit 1
            fi

            if [[ ! "$2" =~ ^[1-9][0-9]*$ ]]; then
                echo "Ошибка: N должно быть положительным целым числом."
                exit 1
            fi

            TOP="$2"
            shift 2
            ;;
        *)
            echo "Ошибка: неизвестный аргумент $1"
            usage
            exit 1
            ;;
    esac
done

# Проверяем существование каталога
if [[ ! -d "$DIR" ]]; then
    echo "Ошибка: каталог '$DIR' не существует."
    exit 1
fi

# Ищем файлы внутри каталога и подсчитываем сообщения
find "$DIR" -type f -print0 |
while IFS= read -r -d '' file; do
    awk -v level="$LEVEL" '
        $2 == level {
            print $3
        }
    ' "$file"
done |
sort |
uniq -c |
sort -k1,1nr -k2,2 |
awk -v top="$TOP" '
    BEGIN {
        printf "%-20s | %s\n", "Модуль", "Количество"
        printf "%-20s-+-%s\n", "--------------------", "----------"
    }

    {
        if (top > 0 && NR > top) {
            exit
        }

        printf "%-20s | %d\n", $2, $1
    }
'
