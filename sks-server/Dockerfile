FROM fedora:22

MAINTAINER swilsonau@gmail.com

RUN dnf -y makecache && dnf -y install \
    sks \
    gnupg \
    nginx \
    ntp \
    cronie \
    tar \
    supervisor

RUN mkdir -p /var/log/supervisor

COPY files/supervisord.conf /etc/supervisord.d/sks.ini
COPY files/sksconf /var/lib/sks/sksconf
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/membership /var/lib/sks/membership

COPY files/crontab.txt /tmp/crontab.txt
RUN crontab /tmp/crontab.txt
RUN chmod 600 /etc/crontab

# TODO: Get dump content
RUN mkdir /var/lib/sks/dump
WORKDIR /var/lib/sks/dump
#RUN wget -c -r -p -e robots=off --timestamping --level=1 --cut-dirs=3 --no-host-directories http://keyserver.mattrude.com/dump/current/
COPY files/dump /var/lib/sks/dump
#RUN md5sum -c metadata-sks-dump.txt

WORKDIR /var/lib/sks/
RUN sks build /var/lib/sks/dump/*.pgp -n 10 -cache 100
RUN sks cleandb
RUN sks pbuild -cache 20 -ptree_cache 70

RUN curl -Ls https://github.com/mattrude/pgpkeyserver-lite/tarball/master -o pgpkeyserver-lite.tgz
RUN mkdir -p /var/www/html && tar -xzf pgpkeyserver-lite.tgz --directory /var/www/html --strip 1

EXPOSE 80 11371

WORKDIR /
CMD ["/usr/bin/supervisord"]
