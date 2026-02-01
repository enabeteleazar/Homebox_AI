#!/bin/bash

# ========================================
# HomeBox Update Script with Telegram notifications
# ========================================

set -a
source /opt/Homebox_AI/Env/.env
set +a

set -e

# ---------------------------
# CONFIG TELEGRAM
# ---------------------------
echo "TELEGRAM_BOT_TOKEN : $TELEGRAM_BOT_TOKEN"
echo "TELEGRAM_CHAT_ID : $TELEGRAM_CHAT_ID"

send_telegram() {
    local MESSAGE=$1
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$MESSAGE" \
         -d parse_mode="Markdown" > /dev/null
}

update_system_packages() {
    echo "===================================="
    echo "🔄 Mise à jour du système avec apt"
    echo "===================================="

    sudo apt update -y
    sudo apt upgrade -y
    sudo apt full-upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean -y

    echo "✅ Mise à jour du système terminée !"
    send_telegram "✅ *HomeBox Update* : Système Ubuntu mis à jour avec succès !"
}

update_service() {
    echo "===================================="
    echo "🔄 Début de la mise à jour HomeBox"
    echo "===================================="

send_telegram "🔄 *HomeBox Update* : Début de la mise à jour des services."

    local SERVICE_PATH=$1
    echo "------------------------------------"
    echo "🔹 Mise à jour du service: $SERVICE_PATH"
    echo "------------------------------------"

    if [ -f "$SERVICE_PATH/docker-compose.yaml" ]; then
        cd "$SERVICE_PATH" || { echo "⚠ Impossible de cd dans $SERVICE_PATH"; return 1; }

        # Correction automatique des permissions pour Grafana
        if [[ "$SERVICE_PATH" == *"Grafana"* ]]; then
            echo "🔧 Correction des permissions pour Grafana..."
            mkdir -p "$SERVICE_PATH/data"
            chown -R 472:472 "$SERVICE_PATH/data"
        fi

        echo "⬇ Pull des dernières images..."
        if ! docker compose pull; then
            echo "⚠ Échec du pull pour $SERVICE_PATH"
            send_telegram "⚠️ *HomeBox Update* : Échec du pull pour $SERVICE_PATH"
            return 1
        fi

        echo "🛑 Stop des conteneurs..."
        docker compose down

        echo "🔧 Rebuild et relance du service..."
        if ! docker compose up -d --build; then
            echo "⚠ Échec du build/up pour $SERVICE_PATH"
            send_telegram "⚠️ *HomeBox Update* : Échec du rebuild/up pour $SERVICE_PATH"
            return 1
        fi

        echo "✅ Service $SERVICE_PATH mis à jour et relancé"
        send_telegram "✅ *HomeBox Update* : Service $SERVICE_PATH mis à jour et relancé"
        cd - >/dev/null
    else
        echo "⚠ Aucun docker-compose.yaml trouvé pour $SERVICE_PATH, skipping..."
        send_telegram "⚠️ *HomeBox Update* : Aucun docker-compose.yaml trouvé pour $SERVICE_PATH"
    fi
}



# Définir les services à mettre à jour
SERVICES=("homeassistant" "monitoring/cadvisor" "monitoring/prometheus" "monitoring/grafana" "portainer" "nginx-proxy-manager" "codi-tv" "ollama")

# Fonction pour mettre à jour un service
update_service() {
    local SERVICE_PATH=$1
    echo "------------------------------------"
    echo "🔹 Mise à jour du service: $SERVICE_PATH"
    echo "------------------------------------"
    
    if [ -f "$SERVICE_PATH/docker-compose.yaml" ]; then
        cd "$SERVICE_PATH"
        echo "⬇️  Pull des dernières images..."
        docker compose pull

        echo "🛑 Stop des conteneurs..."
        docker compose down

        echo "🔧 Rebuild si nécessaire..."
        docker compose up -d --build

        echo "✅ Service $SERVICE_PATH mis à jour et relancé"
        cd - >/dev/null
    else
        echo "⚠️  Aucun docker-compose.yaml trouvé pour $SERVICE_PATH, skipping..."
    fi
}

# Boucle sur tous les services
for SERVICE in "${SERVICES[@]}"; do
    update_service "$SERVICE"
done

# Nettoyage des images et volumes inutilisés
echo "🧹 Nettoyage des images et volumes inutilisés..."
docker system prune -af --volumes

echo "===================================="
echo "🎉 Mise à jour HomeBox terminée !"
echo "===================================="

send_telegram "🎉 *HomeBox Update* : Tous les services ont été mis à jour avec succès ! ✅"
