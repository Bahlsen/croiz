import base64
from pathlib import Path
p = Path('build/web/assets/AssetManifest.bin.json')
s = p.read_text().strip().strip('"')
raw = base64.b64decode(s)
# try to decode utf-8 and print
text = raw.decode('utf-8', errors='ignore')
out = Path('build/web/assets/AssetManifest.decoded.txt')
out.write_text(text)
print('wrote', out)