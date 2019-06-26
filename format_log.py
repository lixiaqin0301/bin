#!/usr/bin/env python3
import sys

fin = open(sys.argv[1], 'r')
fout = open(sys.argv[1] + '.formated', 'w')
content = []
for line in fin:
    inquote = False
    insquarebrackets = 0
    ls = []
    for c in line.split():
        if len(ls) == 1 and ls[0] == '#Fields:':
            ls[0] = ls[0] + ' ' + c
        elif len(ls) == 1 and c == '1/1':
            ls[0] = '#Fields:'
        elif inquote or insquarebrackets > 0:
            ls[-1] = ls[-1] + ' ' + c
        else:
            ls.append(c)
        if (c.count('"') - c.count('\\"')) % 2 == 1:
            inquote = not inquote
        insquarebrackets = insquarebrackets + c.count('[') - c.count(']')
        if insquarebrackets < 0:
            insquarebrackets = 0
    content.append(ls)

colwide = [0] * 1000
for ls in content:
    for i in range(len(ls)):
        if len(ls[i]) > colwide[i]:
            colwide[i] = len(ls[i])

for ls in content:
    for i in range(len(ls)):
        fout.write(ls[i].ljust(colwide[i] + 1))
    fout.write('\n')
