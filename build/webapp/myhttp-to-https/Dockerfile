FROM apache2test:latest
MAINTAINER "me"

ENV REFRESHED_AT 2015-07-20

RUN apt-get update -y \
    && apt-get clean

COPY redirect.conf /etc/apache2/sites-enabled/

