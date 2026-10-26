#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do TypeScript"
CLEANER_TARGETS=("$HOME/Library/Caches/typescript" )
cleaner_dispatch "$@"
