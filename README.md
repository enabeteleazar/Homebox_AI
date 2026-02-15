# 🏠 Homebox_AI

<div align="center">

![Status](https://img.shields.io/badge/status-active-success.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![Python](https://img.shields.io/badge/python-99.6%25-blue.svg)

**Plateforme d'automatisation domotique intelligente tout-en-un**

Une solution complète et modulaire pour gérer votre infrastructure domestique avec monitoring, automatisation et intelligence artificielle.

[Installation](#-installation) • [Démarrage Rapide](#-démarrage-rapide) • [Services](#-services-inclus) • [Configuration](#%EF%B8%8F-configuration) • [Documentation](#-documentation)

</div>

---

## 📋 Table des Matières

- [À Propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Démarrage Rapide](#-démarrage-rapide)
- [Services Inclus](#-services-inclus)
- [Configuration](#%EF%B8%8F-configuration)
- [Scripts Utilitaires](#-scripts-utilitaires)
- [Sauvegarde](#-sauvegarde)
- [Monitoring](#-monitoring)
- [Sécurité](#-sécurité)
- [Troubleshooting](#-troubleshooting)
- [Contribution](#-contribution)
- [Licence](#-licence)

---

## 🎯 À Propos

**Homebox_AI** est une plateforme d'automatisation domotique complète et containerisée qui intègre :

- 🏠 **Automatisation domotique** avec Home Assistant, Node-RED et n8n
- 📊 **Monitoring avancé** avec Prometheus, Grafana et cAdvisor
- 🔐 **Reverse proxy sécurisé** avec Nginx Proxy Manager
- 🐳 **Gestion de containers** avec Portainer
- 📱 **Notifications Telegram** pour tous les événements système
- 🔄 **Mises à jour automatiques** avec scripts intelligents

L'ensemble du système est orchestré via Docker Compose pour une installation simple et une maintenance facilitée.

---

## ✨ Fonctionnalités

### 🏗️ Core Services
- **Portainer** : Interface web de gestion Docker
- **Nginx Proxy Manager** : Reverse proxy avec gestion SSL automatique
- **Base de données MariaDB** : Stockage pour Nginx Proxy Manager

### 🤖 Automation
- **Home Assistant** : Hub domotique central
- **n8n** : Automatisation de workflows (alternative open-source à Zapier)
- **Node-RED** : Programmation visuelle par flux

### 📈 Monitoring
- **Prometheus** : Collecte de métriques
- **Grafana** : Visualisation de données et dashboards
- **cAdvisor** : Métriques des containers Docker
- **Beszel** : Monitoring système léger

### 🔧 Gestion & Maintenance
- Scripts de démarrage/arrêt automatisés
- Système de backup avec rotation
- Mises à jour automatiques avec notifications
- Nettoyage Docker automatique
- Monitoring de l'état des services

---

## 🏛️ Architecture

```
Homebox_AI/
├── 🐳 docker-compose.yaml         # Configuration principale
├── 📁 Services/
│   ├── Core/                      # Services essentiels
│   │   ├── Portainer/
│   │   └── NginxProxy/
│   ├── Automation/                # Services d'automatisation
│   │   ├── HomeAssistant/
│   │   ├── n8n/
│   │   └── Node-Red/
│   └── Monitoring/                # Services de monitoring
│       ├── Prometheus/
│       ├── Grafana/
│       ├── Cadvisor/
│       └── Beszel/
├── 📜 Scripts/                    # Scripts utilitaires
│   ├── start.sh
│   ├── stop.sh
│   ├── status.sh
│   ├── update_System.sh
│   ├── Homebox_Backup.sh
│   └── docker-cleaner-auto.sh
├── 📊 Data/                       # Données persistantes
├── ⚙️ Config/                     # Configurations
└── 🔐 .env                        # Variables d'environnement (à créer)
```

### Réseau

Tous les services sont connectés via deux réseaux Docker :
- **Homebox_Network** : Réseau principal pour tous les services
- **Neron_Network** : Réseau dédié (optionnel)

---

## 🔧 Prérequis

### Système
- **OS** : Ubuntu 20.04+ / Debian 11+ (recommandé)
- **RAM** : 4 GB minimum, 8 GB recommandé
- **Stockage** : 20 GB minimum (SSD recommandé)
- **CPU** : 2 cores minimum, 4+ recommandé

### Logiciels
- Docker Engine 24.0+
- Docker Compose v2.20+
- Git
- Bash 4.0+
- curl

### Installation Docker (Ubuntu/Debian)
```bash
# Installation Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installation Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Vérification
docker --version
docker compose version
```

---

## 📥 Installation

### 1. Cloner le Repository

```bash
# Cloner dans /opt (recommandé)
sudo mkdir -p /opt
cd /opt
sudo git clone https://github.com/enabeteleazar/Homebox_AI.git
sudo chown -R $USER:$USER Homebox_AI
cd Homebox_AI
```

### 2. Créer les Réseaux Docker

```bash
docker network create Homebox_Network
docker network create Neron_Network  # Optionnel
```

### 3. Configuration des Variables d'Environnement

Créez le fichier `.env` à la racine du projet :

```bash
cp .env.example .env
nano .env
```

**Contenu du fichier `.env` :**

```bash
# === PATHS ===
DOCKER_DATA_PATH=/opt/Homebox_AI/Data

# === USER & GROUP IDs ===
PUID=1000
PGID=1000

# === PORTAINER ===
PORTAINER_HTTP=9000
PORTAINER_HTTPS=9443

# === NGINX PROXY MANAGER ===
NGINX_PROXY_HTTP=80
NGINX_PROXY_HTTPS=443
NGINX_PROXY_ADMIN=81

# Database Nginx Proxy Manager
NPM_DB_ROOT_PASSWORD=your_secure_root_password
NPM_DB_NAME=npm_db
NPM_DB_USER=npm_user
NPM_DB_PASSWORD=your_secure_password

# === HOME ASSISTANT ===
HOMEASSISTANT_HTTP=8123

# === N8N ===
N8N_HTTP=5678
N8N_HOST=0.0.0.0
N8N_WEBHOOK_URL=http://your-domain.com

# === NODE-RED ===
NODE_RED_HTTP=1880

# === MONITORING ===
BESZEL_HTTP=8090
CADVISOR_HTTP=8081
GRAFANA_HTTP=3001
PROMETHEUS_HTTP=9090

# Grafana Admin
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your_secure_password
GRAFANA_ROOT_URL=http://localhost:3001

# === TELEGRAM NOTIFICATIONS ===
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
```

### 4. Créer la Structure de Données

```bash
mkdir -p Data/{portainer,nginx-proxy-manager,homeassistant,n8n,node-red,Beszel,grafana,prometheus}
mkdir -p Data/nginx-proxy-manager/{mysql,letsencrypt}
mkdir -p Data/grafana/{data,provisioning}
mkdir -p Data/prometheus/{config,data}
```

### 5. Configurer les Permissions

```bash
# Permissions Grafana
sudo chown -R 472:472 Data/grafana/data

# Permissions générales
sudo chown -R $USER:$USER Data/
```

---

## 🚀 Démarrage Rapide

### Lancer tous les services

```bash
# Méthode 1 : Script automatique
./start.sh

# Méthode 2 : Docker Compose manuel
docker compose up -d
```

### Vérifier le statut

```bash
./status.sh
```

### Arrêter les services

```bash
./stop.sh
```

---

## 🛠️ Services Inclus

### 🔑 Accès aux Interfaces Web

| Service | Port | URL | Identifiants par défaut |
|---------|------|-----|-------------------------|
| **Portainer** | 9000 | `http://localhost:9000` | Créer au premier accès |
| **Nginx Proxy Manager** | 81 | `http://localhost:81` | `admin@example.com` / `changeme` |
| **Home Assistant** | 8123 | `http://localhost:8123` | Créer au premier accès |
| **n8n** | 5678 | `http://localhost:5678` | Créer au premier accès |
| **Node-RED** | 1880 | `http://localhost:1880` | Aucun (configurer) |
| **Grafana** | 3001 | `http://localhost:3001` | Voir `.env` |
| **Prometheus** | 9090 | `http://localhost:9090` | Aucun |
| **cAdvisor** | 8081 | `http://localhost:8081` | Aucun |
| **Beszel** | 8090 | `http://localhost:8090` | Créer au premier accès |

### 📝 Descriptions Détaillées

#### Portainer
Interface graphique pour gérer tous vos containers, images, volumes et réseaux Docker.

**Fonctionnalités :**
- Gestion visuelle des containers
- Logs en temps réel
- Terminal intégré
- Gestion des stacks Docker Compose

#### Home Assistant
Hub central pour votre domotique, compatible avec des centaines d'appareils et services.

**Intégrations populaires :**
- Lumières (Philips Hue, LIFX, etc.)
- Capteurs (température, mouvement, etc.)
- Caméras et sonnettes
- Assistants vocaux (Google Home, Alexa)
- Automatisations complexes

#### n8n
Outil d'automatisation de workflows avec une interface visuelle intuitive.

**Cas d'usage :**
- Automatiser des tâches entre services
- Créer des webhooks
- Intégrer des APIs externes
- Traiter des données

#### Grafana + Prometheus
Stack de monitoring professionnel pour visualiser toutes vos métriques système.

**Dashboards disponibles :**
- Utilisation CPU/RAM/Disque
- Métriques Docker par container
- Performances réseau
- Alertes configurables

---

## ⚙️ Configuration

### Configuration Prometheus

Créez le fichier `Data/prometheus/config/prometheus.yml` :

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

### Configuration Grafana

Les datasources peuvent être provisionnées via `Data/grafana/provisioning/datasources/datasources.yml` :

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
```

### Nginx Proxy Manager - SSL Automatique

1. Accédez à l'interface web (port 81)
2. Connectez-vous avec les identifiants par défaut
3. Changez immédiatement le mot de passe
4. Ajoutez vos domaines dans "Proxy Hosts"
5. Activez SSL avec Let's Encrypt

---

## 📜 Scripts Utilitaires

### `start.sh` - Démarrage du système
Lance tous les services avec vérification Docker et affichage du statut.

```bash
./start.sh
```

### `stop.sh` - Arrêt propre
Arrête tous les containers de manière propre avec confirmation.

```bash
./stop.sh
```

### `status.sh` - Vérification de l'état
Affiche un tableau détaillé de l'état de tous les services.

```bash
./status.sh
```

**Sortie exemple :**
```
📊 Services détectés : 10
---------------------------------------------------------
CONTAINER                 PORTS                STATUS
---------------------------------------------------------
portainer                0.0.0.0:9000         Up 2 hours
homeassistant            0.0.0.0:8123         Up 2 hours
grafana                  0.0.0.0:3001         Up 2 hours
...
```

### `Scripts/update_System.sh` - Mises à jour automatiques
Met à jour le système Ubuntu et tous les containers Docker avec notifications Telegram.

```bash
sudo ./Scripts/update_System.sh
```

**Fonctionnalités :**
- Mise à jour système (apt)
- Pull des dernières images Docker
- Rebuild des containers
- Notifications Telegram à chaque étape
- Gestion des erreurs

### `Scripts/Homebox_Backup.sh` - Sauvegarde automatique
Sauvegarde complète avec compression et rotation.

```bash
sudo ./Scripts/Homebox_Backup.sh
```

**Configuration :**
- Source : `/opt/Homebox_AI`
- Destination : `/mnt/usb-storage/Backup/Homebox_AI`
- Rétention : 5 backups maximum
- Format : `backup_YYYY-MM-DD_HH-MM-SS.tar.gz`

### `Scripts/docker-cleaner-auto.sh` - Nettoyage Docker
Nettoie les images, containers et volumes inutilisés.

```bash
sudo ./Scripts/docker-cleaner-auto.sh
```

---

## 💾 Sauvegarde

### Sauvegarde Manuelle

```bash
# Arrêter les services
./stop.sh

# Sauvegarder le dossier complet
sudo tar -czf homebox_backup_$(date +%Y%m%d).tar.gz /opt/Homebox_AI

# Redémarrer les services
./start.sh
```

### Sauvegarde Automatique (Cron)

Ajoutez à votre crontab :

```bash
sudo crontab -e
```

```bash
# Backup quotidien à 2h00 du matin
0 2 * * * /opt/Homebox_AI/Scripts/Homebox_Backup.sh

# Mise à jour hebdomadaire le dimanche à 3h00
0 3 * * 0 /opt/Homebox_AI/Scripts/update_System.sh

# Nettoyage Docker mensuel le 1er à 4h00
0 4 1 * * /opt/Homebox_AI/Scripts/docker-cleaner-auto.sh
```

### Restauration

```bash
# Extraire le backup
sudo tar -xzf homebox_backup_YYYYMMDD.tar.gz -C /

# Redémarrer les services
cd /opt/Homebox_AI
./start.sh
```

---

## 📊 Monitoring

### Métriques Disponibles

**Système :**
- CPU, RAM, Disque, Réseau
- Température (si capteurs disponibles)
- Uptime

**Docker :**
- CPU/RAM par container
- I/O disque et réseau
- Nombre de containers actifs
- Utilisation des volumes

**Services :**
- État de santé (healthcheck)
- Logs d'erreurs
- Temps de réponse

### Configuration des Alertes Grafana

1. Accédez à Grafana
2. Créez un dashboard
3. Ajoutez des alertes sur les métriques critiques
4. Configurez les notifications (email, Telegram, Slack)

---

## 🔐 Sécurité

### Bonnes Pratiques

1. **Changez tous les mots de passe par défaut** immédiatement
2. **Utilisez des mots de passe forts** (20+ caractères, aléatoires)
3. **Ne commitez JAMAIS le fichier `.env`** sur Git
4. **Utilisez Nginx Proxy Manager** pour exposer les services en HTTPS
5. **Activez l'authentification** sur tous les services publics
6. **Mettez à jour régulièrement** avec le script d'update
7. **Surveillez les logs** pour détecter les activités suspectes

### Firewall (UFW)

```bash
# Installer UFW
sudo apt install ufw

# Règles de base
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH
sudo ufw allow 22/tcp

# Autoriser HTTP/HTTPS (Nginx)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Autoriser services locaux uniquement
# (accès via reverse proxy recommandé)

# Activer le firewall
sudo ufw enable
```

### SSL/TLS avec Let's Encrypt

Utilisez Nginx Proxy Manager pour générer automatiquement des certificats SSL gratuits :

1. Pointez votre domaine vers votre IP
2. Dans Nginx PM, créez un Proxy Host
3. Activez "Force SSL" et "HTTP/2 Support"
4. Demandez un certificat Let's Encrypt
5. Renouvellement automatique tous les 90 jours

---

## 🐛 Troubleshooting

### Les containers ne démarrent pas

```bash
# Vérifier les logs
docker compose logs -f

# Vérifier un container spécifique
docker logs <container_name>

# Vérifier l'espace disque
df -h

# Vérifier la mémoire
free -h
```

### Problèmes de permissions

```bash
# Réinitialiser les permissions
sudo chown -R $USER:$USER /opt/Homebox_AI/Data
sudo chown -R 472:472 /opt/Homebox_AI/Data/grafana/data
```

### Grafana ne démarre pas

```bash
# Corriger les permissions
sudo chown -R 472:472 /opt/Homebox_AI/Data/grafana/data

# Redémarrer
docker compose restart grafana
```

### Problème de réseau Docker

```bash
# Recréer les réseaux
docker network rm Homebox_Network
docker network create Homebox_Network

# Redémarrer Docker
sudo systemctl restart docker
```

### Base de données Nginx corrompue

```bash
# Sauvegarder les données existantes
sudo cp -r Data/nginx-proxy-manager/mysql Data/nginx-proxy-manager/mysql.backup

# Supprimer et recréer
docker compose down
sudo rm -rf Data/nginx-proxy-manager/mysql
docker compose up -d
```

### Reset complet (dernier recours)

```bash
# ATTENTION : Ceci supprime TOUTES les données
./stop.sh
sudo rm -rf Data/*
mkdir -p Data/{portainer,nginx-proxy-manager,homeassistant,n8n,node-red,Beszel,grafana,prometheus}
./start.sh
```

---

## 📚 Documentation

### Liens Officiels

- [Home Assistant](https://www.home-assistant.io/docs/)
- [Portainer](https://docs.portainer.io/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/guide/)
- [n8n](https://docs.n8n.io/)
- [Node-RED](https://nodered.org/docs/)
- [Grafana](https://grafana.com/docs/)
- [Prometheus](https://prometheus.io/docs/)

### Tutoriels Recommandés

- Configuration Home Assistant pour débutants
- Créer des automatisations avec n8n
- Dashboards Grafana personnalisés
- Sécuriser son reverse proxy

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment participer :

1. Fork le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Guidelines

- Respectez le style de code existant
- Ajoutez des tests si applicable
- Mettez à jour la documentation
- Décrivez clairement vos changements dans la PR

---

## 🗺️ Roadmap

- [ ] Interface web centralisée de gestion
- [ ] Support multi-architecture (ARM64 pour Raspberry Pi)
- [ ] Intégration d'IA avec Ollama/LLM
- [ ] Dashboard mobile dédié
- [ ] Système de plugins personnalisés
- [ ] Migration vers Kubernetes (optionnelle)
- [ ] Intégration MQTT pour IoT
- [ ] Système d'alertes avancé multi-canal

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👤 Auteur

**enabeteleazar**

- GitHub: [@enabeteleazar](https://github.com/enabeteleazar)
- Projet: [Homebox_AI](https://github.com/enabeteleazar/Homebox_AI)

---

## 🙏 Remerciements

- La communauté Home Assistant
- Les développeurs de tous les services open-source utilisés
- Tous les contributeurs du projet

---

## ⭐ Support

Si ce projet vous est utile, n'hésitez pas à :
- ⭐ Mettre une étoile sur GitHub
- 🐛 Signaler les bugs via les Issues
- 💡 Proposer de nouvelles fonctionnalités
- 📖 Améliorer la documentation

---

<div align="center">

**Fait avec ❤️ pour la communauté domotique**

[⬆ Retour en haut](#-homebox_ai)

</div>
