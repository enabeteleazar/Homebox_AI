#!/usr/bin/env python3
"""
Script de création de l'arborescence complète Néron
Crée tous les dossiers évoqués et ajoute un README.md avec la description du rôle
"""

import os

# Chemin racine où créer Néron
base_path = "/opt/Labo/Neron"

# Définition des modules et description
modules = {
    "Neron-Core": "Cerveau de Néron : décision, orchestration et planification des tâches.",
    "Neron-LLM": "Personnalité de Néron : traitement du langage et dialogue.",
    "Neron-Memory": "Mémoire persistante : stockage des connaissances et contextes.",
    "Neron-IO": "Interface pour l'extérieur : commandes, capteurs et actions système.",
    "Neron-Forge": "Développement et exécution technique des outils, contient Claude Code et Claude Engineer.",
    "Neron-Security": "Audit de sécurité, contrôle des actions critiques, sandboxing.",
    "Neron-Agent": "Gestion de processus autonomes et agents secondaires.",
    "Neron-Scheduler": "Gestion des tâches planifiées ou récurrentes.",
    "Neron-Analytics": "Logging avancé, métriques de performance et alertes.",
    "Neron-Integrations": "Connecteurs vers services externes comme Home Assistant, Docker et APIs."
}

def create_structure(base, modules_dict):
    # Crée le dossier racine si inexistant
    os.makedirs(base, exist_ok=True)
    print(f"[INFO] Dossier racine créé : {base}")

    for module, description in modules_dict.items():
        module_path = os.path.join(base, module)
        os.makedirs(module_path, exist_ok=True)
        print(f"[INFO] Module créé : {module_path}")

        # Création du README
        readme_path = os.path.join(module_path, "README.md")
        with open(readme_path, "w") as f:
            f.write(f"# {module}\n\n{description}\n")
        print(f"[INFO] README ajouté pour {module}")

if __name__ == "__main__":
    create_structure(base_path, modules)
    print("\n[INFO] Arborescence complète Néron créée avec succès !")
