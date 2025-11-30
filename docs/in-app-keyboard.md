# Clavier intégré (A–Z majuscules)

Ce document décrit l’intégration d’un clavier virtuel directement dans le jeu pour éviter l’ouverture du clavier système.

## Composants fournis

- `lib/widgets/virtual_keyboard.dart` : Clavier virtuel responsive A–Z avec Backspace (maintien accéléré), layouts AZERTY/QWERTY, lettres supplémentaires (`extraLetters`), accessibilité Semantics.
- `lib/widgets/in_game_text_input.dart` : Champ de saisie qui utilise le clavier virtuel et bloque le clavier OS.

## Utilisation rapide

```dart
import 'package:flutter/material.dart';
import 'widgets/in_game_text_input.dart';

class GuessInput extends StatefulWidget {
  const GuessInput({super.key});

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InGameTextInput(
      controller: controller,
      hintText: 'VOTRE MOT',
      maxLength: 8,
      onSubmitted: (value) {
        // TODO: valider la proposition
        debugPrint('Submit: $value');
      },
      // Optionnel: restreindre les lettres utilisables
      // enabledLetters: {'A','B','C', ...},
      // Optionnel: layout personnalisé (AZERTY par défaut)
      // keyboardLayout: [
      //   ['A','Z','E','R','T','Y','U','I','O','P'],
      //   ['Q','S','D','F','G','H','J','K','L'],
      //   ['W','X','C','V','B','N','M'],
      // ],
      // extraLetters: ['É','À','Ç'], // rangée supplémentaire
    );
  }
}
```

## Points clés d’intégration

- Le `TextField` est `readOnly: true` et `showCursor: true` pour afficher le curseur sans clavier OS.
- Toutes les entrées sont mises en majuscule et limitées à A–Z.
- `maxLength` permet de limiter la longueur de la saisie.
- `enabledLetters` permet de griser certaines lettres (ex: lettres déjà utilisées).
- La seule touche spéciale est `VirtualKeyboard.backspaceToken` (effacement + maintien accéléré).

## Accessibilité & UX

- Clavier responsive: largeur calculée selon l’espace disponible (poids Backspace=2).
- Haptique + clic sonore sur chaque frappe activables (`enableFeedback`).
- Backspace: accélération progressive (≈260ms → 110ms → 55ms). 
- Semantics: chaque touche est annoncée (`Lettre X`, `Effacer`).
- Flash visuel: cases modifiées brièvement sur grille (échelle + couleur). 

## Limitations actuelles

- Pas encore d’auto-adaptation de la hauteur sur rotation/tablette (peut se faire via un paramètre supplémentaire).
- Pas de gestion contextuelle dynamique (désactiver Backspace lorsqu’aucune sélection). À gérer côté appelant.
