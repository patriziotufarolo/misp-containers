FROM misp:latest

FROM mariadb:latest
COPY --from=0 /var/www/MISP/INSTALL/MYSQL.sql /docker-entrypoint-initdb.d 
RUN sed -i '1 i\\ \
USE misp' /docker-entrypoint-initdb.d/MYSQL.sql
