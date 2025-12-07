import json
from tools.xd_to_canonical import parse_xd


def test_rebus_parsing_space_separated():
    xd = """
Rebus: 1=HEART 2=DIAMOND

1#2
"""
    p = parse_xd(xd)
    # grid should be 1 row, 3 cols
    assert p['rows'] == 1
    assert p['cols'] == 3
    cells = p['cells']
    # middle cell should be rebus 'HEART' represented by single-letter solution
    cell = cells[0 * p['cols'] + 1]
    assert cell.get('rebus') == 'HEART'
    assert isinstance(cell.get('solution'), str) and len(cell.get('solution')) == 1


def test_rebus_parsing_newline_separated():
    xd = """
Rebus:
1=HEART
2=DIAMOND

1#2
"""
    p = parse_xd(xd)
    assert p['rows'] == 1
    assert p['cols'] == 3
    cell = p['cells'][1]
    assert cell.get('rebus') == 'HEART'


def test_clue_with_tilde_answer():
    xd = """
Title: Test

ABC#DEF

A1. Clue text ~ ANSWER
D1. Down clue ~ DOWNER
"""
    p = parse_xd(xd)
    # should have entries parsed
    entries = p['entries']
    # find across entry number 1
    a1 = [e for e in entries if e['id'].startswith('a') and e['number'] == 1]
    assert len(a1) == 1
    assert a1[0]['answer'] == 'ANSWER'
