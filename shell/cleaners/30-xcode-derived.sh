#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Xcode DerivedData"
CLEANER_TARGETS=("$HOME/Library/Developer/Xcode/DerivedData" )
cleaner_dispatch "$@"
