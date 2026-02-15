FROM ghcr.io/coolcow/entrypoints:latest

# runtime variables
ENV ARCH=amd64 \
    RCLONE_VERSION=current \
    RCLONE_DOWNLOAD=http://downloads.rclone.org \
    ENTRYPOINT_USER=rclone \
    ENTRYPOINT_GROUP=rclone \
    ENTRYPOINT_HOME=/home

# install rclone
RUN apk --no-cache --update add \
      ca-certificates \
      fuse \
      openssl \
    && cd /tmp \
    && wget -q ${RCLONE_DOWNLOAD}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -r /tmp/rclone-*-linux-${ARCH}/

VOLUME $ENTRYPOINT_HOME

WORKDIR $ENTRYPOINT_HOME

ENTRYPOINT ["/entrypoint_su-exec.sh", "rclone"]

CMD ["--help"]