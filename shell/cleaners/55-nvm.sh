#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Versões do Node/nvm (explorar)"
CLEANER_TARGET="$HOME/.nvm/versions"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
