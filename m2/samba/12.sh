#!/bin/bash

# Путь к CSV-файлу
CSV_FILE="users.csv"

# Проверка существования файла
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Файл $CSV_FILE не найден!"
    exit 1
fi

# Чтение CSV-файла и обработка данных
while IFS=";" read -r firstName lastName role phone ou street zip city country password; do
    # Пропуск заголовка
    if [[ "$firstName" == "First Name" ]]; then
        continue
    fi

    # Формирование имени пользователя в нижнем регистре
    username="${firstName,,} ${lastName,,}"

    # Проверка, существует ли пользователь
    if samba-tool user show "$username" &> /dev/null; then
        echo "Пользователь $username уже существует. Пропуск."
        continue
    fi

    # Добавление пользователя с заданным паролем из CSV
    if sudo samba-tool user add "$username" "$password"; then
        echo "Пользователь $username успешно создан с паролем $password!"
    else
        echo "Не удалось создать пользователя $username. Проверьте ошибки."
    fi
done < "$CSV_FILE"

echo "Импорт пользователей завершен."
