#!/bin/bash
# Script d'optimisation automatique - Ponyo (AMD A6)
# Applique les optimisations recommandées selon configuration détectée

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Vérification root pour certaines opérations
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  Certaines optimisations nécessitent sudo${NC}"
    echo "   Relancer avec: sudo $0"
    echo ""
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Optimisation Système - Ponyo (AMD A6) ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# === Détection configuration ===
echo -e "${BLUE}🔍 Détection configuration...${NC}"
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
IS_SSD=0
for disk in /sys/block/sd? /sys/block/nvme?n?; do
    if [ -e "$disk/queue/rotational" ]; then
        ROTA=$(cat "$disk/queue/rotational")
        [ "$ROTA" -eq 0 ] && IS_SSD=1
    fi
done

echo "   RAM détectée: ${RAM_GB}GB"
[ "$IS_SSD" -eq 1 ] && echo "   Stockage: SSD" || echo "   Stockage: HDD"
echo ""

# === 1. Swappiness ===
echo -e "${BLUE}📝 1. Configuration Swappiness${NC}"
if [ "$RAM_GB" -le 4 ]; then
    RECOMMENDED_SWAP=35
elif [ "$RAM_GB" -le 6 ]; then
    RECOMMENDED_SWAP=20
else
    RECOMMENDED_SWAP=10
fi

CURRENT_SWAP=$(cat /proc/sys/vm/swappiness)
echo "   Actuel: $CURRENT_SWAP | Recommandé: $RECOMMENDED_SWAP"

if [ "$EUID" -eq 0 ]; then
    sysctl -w vm.swappiness=$RECOMMENDED_SWAP > /dev/null
    if ! grep -q "vm.swappiness" /etc/sysctl.conf 2>/dev/null; then
        echo "vm.swappiness=$RECOMMENDED_SWAP" >> /etc/sysctl.conf
    else
        sed -i "s/^vm.swappiness=.*/vm.swappiness=$RECOMMENDED_SWAP/" /etc/sysctl.conf
    fi
    echo -e "   ${GREEN}✅ Swappiness configuré: $RECOMMENDED_SWAP${NC}"
else
    echo -e "   ${YELLOW}⚠️  Nécessite sudo${NC}"
    echo "   Commande: sudo sysctl -w vm.swappiness=$RECOMMENDED_SWAP"
fi
echo ""

# === 2. I/O Scheduler ===
echo -e "${BLUE}⚙️  2. I/O Scheduler${NC}"
if [ "$IS_SSD" -eq 1 ]; then
    RECOMMENDED_SCHED="mq-deadline"
else
    RECOMMENDED_SCHED="bfq"
fi

echo "   Recommandé: $RECOMMENDED_SCHED"

if [ "$EUID" -eq 0 ]; then
    for disk in /sys/block/sd?/queue/scheduler /sys/block/nvme?n?/queue/scheduler; do
        if [ -e "$disk" ]; then
            DISK_NAME=$(echo "$disk" | cut -d'/' -f4)
            if grep -q "$RECOMMENDED_SCHED" "$disk"; then
                echo "$RECOMMENDED_SCHED" > "$disk" 2>/dev/null && \
                    echo -e "   ${GREEN}✅ $DISK_NAME: $RECOMMENDED_SCHED${NC}" || \
                    echo -e "   ${YELLOW}⚠️  $DISK_NAME: impossible de changer${NC}"
            else
                echo -e "   ${YELLOW}⚠️  $DISK_NAME: $RECOMMENDED_SCHED non disponible${NC}"
            fi
        fi
    done
else
    echo -e "   ${YELLOW}⚠️  Nécessite sudo${NC}"
    echo "   Commande: echo '$RECOMMENDED_SCHED' | sudo tee /sys/block/sda/queue/scheduler"
fi
echo ""

# === 3. TRIM (si SSD) ===
if [ "$IS_SSD" -eq 1 ]; then
    echo -e "${BLUE}✂️  3. TRIM (SSD)${NC}"
    if systemctl is-enabled fstrim.timer &>/dev/null; then
        echo -e "   ${GREEN}✅ fstrim.timer déjà actif${NC}"
    else
        if [ "$EUID" -eq 0 ]; then
            systemctl enable fstrim.timer &>/dev/null && \
                systemctl start fstrim.timer &>/dev/null && \
                echo -e "   ${GREEN}✅ fstrim.timer activé${NC}" || \
                echo -e "   ${YELLOW}⚠️  Erreur activation fstrim${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Nécessite sudo${NC}"
            echo "   Commande: sudo systemctl enable --now fstrim.timer"
        fi
    fi
    echo ""
