FROM debian:buster-slim

RUN apt-get update && apt-get install -y devscripts build-essential cpio rsync
COPY ./docker/entrypoint.sh /
COPY ./docker/dpkg-deb-wrapper /usr/local/bin/dpkg-deb
VOLUME /src
WORKDIR /src
ENTRYPOINT /entrypoint.sh
