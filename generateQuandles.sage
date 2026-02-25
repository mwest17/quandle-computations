# Standard library imports:
import sys
import argparse
from itertools import permutations

# Library imports:
from sage.all import *



def ruleCheck():
    pass


# Returns True if two quandles are isomorphic
def isomorphismCheck(quandle1, quandle2):
    # Can't be isomorphic if sizes don't match
    if quandle1.nrows() != quandle2.nrows() or quandle1.ncols() != quandle2.ncols():
        return False

    values1 = list(set(quandle1.list()))
    values2 = list(set(quandle2.list()))
    
    # print(f"values1: {values1}")
    # print(f"values2: {values2}")

    # Get all permutations from 1 set to the other
    # That will be all bijections from 1 set to the other. Also n! :((((((

    # Need to try every mapping between values1 and values2
    # For every possible bijection between quandles
    for perm in permutations(values2):
        # Make a dict of mappings of index values
        # Find value in diagonal. That is index value. Then permute rows/columns based on that mapping
        mapping = dict(zip(values1, perm))
        
        # apply permutation to imageQuandle
        # Need to reorder columns
        # Iso check logic is not working right
        imageQuandle = Matrix([[mapping[x] for x in row] for row in quandle1])

        if imageQuandle == quandle2:
            # If we have a bijective mapping, we're good
            return True

    return False


def findOrbits(quandle):
    orbits = list()

    for row in range(0, n):
        # find orbit with our row in it
        orbit = set()

        for col in range(0,n):
            v = quandle[row, col]
            if v != -1:
                orbit.add(v)

        # See if orbit has new elements to add to existing orbit
        new = True
        for existingOrbit in orbits:
            if orbit & existingOrbit:
                existingOrbit = orbit | existingOrbit
                new = False

        if new:
            orbits.append(orbit)

    return orbits


def isCohen(quandle):
    orbits = findOrbits(quandle)

    if len(orbits) < 2:
        # Must have at least 2 orbits
        # print("Not enough orbits")
        return False

    # Add a check for orbit sizes?? - Might save some time
    # Might also be negligable since this is so asymptoptically large

    subQuandles = list()

    for orbit in orbits:
        # Remove rows and columns of orbit
        keep = [i for i in range(quandle.nrows()) if (i + 1) not in orbit]
        subQ = quandle.matrix_from_rows(keep).matrix_from_columns(keep)
        subQuandles.append(subQ)

    # print("SubQuandles: ")
    # for q in subQuandles:
    #     print(q, "\n")

    # Check if all are isomorphic
    for i in range (0, len(subQuandles) - 1):
        if not isomorphismCheck(subQuandles[i], subQuandles[i+1]):
            return False

    return True


def cohenRules():
    # Check if current orbit is too long? ie longer than factors of n
    # Current row can only have less than factors of n

    pass


def verifyAxiom2(quandle, i, j):
    # Iterate through column and see if new value is repeated.
    pass


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


def generate(quandle, i, j):
    # Base Case: Matrix is full
    if (i >= n): 
        # Add quandle to output list
        if verifyAxiom3(quandle):
            for q in valid:
                if False: #isomorphismCheck(q, quandle):
                    return
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
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-s", "--save",
        action="store_true",
        help="Save quandles to file"
    )

    parser.add_argument(
        "-n", "--order",
        required=True,
        help="Order of quandle to generate"
    )
    
    args = parser.parse_args()

    n = int(args.order)

    print(f"Generating all Quandles of order {n} ....")

    valid = list()

    # Axiom 1: Generate idempotency along diagonal:
    quandle = Matrix(ZZ, n, n, lambda i, j: i + 1 if i == j else -1)
    generate(quandle, 0, 0)
    
    for M in valid:
        if True: #isCohen(M):
            print(findOrbits(M))
            print(M, "\n")

    print(f"There are {len(valid)} quandles of order {n}")

    if args.save:
        # Save to file logic here
        pass 

    # M1 = matrix([[1, 2],
    #             [1, 2]])
    # M2 = matrix([[3, 4],
    #             [6, 4]])
    # print(isomorphismCheck(M1, M2))