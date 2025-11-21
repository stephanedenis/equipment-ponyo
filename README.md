# Equipment Ponyo

Configuration et documentation système pour le laptop **Ponyo** (HP Pavilion g series).

## 🖥️ Spécifications

- **Machine**: HP Pavilion g series
- **CPU**: AMD A6 (APU)
  - Architecture: Excavator ou plus ancien (à vérifier)
  - Cores: 2-4 cores (selon modèle)
  - Fréquence: ~1.8-2.5 GHz
- **GPU**: AMD Radeon intégré (APU)
  - Accélération matérielle: à configurer
- **RAM**: À déterminer (probablement 4-8 GB DDR3)
- **Stockage**: HDD/SSD (à vérifier)
- **OS**: À installer/configurer
- **Desktop**: À choisir (KDE Plasma, GNOME, XFCE...)

## 📁 Structure

```
equipment-ponyo/
├── system/               # Configuration système
│   ├── SPECIFICATIONS.md           # Specs détaillées (à compléter)
│   ├── OPTIMISATIONS_AMD.md        # Optimisations spécifiques AMD
│   └── INSTALLATION.md             # Guide installation OS
├── hardware/             # Documentation matériel
└── docs/                 # Documentation générale
```

## 🎯 Optimisations Recommandées AMD A6

### Préparation
- [ ] Identifier modèle exact AMD A6 (`lscpu`, `cat /proc/cpuinfo`)
- [ ] Vérifier RAM installée (`free -h`)
- [ ] Type stockage (HDD vs SSD)
- [ ] Génération GPU Radeon

### Système
- [ ] **Swappiness**: Adapter selon RAM (10 si ≥8GB, 30 si 4GB)
- [ ] **ZRAM**: Recommandé si ≤4GB RAM
- [ ] **I/O Scheduler**: 
  - BFQ pour desktop
  - mq-deadline si SSD performant
- [ ] **TRIM**: Si SSD présent

### GPU AMD Radeon
- [ ] **Driver Mesa**: Installation mesa-dri-drivers
- [ ] **VAAPI**: Configuration décodage matériel
  - `libva-mesa-driver` pour AMD
  - Tester avec `vainfo`
- [ ] **Vulkan**: mesa-vulkan-drivers
- [ ] **Variables env**:
  ```bash
  export MESA_LOADER_DRIVER_OVERRIDE=radeon  # ou radeonsi
  export AMD_VULKAN_ICD=RADV
  ```

### CPU AMD
- [ ] **Fréquence scaling**: 
  - schedutil (moderne) ou ondemand
  - Vérifier support Turbo/Boost
- [ ] **Firmware AMD**: linux-firmware installé

### Compilation (si utilisé pour dev)
- [ ] **ccache**: Cache compilation
- [ ] **Flags AMD**:
  ```bash
  export CFLAGS="-march=native -O2 -pipe"
  export CXXFLAGS="-march=native -O2 -pipe"
  export MAKEFLAGS="-j$(nproc)"  # Parallélisation selon cores
  ```

### Économie Énergie (si laptop)
- [ ] **TLP**: Gestion batterie automatique
- [ ] **powertop**: Monitoring et optimisation
- [ ] **CPU governor**: powersave quand sur batterie

## 🔧 Outils Diagnostic

```bash
# Infos CPU
lscpu
cat /proc/cpuinfo | grep "model name"

# Infos GPU
lspci | grep -i vga
glxinfo | grep "OpenGL renderer"

# Accélération matérielle
vainfo  # Décodage vidéo
vulkaninfo  # Vulkan

# Température
sensors  # Après sensors-detect

# Performance
stress -c $(nproc) -t 60s  # Test CPU
```

## 📊 Performances Attendues

AMD A6 (APU) est optimisé pour:
- ✅ Bureautique légère
- ✅ Décodage vidéo 1080p (GPU intégré)
- ⚠️ Compilation moyenne (selon nb cores)
- ❌ Gaming intensif (GPU intégré limité)

## 🔗 Repos Connexes

- [equipment-totoro](https://github.com/stephanedenis/equipment-totoro) - Laptop Intel i7-2670QM
- [equipment-remarkable](https://github.com/stephanedenis/equipment-remarkable) - Tablette reMarkable

## 📝 Notes

**À compléter lors configuration sur la machine Ponyo:**
1. Modèle exact AMD A6 (ex: A6-7310, A6-9225...)
2. RAM installée
3. Type stockage (HDD/SSD)
4. Système choisi (openSUSE, Ubuntu, Fedora...)
5. Desktop environment

