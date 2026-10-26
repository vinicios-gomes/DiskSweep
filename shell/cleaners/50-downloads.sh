#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Downloads (explorar)"
CLEANER_TARGET="$HOME/Downloads"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
