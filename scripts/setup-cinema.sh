#!/bin/bash
# Script de configuration complète pour usage cinéma hors-ligne
# Ponyo - Configuration station de visionnage

set -e

echo "╔════════════════════════════════════════════════╗"
echo "║   Configuration Cinéma Hors-Ligne - Ponyo     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction de confirmation
confirm() {
    read -p "$1 (o/N): " response
    case "$response" in
        [oO][uU][iI]|[oO]) return 0 ;;
        *) return 1 ;;
    esac
}

echo "🎬 Ce script va configurer Ponyo pour le visionnage de films"
echo ""

# 1. Identifier les disques
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📀 ÉTAPE 1: Identification des disques"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,ROTA,MODEL
echo ""

echo -e "${YELLOW}⚠️  ATTENTION: Identifier le bon disque pour éviter la perte de données !${NC}"
echo ""
read -p "Entrer le device du disque 750GB (ex: sdb): " DISK_DEVICE

if [ -z "$DISK_DEVICE" ]; then
    echo -e "${RED}❌ Device non fourni. Abandon.${NC}"
    exit 1
fi

DISK_PATH="/dev/${DISK_DEVICE}"
PARTITION="${DISK_PATH}1"

if [ ! -b "$DISK_PATH" ]; then
    echo -e "${RED}❌ Le disque $DISK_PATH n'existe pas !${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  VOUS ALLEZ FORMATER: $DISK_PATH${NC}"
echo -e "${RED}⚠️  TOUTES LES DONNÉES SERONT EFFACÉES !${NC}"
echo ""

if ! confirm "Êtes-vous ABSOLUMENT SÛR de vouloir continuer ?"; then
    echo "Abandon."
    exit 0
fi

# 2. Créer la partition
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 ÉTAPE 2: Création de la partition"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

sudo parted -s "$DISK_PATH" mklabel gpt
sudo parted -s "$DISK_PATH" mkpart primary ext4 0% 100%

echo -e "${GREEN}✓${NC} Partition créée"

# 3. Formater en ext4
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 ÉTAPE 3: Formatage en ext4"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

sudo mkfs.ext4 -L "Films" "$PARTITION" -F

echo -e "${GREEN}✓${NC} Disque formaté en ext4 (label: Films)"

# 4. Créer le point de montage
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 ÉTAPE 4: Configuration du montage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

sudo mkdir -p /mnt/films
sudo mount "$PARTITION" /mnt/films
sudo chown "$USER:$USER" /mnt/films

echo -e "${GREEN}✓${NC} Disque monté sur /mnt/films"

# 5. Montage automatique
DISK_UUID=$(sudo blkid -s UUID -o value "$PARTITION")

if [ -n "$DISK_UUID" ]; then
    if ! grep -q "$DISK_UUID" /etc/fstab; then
        echo "UUID=$DISK_UUID /mnt/films ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab > /dev/null
        echo -e "${GREEN}✓${NC} Montage automatique configuré (fstab)"
    else
        echo -e "${YELLOW}⚠${NC} Entrée fstab déjà présente"
    fi
fi

# 6. Optimisations HDD
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ ÉTAPE 5: Optimisations HDD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Désactiver indexation
sudo chattr +C /mnt/films 2>/dev/null || echo "Note: chattr +C non supporté sur ce filesystem"

# Scheduler BFQ pour HDD
if [ -e "/sys/block/${DISK_DEVICE}/queue/scheduler" ]; then
    echo bfq | sudo tee "/sys/block/${DISK_DEVICE}/queue/scheduler" > /dev/null
    echo -e "${GREEN}✓${NC} I/O Scheduler: BFQ activé"
    
    # Rendre permanent
    echo "ACTION==\"add|change\", KERNEL==\"${DISK_DEVICE}\", ATTR{queue/scheduler}=\"bfq\"" | \
        sudo tee /etc/udev/rules.d/60-scheduler-hdd.rules > /dev/null
    echo -e "${GREEN}✓${NC} Scheduler BFQ persistant (udev)"
