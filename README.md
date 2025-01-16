# TP_APPARMOR
# nouvemat 16/01/25 13:58
# Documentation des scripts `prog.sh` et `rech.sh`

## Introduction

Dans ce TP, j'ai fait deux scripts principaux qui fonctionnent ensemble pour automatiser la collecte des informations sur les vulnérabilités de sécurité d'un système Debian. Le premier script, **`prog.sh`**, permet d'ajouter une tâche cron qui exécute régulièrement le deuxième script, **`rech.sh`**. Ce dernier génère un rapport des vulnérabilités corrigées à l'aide de l'outil **`debsecan`** et nettoie les fichiers de logs plus anciens que 7 jours.

### Objectifs
- **`prog.sh`** : Ajouter une tâche cron pour exécuter **`rech.sh`** tous les jours à 2h30.
- **`rech.sh`** : Utiliser `debsecan` pour générer un rapport de vulnérabilités, le sauvegarder dans un fichier avec la date actuelle, et supprimer les anciens logs.

---

## Script 1 : `prog.sh`

Le script **`prog.sh`** est utilisé pour ajouter une tâche cron qui exécutera **`rech.sh`** tous les jours à 2h30. Comment fonctionne t'il ?

### 1. Vérification des permissions

La première chose que fait le script est de vérifier si l'utilisateur qui exécute le script a les privilèges root. Si ce n'est pas le cas, il arrête l'exécution du script et affiche un message d'erreur.

```bash
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi
```

Cela est obligatoire car une tâche cron nécessite des privilèges admin

### 2. Définition de la tâche cron

Ensuite, le script définit la tâche cron qui doit être exécutée. La tâche cron ajoute **`rech.sh`** dans le fichier de configuration de cron : 

```bash
CRON_JOB="30 2 * * * /home/user/scripts/debscan/rech.sh"
```

Cette ligne indique que **`rech.sh`** doit être exécuté tous les jours à 2h30.

### 3. Vérification de l'existence de la tâche cron

Avant d'ajouter la tâche cron, le script vérifie si la tâche existe déjà. Si la tâche est déjà présente dans le crontab, il affiche un message indiquant que la tâche existe déjà. Sinon, il ajoute la tâche cron au fichier de crontab.

```bash
if sudo crontab -l 2>/dev/null | grep -q -F "$CRON_JOB"; then
    echo "La tâche cron existe déjà."
else
    (sudo crontab -l 2>/dev/null; echo "$CRON_JOB") | sudo crontab -
    echo "Tâche programmée pour exécuter rech.sh tous les jours à 2h30."
fi
```

Cela permet de ne pas ajouter plusieurs fois la même tâche cron.

---

## Script 2 : `rech.sh`

Le script **`rech.sh`** est responsable de la recherche des vulnérabilités corrigées et gestion fichiers logs.

### 1. Création du répertoire des logs

Pour commencer, le script créer le répertoire défini dans OUTPUT_DIR :

```bash
OUTPUT_DIR="/home/user/scripts/debscan/logs"
mkdir -p "$OUTPUT_DIR"
```

On est donc sure que le dossier est prêt à recevoir les fichiers de logs.

### 2. Définition du fichier log

Ensuite, le script obtient la date actuelle (au format `YYYY-MM-DD`) pour l'utiliser dans le nom du fichier log. Cela permet d'avoir un fichier de log unique pour chaque exécution de mon script.

```bash
CURRENT_DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$OUTPUT_DIR/debsecan_$CURRENT_DATE.log"
```

Cela génère un fichier de log avec la date du jour.

### 3. Exécution de `debsecan`

Le script utilise ensuite l'outil **`debsecan`** pour scanner les vulnérabilités des paquets Debian et générer un rapport. Le rapport est ensuite redirigé vers le fichier de log :

```bash
debsecan --suite bookworm --only-fixed > "$OUTPUT_FILE"
```

Le paramètre `--suite bookworm` permet de spécifier la version de la distribution Debian (ici, **bookworm**), et `--only-fixed` filtre les résultats pour n'afficher que les vulnérabilités corrigées.

### 4. Suppression des logs plus vieux que 7 jours

Pour éviter que le répertoire des logs ne devienne trop volumineux, le script supprime les fichiers de logs qui ont plus de 7 jours :

```bash
find "$OUTPUT_DIR" -type f -name "debsecan_*.log" -mtime +7 -exec rm -f {} \;
```

Cela garantit que seuls les logs récents sont conservés, et les anciens sont directement supprimés.

### 5. Message de confirmation

Enfin, le script affiche un message confirmant où le rapport a été sauvegardé.

```bash
echo "Le rapport debsecan a été sauvegardé dans : $OUTPUT_FILE"
```

---

## Conclusion

Ce TP permet d'automatiser la gestion des rapports de vulnérabilités sur un système Debian. Le script **`prog.sh`** ajoute une tâche cron pour exécuter **`rech.sh`** à intervalles réguliers, et **`rech.sh`** génère un rapport sur les vulnérabilités corrigées, tout en gérant les fichiers de logs pour éviter leur accumulation.

En résumé, ce système permet de :
1. Programmer un scan automatique des vulnérabilités avec `debsecan`.
2. Sauvegarder les résultats dans des fichiers de logs organisés.
3. Nettoyer automatiquement les anciens logs pour éviter d'encombrer votre système.

---

## Problèmes rencontrés et solutions

- **Problème d'ajout de tâche cron** : j'ai ajouté une vérification pour éviter de redéfinir la même tâche cron plusieurs fois.
- **Gestion des logs** : Le nettoyage des logs plus vieux que 7 jours permet de maintenir le répertoire de logs propre et d'éviter qu'il ne devienne trop volumineux.
