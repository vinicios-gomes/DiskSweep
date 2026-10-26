#!/bin/bash
# Responsabilidade única: operações de sistema de arquivos (tamanho, remoção segura, expansão de glob).

fs_size() { # fs_size <caminho>... -> tamanho total legível (ex: 1,2G)
  local out
  out=$(du -sch "$@" 2>/dev/null | tail -1 | awk '{print $1}')
  echo "${out:-0B}"
}

fs_expand() { # fs_expand <glob> -> um caminho por linha (aceita espaços no padrão)
  compgen -G "$1"
}

fs_safe_rm() { # remove apenas dentro de $HOME e nunca o próprio $HOME
  local p="$1"
  if [[ -z "$p" || "$p" == "/" || "$p" == "$HOME" || "$p" == "$HOME/" || "$p" != "$HOME"/* ]]; then
    ui_warn "Recusado por segurança: '$p'"; return 1
  fi
  rm -rf -- "$p"
}

fs_free_space() { df -h /System/Volumes/Data | awk 'NR==2{print $4}'; }

fs_kb() { # fs_kb <caminho>... -> soma em KB (número inteiro)
  du -sk "$@" 2>/dev/null | awk '{s+=$1} END{print s+0}'
}

fs_human() { # fs_human <kb> -> 1.3G
  awk -v k="$1" 'BEGIN{ split("K M G T",u," "); i=1; while(k>=1024 && i<4){k/=1024;i++}
    if(i==1) printf "%dK\n",k; else printf "%.1f%s\n",k,u[i] }'
}

fs_realdir() { (cd "$1" 2>/dev/null && pwd -P); }

# true se $1 (caminho real do diretório) é $2 ou está dentro dele
fs_within() { [[ "$1" == "$2" || "$1" == "$2"/* ]]; }
