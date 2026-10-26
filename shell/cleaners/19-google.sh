#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Google/Chrome"
CLEANER_TARGETS=("$HOME/Library/Caches/Google" )
cleaner_dispatch "$@"
