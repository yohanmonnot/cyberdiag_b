#!/bin/bash

echo "[testArgs] Script appelé."

echo "[testArgs] Nombre d'arguments : $#"

i=1
for arg in "$@"; do
    echo "[testArgs] Arg $i : $arg"
    i=$((i+1))
done

echo "[testArgs] Fin du script."
