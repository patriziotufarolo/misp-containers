#!/bin/bash

#R_SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#R_SEED=$(cat /dev/urandom | tr -dc '0-9' | fold -w 30 | head -n 1)

MISP_DIRECTORY="/var/www/MISP"
CONFIG_DIRECTORY="$MISP_DIRECTORY/app/Config"
mispconfig="$MISP_DIRECTORY/app/Console/cake Configurator"


MAX_TRIES=5

function database_ready() {
    [[ $($mispconfig.db_conn | tail -n 1) == 1 ]]
}

cat << EOF >> "$MISP_DIRECTORY/app/Plugin/CakeResque/Config/config.php"
\$config['CakeResque']['Redis']['host'] = env("REDIS_HOST") ? env("REDIS_HOST") : "localhost"; 
\$config['CakeResque']['Redis']['port'] = env("REDIS_PORT") ? env("REDIS_PORT") : "6379"; 
\$config['CakeResque']['Redis']['database'] = env("REDIS_DB") ? env("REDIS_DB") : 0; 
\$config['CakeResque']['Redis']['namespace'] = env("REDIS_NAMESPACE") ? env("REDIS_NAMESPACE") : "resque"; 
\$config['CakeResque']['Redis']['password'] = env("REDIS_PASSWORD") ? env("REDIS_PASSWORD") : null; 
EOF

sed -i -e 's,\(\t\x27datasource\x27 \?=> \?\)\(.*\)\(\,\)'",\1\'Database\/Mysql'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27host\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${DB_CONTAINER_ALIAS:-database}'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27login\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${MYSQL_USER:-misp}'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27port\x27 \?=> \?\)\(.*\)\(\,\),'"\1${MYSQL_PORT:-3306}\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27password\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${MYSQL_PASSWORD}'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27database\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${MYSQL_DATABASE:-misp}'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27prefix\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${MYSQL_PREFIX}'\3,g" "$CONFIG_DIRECTORY/database.php"
sed -i -e 's,\(\t\x27encoding\x27 \?=> \?\)\(.*\)\(\,\),'"\1'${MYSQL_ENCODING:-utf8}'\3,g" "$CONFIG_DIRECTORY/database.php"


echo "Waiting MariaDB to be initialized..."
sleep 5
until database_ready || [ $MAX_TRIES -eq 0 ]; do
    echo "Not ready..., will do other $((MAX_TRIES--)) attempts..."
    sleep 5
done
if [ $MAX_TRIES -eq 0 ]
then
    echo "Database not ready... bye bye..."
    exit 1
fi

echo "Ok database ready... going further..."


$mispconfig MISP.baseurl "${MISP_BASEURL:-http://misp}"
$mispconfig MISP.baseurl "${MISP_EXTERNAL_BASEURL:-${MISP_BASEURL:-http://misp}}"
$mispconfig MISP.python_bin "/venv/bin/python"
$mispconfig MISP.redis_host "${REDIS_CONTAINER_ALIAS}" 
$mispconfig MISP.redis_port 6379 
$mispconfig MISP.redis_database 1 
$mispconfig MISP.redis_password "${REDIS_PASSWORD}"
$mispconfig MISP.live true 
$mispconfig MISP.manage_workers false

php-fpm
