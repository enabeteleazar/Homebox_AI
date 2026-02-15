# ⚡ Guide de Démarrage Rapide - Homebox_AI

Ce guide vous permet d’installer et de démarrer Homebox_AI en quelques minutes.

## 🚀 Installation Express (Méthode Automatique)

### Pour Ubuntu/Debian

```bash
# 1. Télécharger et exécuter le script d'installation
wget https://raw.githubusercontent.com/enabeteleazar/Homebox_AI/master/install.sh
chmod +x install.sh
sudo ./install.sh
```

C’est tout ! Le script s’occupe de :

- ✅ Installer Docker et Docker Compose
- ✅ Cloner le projet
- ✅ Créer la structure de données
- ✅ Générer des mots de passe sécurisés
- ✅ Démarrer tous les services

-----

## 🛠️ Installation Manuelle (5 minutes)

### Étape 1 : Installer Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Étape 2 : Cloner le Projet

```bash
sudo mkdir -p /opt
cd /opt
sudo git clone https://github.com/enabeteleazar/Homebox_AI.git
sudo chown -R $USER:$USER Homebox_AI
cd Homebox_AI
```

### Étape 3 : Créer les Réseaux

```bash
docker network create Homebox_Network
docker network create Neron_Network
```

### Étape 4 : Configurer les Variables

```bash
cp .env.example .env
nano .env  # Éditez les valeurs
```

Minimum requis à modifier :

```bash
DOCKER_DATA_PATH=/opt/Homebox_AI/Data
NPM_DB_ROOT_PASSWORD=votre_mot_de_passe
NPM_DB_PASSWORD=votre_mot_de_passe
GRAFANA_ADMIN_PASSWORD=votre_mot_de_passe
```

### Étape 5 : Créer la Structure

```bash
mkdir -p Data/{portainer,nginx-proxy-manager,homeassistant,n8n,node-red,Beszel,grafana,prometheus}
mkdir -p Data/nginx-proxy-manager/{mysql,letsencrypt}
mkdir -p Data/grafana/{data,provisioning}
mkdir -p Data/prometheus/{config,data}
sudo chown -R 472:472 Data/grafana/data
```

### Étape 6 : Démarrer

```bash
./start.sh
```

-----

## 🌐 Premier Accès aux Services

Après le démarrage, accédez aux interfaces web :

|Service           |URL                  |Configuration Initiale                       |
|------------------|---------------------|---------------------------------------------|
|**Portainer**     |http://localhost:9000|Créer un compte admin au premier accès       |
|**Nginx Proxy**   |http://localhost:81  |Email: `admin@example.com` / Pass: `changeme`|
|**Home Assistant**|http://localhost:8123|Suivre l’assistant de configuration          |
|**Grafana**       |http://localhost:3001|Login avec les identifiants du .env          |

### ⚠️ Sécurité Première Connexion

**Actions OBLIGATOIRES immédiatement :**

1. **Portainer** : Créez votre compte admin (premier utilisateur = admin)
1. **Nginx Proxy Manager** : Changez le mot de passe (`admin@example.com` / `changeme`)
1. **Grafana** : Changez le mot de passe admin
1. **Home Assistant** : Créez votre compte principal

-----

## 📊 Vérifier que Tout Fonctionne

```bash
# Vérifier le statut des services
./status.sh

# Voir les logs en temps réel
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f grafana
```

**Statut attendu :**

```
🟢 ONLINE  : 9
🔴 OFFLINE : 0
```

-----

## ⚙️ Configuration Post-Installation

### 1. Configurer Telegram (Optionnel mais Recommandé)

Notifications pour mises à jour et backups :

