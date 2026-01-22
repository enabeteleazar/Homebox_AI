#!/usr/bin/env bash
set -e

echo "=== Installation Python (Ubuntu / Debian) ==="

# Vérification root
if [ "$EUID" -ne 0 ]; then
  echo "ERREUR: ce script doit être exécuté en root (sudo)"
  exit 1
fi

# Vérification OS
if [ ! -f /etc/debian_version ]; then
  echo "ERREUR: OS non supporté (Debian / Ubuntu uniquement)"
  exit 1
fi

echo "Mise à jour des dépôts..."
apt-get update

echo "Installation des dépendances système..."
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  build-essential \
  ca-certificates \
  curl \
  git \
  unzip

echo "Nettoyage..."
apt-get autoremove -y
apt-get clean

echo "Vérification des versions installées..."
python3 --version
pip3 --version

echo
echo "Installation Python terminée avec succès."

echo
echo "Recommandations:"
echo "- Utiliser python3 + venv (pas pip global)"
echo "- Créer les environnements dans /opt/venvs ou par projet"
