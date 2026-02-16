# ghcr.io/coolcow/rclone

A flexible, multi-purpose, and minimal Alpine-based Docker image for [Rclone](https://rclone.org/).

This image supports two modes: direct `rclone` command execution (default) and a cron-based scheduler for running tasks automatically. It runs as a non-root user and is highly configurable through both runtime environment variables and build-time arguments.

---

## Recommended Usage with `docker-compose`

This example demonstrates both modes side-by-side.

**`docker-compose.yml`**
```yaml
version: "3.7"
services:
  # Example 1: Running a one-off rclone command
  rclone-command:
    image: ghcr.io/coolcow/rclone:latest
    # The command to run is passed here
    command: sync /data MyRemote:backup --progress
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - ./rclone.conf:/home/.config/rclone/rclone.conf:ro
      - /path/to/data:/data

  # Example 2: Running as a cron scheduler
  rclone-cron:
    image: ghcr.io/coolcow/rclone:latest
    restart: unless-stopped
    environment:
      - RUN_MODE=cron
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
    volumes:
      - ./rclone.conf:/home/.config/rclone/rclone.conf:ro
      - ./crontab:/crontab:ro
      - /path/to/data:/data # Mount data for the cron job
      - /path/to/logs:/logs # Mount a log volume for cron output
```

**Example `crontab` file:**
```crontab
# Run a sync every day at 2:00 AM
0 2 * * *    flock -n /tmp/rclone.lock rclone sync /data MyRemote:backup --log-file /logs/rclone-sync.log
```

---

## Configuration

### Runtime Environment Variables

| Variable        | Default   | Description                                                        |
| --------------- | --------- | ------------------------------------------------------------------ |
| `RUN_MODE`      | `rclone`  | Set to `cron` to activate the cron scheduler mode.                 |
| `PUID`          | `1000`    | The user ID to run the `rclone` process as.                        |
| `PGID`          | `1000`    | The group ID to run the `rclone` process as.                       |
| `TZ`            | `Etc/UTC` | Timezone for the container, important for correct cron scheduling. |
| `CROND_CRONTAB` | `/crontab`| Path inside the container for the crontab file.                    |

### Build-Time Arguments

Customize the image at build time with `docker build --build-arg <KEY>=<VALUE>`.

| Argument              | Default   | Description                                  |
| --------------------- | --------- | -------------------------------------------- |
| `ALPINE_VERSION`      | `3.19.1`  | Version of the Alpine base image.            |
| `RCLONE_VERSION`      | `v1.73.0` | Version of Rclone to install.                |
| `ENTRYPOINTS_VERSION` | `v2.0.0`  | Version of the `coolcow/entrypoints` image.  |

---

## Local Testing

Run the built-in smoke tests locally.

1.  `docker build -t ghcr.io/coolcow/rclone:local-test-build -f build/Dockerfile build`
2.  `docker build --build-arg APP_IMAGE=ghcr.io/coolcow/rclone:local-test-build -f build/Dockerfile.test build`

---

## Deprecation Notice

This image replaces the now-obsolete `ghcr.io/coolcow/rclone-cron` image. Migrate by using the `RUN_MODE=cron` environment variable.
