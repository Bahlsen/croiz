---
description: Opérations courantes de développement Flutter (auto-exécution)
---

# Workflow de développement Flutter

Ce workflow contient les opérations courantes de développement Flutter qui s'exécutent automatiquement.

// turbo-all

## Étapes

### 1. Formater le code Dart
```bash
cd frontend
dart format .
```

### 2. Appliquer les corrections automatiques
```bash
cd frontend
dart fix --apply
```

### 3. Analyser le code
```bash
cd frontend
flutter analyze
```

### 4. Exécuter tous les tests
```bash
cd frontend
flutter test --no-pub
```

### 5. Exécuter les tests avec couverture
```bash
cd frontend
flutter test --coverage --no-pub
```

### 6. Filtrer les erreurs de tests (PowerShell)
```powershell
cd frontend
flutter test --no-pub 2>&1 | Select-String -Pattern "FAIL", "Error", "Exception" -Context 2, 5 | Select-Object -First 100
```

### 7. Nettoyer le projet
```bash
cd frontend
flutter clean
```

### 8. Récupérer les dépendances
```bash
cd frontend
flutter pub get
```

### 9. Mettre à jour les dépendances
```bash
cd frontend
flutter pub upgrade
```

### 10. Vérifier les dépendances obsolètes
```bash
cd frontend
flutter pub outdated
```

### 11. Construire l'APK de debug
```bash
cd frontend
flutter build apk --debug
```

### 12. Construire l'APK de release
```bash
cd frontend
flutter build apk --release
```

## Notes

- Toutes ces commandes s'exécutent automatiquement grâce à l'annotation `// turbo-all`
- Le répertoire de travail est `frontend` car c'est la racine du projet Flutter
- Les tests utilisent `--no-pub` pour éviter de récupérer les dépendances à chaque fois
