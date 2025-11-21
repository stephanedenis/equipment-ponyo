# 🎬 Sources de Films Légaux et Gratuits en H.264

Guide pour trouver des films optimisés pour Ponyo (H.264 1080p/720p).

## 🎯 Critères Essentiels

Avant de télécharger, **TOUJOURS vérifier** :
- ✅ **Codec vidéo : H.264** (ou AVC, x264)
- ✅ **Résolution : 1080p ou 720p**
- ✅ **Bitrate : 3-10 Mbps**
- ❌ **PAS H.265/HEVC** (lag garanti)
- ❌ **PAS 4K** (impossible)

## 📚 Sources Légales et Gratuites

### 1. Archive.org (Internet Archive) ⭐⭐⭐⭐⭐

**Le trésor du domaine public**

🔗 https://archive.org/details/movies

**Contenu** :
- Milliers de films classiques du domaine public
- Documentaires historiques
- Films muets, films noirs, westerns
- Dessins animés classiques
- Actualités anciennes

**Formats disponibles** :
- MP4 H.264 (souvent disponible)
- Résolutions diverses (chercher 720p/1080p)

**Comment chercher** :
```
Site: archive.org/details/movies
Filtres: Format > "MPEG4" ou "h.264"
Trier par: Views / Downloads
```

**Exemples de collections** :
- Classic Cinema
- Film Noir
- Silent Films
- Prelinger Archives (documentaires vintage)
- Feature Films

**Téléchargement** :
1. Sélectionner un film
2. Cliquer "SHOW ALL" (formats disponibles)
3. Choisir "MPEG4" ou "h.264 720p/1080p"
4. Clic droit > Enregistrer sous

### 2. YouTube (avec yt-dlp) ⭐⭐⭐⭐

**Films légaux et gratuits sur YouTube**

🔗 https://www.youtube.com

**Chaînes officielles gratuites** :
- **Popcornflix** : Films récents gratuits
- **Paramount Vault** : Classiques Paramount
- **Timeless Classic Movies** : Domaine public
- **Public Domain Movies** : Classiques
- **Cult Cinema Classics** : Films cultes

**Installation yt-dlp** :
```bash
# OpenSUSE
sudo zypper install yt-dlp

# Ou via pip
pip install --user yt-dlp
```

**Télécharger en H.264 optimal** :
```bash
# Format optimal pour Ponyo (1080p H.264)
yt-dlp -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]" \
  --merge-output-format mp4 \
  -o "/mnt/films/Films/%(title)s.%(ext)s" \
  "URL_YOUTUBE"

# Exemple : Film en 720p maximum
yt-dlp -f "bestvideo[ext=mp4][height<=720]+bestaudio[ext=m4a]/best[ext=mp4]" \
  --merge-output-format mp4 \
  -o "/mnt/films/Films/Comedie/%(title)s.%(ext)s" \
  "https://youtube.com/watch?v=XXXXX"
```

**Forcer H.264 (éviter VP9)** :
```bash
# Format qui garantit H.264
yt-dlp -f "bestvideo[vcodec^=avc]+bestaudio/best" \
  --merge-output-format mp4 \
  -o "/mnt/films/Films/%(title)s.%(ext)s" \
  "URL"
```

**Lister les formats disponibles** :
```bash
yt-dlp -F "URL_YOUTUBE"
# Chercher les lignes avec "avc1" (= H.264)
```

### 3. Wikimedia Commons ⭐⭐⭐

**Films historiques et documentaires**

🔗 https://commons.wikimedia.org/wiki/Category:Video_files

**Contenu** :
- Documentaires éducatifs
- Films historiques
- Actualités d'archives
- Animations libres

**Format** : Souvent WebM, mais certains en MP4 H.264

### 4. Bibliothèques Numériques ⭐⭐⭐⭐

**Services légaux français**

**Bibliothèque Nationale de France (BNF)** :
- 🔗 https://gallica.bnf.fr
- Films d'archives, documentaires
- Domaine public français

**Europeana** :
- 🔗 https://www.europeana.eu
- Archives européennes
- Films historiques

