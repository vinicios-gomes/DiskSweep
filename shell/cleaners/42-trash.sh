#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Lixeira"
CLEANER_TARGETS=("$HOME/.Trash/*" )
cleaner_dispatch "$@"
