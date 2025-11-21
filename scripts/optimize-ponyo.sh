#!/bin/bash
# Optimisations spécifiques pour PONYO (AMD A6-3420M, 15GB RAM)
# Applique la configuration optimale détectée

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Optimisations Ponyo - AMD A6-3420M   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

NEEDS_ROOT=0

# === 1. Swappiness (15GB RAM = 10) ===
echo -e "${BLUE}📝 1. Swappiness (RAM: 15GB)${NC}"
CURRENT=$(cat /proc/sys/vm/swappiness)
TARGET=10

if [ "$CURRENT" -ne "$TARGET" ]; then
    if [ "$EUID" -eq 0 ]; then
        sysctl -w vm.swappiness=$TARGET > /dev/null
        if ! grep -q "vm.swappiness" /etc/sysctl.conf 2>/dev/null; then
            echo "vm.swappiness=$TARGET" >> /etc/sysctl.conf
        else
            sed -i "s/^vm.swappiness=.*/vm.swappiness=$TARGET/" /etc/sysctl.conf
        fi
        echo -e "   ${GREEN}✅ Swappiness: $CURRENT → $TARGET${NC}"
    else
        echo -e "   ${YELLOW}⚠️  Nécessite root: sysctl -w vm.swappiness=$TARGET${NC}"
        NEEDS_ROOT=1
    fi
else
    echo -e "   ${GREEN}✅ Swappiness déjà optimal: $TARGET${NC}"
fi
echo ""

# === 2. Variables GPU (Radeon HD 6520G - ancien) ===
echo -e "${BLUE}🎮 2. GPU AMD Radeon HD 6520G${NC}"

mkdir -p ~/.config

cat > ~/.config/ponyo.env << 'EOF'
# Configuration Ponyo - AMD A6-3420M avec Radeon HD 6520G
# GPU ancien (TeraScale 2) = driver radeon (PAS radeonsi)

# Driver Mesa ancien
export MESA_LOADER_DRIVER_OVERRIDE=radeon

# VAAPI pour H.264 (pas HEVC)
export LIBVA_DRIVER_NAME=r600

# Vulkan non supporté sur cette génération
# AMD_VULKAN_ICD non nécessaire

# Optimisations compilation si dev
export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="-march=native -O2 -pipe"
export MAKEFLAGS="-j4"
EOF

if ! grep -q "ponyo.env" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Ponyo AMD A6-3420M optimizations" >> ~/.bashrc
    echo "[ -f ~/.config/ponyo.env ] && source ~/.config/ponyo.env" >> ~/.bashrc
fi

echo -e "   ${GREEN}✅ Variables GPU configurées (driver radeon)${NC}"
echo -e "   ${GREEN}✅ LIBVA_DRIVER_NAME=r600 (H.264 hardware decode)${NC}"
echo ""

# === 3. CPU Governor ===
echo -e "${BLUE}🔋 3. CPU Governor${NC}"

if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]; then
    AVAILABLE=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)
    
    if echo "$AVAILABLE" | grep -q "schedutil"; then
        TARGET_GOV="schedutil"
    elif echo "$AVAILABLE" | grep -q "ondemand"; then
        TARGET_GOV="ondemand"
    else
        TARGET_GOV="powersave"
    fi
    
    CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    
    if [ "$CURRENT_GOV" != "$TARGET_GOV" ]; then
        if [ "$EUID" -eq 0 ]; then
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                [ -e "$cpu" ] && echo "$TARGET_GOV" > "$cpu" 2>/dev/null
            done
            echo -e "   ${GREEN}✅ Governor: $TARGET_GOV${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Nécessite root pour changer governor vers $TARGET_GOV${NC}"
            NEEDS_ROOT=1
        fi
    else
        echo -e "   ${GREEN}✅ Governor déjà optimal: $TARGET_GOV${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  Gestion CPU governor non disponible${NC}"
fi
echo ""

# === 4. ZRAM (NON nécessaire avec 15GB) ===
echo -e "${BLUE}💾 4. ZRAM${NC}"
if [ -e /dev/zram0 ]; then
    echo -e "   ${YELLOW}⚠️  ZRAM actif mais NON nécessaire avec 15GB RAM${NC}"
    echo -e "   ${YELLOW}   Optionnel: désactiver pour libérer CPU${NC}"
else
    echo -e "   ${GREEN}✅ ZRAM désactivé (correct avec 15GB RAM)${NC}"
fi
echo ""

# === 5. I/O Scheduler ===
echo -e "${BLUE}⚙️  5. I/O Scheduler${NC}"
echo -e "   ${YELLOW}ℹ️  Vérifier type disque avec: lsblk -o NAME,ROTA${NC}"
echo -e "   ${YELLOW}   HDD (ROTA=1): echo bfq | sudo tee /sys/block/sda/queue/scheduler${NC}"
echo -e "   ${YELLOW}   SSD (ROTA=0): echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler${NC}"
echo ""

# === Résumé ===
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ✅ TERMINÉ                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

echo "Configuration appliquée pour Ponyo (AMD A6-3420M, 15GB RAM):"
echo ""
echo -e "${GREEN}✅ Swappiness: $TARGET (optimal pour 15GB RAM)${NC}"
echo -e "${GREEN}✅ GPU: Driver radeon (Radeon HD 6520G)${NC}"
echo -e "${GREEN}✅ VAAPI: r600 (H.264 hardware decode)${NC}"
echo -e "${GREEN}✅ Variables env: ~/.config/ponyo.env${NC}"
echo ""

if [ "$NEEDS_ROOT" -eq 1 ]; then
    echo -e "${YELLOW}⚠️  Certaines optimisations nécessitent root:${NC}"
    echo "   sudo $0"
    echo ""
fi

echo "Prochaines étapes:"
echo "  1. Recharger shell: source ~/.bashrc"
echo "  2. Vérifier VAAPI: vainfo (installer si besoin)"
echo "  3. Test GPU: glxinfo | grep -i renderer"
echo "  4. Vérifier disque: lsblk -o NAME,ROTA"
echo ""
echo "Documentation: voir hardware/PONYO-SPECS.md"
echo ""
