# Домашнее задание №3: Docker и Bash

Проект генерирует CSV-файл с данными о заказах доставки и создаёт по нему
HTML-отчёт. Генератор и аналитик работают в отдельных Docker-контейнерах.
Каталог `data/` монтируется в контейнеры, поэтому результаты сохраняются на
хосте и доступны после завершения контейнеров.

## Структура проекта

```text
.
├── data/                   # CSV и HTML, созданные контейнерами
├── generator/
│   ├── Dockerfile
│   └── generate.py
├── local_data/             # CSV для локальной отладки
├── reporter/
│   ├── Dockerfile
│   ├── package.json
│   └── report.js
├── HW.ipynb
├── README.md
└── run.sh
```

## Быстрый запуск

Требования: Bash, Python 3 для локальной проверки и запущенный Docker.

```bash
chmod +x run.sh

./run.sh build_generator
./run.sh run_generator

./run.sh build_reporter
./run.sh run_reporter
```

После выполнения команд появятся:

- `data/data.csv` — сгенерированные данные;
- `data/report.html` — HTML-отчёт.

## Команды

```bash
./run.sh build_generator
```

Собирает образ `hw3-generator` из каталога `generator/`.

```bash
./run.sh run_generator
```

Запускает генератор и монтирует локальный каталог `data/` в `/data`
контейнера. Генератор записывает результат в `/data/data.csv`, поэтому файл
появляется на хосте как `data/data.csv`.

```bash
./run.sh create_local_data
```

Запускает Python-скрипт без Docker и создаёт `local_data/data.csv`.

```bash
./run.sh build_reporter
./run.sh run_reporter
```

Собирает образ `hw3-reporter`, устанавливая Node.js-зависимости во время
сборки, а затем создаёт `data/report.html` на основе `data/data.csv`.

```bash
./run.sh structure
./run.sh clear_data
./run.sh inside_generator
./run.sh inside_reporter
```

- `structure` выводит структуру проекта;
- `clear_data` удаляет файлы `.csv` и `.html` из `data/`;
- `inside_generator` показывает содержимое `/data` из контейнера генератора;
- `inside_reporter` показывает содержимое `/data` из контейнера аналитика.

После `clear_data` результаты можно пересоздать:

```bash
./run.sh run_generator
./run.sh run_reporter
```

## Веб-сервер

Сначала создайте отчёт, затем запустите nginx:

```bash
./run.sh report_server
```

Команда запускает контейнер `hw3-report-server`, монтирует `data/` в каталог
nginx только для чтения и публикует порт контейнера `80` на порту хоста
`8080`. Локально отчёт доступен по адресу:

```text
http://localhost:8080/report.html
```

Порт можно изменить через переменную окружения:

```bash
REPORT_PORT=8090 ./run.sh report_server
```

Чтобы остановить веб-сервер:

```bash
docker rm -f hw3-report-server
```

## Открытие отчёта в GitHub Codespaces

1. Откройте публичный репозиторий на GitHub и нажмите **Code → Codespaces →
   Create codespace on main**.
2. В терминале Codespaces перейдите в каталог `docker_bi/HW`.
3. Выполните команды из раздела «Быстрый запуск», затем
   `./run.sh report_server`.
4. Откройте вкладку **Ports** в нижней панели Codespaces.
5. Найдите порт `8080`. При необходимости нажмите на него правой кнопкой,
   выберите **Port Visibility → Public**.
6. Нажмите **Open in Browser** и добавьте к выданному Codespaces адресу путь
   `/report.html`.

Запрос проходит по следующей цепочке:

```text
браузер
  → публичный HTTPS-адрес, созданный GitHub Codespaces для порта 8080
  → порт 8080 виртуальной машины Codespaces
  → опубликованный порт 80 контейнера nginx
  → /usr/share/nginx/html/report.html внутри контейнера
  → data/report.html в рабочем каталоге Codespaces через bind mount
```

GitHub Codespaces перенаправляет внешний HTTPS-запрос на порт виртуальной
машины. Флаг Docker `-p 8080:80` направляет запрос дальше в nginx-контейнер,
а bind mount предоставляет nginx доступ к отчёту, который хранится на хосте.

## Источники

- [Docker: Bind mounts](https://docs.docker.com/engine/storage/bind-mounts/)
- [Docker: Publishing and exposing ports](https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/)
- [GitHub Docs: Forwarding ports in your codespace](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace)
