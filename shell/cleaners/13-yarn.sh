#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Yarn"
CLEANER_TARGETS=("$HOME/Library/Caches/Yarn" )
cleaner_dispatch "$@"
