FROM alpine:3.10
ARG MISP_TAG=2.4.120
RUN apk add --update git
RUN mkdir /misp
RUN git clone https://github.com/MISP/MISP.git /misp; cd /misp; git checkout tags/v${MISP_TAG};
WORKDIR /misp
RUN git config core.filemode false; git submodule update --init --recursive; git submodule update; git submodule foreach git config core.filemode false

FROM alpine:3.10
RUN apk add --update git
RUN apk add --update python3 py3-pip python3-dev cython3 gcc g++ autoconf libtool make cmake linux-headers libxml2-dev libxml2 libxslt-dev libmagic bash libffi-dev openssl-dev zeromq-dev cython
RUN pip3 install 'virtualenv<20'
RUN virtualenv --distribute /venv && virtualenv --relocatable /venv && echo -en "#!/bin/bash\nLD_LIBRARY_PATH=/venv/lib /venv/bin/python \"\$@\"" >  /venv/bin/python-wrapper ; chmod +x /venv/bin/python-wrapper
COPY --from=0 /misp/requirements.txt /venv/requirements.txt
ENV VIRTUAL_ENV=/venv
#RUN /venv/bin/pip install wheel
#RUN /venv/bin/pip install -r /venv/requirements.txt
#RUN /venv/bin/pip install maec stix2 git+https://github.com/CybOXProject/python-cybox
