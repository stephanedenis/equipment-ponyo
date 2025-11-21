# 🎬 Configuration Cinéma Hors-Ligne - Ponyo

Guide pour optimiser Ponyo comme station de visionnage de films avec stockage 750GB.

## 📋 Vue d'ensemble

**Configuration cible**:
- **SSD 112GB**: Système + applications + cache
- **HDD 750GB**: Bibliothèque de films (à configurer)
- **Usage**: Visionnage hors-ligne, téléchargements occasionnels

## 💾 Configuration Disque 750GB

### 1. Formatage et montage

#### Identifier le disque
```bash
# Lister tous les disques
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,ROTA,MODEL

# Le HDD 750GB devrait apparaître (ROTA=1 = disque mécanique)
# Exemple: /dev/sdb (vérifier le bon device !)
```

#### Formater en ext4 (recommandé pour Linux)
```bash
# ⚠️ ATTENTION: Remplacer /dev/sdX par le BON disque !
# Vérifier DEUX FOIS avant d'exécuter

# Créer une partition
sudo fdisk /dev/sdX
# Dans fdisk: n (nouvelle), p (primaire), Enter, Enter, Enter, w (écrire)

# Formater en ext4
sudo mkfs.ext4 -L "Films" /dev/sdX1

# Créer le point de montage
sudo mkdir -p /mnt/films

# Monter le disque
sudo mount /dev/sdX1 /mnt/films

# Donner les permissions utilisateur
sudo chown $USER:$USER /mnt/films
```

#### Montage automatique au démarrage
```bash
# Obtenir l'UUID du disque
sudo blkid /dev/sdX1

# Éditer fstab
sudo nano /etc/fstab

# Ajouter cette ligne (remplacer UUID par la valeur obtenue):
UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /mnt/films ext4 defaults,noatime 0 2
```

### 2. Optimisations HDD pour films

```bash
# Désactiver l'indexation (inutile pour films)
sudo chattr +C /mnt/films

# Optimiser le scheduler pour HDD (lecture séquentielle)
echo bfq | sudo tee /sys/block/sdX/queue/scheduler

# Rendre permanent
echo 'ACTION=="add|change", KERNEL=="sdX", ATTR{queue/scheduler}="bfq"' | \
  sudo tee /etc/udev/rules.d/60-scheduler-hdd.rules
```

## 🎬 Formats Vidéo Optimaux pour Ponyo

### Recommandations basées sur le matériel

**GPU**: AMD Radeon HD 6520G avec VAAPI r600
- ✅ **H.264 (AVC)**: Décodage MATÉRIEL - **OPTIMAL**
- ⚠️ **H.265 (HEVC)**: Décodage SOFTWARE uniquement (lent, CPU intensif)
- ⚠️ **VP9**: Décodage SOFTWARE uniquement
- ⚠️ **AV1**: Non supporté (trop récent)

### Formats de conteneurs recommandés
1. **MP4** (`.mp4`) - Universel, léger
2. **MKV** (`.mkv`) - Flexible, multi-pistes audio/sous-titres
3. **AVI** (`.avi`) - Compatible mais obsolète

### Codecs à privilégier

| Format | Codec Vidéo | Codec Audio | Décodage | Qualité | Recommandé |
|--------|-------------|-------------|----------|---------|------------|
| **1080p H.264** | H.264/AVC | AAC/AC3 | 🟢 GPU | Excellente | ✅ **OPTIMAL** |
| 720p H.264 | H.264/AVC | AAC | 🟢 GPU | Très bonne | ✅ Bon |
| 1080p H.265 | HEVC | AAC | 🔴 CPU | Excellente | ⚠️ Éviter (lag) |
| 4K | Quelconque | Quelconque | 🔴 CPU | - | ❌ Impossible |

