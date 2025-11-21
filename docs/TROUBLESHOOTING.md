# Troubleshooting - Ponyo (AMD A6)

Guide de résolution des problèmes courants sur AMD A6 APU.

## 🔍 Table des Matières

- [Problèmes GPU](#-problèmes-gpu)
- [Problèmes Performances](#-problèmes-performances)
- [Problèmes Système](#-problèmes-système)
- [Problèmes Batterie](#-problèmes-batterie)
- [Diagnostic Général](#-diagnostic-général)

---

## 🎮 Problèmes GPU

### VAAPI ne fonctionne pas (pas d'accélération vidéo)

**Symptômes:**
- CPU à 100% lors lecture vidéo 1080p+
- `vainfo` affiche erreur ou "No driver"

**Diagnostic:**
```bash
# Vérifier VAAPI
vainfo

# Vérifier driver Mesa
glxinfo | grep "OpenGL renderer"
lspci | grep VGA
```

**Solutions:**

1. **Installer drivers VAAPI:**
```bash
# openSUSE
sudo zypper install libva-mesa-driver libva2 libva-utils

# Ubuntu/Debian
sudo apt install mesa-va-drivers libva2 vainfo

# Fedora
sudo dnf install mesa-va-drivers libva-utils
```

2. **Forcer driver radeonsi:**
```bash
export LIBVA_DRIVER_NAME=radeonsi
echo 'export LIBVA_DRIVER_NAME=radeonsi' >> ~/.bashrc
```

3. **Si GPU très ancien (pré-GCN):**
```bash
export LIBVA_DRIVER_NAME=r600
```

4. **Vérifier Mesa version:**
```bash
glxinfo | grep "OpenGL version"
# Si < 20.0, mettre à jour Mesa
```

### Écran noir au boot / Pas d'affichage

**Solutions:**

1. **Ajouter paramètres kernel:**
```bash
# Éditer GRUB
sudo nano /etc/default/grub

# Ajouter à GRUB_CMDLINE_LINUX_DEFAULT:
radeon.dpm=1 amdgpu.dpm=1

# Appliquer
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # openSUSE/Fedora
sudo update-grub                              # Ubuntu
```

2. **Désactiver modesetting au boot:**
```bash
# Temporaire (au boot): touche 'e' dans GRUB
# Ajouter: nomodeset
```

### Performances GPU faibles / Saccades

**Diagnostic:**
```bash
# Vérifier fréquence GPU
sudo cat /sys/kernel/debug/dri/0/radeon_pm_info  # Si radeon
# ou
sudo cat /sys/class/drm/card0/device/pp_dpm_sclk  # Si amdgpu

# Monitoring GPU
radeontop  # sudo zypper install radeontop
```

**Solutions:**

1. **Activer DPM (Dynamic Power Management):**
```bash
echo "auto" | sudo tee /sys/class/drm/card0/device/power_dpm_state
echo "high" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level
```

2. **Permanentiser:**
```bash
sudo nano /etc/modprobe.d/radeon.conf
# Ajouter:
options radeon dpm=1
```

---

## ⚡ Problèmes Performances

### Système lent / Lags

**Diagnostic:**
```bash
# Vérifier usage RAM
free -h

# Vérifier swap
swapon --show

# Top processus
htop

# I/O disque
iostat -x 2  # sudo zypper install sysstat
```

**Solutions selon cause:**

#### A. RAM saturée

```bash
# Vérifier swappiness
cat /proc/sys/vm/swappiness

# Si RAM ≤4GB, activer ZRAM
# openSUSE
sudo zypper install systemd-zram-service
sudo systemctl enable --now zram

# Ubuntu 22.04+
sudo apt install zram-config
sudo systemctl start zramswap

# Vérifier
zramctl
```

#### B. HDD lent

```bash
# Tester vitesse disque
sudo hdparm -t /dev/sda

# Si <50 MB/s: HDD vieillissant
# Solution: upgrade vers SSD

# Optimiser I/O scheduler
echo "bfq" | sudo tee /sys/block/sda/queue/scheduler
```

#### C. CPU throttling

```bash
# Vérifier fréquences
watch -n 1 'grep MHz /proc/cpuinfo'

# Vérifier températures
sensors

# Si >85°C: nettoyage/repâte thermique nécessaire
```

### Firefox lent / Vidéos saccadent

**Solutions:**

1. **Activer accélération matérielle:**
   - Voir `config/firefox-prefs.js`
   - about:config → appliquer toutes les préfs

2. **Vérifier VAAPI actif:**
```bash
# Dans Firefox, ouvrir about:support
# Section "Graphics"
# Chercher: "HARDWARE_VIDEO_DECODING"
```

3. **Réduire processus de contenu:**
```bash
# about:config
# dom.ipc.processCount = 2  # si RAM ≤4GB
```

### Compilation lente

**Solutions:**

1. **Activer ccache:**
```bash
sudo zypper install ccache
export PATH="/usr/lib64/ccache:$PATH"
ccache -M 3G
```

2. **Parallélisation:**
```bash
export MAKEFLAGS="-j$(nproc)"
# Ajouter à ~/.bashrc
```

3. **Flags optimisés:**
```bash
export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="-march=native -O2 -pipe"
```

---

## 🐧 Problèmes Système

### Kernel Panic / Boot impossible

**Solutions:**

1. **Boot en mode recovery:**
   - GRUB: sélectionner "Advanced Options"
   - Choisir kernel précédent

2. **Si openSUSE (Btrfs + Snapper):**
```bash
# Au boot, sélectionner snapshot précédent
# Rollback automatique
```

3. **Réparer GRUB:**
```bash
# Depuis LiveUSB
sudo mount /dev/sdXY /mnt
sudo mount --bind /dev /mnt/dev
sudo mount --bind /sys /mnt/sys
sudo mount --bind /proc /mnt/proc
sudo chroot /mnt
grub2-install /dev/sdX
grub2-mkconfig -o /boot/grub2/grub.cfg
```

### Wifi ne fonctionne pas

**Diagnostic:**
```bash
lspci | grep -i network
rfkill list
ip link show
```

**Solutions:**

1. **Débloquer:**
```bash
sudo rfkill unblock wifi
```

2. **Installer firmware:**
```bash
# openSUSE
sudo zypper install kernel-firmware

# Ubuntu
sudo apt install linux-firmware

# Fedora
sudo dnf install linux-firmware
```

3. **Réinitialiser NetworkManager:**
```bash
sudo systemctl restart NetworkManager
```

### Audio ne fonctionne pas

**Diagnostic:**
```bash
aplay -l
pactl list sinks
```

**Solutions:**

1. **Réinstaller PulseAudio/PipeWire:**
```bash
# openSUSE
sudo zypper install pulseaudio

# Redémarrer
pulseaudio -k
pulseaudio --start
```

2. **Vérifier unmute:**
```bash
alsamixer  # Touche 'M' pour unmute
```

---

## 🔋 Problèmes Batterie

### Batterie se vide vite

**Solutions:**

1. **Installer TLP:**
```bash
sudo zypper install tlp tlp-rdw
sudo systemctl enable --now tlp
```

2. **Vérifier santé batterie:**
```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
# Regarder "capacity"
```

3. **Réduire luminosité:**
```bash
# Ajouter à ~/.bashrc
echo 50 | sudo tee /sys/class/backlight/*/brightness
```

4. **Gouverneur CPU powersave:**
```bash
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave | sudo tee $cpu
done
```

### Batterie ne charge pas

**Diagnostic:**
```bash
cat /sys/class/power_supply/BAT0/status
cat /sys/class/power_supply/AC/online
```

**Solutions:**

1. Vérifier câble/adaptateur
2. Calibrer batterie (décharge complète puis charge 100%)
3. Si vieille batterie (>3 ans): remplacement probable

---

## 🔧 Diagnostic Général

### Commandes Essentielles

```bash
# Audit complet automatique
bash scripts/audit-hardware.sh

# Monitoring en direct
bash scripts/monitor.sh

# Benchmark performances
bash scripts/benchmark.sh

# Infos système
inxi -Fxz   # sudo zypper install inxi

# Logs système
journalctl -xe
dmesg | tail -50
```

### Températures Anormales

**Normal:**
- CPU idle: 40-55°C
- CPU load: 60-85°C
- **>90°C: PROBLÈME**

**Solutions:**
1. Nettoyer ventilateurs (air comprimé)
2. Remplacer pâte thermique
3. Vérifier ventilateur fonctionne:
```bash
sensors | grep fan
```

### Disk Full

```bash
# Trouver gros fichiers
sudo du -h / | sort -rh | head -20

# Nettoyage automatique
sudo bash scripts/maintenance.sh

# Journaux
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M
```

---

## 🆘 Ressources

### Communauté

- **openSUSE**: https://forums.opensuse.org
- **Ubuntu**: https://askubuntu.com
- **Arch Wiki** (excellent même pour autres distros): https://wiki.archlinux.org

### Fichiers Logs Importants

```bash
# Boot
journalctl -b

# Kernel
dmesg

# Xorg/Wayland
~/.local/share/xorg/Xorg.0.log
journalctl -u display-manager

# Mesa/GPU
LIBGL_DEBUG=verbose glxinfo
```

### Si Tout Échoue

1. **Créer issue GitHub** avec:
   - Sortie de `scripts/audit-hardware.sh`
   - Description problème
   - Logs pertinents

2. **Réinstallation propre:**
   - Backup données
   - Réinstaller distribution
   - Appliquer `scripts/optimize-system.sh`

---

**Problème non listé?** Ouvrez une issue sur GitHub avec détails.
