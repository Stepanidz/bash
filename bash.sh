#!/bin/bash

# Функция для обработки пользователей
function users() {
    getent passwd | awk -F: '{print $1, $6}' | sort
}

# Функция для обработки процессов
function processes() {
    ps -eo pid,comm --sort=pid
}

# Функция для вывода справки
function h_help() {
    echo "Использование: $0 [OPTIONS]"
    echo "Опции:"
    echo "  -u, --users         Вывести список пользователей и их домашних директорий."
    echo "  -p, --processes     Вывести список запущенных процессов."
    echo "  -h, --help          Показать это сообщение."
    echo "  -l PATH, --log PATH Выводить результаты в указанный файл."
    echo "  -e PATH, --errors PATH Выводить ошибки в указанный файл."
    exit 0
}

# Функция проверки доступности пути и создание файла, если необходимо
check_and_create_file() {
    local path="$1"
    if [[ ! -d "$(dirname "$path")" ]]; then
        echo "Ошибка: Директория '$path' не существует." >&2
        exit 1
    fi

    if [[ -f "$path" ]]; then
        echo "Предупреждение: Файл '$path' существует. Будет перезаписан." >&2
    fi
    touch "$path" # создаем файл если он не существует.
    # проверяем права на запись
    if [[ ! -w "$path" ]]; then
        echo "Ошибка: Нет прав на запись в '$path'" >&2
        exit 1
    fi
}

# Функция перенаправления стандартного вывода
redirect_stdout() {
    local log_file="$1"
    check_and_create_file "$log_file"
    exec > "$log_file"
}

# Функция перенаправления стандартного потока ошибок
redirect_stderr() {
    local error_file="$1"
    check_and_create_file "$error_file"
    exec 2>"$error_file"
}

# Функция обработки параметров
function parse_param() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--users)
                users
                shift
                ;;
            -p|--processes)
                processes
                shift
                ;;
            -h|--help)
                h_help
                ;;
            -l|--log)
                log_file="$2"
                redirect_stdout "$log_file"
                shift 2
                ;;
            -e|--errors)
                error_file="$2"
                redirect_stderr "$error_file"
                shift 2
                ;;
            *)
                echo "Ошибка: Неизвестный параметр $1" >&2
                exit 1
                ;;
        esac
    done
}

# Основной блок обработки аргументов
if [[ $# -eq 0 ]]; then
    echo "Ошибка: Не указаны параметры." >&2
    h_help
fi

parse_param "$@"

exit 0
