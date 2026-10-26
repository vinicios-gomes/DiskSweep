#!/bin/bash
source "$(dirname "$0")/../lib/strategy_cmd.sh"
CLEANER_NAME="Homebrew cleanup"
CLEANER_CMD='brew cleanup --prune=all'
CLEANER_REQUIRES="brew"
CLEANER_SIZE_PATH=""
cleaner_dispatch "$@"
