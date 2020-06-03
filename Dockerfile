FROM ubuntu:focal-20200423

LABEL maintainer="sameer@damagehead.com"

ENV APT_CACHER_NG_VERSION=3.3 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      apt-cacher-ng=${APT_CACHER_NG_VERSION}* ca-certificates wget cron \
 && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
 && rm -rf /var/lib/apt/lists/*

# Clean out /etc/cron.daily since we supply our own expire script
RUN rm -rf /etc/cron.daily/*

COPY entrypoint.sh /sbin/entrypoint.sh
COPY entrypoint_cron.sh /sbin/entrypoint_cron.sh
COPY apt-cacher-ng_expire.sh /etc/cron.daily/apt-cacher-ng_expire.sh

RUN chmod 755 /sbin/entrypoint.sh \
 && chmod 755 /sbin/entrypoint_cron.sh \
 && chmod 755 /etc/cron.daily/apt-cacher-ng_expire.sh

EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD wget -q -t1 -O /dev/null  http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
