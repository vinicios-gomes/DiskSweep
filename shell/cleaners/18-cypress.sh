#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Cypress"
CLEANER_TARGETS=("$HOME/Library/Caches/Cypress" )
cleaner_dispatch "$@"
