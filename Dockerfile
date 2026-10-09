FROM ghcr.io/mihaiush/build:26.824.16 AS build

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install \
        fcgiwrap \
        curl \
        busybox \
        jq

RUN \
    ldd_jail build \
        /usr/sbin/fcgiwrap \
        /usr/bin/curl \
        /usr/bin/busybox \
        /usr/bin/bash \
        /usr/bin/jq

RUN \
    mkdir /tmp/build/bin &&\
    chroot /tmp/build /usr/bin/busybox --install -s /bin

FROM scratch

COPY --from=build /tmp/build /

CMD fcgiwrap -f -c 2 -s unix:/dev/shm/fcgi.sock
