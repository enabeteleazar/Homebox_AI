#!/usr/bin/env python3
import os
import subprocess
import sys
import shutil
import platform

def run(cmd, check=True):
    print(f"\n>>> {cmd}")
    subprocess.run(cmd, shell=True, check=check)

def require_root():
    if os.geteuid() != 0:
        print("ERREUR: Ce script doit être exécuté en root (sudo).")
        sys.exit(1)

def check_os():
    if not os.path.exists("/etc/debian_version"):
        print("ERREUR: OS non supporté. Debian/Ubuntu requis.")
        sys.exit(1)

def command_exists(cmd):
    return shutil.which(cmd) is not None

def install_prerequisites():
    run("apt-get update")
    run("apt-get install -y ca-certificates curl gnupg lsb-release")

def install_docker_repo():
    if not os.path.exists("/etc/apt/keyrings"):
        os.makedirs("/etc/apt/keyrings", exist_ok=True)

    if not os.path.exists("/etc/apt/keyrings/docker.gpg"):
        run(
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | "
            "gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
        )
        run("chmod a+r /etc/apt/keyrings/docker.gpg")

    distro = subprocess.check_output("lsb_release -cs", shell=True).decode().strip()

    repo_line = (
        f"deb [arch=$(dpkg --print-architecture) "
        f"signed-by=/etc/apt/keyrings/docker.gpg] "
        f"https://download.docker.com/linux/ubuntu {distro} stable"
    )

    repo_file = "/etc/apt/sources.list.d/docker.list"
    if not os.path.exists(repo_file):
        with open(repo_file, "w") as f:
            f.write(repo_line + "\n")

def install_docker_engine():
    run("apt-get update")
    run(
        "apt-get install -y "
        "docker-ce docker-ce-cli containerd.io "
        "docker-buildx-plugin docker-compose-plugin"
    )

def enable_docker():
    run("systemctl enable docker")
    run("systemctl start docker")

def add_user_to_docker_group():
    user = os.environ.get("SUDO_USER")
    if user:
        run(f"usermod -aG docker {user}")
        print(f"Utilisateur '{user}' ajouté au groupe docker.")
        print("Déconnexion/reconnexion nécessaire pour prise d'effet.")

def verify_installation():
    run("docker --version", check=False)
    run("docker compose version", check=False)

def main():
    require_root()
    check_os()

    print("=== Installation Docker & Docker Compose ===")

    if command_exists("docker"):
        print("Docker est déjà installé. Vérification de Compose...")
    else:
        install_prerequisites()
        install_docker_repo()
        install_docker_engine()
        enable_docker()
        add_user_to_docker_group()

    verify_installation()

    print("\nInstallation terminée avec succès.")

if __name__ == "__main__":
    main()
