FROM ubuntu:trusty

MAINTAINER swilsonau@gmail.com

RUN apt-get update && apt-get -y install gcc ocaml libdb6.0-dev gnupg nginx wget curl patch make

RUN gpg --keyserver hkp://pool.sks-keyservers.net --trust-model always --recv-key 0x41259773973A612A
RUN wget https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz && wget  https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.5.tgz.asc
RUN gpg --keyid-format long --verify sks-1.1.5.tgz.asc
RUN tar -xzf sks-1.1.5.tgz
RUN cd sks-1.1.5 && curl -sL "https://bitbucket.org/skskeyserver/sks-keyserver/commits/40280f59d0f503da1326972757168aa42335573f/raw/" |patch -p1 && cp Makefile.local.unused Makefile.local && sed -i 's/ldb\-4.6/ldb\-6.0/' Makefile.local && make dep && make all && make install
