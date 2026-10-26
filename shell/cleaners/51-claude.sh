#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Claude Desktop (explorar)"
CLEANER_TARGET="$HOME/Library/Application Support/Claude"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
