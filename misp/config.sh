#!/bin/bash

#R_SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#R_SEED=$(cat /dev/urandom | tr -dc '0-9' | fold -w 30 | head -n 1)

MISP_DIRECTORY="/var/www/MISP"
CONFIG_DIRECTORY="$MISP_DIRECTORY/app/Config"
mispcake="$MISP_DIRECTORY/app/Console/cake"
mispadmin="$mispcake Admin"
mispconfig="$mispadmin setSetting"


MAX_TRIES=5

function database_ready() {
    [[ $($mispcake Configurator.db_conn | tail -n 1) == 1 ]]
}

cat << EOF >> "$MISP_DIRECTORY/app/Plugin/CakeResque/Config/config.php"
\$config['CakeResque']['Redis']['host'] = "${REDIS_CONTAINER_ALIAS:-redis}"; 
\$config['CakeResque']['Redis']['port'] = 6379; 
\$config['CakeResque']['Redis']['database'] = 0; 
\$config['CakeResque']['Redis']['namespace'] = 'resque'; 
\$config['CakeResque']['Redis']['password'] = null; 
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
sleep 10
until database_ready || [ $MAX_TRIES -eq 0 ]; do
    echo "Not ready..., will give $((MAX_TRIES--)) more shots..."
    sleep 10
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
$mispconfig MISP.redis_database 13 
$mispconfig MISP.redis_password "${REDIS_PASSWORD}"
$mispconfig MISP.live 1
$mispconfig MISP.manage_workers 0

$mispconfig Plugin.Enrichment_hover_enable true

for plg in Enrichment Import Export
do
$mispconfig Plugin.${plg}_services_enable true
$mispconfig Plugin.${plg}_services_url http://"${MODULES_CONTAINER_ALIAS:-http://misp-modules}"
$mispconfig Plugin.${plg}_services_port 6666
done
$mispadmin runUpdates 
$mispadmin updateGalaxies
$mispadmin updateTaxonomies
$mispadmin updateWarningLists
$mispadmin updateNoticeLists
$mispadmin updateObjectTemplates "1337"
php-fpm
