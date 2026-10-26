#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Atualizações antigas do VS Code (ShipIt)"
CLEANER_TARGETS=("$HOME/Library/Caches/com.microsoft.VSCode.ShipIt" )
cleaner_dispatch "$@"
