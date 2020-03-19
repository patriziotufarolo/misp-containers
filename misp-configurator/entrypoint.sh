#!/bin/bash

#R_SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#R_SEED=$(cat /dev/urandom | tr -dc '0-9' | fold -w 30 | head -n 1)

cat << EOF >> /var/www/MISP/app/Plugin/CakeResque/Config/config.php
\$config['CakeResque']['Redis']['host'] = env("REDIS_HOST") ? env("REDIS_HOST") : "localhost"; 
\$config['CakeResque']['Redis']['port'] = env("REDIS_PORT") ? env("REDIS_PORT") : "6379"; 
\$config['CakeResque']['Redis']['database'] = env("REDIS_DB") ? env("REDIS_DB") : 0; 
\$config['CakeResque']['Redis']['namespace'] = env("REDIS_NAMESPACE") ? env("REDIS_NAMESPACE") : "resque"; 
\$config['CakeResque']['Redis']['password'] = env("REDIS_PASSWORD")?env("REDIS_PASSWORD") : null; 
EOF
