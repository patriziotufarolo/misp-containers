FROM misp:latest

FROM mariadb:latest
COPY --from=0 /var/www/MISP/INSTALL/MYSQL.sql /docker-entrypoint-initdb.d 
