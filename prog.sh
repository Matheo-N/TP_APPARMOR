#!/bin/bash

# Vérification des permissions
# Le script doit être exécuté avec les privilèges root pour ajouter une tâche cron.
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# chemin complet du script rech.sh
CRON_JOB="30 2 * * * /home/user/scripts/debscan/rech.sh"

# Vérifier si la tâche cron existe déjà
if sudo crontab -l 2>/dev/null | grep -q -F "$CRON_JOB"; then
    echo "La tâche cron existe déjà."
else
    # Ajouter la tâche cron
    (sudo crontab -l 2>/dev/null; echo "$CRON_JOB") | sudo crontab -
    echo "Tâche programmée pour exécuter rech.sh tous les jours à 2h30."
fi
