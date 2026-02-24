# Standard library imports:
import sys

# Library imports:
from sage.all import *



def ruleCheck():
    pass

def isCohen():
    # Check if current orbit is too long? ie longer than factors of n
    # Current row can only have less than factors of n

    pass

def isomorphismCheck():
    pass

def verifyAxiom2(quandle, i, j):
    # Iterate through column and see if new value is repeated.
    pass

def validCheck(quandle, i, j) -> bool:
    v = quandle[i, j]

    # Axiom 2: Ensure operation is bijective (no repeating in columns)
    for c in range(0, n):
        # Matching element (ignoring our column)
        if c != i and v == quandle[c, j]:
                return False
    
    # Rule 1:

    # Rule 2:

    # Rule 3:

    return True

def verifyAxiom3(quandle) -> bool:
    for x in range(0, n):
        for y in range(0, n):
            for z in range(0, n):
                x_y = quandle[x, y] - 1
                result = quandle[x_y, z]

                x_z = quandle[x, z] - 1
                y_z = quandle[y, z] - 1

                if result != quandle[x_z, y_z]:
                    return False

    return True

def generate(quandle, i, j):
    # Base Case: Matrix is full
    if (i >= n): 
        # Add quandle to output list
        if verifyAxiom3(quandle):
            valid.append(quandle)
        return

    nextJ = (j + 1) % n
    nextI = i + (1 if (nextJ == 0) else 0) # If we've reached end of the row, go down to next row

    if quandle[i,j] != -1: # position i, j has already been filled in by axioms
        generate(quandle, nextI, nextJ)
        return

    for v in range(1, n + 1):
        newQuandle = Matrix(quandle)
        newQuandle[i, j] = v
        if validCheck(newQuandle, i, j): # Fill in and verify potential based on axioms
            generate(newQuandle, nextI, nextJ)
    
    return


if __name__ == '__main__':
    # Get n-value from user
    n = int(sys.argv[1])

    print(f"Generating all Quandles of order {n} ....")

    valid = list()

    # Axiom 1: Generate idempotency along diagonal:
    quandle = Matrix(ZZ, n, n, lambda i, j: i + 1 if i == j else -1)
    generate(quandle, 0, 0)
    
    for M in valid:
        print(M, "\n")