# Contributing to Equipment Ponyo

Merci de votre intérêt pour améliorer Equipment Ponyo ! 🎉

## 🤝 Comment Contribuer

### Signaler un Bug

1. Vérifiez que le bug n'est pas déjà signalé dans [Issues](https://github.com/stephanedenis/equipment-ponyo/issues)
2. Créez une nouvelle issue avec:
   - Sortie de `scripts/audit-hardware.sh`
   - Description détaillée du problème
   - Étapes pour reproduire
   - Comportement attendu vs observé

### Proposer une Amélioration

1. Ouvrez une issue pour discuter de la fonctionnalité
2. Attendez validation avant de coder
3. Créez une Pull Request

### Soumettre une Pull Request

1. Fork le projet
2. Créez une branche: `git checkout -b feature/ma-fonctionnalite`
3. Commitez: `git commit -m 'Ajout fonctionnalité X'`
4. Push: `git push origin feature/ma-fonctionnalite`
5. Ouvrez une Pull Request

## 📝 Standards de Code

### Scripts Bash

- Utiliser `#!/bin/bash` (pas sh)
- Ajouter `set -e` pour arrêter sur erreur
- Commenter les sections importantes
- Tester sur openSUSE, Ubuntu, Fedora si possible

### Documentation

- Markdown standard (GitHub Flavored)
- Emojis pour clarté (modération)
- Exemples de commandes complets
- Français pour cohérence du projet

## 🧪 Tests

Avant de soumettre:

```bash
# Tester les scripts
bash scripts/audit-hardware.sh
bash scripts/verify-config.sh
bash scripts/benchmark.sh

# Vérifier pas d'erreurs shell
shellcheck scripts/*.sh  # si installé
```

## 🎯 Domaines de Contribution

### Prioritaire

- [ ] Tests sur autres HP Pavilion g series
- [ ] Support autres AMD A6/A8/A10
- [ ] Optimisations spécifiques par modèle CPU
- [ ] Benchmarks de référence

### Souhaité

- [ ] Support Arch Linux dans install-complete.sh
- [ ] Script de rollback des optimisations
- [ ] Dashboard web pour monitoring
- [ ] Tests automatisés

### Documentation

- [ ] Traduction anglaise
- [ ] Vidéos tutoriels
- [ ] Screenshots configurations
- [ ] Cas d'usage détaillés

## 📜 Licence

En contribuant, vous acceptez que vos contributions soient sous licence MIT.

## 🆘 Besoin d'Aide?

- Lisez [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Posez des questions dans Issues
- Consultez [MEMO.md](MEMO.md) pour références rapides

---

**Merci de rendre Ponyo encore meilleur !** 🐟
