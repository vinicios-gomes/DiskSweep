#!/bin/bash
source "$(dirname "$0")/../lib/strategy_items.sh"
CLEANER_NAME="Docker: imagens (escolher quais remover)"
CLEANER_REQUIRES="docker"

items_list() { # converte o tamanho textual do docker (kB/MB/GB) para KB
  docker image ls --format '{{.ID}}|{{.Repository}}:{{.Tag}}|{{.Size}}' 2>/dev/null | awk -F'|' '
    !seen[$1]++ { v=$3; n=v+0; u=v; gsub(/[0-9.]/,"",u);
      if(u=="GB") n*=1048576; else if(u=="MB") n*=1024; else if(u=="kB"||u=="KB") n*=1; else if(u=="B") n/=1024;
      printf "%d\t%s\t%s (%s)\n", n, $1, $2, $3 }'
}
items_delete() { docker rmi "$1"; }

cleaner_dispatch "$@"
