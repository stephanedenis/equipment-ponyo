#!/bin/bash
# Script de vérification post-installation - Ponyo
# Vérifie que tout est correctement configuré

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARN++))
}

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Vérification Configuration - Ponyo   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# === 1. GPU/Mesa ===
echo -e "${BLUE}🎮 GPU & Mesa${NC}"
if command -v glxinfo &>/dev/null; then
    if glxinfo | grep -q "AMD"; then
        check_pass "Mesa/Driver AMD détecté"
    else
        check_warn "GPU AMD non détecté dans glxinfo"
    fi
else
    check_fail "glxinfo non installé (mesa-utils)"
fi

# === 2. VAAPI ===
if command -v vainfo &>/dev/null; then
    if vainfo 2>&1 | grep -q "VA-API version"; then
        check_pass "VAAPI fonctionnel"
    else
        check_fail "VAAPI non fonctionnel"
        echo "  → export LIBVA_DRIVER_NAME=radeonsi"
    fi
else
    check_fail "vainfo non installé (libva-utils)"
fi
echo ""

# === 3. Optimisations système ===
echo -e "${BLUE}⚙️  Optimisations Système${NC}"

# Swappiness
SWAP=$(cat /proc/sys/vm/swappiness)
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')

if [ "$RAM_GB" -le 4 ] && [ "$SWAP" -ge 30 ] && [ "$SWAP" -le 40 ]; then
    check_pass "Swappiness optimal pour RAM ≤4GB ($SWAP)"
elif [ "$RAM_GB" -le 6 ] && [ "$SWAP" -ge 15 ] && [ "$SWAP" -le 25 ]; then
    check_pass "Swappiness optimal pour RAM 4-6GB ($SWAP)"
elif [ "$RAM_GB" -gt 6 ] && [ "$SWAP" -ge 5 ] && [ "$SWAP" -le 15 ]; then
    check_pass "Swappiness optimal pour RAM >6GB ($SWAP)"
else
    check_warn "Swappiness=$SWAP (recommandé: RAM≤4GB=35, 4-6GB=20, >6GB=10)"
fi

# ZRAM
if [ "$RAM_GB" -le 4 ]; then
    if [ -e /dev/zram0 ]; then
        check_pass "ZRAM actif (requis pour RAM ≤4GB)"
    else
        check_fail "ZRAM non activé (fortement recommandé)"
    fi
else
    if [ -e /dev/zram0 ]; then
        check_pass "ZRAM actif"
    else
        check_warn "ZRAM non activé (optionnel pour RAM >4GB)"
    fi
fi

# CPU Governor
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    if [ "$GOV" = "schedutil" ] || [ "$GOV" = "ondemand" ]; then
        check_pass "Governor CPU: $GOV (optimal)"
    elif [ "$GOV" = "powersave" ]; then
        check_warn "Governor: powersave (OK sur batterie)"
    else
        check_warn "Governor: $GOV (schedutil/ondemand recommandé)"
    fi
fi
echo ""

# === 4. Variables environnement ===
echo -e "${BLUE}🔧 Variables Environnement${NC}"

if [ -f ~/.config/ponyo.env ]; then
    check_pass "Fichier ponyo.env existe"
    
    if grep -q "ponyo.env" ~/.bashrc; then
        check_pass "ponyo.env sourcé dans .bashrc"
    else
        check_fail "ponyo.env non sourcé dans .bashrc"
    fi
else
    check_fail "Fichier ~/.config/ponyo.env manquant"
fi

# Test variables
source ~/.bashrc 2>/dev/null || true

if [ -n "$MESA_LOADER_DRIVER_OVERRIDE" ]; then
    check_pass "MESA_LOADER_DRIVER_OVERRIDE défini"
else
    check_warn "MESA_LOADER_DRIVER_OVERRIDE non défini"
fi
echo ""

# === 5. TLP (si laptop) ===
echo -e "${BLUE}🔋 Gestion Batterie${NC}"
if [ -e /sys/class/power_supply/BAT0 ]; then
    if systemctl is-active tlp &>/dev/null; then
        check_pass "TLP actif"
    else
        check_fail "TLP non actif (recommandé pour laptop)"
    fi
else
    check_warn "Pas de batterie détectée (desktop?)"
fi
echo ""

# === 6. Température ===
echo -e "${BLUE}🌡️  Monitoring${NC}"
if command -v sensors &>/dev/null; then
    check_pass "lm-sensors installé"
    
    # Test température
    TEMP=$(sensors 2>/dev/null | grep -oP '\+\K[0-9]+' | head -1)
    if [ -n "$TEMP" ]; then
        if [ "$TEMP" -lt 70 ]; then
            check_pass "Température CPU: ${TEMP}°C (normal)"
        elif [ "$TEMP" -lt 85 ]; then
            check_warn "Température CPU: ${TEMP}°C (limite acceptable)"
        else
            check_fail "Température CPU: ${TEMP}°C (TROP CHAUD!)"
        fi
    fi
else
    check_fail "lm-sensors non installé"
fi
echo ""

# === 7. Stockage ===
echo -e "${BLUE}💿 Stockage${NC}"

IS_SSD=0
for disk in /sys/block/sd? /sys/block/nvme?n?; do
    if [ -e "$disk/queue/rotational" ]; then
        ROTA=$(cat "$disk/queue/rotational")
        if [ "$ROTA" -eq 0 ]; then
            IS_SSD=1
            check_pass "SSD détecté"
            
            # Vérifier TRIM
            if systemctl is-enabled fstrim.timer &>/dev/null; then
                check_pass "TRIM actif (fstrim.timer)"
            else
                check_warn "TRIM non activé (recommandé pour SSD)"
            fi
        else
            check_warn "HDD détecté (SSD recommandé pour meilleures perfs)"
        fi
    fi
done
echo ""

# === 8. Outils essentiels ===
echo -e "${BLUE}🛠️  Outils${NC}"

TOOLS=("htop" "git" "curl" "wget")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        check_pass "$tool installé"
    else
        check_warn "$tool non installé"
    fi
done
echo ""

# === Résumé ===
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RÉSUMÉ                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Checks réussis: $PASS${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARN${NC}"
echo -e "${RED}❌ Checks échoués: $FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}🎉 Configuration optimale !${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "  - Benchmark: bash scripts/benchmark.sh"
    echo "  - Monitoring: bash scripts/monitor.sh"
    echo "  - Firefox: voir config/firefox-prefs.js"
elif [ "$FAIL" -le 2 ]; then
    echo -e "${YELLOW}⚠️  Configuration acceptable avec quelques améliorations possibles${NC}"
    echo ""
    echo "Corrections recommandées listées ci-dessus"
else
    echo -e "${RED}❌ Configuration incomplète${NC}"
    echo ""
    echo "Exécuter: sudo bash scripts/install-complete.sh"
fi
echo ""
