#!/bin/bash

# ~/homebox/bash/stop_all.sh

HOMEBOX_DIR="/opt/Homebox_AI/Services"
SERVICES=(
        "Beszel"
        "Cadvisor"
        "Grafana"
        "HomeAssistant"
        "n8n"
        "NginxProxy"
        "Node-Red"
        "Portainer"
        "Prometheus"
        "Pythonista"
)

echo "🛑 Arrêt de HomeBox..."

for service in "${SERVICES[@]}"; do
    if [ -d "$HOMEBOX_DIR/$service" ]; then
        echo "⏹️  Arrêt de $service..."
        cd "$HOMEBOX_DIR/$service"
	docker compose --env-file /opt/Homebox_AI/Env/.env down

    fi
done

echo "✅ HomeBox arrêté !"
