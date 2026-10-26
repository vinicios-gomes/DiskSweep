#!/bin/bash
# Cria e envia a tag vX.Y.Z a partir da main; o workflow "Release" gera o .dmg e publica.
# Uso: ./scripts/release.sh 1.2.0
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="${1:-}"; [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "uso: $0 X.Y.Z" >&2; exit 2; }
TAG="v$VERSION"

[[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]] || { echo "Troque para a branch main." >&2; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "Há alterações não commitadas." >&2; exit 1; }
git fetch -q origin main --tags
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] || { echo "main local difere de origin/main (pull/push primeiro)." >&2; exit 1; }
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null && { echo "A tag $TAG já existe." >&2; exit 1; }

read -r -p "Publicar $TAG a partir de $(git rev-parse --short HEAD)? [s/N] " ans
[[ "$ans" == "s" || "$ans" == "S" ]] || { echo "Cancelado."; exit 1; }
git tag -a "$TAG" -m "DiskSweep $TAG"
git push origin "$TAG"
echo "Tag enviada. Acompanhe: gh run watch  |  Release: https://github.com/vinicios-gomes/DiskSweep/releases/tag/$TAG"
