#!/bin/bash

# ========================================
# HomeBox Backup Script with Telegram notifications
# ========================================

set -a
source /opt/Homebox_AI/Env/.env
set +a

set -e

# ---------------------------
# CONFIG TELEGRAM
# ---------------------------
send_telegram() {
    local MESSAGE=$1
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$MESSAGE" \
         -d parse_mode="Markdown" > /dev/null
}

# === CONFIGURATION ===
SOURCE="/opt/Neron_AI"				# Dossier à sauvegarder
DEST="/mnt/usb-storage/Backup/Neron_AI"		# Dossier de destination
LOG="$DEST/backup.log"               		# Fichier de log
MAX_BACKUPS=5                           	# Nombre max de backups à conserver

# === SCRIPT ===
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup_$DATE.tar.gz"

# Crée le dossier de destination si inexistant
mkdir -p "$DEST"

# Sauvegarde avec compression
if tar -czf "$DEST/$BACKUP_NAME" -C "$SOURCE" .; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup $BACKUP_NAME créé avec succès." >> "$LOG"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERREUR lors de la création de $BACKUP_NAME" >> "$LOG"
    exit 1
fi

# Supprimer les anciens backups dépassant MAX_BACKUPS
cd "$DEST" || exit
BACKUPS_COUNT=$(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUPS_COUNT" -gt "$MAX_BACKUPS" ]; then
    ls -1t backup_*.tar.gz | tail -n +"$((MAX_BACKUPS + 1))" | xargs rm -f
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Suppression des anciens backups pour ne garder que $MAX_BACKUPS." >> "$LOG"
fi

send_telegram "🎉 *Neron_AI Backup* : La sauvegarde a été effecutée ! ✅"
