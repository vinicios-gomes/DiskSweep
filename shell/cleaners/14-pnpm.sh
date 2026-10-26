#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do pnpm"
CLEANER_TARGETS=("$HOME/Library/Caches/pnpm" )
cleaner_dispatch "$@"