### Résolutions optimales
- ✅ **1080p (1920×1080)**: Parfait pour Ponyo
- ✅ **720p (1280×720)**: Très fluide, bon compromis taille/qualité
- ⚠️ **480p (SD)**: Fluide mais qualité moyenne
- ❌ **4K/2160p**: GPU trop ancien, impossible

### Bitrates recommandés (H.264)

**Pour 1080p**:
- Films d'action: 8-12 Mbps
- Films standards: 5-8 Mbps
- Séries TV: 3-5 Mbps

**Pour 720p**:
- Films: 3-6 Mbps
- Séries: 2-4 Mbps

**Calcul de taille**:
```
1080p @ 8 Mbps × 2h = ~7 GB par film
720p @ 4 Mbps × 2h = ~3.5 GB par film

Capacité 750GB:
- Films 1080p: ~100 films
- Films 720p: ~200 films
- Mix optimal: ~150 films
```

## 🎯 Logiciels Recommandés

### Lecteurs vidéo optimisés VAAPI

#### 1. MPV (recommandé)
```bash
# Installation
sudo zypper install mpv

# Configuration ~/.config/mpv/mpv.conf
hwdec=vaapi
vo=gpu
gpu-context=wayland
profile=gpu-hq
scale=ewa_lanczossharp
cscale=ewa_lanczossharp
```

#### 2. VLC (alternative)
```bash
sudo zypper install vlc

# Activer VAAPI dans VLC:
# Outils > Préférences > Entrée/Codecs
# Décodage accéléré par matériel: VA-API
```

### Organisation de bibliothèque

#### Jellyfin (serveur média local)
```bash
# Serveur média avec interface web élégante
sudo zypper install jellyfin

# Avantages:
# - Interface Netflix-like
# - Métadonnées automatiques (posters, synopsis)
# - Lecture dans navigateur
# - Gestion sous-titres
```

#### Kodi (alternative)
```bash
sudo zypper install kodi

# Centre média complet, interface TV
```

### Gestionnaires de téléchargement

#### Transmission (BitTorrent)
```bash
sudo zypper install transmission-gtk

# Léger, interface simple
# Télécharger directement dans /mnt/films/Downloads
```

#### qBittorrent (alternative riche)
```bash
sudo zypper install qbittorrent

# Plus de fonctionnalités, recherche intégrée
```

## 📂 Structure de dossiers recommandée

```
/mnt/films/
├── Films/
│   ├── Action/
│   ├── Comedie/
│   ├── Drame/
│   ├── SF/
│   └── ...
├── Series/
│   ├── NomSerie1/
│   │   ├── Saison 01/
│   │   ├── Saison 02/
│   │   └── ...
│   └── NomSerie2/
├── Documentaires/
├── Downloads/          # Zone de téléchargement temporaire
└── .jellyfin/         # Métadonnées (si Jellyfin)
```

## 🔍 Où trouver des films H.264 optimaux

### Sources légales gratuites
- **Archive.org**: Domaine public, classiques
- **YouTube**: Télécharger avec `yt-dlp` (format bestvideo[ext=mp4])
- **Bibliothèques**: Nombreuses proposent prêt numérique

### Vérifier le codec d'une vidéo
```bash
# Installer mediainfo
sudo zypper install mediainfo

# Analyser un fichier
mediainfo fichier.mp4 | grep -E "Format|Codec|Width|Height|Bit rate"

# Ou plus simple
ffprobe -hide_banner fichier.mp4 2>&1 | grep -E "Video|Audio"
```

### Convertir HEVC → H.264 (si nécessaire)
```bash
# Installer ffmpeg
sudo zypper install ffmpeg

# Conversion GPU-accélérée avec VAAPI
ffmpeg -vaapi_device /dev/dri/renderD128 -hwaccel vaapi \
  -i input.mkv \
  -vf 'format=nv12,hwupload' \
  -c:v h264_vaapi -b:v 8M \
  -c:a copy \
  output.mp4

# Ou conversion CPU (lent mais fonctionne toujours)
ffmpeg -i input.mkv \
  -c:v libx264 -preset medium -crf 23 \
  -c:a copy \
  output.mp4
```

