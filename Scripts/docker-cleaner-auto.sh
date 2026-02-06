#!/bin/bash
# Script pour nettoyer Docker automatiquement et notifier via Telegram
# Les variables TELEGRAM_BOT_TOKEN et TELEGRAM_CHAT_ID sont récupérées depuis le fichier .env

#  Charger le fichier .env
ENV_FILE="/opt/Homebox_AI/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Fichier .env non trouvé : $ENV_FILE"
    exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

# Vérification que les variables existent
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "❌ TELEGRAM_BOT_TOKEN ou TELEGRAM_CHAT_ID non défini dans le .env"
    exit 1
fi

# Fonction pour envoyer un message Telegram
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="Markdown"
}

echo -e "\033[1;34m[DOCKER CLEANUP] Résumé avant nettoyage :\033[0m"
docker system df
echo

echo -e "\033[1;33m[DOCKER CLEANUP] Suppression des conteneurs, images et réseaux inutilisés...\033[0m"
docker system prune -a -f

echo -e "\033[1;33m[DOCKER CLEANUP] Suppression des volumes Docker non utilisés...\033[0m"
docker volume prune -f

echo
echo -e "\033[1;32m[DOCKER CLEANUP] Terminé. Résumé après nettoyage :\033[0m"
docker system df

# 🔹 Envoi du message Telegram
send_telegram "🚀 Néron a terminé le nettoyage Docker sur le serveur.\n✅ Conteneurs, images, réseaux et volumes inutilisés supprimés."
