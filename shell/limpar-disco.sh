#!/bin/bash
# Orquestrador: descobre cleaners em ./cleaners, monta o menu e delega a execução.
# Depende apenas do contrato (name|size|run), nunca de um cleaner específico (DIP/OCP).
# Para adicionar um item novo: crie um arquivo em cleaners/ e dê chmod +x.
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib/ui.sh"; source "$ROOT/lib/fs.sh"

discover() { CLEANERS=(); local f; for f in "$ROOT"/cleaners/*.sh; do [[ -x "$f" ]] && CLEANERS+=("$f"); done; }

collect_sizes() { # calcula tamanhos em paralelo
  local tmp i; tmp=$(mktemp -d)
  for i in "${!CLEANERS[@]}"; do "${CLEANERS[$i]}" size > "$tmp/$i" 2>/dev/null & done
  wait
  SIZES=(); for i in "${!CLEANERS[@]}"; do SIZES+=("$(cat "$tmp/$i" 2>/dev/null)"); done
  rm -rf "$tmp"
}

render() {
  clear; ui_title "=== Limpeza de disco macOS ===   Livre: ${GRN}$(fs_free_space)${RST}"; echo
  local i; for i in "${!CLEANERS[@]}"; do printf " %2d) %8s  %s\n" $((i+1)) "${SIZES[$i]}" "$("${CLEANERS[$i]}" name)"; done
  echo; echo "  r) Recalcular    0) Sair"
}

discover
[[ ${#CLEANERS[@]} -eq 0 ]] && { ui_warn "Nenhum cleaner em $ROOT/cleaners"; exit 1; }
echo "Calculando tamanhos..."; collect_sizes
while true; do
  render; printf "Escolha: "; read -r opt
  case "$opt" in
    0|q) echo "Até mais."; exit 0 ;;
    r|"") echo "Recalculando..."; collect_sizes ;;
    *) if [[ "$opt" =~ ^[0-9]+$ && $opt -ge 1 && $opt -le ${#CLEANERS[@]} ]]; then
         echo; "${CLEANERS[$((opt-1))]}" run; echo; ui_pause; echo "Recalculando..."; collect_sizes
       else echo "Opção inválida."; sleep 1; fi ;;
  esac
done
