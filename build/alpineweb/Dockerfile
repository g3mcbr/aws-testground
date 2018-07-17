FROM alpine:latest
RUN apk update;apk add apache2
RUN mkdir -p /run/apache2/
RUN rm /var/www/localhost/htdocs/index.html
COPY index.html /var/www/localhost/htdocs/index.html
COPY linux.png /var/www/localhost/htdocs
ENTRYPOINT ["/usr/sbin/httpd", "-DFOREGROUND"]
