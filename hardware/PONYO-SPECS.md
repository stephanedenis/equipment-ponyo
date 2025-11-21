# Spécifications Réelles - Ponyo

**Date audit**: 21 novembre 2025

## 🖥️ CPU

**Modèle**: AMD A6-3420M APU with Radeon HD Graphics
- **Architecture**: Llano (K10.5)
- **Famille**: 18
- **Cores**: 4 (physiques)
- **Threads**: 4 (pas d'hyperthreading)
- **Fréquence**: 
  - Minimum: 800 MHz
  - Maximum: 1500 MHz (Turbo Core)
- **BogoMIPS**: 2994.59
- **TDP**: ~35W

### Features CPU
- ✅ SSE, SSE2, SSE4a
- ✅ 3DNow! / 3DNow!+ extended
- ✅ AMD-V (virtualisation)
- ✅ Cool'n'Quiet (gestion énergie)
- ✅ Turbo Core

## 💾 RAM

**Capacité totale**: 15 GB
- **Type**: DDR3 (probable)
- **Utilisation actuelle**: 5.3 GB / 15 GB
- **Disponible**: 9.8 GB

**Verdict**: ✅ **Excellente configuration RAM** - Largement suffisant pour multitâche

## 🎮 GPU

**Modèle**: AMD Radeon HD 6520G (Sumo)
- **Architecture**: VLIW5 (TeraScale 2)
- **Génération**: 6xxx series
- **Type**: APU intégré
- **Support**:
  - ✅ OpenGL 4.2
  - ✅ DirectX 11
  - ✅ UVD3 (décodage vidéo matériel H.264)
  - ⚠️ Pas de HEVC/VP9 natif (ancien GPU)

**Driver**: Mesa radeon (pas radeonsi - génération ancienne)

## 💿 Stockage

**À vérifier manuellement**:
```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,ROTA,FSTYPE
```

## 🐧 Système

**Distribution**: openSUSE Tumbleweed (détecté via environnement)
**Desktop**: À déterminer (KDE/GNOME/XFCE/autre)

## ⚙️ Optimisations Recommandées Spécifiques

### RAM (15 GB - Excellente)
- ✅ **Swappiness**: 10 (RAM largement suffisante)
- ✅ **ZRAM**: **NON nécessaire** (RAM >8GB)
- ✅ **Desktop**: Tous supportés (même KDE Plasma)
- ✅ **Multitâche**: Excellente capacité

### CPU (AMD A6-3420M)
- ✅ **Governor**: schedutil ou ondemand
- ✅ **Turbo Core**: Activer pour performances
- ✅ **Compilation**: ccache + `-j4` (4 cores)

### GPU (Radeon HD 6520G)
- ⚠️ **Driver**: `radeon` (PAS radeonsi)
- ⚠️ **VAAPI**: Limité à H.264 (pas HEVC/VP9)
- ✅ **Variables**:
  ```bash
  export MESA_LOADER_DRIVER_OVERRIDE=radeon  # Ancien driver
  export LIBVA_DRIVER_NAME=r600              # Pas radeonsi
  ```

### Performances Attendues

**Excellent pour**:
- ✅ Bureautique intensive (LibreOffice, multiple docs)
- ✅ Développement (VS Code, multiples projets)
- ✅ Navigation web (dizaines d'onglets possible)
- ✅ Multitâche (15GB RAM permet beaucoup)
- ✅ Vidéo 1080p H.264 (décodage matériel)

**Limites**:
- ⚠️ Vidéo 4K (GPU ancien)
- ⚠️ Gaming moderne (GPU intégré génération 2011)
- ⚠️ HEVC/VP9 hardware decode (non supporté)

## 🎯 Configuration Optimale

Avec cette configuration (15GB RAM, 4 cores), Ponyo est **bien au-dessus** des attentes initiales !

### Priorités
1. ✅ Swappiness = 10
2. ✅ Driver radeon (pas radeonsi)
3. ✅ Pas besoin de ZRAM
4. ✅ Desktop au choix (même KDE OK)
5. ✅ H.264 hardware decode

## 📊 Comparaison vs Attentes

| Élément | Attendu | Réel | Verdict |
|---------|---------|------|---------|
| RAM | 4-8 GB | **15 GB** | 🎉 Excellent |
| Cores | 2-4 | **4** | ✅ Bon |
| GPU Gen | Inconnue | HD 6520G (2011) | ✅ Ancien mais utilisable |
| Fréquence | 1.8-2.5 GHz | 0.8-1.5 GHz | ⚠️ Plus bas mais 4 cores |

**Conclusion**: Configuration très capable pour usage bureautique/développement intensif !
