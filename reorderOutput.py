from sage.all import *
from generateQuandles import * 
import re

def readCohen(filename):
    cohen = list()
    matrix_rows = list()
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()
            if re.match(r'^\[\s*\d+(?:\s+\d+)*\s*\]$', line):
                row = list(map(int, line.strip('[]').split()))
                matrix_rows.append(row)

            if line == "" and matrix_rows:
                cohen.append(Matrix(matrix_rows))
                matrix_rows = []
    return cohen[:]

def reorderByOrbit(quandle):
    orbits = findOrbits(quandle)
    swapIndex = 0

    for o in orbits:
        o = list(o)
        o.sort()

        for e in o:
            index = 0
            for i in range(quandle.nrows()):
                if quandle[i, i] == e:
                    index = i

            quandle.swap_rows(swapIndex, index)
            quandle.swap_columns(swapIndex, index)
            swapIndex += 1
    return



if __name__ == "__main__":
    for i in range (3, 10 + 1):

        cohen = readCohen(f"output/cohen{i}.txt")
        
        
        for c in cohen:
            reorderByOrbit(c)
            # print(c, "\n")

        saveCohen(f"output/ordered/ordered_cohen{i}.txt", cohen)

    