#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$DIR/diag.json" ]; then
    echo "Erreur : Le fichier '$DIR/diag.json' n'existe pas."
    exit 1
fi

jq -c . "$DIR/diag.json"