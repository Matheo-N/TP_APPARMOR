#!/bin/bash

# Définir le répertoire des logs
OUTPUT_DIR="/home/user/scripts/debscan/logs"

# Créer le répertoire des logs s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Obtenir la date actuelle pour nommer le fichier log
CURRENT_DATE=$(date +%Y-%m-%d)

# Définir le fichier log pour cette exécution
OUTPUT_FILE="$OUTPUT_DIR/debsecan_$CURRENT_DATE.log"

# debsecan pour rechercher les vulnérabilités
# Nous allons utiliser debsecan avec la suite "bookworm" et uniquement les problèmes corrigés.
debsecan --suite bookworm --only-fixed > "$OUTPUT_FILE"

# Supprimer les logs plus vieux que 7 jours
find "$OUTPUT_DIR" -type f -name "debsecan_*.log" -mtime +7 -exec rm -f {} \;

echo "Le rapport debsecan a été sauvegardé dans : $OUTPUT_FILE"
