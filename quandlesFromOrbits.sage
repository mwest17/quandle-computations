from sage.all import *
# import time
# import multiprocessing as mp
# import argparse
import os
# import copy

from generateQuandles import * 


def generateByOrbits(quandle, i, j, n, valid, orbitSize):
    # Base Case: We've reached end of matrix (ie no more positions to fill)
    if (i >= n): 
        orbits = findOrbits(quandle)

        # Find orbit with value that should be in it
        orb = None
        for o in orbits:
            if i - 1 in o:
                orb = o.copy()
                break

        # Ensure it is the correct size
        if len(orb) != orbitSize:
            return


        # Verify complete table satisfies axiom 3
        if verifyAxiom3(quandle, n):

            # # NEED TO FIX. Probably has to do with rules
            # for r in range(0, n):
            #     for c in range(0, n):
            #         if not verifyAxiom2(quandle, r, c):
            #             return 
                    
            for q in valid: # Compare with already found to see if duplicate
                if isomorphismCheck(q, quandle):
                    return
            valid.append(Matrix(quandle))
        return

    nextJ = (j + 1) % n
    nextI = i + (1 if (nextJ == 0) else 0) # If we've reached end of the row, go down to next row


    if quandle[i,j] != -1: # position i, j has already been filled in by axioms
        generateByOrbits(quandle, nextI, nextJ, n, valid, orbitSize)
        return

    filledIn = list()
    
    # print(i, " ", j)
    # print(range(i - i % orbitSize, (i - i % orbitSize) + orbitSize))
    # print()

    for v in range(i - i % orbitSize, (i - i % orbitSize) + orbitSize):
        # Make a list of (i,j) indecies where new values are added
        quandle[i, j] = v
        # print(f"At row {i}, col {j}, trying {v}")

        if validCheck(quandle, i, j, filledIn, n): # Fill in and verify potential based on axioms
            # Ensure previous orbit is connected
            if i % orbitSize == 0 and i != 0:
                # Finished an orbit, so it should be connected
                orbits = findOrbits(quandle)

                # Find orbit with value that should be in it
                orb = None
                for o in orbits:
                    if i - 1 in o:
                        orb = o.copy()
                        break

                # Ensure it is the correct size
                if len(orb) != orbitSize:
                    quandle[i, j] = -1
                    return
            
            generateByOrbits(quandle, nextI, nextJ, n, valid, orbitSize)

        while filledIn:
            r, c = filledIn.pop()
            quandle[r, c] = -1
    quandle[i, j] = -1
    
    return



for n in range(6, 10):
    print(f"Orbits of size {n}")
    orbits = list()

    o = list()
    for i in range(0, 2*n):
        if i % n == 0 and i != 0:
            orbits.append(o)
            o = list()

        o.append([i + 1 for _ in range(0, n)])
    orbits.append(o)


    # orbits.append([[1, 1], [2, 2]])
    # orbits.append([[3, 3], [4, 4]])
    # orbits.append([[5, 5], [6, 6]])

    # orbits.append([[1, 1, 2], [2, 2, 1], [3, 3, 3]])
    # orbits.append([[4, 4, 5], [5, 5, 4], [6, 6, 6]])
    # orbits.append([[7, 7, 8], [8, 8, 7], [9, 9, 9]])
    # orbits.append([[10, 10, 11], [11, 11, 10], [12, 12, 12]])
    # orbits.append([[13, 13, 14], [14, 14, 13], [15, 15, 15]])

    # orbits.append([[1, 3, 2], [3, 2, 1], [2, 1, 3]])
    # orbits.append([[4, 6, 5], [6, 5, 4], [5, 4, 6]])
    # orbits.append([[7, 9, 8], [9, 8, 7], [8, 7, 9]])

    # orbits.append([[1, 1, 2], [2, 2, 1], [3, 3, 3]])
    # orbits.append([[4, 6, 5], [6, 5, 4], [5, 4, 6]])

    # orbits.append([[1, 1, 1, 1], [2, 2, 2, 3], [3, 3, 3, 2], [4, 4, 4, 4]])

    # orbits.append([[1, 1, 2, 2], [2, 2, 1, 1], [4, 4, 3, 3], [3, 3, 4, 4]])
    # orbits.append([[5, 5, 6, 6], [6, 6, 5, 5], [8, 8, 7, 7], [7, 7, 8, 8]])

    # orbits.append([[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3], [4, 4, 4, 4]])
    # orbits.append([[5, 5, 5, 5], [6, 6, 6, 6], [7, 7, 7, 7], [8, 8, 8, 8]])

    # orbits.append([[1, 1, 1], [2, 2, 2], [3, 3, 3]])
    # orbits.append([[4, 4, 4], [5, 5, 5], [6, 6, 6]])
    # orbits.append([[7, 7, 7], [8, 8, 8], [9, 9, 9]])
    # orbits.append([[10, 10, 10], [11, 11, 11], [12, 12, 12]])


    orbitSize = len(orbits[0])
    n = len(orbits) * len(orbits[0])

    quandle = Matrix(ZZ, n, n, lambda i, j: i if i == j else -1)

    for orbit in orbits:
        for i in range(len(orbit)):
            row = orbit[i][i]
            for j in range(len(orbit[i])):
                quandle[row - 1, orbit[0][0] - 1 + j] = orbit[i][j] - 1


    ones = Matrix(n, n, lambda i, j: 1)
    # quandle = quandle - ones
    # print(quandle)

    valid = list()
    generateByOrbits(quandle, 0, 0, n, valid, orbitSize) # Doesn't respect that I want the rows of the orbits to be only those values

    for q in valid:
        print(q + ones)
        if isCohen(q):
            print("Is Cohen")
        print()
    
    print()