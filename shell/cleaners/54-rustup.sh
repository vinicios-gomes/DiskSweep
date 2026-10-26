#!/bin/bash
source "$(dirname "$0")/../lib/strategy_explore.sh"
CLEANER_NAME="Toolchains Rust (explorar)"
CLEANER_TARGET="$HOME/.rustup/toolchains"
CLEANER_SIZE_SKIP=0
cleaner_dispatch "$@"
