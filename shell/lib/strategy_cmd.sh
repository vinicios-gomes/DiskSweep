#!/bin/bash
# Strategy: executar um comando externo.
# Variáveis: CLEANER_NAME, CLEANER_CMD, CLEANER_REQUIRES (binário), CLEANER_SIZE_PATH (opcional)
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB/ui.sh"; source "$LIB/fs.sh"; source "$LIB/contract.sh"

_available() { [[ -z "${CLEANER_REQUIRES:-}" ]] || command -v "$CLEANER_REQUIRES" >/dev/null; }

cleaner_name() { echo "$CLEANER_NAME"; }
cleaner_kind() { echo cmd; }
cleaner_kb() {
  _available || { echo -1; return; }
  if [[ -n "${CLEANER_SIZE_PATH:-}" && -e "$CLEANER_SIZE_PATH" ]]; then fs_kb "$CLEANER_SIZE_PATH"; else echo -1; fi
}
cleaner_plan() { printf -- '-1\t%s\n' "$CLEANER_CMD"; }
cleaner_apply() {
  _available || { ui_warn "'$CLEANER_REQUIRES' não está instalado."; return 1; }
  bash -c "$CLEANER_CMD" 2>&1
}
