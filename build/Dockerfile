# Global build arguments
ARG ENTRYPOINTS_VERSION=2.2.0
ARG ALPINE_VERSION=3.23.3

# Stage to fetch scripts from the versioned entrypoints asset image
FROM ghcr.io/coolcow/entrypoints:${ENTRYPOINTS_VERSION} AS entrypoints

# Main build stage
FROM alpine:${ALPINE_VERSION}

# Build-time arguments. These are not persisted in the final image's environment.
# This allows building with different rclone versions, e.g.:
# docker build --build-arg RCLONE_VERSION=1.62.0 -t my-rclone .
ARG RCLONE_VERSION=1.73.0
ARG RCLONE_DOWNLOAD=http://downloads.rclone.org
ARG ARCH=amd64

# Runtime environment variables needed by the entrypoint scripts.
ENV RCLONE_UID=1000 \
    RCLONE_GID=1000 \
    RCLONE_REMAP_IDS=1 \
    RCLONE_USER=rclone \
    RCLONE_GROUP=rclone \
    RCLONE_HOME=/home/rclone \
    RCLONE_SHELL=/bin/sh \
    CROND_CRONTAB=/crontab

# install dependencies for rclone, cron, and script execution
RUN apk --no-cache --update add \
      ca-certificates \
      dcron \
      fuse \
      openssl \
      shadow \
      su-exec \
      wget \
      unzip \
    # Create an empty crontab file. The user is expected to mount their own.
    && touch $CROND_CRONTAB

# Copy required scripts from the entrypoints asset image
COPY --from=entrypoints /assets/ensure_user_group_home.sh /usr/local/bin/
COPY --from=entrypoints /assets/entrypoint_su-exec.sh /usr/local/bin/
COPY --from=entrypoints /assets/entrypoint_crond.sh /usr/local/bin/

# Copy the new smart entrypoint
COPY entrypoint.sh /usr/local/bin/

# Make scripts executable
RUN chmod +x /usr/local/bin/*.sh

# install rclone
RUN cd /tmp \
    && wget -q ${RCLONE_DOWNLOAD}/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -rf /tmp/*

VOLUME $RCLONE_HOME

WORKDIR $RCLONE_HOME

# The smart entrypoint decides whether to run rclone directly or start crond.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command if nothing is provided to `docker run`.
# The smart entrypoint will pass this to rclone.
CMD ["--help"]