## ⚡ Optimisations Lecture Vidéo

### Variables d'environnement (déjà configurées)
```bash
# Dans ~/.config/ponyo.env (déjà fait)
export LIBVA_DRIVER_NAME=r600
export MESA_LOADER_DRIVER_OVERRIDE=radeon
```

### Test de décodage VAAPI
```bash
# Installer outils VAAPI
sudo zypper install libva-utils

# Vérifier le support
vainfo

# Attendu:
# VAProfileH264High      : VAEntrypointVLD
# VAProfileH264Main      : VAEntrypointVLD
```

### Sous-titres optimisés
- **Format SRT** (`.srt`): Léger, universel
- **Format ASS/SSA**: Stylisés, plus gourmands
- Éviter les sous-titres PGS (Blu-ray) qui surchargent le CPU

## 🎛️ Configuration Firefox pour streaming local

Si vous utilisez Jellyfin/Plex via navigateur:

```javascript
// Fichier: ~/.mozilla/firefox/PROFILE/user.js
// (déjà partiellement configuré dans config/firefox-prefs.js)

// Forcer VAAPI dans Firefox
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.rdd-vpx.enabled", false);

// Optimiser cache vidéo
user_pref("media.cache_size", 512000);
user_pref("media.cache_readahead_limit", 120);
```

## 📊 Monitoring Performances Vidéo

### Avec MPV (afficher stats en direct)
Pendant la lecture, appuyer sur **`i`** puis **`2`** pour voir:
- Décodage matériel actif (vaapi)
- Dropped frames
- Bitrate

### Avec VLC
Outils > Informations sur les codecs > Statistiques

### Monitoring système pendant lecture
```bash
# Terminal 1: Lancer une vidéo
mpv /mnt/films/test.mp4

# Terminal 2: Observer les performances
watch -n 1 'grep "cpu MHz" /proc/cpuinfo | head -4 && echo && free -h'
```

## 🎯 Checklist Optimale

- [ ] Disque 750GB formaté en ext4
- [ ] Point de montage `/mnt/films` configuré
- [ ] Scheduler BFQ activé pour le HDD
- [ ] Montage automatique dans `/etc/fstab`
- [ ] MPV installé et configuré pour VAAPI
- [ ] VAAPI testé avec `vainfo`
- [ ] Structure de dossiers créée
- [ ] Client torrent installé (transmission/qbittorrent)
- [ ] Jellyfin installé (optionnel)
- [ ] Test de lecture vidéo H.264 1080p réussi

## 💡 Conseils Finaux

### Priorités de téléchargement
1. **Toujours privilégier H.264** sur H.265/HEVC
2. **1080p optimal**, 720p excellent aussi
3. Vérifier le bitrate (5-10 Mbps idéal)
4. Format MP4 ou MKV

### Économie d'énergie
- HDD se met en veille automatiquement après 20min d'inactivité
- Désactiver l'indexation (`chattr +C`)
- Utiliser `noatime` dans fstab (déjà configuré)

### Maintenance
```bash
# Vérifier santé du HDD
sudo smartctl -a /dev/sdX

# Défragmenter si besoin (rare sur ext4)
sudo e4defrag /mnt/films
```

## 🚀 Performances Attendues

Avec cette configuration:
- ✅ **1080p H.264 @ 8Mbps**: Fluide, 0% dropped frames
- ✅ **720p H.264**: Ultra-fluide
- ✅ **Multi-pistes audio**: Pas de problème
- ✅ **Sous-titres SRT**: Instantanés
- ⚠️ **1080p H.265**: Possible mais saccadé (CPU à 100%)
- ❌ **4K**: Impossible

**Ponyo = Station cinéma parfaite pour H.264 1080p ! 🎬✨**
