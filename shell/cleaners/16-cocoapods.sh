#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do CocoaPods"
CLEANER_TARGETS=("$HOME/Library/Caches/CocoaPods" )
cleaner_dispatch "$@"
