import requests
import os
import re
from datetime import datetime

def main():
    print('--- Fetching Dictionaries for Other Languages ---')

    base_url = 'https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018'
    targets = {
        'fr': f'{base_url}/fr/fr_full.txt',
        'es': f'{base_url}/es/es_full.txt',
        'de': f'{base_url}/de/de_full.txt',
        'it': f'{base_url}/it/it_full.txt',
        'pt': f'{base_url}/pt_br/pt_br_full.txt',
        'ru': f'{base_url}/ru/ru_full.txt',
        'uk': f'{base_url}/uk/uk_full.txt',
    }

    output_dir = 'assets/dictionaries'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    valid_word_exp = re.compile(r'^[A-ZÀ-ÖØ-ÞĀ-ŽА-ЯҐЄІЇ]+$')
    digit_symbol_exp = re.compile(r'[0-9\\._,;:"!¡?¿\(\)\[\]\{\}]')

    for lang, url in targets.items():
        output_file = os.path.join(output_dir, f'fill_{lang}.txt')
        print(f'\nProcessing {lang} from {url}...')

        try:
            response = requests.get(url)
            if response.status_code != 200:
                print(f'Error: Failed to download {lang} (Status {response.status_code})')
                continue

            print('  Parsing and Cleaning...')
            unique_words = set()
            lines = response.text.split('\n')

            for line in lines:
                line = line.strip()
                if not line:
                    continue

                parts = line.split(' ')
                if not parts:
                    continue

                word = parts[0].upper()

                if len(word) < 2:
                    continue

                if digit_symbol_exp.search(word):
                    continue

                if valid_word_exp.match(word):
                    unique_words.add(word)

            if not unique_words:
                print(f'  Warning: No valid words found for {lang}')
                continue

            print(f'  Derived {len(unique_words)} unique words.')
            print(f'  Writing to {output_file}...')

            sorted_list = sorted(list(unique_words))
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write('# Auto-fetched dictionary\n')
                f.write(f'# Source: {url}\n')
                f.write(f'# Date: {datetime.now().isoformat()}\n')
                for word in sorted_list:
                    f.write(word + '\n')

            print(f'  Success! {os.path.getsize(output_file) / 1024:.1f} KB')

        except Exception as e:
            print(f'  Error processing {lang}: {e}')

    print('\nAll done.')

if __name__ == "__main__":
    main()
