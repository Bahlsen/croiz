import json
import os
import time
import requests
from typing import List, Dict, Set

# --- CONFIGURATION ---
DATA_DIR = 'assets/data'
DICT_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
DICT_PATH = 'assets/dictionaries/words_alpha.txt'

# --- DATA ---
EXPERT_KNOWLEDGE = {
    'ONALEASH': [2, 1, 5],
    'ONAROLL': [2, 1, 4],
    'ONATEAR': [2, 1, 4],
    'ONATILT': [2, 1, 4],
    'ONEDGE': [2, 4],
    'INASEC': [2, 1, 3],
    'INAJAM': [2, 1, 3],
    'INAHUFF': [2, 1, 4],
    'INARUT': [2, 1, 3],
    'INAFOG': [2, 1, 3],
    'INADATZ': [2, 1, 4],
    'INTHESWIM': [2, 3, 4],
    'INTHENUDE': [2, 3, 4],
    'COOLBEANS': [4, 5],
    'SEALTEAM': [4, 4],
    'AIRBASE': [3, 4],
    'STANDIN': [5, 2],
    'YOADRIAN': [2, 6],
    'TRYME': [3, 2],
    'DELAYPEDAL': [5, 5],
    'TENHUT': [3, 3],
    'MIXIN': [3, 2],
    'IMOUTIE': [2, 5],
    'OUTOF': [3, 2],
    'STAYAT': [4, 2],
    'HEWHOMUSTNOTBENAMED': [2, 3, 4, 3, 2, 5],
    'NOTBENAMED': [3, 7],
    'HEWHOMUST': [2, 3, 4],
    'NEWYORK': [3, 4],
    'LOSANGELES': [3, 7],
    'SANFRAN': [3, 4],
    'ELONMUSK': [4, 4],
    'BILLGATES': [4, 5],
    'LADYGAGA': [4, 4],
    'COUPDETAT': [4, 2, 4],
    'VISAVIS': [3, 1, 3],
    'HOTDOG': [3, 3],
    'MAKESOUT': [5, 3],
    'STEPONIT': [4, 2, 2],
    'SEETO': [3, 2],
    'IFNOT': [2, 3],
}

PROTECTED_SINGLE_WORDS = {
    'ASAHI', 'PENSKE', 'KEEBLER', 'ESTEE', 'ELMO', 'GRETAS', 'GRETEL', 'STEVES', 'ETCH', 'ALES', 'AVEC', 'LIMO',
    'JAKE', 'EMMA', 'SAPS', 'WHITE', 'BHUTAN', 'BABAS', 'CELEB', 'GIRDS', 'NISEI', 'CARETS', 'ANODE', 'FICTION',
    'ORBIT', 'KLINE', 'NETS', 'TESTY', 'ELKS', 'ELENA', 'DIANA', 'TOBE', 'ALBERT', 'ROBERT', 'EDWARD', 'ALFRED',
    'ALVIN', 'ALICE', 'ALAN', 'ALANA', 'ALEX', 'ALEXA', 'ALEXIS', 'ALISON', 'ALINE', 'ALONDRA', 'INAS', 'INET',
    'TRINI', 'OMNIA', 'FANTA', 'SANCTI', 'COREA', 'ACCRA', 'OAHU', 'LARAM', 'TRIM', 'SELL', 'GRAVY', 'LENT',
    'NBC', 'ROSE', 'DRAW', 'EMIT', 'ISADORA', 'PREMISE', 'POT', 'NASH', 'HOT', 'NINES', 'HERB', 'USED', 'TIMED',
    'METEORS', 'ORAN', 'SAGE', 'ONCE', 'ALDO', 'INRE', 'INCA', 'ASKS', 'ALSO', 'ALOE', 'ALOT', 'AFEW', 'ABIT',
    'ONLY', 'EVEN', 'SOME', 'MANY', 'HERE', 'THERE', 'WHEN', 'WHAT', 'WHOA', 'WHAM', 'ALIE', 'ELIE', 'ANNE',
    'ANNA', 'AMIE', 'AMII', 'ENOS', 'EROS', 'ERAS', 'ETAS', 'ETES', 'LEES', 'ALAS', 'ARIA', 'AREA', 'ORAL',
    'IDOL', 'IDEA', 'IRON', 'IRIS', 'ICON', 'ITEM', 'INCH', 'INTO', 'IOTA', 'INANE', 'INPUT', 'INNER', 'INDEX',
    'INDIA', 'INERT', 'INFER', 'INFRA', 'INGOT', 'INLAY', 'INLET', 'INSET', 'INTER', 'INTRA', 'INURE', 'INVOX',
    'ASSET', 'ASIAN', 'ASIDE', 'ASPIE', 'ASSAY', 'ASTER', 'ASTIR', 'ASTRO', 'ASYLUM', 'ASLEEP', 'ASSERT',
    'ASSIGN', 'ASSIST', 'ASSORT', 'ASSUME', 'ASSURE', 'ASTERN', 'ASTUTE', 'ASTRAY', 'ASUNDER', 'ESTATE',
    'ESTHER', 'ESTIMATE', 'ESTRANGE', 'ESTABLISHED', 'ASAHIS'
}

