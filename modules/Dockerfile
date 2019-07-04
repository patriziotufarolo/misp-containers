FROM python:3.6-alpine3.10
RUN apk --no-cache add \
        git \
        curl \
        g++ \
        linux-headers \
        python3-dev \
        libjpeg-turbo-dev \
        tesseract-ocr \
        imagemagick \
        ruby-pygments \
        libpq \
        zlib-dev \
        ruby-rdoc
RUN git clone https://github.com/MISP/misp-modules.git /usr/local/src/misp-modules && \
    cd /usr/local/src/misp-modules && pip3 install -I -r REQUIREMENTS && pip3 install -I .
RUN gem install asciidoctor-pdf --pre 
EXPOSE 9000
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
