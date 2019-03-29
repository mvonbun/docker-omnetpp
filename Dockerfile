FROM ubuntu:18.04 AS base
MAINTAINER Michael Vonbun <michael.vonbun@tum.de>

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE                              \
      org.label-schema.vcs-url="https://github.com/mvonbun/docker-omnetpp" \
      org.label-schema.vcs-ref=$VCS_REF                                    \
      org.label-schema.schema-version="1.1"

ENV PATH /usr/local/src/omnetpp/bin:$PATH

# intall required packages
# qt5-default \
# perl python python3  libqt5opengl5-dev tcl-dev tk-dev \
# default-jre doxygen graphviz libwebkitgtk-1.0;
RUN set -x;                                       \
    apt-get update -q -y;                         \
    apt-get install -q -y --no-install-recommends \
        build-essential gcc g++ bison flex        \
	libxml2-dev zlib1g-dev;                   \
    apt-get autoremove -q -y;                     \
    apt-get clean -q -y;                          \
    rm -rf /var/lib/apt/lists/*

# intermediate stage that builds omnet
FROM base AS build
WORKDIR /usr/local/src
RUN set -x;                                             \
    apt-get update -q -y;                               \
    apt-get install -q -y --no-install-recommends wget; \
    apt-get autoremove -q -y;                           \
    apt-get clean -q -y;                                \
    rm -rf /var/lib/apt/lists/*

# change only this line for different Omnet++ versions
RUN wget --no-check-certificate https://ipfs.omnetpp.org/release/5.4.1/omnetpp-5.4.1-src-core.tgz --output-document=omnetpp.tgz
RUN mkdir omnetpp && tar xfz omnetpp.tgz -C omnetpp --strip-components 1 && rm omnetpp.tgz
WORKDIR omnetpp
RUN sed -i "/WITH_TKENV=yes/c\WITH_TKENV=no" configure.user; \
    sed -i "/WITH_QTENV=yes/c\WITH_QTENV=no" configure.user; \
    sed -i "/PREFER_QTENV=yes/c\PREFER_QTENV=no" configure.user; \
    sed -i "/WITH_OSG=yes/c\WITH_OSG=no" configure.user; \
    sed -i "/WITH_OSGEARTH=yes/c\WITH_OSGEARTH=no" configure.user; \
    ./configure && make

FROM base as final
COPY --from=build /usr/local/src /usr/local/src
WORKDIR /sim



