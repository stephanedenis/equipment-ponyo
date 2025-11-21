#!/bin/bash
# Script de benchmark - Ponyo (AMD A6)
# Teste les performances CPU, RAM, disque et GPU

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$PROJECT_ROOT/benchmarks"
RESULTS_FILE="$RESULTS_DIR/benchmark-$(date +%Y%m%d-%H%M%S).md"

mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Benchmark Système - Ponyo         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Création fichier résultats
cat > "$RESULTS_FILE" << 'HEADER'
# Benchmark Système - Ponyo

HEADER
echo "Date: $(date '+%d %B %Y - %H:%M:%S')" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# === Configuration ===
echo "## ⚙️ Configuration" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "- **CPU**: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)" >> "$RESULTS_FILE"
echo "- **RAM**: $(free -h | awk '/^Mem:/{print $2}')" >> "$RESULTS_FILE"
echo "- **OS**: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> "$RESULTS_FILE"
echo "- **Kernel**: $(uname -r)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# === 1. CPU Performance ===
echo -e "${BLUE}🖥️  Test CPU...${NC}"
echo "## 🖥️ CPU Performance" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v sysbench &> /dev/null; then
    echo "### Sysbench CPU (single-thread)" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    sysbench cpu --cpu-max-prime=20000 --threads=1 run 2>&1 | grep -E "events per second|total time|min:|avg:|max:" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "### Sysbench CPU (multi-thread)" >> "$RESULTS_FILE"
    NCORES=$(nproc)
    echo '```' >> "$RESULTS_FILE"
    sysbench cpu --cpu-max-prime=20000 --threads=$NCORES run 2>&1 | grep -E "events per second|total time|min:|avg:|max:" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
else
    echo -e "${YELLOW}⚠️  sysbench non installé (optionnel)${NC}"
    echo "_sysbench non installé_" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
fi

# Test compression (toujours dispo)
echo "### Test compression (pigz)" >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
if command -v pigz &> /dev/null; then
    dd if=/dev/zero bs=1M count=100 2>/dev/null | pigz -c > /dev/null
    echo "100MB compressés avec pigz: OK" >> "$RESULTS_FILE"
else
    dd if=/dev/zero bs=1M count=100 2>/dev/null | gzip -c > /dev/null
    echo "100MB compressés avec gzip: OK" >> "$RESULTS_FILE"
fi
echo '```' >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# === 2. RAM Performance ===
echo -e "${BLUE}💾 Test RAM...${NC}"
echo "## 💾 RAM Performance" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v sysbench &> /dev/null; then
    echo "### Sysbench Memory" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    sysbench memory --memory-total-size=1G run 2>&1 | grep -E "transferred|total time|min:|avg:|max:" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
else
    echo "_sysbench non installé_" >> "$RESULTS_FILE"
fi
echo "" >> "$RESULTS_FILE"

# === 3. Disque Performance ===
echo -e "${BLUE}💿 Test Disque...${NC}"
echo "## 💿 Disque Performance" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

TEMP_FILE="/tmp/benchmark-disk-test.tmp"

echo "### Lecture séquentielle" >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
dd if=/dev/zero of=$TEMP_FILE bs=1M count=500 conv=fdatasync 2>&1 | grep -E "copied|MB/s|GB/s" >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

echo "### Écriture séquentielle" >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
dd if=$TEMP_FILE of=/dev/null bs=1M 2>&1 | grep -E "copied|MB/s|GB/s" >> "$RESULTS_FILE"
rm -f $TEMP_FILE
echo '```' >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# === 4. GPU (si disponible) ===
echo -e "${BLUE}🎮 Test GPU...${NC}"
echo "## 🎮 GPU" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v glxinfo &> /dev/null; then
    echo "### OpenGL Info" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    glxinfo | grep -E "OpenGL renderer|OpenGL version|direct rendering" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
fi

if command -v glxgears &> /dev/null; then
    echo "### glxgears (5 secondes)" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    timeout 5s glxgears 2>&1 | grep "frames" | tail -1 >> "$RESULTS_FILE" || echo "glxgears test terminé" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
fi

if command -v vainfo &> /dev/null; then
    echo "### VAAPI Support" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    vainfo 2>&1 | grep -E "Driver version|VAProfile" | head -10 >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
fi

# === 5. Température & Monitoring ===
echo -e "${BLUE}🌡️  Monitoring...${NC}"
echo "## 🌡️ Température & État" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

if command -v sensors &> /dev/null; then
    echo "### Température CPU" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
    sensors 2>/dev/null | grep -E "°C|RPM" >> "$RESULTS_FILE" || echo "sensors-detect non exécuté" >> "$RESULTS_FILE"
    echo '```' >> "$RESULTS_FILE"
else
    echo "_lm-sensors non installé_" >> "$RESULTS_FILE"
fi
echo "" >> "$RESULTS_FILE"

echo "### Fréquences CPU" >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
grep MHz /proc/cpuinfo >> "$RESULTS_FILE"
echo '```' >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# === Résumé ===
echo "## 📊 Résumé" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$RAM_GB" -le 4 ]; then
    echo "- ⚠️ RAM ≤4GB: Performances limitées pour multitâche" >> "$RESULTS_FILE"
elif [ "$RAM_GB" -le 6 ]; then
    echo "- ✅ RAM correcte pour usage bureautique/web" >> "$RESULTS_FILE"
else
    echo "- ✅ RAM suffisante pour multitâche" >> "$RESULTS_FILE"
fi

if lsblk -o ROTA | grep -q "^1$"; then
    echo "- 💿 HDD: SSD recommandé pour boost performances" >> "$RESULTS_FILE"
else
    echo "- ⚡ SSD: Performances disque optimales" >> "$RESULTS_FILE"
fi

if lspci | grep -i vga | grep -qi "amd"; then
    if command -v vainfo &> /dev/null && vainfo 2>&1 | grep -q "VA-API version"; then
        echo "- 🎮 VAAPI: Décodage vidéo matériel actif" >> "$RESULTS_FILE"
    else
        echo "- ⚠️ VAAPI: Configurer pour décodage vidéo" >> "$RESULTS_FILE"
    fi
fi

echo "" >> "$RESULTS_FILE"
echo "---" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"
echo "**Outils optionnels pour benchmarks avancés:**" >> "$RESULTS_FILE"
echo "- CPU: \`sysbench\` (sudo zypper/apt/dnf install sysbench)" >> "$RESULTS_FILE"
echo "- GPU: \`glmark2\` (benchmark OpenGL avancé)" >> "$RESULTS_FILE"
echo "- Disque: \`fio\` (benchmark I/O professionnel)" >> "$RESULTS_FILE"

# Affichage
echo ""
echo -e "${GREEN}✅ Benchmark terminé !${NC}"
echo -e "📄 Résultats: ${YELLOW}$RESULTS_FILE${NC}"
echo ""
cat "$RESULTS_FILE"
