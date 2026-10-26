#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Microsoft Edge"
CLEANER_TARGETS=("$HOME/Library/Caches/Microsoft Edge" )
cleaner_dispatch "$@"
