#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Logs (~/Library/Logs)"
CLEANER_TARGETS=("$HOME/Library/Logs/*" )
cleaner_dispatch "$@"
