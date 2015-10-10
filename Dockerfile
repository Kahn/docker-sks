FROM ubuntu:trusty

MAINTAINER swilsonau@gmail.com

RUN apt-get -y update && apt-get -y install \
    gcc \
    ocaml \
    libdb6.0-dev \
    gnupg \
    nginx \
    wget \
    curl \
    patch \
    make \
    zlib1g-dev \
    supervisor

RUN mkdir -p /var/log/supervisor

WORKDIR /tmp/
RUN gpg --keyserver hkp://pool.sks-keyservers.net --trust-model always --recv-key 0x41259773973A612A
RUN wget https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz && wget  https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz.asc
RUN gpg --keyid-format long --verify sks-1.1.5.tgz.asc
RUN tar -xzf sks-1.1.5.tgz
RUN cd sks-1.1.5 && \
    curl -sL "https://bitbucket.org/skskeyserver/sks-keyserver/commits/40280f59d0f503da1326972757168aa42335573f/raw/" |patch -p1 && \
    cp Makefile.local.unused Makefile.local && \
    sed -i 's/ldb\-4.6/ldb\-6.0/' Makefile.local && \
    make dep && \
    make all && \
    make install

RUN curl -Ls https://github.com/mattrude/pgpkeyserver-lite/tarball/master -o pgpkeyserver-lite.tgz
RUN mkdir -p /var/www/html && tar -xzf pgpkeyserver-lite.tgz --directory /var/www/html --strip 1

# TODO: Get dump content
RUN ln -s /usr/local/bin/sks /usr/sbin/

COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/sksconf /var/lib/sks/sksconf
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/dump /var/lib/sks/dump
COPY files/membership /var/lib/sks/membership

WORKDIR /var/lib/sks/
RUN /usr/sbin/sks build /var/lib/sks/dump/*.pgp -n 10 -cache 100
RUN /usr/sbin/sks cleandb
RUN /usr/sbin/sks pbuild -cache 20 -ptree_cache 70

EXPOSE 80 11371

CMD ["/usr/bin/supervisord"]