fi

# === 4. CPU Governor ===
echo -e "${BLUE}🔋 4. CPU Governor${NC}"
AVAILABLE_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)

if echo "$AVAILABLE_GOV" | grep -q "schedutil"; then
    RECOMMENDED_GOV="schedutil"
elif echo "$AVAILABLE_GOV" | grep -q "ondemand"; then
    RECOMMENDED_GOV="ondemand"
else
    RECOMMENDED_GOV="powersave"
fi

CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
echo "   Actuel: $CURRENT_GOV | Recommandé: $RECOMMENDED_GOV"

if [ "$EUID" -eq 0 ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -e "$cpu" ] && echo "$RECOMMENDED_GOV" > "$cpu" 2>/dev/null
    done
    echo -e "   ${GREEN}✅ Governor configuré: $RECOMMENDED_GOV${NC}"
else
    echo -e "   ${YELLOW}⚠️  Nécessite sudo${NC}"
fi
echo ""

# === 5. ZRAM ===
echo -e "${BLUE}💾 5. ZRAM${NC}"
if [ "$RAM_GB" -le 4 ]; then
    echo "   ZRAM fortement recommandé (RAM ≤4GB)"
    if [ -e /dev/zram0 ]; then
        echo -e "   ${GREEN}✅ ZRAM déjà actif${NC}"
        zramctl 2>/dev/null | head -2
    else
        echo -e "   ${YELLOW}⚠️  ZRAM non configuré${NC}"
        echo "   Installation: voir docs/QUICK_START.md"
    fi
elif [ "$RAM_GB" -le 6 ]; then
    echo "   ZRAM recommandé (RAM 4-6GB)"
    [ -e /dev/zram0 ] && echo -e "   ${GREEN}✅ ZRAM actif${NC}" || echo -e "   ${YELLOW}⚠️  ZRAM optionnel${NC}"
else
    echo "   ZRAM optionnel (RAM >6GB)"
    [ -e /dev/zram0 ] && echo -e "   ℹ️  ZRAM actif" || echo -e "   ℹ️  ZRAM non nécessaire"
fi
echo ""

# === 6. AMD GPU ===
echo -e "${BLUE}🎮 6. GPU AMD - VAAPI${NC}"
if lspci | grep -i vga | grep -qi "amd"; then
    if command -v vainfo &> /dev/null; then
        if vainfo 2>&1 | grep -q "VA-API version"; then
            echo -e "   ${GREEN}✅ VAAPI fonctionnel${NC}"
            vainfo 2>&1 | grep "Driver version" | head -1
        else
            echo -e "   ${YELLOW}⚠️  VAAPI installé mais non fonctionnel${NC}"
            echo "   Vérifier: export LIBVA_DRIVER_NAME=radeonsi"
        fi
    else
        echo -e "   ${YELLOW}⚠️  VAAPI non installé${NC}"
        echo "   Installation: sudo zypper/apt/dnf install libva-mesa-driver vainfo"
    fi
else
    echo "   Pas de GPU AMD détecté"
fi
echo ""

# === 7. TLP (si laptop) ===
echo -e "${BLUE}🔌 7. TLP (gestion batterie)${NC}"
if [ -e /sys/class/power_supply/BAT0 ] || [ -e /sys/class/power_supply/BAT1 ]; then
    if systemctl is-active tlp &>/dev/null; then
        echo -e "   ${GREEN}✅ TLP actif${NC}"
    else
        echo -e "   ${YELLOW}⚠️  TLP non installé/actif${NC}"
        echo "   Installation: sudo zypper/apt/dnf install tlp"
        echo "   Activation: sudo systemctl enable --now tlp"
    fi
else
    echo "   Pas de batterie détectée (desktop?)"
fi
echo ""

# === Résumé ===
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           📊 RÉSUMÉ                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Optimisations appliquées avec succès${NC}"
echo -e "${YELLOW}⚠️  Optimisations nécessitant sudo (si applicable)${NC}"
echo ""
echo "Pour appliquer toutes les optimisations:"
echo "  sudo $0"
echo ""
echo "Autres optimisations disponibles:"
echo "  - Installation complète: voir docs/QUICK_START.md"
echo "  - Configuration Firefox: voir config/firefox-prefs.js"
echo "  - Monitoring: scripts/monitor.sh"
echo ""
