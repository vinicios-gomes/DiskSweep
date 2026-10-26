#!/bin/bash
# Strategy: explorar uma pasta e apagar subitens individualmente.
# Variáveis: CLEANER_NAME, CLEANER_TARGET, CLEANER_SIZE_SKIP (1 = não calcular tamanho)
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB/ui.sh"; source "$LIB/fs.sh"; source "$LIB/contract.sh"

_root() { fs_realdir "$CLEANER_TARGET"; }

cleaner_name() { echo "$CLEANER_NAME"; }
cleaner_kind() { echo explore; }
cleaner_kb() {
  [[ "${CLEANER_SIZE_SKIP:-0}" == "1" || ! -e "$CLEANER_TARGET" ]] && { [[ -e "$CLEANER_TARGET" ]] && echo -1 || echo 0; return; }
  fs_kb "$CLEANER_TARGET"
}

cleaner_plan() { # [dir] -> top 25 subitens "kb<TAB>caminho"; dir deve estar dentro do alvo
  local dir="${1:-$CLEANER_TARGET}" real root; root=$(_root); real=$(fs_realdir "$dir")
  [[ -n "$real" && -n "$root" ]] && fs_within "$real" "$root" || { ui_warn "Pasta fora do escopo: $dir" >&2; return 1; }
  du -sk "$real"/* "$real"/.[!.]* 2>/dev/null | sort -rn | head -25
}

cleaner_apply() { # paths... (validados: precisam estar dentro do alvo)
  local p parent root; root=$(_root)
  for p in "$@"; do
    parent=$(fs_realdir "$(dirname "$p")")
    if [[ -n "$parent" && "$p" != "$CLEANER_TARGET" ]] && fs_within "$parent" "$root"; then
      fs_safe_rm "$p" && echo "apagado: $p"
    else ui_warn "Ignorado (fora do escopo): $p"; fi
  done
}

_explore() {
  local dir="$1" items=() sizes=() kb path i choice n t
  [[ -d "$dir" ]] || { ui_dim "Pasta não existe: $dir"; return; }
  while true; do
    echo; ui_title "Explorando: $dir (calculando tamanhos...)"
    items=(); sizes=()
    while IFS=$'\t' read -r kb path; do items+=("$path"); sizes+=("$(fs_human "$kb")"); done < <(cleaner_plan "$dir")
    [[ ${#items[@]} -eq 0 ]] && { echo "Vazio."; return; }
    for i in "${!items[@]}"; do printf " %2d) %8s  %s\n" $((i+1)) "${sizes[$i]}" "$(basename "${items[$i]}")"; done
    echo "  Número = APAGAR | 'e N' = entrar na pasta | 0 = voltar"
    read -r choice
    case "$choice" in
      0|"") return ;;
      e\ *) n="${choice#e }"
            if [[ "$n" =~ ^[0-9]+$ && $n -ge 1 && $n -le ${#items[@]} && -d "${items[$((n-1))]}" ]]; then _explore "${items[$((n-1))]}"; else echo "Inválido."; fi ;;
      *)    if [[ "$choice" =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#items[@]} ]]; then
              t="${items[$((choice-1))]}"; echo "Apagar: $t (${sizes[$((choice-1))]})"
              if ui_confirm "Confirmar exclusão?"; then cleaner_apply "$t" >/dev/null && ui_ok "Apagado."; else ui_info "Cancelado."; fi
            else echo "Inválido."; fi ;;
    esac
  done
}
cleaner_run() { ui_title "$CLEANER_NAME"; _explore "$CLEANER_TARGET"; }
