#!/usr/bin/env python3
"""
init_labo_storage.py

Initialisation de l’arborescence de stockage Homebox.
- Création des dossiers Data, Config, Env dans /mnt/usb-storage
- Création des liens symboliques correspondants dans /opt/Labo

Script idempotent et sécurisé.
"""

import os
import sys
import pwd
import grp
from typing import List

# =========================
# CONFIGURATION
# =========================

USB_BASE_PATH = "/mnt/usb-storage"
LABO_BASE_PATH = "/opt/Labo"

DIRECTORIES: List[str] = [
    "Data",
    "Config",
    "Env",
]

OWNER_USER = "eleazar"
OWNER_GROUP = "eleazar"
DIR_MODE = 0o750


# =========================
# UTILITAIRES
# =========================

def require_root() -> None:
    if os.geteuid() != 0:
        print("[ERREUR] Ce script doit être exécuté avec sudo.")
        sys.exit(1)


def get_uid_gid(user: str, group: str) -> tuple[int, int]:
    uid = pwd.getpwnam(user).pw_uid
    gid = grp.getgrnam(group).gr_gid
    return uid, gid


def set_permissions(path: str) -> None:
    uid, gid = get_uid_gid(OWNER_USER, OWNER_GROUP)
    os.chown(path, uid, gid)
    os.chmod(path, DIR_MODE)


def log_info(message: str) -> None:
    print(f"[INFO] {message}")


def log_error(message: str) -> None:
    print(f"[ERREUR] {message}")


# =========================
# LOGIQUE PRINCIPALE
# =========================

def ensure_usb_directory(dir_name: str) -> str:
    usb_dir = os.path.join(USB_BASE_PATH, dir_name)

    if not os.path.exists(usb_dir):
        log_info(f"Création du dossier USB : {usb_dir}")
        os.makedirs(usb_dir, exist_ok=True)
        set_permissions(usb_dir)
    else:
        log_info(f"Dossier USB déjà existant : {usb_dir}")

    return usb_dir


def ensure_labo_symlink(dir_name: str, target: str) -> None:
    labo_path = os.path.join(LABO_BASE_PATH, dir_name)

    if os.path.exists(labo_path):
        if os.path.islink(labo_path):
            log_info(f"Lien déjà existant : {labo_path}")
            return

        if os.path.isdir(labo_path):
            if os.listdir(labo_path):
                log_error(f"{labo_path} existe et n’est pas vide")
                sys.exit(1)

            log_info(f"Suppression de l’ancien dossier : {labo_path}")
            os.rmdir(labo_path)
        else:
            log_error(f"{labo_path} existe mais n’est pas un dossier valide")
            sys.exit(1)

    log_info(f"Création du lien : {labo_path} -> {target}")
    os.symlink(target, labo_path)


def initialize_storage() -> None:
    log_info("Démarrage de l’initialisation du stockage Homebox")

    for directory in DIRECTORIES:
        usb_dir = ensure_usb_directory(directory)
        ensure_labo_symlink(directory, usb_dir)

    log_info("Initialisation terminée avec succès")


# =========================
# POINT D’ENTRÉE
# =========================

def main() -> None:
    require_root()
    initialize_storage()


if __name__ == "__main__":
    main()
