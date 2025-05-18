#!/bin/bash


bash << 'EOF'
BASE_HOMEDIR="/home/AU-TEAM.IRPO"
DOMAIN_REALM="au-team.irpo"
SKEL_DIR="/etc/skel"
mkdir -p "${BASE_HOMEDIR}" && chmod 755 "${BASE_HOMEDIR}" || exit 1
echo ">>> Создание домашних каталогов user1.hq - user5.hq..."
for i in {1..5}; do
  user_name="user${i}.hq"
  full_user_name="${user_name}@${DOMAIN_REALM}"
  lower_user_name=$(echo "${user_name}" | tr '[:upper:]' '[:lower:]')
  user_home_dir="${BASE_HOMEDIR}/${lower_user_name}"
  echo -n "Обработка ${full_user_name}... "
  user_uid=$(id -u "${full_user_name}" 2>/dev/null)
  user_gid=$(id -g "${full_user_name}" 2>/dev/null)
  if [ -n "$user_uid" ] && [ -n "$user_gid" ]; then
    if [ ! -d "${user_home_dir}" ]; then
        install -d -o "${user_uid}" -g "${user_gid}" -m 700 "${user_home_dir}" || { echo "Ошибка install."; continue; }
    fi
    if [ $? -eq 0 ]; then # Проверяем код возврата install
        cp -aT "${SKEL_DIR}/" "${user_home_dir}/" && chown -R "${user_uid}:${user_gid}" "${user_home_dir}" && chmod 700 "${user_home_dir}" && echo "Готово." || echo "Ошибка копирования/прав."
    else
        echo "Каталог уже существовал или ошибка создания."
    fi
  else
    echo "Ошибка: Не удалось получить UID/GID."
  fi
done
echo "<<< Создание домашних каталогов завершено."
exit 0
EOF

