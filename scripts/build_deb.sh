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
cp -r bash-app/* $PKG_ROOT/opt/cyberdiag/

# 3. Création du wrapper binaire
cat <<EOF > $PKG_ROOT/usr/bin/cyberdiag
#!/bin/bash
cd /opt/cyberdiag && ./main.sh "\$@"
EOF
chmod +x $PKG_ROOT/usr/bin/cyberdiag

# 4. Fichier control
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

# 5. Construction
dpkg-deb --build $PKG_ROOT "cyberdiag_${VERSION}_amd64.deb"
echo "Paquet généré : cyberdiag_${VERSION}_amd64.deb"