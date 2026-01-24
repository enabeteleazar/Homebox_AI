#!/bin/bash

# Nom approximatif pour détecter l'Anker
ANKER_NAME="Anker"

echo "=== Vérification du périphérique USB ==="
lsusb | grep -i "$ANKER_NAME"
if [ $? -ne 0 ]; then
    echo "Anker USB non détecté. Vérifie le câble ou le port USB."
    exit 1
fi

echo "Anker détecté !"

# Charger module USB audio si nécessaire
if ! lsmod | grep -q snd_usb_audio; then
    echo "Chargement du module snd-usb-audio..."
    sudo modprobe snd-usb-audio
else
    echo "Module snd-usb-audio déjà chargé."
fi

sleep 1

echo "=== Cartes son disponibles ==="
arecord -l
aplay -l

# Identifier la première carte USB détectée
CARD=$(arecord -l | grep "card" | grep -i "$ANKER_NAME" | awk '{print $2}' | tr -d ':')
if [ -z "$CARD" ]; then
    echo "Impossible de trouver la carte Anker pour le test audio."
    exit 1
fi

echo "Carte Anker détectée : $CARD"

# Enregistrement test micro (3 secondes)
echo "Test du micro (3 secondes)..."
arecord -D plughw:$CARD,0 -f cd -d 3 test_anker.wav

# Lecture test enceinte
echo "Lecture sur l'enceinte..."
aplay -D plughw:$CARD,0 test_anker.wav

echo "Test terminé. Si tu as entendu le son, le micro et l'enceinte fonctionnent !"
