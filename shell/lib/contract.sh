#!/bin/bash
# Contrato que todo cleaner implementa (ISP/LSP). Usado pelo menu CLI e pela interface web.
#   name            -> nome exibido
#   kind            -> path | cmd | explore | nm | items
#   kb              -> tamanho recuperável em KB (-1 = desconhecido)
#   size            -> tamanho legível (derivado de kb)
#   plan [dir]      -> o que seria afetado, linhas "kb<TAB>id[<TAB>label]" (não altera nada)
#                      id é um caminho (path/explore/nm) ou um identificador (items)
#   apply [paths..] -> executa SEM perguntar (quem chama é responsável pela confirmação)
#   run             -> fluxo interativo no terminal: plan + confirmação + apply
# Cada strategy define cleaner_name/kind/kb/plan/apply (e opcionalmente cleaner_run).
cleaner_size() { local kb; kb=$(cleaner_kb); [[ "$kb" -lt 0 ]] && echo "-" || fs_human "$kb"; }

cleaner_run_default() {
  ui_title "$(cleaner_name)"
  local plan kb p; plan=$(cleaner_plan)
  [[ -z "$plan" ]] && { ui_dim "Nada encontrado."; return; }
  echo "Será executado/apagado:"
  local label
  while IFS=$'\t' read -r kb p label; do
    [[ -n "$label" ]] && p="$label"
    [[ "$kb" == "-1" ]] && echo "  - $p" || echo "  - $p ($(fs_human "$kb"))"
  done <<< "$plan"
  if ui_confirm "Confirmar?"; then cleaner_apply && ui_ok "Concluído."; else ui_info "Cancelado."; fi
}
type cleaner_run >/dev/null 2>&1 || cleaner_run() { cleaner_run_default; }

cleaner_dispatch() {
  local c="${1:-}"; shift || true
  case "$c" in
    name) cleaner_name ;;  kind) cleaner_kind ;;  kb) cleaner_kb ;;  size) cleaner_size ;;
    plan) cleaner_plan "$@" ;;  apply) cleaner_apply "$@" ;;  run) cleaner_run ;;
    *) echo "uso: $0 {name|kind|kb|size|plan|apply|run}" >&2; return 2 ;;
  esac
}
