# Guide Démarrage Rapide - Ponyo (5 minutes) ⚡

Ce guide vous permet de configurer et optimiser Ponyo en **moins de 5 minutes**.

## 📋 Prérequis

- Ponyo démarré avec une distribution Linux installée
- Connexion internet active
- Accès sudo/root

## 🚀 Installation Express

### Étape 1: Cloner ce repo (30 secondes)

```bash
cd ~
git clone https://github.com/stephanedenis/equipment-ponyo.git
cd equipment-ponyo
```

### Étape 2: Audit matériel (1 minute)

```bash
# Exécuter audit automatique
bash scripts/audit-hardware.sh

# Ou avec sudo pour détails complets
sudo bash scripts/audit-hardware.sh
```

Les résultats sont sauvegardés dans `hardware/system-audit-YYYYMMDD-HHMMSS.md`

### Étape 3: Optimisation automatique (2 minutes)

```bash
# Appliquer toutes les optimisations
sudo bash scripts/optimize-system.sh
```

Ce script configure automatiquement:
- ✅ Swappiness adapté à votre RAM
- ✅ I/O Scheduler optimal (HDD/SSD)
- ✅ CPU Governor
- ✅ TRIM si SSD
- ✅ Recommandations ZRAM et VAAPI

### Étape 4: Configuration manuelle rapide (1 minute)

#### A. Variables environnement GPU AMD

```bash
# Copier template
cp config/env-template ~/.config/ponyo.env

# Éditer si nécessaire (optionnel)
nano ~/.config/ponyo.env

# Activer
echo '[ -f ~/.config/ponyo.env ] && source ~/.config/ponyo.env' >> ~/.bashrc
source ~/.bashrc
```

#### B. Optimisations système (optionnel)

```bash
# Copier config sysctl
sudo cp config/sysctl-ponyo.conf /etc/sysctl.d/99-ponyo.conf
sudo sysctl --system
```

## ✅ Vérification

### Test accélération GPU (VAAPI)

```bash
# Installer si manquant
sudo zypper install libva-mesa-driver vainfo   # openSUSE
# sudo apt install libva-mesa-driver vainfo    # Ubuntu
# sudo dnf install libva-mesa-driver           # Fedora

# Tester
vainfo
```

**Succès si**: affiche "VA-API version" et liste des profils

### Monitoring en direct

```bash
bash scripts/monitor.sh
```

Affiche CPU, RAM, température, fréquences en temps réel. `Ctrl+C` pour quitter.

## 🎯 Optimisations selon RAM

Votre script a détecté votre RAM et appliqué automatiquement, mais voici le détail:

### Si RAM ≤ 4GB
```bash
# ZRAM obligatoire (compression RAM)
# openSUSE
sudo zypper install systemd-zram-service
sudo systemctl enable --now zram

# Ubuntu 22.04+
sudo apt install zram-config

# Fedora
sudo dnf install zram-generator
```

### Si RAM 4-8GB
- ZRAM recommandé mais optionnel
- Desktop: préférer XFCE, LXQt ou KDE léger

### Si RAM ≥ 8GB
- Configuration optimale
- Tous desktops supportés

## 🔥 Firefox Optimisé (1 minute)

1. Ouvrir Firefox
2. Aller à `about:config`
3. Ouvrir `config/firefox-prefs.js` dans un éditeur
4. Copier-coller les préférences une par une

**Test**: Ouvrir YouTube 4K → CPU usage doit être <30% si VAAPI fonctionne

## 📊 Benchmark (optionnel)

```bash
# Test complet performances
bash scripts/benchmark.sh

# Résultats dans: benchmarks/benchmark-YYYYMMDD-HHMMSS.md
```

## 🔧 Maintenance Régulière

```bash
# Nettoyage automatique (1x/semaine)
sudo bash scripts/maintenance.sh
```

Nettoie:
- Cache paquets
- Journaux anciens (>7 jours)
- Fichiers temporaires
- Thumbnails
- Exécute TRIM si SSD

## 📚 Prochaines Étapes

Une fois la configuration de base terminée:

1. **Documentation complète**: Lire `system/OPTIMISATIONS_AMD.md`
2. **Troubleshooting**: Voir `docs/TROUBLESHOOTING.md` si problèmes
3. **Distribution**: Comparer dans `docs/DISTRIBUTIONS.md`

## ⚡ One-Liner Complet

Pour les experts, tout en une commande:

```bash
cd ~ && \
git clone https://github.com/stephanedenis/equipment-ponyo.git && \
cd equipment-ponyo && \
sudo bash scripts/optimize-system.sh && \
cp config/env-template ~/.config/ponyo.env && \
echo '[ -f ~/.config/ponyo.env ] && source ~/.config/ponyo.env' >> ~/.bashrc && \
source ~/.bashrc
```

## 🆘 Aide

- **Problèmes**: Voir `docs/TROUBLESHOOTING.md`
- **Questions**: Ouvrir une issue GitHub
- **Audit**: `bash scripts/audit-hardware.sh`

---

✅ **Configuration terminée en 5 minutes !** Profitez de Ponyo optimisé. 🚀
