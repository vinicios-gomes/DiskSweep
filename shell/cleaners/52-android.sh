#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Android AVDs/SDK (~/.android) (explorar)"
CLEANER_TARGET="$HOME/.android"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
