#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${PROJECT_DIR}/data"
LOCAL_DATA_DIR="${PROJECT_DIR}/local_data"

GENERATOR_IMAGE="hw3-generator"
REPORTER_IMAGE="hw3-reporter"
SERVER_CONTAINER="hw3-report-server"
REPORT_PORT="${REPORT_PORT:-8080}"

prepare_directories() {
    mkdir -p "${DATA_DIR}" "${LOCAL_DATA_DIR}"
}

require_file() {
    local file_path="$1"
    local hint="$2"

    if [[ ! -f "${file_path}" ]]; then
        echo "Ошибка: не найден файл ${file_path}." >&2
        echo "${hint}" >&2
        exit 1
    fi
}

show_help() {
    cat <<'EOF'
Использование: ./run.sh <команда>

Команды:
  build_generator    собрать образ генератора
  run_generator      создать data/data.csv через контейнер
  create_local_data  создать local_data/data.csv локально
  build_reporter     собрать образ аналитика
  run_reporter       создать data/report.html через контейнер
  structure          вывести структуру проекта
  clear_data         удалить CSV и HTML из data
  inside_generator   показать /data из контейнера генератора
  inside_reporter    показать /data из контейнера аналитика
  report_server      раздать data/report.html через nginx
EOF
}

prepare_directories

case "${1:-help}" in
    build_generator)
        docker build -t "${GENERATOR_IMAGE}" "${PROJECT_DIR}/generator"
        ;;
    run_generator)
        docker run --rm \
            --mount "type=bind,source=${DATA_DIR},target=/data" \
            "${GENERATOR_IMAGE}"
        echo "Данные сохранены: ${DATA_DIR}/data.csv"
        ;;
    create_local_data)
        python3 "${PROJECT_DIR}/generator/generate.py" "${LOCAL_DATA_DIR}"
        echo "Локальные данные сохранены: ${LOCAL_DATA_DIR}/data.csv"
        ;;
    build_reporter)
        docker build -t "${REPORTER_IMAGE}" "${PROJECT_DIR}/reporter"
        ;;
    run_reporter)
        require_file "${DATA_DIR}/data.csv" \
            "Сначала выполните: ./run.sh run_generator"
        docker run --rm \
            --mount "type=bind,source=${DATA_DIR},target=/data" \
            "${REPORTER_IMAGE}"
        echo "Отчёт сохранён: ${DATA_DIR}/report.html"
        ;;
    structure)
        (
            cd "${PROJECT_DIR}"
            find . -path './.git' -prune -o -print | sort
        )
        ;;
    clear_data)
        find "${DATA_DIR}" -maxdepth 1 -type f \
            \( -name '*.csv' -o -name '*.html' \) -delete
        echo "Сгенерированные данные удалены из ${DATA_DIR}"
        ;;
    inside_generator)
        docker run --rm \
            --mount "type=bind,source=${DATA_DIR},target=/data" \
            --entrypoint sh \
            "${GENERATOR_IMAGE}" \
            -c 'echo "Содержимое /data в generator:"; ls -la /data'
        ;;
    inside_reporter)
        docker run --rm \
            --mount "type=bind,source=${DATA_DIR},target=/data" \
            --entrypoint sh \
            "${REPORTER_IMAGE}" \
            -c 'echo "Содержимое /data в reporter:"; ls -la /data'
        ;;
    report_server)
        require_file "${DATA_DIR}/report.html" \
            "Сначала выполните: ./run.sh run_reporter"
        docker rm -f "${SERVER_CONTAINER}" >/dev/null 2>&1 || true
        docker run -d \
            --name "${SERVER_CONTAINER}" \
            -p "${REPORT_PORT}:80" \
            --mount "type=bind,source=${DATA_DIR},target=/usr/share/nginx/html,readonly" \
            nginx:alpine
        echo "Отчёт доступен по адресу: http://localhost:${REPORT_PORT}/report.html"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Неизвестная команда: $1" >&2
        show_help >&2
        exit 1
        ;;
esac
