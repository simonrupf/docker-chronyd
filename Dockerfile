FROM alpine:3.21

ARG BUILD_DATE

# first, a bit about this container
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="Simon Rupf <simon@rupf.net>" \
      org.opencontainers.image.documentation=https://github.com/simonrupf/docker-chronyd

# default configuration
ENV NTP_DIRECTIVES="ratelimit\nrtcsync"

# install chrony
RUN apk add --no-cache chrony tzdata && \
    rm /etc/chrony/chrony.conf && \
    chmod 1750 /etc/chrony && \
    mkdir /run/chrony && \
    chown -R chrony:chrony /run/chrony && \
    chmod 1750 /run/chrony && \
    chown -R chrony:chrony /var/lib/chrony && \
    chmod 1750 /var/lib/chrony

# script to configure/startup chrony (ntp)
COPY --chmod=0755 assets/startup.sh /bin/startup

# ntp port
EXPOSE 123/udp

# marking volumes that need to be writable
# this will also create unnamed volumes on the host system
VOLUME /etc/chrony /run/chrony /var/lib/chrony

# let docker know how to test container health
HEALTHCHECK CMD chronyc -n tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/startup" ]
