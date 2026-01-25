
#!/bin/bash

# ~/homebox/bash/start_all.sh

HOMEBOX_DIR="/opt/Labo/Services"
SERVICES=(
    "Beszel"
    "Cadvisor"
    "Dashboard"
    "Grafana"
    "HomeAssistant"
    "n8n"
    "NginxProxy"
    "Node-Red"
    "Portainer"
    "Prometheus"
)

echo "🚀 Démarrage des Services ..."

# Créer le réseau s'il n'existe pa
if ! docker network ls | grep -q "Homebox"; then
    echo "📡 Création du réseau Homebox..."
    docker network create Homebox
fi

# Démarrer chaque service
for service in "${SERVICES[@]}"; do
    if [ -d "$HOMEBOX_DIR/$service" ]; then
        echo "▶️  Démarrage de $service..."
        cd "$HOMEBOX_DIR/$service"
        docker compose --env-file /opt/Labo/Env/.env  up -d --build
    else
        echo "⚠️  Dossier $service introuvable"
    fi
done

cd "$HOMEBOX_DIR"
echo "✅ HomeBox démarré !"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
