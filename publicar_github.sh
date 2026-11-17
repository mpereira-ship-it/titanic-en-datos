#!/usr/bin/env bash
# Ejecutar desde la carpeta del proyecto: bash publicar_github.sh
set -euo pipefail
cd "$(dirname "$0")"
REPO="titanic-en-datos"
for programa in git gh; do
  if ! command -v "$programa" >/dev/null 2>&1; then
    echo "Falta $programa. En Ubuntu: sudo apt install git gh"
    exit 1
  fi
done
if ! gh auth status >/dev/null 2>&1; then
  echo "Antes debes iniciar sesión con: gh auth login"
  exit 1
fi
if [ -d .git ]; then
  echo "Esta carpeta ya tiene un repositorio Git. Para actualizar usa: git add . && git commit -m 'Actualizacion' && git push"
  exit 1
fi
OWNER="$(gh api user --jq .login)"
echo "Se creará un repositorio PUBLICO: ${OWNER}/${REPO}"
echo "Los archivos de esta carpeta quedarán visibles en GitHub, incluido el modelo R de referencia."
read -r -p "¿Confirmas que deseas publicarlo? [s/N]: " CONFIRMACION
case "${CONFIRMACION}" in
  s|S|si|sí|Si|Sí) ;;
  *) echo "Cancelado sin cambios remotos"; exit 0;;
esac
if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
  echo "Configura tu autor Git antes de continuar:"
  echo '  git config --global user.name "Tu nombre"'
  echo '  git config --global user.email "tu-email-de-github@example.com"'
  exit 1
fi
git init -b main
git add .
git commit -m "Version inicial del simulador Titanic"
gh repo create "$REPO" --public --source=. --remote=origin --push
printf '{"source":{"branch":"main","path":"/"}}' | gh api --method POST "repos/${OWNER}/${REPO}/pages" --input - >/dev/null || {
  echo "El repositorio ya esta en GitHub, pero Pages no pudo activarse por API."
  echo "Activala desde Settings → Pages → Deploy from a branch → main → /(root)."
}
echo "Repositorio: https://github.com/${OWNER}/${REPO}"
echo "Pagina esperada cuando GitHub Pages complete el despliegue: https://${OWNER}.github.io/${REPO}/"
echo "Comprueba la URL definitiva en Settings → Pages antes de compartirla."
