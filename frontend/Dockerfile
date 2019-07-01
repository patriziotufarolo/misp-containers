FROM nginx:stable-alpine
COPY misp.conf /etc/nginx/conf.d/misp.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
