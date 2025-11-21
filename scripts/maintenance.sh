#!/bin/bash
# Script de maintenance automatique - Ponyo
# Nettoie le système et optimise les performances

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Maintenance Système - Ponyo        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Ce script nécessite sudo${NC}"
    echo "   Relancer avec: sudo $0"
    exit 1
fi

# === 1. Nettoyage cache paquets ===
echo -e "${BLUE}🧹 Nettoyage cache paquets...${NC}"
if command -v zypper &> /dev/null; then
    zypper clean --all
    echo -e "${GREEN}✅ Cache zypper nettoyé${NC}"
elif command -v apt &> /dev/null; then
    apt clean
    apt autoclean
    apt autoremove -y
    echo -e "${GREEN}✅ Cache apt nettoyé${NC}"
elif command -v dnf &> /dev/null; then
    dnf clean all
    dnf autoremove -y
    echo -e "${GREEN}✅ Cache dnf nettoyé${NC}"
fi
echo ""

# === 2. Journaux ===
echo -e "${BLUE}📝 Nettoyage journaux système...${NC}"
journalctl --vacuum-time=7d
journalctl --vacuum-size=100M
echo -e "${GREEN}✅ Journaux nettoyés (>7 jours)${NC}"
echo ""

# === 3. Fichiers temporaires ===
echo -e "${BLUE}🗑️  Nettoyage fichiers temporaires...${NC}"
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true
echo -e "${GREEN}✅ /tmp et /var/tmp nettoyés${NC}"
echo ""

# === 4. Cache thumbnails ===
echo -e "${BLUE}🖼️  Nettoyage cache thumbnails...${NC}"
find /home -type d -name ".cache/thumbnails" -exec rm -rf {}/\* \; 2>/dev/null || true
echo -e "${GREEN}✅ Thumbnails nettoyés${NC}"
echo ""

# === 5. TRIM si SSD ===
IS_SSD=0
for disk in /sys/block/sd? /sys/block/nvme?n?; do
    if [ -e "$disk/queue/rotational" ]; then
        ROTA=$(cat "$disk/queue/rotational")
        [ "$ROTA" -eq 0 ] && IS_SSD=1
    fi
done

if [ "$IS_SSD" -eq 1 ]; then
    echo -e "${BLUE}✂️  Exécution TRIM (SSD)...${NC}"
    fstrim -av
    echo -e "${GREEN}✅ TRIM exécuté${NC}"
    echo ""
fi

# === 6. Vérification santé disque ===
echo -e "${BLUE}💿 État disque...${NC}"
df -h / | awk 'NR==2{printf "   Utilisé: %s / %s (%s)\n", $3, $2, $5}'
echo ""

# === 7. Mise à jour base de données locate ===
if command -v updatedb &> /dev/null; then
    echo -e "${BLUE}🔍 Mise à jour base locate...${NC}"
    updatedb
    echo -e "${GREEN}✅ Base locate mise à jour${NC}"
    echo ""
fi

# === 8. Optimisation base de données paquets ===
echo -e "${BLUE}📦 Optimisation base de données...${NC}"
if command -v zypper &> /dev/null; then
    zypper refresh
elif command -v apt &> /dev/null; then
    apt update
elif command -v dnf &> /dev/null; then
    dnf makecache
fi
echo -e "${GREEN}✅ Base de données actualisée${NC}"
echo ""

# === Résumé ===
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            ✅ TERMINÉ                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Maintenance effectuée avec succès !"
echo ""
echo "Espace libéré:"
df -h / | awk 'NR==2{print "  Racine: "$4" disponible"}'
echo ""
