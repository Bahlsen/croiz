# Système de Succès (Achievements)

Ce document décrit l'implémentation du système de succès dans l'application Croiz.

## Vue d'ensemble

Le système de succès est basé sur une architecture événementielle utilisant Riverpod. Il permet de détecter l'accomplissement de conditions (ex: premier puzzle complété) et d'afficher des notifications pop-up non intrusives, tout en gérant intelligemment les conflits avec les publicités interstitielles.

## Architecture

### 1. Détection (`AchievementService`)
Service responsable de vérifier les conditions de déblocage.
- **Méthode principale** : `checkAchievements(UserStats stats, PuzzleStat lastPuzzle)`
- Appelé après chaque fin de partie par `StatisticsService`.
- Sauvegarde les nouveaux succès en base de données de manière persistante.

### 2. Diffusion (`AchievementNotifier`)
Un `stream` Riverpod qui diffuse les IDs des succès nouvellement débloqués.
- Agit comme un bus d'événements.
- Les écouteurs s'abonnent à ce provider pour réagir aux déblocages.

### 3. Affichage (`AchievementListener`)
Un widget qui se place au sommet de l'arbre des widgets (dans le `builder` de `MaterialApp`).
- **Rôle** : Écoute le `AchievementNotifier` et affiche les pop-ups visuels.
- **Gestion des Pubs** : Intègre une logique "Wait for Ad" pour éviter d'afficher des succès par-dessus ou dessous une publicité interstitielle.
  - Vérifie `MonetizationService.isAdShowing`.
  - Attend la fin de la pub via `waitForAdDismissed()`.
- **Overlay** : Utilise `rootNavigatorKey` pour injecter les notifications directement dans l'Overlay du Navigator racine, garantissant qu'elles sont toujours visibles.

## Règles Spéciales

Certains succès ont des conditions strictes concernant l'utilisation des aides de jeu ("Reveal Word", "Reveal Puzzle", "Validation") :
- **Speed Demon** : Terminer en moins de 3 minutes **SANS** utiliser aucune aide ni révélation.
- **Perfect Puzzle** : Terminer avec 100% de précision **SANS** utiliser aucune aide ni révélation.

### 4. Navigation et Context (`rootNavigatorKey`)
Pour garantir l'accès au bon `Overlay` (surtout après une pub ou des dialogues), nous utilisons une `GlobalKey<NavigatorState>` définie dans `app_router.dart`.
- Cette clé est passée au `GoRouter`.
- `AchievementListener` l'utilise pour récupérer le contexte d'overlay sans dépendre de son propre contexte (qui est au-dessus du Navigator).

## Flux de données

1. **Fin de partie** : L'utilisateur termine un puzzle.
2. **Calcul** : `StatisticsService` met à jour les stats et appelle `AchievementService`.
3. **Déblocage** : Si un succès est nouveau, il est sauvegardé et envoyé au `AchievementNotifier`.
4. **Réception** : `AchievementListener` reçoit l'événement.
5. **Attente Pub** : Si une pub est détectée (`isAdShowing`), le listener se met en pause.
6. **Affichage** : Une fois la voie libre, le listener récupère l'overlay via `rootNavigatorKey` et injecte `AchievementNotification` animée.

## Ajouter un nouveau succès

1. **Définition** : Ajouter l'entrée dans l'enum `AchievementId` (`lib/features/statistics/models/achievement.dart`).
2. **Logique** : Ajouter la condition de vérification dans `AchievementService.checkAchievements`.
3. **UI** : Ajouter l'icône et les textes dans `AchievementNotification` et les fichiers `.arb` de localisation.

## Tests

Les tests se trouvent dans `test/widget/features/statistics/achievement_listener_test.dart`.
Ils utilisent une approche isolée :
- Test du `AchievementNotifier` pour vérifier la diffusion.
- Test du widget d'affichage séparément pour éviter les timeouts d'animation.
- Utilisation de `FakeMonetizationService` pour simuler le comportement des pubs.
