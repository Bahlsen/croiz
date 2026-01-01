
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

# Liste étendue de mots sur la Bretagne
WORDS_DATA = {
    'BRETAGNE': 'Région du Grand Ouest français',
    'RENNES': 'Capitale administrative régionale',
    'BREST': 'Port du Ponant',
    'VANNES': 'Préfecture du Morbihan',
    'QUIMPER': 'Capitale de la Cornouaille',
    'LORIENT': 'Ville aux 5 ports',
    'STMALO': 'La cité corsaire',
    'DINAN': 'Cité médiévale des Côtes-d\'Armor',
    'AURAY': 'Port de Saint-Goustan',
    'CARNAC': 'Site mégalithique mondialement connu',
    'REDON': 'Au carrefour des voies navigables',
    
    'ARMOR': 'La mer en breton',
    'ARGOAT': 'La terre/forêt en breton',
    'MORBIHAN': 'La petite mer',
    'FINISTERE': 'La fin de la terre',
    
    'CREPE': 'Fine et sucrée',
    'GALETTE': 'Au blé noir',
    'KIGHAARZ': 'Pot-au-feu breton',
    'FAR': 'Gâteau aux pruneaux',
    'KOUIGN': 'Gâteau (avec Amann = au beurre)',
    'BEURRE': 'Toujours salé ici !',
    'CIDRE': 'À boire dans une bolée',
    'CHOUCHEN': 'Hydromel breton',
    'HUITRES': 'Perles de Cancale ou Belon',
    
    'PHARE': 'Guide les marins',
    'BALISE': 'Marque le danger en mer',
    'AMER': 'Repère visuel sur la côte',
    'MENHIR': 'Pierre longue dressée',
    'DOLMEN': 'Table de pierre antique',
    
    'BINIOU': 'Cornemuse bretonne',
    'BOMBARDE': 'Hautbois breton puissant',
    'BAGAD': 'Ensemble musical breton',
    'FESTNOZ': 'Fête de nuit dansante',
    'CELTE': 'Origine culturelle',
    'DRAPEAU': 'Le Gwenn ha Du',
    'HERMINE': 'Symbole ducal',
    'TRISKELL': 'Symbole à trois branches',
    
    'ILE': 'Terre entourée d\'eau',
    'GROIX': 'L\'île aux grenats',
    'OUESSANT': 'L\'île la plus à l\'ouest',
    'BREHAT': 'L\'île aux fleurs',
    'BELLEILE': 'La bien nommée',
    
    'GRANIT': 'Roche rose de Ploumanac\'h',
    'ARDOISE': 'Couvre les toits bleutés',
    'AJONCS': 'Fleurs jaunes des landes',
    'BRUYERE': 'Fleur violette des landes',
    'HORTENSIA': 'Buisson fleuri emblématique',
    
    'PLUIE': 'Le crachin breton',
    'VENT': 'Souffle fort sur la côte',
    'MARFE': 'Cycle des eaux',
    'OCEAN': 'Borde la péninsule',
    'ABERS': 'Fjords bretons',
    
    'KORRIGAN': 'Lutin farceur',
    'ANKOU': 'Serviteur de la mort',
    'MERLIN': 'Enchanteur de Brocéliande',
    'VIVIANE': 'Fée du lac',
    
    'MARIN': 'Navigateur',
    'PECHEUR': 'Ramène le poisson',
    'VOILE': 'Sport nautique roi'
}

words = list(WORDS_DATA.keys())

metadata = {
    'title': 'La Bretagne',
    'author': 'Fred',
    'language': 'fr',
    'source_format': 'pycrossword',
    'theme': 'Bretagne',
    'difficulty': 3,
    'difficultyLabel': 'Moyen',
}

print(f"Generating optimized puzzle with {len(words)} words...")

# Try multiple generations to find the best density
best_puzzle = None
best_score = -1

# Configuration: smaller grid for higher density
TARGET_WIDTH = 13
TARGET_HEIGHT = 13

for i in range(10):  # Try 10 iterations
    try:
        # Vary seed implicitly or explicitly if supported
        puzzle = generate_puzzle_from_words(
            words=words,
            puzzle_id='bretagne-2024',
            metadata=metadata,
            max_width=TARGET_WIDTH,
            max_height=TARGET_HEIGHT,
            seed=i*100  # Try different seeds
        )
        
        # Calculate a "density score"
        # Score = number of placed words - (number of black cells / 10)
        # We want MORE words and FEWER black cells
        placed_words = len(puzzle.get('entries', []))
        
        # Count black cells
        black_cells = sum(1 for c in puzzle['cells'] if c.get('is_black'))
        total_cells = len(puzzle['cells'])
        
        score = placed_words * 10 - (black_cells / total_cells * 100)
        
        print(f"Gen {i}: {placed_words} words, {black_cells} black cells. Score: {score:.2f}")
        
        if score > best_score:
            best_score = score
            best_puzzle = puzzle
            
    except Exception as e:
        print(f"Gen {i} failed: {e}")

if best_puzzle:
    print(f"BEST RESULT: {len(best_puzzle.get('entries', []))} words")
    
    # Inject clues
    words_placed = 0
    missing_clues = []
    
    for entry in best_puzzle['entries']:
        word = entry.get('answer', '')
        if word in WORDS_DATA:
            entry['clue'] = WORDS_DATA[word]
        else:
            entry['clue'] = f"Définition manquante pour {word}"
            missing_clues.append(word)
        # Ensure ID format
        if 'id' not in entry:
            direction = entry['direction']
            number = entry['number']
            entry['id'] = f"{direction[0]}{number}"
            
        words_placed += 1
            
    if missing_clues:
        print(f"Missing clues for: {missing_clues}")

    output_dir = Path('../frontend/assets/data/generated')
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / 'bretagne-2024.json'

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(best_puzzle, f, indent=2, ensure_ascii=False)

    print(f"Saved to {output_path}")

else:
    print("Failed to generate any valid puzzle")
