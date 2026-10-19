FROM ghcr.io/mihaiush/build:26.824.32 AS build

# renovate: datasource=deb depName=fcgiwrap registryUrl=https://deb.debian.org/debian?suite=testing&components=main&binaryArch=amd64
ENV FCGIWRAP_VERSION="1.1.0-17"

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install \
        fcgiwrap=$FCGIWRAP_VERSION \
        mawk \
        curl \
        busybox \
        jq \
        tini

RUN \
    ldd_jail build \
        /usr/sbin/fcgiwrap \
        /usr/bin/mawk \
        /usr/bin/curl \
        /etc/ssl/certs/ca-certificates.crt \
        /usr/bin/busybox \
        /usr/bin/bash \
        /usr/bin/jq \
        /usr/bin/tini

RUN \
    mkdir /tmp/build/bin &&\
    chroot /tmp/build /usr/bin/busybox --install -s /bin

FROM scratch

COPY --from=build /tmp/build /

CMD tini -v -s -- fcgiwrap -f -c 2 -s unix:/dev/shm/fcgi.sock
