#!/bin/bash
source "$(dirname "$0")/../lib/strategy_path.sh"
CLEANER_NAME="Cache do Gradle"
CLEANER_TARGETS=("$HOME/.gradle/caches" )
cleaner_dispatch "$@"
