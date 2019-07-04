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
RUN apk add gcc g++ autoconf libtool make cmake linux-headers
RUN pip3 install virtualenv
RUN virtualenv /venv && echo -en "#!/bin/bash\nLD_LIBRARY_PATH=/venv/lib /venv/bin/python \"\$@\"" >  /venv/bin/python-wrapper ; chmod +x /venv/bin/python-wrapper
COPY --from=0 /misp/requirements.txt /venv/requirements.txt
RUN apk add libxml2-dev libxml2 libxslt-dev
ENV VIRTUAL_ENV=/venv
RUN /venv/bin/pip install -r /venv/requirements.txt
ENV SSDEEP ssdeep-2.13
RUN wget -O /tmp/$SSDEEP.tar.gz https://downloads.sourceforge.net/project/ssdeep/$SSDEEP/$SSDEEP.tar.gz \
  && cd /tmp \
  && tar zxvf $SSDEEP.tar.gz \
  && cd $SSDEEP \
  && ./configure --prefix=$VIRTUAL_ENV \
  && make -j$(nproc) \
  && make install \
  && CPPFLAGS="-L/venv/lib -I/venv/include" /venv/bin/pip  install git+https://github.com/kbandla/pydeep python-magic
RUN git clone https://github.com/lief-project/LIEF /tmp/lief && cd /tmp/lief && /venv/bin/python setup.py build_ext -j$(nproc) && /venv/bin/python setup.py install
RUN /venv/bin/pip install maec stix2 git+https://github.com/CybOXProject/python-cybox

FROM php:7.2-fpm-alpine
RUN apk add --update \
		autoconf \
		g++ \
		libtool \
        make \
        git \
        libmagic \
        gpgme \
        gpgme-dev libjpeg libjpeg-turbo-dev libpng libpng-dev freetype-dev libxml2-dev
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install -j$(nproc) pdo_mysql && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install -j$(nproc) mysqli && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/lib && \
    docker-php-ext-install -j$(nproc) gd mbstring xml bcmath opcache ; \
    pecl install -o -f redis gnupg && rm -rf /tmp/pear &&  docker-php-ext-enable redis

RUN apk del autoconf g++ libtool make gpgme-dev libjpeg-turbo-dev libpng-dev freetype-dev libxml2-dev

VOLUME /var/www/MISP
COPY --from=0 /misp /var/www/MISP
COPY --from=1 /venv /venv
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
RUN     apk add libmagic
