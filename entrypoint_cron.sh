#!/bin/bash
set -e

chmod +x /etc/cron.daily/apt-cacher-ng

exec start-stop-daemon --start --exec "$(which cron)" -- -f -l 1 -L /dev/stdout
