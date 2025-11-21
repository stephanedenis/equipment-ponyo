#!/bin/bash
# Installation rapide complète - Ponyo
# One-liner pour configuration complète automatique

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Installation Complète - Ponyo (AMD A6)║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Détection distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}❌ Distribution non détectée${NC}"
    exit 1
fi

echo -e "${GREEN}Distribution détectée: $PRETTY_NAME${NC}"
echo ""

# === 1. Mise à jour système ===
echo -e "${BLUE}📦 1/8 Mise à jour système...${NC}"
case $DISTRO in
    opensuse*|suse)
        sudo zypper ref && sudo zypper -n dup
        ;;
    ubuntu|debian)
        sudo apt update && sudo apt upgrade -y
        ;;
    fedora)
        sudo dnf upgrade -y
        ;;
    arch|manjaro)
        sudo pacman -Syu --noconfirm
        ;;
esac
echo -e "${GREEN}✅ Système à jour${NC}"
echo ""

# === 2. Installation paquets essentiels ===
echo -e "${BLUE}🔧 2/8 Installation paquets essentiels...${NC}"
case $DISTRO in
    opensuse*|suse)
        sudo zypper -n install \
            Mesa-dri libva-mesa-driver mesa-vulkan-drivers \
            libva2 libva-utils \
            htop git curl wget vim \
            lm_sensors \
            tlp tlp-rdw \
            zstd pigz
        ;;
    ubuntu|debian)
        sudo apt install -y \
            mesa-va-drivers mesa-vulkan-drivers \
            libva2 vainfo \
            htop git curl wget vim \
            lm-sensors \
            tlp tlp-rdw \
            zstd pigz
        ;;
    fedora)
        sudo dnf install -y \
            mesa-dri-drivers mesa-va-drivers mesa-vulkan-drivers \
            libva libva-utils \
            htop git curl wget vim \
            lm_sensors \
            tlp tlp-rdw \
            zstd pigz
        ;;
esac
echo -e "${GREEN}✅ Paquets installés${NC}"
echo ""

# === 3. Configuration TLP ===
echo -e "${BLUE}🔋 3/8 Configuration TLP (batterie)...${NC}"
if [ -e /sys/class/power_supply/BAT0 ]; then
    sudo systemctl enable tlp
    sudo systemctl start tlp
    echo -e "${GREEN}✅ TLP activé${NC}"
else
    echo -e "${YELLOW}⚠️  Pas de batterie (desktop)${NC}"
fi
echo ""

# === 4. Configuration GPU AMD ===
echo -e "${BLUE}🎮 4/8 Configuration GPU AMD...${NC}"
cp "$PROJECT_ROOT/config/env-template" ~/.config/ponyo.env

if ! grep -q "ponyo.env" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Ponyo AMD optimizations" >> ~/.bashrc
    echo "[ -f ~/.config/ponyo.env ] && source ~/.config/ponyo.env" >> ~/.bashrc
fi

echo -e "${GREEN}✅ Variables GPU configurées${NC}"
echo ""

# === 5. Configuration sysctl ===
echo -e "${BLUE}⚙️  5/8 Optimisations kernel...${NC}"
sudo cp "$PROJECT_ROOT/config/sysctl-ponyo.conf" /etc/sysctl.d/99-ponyo.conf
sudo sysctl --system > /dev/null 2>&1
echo -e "${GREEN}✅ sysctl configuré${NC}"
echo ""

# === 6. ZRAM (si nécessaire) ===
echo -e "${BLUE}💾 6/8 Configuration ZRAM...${NC}"
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')

if [ "$RAM_GB" -le 4 ]; then
    case $DISTRO in
        opensuse*|suse)
            if ! rpm -q systemd-zram-service &>/dev/null; then
                sudo zypper -n install systemd-zram-service
                sudo systemctl enable --now zram
                echo -e "${GREEN}✅ ZRAM installé et activé${NC}"
            else
                echo -e "${GREEN}✅ ZRAM déjà installé${NC}"
            fi
            ;;
        ubuntu|debian)
            if ! dpkg -l | grep -q zram-config; then
                sudo apt install -y zram-config
                echo -e "${GREEN}✅ ZRAM installé${NC}"
            else
                echo -e "${GREEN}✅ ZRAM déjà installé${NC}"
            fi
            ;;
        fedora)
            if ! rpm -q zram-generator-defaults &>/dev/null; then
                sudo dnf install -y zram-generator-defaults
                echo -e "${GREEN}✅ ZRAM installé${NC}"
            else
                echo -e "${GREEN}✅ ZRAM déjà installé${NC}"
            fi
            ;;
    esac
else
    echo -e "${YELLOW}⚠️  RAM >4GB: ZRAM optionnel${NC}"
fi
echo ""

# === 7. Audit matériel ===
echo -e "${BLUE}🔍 7/8 Audit matériel...${NC}"
bash "$PROJECT_ROOT/scripts/audit-hardware.sh" > /dev/null
echo -e "${GREEN}✅ Audit sauvegardé dans hardware/${NC}"
echo ""

# === 8. Optimisations système ===
echo -e "${BLUE}⚡ 8/8 Application optimisations...${NC}"
sudo bash "$PROJECT_ROOT/scripts/optimize-system.sh"
echo ""

# === Configuration sensors ===
if ! sensors &>/dev/null; then
    echo -e "${YELLOW}Configuration lm-sensors...${NC}"
    sudo sensors-detect --auto
fi

# === Résumé ===
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        ✅ INSTALLATION TERMINÉE        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Système mis à jour${NC}"
echo -e "${GREEN}✅ Drivers AMD installés${NC}"
echo -e "${GREEN}✅ VAAPI configuré${NC}"
echo -e "${GREEN}✅ Optimisations appliquées${NC}"
echo -e "${GREEN}✅ TLP activé (si laptop)${NC}"
[ "$RAM_GB" -le 4 ] && echo -e "${GREEN}✅ ZRAM activé${NC}"
echo ""
echo -e "${YELLOW}⚠️  REDÉMARRAGE RECOMMANDÉ${NC}"
echo ""
echo "Prochaines étapes:"
echo "  1. Redémarrer: sudo reboot"
echo "  2. Tester VAAPI: vainfo"
echo "  3. Configurer Firefox: voir config/firefox-prefs.js"
echo "  4. Benchmark: bash scripts/benchmark.sh"
echo ""
echo "Monitoring: bash scripts/monitor.sh"
echo "Maintenance: sudo bash scripts/maintenance.sh"
echo ""
