#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do pip"
CLEANER_TARGETS=("$HOME/Library/Caches/pip" )
cleaner_dispatch "$@"
