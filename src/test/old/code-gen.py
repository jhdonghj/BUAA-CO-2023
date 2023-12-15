from random import *

# add, sub, ori, lw, sw, beq, lui, nop
"""
ADD 
SUB
ORI
LW
SW
BEQ
LUI
NOP
"""

registers = {
    'zero': 0,   'at': 1,   'v0': 2,   'v1': 3,
    'a0': 4,   'a1': 5,   'a2': 6,   'a3': 7,
    't0': 8,   't1': 9,   't2': 10,  't3': 11,
    't4': 12,  't5': 13,  't6': 14,  't7': 15,
    's0': 16,  's1': 17,  's2': 18,  's3': 19,
    's4': 20,  's5': 21,  's6': 22,  's7': 23,
    't8': 24,  't9': 25,  'k0': 26,  'k1': 27,
    'gp': 28,  'sp': 29,  'fp': 30,  'ra': 31
}

# reg: 2 - 25
regL, regR = 4, 25
def getReg():
    return randint(regL, regR)
def getImm():
    return randint(0, 2**16)
def lineGen():
    line = 0
    while 1:
        yield line
        line += 1
line = lineGen()
pos = 0
def posGen():
    global pos
    while 1:
        yield pos
        pos += 4
addr = posGen()

def add():
    print(f'L{next(line)}: add ${getReg()}, ${getReg()}, ${getReg()}')
def sub():
    print(f'L{next(line)}: sub ${getReg()}, ${getReg()}, ${getReg()}')
def ori():
    print(f'L{next(line)}: ori ${getReg()}, ${getReg()}, {getImm()}')
def lw():
    for i in range(regL, regR + 1):
        print(f'L{next(line)}: lw ${i}, {randint(0, pos // 4) * 4}($0)')
def sw():
    for i in range(regL, regR + 1):
        print(f'L{next(line)}: sw ${i}, {next(addr)}($0)')
def beq():
    nowLine = next(line)
    print(f'L{nowLine}: beq ${getReg()}, ${getReg()}, L{randint(1, 10) + nowLine}')
def lui():
    print(f'L{next(line)}: lui ${getReg()}, {getImm()}')
def nop():
    print(f'L{next(line)}: nop')

instrs_beg = [add, sub, ori, beq, lui, nop]
instrs_all = [add, sub, ori, lw, sw, beq, lui, nop]
instrs_end = [add, sub, ori, lw, sw, lui, nop]

ops = 100
for i in range(ops):
    choice(instrs_beg)()
    if i % 20 == 19:
        sw()
        lw()
sw()
