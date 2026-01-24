#!/usr/bin/env bash
set -e

echo "=== Installation Docker Engine + Docker Compose v2 ==="

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

echo "Installation des dépendances nécessaires..."
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

echo "Configuration du dépôt Docker officiel..."

# Keyrings
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Distribution
DISTRO=$(lsb_release -cs)

# Dépôt
cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu ${DISTRO} stable
EOF

echo "Installation Docker Engine + plugins..."
apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "Activation et démarrage du service Docker..."
systemctl enable docker
systemctl start docker

# Ajout utilisateur au groupe docker
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
  echo "Utilisateur '$SUDO_USER' ajouté au groupe docker."
  echo "Déconnexion/reconnexion requise."
fi

echo
echo "Vérification installation..."
docker --version
docker compose version

echo
echo "Installation Docker terminée avec succès."
