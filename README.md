# Equipment Ponyo 🐟

Configuration et documentation système pour le laptop **Ponyo** (HP Pavilion g series avec AMD A6 APU).

> **Démarrage rapide**: Voir [docs/QUICK_START.md](docs/QUICK_START.md) pour configurer en 5 minutes ⚡

## 🖥️ Spécifications de Ponyo

- **Machine**: HP Pavilion g series
- **CPU**: **AMD A6-3420M APU** (Llano, 2011)
  - Architecture: K10.5
  - Cores: **4 physiques** (pas d'HT)
  - Fréquence: **800-1500 MHz** (Turbo Core)
- **GPU**: **AMD Radeon HD 6520G** (TeraScale 2)
  - Support UVD3 (H.264 hardware decode)
  - OpenGL 4.2, DirectX 11
  - Driver: Mesa **radeon** (génération ancienne)
- **RAM**: **15 GB** DDR3 🎉
- **Stockage**: **SSD 112 GB** ⚡

✅ **Configuration excellente** pour bureautique/développement intensif !

📋 **Specs détaillées**: Voir [hardware/PONYO-SPECS.md](hardware/PONYO-SPECS.md)

## 📁 Structure du Projet

```
equipment-ponyo/
├── scripts/              # Scripts d'automatisation
│   ├── audit-hardware.sh         # Audit matériel automatique
│   ├── optimize-system.sh        # Optimisations automatiques
│   ├── benchmark.sh              # Tests de performances
│   ├── monitor.sh                # Monitoring temps réel
│   └── maintenance.sh            # Maintenance système
├── system/               # Configuration système de base
│   ├── SPECIFICATIONS.md         # Template specs détaillées
│   ├── OPTIMISATIONS_AMD.md      # Guide optimisations AMD
│   └── INSTALLATION.md           # Guide installation OS
├── config/               # Fichiers de configuration
│   ├── sysctl-ponyo.conf         # Optimisations kernel
│   ├── firefox-prefs.js          # Firefox optimisé AMD
│   └── env-template              # Variables environnement
├── docs/                 # Documentation complète
│   ├── QUICK_START.md            # Démarrage rapide (5 min)
│   ├── TROUBLESHOOTING.md        # Résolution problèmes
│   └── DISTRIBUTIONS.md          # Comparatif distributions
├── hardware/             # Audits matériel sauvegardés
└── benchmarks/           # Résultats benchmarks
```

## 🚀 Démarrage Rapide

### Option 1: Installation Automatique (Recommandé) ⚡

```bash
# Cloner et installer en une commande
git clone https://github.com/stephanedenis/equipment-ponyo.git
cd equipment-ponyo
sudo bash scripts/install-complete.sh
```

**Inclut:** Drivers AMD, VAAPI, TLP, ZRAM, optimisations complètes

### Option 2: Installation Manuelle

```bash
# 1. Cloner le repo
git clone https://github.com/stephanedenis/equipment-ponyo.git
cd equipment-ponyo

# 2. Auditer le matériel
bash scripts/audit-hardware.sh

# 3. Optimiser
sudo bash scripts/optimize-system.sh

# 4. Vérifier
bash scripts/verify-config.sh
```

✅ **Configuration terminée !** Voir [MEMO.md](MEMO.md) pour référence rapide ou [docs/QUICK_START.md](docs/QUICK_START.md) pour guide détaillé.

## 📚 Documentation

| Document | Description |
|----------|-------------|
| 🚀 **[MEMO.md](MEMO.md)** | **Référence rapide - commandes essentielles** |
| ⚡ **[QUICK_START.md](docs/QUICK_START.md)** | **Guide 5 minutes pour démarrer** |
| 🎬 **[CINEMA_OFFLINE.md](docs/CINEMA_OFFLINE.md)** | **Configuration visionnage films (HDD 750GB, H.264, VAAPI)** |
| 🎞️ **[SOURCES_FILMS.md](docs/SOURCES_FILMS.md)** | **Trouver films légaux gratuits en H.264 (Archive.org, YouTube)** |
| 🐧 **[DISTRIBUTIONS.md](docs/DISTRIBUTIONS.md)** | Comparatif distributions Linux |
| 🔧 **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** | Résolution de problèmes |
| ⚙️ **[OPTIMISATIONS_AMD.md](system/OPTIMISATIONS_AMD.md)** | Optimisations spécifiques AMD |
| 📦 **[INSTALLATION.md](system/INSTALLATION.md)** | Guide installation OS |
| ✅ **[CHECKLIST.md](CHECKLIST.md)** | Suivi configuration étape par étape |

## 🛠️ Scripts Disponibles

| Script | Usage | Description |
|--------|-------|-------------|
| **`install-complete.sh`** | **Installation** | **Installation complète automatique (one-shot)** |
| **`setup-cinema.sh`** | **🎬 Cinéma** | **Configuration disque 750GB pour films (interactif)** |
| `download-films-example.sh` | Téléchargement | Script exemple pour télécharger films H.264 avec yt-dlp |
| `audit-hardware.sh` | Diagnostic | Collecte infos matériel et génère rapport |
| `optimize-system.sh` | Configuration | Applique optimisations automatiques |
| `verify-config.sh` | Vérification | Vérifie que tout est bien configuré |
| `benchmark.sh` | Performance | Teste CPU, RAM, disque, GPU |
| `monitor.sh` | Monitoring | Dashboard temps réel (CPU, RAM, T°) |
| `maintenance.sh` | Maintenance | Nettoyage système automatique |

**Exemples:**

```bash
# Installation complète (une seule commande!)
sudo bash scripts/install-complete.sh

# 🎬 Configuration cinéma hors-ligne (HDD 750GB)
sudo bash scripts/setup-cinema.sh

# Vérifier configuration
bash scripts/verify-config.sh

# Monitoring en direct
bash scripts/monitor.sh

# Maintenance hebdomadaire
sudo bash scripts/maintenance.sh
```

## ⚙️ Configurations Optimisées

| Fichier | Application | Description |
|---------|-------------|-------------|
| `config/sysctl-ponyo.conf` | Kernel | Optimisations mémoire, réseau, I/O |
| `config/firefox-prefs.js` | Firefox | Accélération GPU, VAAPI |
| `config/env-template` | Shell | Variables environnement AMD |

## 🎯 Optimisations Appliquées sur Ponyo

### ✅ Configuration 100% Optimale

- ✅ **Swappiness**: 10 (optimal pour 15GB RAM) - Actif
- ✅ **CPU Governor**: schedutil (performances/efficience) - Actif
- ✅ **GPU Driver**: radeon (Radeon HD 6520G) - Configuré
- ✅ **VAAPI**: r600 (décodage H.264 matériel) - Actif
- ✅ **SSD**: 112GB avec **mq-deadline** - Actif
- ✅ **TRIM**: fstrim.timer - Actif
- ✅ **ZRAM**: Désactivé (non nécessaire avec 15GB)
- ✅ **Variables env**: Configurées dans ~/.config/ponyo.env

### 🚀 Script d'Optimisation Ponyo

Configuration spécifique déjà appliquée ! Pour réappliquer:

```bash
bash scripts/optimize-ponyo.sh
```

### 📚 Capacités de Ponyo (15GB RAM + 4 cores)

**Excellent pour**:

- ✅ Bureautique intensive (LibreOffice multi-docs)
- ✅ Développement (VS Code, Docker, multiples projets)
- ✅ Navigation intensive (dizaines d'onglets)
- ✅ Vidéo 1080p H.264 (décodage GPU)
- ✅ Multitâche avancé

**Limites**:

- ⚠️ Vidéo 4K / HEVC/VP9 (GPU 2011)
- ⚠️ Gaming moderne

📖 **Détails complets**: [hardware/PONYO-SPECS.md](hardware/PONYO-SPECS.md)

## 🔧 Commandes Utiles

### Diagnostic Rapide

```bash
# Audit complet automatique
bash scripts/audit-hardware.sh

# Infos système
lscpu                              # CPU
free -h                            # RAM
lsblk                              # Disques
lspci | grep -i vga                # GPU

# Accélération GPU
vainfo                             # VAAPI (vidéo)
glxinfo | grep "OpenGL renderer"   # OpenGL

# Monitoring
bash scripts/monitor.sh            # Dashboard temps réel
sensors                            # Températures
htop                               # Processus
```

### Tests Performance

```bash
# Benchmark automatique complet
bash scripts/benchmark.sh

# Tests manuels
stress -c $(nproc) -t 60           # Stress CPU
dd if=/dev/zero of=/tmp/test bs=1M count=500 conv=fdatasync  # Disque
```

## 🎯 Capacités et Cas d'Usage

Ponyo est optimisé pour:

- ✅ **Bureautique**: LibreOffice, navigation web, email
- ✅ **Multimédia**: Lecture 1080p (avec VAAPI configuré)
- ✅ **Développement web**: VS Code, Node.js, Python
- ✅ **Apprentissage Linux**: Plateforme idéale

Limitations:

- ⚠️ **Compilation lourde**: Utiliser ccache et MAKEFLAGS
- ⚠️ **Multitâche intensif**: Selon RAM disponible
- ❌ **Gaming moderne**: GPU intégré limité
- ❌ **Édition vidéo 4K**: Hardware insuffisant

## 🔗 Repos Connexes

- [equipment-totoro](https://github.com/stephanedenis/equipment-totoro) - Laptop Intel i7-2670QM
- [equipment-remarkable](https://github.com/stephanedenis/equipment-remarkable) - Tablette reMarkable

## 🆘 Support et Contribution

- **Problèmes**: Voir [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Questions**: Ouvrir une [issue GitHub](https://github.com/stephanedenis/equipment-ponyo/issues)
- **Améliorations**: Pull requests bienvenues !

## 📝 Prochaines Étapes

Après installation:

1. ✅ Exécuter `bash scripts/audit-hardware.sh`
2. ✅ Compléter `system/SPECIFICATIONS.md` avec infos réelles
3. ✅ Appliquer `sudo bash scripts/optimize-system.sh`
4. ✅ Configurer Firefox avec `config/firefox-prefs.js`
5. ✅ Tester avec `bash scripts/benchmark.sh`

Suivi détaillé: [CHECKLIST.md](CHECKLIST.md)

## 📄 Licence

MIT License - Libre d'utilisation et modification.

---

**Fait avec ❤️ pour optimiser Ponyo (AMD A6)** 🐟

