#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Xcode Archives"
CLEANER_TARGETS=("$HOME/Library/Developer/Xcode/Archives" )
cleaner_dispatch "$@"
