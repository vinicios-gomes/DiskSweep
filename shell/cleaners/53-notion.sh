#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Notion (explorar)"
CLEANER_TARGET="$HOME/Library/Application Support/Notion"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