**Médiathèque Numérique** :
- Via votre bibliothèque municipale
- Prêt de films numériques (légal)
- Vérifier avec votre carte de bibliothèque

### 5. Distributeurs Indépendants Gratuits ⭐⭐⭐

**Plate-formes de cinéma indépendant**

**Vimeo** :
- 🔗 https://vimeo.com
- Films indépendants gratuits
- Section "Staff Picks" (sélection)
- Chercher "Creative Commons"

**Téléchargement Vimeo (si autorisé)** :
```bash
yt-dlp "URL_VIMEO" -o "/mnt/films/Films/%(title)s.%(ext)s"
```

### 6. Plex / Tubi (Streaming Gratuit Légal) ⭐⭐⭐

**Streaming avec publicités (légal)**

Ces services nécessitent une connexion internet :
- **Tubi** : Films et séries gratuits avec pub
- **Plex** : Section "Free Movies"
- **Pluto TV** : Chaînes et films gratuits

⚠️ **Note** : Streaming uniquement, pas de téléchargement direct

### 7. Creative Commons Films ⭐⭐⭐⭐

**Films sous licence libre**

🔗 https://creativecommons.org/about/program-areas/arts-culture/arts-culture-resources/films/

**Exemples célèbres** :
- **"Big Buck Bunny"** (court-métrage 3D)
- **"Sintel"** (animation Blender)
- **"Tears of Steel"** (sci-fi)
- **"Elephants Dream"** (animation)

**Téléchargement direct** :
- Blender Foundation : https://studio.blender.org/films/

## 🔍 Comment Vérifier le Codec

### Méthode 1 : Avant téléchargement

Sur YouTube avec yt-dlp :
```bash
yt-dlp -F "URL"
# Chercher "avc1" = H.264 ✅
# Éviter "vp9" = VP9 ❌
# Éviter "hev1" = H.265 ❌
```

### Méthode 2 : Après téléchargement

Avec mediainfo :
```bash
mediainfo fichier.mp4 | grep -E "Format|Codec"

# Attendu :
# Format : AVC ou H.264 ✅
# Codec ID : avc1 ✅
```

Avec ffprobe :
```bash
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name fichier.mp4

# Attendu : codec_name=h264 ✅
```

## 📊 Tailles et Bitrates Recommandés

### Films 1080p (1920×1080)
- **Bitrate optimal** : 5-10 Mbps
- **Taille** : 2-8 GB pour 2h
- **Codec** : H.264 High Profile

### Films 720p (1280×720)
- **Bitrate optimal** : 3-6 Mbps
- **Taille** : 1-4 GB pour 2h
- **Codec** : H.264 Main/High Profile

### Séries TV (épisodes 45min)
- **720p** : 500MB - 1.5GB
- **1080p** : 1-3GB

## ⚠️ Ce qu'il faut ÉVITER

### Sites de torrent illégaux
- ❌ Illégal dans la plupart des pays
- ❌ Risques de virus/malware
- ❌ Qualité variable, souvent H.265

### Formats incompatibles Ponyo
- ❌ **H.265/HEVC** : Lag assuré (CPU uniquement)
- ❌ **VP9** : Non supporté matériellement
- ❌ **AV1** : GPU trop ancien
- ❌ **4K/2160p** : Impossible à décoder

### Conversions à éviter
- ❌ Télécharger en H.265 puis convertir (perte qualité)
- ✅ Toujours chercher la source H.264 directement

## 🛠️ Outils de Téléchargement

### yt-dlp (Recommandé)
```bash
# Installation
sudo zypper install yt-dlp

# Mise à jour
sudo zypper update yt-dlp

# Télécharger playlist YouTube
yt-dlp -f "bestvideo[ext=mp4][height<=1080]+bestaudio" \
  --merge-output-format mp4 \
  -o "/mnt/films/Films/%(playlist)s/%(title)s.%(ext)s" \
  "URL_PLAYLIST"
```

### aria2c (Téléchargements rapides)
```bash
# Installation
sudo zypper install aria2

# Télécharger avec aria2
aria2c -x 16 -s 16 -d /mnt/films/Downloads "URL_DIRECT"
```

