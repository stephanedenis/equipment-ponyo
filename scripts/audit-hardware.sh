#!/bin/bash
# Script d'audit automatique du matériel - Ponyo (AMD A6)
# Collecte toutes les informations système nécessaires

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_ROOT/hardware/system-audit-$(date +%Y%m%d-%H%M%S).md"

echo "🔍 Audit matériel de Ponyo en cours..."
echo ""

# Création du fichier de sortie
mkdir -p "$(dirname "$OUTPUT_FILE")"

cat > "$OUTPUT_FILE" << 'HEADER'
# Audit Système - Ponyo
HEADER

echo "Date: $(date '+%d %B %Y - %H:%M:%S')" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# === CPU ===
echo "## 🖥️ CPU" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
lscpu | grep -E "Architecture|Model name|CPU\(s\)|Thread|MHz|Cache" >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur collecte CPU" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### Détails processeur" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cat /proc/cpuinfo | grep -E "model name|cpu MHz|cores|flags" | head -20 >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur /proc/cpuinfo" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### Governor actuel" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort -u >> "$OUTPUT_FILE" || echo "Non disponible" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# === RAM ===
echo "## 💾 RAM" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
free -h >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v dmidecode &> /dev/null && [ "$EUID" -eq 0 ]; then
    echo "### Détails RAM (dmidecode)" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    dmidecode -t memory | grep -E "Size|Speed|Type:|Manufacturer" >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur dmidecode" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
else
    echo "_Note: Exécuter avec sudo pour détails RAM complets_" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# === GPU ===
echo "## 🎮 GPU" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
lspci | grep -i vga >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur lspci GPU" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if command -v glxinfo &> /dev/null; then
    echo "### OpenGL Info" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    glxinfo | grep -E "OpenGL renderer|OpenGL version|OpenGL vendor" >> "$OUTPUT_FILE" 2>/dev/null || echo "glxinfo non disponible" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

if command -v vainfo &> /dev/null; then
    echo "### VAAPI (décodage matériel)" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    vainfo 2>&1 | head -20 >> "$OUTPUT_FILE" || echo "VAAPI non configuré" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# === Stockage ===
echo "## 💿 Stockage" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,ROTA,FSTYPE >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur lsblk" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### Détails disques" >> "$OUTPUT_FILE"
for disk in /dev/sd? /dev/nvme?n?; do
    if [ -e "$disk" ]; then
        echo "#### $disk" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        if command -v hdparm &> /dev/null && [ "$EUID" -eq 0 ]; then
            hdparm -I "$disk" 2>/dev/null | grep -E "Model|TRIM|LBA" | head -5 >> "$OUTPUT_FILE" || echo "Erreur hdparm" >> "$OUTPUT_FILE"
        else
            echo "Exécuter avec sudo pour plus de détails" >> "$OUTPUT_FILE"
        fi
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# === Système ===
echo "## 🐧 Système" >> "$OUTPUT_FILE"
echo "- **Distribution**: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> "$OUTPUT_FILE"
echo "- **Kernel**: $(uname -r)" >> "$OUTPUT_FILE"
echo "- **Architecture**: $(uname -m)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Desktop environment
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    echo "- **Desktop**: $XDG_CURRENT_DESKTOP" >> "$OUTPUT_FILE"
elif [ -n "$DESKTOP_SESSION" ]; then
    echo "- **Desktop**: $DESKTOP_SESSION" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# === Réseau ===
echo "## 🌐 Réseau" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
lspci | grep -i network >> "$OUTPUT_FILE" 2>/dev/null || echo "Erreur réseau" >> "$OUTPUT_FILE"
ip link show | grep -E "^[0-9]" >> "$OUTPUT_FILE" 2>/dev/null
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# === Batterie ===
echo "## 🔋 Batterie (si laptop)" >> "$OUTPUT_FILE"
if command -v upower &> /dev/null; then
    echo '```' >> "$OUTPUT_FILE"
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep -E "percentage|state|energy|capacity" >> "$OUTPUT_FILE" || echo "Pas de batterie détectée" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
else
    echo "_upower non installé_" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# === Température ===
echo "## 🌡️ Température" >> "$OUTPUT_FILE"
if command -v sensors &> /dev/null; then
    echo '```' >> "$OUTPUT_FILE"
    sensors 2>/dev/null | grep -E "°C|RPM" >> "$OUTPUT_FILE" || echo "sensors-detect pas exécuté" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
else
    echo "_lm-sensors non installé (installer avec: sudo zypper/apt/dnf install lm-sensors)_" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# === Optimisations actuelles ===
echo "## ⚙️ Optimisations actuelles" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### Swappiness" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cat /proc/sys/vm/swappiness >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### I/O Scheduler" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
for disk in /sys/block/sd?/queue/scheduler /sys/block/nvme?n?/queue/scheduler; do
    [ -e "$disk" ] && echo "$disk: $(cat $disk)" >> "$OUTPUT_FILE"
done
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "### ZRAM status" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
if [ -e /dev/zram0 ]; then
    zramctl 2>/dev/null >> "$OUTPUT_FILE" || echo "zram présent mais zramctl non dispo" >> "$OUTPUT_FILE"
else
    echo "ZRAM non activé" >> "$OUTPUT_FILE"
fi
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# === Résumé et recommandations ===
echo "## 📊 Résumé et Recommandations" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Analyse RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$RAM_GB" -le 4 ]; then
    echo "- ⚠️ RAM ≤4GB détectée → **ZRAM fortement recommandé**" >> "$OUTPUT_FILE"
    echo "- ⚠️ Swappiness recommandé: **30-40**" >> "$OUTPUT_FILE"
    echo "- ⚠️ Desktop léger recommandé (XFCE/LXQt)" >> "$OUTPUT_FILE"
elif [ "$RAM_GB" -le 6 ]; then
    echo "- ✅ RAM 4-6GB → ZRAM optionnel mais recommandé" >> "$OUTPUT_FILE"
    echo "- ✅ Swappiness recommandé: **10-20**" >> "$OUTPUT_FILE"
else
    echo "- ✅ RAM >6GB → Configuration optimale" >> "$OUTPUT_FILE"
    echo "- ✅ Swappiness recommandé: **10**" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Analyse disque
if lsblk -o ROTA | grep -q "^1$"; then
    echo "- 💿 HDD détecté → Envisager upgrade SSD (amélioration majeure)" >> "$OUTPUT_FILE"
    echo "- 💿 Scheduler recommandé: **BFQ**" >> "$OUTPUT_FILE"
else
    echo "- ⚡ SSD détecté → Vérifier TRIM activé" >> "$OUTPUT_FILE"
    echo "- ⚡ Scheduler recommandé: **mq-deadline** ou **kyber**" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# GPU
if lspci | grep -i vga | grep -qi "amd"; then
    echo "- 🎮 GPU AMD détecté → Configurer VAAPI pour décodage vidéo" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "✅ Audit terminé. Résultats sauvegardés dans: \`$OUTPUT_FILE\`" >> "$OUTPUT_FILE"

# Affichage
echo ""
echo "✅ Audit terminé !"
echo "📄 Résultats: $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"
