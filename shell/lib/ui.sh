#!/bin/bash
# Responsabilidade única: interação com o usuário (cores, confirmação, pausa).
RED=$'\033[31m'; GRN=$'\033[32m'; YEL=$'\033[33m'; BLD=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'

ui_confirm() { # ui_confirm "mensagem" -> 0 somente se o usuário digitar s/S/sim
  local ans
  printf "%s%s%s [s/N]: " "$YEL" "$1" "$RST"
  read -r ans
  [[ "$ans" == "s" || "$ans" == "S" || "$ans" == "sim" ]]
}
ui_info()  { echo "$*"; }
ui_ok()    { echo "${GRN}$*${RST}"; }
ui_warn()  { echo "${RED}$*${RST}"; }
ui_dim()   { echo "${DIM}$*${RST}"; }
ui_title() { echo "${BLD}$*${RST}"; }
ui_pause() { printf "Enter para continuar..."; read -r _; }
