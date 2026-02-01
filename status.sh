#!/bin/bash

# ==================================================
#  HOMEBOX – Vérification des services (hors NERON)
# ==================================================

echo -e "\033[1;34m[HOMEBOX] Vérification de l'état des services (hors NERON)...\033[0m"

# 🔥 Récupère tous les containers
mapfile -t all_services < <(docker ps -a --format "{{.Names}}")

# Filtre pour exclure les conteneurs commençant par "neron"
services=()
for s in "${all_services[@]}"; do
    if [[ ! $s =~ ^neron ]]; then
        services+=("$s")
    fi
done

offline_list=()
online_count=0
offline_count=0

echo -e "\n📊 Services détectés (hors NERON) : ${#services[@]}"
echo "---------------------------------------------------------"
printf "%-25s %-20s %-15s\n" "CONTAINER" "PORTS" "STATUS"
echo "---------------------------------------------------------"

# Boucle de vérification
for s in "${services[@]}"; do
    ports=$(docker ps -a --filter "name=^${s}$" --format "{{.Ports}}")
    status=$(docker ps --filter "name=^${s}$" --format "{{.Status}}")

    if [[ -z "$status" ]]; then
        status="OFFLINE"
        offline_list+=("$s")
        ((offline_count++))
        printf "\033[1;31m%-25s %-20s %-15s\033[0m\n" "$s" "$ports" "$status"
    else
        ((online_count++))
        printf "\033[1;32m%-25s %-20s %-15s\033[0m\n" "$s" "$ports" "$status"
    fi
done

# === RÉSUMÉ =====================================
echo "---------------------------------------------------------"
echo -e "\n==============================="
echo -e "  🟢 ONLINE  : $online_count"
echo -e "  🔴 OFFLINE : $offline_count"
echo -e "==============================="

# === LISTE DES SERVICES OFFLINE ==================
if (( offline_count > 0 )); then
    echo -e "\n⚠️  Services arrêtés (hors NERON) :"
    for s in "${offline_list[@]}"; do
        echo -e "   - $s"
    done
fi
