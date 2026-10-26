#!/bin/bash
# Gera o app e abre. Usa DISK_TOOLS_ROOT apontando para ./shell, então edições nos cleaners valem sem rebuild.
cd "$(dirname "$0")/.." && ./scripts/build-app.sh && pkill -x DiskSweep 2>/dev/null
DISK_TOOLS_ROOT="$PWD/shell" open --env DISK_TOOLS_ROOT="$PWD/shell" build/DiskSweep.app