COMMON_WORDS = {
    'THE', 'BE', 'TO', 'OF', 'AND', 'A', 'IN', 'THAT', 'HAVE', 'I', 'IT', 'FOR', 'NOT', 'ON', 'WITH', 'HE', 'AS', 'YOU', 'DO', 'AT',
    'THIS', 'BUT', 'HIS', 'BY', 'FROM', 'THEY', 'WE', 'SAY', 'HER', 'SHE', 'OR', 'AN', 'WILL', 'MY', 'ONE', 'ALL', 'WOULD', 'THERE',
    'WHAT', 'SO', 'UP', 'OUT', 'IF', 'ABOUT', 'WHO', 'GET', 'WHICH', 'GO', 'ME', 'WHEN', 'MAKE', 'CAN', 'LIKE', 'TIME', 'NO', 'JUST',
    'HIM', 'KNOW', 'TAKE', 'INTO', 'YEAR', 'YOUR', 'GOOD', 'SOME', 'COULD', 'THEM', 'SEE', 'OTHER', 'THAN', 'THEN', 'NOW', 'LOOK',
    'ONLY', 'COME', 'ITS', 'OVER', 'THINK', 'ALSO', 'BACK', 'AFTER', 'USE', 'TWO', 'HOW', 'OUR', 'WORK', 'FIRST', 'WELL', 'WAY',
    'EVEN', 'NEW', 'WANT', 'ANY', 'THESE', 'GIVE', 'DAY', 'MOST', 'US', 'ETA', 'ELI', 'ALI', 'ERA', 'ALE', 'LEE', 'ANA', 'AMA'
}

MEGA_DICT = set()

def load_dictionary():
    if not os.path.exists(DICT_PATH):
        print(f"Downloading dictionary to {DICT_PATH}...")
        os.makedirs(os.path.dirname(DICT_PATH), exist_ok=True)
        response = requests.get(DICT_URL)
        with open(DICT_PATH, 'wb') as f:
            f.write(response.content)
    
    with open(DICT_PATH, 'r') as f:
        for line in f:
            word = line.strip().upper()
            if word:
                MEGA_DICT.add(word)

