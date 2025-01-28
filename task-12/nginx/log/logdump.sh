#!/bin/bash

# Создаем директорию для логов, если она не существует
LOG_DIR="/var/log/nginx/dump"
mkdir -p "$LOG_DIR"

# Создаем файлы для логов, если они не существуют
FILE_1="$LOG_DIR/log_1.log"
FILE_2="$LOG_DIR/log_2.log"
FILE_3="$LOG_DIR/log_3.log"
FILE_4="$LOG_DIR/log_4.log"

touch "$FILE_1" "$FILE_2" "$FILE_3" "$FILE_4"

# Получение даты последнего задампленного лога из файла 1
get_last_dumped_log_time() {
  if [[ -s "$FILE_1" ]]; then
    # Если файл 1 не пустой, получаем время последней записи из него
    last_log_time=$(tail -n 1 "$FILE_1" | awk '{print $1}')
  else
    # Если файл 1 пустой, проверяем файл 2
    if [[ -s "$FILE_2" ]]; then
      # Если файл 2 не пустой, получаем время последней очистки из него
      # Time: *** Cleared: ***
      last_log_time=$(tail -n 1 "$FILE_2" | awk '{print $2}')
    else
      # Если файл 2 пустой, инициализируем его текущим временем и 0 очищенных записей
      current_time=$(date +%s)
      echo "Time: $current_time Cleared: 0" > "$FILE_2"
      last_log_time=$current_time
    fi
  fi

  echo "$last_log_time"
}

ACCESS_PATH="$LOG_DIR/../access.log"
ERROR_PATH="$LOG_DIR/../error.log"

make_unix_time() {
    local time_filter=$1
    local log_file=$2
    awk -v OFS=" " -v start_time="$time_filter" '{
        # Преобразование даты и времени в Unix timestamp
        split($1, date, "/");
        split($2, time, ":");
        unix_time = mktime(date[1] " " date[2] " " date[3] " " time[1] " " time[2] " " time[3]);

        if (unix_time > start_time) {
            $1 = unix_time;
            # NOTE: Остается лишний пробел
            $2 = "";
            print $0;
        }
    }' "$log_file" 
}

filter_merge_sort() {
    TMP_FILE_PATH="$LOG_DIR/tmp.log"
    touch "$TMP_FILE_PATH"
    local last_log_time=$(get_last_dumped_log_time)
    make_unix_time "$last_log_time" "$ACCESS_PATH" > "$TMP_FILE_PATH"
    make_unix_time "$last_log_time" "$ERROR_PATH" >> "$TMP_FILE_PATH"

    # 4xx
    awk '$8 ~ /^4[0-9][0-9]$/ {
        print $0
    }' "$TMP_FILE_PATH" >> "$FILE_4"

    # 5xx
    awk '$8 ~ /^5[0-9][0-9]$/ {
        print $0
    }' "$TMP_FILE_PATH" >> "$FILE_3"

    sort -n "$TMP_FILE_PATH"
    rm "$TMP_FILE_PATH"
}

truncate_log() {
  local log_file="$1"
  local truncate_log_file="$2"
  local max_size_kb=300
  local count=0

  # Получаем размер файла в килобайтах
  size_kb=$(wc -c < "$log_file" | awk '{print int($1 / 1024)}')

  if (( size_kb >= max_size_kb )); then
    # Считаем количество строк в файле
    count=$(wc -l < "$log_file")

    # Получаем текущее время в формате Unix timestamp
    current_time=$(date +%s)

    # Записываем информацию об очистке в truncate_log_file
    echo "Time: $current_time Cleared: $count" >> "$truncate_log_file"

    # Очищаем log_file
    truncate -s 0 "$log_file"
  fi
}

while true
do
    filter_merge_sort >> "$FILE_1"
    truncate_log "$FILE_1" "$FILE_2"
    sleep 5
done
