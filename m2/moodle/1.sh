#!/bin/bash


   # Установите пароль для root
   NEW_PASSWORD="P@ssw0rd"

   # Запуск mysql_secure_installation с автоматическими ответами
   mysql_secure_installation <<EOF

# Установите текущий пароль root (если он не установлен, просто нажмите Enter)
$NEW_PASSWORD
Y
$NEW_PASSWORD
$NEW_PASSWORD
Y
Y
Y
Y
EOF
   



