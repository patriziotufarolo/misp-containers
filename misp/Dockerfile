FROM alpine:3.10
ARG MISP_TAG=2.4.109 
RUN apk add --update git
RUN mkdir /misp
RUN git clone https://github.com/MISP/MISP.git /misp; cd /misp; git checkout tags/v${MISP_TAG};
WORKDIR /misp
RUN git config core.filemode false; git submodule init; git submodule update; git submodule foreach git config core.filemode false

FROM alpine:3.10
RUN apk add --update git
RUN apk add python3 py3-pip python3-dev
RUN apk add gcc g++ autoconf libtool make 
RUN pip3 install virtualenv
RUN virtualenv /venv
COPY --from=0 /misp/requirements.txt /venv/requirements.txt
RUN apk add linux-headers
RUN apk add libxml2-dev libxml2
RUN apk add libxslt-dev
ENV VIRTUAL_ENV=/venv
RUN /venv/bin/pip install -r /venv/requirements.txt
ENV SSDEEP ssdeep-2.13
RUN wget -O /tmp/$SSDEEP.tar.gz https://downloads.sourceforge.net/project/ssdeep/$SSDEEP/$SSDEEP.tar.gz \
  && cd /tmp \
  && tar zxvf $SSDEEP.tar.gz \
  && cd $SSDEEP \
  && ./configure --prefix=$VIRTUAL_ENV \
  && make \
  && make install \
  && CPPFLAGS="-L/venv/lib -I/venv/include" /venv/bin/pip install git+https://github.com/kbandla/pydeep
RUN /venv/bin/pip install python-magic maec stix2

FROM php:7.2-fpm-alpine
RUN apk add --update \
		autoconf \
		g++ \
		libtool \
        make
RUN apk add --update libjpeg libjpeg-turbo-dev libpng libpng-dev freetype-dev libxml2-dev
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install -j$(nproc) pdo_mysql && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install -j$(nproc) mysqli && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && \
    docker-php-ext-install -j$(nproc) gd mbstring xml bcmath opcache
RUN apk add gpgme gpgme-dev
RUN	pecl install -o -f redis gnupg && rm -rf /tmp/pear &&  docker-php-ext-enable redis
VOLUME /var/www/MISP
COPY --from=0 /misp /var/www/MISP
COPY --from=1 /venv /venv
RUN cp -R /venv/lib/* /usr/lib
RUN cp -R /venv/include/* /usr/include/
RUN     docker-php-ext-install -j$(nproc) pcntl
RUN     cd /var/www/MISP/app \
        ;php composer.phar require kamisama/cake-resque:4.1.2 \
        ;php composer.phar config vendor-dir Vendor \
        ;php composer.phar install \
        ;chown -R www-data:www-data /var/www/MISP \
        ;chmod -R 750 /var/www/MISP \
        ;chmod -R g+ws /var/www/MISP/app/tmp \ 
        ;chmod -R g+ws /var/www/MISP/app/files \
        ;chmod -R g+ws /var/www/MISP/app/files/scripts/tmp
