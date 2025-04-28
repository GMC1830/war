#!/bin/bash

# Путь к CSV-файлу
CSV_FILE="users.csv"

# Проверка существования файла
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Файл $CSV_FILE не найден!"
    exit 1
fi

# Чтение CSV-файла
while IFS=";" read -r firstName lastName role phone ou street zip city country password; do
    # Пропуск заголовка
    if [[ "$firstName" == "First Name" ]]; then
        continue
    fi

    # Формирование имени пользователя
    username="${firstName,,}.${lastName,,}"

    # Добавление пользователя с использованием samba-tool
    if samba-tool user add "$username" "$password"; then
        echo "Пользователь $username успешно создан!"
    else
        echo "Не удалось создать пользователя $username. Проверьте ошибки."
    fi

done < "$CSV_FILE"

echo "Импорт пользователей завершен."
