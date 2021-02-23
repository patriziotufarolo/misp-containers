#!/bin/bash
MISP_DIRECTORY="/var/www/MISP"
CONFIG_DIRECTORY="$MISP_DIRECTORY/app/Config"
mispcake="$MISP_DIRECTORY/app/Console/cake"
mispadmin="$mispcake Admin"
mispconfig="$mispadmin setSetting"

cat << EOF >> "$MISP_DIRECTORY/app/Plugin/CakeResque/Config/config.php"
\$config['CakeResque']['Redis']['host'] = "${REDIS_CONTAINER_ALIAS:-redis}"; 
\$config['CakeResque']['Redis']['port'] = 6379; 
\$config['CakeResque']['Redis']['database'] = 0; 
\$config['CakeResque']['Redis']['namespace'] = 'resque'; 
\$config['CakeResque']['Redis']['password'] = null; 
EOF

eval $@
