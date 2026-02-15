#!/bin/bash
# start_homebox.sh - Lance Services V1.3.2 sur Homebox (Docker Compose moderne)

set -e

echo "╔════════════════════════════════════════╗"
echo "║  🧪 Lancement de Homebox v1.3.2         "
echo "╔════════════════════════════════════════╗"
echo ""

set -euo pipefail
clear

# --- Couleurs ---
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$RESET

# --- Fonctions ---
slow_echo() {
    local text="$1"
    local delay="${2:-0.01}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo
}

check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Docker n'est pas installé. Installez docker.io et le plugin docker compose.${NC}"
        exit 1
    fi
}


# --- Début du script ---
slow_echo "${BOLD}${BLUE}Vérification Docker...${NC}"
check_docker
slow_echo "${GREEN}Docker OK${NC}"

slow_echo "${BOLD}${BLUE}Construction et lancement des conteneurs Homebox...${NC}"
docker compose --env-file /opt/Homebox_AI/.env up -d --build --remove-orphans

slow_echo "${GREEN}Tous les services Homebox v1.3.2 sont lancés !${NC}"

# --- Affichage du statut ---
show_status

slow_echo "${YELLOW}Pour suivre les logs du Core: docker compose logs -f ${NC}"
