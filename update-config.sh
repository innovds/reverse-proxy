#!/bin/bash

# Script simple pour régénérer la configuration Traefik
# Compatible avec Linux, macOS et Windows (via Git Bash/WSL)

echo "Régénération de la configuration Traefik..."
echo ""

# Exécuter le générateur de configuration
docker compose run --rm config-generator

# Vérifier le résultat
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuration régénérée avec succès !"
    echo "📁 Fichier généré : config/traefik.yml"
else
    echo ""
    echo "❌ Erreur lors de la génération de la configuration"
    exit 1
fi

echo ""
echo "🎉 Configuration mise à jour !"
