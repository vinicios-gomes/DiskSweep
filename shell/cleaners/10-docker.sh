#!/bin/bash
source "$(dirname "$0")/../lib/strategy_cmd.sh"
CLEANER_NAME="Docker (imagens, containers, volumes, build cache)"
CLEANER_CMD='docker system prune -a --volumes'
CLEANER_REQUIRES="docker"
CLEANER_SIZE_PATH=""
cleaner_dispatch "$@"
