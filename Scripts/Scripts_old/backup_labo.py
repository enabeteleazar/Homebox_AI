#!/usr/bin/env python3
"""
Script de sauvegarde automatique pour HP HomeBox
Sauvegarde /opt/Labo vers clé USB avec horodatage
Journalisation complète dans Backup/backup.log
"""

import os
import sys
import subprocess
import shutil
from datetime import datetime

# Configuration
USB_DEVICE = "/dev/sdb1"
MOUNT_POINT = "/mnt/usb-storage"
SOURCE_DIR = "/opt/Labo"
BACKUP_DIR = f"{MOUNT_POINT}/Backup"
LOG_FILE = f"{BACKUP_DIR}/backup.log"
KEEP_LAST = 5  # Nombre de sauvegardes à conserver

# Couleurs pour terminal
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    END = '\033[0m'

def log(message, color=None):
    """Affiche un message avec couleur et écrit dans le log"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {message}"
    if color:
        print(f"{color}{line}{Colors.END}")
    else:
        print(line)
    # Écrire dans le fichier log
    try:
        os.makedirs(BACKUP_DIR, exist_ok=True)
        with open(LOG_FILE, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass  # Ne pas bloquer le script si le log échoue

def check_root():
    """Vérifie que le script est exécuté en tant que root"""
    if os.geteuid() != 0:
        log("ERREUR: Ce script doit être exécuté en tant que root (sudo)", Colors.RED)
        sys.exit(1)

def check_usb_device():
    """Vérifie la présence du périphérique USB"""
    log("Vérification de la présence de la clé USB…", Colors.BLUE)
    if not os.path.exists(USB_DEVICE):
        log(f"ERREUR: Le périphérique {USB_DEVICE} n'est pas détecté", Colors.RED)
        log("Vérifiez que la clé USB est bien branchée", Colors.YELLOW)
        sys.exit(1)
    log(f"✓ Périphérique {USB_DEVICE} détecté", Colors.GREEN)

def check_mount_point():
    """Vérifie et crée le point de montage"""
    log("Vérification du point de montage…", Colors.BLUE)
    if not os.path.exists(MOUNT_POINT):
        log(f"Création du dossier {MOUNT_POINT}...", Colors.YELLOW)
        try:
            os.makedirs(MOUNT_POINT, exist_ok=True)
            log(f"✓ Dossier {MOUNT_POINT} créé", Colors.GREEN)
        except Exception as e:
            log(f"ERREUR: Impossible de créer {MOUNT_POINT}: {e}", Colors.RED)
            sys.exit(1)

def is_mounted():
    """Vérifie si la clé USB est montée"""
    try:
        result = subprocess.run(['mount'], capture_output=True, text=True)
        return USB_DEVICE in result.stdout and MOUNT_POINT in result.stdout
    except Exception as e:
        log(f"ERREUR lors de la vérification du montage: {e}", Colors.RED)
        return False

def mount_usb():
    """Monte la clé USB si nécessaire"""
    if is_mounted():
        log(f"✓ La clé USB est déjà montée sur {MOUNT_POINT}", Colors.GREEN)
        return
    log(f"Montage de {USB_DEVICE} sur {MOUNT_POINT}...", Colors.YELLOW)
    try:
        result = subprocess.run(['mount', USB_DEVICE, MOUNT_POINT], capture_output=True, text=True)
        if result.returncode == 0:
            log(f"✓ Clé USB montée avec succès", Colors.GREEN)
        else:
            log(f"ERREUR lors du montage: {result.stderr}", Colors.RED)
            sys.exit(1)
    except Exception as e:
        log(f"ERREUR: {e}", Colors.RED)
        sys.exit(1)

def verify_usb_structure():
    """Vérifie et crée la structure de la clé USB"""
    log("Vérification de la structure de la clé USB…", Colors.BLUE)
    dirs = {
        'Backup': BACKUP_DIR,
        'Data': f"{MOUNT_POINT}/Data",
        'Config': f"{MOUNT_POINT}/Config",
        'Env': f"{MOUNT_POINT}/Env"
    }
    for name, path in dirs.items():
        if not os.path.exists(path):
            if name == 'Backup':
                os.makedirs(path, exist_ok=True)
                log(f"✓ Dossier {name} créé", Colors.GREEN)
            else:
                source = f"{SOURCE_DIR}/{name}"
                if os.path.exists(source):
                    os.symlink(source, path)
                    log(f"✓ Lien symbolique {name} créé", Colors.GREEN)
                else:
                    log(f"ATTENTION: {source} n'existe pas, lien non créé", Colors.YELLOW)
        else:
            log(f"✓ {name} existe déjà", Colors.GREEN)

def create_backup():
    """Crée une sauvegarde ZIP horodatée"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"Labo_backup_{timestamp}.zip"
    backup_path = f"{BACKUP_DIR}/{backup_name}"

    log(f"Création de la sauvegarde ZIP: {backup_name}", Colors.BLUE)
    if not os.path.exists(SOURCE_DIR):
        log(f"ERREUR: Le dossier source {SOURCE_DIR} n'existe pas", Colors.RED)
        sys.exit(1)

    try:
        shutil.make_archive(
            backup_path.replace('.zip', ''),
            'zip',
            root_dir=os.path.dirname(SOURCE_DIR),
            base_dir=os.path.basename(SOURCE_DIR)
        )
        if os.path.exists(backup_path):
            size_bytes = os.path.getsize(backup_path)
            size_mb = size_bytes / (1024 * 1024)
            size = f"{size_mb:.2f} MB" if size_mb < 1024 else f"{size_mb/1024:.2f} GB"
            log(f"✓ Sauvegarde ZIP créée avec succès: {backup_name}", Colors.GREEN)
            log(f"  Taille: {size}", Colors.GREEN)
            log(f"  Emplacement: {backup_path}", Colors.GREEN)
            return backup_path
        else:
            log("ERREUR: Le fichier ZIP n'a pas été créé", Colors.RED)
            sys.exit(1)
    except Exception as e:
        log(f"ERREUR lors de la création du ZIP: {e}", Colors.RED)
        sys.exit(1)

def cleanup_old_backups():
    """Supprime les anciennes sauvegardes ZIP en conservant les N dernières"""
    log(f"Nettoyage des anciennes sauvegardes (conservation des {KEEP_LAST} dernières)…", Colors.BLUE)
    try:
        backups = [
            (f, os.path.getctime(os.path.join(BACKUP_DIR, f)))
            for f in os.listdir(BACKUP_DIR)
            if f.startswith("Labo_backup_") and f.endswith(".zip")
        ]
        backups.sort(key=lambda x: x[1], reverse=True)
        for backup_name, _ in backups[KEEP_LAST:]:
            os.remove(os.path.join(BACKUP_DIR, backup_name))
            log(f"  Supprimé: {backup_name}", Colors.YELLOW)
        log(f"✓ Nettoyage terminé", Colors.GREEN)
    except Exception as e:
        log(f"ATTENTION: Erreur lors du nettoyage: {e}", Colors.YELLOW)

def main():
    """Fonction principale"""
    log("=== Démarrage du script de sauvegarde HP HomeBox ===", Colors.BLUE)
    check_root()
    check_usb_device()
    check_mount_point()
    mount_usb()
    verify_usb_structure()
    create_backup()
    cleanup_old_backups()
    log("=== Sauvegarde terminée avec succès ===", Colors.GREEN)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log("\nScript interrompu par l’utilisateur", Colors.YELLOW)
        sys.exit(1)
    except Exception as e:
        log(f"ERREUR FATALE: {e}", Colors.RED)
        sys.exit(1)
