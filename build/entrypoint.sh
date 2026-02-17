#!/bin/sh

# This is a smart entrypoint script that allows the rclone image to be used
# in two modes, controlled by the RUN_MODE environment variable.

set -e

export TARGET_UID=${RCLONE_UID:-1000}
export TARGET_GID=${RCLONE_GID:-1000}
export TARGET_REMAP_IDS=${RCLONE_REMAP_IDS:-1}
export TARGET_USER=${RCLONE_USER:-rclone}
export TARGET_GROUP=${RCLONE_GROUP:-rclone}
export TARGET_HOME=${RCLONE_HOME:-/home/rclone}
export TARGET_SHELL=${RCLONE_SHELL:-/bin/sh}

# Check the value of the RUN_MODE environment variable.
# Default to 'rclone' if the variable is not set.
case "${RUN_MODE}" in
  cron)
    echo "Starting in cron daemon mode."
    # Hand over execution to the cron entrypoint script.
    # Any arguments passed to this container (e.g. from CMD) will be passed to crond.
    exec /usr/local/bin/entrypoint_crond.sh "$@"
    ;;
  *)
    echo "Starting in direct command mode (default)."
    # For any other value (or if RUN_MODE is unset), assume the user wants to run rclone.
    # Hand over execution to the su-exec entrypoint, which will
    # run 'rclone' with all the provided arguments as the correct user.
    exec /usr/local/bin/entrypoint_su-exec.sh rclone "$@"
    ;;
esac
