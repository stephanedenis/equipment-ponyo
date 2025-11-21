# Checklist Configuration - Ponyo

Suivi étape par étape de la configuration système.

## ✅ Checklist Initiale

### Phase 1: Installation Base

- [ ] Distribution Linux installée
- [ ] Distribution: ______________
- [ ] Version: ______________
- [ ] Desktop: ______________
- [ ] Repo cloné: `git clone https://github.com/stephanedenis/equipment-ponyo.git`

### Phase 2: Audit Matériel

- [ ] Audit exécuté: `bash scripts/audit-hardware.sh`
- [ ] Fichier généré consulté dans `hardware/`
- [ ] SPECIFICATIONS.md complété avec infos réelles
- [ ] Configuration déterminée:
  - RAM: _____ GB
  - Stockage: HDD / SSD
  - CPU exact: AMD A6-_____
  - GPU: AMD Radeon _____

### Phase 3: Optimisations Automatiques

- [ ] Script optimisation exécuté: `sudo bash scripts/optimize-system.sh`
- [ ] Swappiness configuré
- [ ] I/O Scheduler configuré
- [ ] CPU Governor configuré
- [ ] TRIM activé (si SSD)

### Phase 4: Optimisations Manuelles

- [ ] Variables environnement GPU configurées
  - [ ] Copié: `cp config/env-template ~/.config/ponyo.env`
  - [ ] Ajouté à .bashrc
  - [ ] Rechargé: `source ~/.bashrc`

- [ ] sysctl optimisé (optionnel)
  - [ ] Copié: `sudo cp config/sysctl-ponyo.conf /etc/sysctl.d/99-ponyo.conf`
  - [ ] Appliqué: `sudo sysctl --system`

- [ ] ZRAM configuré (si RAM ≤4GB)
  - [ ] Installé
  - [ ] Service activé
  - [ ] Vérifié avec `zramctl`

### Phase 5: GPU/Multimédia

- [ ] Drivers Mesa installés
  - [ ] mesa-dri-drivers
  - [ ] libva-mesa-driver
  - [ ] mesa-vulkan-drivers

- [ ] VAAPI fonctionnel
  - [ ] `vainfo` fonctionne sans erreur
  - [ ] Driver détecté: ______________

- [ ] Firefox optimisé
  - [ ] Préférences about:config appliquées
  - [ ] Test vidéo YouTube 1080p OK
  - [ ] CPU usage <30% en lecture vidéo

### Phase 6: Batterie (si laptop)

- [ ] TLP installé
  - [ ] Service activé: `sudo systemctl enable --now tlp`
  - [ ] Statut vérifié: `sudo tlp-stat -s`

- [ ] Santé batterie vérifiée
  - [ ] Capacité: _____ %
  - [ ] État: ______________

### Phase 7: Tests et Validation

- [ ] Benchmark exécuté: `bash scripts/benchmark.sh`
- [ ] Résultats sauvegardés dans `benchmarks/`
- [ ] Monitoring testé: `bash scripts/monitor.sh`
- [ ] Températures normales (<85°C sous charge)

### Phase 8: Maintenance

- [ ] Maintenance exécutée: `sudo bash scripts/maintenance.sh`
- [ ] Cron optionnel configuré (hebdomadaire)

## 📊 Résultats Post-Configuration

### Performances

- **Boot**: _____ secondes
- **RAM utilisée (idle)**: _____ GB / _____ GB
- **CPU idle**: _____ °C
- **CPU load**: _____ °C
- **Benchmark CPU**: _____ events/sec
- **Benchmark disque**: _____ MB/s

### Fonctionnalités

- **VAAPI**: ✅ Fonctionne / ❌ Non configuré
- **Vulkan**: ✅ Fonctionne / ❌ Non configuré
- **TRIM**: ✅ Actif / ❌ N/A (HDD)
- **TLP**: ✅ Actif / ❌ N/A (desktop)

## 🎯 Optimisations Optionnelles Restantes

- [ ] ccache installé (si développement)
- [ ] Preload installé (si HDD)
- [ ] Flatpak/Snap configuré
- [ ] Timeshift/Snapper backups configurés

## 📝 Notes Personnelles

```
(Espace pour notes spécifiques à votre config)




```

---

**Date configuration**: ______________  
**Configuré par**: ______________  
**Distribution**: ______________
