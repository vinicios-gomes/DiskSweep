#!/bin/bash
# Strategy: localizar node_modules e apagar os escolhidos.
# Variáveis: CLEANER_NAME, CLEANER_ROOT
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB/ui.sh"; source "$LIB/fs.sh"; source "$LIB/contract.sh"

cleaner_name() { echo "$CLEANER_NAME"; }
cleaner_kind() { echo nm; }
cleaner_kb()   { echo -1; }
cleaner_plan() {
  find "$CLEANER_ROOT" -maxdepth 6 -name node_modules -type d -prune \
    -not -path "*/Library/*" -not -path "*/.npm/*" -not -path "*/node_modules/*" 2>/dev/null \
    | while IFS= read -r d; do du -sk "$d" 2>/dev/null; done | sort -rn | head -30
}
cleaner_apply() { # só aceita pastas chamadas node_modules dentro do root
  local p root; root=$(fs_realdir "$CLEANER_ROOT")
  for p in "$@"; do
    if [[ "$(basename "$p")" == "node_modules" && -d "$p" ]] && fs_within "$(fs_realdir "$(dirname "$p")")" "$root"; then
      fs_safe_rm "$p" && echo "apagado: $p"
    else ui_warn "Ignorado: $p"; fi
  done
}
cleaner_run() {
  local items=() sizes=() kb path i choice n sel=()
  ui_title "$CLEANER_NAME"; echo "Buscando em $CLEANER_ROOT (pode demorar)..."
  while IFS=$'\t' read -r kb path; do items+=("$path"); sizes+=("$(fs_human "$kb")"); done < <(cleaner_plan)
  [[ ${#items[@]} -eq 0 ]] && { echo "Nenhum encontrado."; return; }
  for i in "${!items[@]}"; do printf " %2d) %8s  %s\n" $((i+1)) "${sizes[$i]}" "${items[$i]}"; done
  echo "  Números separados por espaço (ex: 1 3), 'todos', ou 0 para voltar."
  read -r choice
  [[ "$choice" == "0" || -z "$choice" ]] && return
  if [[ "$choice" == "todos" ]]; then sel=("${items[@]}")
  else for n in $choice; do [[ "$n" =~ ^[0-9]+$ && $n -ge 1 && $n -le ${#items[@]} ]] && sel+=("${items[$((n-1))]}"); done; fi
  [[ ${#sel[@]} -eq 0 ]] && { echo "Seleção vazia."; return; }
  echo "Será apagado:"; printf '  - %s\n' "${sel[@]}"
  if ui_confirm "Confirmar exclusão? (npm install restaura)"; then cleaner_apply "${sel[@]}" >/dev/null; ui_ok "Concluído."; else ui_info "Cancelado."; fi
}