def segment(answer: str, clue: str) -> List[str]:
    if not answer:
        return []
    
    clue_lower = clue.lower()
    
    is_phrase_clue = (
        'phrase' in clue_lower or 'saying' in clue_lower or 
        'being ' in clue_lower or clue_lower.startswith('with ') or 
        clue_lower.startswith('to ') or clue_lower.startswith('a ') or
        clue_lower.startswith('an ') or clue_lower.startswith('the ') or
        ', say' in clue_lower or 'expression' in clue_lower or
        'words' in clue_lower or '"' in clue_lower or
        clue_lower.startswith('"') or clue_lower.endswith('"') or
        '!"' in clue_lower or '... or' in clue_lower
    )

    is_proper_entity_clue = (
        'actor' in clue_lower or 'actress' in clue_lower or
        'director' in clue_lower or 'coach' in clue_lower or
        'player' in clue_lower or 'singer' in clue_lower or
        'author' in clue_lower or 'writer' in clue_lower or
        'statesman' in clue_lower or 'senator' in clue_lower or
        'brand' in clue_lower or 'port' in clue_lower or
        'city' in clue_lower or 'river' in clue_lower or
        'island' in clue_lower or 'capital' in clue_lower or
        'activist' in clue_lower or 'name' in clue_lower or
        'surname' in clue_lower or 'role' in clue_lower or
        'starred' in clue_lower or 'composer' in clue_lower or
        'lat.' in clue_lower or 'span.' in clue_lower or 'latin' in clue_lower
    )

    if answer in PROTECTED_SINGLE_WORDS:
        if answer == 'TOBE' and is_phrase_clue and not is_proper_entity_clue:
            return ['TO', 'BE']
        if answer == 'ABIT' and is_phrase_clue:
            return ['A', 'BIT']
        if answer == 'ALOT' and is_phrase_clue:
            return ['A', 'LOT']
        if answer == 'AFEW' and is_phrase_clue:
            return ['A', 'FEW']
        if answer == 'DOIT' and is_phrase_clue:
            return ['DO', 'IT']
        return [answer]

    if answer in EXPERT_KNOWLEDGE:
        lengths = EXPERT_KNOWLEDGE[answer]
        segs = []
        start = 0
        for length in lengths:
            segs.append(answer[start:start+length])
            start += length
        return segs

    if len(answer) <= 4:
        if not is_phrase_clue or is_proper_entity_clue:
            return [answer]

    if answer.endswith(('A', 'I', 'O', 'E')):
        if not is_phrase_clue and not answer.startswith(('A', 'I')):
            return [answer]

    if len(answer) >= 4 and answer in MEGA_DICT:
        if not is_phrase_clue:
            return [answer]

    n = len(answer)
    min_words = [100] * (n + 1)
    parent = [-1] * (n + 1)
    min_words[0] = 0

    for i in range(1, n + 1):
        for j in range(i):
            word = answer[j:i]
            is_valid = False
            if word in COMMON_WORDS:
                is_valid = True
            elif len(word) >= 4 and word in MEGA_DICT:
                is_valid = True
            elif word == 'I' or word == 'A':
                is_valid = True
            
            if is_valid:
                if min_words[j] + 1 < min_words[i]:
                    min_words[i] = min_words[j] + 1
                    parent[i] = j

    if min_words[n] > 10:
        return [answer]

    res = []
    curr = n
    while curr > 0:
        prev = parent[curr]
        res.append(answer[prev:curr])
        curr = prev
    
    segments = res[::-1]

    if len(segments) > 1:
        if is_proper_entity_clue:
            return [answer]
        
        if len(segments[-1]) == 1 and segments[-1] not in ('A', 'I'):
            return [answer]
        if len(segments[-1]) == 1 and not is_phrase_clue:
            return [answer]

        all_common = all(s in COMMON_WORDS or s in ('A', 'I') for s in segments)
        if not is_phrase_clue and not all_common:
            return [answer]

    if any(len(s) == 1 and s not in ('A', 'I') for s in segments):
        return [answer]

    return segments

def main():
    start_time = time.time()
    print("Building Knowledge Base...")
    load_dictionary()

    puzzle_files = []
    for root, dirs, files in os.walk(DATA_DIR):
        for file in files:
            if file.endswith('.json') and 'puzzles.json' not in file:
                puzzle_files.append(os.path.join(root, file))

    print(f"Auditing {len(puzzle_files)} puzzles...")
    modified_count = 0
    processed_count = 0

    for file_path in puzzle_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = json.load(f)
            
            modified = False
            entries = content.get('entries', [])
            
            for entry in entries:
                answer = entry.get('answer')
                clue = str(entry.get('clue', '')).lower()
                
                if not answer or len(answer) <= 3:
                    if 'enumeration' in entry:
                        del entry['enumeration']
                        modified = True
                    continue

                segments = segment(answer, clue)
                
                if len(segments) > 1:
                    enum_str = ','.join(str(len(s)) for s in segments)
                    if entry.get('enumeration') != enum_str:
                        entry['enumeration'] = enum_str
                        modified = True
                else:
                    if 'enumeration' in entry:
                        del entry['enumeration']
                        modified = True

            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(content, f, indent=2)
                modified_count += 1

            processed_count += 1
            if processed_count % 1000 == 0:
                print(f"Progress: {processed_count} files...")

        except Exception as e:
            if 'puzzles_index' not in file_path:
                print(f"Error in {file_path}: {e}")

    elapsed = time.time() - start_time
    print(f"Migration Complete. Modified {modified_count} files in {elapsed:.1f}s.")

if __name__ == "__main__":
    main()
