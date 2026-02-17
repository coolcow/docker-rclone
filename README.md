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
      - RCLONE_UID=1000
      - RCLONE_GID=1000
    volumes:
      - ./rclone.conf:/home/.config/rclone/rclone.conf:ro
      - /path/to/data:/data

  # Example 2: Running as a cron scheduler
  rclone-cron:
    image: ghcr.io/coolcow/rclone:latest
    restart: unless-stopped
    environment:
      - RUN_MODE=cron
      - RCLONE_UID=1000
      - RCLONE_GID=1000
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

| Variable           | Default    | Target              | Description                                                        |
| ------------------ | ---------- | ------------------- | ------------------------------------------------------------------ |
| `RCLONE_UID`       | `1000`     | `TARGET_UID`        | The user ID to run `rclone` as.                                   |
| `RCLONE_GID`       | `1000`     | `TARGET_GID`        | The group ID to run `rclone` as.                                  |
| `RCLONE_REMAP_IDS` | `1`        | `TARGET_REMAP_IDS`  | Set `0` to disable remapping conflicting UID/GID entries.         |
| `RCLONE_USER`      | `rclone`   | `TARGET_USER`       | The runtime user name inside the container.                        |
| `RCLONE_GROUP`     | `rclone`   | `TARGET_GROUP`      | The runtime group name inside the container.                       |
| `RCLONE_HOME`      | `/home`    | `TARGET_HOME`       | Home directory used by `rclone` and as default working directory. |
| `RCLONE_SHELL`     | `/bin/sh`  | `TARGET_SHELL`      | Login shell for the runtime user.                                 |
| `RUN_MODE`         | `rclone`   | —                   | Set to `cron` to activate the cron scheduler mode.                |
| `CROND_CRONTAB`    | `/crontab` | —                   | Path inside the container for the crontab file.                    |
| `TZ`               | `Etc/UTC`  | —                   | Timezone for the container, important for correct cron scheduling. |

`Target` shows the corresponding variable used by `coolcow/entrypoints`; `—` means no mapping.

### Build-Time Arguments

Customize the image at build time with `docker build --build-arg <KEY>=<VALUE>`.

| Argument              | Default   | Description                                  |
| --------------------- | --------- | -------------------------------------------- |
| `RCLONE_VERSION`      | `1.73.0`  | Version of Rclone to install.                |
| `ALPINE_VERSION`      | `3.23.3`  | Version of the Alpine base image.            |
| `ENTRYPOINTS_VERSION` | `2.2.0`   | Version of the `coolcow/entrypoints` image.  |

---

## Migration Notes

Since `v1.2.0`, runtime user/group environment variables were renamed to image-specific `RCLONE_*` names.

- `PUID` → `RCLONE_UID`
- `PGID` → `RCLONE_GID`
- `ENTRYPOINT_USER` → `RCLONE_USER`
- `ENTRYPOINT_GROUP` → `RCLONE_GROUP`
- `ENTRYPOINT_HOME` → `RCLONE_HOME`

Update your `docker run` / `docker-compose` environment configuration accordingly when upgrading from older tags.

---

## Local Testing

Run the built-in smoke tests locally.

1.  `docker build -t ghcr.io/coolcow/rclone:local-test-build -f build/Dockerfile build`
2.  `docker build --build-arg APP_IMAGE=ghcr.io/coolcow/rclone:local-test-build -f build/Dockerfile.test build`

---

## Deprecation Notice

This image replaces the now-obsolete `ghcr.io/coolcow/rclone-cron` image. Migrate by using the `RUN_MODE=cron` environment variable.
