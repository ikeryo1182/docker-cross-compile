FROM debian:jessie

WORKDIR /workspace

COPY download.sh /workspace
COPY build.sh /workspace

RUN apt-get update
RUN apt-get -y install wget

RUN sh download.sh

RUN sh build.sh
