FROM ubuntu:14.04
MAINTAINER "me"

ENV REFRESHED_AT 2015-05-11
ENV HTTPD_PREFIX /etc/apache2

# Install apache2
RUN apt-get update -y \
	&& apt-get install -y \
		apache2

# Remove default site, configs, and mods not needed
WORKDIR $HTTPD_PREFIX
RUN rm -f \
		sites-enabled/000-default.conf \
		conf-enabled/serve-cgi-bin.conf \
		mods-enabled/autoindex.conf \
		mods-enabled/autoindex.load

# Enable additional configs and mods
RUN ln -s $HTTPD_PREFIX/mods-available/expires.load $HTTPD_PREFIX/mods-enabled/expires.load \
    && ln -s $HTTPD_PREFIX/mods-available/headers.load $HTTPD_PREFIX/mods-enabled/headers.load \
	&& ln -s $HTTPD_PREFIX/mods-available/rewrite.load $HTTPD_PREFIX/mods-enabled/rewrite.load

# Overwrite default security.conf file
#COPY security.conf $HTTPD_PREFIX/conf-available/security.conf

EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
