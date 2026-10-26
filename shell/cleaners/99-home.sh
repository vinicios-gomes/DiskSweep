#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Maiores pastas da home (explorar)"
CLEANER_TARGET="$HOME"
CLEANER_SIZE_SKIP=1
cleaner_dispatch "$@"
