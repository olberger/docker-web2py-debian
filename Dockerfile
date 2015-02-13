#
# Runs web2py as a docker container over Debian, with Apache and mod_wsgi
#

FROM debian:wheezy

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    apache2 libapache2-mod-wsgi libapache2-mod-python \
    ssl-cert \
    python-web2py


# Configuring web2py run by mod_wsgi
RUN cp /usr/share/doc/python-gluon/examples/wsgihandler.py /usr/share/web2py/

COPY web2py.conf /etc/apache2/sites-available/web2py.conf
RUN ln -s ../sites-available/web2py.conf /etc/apache2/sites-enabled/

RUN rm /etc/apache2/sites-enabled/000-default
RUN a2enmod ssl

# Lower mpm-prefork minimum servers
RUN sed -i "s/StartServers          5/StartServers          1/g" /etc/apache2/apache2.conf
RUN sed -i "s/MinSpareServers       5/MinSpareServers       1/g" /etc/apache2/apache2.conf
RUN sed -i "s/MaxSpareServers      10/MaxSpareServers       1/g" /etc/apache2/apache2.conf

RUN chown -R www-data /usr/share/web2py

WORKDIR /usr/share/web2py

# Set web2py admin password
RUN sudo -u www-data python -c "from gluon.main import save_password; save_password('coin123',8443)"

EXPOSE 80
EXPOSE 443

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_DIR /var/run/apache2

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
