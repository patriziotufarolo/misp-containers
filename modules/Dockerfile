FROM python:3.6
RUN apt-get update && apt-get install python3-dev python3-pip libpq5 libjpeg-dev tesseract-ocr libpoppler-cpp-dev imagemagick virtualenv libopencv-dev zbar-tools libzbar0 libzbar-dev libfuzzy-dev git -y
RUN git clone https://github.com/MISP/misp-modules.git /usr/local/src/misp-modules && \
    cd /usr/local/src/misp-modules && \
    # sed -i '/^opencv-python/ d'  REQUIREMENTS && \
    pip3 install -I -r REQUIREMENTS && \
    pip3 install -I .

EXPOSE 9000
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
