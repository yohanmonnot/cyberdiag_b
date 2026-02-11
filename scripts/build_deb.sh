#!/bin/bash
# Script de construction du paquet Debian pour CyberDiag

PKG_ROOT="cyberdiag_pkg"
VERSION="1.0.0"

# 1. Nettoyage
rm -rf $PKG_ROOT
mkdir -p $PKG_ROOT/DEBIAN
mkdir -p $PKG_ROOT/opt/cyberdiag
mkdir -p $PKG_ROOT/usr/bin

# 2. Copie des fichiers
if [ -d "bash-app" ]; then
    cp -r bash-app/* $PKG_ROOT/opt/cyberdiag/
else
    echo "Erreur : Le dossier bash-app n'existe pas."
    exit 1
fi

# 3. Gestion des permissions (Crucial pour le paquet)
echo "Application des permissions dans $PKG_ROOT..."

# Rendre tous les .sh exécutables dans le paquet
find $PKG_ROOT/opt/cyberdiag -type f -name "*.sh" -exec chmod +x {} \;

# Permissions spécifiques pour les binaires et modules
chmod +x $PKG_ROOT/opt/cyberdiag/modules/graphicInterface/runtime/bin/java
chmod +x $PKG_ROOT/opt/cyberdiag/modules/reports/*

# 4. Création du wrapper binaire
cat <<EOF > $PKG_ROOT/usr/bin/cyberdiag
#!/bin/bash
# On se déplace dans le dossier pour que les chemins relatifs du script fonctionnent
cd /opt/cyberdiag && ./main.sh "\$@"
EOF
chmod +x $PKG_ROOT/usr/bin/cyberdiag

# 5. Fichier control
cat <<EOF > $PKG_ROOT/DEBIAN/control
Package: cyberdiag
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: jq, bash
Maintainer: Team Cyclonic Force
Description: Scanner de vulnerabilites et bonnes pratiques cyber.
EOF

# 6. Construction
# Utilisation de --root-owner-group pour garantir que les fichiers
# appartiennent à root lors de l'installation chez l'utilisateur
dpkg-deb --build --root-owner-group $PKG_ROOT "cyberdiag_${VERSION}_amd64.deb"

echo "Succès : Paquet généré : cyberdiag_${VERSION}_amd64.deb"