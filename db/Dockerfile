FROM misp:latest
USER root 
RUN chown root:root /var/www/MISP/INSTALL/MYSQL.sql
FROM mariadb:latest
COPY --from=0 /var/www/MISP/INSTALL/MYSQL.sql /docker-entrypoint-initdb.d/01-init.sql
run chown root:root /docker-entrypoint-initdb.d/01-init.sql && chmod 644 /docker-entrypoint-initdb.d/01-init.sql
#RUN sed -i '1 i\\ \
#USE misp' /docker-entrypoint-initdb.d/MYSQL.sql