fi

# 7. Créer structure de dossiers
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 ÉTAPE 6: Structure de dossiers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p /mnt/films/{Films/{Action,Comedie,Drame,SF,Animation,Thriller},Series,Documentaires,Downloads}

echo -e "${GREEN}✓${NC} Structure créée:"
tree -L 2 /mnt/films 2>/dev/null || ls -R /mnt/films

# 8. Installation logiciels
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 ÉTAPE 7: Installation logiciels (optionnel)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if confirm "Installer MPV (lecteur vidéo optimisé VAAPI) ?"; then
    sudo zypper install -y mpv
    
    # Configuration MPV
    mkdir -p ~/.config/mpv
    cat > ~/.config/mpv/mpv.conf << 'EOF'
# Configuration MPV optimisée pour Ponyo (Radeon HD 6520G)
hwdec=vaapi
vo=gpu
gpu-context=wayland
profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp

# Sous-titres
sub-auto=fuzzy
sub-file-paths=subs:subtitles

# Cache pour HDD
cache=yes
demuxer-max-bytes=150M
demuxer-readahead-secs=20
EOF
    echo -e "${GREEN}✓${NC} MPV installé et configuré"
fi

if confirm "Installer VLC (alternative) ?"; then
    sudo zypper install -y vlc
    echo -e "${GREEN}✓${NC} VLC installé (activer VAAPI dans Préférences)"
fi

if confirm "Installer Transmission (client BitTorrent) ?"; then
    sudo zypper install -y transmission-gtk
    echo -e "${GREEN}✓${NC} Transmission installé"
fi

if confirm "Installer mediainfo (analyser codecs vidéo) ?"; then
    sudo zypper install -y mediainfo
    echo -e "${GREEN}✓${NC} mediainfo installé"
fi

if confirm "Installer libva-utils (tester VAAPI) ?"; then
    sudo zypper install -y libva-utils
    echo -e "${GREEN}✓${NC} libva-utils installé"
fi

# 9. Test VAAPI
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 ÉTAPE 8: Test VAAPI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v vainfo &> /dev/null; then
    echo "Test du décodage matériel H.264..."
    vainfo 2>&1 | grep -E "VAProfile|Driver"
    
    if vainfo 2>&1 | grep -q "VAProfileH264"; then
        echo -e "${GREEN}✓${NC} Décodage H.264 matériel ACTIF !"
    else
        echo -e "${YELLOW}⚠${NC} VAAPI disponible mais H.264 non détecté"
    fi
else
    echo "vainfo non installé (optionnel)"
fi

# 10. Résumé
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║         ✅ CONFIGURATION TERMINÉE !            ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "📊 RÉSUMÉ:"
echo "  • Disque: $DISK_PATH formaté et monté sur /mnt/films"
echo "  • Capacité: 750 GB (ext4)"
echo "  • Montage automatique: ✓"
echo "  • Scheduler: BFQ (optimal HDD)"
echo "  • Structure: Films/Series/Documentaires/Downloads"
echo ""
echo "🎬 FORMATS OPTIMAUX POUR PONYO:"
echo "  ✅ H.264 1080p @ 5-10 Mbps  (décodage GPU)"
echo "  ✅ H.264 720p               (très fluide)"
echo "  ⚠️  H.265/HEVC              (éviter, CPU uniquement)"
echo "  ❌ 4K                        (impossible)"
echo ""
echo "📚 DOCUMENTATION:"
echo "  • Guide complet: docs/CINEMA_OFFLINE.md"
echo "  • Test vidéo: mpv /chemin/vers/film.mp4"
echo "  • Vérifier codec: mediainfo fichier.mp4"
echo ""
echo "🚀 Ponyo est prêt pour le cinéma hors-ligne !"
echo ""
