# ghcr.io/coolcow/rclone

Simple and minimal Alpine-based Docker image for [Rclone](https://rclone.org/).

---

## Overview

Rclone is a command-line program to sync files and directories to and from cloud storage.

---

## Features

- Based on Alpine Linux for a small footprint
- Runs as non-root by default (user: `rclone`)
- Secure execution via [docker-entrypoints](https://github.com/coolcow/docker-entrypoints)
- Configurable user/group IDs to avoid permission issues on mounted volumes

---

## Usage

### Quick Start

```sh
docker run --rm ghcr.io/coolcow/rclone
```

Default runtime behavior:

- **ENTRYPOINT:** `/entrypoint_su-exec.sh rclone`
- **CMD:** `--help`

### Environment Variables

| Variable | Default | Description |
|---|---:|---|
| `PUID` | 1000 | User ID to run rclone as |
| `PGID` | 1000 | Group ID to run rclone as |
| `ENTRYPOINT_USER` | rclone | Internal: user for entrypoint script |
| `ENTRYPOINT_GROUP` | rclone | Internal: group for entrypoint script |
| `ENTRYPOINT_HOME` | /home | Internal: working home directory |

Use `PUID` and `PGID` to run rclone with your host user's uid/gid and avoid permission issues.

### Create or Edit Rclone Config

```sh
docker run -it --rm \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -v <PATH_TO_YOUR_CONF>:/home/.rclone.conf \
  ghcr.io/coolcow/rclone \
    config
```

Replace `<PATH_TO_YOUR_CONF>` with the file path of your rclone configuration file.

### Sync Data to Cloud Storage

```sh
docker run -it --rm \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -v <PATH_TO_YOUR_CONF>:/home/.rclone.conf \
  -v <PATH_TO_YOUR_DATA>:/data \
  ghcr.io/coolcow/rclone \
    sync /data cloudstorage:
```

Replace `<PATH_TO_YOUR_CONF>` with your config file path and `<PATH_TO_YOUR_DATA>` with your data directory.

### Run Sync as Cron Daemon

Take a look at [ghcr.io/coolcow/rclone-cron](https://ghcr.io/coolcow/rclone-cron), an image based on this one that uses `/entrypoint_crond.sh`.

Example crontab entry (every two hours):

```crontab
0 */2 * * * flock -n ~/rclone.lock rclone sync --log-file /logs/rclone.$(date +%Y%m%d_%H%M%S).log /data cloudstorage: &
```

Run command:

```sh
docker run -d \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e CROND_CRONTAB=/crontab \
  -v <PATH_TO_YOUR_CONF>:/home/.rclone.conf \
  -v <PATH_TO_YOUR_DATA>:/data \
  -v <PATH_TO_YOUR_CRONTAB>:/crontab \
  -v <PATH_TO_YOUR_LOGS>:/logs \
  --entrypoint=/entrypoint_crond.sh \
  ghcr.io/coolcow/rclone \
    -f
```

---

## References

- [Rclone Documentation](https://rclone.org/)
- [Rclone Command List](https://rclone.org/commands/)
- [docker-entrypoints](https://github.com/coolcow/docker-entrypoints)
