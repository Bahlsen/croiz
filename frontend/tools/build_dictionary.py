import json
import os
import re
from datetime import datetime

def extract_from_clues(clues_list, target_set):
    if isinstance(clues_list, list):
        for item in clues_list:
            if isinstance(item, dict) and 'answer' in item:
                answer = item['answer']
                if isinstance(answer, str):
                    # Sanitize: only ASCII letters A-Z
                    clean = re.sub(r'[^A-Z]', '', answer.upper())
                    if clean:
                        target_set.add(clean)

def main():
    data_dir = 'assets/data'
    target_file = 'assets/dictionaries/fill_en.txt'

    if not os.path.exists(data_dir):
        print(f'Error: Could not find {data_dir} directory.')
        return

    print(f'Scanning {data_dir} for puzzles...')
    print(f'Target dictionary: {target_file}')

    unique_words = set()
    processed_count = 0
    error_count = 0

    for root, dirs, files in os.walk(data_dir):
        for file in files:
            if file.endswith('.json'):
                if 'puzzles_index' in file or 'puzzles.json' in file:
                    continue

                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    
                    if isinstance(data, dict) and 'clues' in data:
                        clues = data['clues']
                        if isinstance(clues, dict):
                            extract_from_clues(clues.get('across'), unique_words)
                            extract_from_clues(clues.get('down'), unique_words)
                    
                    processed_count += 1
                    if processed_count % 500 == 0:
                        print(f'Processed {processed_count} puzzles. Unique words found: {len(unique_words)}', end='\r')

                except Exception:
                    error_count += 1

    print(f'\n\n--- Extraction Complete ---')
    print(f'Total puzzles processed: {processed_count}')
    print(f'Errors/Skipped: {error_count}')
    print(f'Total unique words found: {len(unique_words)}')

    if not unique_words:
        print('Warning: No words found. Dictionary will not be updated.')
        return

    print('Sorting and writing to file...')
    sorted_words = sorted([w for w in unique_words if len(w) >= 2])
    
    os.makedirs(os.path.dirname(target_file), exist_ok=True)
    with open(target_file, 'w', encoding='utf-8') as f:
        f.write('# Auto-generated dictionary from local puzzle database\n')
        f.write('# Source: assets/data\n')
        f.write(f'# Count: {len(unique_words)} words\n')
        f.write(f'# Date: {datetime.now().isoformat()}\n')
        for word in sorted_words:
            f.write(word + '\n')

    print(f'Success! Dictionary saved to {target_file}')
    print(f'File size: {os.path.getsize(target_file) / 1024:.2f} KB')

if __name__ == "__main__":
    main()
