#!/bin/bash
source "$(dirname "$0")/../lib/strategy_nodemodules.sh"
CLEANER_NAME="node_modules de projetos (buscar e escolher)"
CLEANER_ROOT="$HOME"
cleaner_dispatch "$@"
