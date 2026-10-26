#!/bin/bash
# Strategy: itens que não são arquivos (simuladores, imagens Docker...), cada um com id próprio.
# O cleaner define: CLEANER_NAME, CLEANER_REQUIRES (binário),
#   items_list        -> imprime "kb<TAB>id<TAB>label" por item
#   items_delete <id> -> remove um item
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB/ui.sh"; source "$LIB/fs.sh"; source "$LIB/contract.sh"

_available() { [[ -z "${CLEANER_REQUIRES:-}" ]] || command -v "$CLEANER_REQUIRES" >/dev/null; }

cleaner_name() { echo "$CLEANER_NAME"; }
cleaner_kind() { echo items; }
cleaner_kb() { _available || { echo -1; return; }; items_list 2>/dev/null | awk -F'\t' '{s+=$1} END{print s+0}'; }
cleaner_plan() { _available || return 0; items_list | sort -t$'\t' -k1,1 -rn; }
cleaner_apply() { # só aceita ids presentes na listagem atual
  local id valid; valid=$(items_list | cut -f2)
  for id in "$@"; do
    if grep -qxF -- "$id" <<< "$valid"; then items_delete "$id" 2>&1 && echo "removido: $id"
    else ui_warn "Ignorado (id desconhecido): $id"; fi
  done
}
cleaner_run() {
  ui_title "$CLEANER_NAME"
  _available || { ui_warn "'$CLEANER_REQUIRES' não está instalado."; return; }
  local ids=() i=0 kb id label choice n sel=()
  while IFS=$'\t' read -r kb id label; do
    ids+=("$id"); i=$((i+1)); printf " %2d) %8s  %s\n" "$i" "$(fs_human "$kb")" "$label"
  done < <(cleaner_plan)
  [[ $i -eq 0 ]] && { echo "Nada encontrado."; return; }
  echo "  Números separados por espaço (ex: 1 3), 'todos', ou 0 para voltar."
  read -r choice; [[ "$choice" == "0" || -z "$choice" ]] && return
  if [[ "$choice" == "todos" ]]; then sel=("${ids[@]}")
  else for n in $choice; do [[ "$n" =~ ^[0-9]+$ && $n -ge 1 && $n -le $i ]] && sel+=("${ids[$((n-1))]}"); done; fi
  [[ ${#sel[@]} -eq 0 ]] && { echo "Seleção vazia."; return; }
  echo "Serão removidos ${#sel[@]} item(ns)."
  if ui_confirm "Confirmar?"; then cleaner_apply "${sel[@]}"; ui_ok "Concluído."; else ui_info "Cancelado."; fi
}