### wget (Simple et efficace)
```bash
# Télécharger un fichier
wget -P /mnt/films/Downloads "URL_DIRECT_MP4"
```

## 📁 Organisation Recommandée

```
/mnt/films/
├── Films/
│   ├── Action/
│   │   └── Film_Action_1080p_H264.mp4
│   ├── Classiques/
│   │   └── Citizen_Kane_720p.mp4
│   ├── Documentaires/
│   │   └── Nature_Documentary.mp4
│   └── Animation/
│       └── Big_Buck_Bunny_1080p.mp4
├── Series/
│   └── NomSerie/
│       ├── S01E01.mp4
│       └── S01E02.mp4
└── Downloads/
    └── temp/
```

## 🎯 Script de Téléchargement Automatique

Créez un script pour télécharger plusieurs films :

```bash
#!/bin/bash
# download-films.sh

DESTINATION="/mnt/films/Films"

# Liste d'URLs YouTube (films gratuits légaux)
URLS=(
  "https://youtube.com/watch?v=XXXXX"
  "https://youtube.com/watch?v=YYYYY"
  "https://youtube.com/watch?v=ZZZZZ"
)

for url in "${URLS[@]}"; do
  echo "📥 Téléchargement: $url"
  yt-dlp -f "bestvideo[vcodec^=avc][height<=1080]+bestaudio/best" \
    --merge-output-format mp4 \
    -o "$DESTINATION/%(title)s.%(ext)s" \
    "$url"
  echo "✅ Terminé"
  echo ""
done

echo "🎉 Tous les téléchargements terminés !"
```

## 🧪 Tester la Lecture

Après téléchargement, tester immédiatement :

```bash
# Lire avec MPV (décodage GPU automatique)
mpv /mnt/films/Films/test.mp4

# Pendant la lecture, appuyer sur "i" puis "2"
# Vérifier: "hwdec: vaapi" = décodage GPU ✅
```

## 💡 Astuces

### Chercher des films spécifiques sur Archive.org
```bash
# Utiliser la recherche avancée
Site: archive.org
Mots-clés: "film noir" OR "western" format:MPEG4
```

### Télécharger sous-titres avec yt-dlp
```bash
yt-dlp --write-sub --sub-lang fr,en \
  -f "bestvideo[ext=mp4]+bestaudio" \
  --merge-output-format mp4 \
  "URL"
```

### Vérifier l'espace disque
```bash
# Avant téléchargement
df -h /mnt/films

# Taille d'un dossier
du -sh /mnt/films/Films/Action
```

## 📊 Résumé des Meilleures Sources

| Source | Légalité | Quantité | Qualité H.264 | Difficulté |
|--------|----------|----------|---------------|------------|
| **Archive.org** | ✅ 100% | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Facile |
| **YouTube (légal)** | ✅ 100% | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Facile |
| **Bibliothèques** | ✅ 100% | ⭐⭐⭐ | ⭐⭐⭐⭐ | Moyen |
| **Wikimedia** | ✅ 100% | ⭐⭐ | ⭐⭐⭐ | Facile |
| **Creative Commons** | ✅ 100% | ⭐⭐ | ⭐⭐⭐⭐⭐ | Facile |

## 🎬 Recommandations Finales

1. **Commencer par Archive.org** : Domaine public, 100% légal, facile
2. **Utiliser yt-dlp** pour YouTube (chaînes officielles)
3. **Toujours vérifier le codec** avant de télécharger
4. **Privilégier 720p** si hésitation (plus petit, très fluide)
5. **Tester immédiatement** chaque film téléchargé

## ⚖️ Note Légale

Ce guide présente **uniquement des sources légales et gratuites**. 

- ✅ Domaine public : Films dont les droits sont expirés
- ✅ Creative Commons : Films sous licence libre
- ✅ Distribution officielle : Chaînes YouTube légales
- ❌ Piratage : Illégal, non couvert par ce guide

**Respectez toujours les droits d'auteur et les lois de votre pays.**

---

🚀 **Bon visionnage sur Ponyo !**

Avec le décodage GPU H.264, vous profiterez d'une lecture fluide en 1080p ! 🎬✨
