# Guide Installation - Ponyo (HP Pavilion AMD A6)

## 🎯 Distributions Recommandées

### Option 1: openSUSE Tumbleweed (Rolling)
**Recommandé si:**
- Aimes les dernières versions
- Veux YaST (outil config graphique)
- Hardware récent (bon support AMD)

**Avantages:**
- ✅ Drivers AMD à jour
- ✅ Btrfs + snapshots par défaut
- ✅ YaST excellent

### Option 2: Fedora Workstation
**Recommandé si:**
- Veux équilibre stabilité/nouveauté
- Apprécies GNOME
- Support Red Hat

**Avantages:**
- ✅ Mesa récent (GPU AMD)
- ✅ SELinux configuré
- ✅ DNF performant

### Option 3: Ubuntu LTS 24.04
**Recommandé si:**
- Veux stabilité maximale
- Nouveau sur Linux
- Support 5 ans

**Avantages:**
- ✅ Documentation extensive
- ✅ Support long terme
- ✅ PPAs disponibles

## 📥 Checklist Installation

### Avant Installation
- [ ] Backup données importantes
- [ ] Note modèle exact: `sudo dmidecode -s system-product-name`
- [ ] Vérifier boot UEFI vs Legacy BIOS
- [ ] Désactiver Secure Boot si problèmes

### Pendant Installation
- [ ] Partitionnement:
  - Si SSD: ext4 ou btrfs
  - Si HDD: ext4 recommandé
  - Swap: taille = RAM (si ZRAM, 2GB suffisent)
- [ ] Choisir desktop selon RAM:
  - ≤4GB: XFCE, LXQt, MATE
  - ≥6GB: KDE Plasma, GNOME

### Après Installation
- [ ] Update système
- [ ] Installer drivers propriétaires si suggérés
- [ ] Configurer VAAPI (voir OPTIMISATIONS_AMD.md)
- [ ] Installer TLP si laptop
- [ ] Cloner ce repo: `git clone https://github.com/stephanedenis/equipment-ponyo.git`

## 🔧 Post-Installation Rapide

```bash
# 1. Update
sudo zypper dup  # openSUSE
sudo apt update && sudo apt upgrade  # Ubuntu
sudo dnf upgrade  # Fedora

# 2. Drivers AMD
sudo zypper install Mesa-dri libva-mesa-driver mesa-vulkan-drivers

# 3. Outils essentiels
sudo zypper install htop git curl wget vim

# 4. TLP (batterie)
sudo zypper install tlp tlp-rdw
sudo systemctl enable --now tlp

# 5. Cloner config
cd ~
git clone https://github.com/stephanedenis/equipment-ponyo.git

# 6. Compléter SPECIFICATIONS.md
cd equipment-ponyo
# Exécuter commandes dans system/SPECIFICATIONS.md
```

