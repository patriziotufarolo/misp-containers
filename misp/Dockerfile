FROM alpine:3.10
ARG MISP_TAG=2.4.123
RUN apk add --update git
RUN mkdir /misp
RUN git clone https://github.com/MISP/MISP.git /misp
#RUN cd /misp; git checkout tags/v${MISP_TAG};
WORKDIR /misp
RUN git config core.filemode false; git submodule update --init --recursive; git submodule update; git submodule foreach git config core.filemode false

FROM alpine:3.10
RUN apk add --update git
RUN apk add python3 py3-pip python3-dev cython3 gcc g++ autoconf libtool make cmake linux-headers libxml2-dev libxml2 libxslt-dev libmagic bash libffi-dev openssl-dev zeromq-dev cython
RUN pip3 install --upgrade pip
RUN pip3 install 'virtualenv<20'
RUN virtualenv --distribute /venv && virtualenv --relocatable /venv && echo -en "#!/bin/bash\nLD_LIBRARY_PATH=/venv/lib /venv/bin/python \"\$@\"" >  /venv/bin/python-wrapper ; chmod +x /venv/bin/python-wrapper
COPY --from=0 /misp/requirements.txt /venv/requirements.txt
ENV VIRTUAL_ENV=/venv
RUN . /venv/bin/activate && /venv/bin/pip install wheel
RUN . /venv/bin/activate && /venv/bin/pip install -r /venv/requirements.txt
ENV SSDEEP ssdeep-2.13
RUN . /venv/bin/activate \
  && wget -O /tmp/$SSDEEP.tar.gz https://downloads.sourceforge.net/project/ssdeep/$SSDEEP/$SSDEEP.tar.gz \
  && cd /tmp \
  && tar zxvf $SSDEEP.tar.gz \
  && cd $SSDEEP \
  && ./configure --prefix=$VIRTUAL_ENV \
  && make -j$(nproc) \
  && make install \
  && CPPFLAGS="-L/venv/lib -I/venv/include" pip install git+https://github.com/kbandla/pydeep python-magic
RUN . /venv/bin/activate && git clone https://github.com/lief-project/LIEF /tmp/lief && cd /tmp/lief && python setup.py build_ext -j$(nproc) && python setup.py install
RUN . /venv/bin/activate && pip install maec stix2 git+https://github.com/CybOXProject/python-cybox

FROM php:7.4-fpm-alpine3.10
RUN apk add --update \
		autoconf \
		g++ \
		libtool \
        make \
        git \
        gcc \
        libc-dev \
        libmagic \
        gpgme \
        bash \
        gpgme-dev libjpeg libjpeg-turbo-dev libpng libpng-dev freetype-dev libxml2-dev procps

ENV SSDEEP ssdeep-2.13
RUN wget -O /tmp/$SSDEEP.tar.gz https://downloads.sourceforge.net/project/ssdeep/$SSDEEP/$SSDEEP.tar.gz \
  && cd /tmp \
  && tar zxvf $SSDEEP.tar.gz \
  && cd $SSDEEP \
  && ./configure \
  && make -j$(nproc) \
  && make install 


RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install -j$(nproc) pdo_mysql && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install -j$(nproc) mysqli && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/lib && \
    docker-php-ext-install -j$(nproc) gd mbstring xml bcmath opcache ; \
    pecl install -o -f redis gnupg ssdeep && rm -rf /tmp/pear &&  docker-php-ext-enable redis && docker-php-ext-enable ssdeep && docker-php-ext-enable gnupg

RUN apk del autoconf g++ gcc libc-dev libtool make 

COPY --from=0 /misp /var/www/MISP
COPY --from=1 /venv /venv
RUN     mkdir /var/www/.composer && chown www-data:www-data /var/www/.composer
RUN     docker-php-ext-install -j$(nproc) pcntl
RUN     cd /var/www/MISP/app \
        ;wget https://getcomposer.org/download/1.10.1/composer.phar -O composer.phar \
        ;php composer.phar require kamisama/cake-resque:4.1.2 \
        ;php composer.phar config vendor-dir Vendor \
        ;php composer.phar install \
        ;chown -R www-data:www-data /var/www/MISP \
        ;chmod -R 750 /var/www/MISP \
        ;chmod -R g+ws /var/www/MISP/app/tmp \ 
        ;chmod -R g+ws /var/www/MISP/app/files \
        ;chmod -R g+ws /var/www/MISP/app/files/scripts/tmp
RUN echo 'expose_php = 0' >> /usr/local/etc/php/conf.d/docker-php-conf.ini
RUN echo 'safe_mode = on' >> /usr/local/etc/php/conf.d/docker-php-conf.ini
RUN echo 'magic_quotes_gpc = off' >> /usr/local/etc/php/conf.d/docker-php-conf.ini
RUN echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;
RUN echo 'upload_max_filesize = 50M' >> /usr/local/etc/php/conf.d/docker-php-max-filesize.ini
RUN echo 'post_max_size = 50M' >> /usr/local/etc/php/conf.d/docker-php-max-filesize.ini
RUN echo 'max_execution_time = 300' >> /usr/local/etc/php/conf.d/docker-php-max-execution-time.ini
RUN     cd /var/www/MISP/app/Config ;\
        for cfg_default in *.default.php; do mv -v "$cfg_default" "${cfg_default/.default/}"; done 
#RUN        R_SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1); \ 
#        sed -i -e 's/\(\x27Security.salt\x27, \?\x27\).\{32\}\(\x27);\)/\1RANDOM_GENERATED_SALT\2/g' -e "s,RANDOM_GENERATED_SALT,${R_SALT}," core.php; \
#        R_SEED=$(cat /dev/urandom | tr -dc '0-9' | fold -w 30 | head -n 1); \
#        sed -i -e 's/\(\x27Security.cipherSeed\x27, \?\x27\).\{30\}\(\x27);\)/\1RANDOM_GENERATED_SEED\2/g' -e "s,RANDOM_GENERATED_SEED,${R_SEED}," core.php

# TMP , TO BE REMOVED LATER , PATCHES /var/www/MISP/app/View/Servers/ajax/submoduleStatus.ctp
RUN sed -i -e 's, _(, __(,g' /var/www/MISP/app/View/Servers/ajax/submoduleStatus.ctp \
&&  sed -i -e 's,(_(,(__(,g' /var/www/MISP/app/View/Servers/ajax/submoduleStatus.ctp

USER    www-data

ADD 01-cakeresque.patch /tmp
RUN cd /var/www/MISP/app/Plugin/CakeResque/Console/Command; \
    patch CakeResqueShell.php < /tmp/01-cakeresque.patch

ADD config.sh /
RUN ["mkdir", "-p", "/var/www/MISP/app/Plugin/Configurator/Console/Command"]
ADD ConfiguratorShell.php /var/www/MISP/app/Plugin/Configurator/Console/Command
ADD DbConnShell.php /var/www/MISP/app/Plugin/Configurator/Console/Command

WORKDIR "/var/www/MISP"
CMD ["/config.sh"]
