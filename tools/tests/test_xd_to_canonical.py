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
    # rebus digits in this grid appear at positions 0 and 2
    cell0 = cells[0]
    cell2 = cells[2]
    assert cell0.get('rebus') == 'HEART'
    assert cell2.get('rebus') == 'DIAMOND'


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
    # for newline separated rebus, check left-most cell contains the rebus
    cells = p['cells']
    assert cells[0].get('rebus') == 'HEART'


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
    # if clue contains explicit '~ ANSWER', prefer that answer over the grid-derived solution
    assert a1[0]['answer'] == 'ANSWER'
