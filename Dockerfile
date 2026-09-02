# Plex and OpenVPN

FROM registry.thejohnsons.site/docker-plex-openvpn:working
ARG PLEX_VERSION=1.43.3.10896
MAINTAINER Aaron Johnson

VOLUME /data
VOLUME /config

USER root

# Update packages and install software
RUN apt-get update \
    && apt-get -y install software-properties-common ufw \
    && apt-get update \
    && apt-get install -y dumb-init openvpn curl wget sudo netcat-openbsd iputils-ping bash net-tools iproute2 bind9-dnsutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://github.com/acjohnson/gptshare/raw/refs/heads/master/plexmediaserver_${PLEX_VERSION}-cb3ebc72d_amd64.deb \
    -O /tmp/plexmediaserver_amd64.deb

RUN apt-get -y install /tmp/plexmediaserver_amd64.deb

ADD openvpn/ /etc/openvpn/
ADD scripts /etc/scripts/
ADD plex /plex/

# Support legacy IPTables commands
RUN update-alternatives --set iptables $(which iptables-legacy) && \
    update-alternatives --set ip6tables $(which ip6tables-legacy)

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_OPTS= \
    GLOBAL_APPLY_PERMISSIONS=true \
    CREATE_TUN_DEVICE=true \
    ENABLE_UFW=false \
    PLEX_PORT=32400 \
    PUID=\
    PGID=

HEALTHCHECK --interval=1m CMD /etc/scripts/healthcheck.sh

# Expose port and run
EXPOSE 9091
CMD ["dumb-init", "/etc/openvpn/start.sh"]