1. Créez un bot Telegram via [@BotFather](https://t.me/BotFather)
1. Récupérez le token
1. Envoyez `/start` à votre bot
1. Visitez : `https://api.telegram.org/bot<VOTRE_TOKEN>/getUpdates`
1. Récupérez votre `chat_id`
1. Mettez à jour `.env` :
   
   ```bash
   TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   TELEGRAM_CHAT_ID=123456789
   ```

### 2. Configurer Prometheus & Grafana

#### Créer le fichier de configuration Prometheus :

```bash
nano Data/prometheus/config/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

#### Dans Grafana :

1. Accédez à http://localhost:3001
1. Allez dans Configuration → Data Sources
1. Ajoutez Prometheus : `http://prometheus:9090`
1. Importez un dashboard (ID: 893 pour Docker)

### 3. Configurer Nginx Proxy Manager pour HTTPS

1. Accédez à http://localhost:81
1. Allez dans “Proxy Hosts” → “Add Proxy Host”
1. Configurez votre domaine :
- **Domain Names** : `subdomain.votredomaine.com`
- **Forward Hostname / IP** : Nom du container (ex: `homeassistant`)
- **Forward Port** : Port du service (ex: `8123`)
1. Onglet “SSL” :
- ☑ Request a new SSL Certificate
- ☑ Force SSL
- ☑ HTTP/2 Support
- Email : votre@email.com

-----

## 🔄 Commandes Quotidiennes

### Gérer les Services

```bash
# Démarrer tout
./start.sh

# Arrêter tout
./stop.sh

# Vérifier le statut
./status.sh

# Redémarrer un service spécifique
docker compose restart grafana
```

### Voir les Logs

```bash
# Tous les services
docker compose logs -f

# Service spécifique
docker compose logs -f homeassistant

# Dernières 100 lignes
docker compose logs --tail=100 n8n
```

### Mettre à Jour

```bash
# Mise à jour manuelle
cd /opt/Homebox_AI
git pull
docker compose pull
docker compose up -d

# Ou avec le script automatique
sudo ./Scripts/update_System.sh
```

-----

## 💾 Backup Rapide

### Backup Manuel

```bash
# Arrêter les services
./stop.sh

# Créer le backup
sudo tar -czf ~/homebox_backup_$(date +%Y%m%d).tar.gz /opt/Homebox_AI

# Redémarrer
./start.sh
```

### Backup Automatique

```bash
# Configurer dans crontab
sudo crontab -e

# Ajouter (backup quotidien à 2h du matin)
0 2 * * * /opt/Homebox_AI/Scripts/Homebox_Backup.sh
```

-----

## 🆘 Dépannage Rapide

### Services ne démarrent pas ?

```bash
# Vérifier les logs
docker compose logs

# Vérifier l'espace disque
df -h

# Recréer les containers
docker compose down
docker compose up -d --force-recreate
```

### Erreur de permissions ?

```bash
# Corriger les permissions
sudo chown -R $USER:$USER /opt/Homebox_AI/Data
sudo chown -R 472:472 /opt/Homebox_AI/Data/grafana/data
```

### Service inaccessible ?

```bash
# Vérifier que le container tourne
docker ps | grep nom_du_service

# Vérifier les ports
docker compose ps

# Redémarrer le service
docker compose restart nom_du_service
```

### Reset complet (dernier recours) ?

```bash
./stop.sh
sudo rm -rf Data/*
# Recréer la structure (voir Étape 5 ci-dessus)
./start.sh
```

-----

## 📱 Prochaines Étapes

Maintenant que Homebox_AI fonctionne, explorez :

1. **Home Assistant** : Ajoutez vos premiers appareils
1. **Node-RED** : Créez votre première automation
1. **n8n** : Connectez vos services (Gmail, Telegram, etc.)
1. **Grafana** : Créez vos dashboards de monitoring
1. **Portainer** : Familiarisez-vous avec la gestion Docker

-----

## 📚 Ressources

- 📖 [Documentation Complète](README.md)
- 🤝 [Guide de Contribution](CONTRIBUTING.md)
- 📝 [Changelog](CHANGELOG.md)
- 🐛 [Signaler un Bug](https://github.com/enabeteleazar/Homebox_AI/issues)

-----

## 💬 Besoin d’Aide ?

- 💡 Consultez les [Issues GitHub](https://github.com/enabeteleazar/Homebox_AI/issues)
- 📖 Lisez le [README complet](README.md)
- 🔍 Cherchez dans les [Discussions](https://github.com/enabeteleazar/Homebox_AI/discussions)

-----

**Félicitations ! Vous êtes prêt à utiliser Homebox_AI ! 🎉**
