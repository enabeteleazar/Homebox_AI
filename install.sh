#!/bin/bash

# ============================================

# HOMEBOX_AI - Script d’Installation Automatique

# ============================================

# Ce script automatise l’installation complète de Homebox_AI

set -e

# Couleurs pour l’affichage

RED=’\033[0;31m’
GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
BLUE=’\033[0;34m’
NC=’\033[0m’ # No Color

# Configuration

INSTALL_DIR=”/opt/Homebox_AI”
BACKUP_DEST=”/mnt/usb-storage/Backup/Homebox_AI”

# Fonction d’affichage

print_step() {
echo -e “\n${BLUE}===================================${NC}”
echo -e “${BLUE}$1${NC}”
echo -e “${BLUE}===================================${NC}\n”
}

print_success() {
echo -e “${GREEN}✓ $1${NC}”
}

print_warning() {
echo -e “${YELLOW}⚠ $1${NC}”
}

print_error() {
echo -e “${RED}✗ $1${NC}”
}

# Vérification de l’utilisateur root

check_root() {
if [[ $EUID -ne 0 ]]; then
print_error “Ce script doit être exécuté en tant que root ou avec sudo”
exit 1
fi
}

# Détection de l’OS

detect_os() {
if [[ -f /etc/os-release ]]; then
. /etc/os-release
OS=$NAME
VER=$VERSION_ID
else
print_error “Système d’exploitation non supporté”
exit 1
fi

```
print_success "OS détecté: $OS $VER"
```

}

# Installation des dépendances système

install_dependencies() {
print_step “Installation des dépendances système”

```
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    wget

print_success "Dépendances système installées"
```

}

# Installation de Docker

install_docker() {
print_step “Installation de Docker”

```
if command -v docker &> /dev/null; then
    print_warning "Docker est déjà installé ($(docker --version))"
    return
fi

# Ajouter la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajouter le repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Démarrer et activer Docker
systemctl start docker
systemctl enable docker

# Ajouter l'utilisateur au groupe docker
if [[ -n $SUDO_USER ]]; then
    usermod -aG docker $SUDO_USER
    print_success "Utilisateur $SUDO_USER ajouté au groupe docker"
fi

print_success "Docker installé: $(docker --version)"
```

}

# Clonage du repository

clone_repository() {
print_step “Clonage du repository Homebox_AI”

```
if [[ -d "$INSTALL_DIR" ]]; then
    print_warning "Le dossier $INSTALL_DIR existe déjà"
    read -p "Voulez-vous le supprimer et réinstaller ? (o/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        print_error "Installation annulée"
        exit 1
    fi
fi

git clone https://github.com/enabeteleazar/Homebox_AI.git "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Permissions
if [[ -n $SUDO_USER ]]; then
    chown -R $SUDO_USER:$SUDO_USER "$INSTALL_DIR"
fi

print_success "Repository cloné dans $INSTALL_DIR"
```

}

# Création des réseaux Docker

create_networks() {
print_step “Création des réseaux Docker”

```
if docker network ls | grep -q "Homebox_Network"; then
    print_warning "Le réseau Homebox_Network existe déjà"
else
    docker network create Homebox_Network
    print_success "Réseau Homebox_Network créé"
fi

if docker network ls | grep -q "Neron_Network"; then
    print_warning "Le réseau Neron_Network existe déjà"
else
    docker network create Neron_Network
    print_success "Réseau Neron_Network créé"
fi
```

}

# Création de la structure de données

create_data_structure() {
print_step “Création de la structure de données”

```
cd "$INSTALL_DIR"

mkdir -p Data/{portainer,nginx-proxy-manager,homeassistant,n8n,node-red,Beszel,grafana,prometheus}
mkdir -p Data/nginx-proxy-manager/{mysql,letsencrypt}
mkdir -p Data/grafana/{data,provisioning}
mkdir -p Data/prometheus/{config,data}

# Permissions spécifiques pour Grafana
chown -R 472:472 Data/grafana/data

# Permissions générales
if [[ -n $SUDO_USER ]]; then
    chown -R $SUDO_USER:$SUDO_USER Data/
fi

print_success "Structure de données créée"
```

}

# Configuration de Prometheus

configure_prometheus() {
print_step “Configuration de Prometheus”

```
cat > "$INSTALL_DIR/Data/prometheus/config/prometheus.yml" << 'EOF'
```

global:
scrape_interval: 15s
evaluation_interval: 15s

scrape_configs:

- job_name: ‘prometheus’
  static_configs:
  - targets: [‘localhost:9090’]
- job_name: ‘cadvisor’
  static_configs:
  - targets: [‘cadvisor:8080’]
    EOF
  
  print_success “Configuration Prometheus créée”
  }

# Configuration du fichier .env

configure_env() {
print_step “Configuration du fichier .env”

```
if [[ -f "$INSTALL_DIR/.env" ]]; then
    print_warning "Le fichier .env existe déjà"
    return
fi

# Générer des mots de passe aléatoires sécurisés
NPM_ROOT_PASS=$(openssl rand -base64 32)
NPM_USER_PASS=$(openssl rand -base64 32)
GRAFANA_PASS=$(openssl rand -base64 32)

cat > "$INSTALL_DIR/.env" << EOF
```

# === PATHS ===

DOCKER_DATA_PATH=$INSTALL_DIR/Data

# === USER & GROUP IDs ===

PUID=$(id -u $SUDO_USER 2>/dev/null || echo 1000)
PGID=$(id -g $SUDO_USER 2>/dev/null || echo 1000)

# === PORTAINER ===

PORTAINER_HTTP=9000
PORTAINER_HTTPS=9443

# === NGINX PROXY MANAGER ===

NGINX_PROXY_HTTP=80
NGINX_PROXY_HTTPS=443
NGINX_PROXY_ADMIN=81

NPM_DB_ROOT_PASSWORD=$NPM_ROOT_PASS
NPM_DB_NAME=npm_db
NPM_DB_USER=npm_user
NPM_DB_PASSWORD=$NPM_USER_PASS

# === HOME ASSISTANT ===

HOMEASSISTANT_HTTP=8123

# === N8N ===

N8N_HTTP=5678
N8N_HOST=0.0.0.0
N8N_WEBHOOK_URL=http://localhost:5678

# === NODE-RED ===

NODE_RED_HTTP=1880

# === MONITORING ===

BESZEL_HTTP=8090
CADVISOR_HTTP=8081
GRAFANA_HTTP=3001
PROMETHEUS_HTTP=9090

GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$GRAFANA_PASS
GRAFANA_ROOT_URL=http://localhost:3001

# === TELEGRAM ===

TELEGRAM_BOT_TOKEN=VOTRE_TOKEN_ICI
TELEGRAM_CHAT_ID=VOTRE_CHAT_ID_ICI
EOF

```
chmod 600 "$INSTALL_DIR/.env"

if [[ -n $SUDO_USER ]]; then
    chown $SUDO_USER:$SUDO_USER "$INSTALL_DIR/.env"
fi

print_success "Fichier .env créé avec des mots de passe sécurisés"
print_warning "IMPORTANT: Notez le mot de passe Grafana: $GRAFANA_PASS"
```

}

# Rendre les scripts exécutables

make_scripts_executable() {
print_step “Configuration des scripts”

```
chmod +x "$INSTALL_DIR"/*.sh
chmod +x "$INSTALL_DIR/Scripts"/*.sh

print_success "Scripts rendus exécutables"
```

}

# Configuration des backups

configure_backups() {
print_step “Configuration des backups (optionnel)”

```
read -p "Voulez-vous configurer les backups automatiques ? (o/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Oo]$ ]]; then
    # Créer le dossier de destination des backups
    mkdir -p "$BACKUP_DEST"
    
    # Ajouter au crontab
    print_warning "Pour activer les backups automatiques, ajoutez à crontab:"
    echo "sudo crontab -e"
    echo "Puis ajoutez: 0 2 * * * $INSTALL_DIR/Scripts/Homebox_Backup.sh"
fi
```

}

# Démarrage des services

start_services() {
print_step “Démarrage des services”

```
read -p "Voulez-vous démarrer les services maintenant ? (O/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    cd "$INSTALL_DIR"
    
    # Si lancé avec sudo, exécuter en tant qu'utilisateur normal
    if [[ -n $SUDO_USER ]]; then
        sudo -u $SUDO_USER docker compose up -d
    else
        docker compose up -d
    fi
    
    sleep 5
    
    # Afficher le statut
    sudo -u $SUDO_USER bash "$INSTALL_DIR/status.sh" || bash "$INSTALL_DIR/status.sh"
    
    print_success "Services démarrés avec succès!"
fi
```

}

# Affichage du résumé

display_summary() {
print_step “Installation terminée !”

```
echo -e "${GREEN}Homebox_AI a été installé avec succès !${NC}\n"

echo "📍 Installation: $INSTALL_DIR"
echo "🔐 Configuration: $INSTALL_DIR/.env"
echo ""
echo "🌐 Accès aux services:"
echo "  • Portainer:        http://localhost:9000"
echo "  • Nginx Proxy:      http://localhost:81"
echo "  • Home Assistant:   http://localhost:8123"
echo "  • n8n:              http://localhost:5678"
echo "  • Node-RED:         http://localhost:1880"
echo "  • Grafana:          http://localhost:3001"
echo "  • Prometheus:       http://localhost:9090"
echo ""
echo "📜 Commandes utiles:"
echo "  • Démarrer:   cd $INSTALL_DIR && ./start.sh"
echo "  • Arrêter:    cd $INSTALL_DIR && ./stop.sh"
echo "  • Statut:     cd $INSTALL_DIR && ./status.sh"
echo ""
echo "⚠️  IMPORTANT:"
echo "  1. Changez tous les mots de passe par défaut"
echo "  2. Configurez votre bot Telegram dans .env"
echo "  3. Mot de passe Grafana noté ci-dessus"
echo ""
echo "📚 Documentation complète: $INSTALL_DIR/README.md"
echo ""

if [[ -n $SUDO_USER ]]; then
    echo -e "${YELLOW}⚠️  Déconnectez-vous et reconnectez-vous pour que les permissions Docker prennent effet${NC}"
fi
```

}

# ============================================

# MAIN - Exécution du script

# ============================================

clear
echo -e “${BLUE}”
cat << “EOF”
╔════════════════════════════════════════╗
║     HOMEBOX_AI - INSTALLATION          ║
║     Plateforme Domotique All-in-One    ║
╚════════════════════════════════════════╝
EOF
echo -e “${NC}”

check_root
detect_os
install_dependencies
install_docker
clone_repository
create_networks
create_data_structure
configure_prometheus
configure_env
make_scripts_executable
configure_backups
start_services
display_summary

print_success “Installation complète ! 🎉”
