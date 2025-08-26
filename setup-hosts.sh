#!/bin/bash

# Script universel pour configurer les hosts - Compatible tous OS
# Usage: ./setup-hosts.sh

echo "🌍 Configuration des hosts pour développement microservices"
echo "📋 Compatible: Windows, Linux, macOS"

# Détection de l'OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    MSYS*)      MACHINE=Windows;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

echo "🖥️  OS détecté: $MACHINE"

# Configuration du fichier hosts selon l'OS
case $MACHINE in
    "Linux"|"Mac")
        HOSTS_FILE="/etc/hosts"
        BACKUP_FILE="/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
        SUDO_CMD="sudo"
        ;;
    "Windows"|"Cygwin"|"MinGw")
        HOSTS_FILE="/c/Windows/System32/drivers/etc/hosts"
        BACKUP_FILE="/c/Windows/System32/drivers/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
        SUDO_CMD=""
        echo "⚠️  Sur Windows, lancez ce script en tant qu'Administrateur"
        ;;
    *)
        echo "❌ OS non supporté: $MACHINE"
        exit 1
        ;;
esac

echo "📁 Fichier hosts: $HOSTS_FILE"

# Backup du fichier hosts
echo "💾 Sauvegarde du fichier hosts..."
$SUDO_CMD cp "$HOSTS_FILE" "$BACKUP_FILE"

# Vérifier si les entrées existent déjà
if grep -q "api.local" "$HOSTS_FILE" 2>/dev/null; then
    echo "⚠️  Les entrées existent déjà dans le fichier hosts"
    echo "🔄 Voulez-vous les remplacer? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Annulé par l'utilisateur"
        exit 0
    fi
    
    # Supprimer les anciennes entrées
    echo "🧹 Suppression des anciennes entrées..."
    $SUDO_CMD sed -i.bak '/# === PROXY IDS ===/,/# === Fin PROXY IDS ===/d' "$HOSTS_FILE"
fi

# Ajouter les nouvelles entrées
echo "➕ Ajout des nouvelles entrées..."
cat << 'EOF' | $SUDO_CMD tee -a "$HOSTS_FILE" > /dev/null

# === PROXY IDS ===
127.0.0.1    api.local
# === Fin PROXY IDS ===
EOF

echo "✅ Configuration terminée avec succès!"
echo ""
echo "🌐 Vos microservices seront accessibles via :"
echo "   - http://api.local/billing/     (via proxy)"
echo ""
echo "🚀 Prochaines étapes :"
echo "   1. Lancez le proxy : ./nginx-start.sh"
echo "   2. Démarrez vos services sur les ports habituels"
echo ""
echo "🔄 Pour restaurer le fichier hosts original :"
echo "   $SUDO_CMD cp \"$BACKUP_FILE\" \"$HOSTS_FILE\""
echo ""
