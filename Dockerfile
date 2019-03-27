FROM ubuntu:18.04
MAINTAINER Michael Vonbun <michael.vonbun@tum.de>

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE                              \
      org.label-schema.vcs-url="https://github.com/mvonbun/docker-omnetpp" \
      org.label-schema.vcs-ref=$VCS_REF                                    \
      org.label-schema.schema-version="1.1"

ENV PATH /usr/local/src/omnetpp-5.4.1/bin:$PATH
RUN set -x; \
    apt-get update -q -y; \
    apt-get install -q -y --no-install-recommends \
        build-essential gcc g++ bison flex perl \
        python python3 qt5-default libqt5opengl5-dev tcl-dev tk-dev \
        libxml2-dev zlib1g-dev default-jre doxygen graphviz libwebkitgtk-1.0;

WORKDIR /usr/local/src
RUN wget https://dist.ipfs.io/go-ipfs/v0.4.19/go-ipfs_v0.4.19_linux-amd64.tar.gz; \
    tar xfz go-ipfs.tar.gz && cd go-ipfs && ./install.sh;

WORKDIR /usr/local/src
RUN ipfs get /ipns/ipfs.omnetpp.org/release/5.4.1/omnetpp-5.4.1-src-core.tgz; \
    tar xfz omnetpp-5.1.1-src-core.tgz && rm omnetpp-5.4.1-src-core.tgz

WORKDIR omnetpp-5.4.1
RUN sed -i "/WITH_TKENV=yes/c\WITH_TKENV=no" configure.user; \
    sed -i "/WITH_QTENV=yes/c\WITH_QTENV=no" configure.user; \
    sed -i "/PREFER_QTENV=yes/c\PREFER_QTENV=no" configure.user; \
    sed -i "/WITH_OSG=yes/c\WITH_OSG=no" configure.user; \
    sed -i "/WITH_OSGEARTH=yes/c\WITH_OSGEARTH=no" configure.user; \
    ./configure && make

VOLUME ["/sim"]
WORKDIR /sim



