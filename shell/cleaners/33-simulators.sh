#!/bin/bash
# Lista os dispositivos em ~/Library/Developer/CoreSimulator/Devices lendo o device.plist de cada um.
# Funciona sem Xcode instalado (sem simctl); se simctl existir, usa-o para remover.
source "$(dirname "$0")/../lib/strategy_items.sh"
CLEANER_NAME="Simuladores iOS (escolher quais remover)"
DEVICES="$HOME/Library/Developer/CoreSimulator/Devices"

items_list() {
  local dir uuid name runtime kb
  for dir in "$DEVICES"/*/; do
    [[ -f "$dir/device.plist" ]] || continue
    uuid=$(basename "$dir")
    name=$(plutil -extract name raw -o - "$dir/device.plist" 2>/dev/null || echo "?")
    runtime=$(plutil -extract runtime raw -o - "$dir/device.plist" 2>/dev/null | sed 's/.*\.//; s/-/ /; s/-/./g')
    kb=$(fs_kb "$dir")
    printf '%s\t%s\t%s\n' "$kb" "$uuid" "$name · ${runtime:-runtime desconhecido}"
  done
}

items_delete() {
  local id="$1"
  [[ "$id" =~ ^[0-9A-Fa-f-]{36}$ ]] || { echo "id inválido"; return 1; }
  if xcrun simctl delete "$id" >/dev/null 2>&1; then return 0; fi   # simctl disponível (Xcode)
  fs_safe_rm "$DEVICES/$id"                                          # sem Xcode: remove a pasta
}

cleaner_dispatch "$@"
