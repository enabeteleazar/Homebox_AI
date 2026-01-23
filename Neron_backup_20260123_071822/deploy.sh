#!/bin/bash
# deploy_neron_v02.sh - Déploiement automatique Néron v0.2

set -euo pipefail

# ==========================================================
# Configuration
# ==========================================================

PROJECT_DIR="/opt/Labo/Neron"
BACKUP_DIR="/opt/Labo/Neron_backup_$(date +%Y%m%d_%H%M%S)"

# ==========================================================
# Couleurs (tput-safe)
# ==========================================================

if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
else
  BOLD=""
  RESET=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
fi

# ==========================================================
# Fonctions de log
# ==========================================================

log_info() {
  echo "${BLUE}[INFO]${RESET} $1"
}

log_success() {
  echo "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
  echo "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
  echo "${RED}[ERROR]${RESET} $1"
}

# ==========================================================
# Fonctions utilitaires
# ==========================================================

create_backup() {
  log_info "Création d’une sauvegarde dans $BACKUP_DIR..."
  if [[ -d "$PROJECT_DIR" ]]; then
    cp -r "$PROJECT_DIR" "$BACKUP_DIR"
    log_success "Sauvegarde créée"
  else
    log_warning "Aucun projet existant à sauvegarder"
  fi
}

create_directories() {
  log_info "Création de la structure de dossiers..."
  mkdir -p "$PROJECT_DIR"/{neron-core,neron-stt,neron-memory,neron-llm}
  log_success "Structure créée"
}

# ==========================================================
# Début du script
# ==========================================================

clear
echo "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════════╗"
echo "║        DÉPLOIEMENT NÉRON v0.2 - AUTO           ║"
echo "╚════════════════════════════════════════════════╝"
echo "${RESET}"

# Vérification des permissions
if [[ ! -w "/opt/Labo" ]]; then
  log_error "Permissions insuffisantes sur /opt/Labo"
  log_info "Relancez avec sudo si nécessaire"
  exit 1
fi

# Sauvegarde
create_backup

# Création des dossiers
create_directories

# ==========================================================
# docker-compose.yml
# ==========================================================

log_info "Création de docker-compose.yml..."
cat > "$PROJECT_DIR/docker-compose.yml" <<'EOFCOMPOSE'
services:

  neron-core:
    build: ./neron-core
    env_file:
      - ${ENV_PATH:-.}/.env
    container_name: neron-core
    ports:
      - "${NERON_CORE_HTTP:-8000}:8000"
    depends_on:
      neron-llm:
        condition: service_healthy
      neron-stt:
        condition: service_healthy
      neron-memory:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    networks:
      - neron-network

  neron-llm:
    image: ollama/ollama
    env_file:
      - ${ENV_PATH:-.}/.env
    container_name: neron-llm
    volumes:
      - ${DOCKER_DATA_PATH:-./data}/ollama:/root/.ollama
    ports:
      - "${NERON_LLM_HTTP:-11434}:11434"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 5
    restart: unless-stopped
    networks:
      - neron-network

  neron-stt:
    build: ./neron-stt
    env_file:
      - ${ENV_PATH:-.}/.env
    container_name: neron-stt
    ports:
      - "${NERON_STT_HTTP:-8001}:8001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    networks:
      - neron-network

  neron-memory:
    build: ./neron-memory
    env_file:
      - ${ENV_PATH:-.}/.env
    container_name: neron-memory
    volumes:
      - ${DOCKER_DATA_PATH:-./data}/memory:/data
    ports:
      - "${NERON_MEMORY_HTTP:-8002}:8002"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8002/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    networks:
      - neron-network

networks:
  neron-network:
    driver: bridge
EOFCOMPOSE

log_success "docker-compose.yml créé"

# ==========================================================
# .env.example
# ==========================================================

log_info "Création de .env.example..."
cat > "$PROJECT_DIR/.env.example" <<'EOFENV'
NERON_CORE_HTTP=8000
NERON_STT_HTTP=8001
NERON_MEMORY_HTTP=8002
NERON_LLM_HTTP=11434

DOCKER_DATA_PATH=/opt/Labo/Data
ENV_PATH=/opt/Labo/Env

OLLAMA_MODEL=mistral
WHISPER_MODEL=base

STT_TIMEOUT=30
LLM_TIMEOUT=60
MEMORY_TIMEOUT=5

LOG_LEVEL=INFO

NERON_STT_URL=http://neron-stt:8001
NERON_LLM_URL=http://neron-llm:11434
NERON_MEMORY_URL=http://neron-memory:8002
EOFENV

log_success ".env.example créé"

# ==========================================================
# Fin
# ==========================================================

log_success "Déploiement Néron v0.2 terminé"
log_info "Lance ensuite : ./start_neron.sh"
