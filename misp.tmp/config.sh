#!/bin/bash

#R_SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#R_SEED=$(cat /dev/urandom | tr -dc '0-9' | fold -w 30 | head -n 1)

MISP_DIRECTORY="/var/www/MISP"
CONFIG_DIRECTORY="$MISP_DIRECTORY/app/Config"

cat << EOF >> "$MISP_DIRECTORY/app/Plugin/CakeResque/Config/config.php"
\$config['CakeResque']['Redis']['host'] = env("REDIS_HOST") ? env("REDIS_HOST") : "localhost"; 
\$config['CakeResque']['Redis']['port'] = env("REDIS_PORT") ? env("REDIS_PORT") : "6379"; 
\$config['CakeResque']['Redis']['database'] = env("REDIS_DB") ? env("REDIS_DB") : 0; 
\$config['CakeResque']['Redis']['namespace'] = env("REDIS_NAMESPACE") ? env("REDIS_NAMESPACE") : "resque"; 
\$config['CakeResque']['Redis']['password'] = env("REDIS_PASSWORD") ? env("REDIS_PASSWORD") : null; 
EOF

sed -i -e 's,\(\t\x27datasource\x27 \?=> \?\)\(.*\)\(\,\)'",\1\'Database\/Mysql'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27host\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("DB_CONTAINER_ALIAS") ? env("DB_CONTAINER_ALIAS") : "database"\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27login\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_USER") ? env("MYSQL_USER") : "misp"\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27port\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_PORT") ? (int)env("MYSQL_PORT") : 3306\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27password\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_PASSWORD") ? env("MYSQL_PASSWORD") : "password"\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27database\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_DATABASE") ? env("MYSQL_DATABASE") : "misp"\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27prefix\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_PREFIX") ? env("MYSQL_PREFIX") : ""\3,g' "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27encoding\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MYSQL_ENCODING") ? env("MYSQL_ENCODING") : "utf8"\3,g' "$CONFIG_DIRECTORY/database.php"

#sed -i -e 's,\(\t\x27baseurl\x27 \?=> \?\)\(.*\)\(\,\)'",\1\'${MISP_BASEURL:-http://localhost}'\3,g" "$CONFIG_DIRECTORY/config.php"
#sed -i -e 's,\(\t\x27org\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MISP_ORG") ? env("MISP_ORG") : "Your Organization"\3,g' "$CONFIG_DIRECTORY/config.php"
#sed -i -e 's,\(\t\x27email\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MISP_EMAIL") ? env("MISP_EMAIL") : "em@il.org"\3,g' "$CONFIG_DIRECTORY/config.php"
#sed -i -e 's,\(\t\x27contact\x27 \?=> \?\)\(.*\)\(\,\)'',\1\env("MISP_CONTACT") ? env("MISP_CONTACT") : "em@il.org"\3,g' "$CONFIG_DIRECTORY/config.php"
#sed -i -e 's,\(\t\x27manage_workers\x27 \?=> \?\)\(.*\)\(\,\)'',\1false\3,g' "$CONFIG_DIRECTORY/config.php"
