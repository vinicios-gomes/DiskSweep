#!/bin/bash
# Strategy: apagar um ou mais caminhos/globs.
# Variáveis: CLEANER_NAME, CLEANER_TARGETS=(globs...)
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB/ui.sh"; source "$LIB/fs.sh"; source "$LIB/contract.sh"

_matches() { local t f; for t in "${CLEANER_TARGETS[@]}"; do while IFS= read -r f; do [[ -n "$f" ]] && echo "$f"; done < <(fs_expand "$t"); done; }

cleaner_name() { echo "$CLEANER_NAME"; }
cleaner_kind() { echo path; }
cleaner_kb() {
  local m=() f; while IFS= read -r f; do m+=("$f"); done < <(_matches)
  [[ ${#m[@]} -eq 0 ]] && echo 0 || fs_kb "${m[@]}"
}

_in_scope() { # $1 = diretório real; true se é (ou está dentro de) algum alvo
  local m r; while IFS= read -r m; do r=$(fs_realdir "$m"); [[ -n "$r" ]] && fs_within "$1" "$r" && return 0; done < <(_matches); return 1
}

cleaner_plan() { # [dir] -> sem argumento lista os alvos; com dir lista os filhos (dentro do escopo)
  local f d
  if [[ -n "${1:-}" ]]; then
    d=$(fs_realdir "$1"); [[ -n "$d" ]] && _in_scope "$d" || { ui_warn "Pasta fora do escopo: $1" >&2; return 1; }
    du -sk "$d"/* "$d"/.[!.]* 2>/dev/null | sort -rn | head -50
  else
    while IFS= read -r f; do printf '%s\t%s\n' "$(fs_kb "$f")" "$f"; done < <(_matches)
  fi
}

cleaner_apply() { # sem argumentos apaga todos os alvos; com paths apaga só esses (validados)
  local f p parent
  if [[ $# -eq 0 ]]; then while IFS= read -r f; do fs_safe_rm "$f" && echo "apagado: $f"; done < <(_matches); return; fi
  for p in "$@"; do
    parent=$(fs_realdir "$(dirname "$p")")
    if { [[ -n "$parent" ]] && _in_scope "$parent"; } || _matches | grep -qxF -- "$p"; then
      fs_safe_rm "$p" && echo "apagado: $p"
    else ui_warn "Ignorado (fora do escopo): $p"; fi
  done
}
