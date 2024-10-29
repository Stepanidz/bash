#!/bin/bash

# Функции для обработки различных аргументов
list_users() {
    awk -F: '{ print $1 " " $6 }' /etc/passwd | sort
}

list_processes() {
    ps -e --sort pid
}

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -u, --users           List users and their home directories, sorted alphabetically"
    echo "  -p, --processes       List running processes, sorted by PID"
    echo "  -h, --help            Display this help message"
    echo "  -l PATH, --log PATH   Redirect output to the specified log file"
    echo "  -e PATH, --errors PATH Redirect error output to the specified error file"
}

# Инициализация переменных для путей
LOG_PATH=""
ERROR_PATH=""

# Обработка аргументов командной строки с использованием getopts
while getopts ":uphl:e:-:" opt; do
    case $opt in
        u) action="users" ;;
        p) action="processes" ;;
        h) action="help" ;;
        l) LOG_PATH="$OPTARG" ;;
        e) ERROR_PATH="$OPTARG" ;;
        -)
            case "${OPTARG}" in
                users) action="users" ;;
                processes) action="processes" ;;
                help) action="help" ;;
                log) LOG_PATH="${!OPTIND}"; OPTIND=$((OPTIND + 1)) ;;
                errors) ERROR_PATH="${!OPTIND}"; OPTIND=$((OPTIND + 1)) ;;
                *)
                    echo "Invalid option: --$OPTARG" >&2
                    exit 1
                    ;;
            esac
            ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done

# Проверка и установка перенаправления потоков, если указаны пути
if [ -n "$LOG_PATH" ]; then
    if [ -w "$LOG_PATH" ] || [ ! -e "$LOG_PATH" ]; then
        exec > "$LOG_PATH"
    else
        echo "Error: Cannot write to log path $LOG_PATH" >&2
        exit 1
    fi
fi

if [ -n "$ERROR_PATH" ]; then
    if [ -w "$ERROR_PATH" ] || [ ! -e "$ERROR_PATH" ]; then
        exec 2> "$ERROR_PATH"
    else
        echo "Error: Cannot write to error path $ERROR_PATH" >&2
        exit 1
    fi
fi

# Выполнение действия в зависимости от аргумента
case $action in
    users) list_users ;;
    processes) list_processes ;;
    help) print_help ;;
    *)
        echo "No valid action specified." >&2
        print_help
        exit 1
        ;;
esac
