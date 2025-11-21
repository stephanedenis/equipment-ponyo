# Optimisations Spécifiques AMD A6

## 🎯 Priorités selon Configuration

### Si RAM ≤ 4GB
1. **ZRAM obligatoire** (compression RAM)
2. **Swappiness = 30-40**
3. **Desktop léger** (XFCE/LXQt au lieu de KDE/GNOME)
4. **Désactiver services inutiles**

### Si RAM ≥ 6GB
1. **Swappiness = 10**
2. **ZRAM optionnel** (mais recommandé)
3. **Desktop au choix**

### Si HDD (pas SSD)
1. **Readahead = 1024-2048 KB** (pas 256KB comme SSD)
2. **Scheduler = BFQ** (meilleur pour HDD)
3. **noatime** dans /etc/fstab (réduit écritures)
4. **Envisager SSD** (amélioration majeure)

### Si SSD
1. **TRIM actif** (`fstrim.timer`)
2. **Readahead = 128-256 KB**
3. **Scheduler = mq-deadline ou kyber**

## 🔧 GPU AMD Radeon (APU)

### Installation Drivers Mesa
```bash
# openSUSE
sudo zypper install Mesa-dri Mesa-libGL1 libva-mesa-driver mesa-vulkan-drivers

# Ubuntu/Debian
sudo apt install mesa-va-drivers mesa-vulkan-drivers

# Fedora
sudo dnf install mesa-dri-drivers mesa-va-drivers mesa-vulkan-drivers
```

### Configuration VAAPI (décodage vidéo)
```bash
# Installer libva
sudo zypper install libva2 libva-utils  # openSUSE
sudo apt install libva2 vainfo          # Ubuntu

# Tester
vainfo

# Si erreur, forcer driver
export LIBVA_DRIVER_NAME=radeonsi  # ou "radeon" si ancien
echo 'export LIBVA_DRIVER_NAME=radeonsi' >> ~/.bashrc
```

### Variables Environnement AMD
```bash
cat >> ~/.bashrc << 'EOF'

# Optimisations AMD GPU
export MESA_LOADER_DRIVER_OVERRIDE=radeonsi  # ou "radeon" si vieux
export AMD_VULKAN_ICD=RADV
export RADV_PERFTEST=aco  # Compilateur shader optimisé

EOF
source ~/.bashrc
```

## ⚡ CPU AMD A6

### Governor Optimal
```bash
# Vérifier governors disponibles
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Recommandé:
# - schedutil (moderne, défaut)
# - ondemand (si schedutil absent)
# - powersave (sur batterie)

# Configurer schedutil
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil | sudo tee $cpu
done
```

### Persistant via systemd
```bash
sudo tee /etc/systemd/system/cpu-governor.service << 'EOF'
[Unit]
Description=Set CPU governor to schedutil
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo schedutil > $cpu; done'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now cpu-governor.service
```

## 🔋 Économie Énergie (Laptop)

### TLP - Automatique
```bash
# Installation
sudo zypper install tlp tlp-rdw  # openSUSE
sudo apt install tlp tlp-rdw     # Ubuntu

# Activer
sudo systemctl enable --now tlp

# Status
sudo tlp-stat -s
```

### Configuration TLP pour AMD
```bash
sudo nano /etc/tlp.conf

# Recommandations:
CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=50
```

## 🚀 Compilation (Développement)

### Flags Optimisés AMD
```bash
# Détecter architecture exacte
gcc -march=native -Q --help=target | grep march

cat >> ~/.bashrc << 'EOF'

# Optimisations compilation AMD
export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="-march=native -O2 -pipe"
export MAKEFLAGS="-j$(nproc)"

EOF
```

### ccache
```bash
sudo zypper install ccache
echo 'export PATH=/usr/lib64/ccache:$PATH' >> ~/.bashrc
ccache -M 3G  # Limiter selon espace disque
```

## 📊 Monitoring

### Température CPU
```bash
# Installer
sudo sensors-detect  # Répondre YES
sudo systemctl enable --now lm_sensors

# Afficher
sensors
watch -n 2 sensors
```

### Performance
```bash
# Top interactif AMD
htop

# Fréquences CPU en direct
watch -n 1 'grep MHz /proc/cpuinfo'

# GPU stats (si AMDGPU)
radeontop  # sudo zypper install radeontop
```

## 🎮 Cas d'Usage

### Bureautique Légère
- ✅ Parfait (LibreOffice, Firefox, Thunderbird)
- Pas d'optimisation particulière nécessaire

### Multimédia
- ✅ Excellent (décodage GPU 1080p)
- Configurer VAAPI obligatoire

### Développement Web
- ✅ Bon (VS Code, Node.js)
- ccache recommandé

### Compilation C/C++
- ⚠️ Moyen (selon nb cores)
- ccache + MAKEFLAGS=-j$(nproc) essentiels

