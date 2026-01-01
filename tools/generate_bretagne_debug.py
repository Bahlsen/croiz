
import json
import sys
import os
from pathlib import Path

# Add current directory to path so imports work
sys.path.append(os.getcwd())

try:
    from generate_puzzle import generate_puzzle_from_words
except ImportError:
    # Try adding tools directory if running from root
    sys.path.append(os.path.join(os.getcwd(), 'tools'))
    from tools.generate_puzzle import generate_puzzle_from_words

words = [
    'BRETAGNE', 'RENNES', 'BREST', 'VANNES', 'ARMOR', 'ARGOAT', 
    'CREPE', 'CIDRE', 'GALETTE', 'PHARE', 'MENHIR', 'DOLMEN',
    'GRANIT', 'GOELAND', 'MOUETTE', 'MARINS', 'TEMPETE', 'FALAISE',
    'QUIMPER', 'LORIENT', 'BIGOUDEN', 'KOUIGN'
]

metadata = {
    'title': 'La Bretagne',
    'author': 'Fred',
    'language': 'fr',
    'source_format': 'pycrossword',
    'theme': 'Bretagne',
    'difficulty': 2,
    'difficultyLabel': 'Moyen'
}


# Dictionnaire des indices
CLUES = {
    'BRETAGNE': 'Région du Grand Ouest français',
    'RENNES': 'Préfecture de la région',
    'BREST': 'Grand port militaire du Finistère',
    'VANNES': 'Préfecture du Morbihan aux remparts célèbres',
    'ARMOR': 'Le pays de la mer en breton',
    'ARGOAT': 'La Bretagne intérieure (terre/forêt)',
    'CREPE': 'Spécialité sucrée fine et ronde',
    'CIDRE': 'Boisson pétillante à base de pommes',
    'GALETTE': 'Spécialité au sarrasin (blé noir)',
    'PHARE': 'Sentinelle des côtes guidant les navires',
    'MENHIR': 'Pierre longue dressée par les peuples anciens',
    'DOLMEN': 'Table de pierre néolithique',
    'GRANIT': 'Roche rose ou grise emblématique de la côte',
    'GOELAND': 'Grand oiseau marin au cri caractéristique',
    'MOUETTE': 'Oiseau blanc du bord de mer, plus petit que le goéland',
    'MARINS': 'Ceux qui travaillent sur les flots',
    'TEMPETE': 'Grosse colère de l\'océan',
    'FALAISE': 'Mur de roche tombant dans la mer',
    'QUIMPER': 'Capitale de la Cornouaille connue pour sa faïence',
    'LORIENT': 'Ville du festival Interceltique',
    'BIGOUDEN': 'Pays célèbre pour la haute coiffe de ses femmes',
    'KOUIGN': 'Gâteau en breton (souvent suivi de "Amann")'
}

print(f"Generating puzzle with {len(words)} words...")

try:
    puzzle = generate_puzzle_from_words(
        words=words,
        puzzle_id='bretagne-2024',
        metadata=metadata,
        max_width=15,
        max_height=15
    )
    
    # Inject clues into entries
    words_placed = 0
    if 'entries' in puzzle:
        for entry in puzzle['entries']:
            word = entry.get('answer', '')
            if word in CLUES:
                entry['clue'] = CLUES[word]
            else:
                entry['clue'] = f"Définition manquante pour {word}"
            words_placed += 1
            
    print(f"Generated: {puzzle.get('cols')}x{puzzle.get('rows')} grid with {words_placed} words")

    output_dir = Path('../frontend/assets/data/generated')
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / 'bretagne-2024.json'

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(puzzle, f, indent=2, ensure_ascii=False)

    print(f"Saved to {output_path}")
    
except Exception as e:
    import traceback
    traceback.print_exc()
    print(f"Error: {e}")
