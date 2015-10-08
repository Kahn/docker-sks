FROM ubuntu:trusty

MAINTAINER swilsonau@gmail.com

RUN apt-get -y update
RUN apt-get -y install gcc
RUN apt-get -y install ocaml
RUN apt-get -y install libdb6.0-dev
RUN apt-get -y install gnupg
RUN apt-get -y install nginx
RUN apt-get -y install wget
RUN apt-get -y install curl
RUN apt-get -y install patch
RUN apt-get -y install make
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor

COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN gpg --keyserver hkp://pool.sks-keyservers.net --trust-model always --recv-key 0x41259773973A612A
RUN wget https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz && wget  https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz.asc
RUN gpg --keyid-format long --verify sks-1.1.5.tgz.asc
RUN tar -xzf sks-1.1.5.tgz
RUN cd sks-1.1.5 && curl -sL "https://bitbucket.org/skskeyserver/sks-keyserver/commits/40280f59d0f503da1326972757168aa42335573f/raw/" |patch -p1 && cp Makefile.local.unused Makefile.local && sed -i 's/ldb\-4.6/ldb\-6.0/' Makefile.local && make dep && make all && make install

COPY files/sksconf /var/lib/sks/sksconf
COPY files/nginx.conf /etc/nginx/nginx.conf

RUN curl -Ls https://github.com/mattrude/pgpkeyserver-lite/tarball/master -o pgpkeyserver-lite.tgz
RUN mkdir -p /var/www/html && tar -xzf pgpkeyserver-lite.tgz --directory /var/www/html --strip 1

COPY files/sks /etc/init.d/sks
RUN chmod 0755 /etc/init.d/sks

EXPOSE 80 11371

CMD ["/usr/bin/supervisord"]
