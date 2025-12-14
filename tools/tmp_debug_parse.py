from tools.xd_to_canonical import parse_xd
import json
xd='''Rebus: 1=HEART 2=DIAMOND

1#2
'''
print(json.dumps(parse_xd(xd), ensure_ascii=False, indent=2))
