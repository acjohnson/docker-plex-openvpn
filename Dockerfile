# Plex and OpenVPN

FROM ghcr.io/onedr0p/plex:1.32.6.7557-1cf77d501
MAINTAINER Aaron Johnson

VOLUME /data
VOLUME /config

# Update packages and install software
RUN apt-get update \
    && apt-get -y install software-properties-common ufw \
    && apt-get update \
    && apt-get install -y dumb-init openvpn curl wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD openvpn/ /etc/openvpn/
ADD stop.sh /

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    OPENVPN_OPTS= \
    LOCAL_NETWORK= \
    ENABLE_UFW=false \
    PLEX_PORT=32400 \
    PUID=\
    PGID=

# Expose port and run
EXPOSE 9091
CMD ["dumb-init", "/etc/openvpn/start.sh"]
