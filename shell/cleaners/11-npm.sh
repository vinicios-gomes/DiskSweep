#!/bin/bash
source "$(dirname "$0")/../lib/strategy_cmd.sh"
CLEANER_NAME="Cache do npm (inclui _npx)"
CLEANER_CMD='npm cache clean --force; rm -rf "$HOME/.npm/_npx"'
CLEANER_REQUIRES="npm"
CLEANER_SIZE_PATH="$HOME/.npm"
cleaner_dispatch "$@"
