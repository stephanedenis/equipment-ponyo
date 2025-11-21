#!/bin/bash
# Script exemple pour télécharger des films légaux en H.264
# Ponyo - Station Cinéma Hors-Ligne

set -e

DESTINATION="/mnt/films/Films"

echo "╔═══════════════════════════════════════════════════════╗"
echo "║   📥 Téléchargement Films H.264 - Ponyo              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Vérifier que yt-dlp est installé
if ! command -v yt-dlp &> /dev/null; then
    echo "❌ yt-dlp non installé"
    echo "Installation: sudo zypper install yt-dlp"
    exit 1
fi

# Vérifier l'espace disque
AVAILABLE=$(df /mnt/films | tail -1 | awk '{print $4}')
echo "💾 Espace disponible: $(df -h /mnt/films | tail -1 | awk '{print $4}')"
echo ""

# Exemples d'URLs de films du domaine public sur YouTube
# Remplacer par vos propres URLs de films légaux
URLS=(
  # Exemple : Film du domaine public
  # "https://youtube.com/watch?v=XXXXX"
)

if [ ${#URLS[@]} -eq 0 ]; then
    echo "ℹ️  Aucune URL configurée dans le script."
    echo ""
    echo "📝 Pour utiliser ce script:"
    echo "1. Éditer: nano $0"
    echo "2. Ajouter des URLs YouTube de films légaux dans URLS=()"
    echo "3. Relancer: bash $0"
    echo ""
    echo "🔍 Sources légales recommandées:"
    echo "  • Archive.org (films domaine public)"
    echo "  • YouTube chaînes officielles gratuites"
    echo "  • Voir: docs/SOURCES_FILMS.md"
    exit 0
fi

# Télécharger chaque film
COUNT=0
TOTAL=${#URLS[@]}

for url in "${URLS[@]}"; do
  COUNT=$((COUNT + 1))
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📥 [$COUNT/$TOTAL] Téléchargement: $url"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Forcer H.264 (avc), max 1080p, format MP4
  yt-dlp \
    -f "bestvideo[vcodec^=avc][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]" \
    --merge-output-format mp4 \
    -o "$DESTINATION/%(title)s.%(ext)s" \
    --no-playlist \
    "$url"
  
  if [ $? -eq 0 ]; then
    echo "✅ Téléchargement réussi"
  else
    echo "❌ Erreur lors du téléchargement"
  fi
  echo ""
done

echo "╔═══════════════════════════════════════════════════════╗"
echo "║   🎉 Téléchargements terminés !                      ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "📂 Films dans: $DESTINATION"
echo ""
echo "🎬 Pour lire un film:"
echo "   mpv /mnt/films/Films/nom_du_film.mp4"
echo ""
echo "🔍 Vérifier codec:"
echo "   mediainfo /mnt/films/Films/nom_du_film.mp4 | grep Format"
echo ""
