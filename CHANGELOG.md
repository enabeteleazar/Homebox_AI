# 📝 Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased](https://github.com/enabeteleazar/Homebox_AI/compare/v1.0.0...HEAD)

### À venir

- Interface web centralisée de gestion
- Support multi-architecture (ARM64 pour Raspberry Pi)
- Intégration d’IA avec Ollama/LLM
- Dashboard mobile dédié
- Système de plugins personnalisés

-----

## [1.3.2](https://github.com/enabeteleazar/Homebox_AI/releases/tag/v1.0.0) - 2026-02-15

### 🎉 Version Initiale

#### Ajouté

- **Core Services**
  - Portainer pour la gestion Docker
  - Nginx Proxy Manager avec SSL automatique
  - Base de données MariaDB pour NPM
- **Automation Services**
  - Home Assistant pour la domotique
  - n8n pour l’automatisation de workflows
  - Node-RED pour la programmation par flux
- **Monitoring Services**
  - Prometheus pour la collecte de métriques
  - Grafana pour la visualisation
  - cAdvisor pour les métriques containers
  - Beszel pour le monitoring léger
- **Scripts Utilitaires**
  - `start.sh` : Démarrage automatique du système
  - `stop.sh` : Arrêt propre des services
  - `status.sh` : Vérification de l’état des services
  - `update_System.sh` : Mise à jour automatique avec notifications Telegram
  - `Homebox_Backup.sh` : Système de backup avec rotation
  - `docker-cleaner-auto.sh` : Nettoyage automatique Docker
- **Documentation**
  - README complet avec guide d’installation
  - Fichier .env.example pour la configuration
  - Guide de contribution (CONTRIBUTING.md)
  - Licence MIT
- **Fonctionnalités**
  - Notifications Telegram pour tous les événements système
  - Système de backup automatique avec rotation (5 backups max)
  - Mises à jour automatiques avec gestion d’erreurs
  - Architecture réseau Docker sécurisée
  - Gestion des permissions automatique (Grafana)

#### Configuration

- Support de 13 variables de ports configurables
- Variables d’environnement pour toutes les configurations
- Chemins de données persistantes configurables
- Support des UID/GID personnalisés

#### Sécurité

- Option `no-new-privileges:true` sur tous les containers
- Isolation réseau via réseaux Docker dédiés
- Variables d’environnement pour les secrets
- Fichier .env exclu du versioning

-----

## Types de Changements

- `Ajouté` : Nouvelles fonctionnalités
- `Modifié` : Changements dans les fonctionnalités existantes
- `Déprécié` : Fonctionnalités qui seront supprimées
- `Supprimé` : Fonctionnalités supprimées
- `Corrigé` : Corrections de bugs
- `Sécurité` : Corrections de vulnérabilités

-----

## [Guide de Versioning]

Ce projet utilise le Semantic Versioning :

- **MAJOR** (X.0.0) : Changements incompatibles avec les versions précédentes
- **MINOR** (0.X.0) : Ajout de fonctionnalités rétro-compatibles
- **PATCH** (0.0.X) : Corrections de bugs rétro-compatibles

### Exemples

- `1.0.0` → `1.0.1` : Correction de bug mineur
- `1.0.0` → `1.1.0` : Ajout d’un nouveau service
- `1.0.0` → `2.0.0` : Restructuration majeure incompatible

-----

## Template pour Nouvelles Versions

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Ajouté
- Nouvelle fonctionnalité A
- Nouveau service B

### Modifié
- Amélioration de C
- Optimisation de D

### Corrigé
- Bug dans E
- Problème avec F

### Sécurité
- Correction de vulnérabilité G
```

-----
