# Standard library imports:
import argparse
from itertools import permutations
import time

# Library imports:
from sage.all import *



# Returns True if two quandles are isomorphic
def isomorphismCheck(quandle1, quandle2):
    # Can't be isomorphic if sizes don't match
    if quandle1.nrows() != quandle2.nrows() or quandle1.ncols() != quandle2.ncols():
        return False
    
    n = quandle1.nrows()

    # Make values match the index valuescomp (so I don't go insane with indexing)
    valueMapping1 = dict()
    valueMapping2 = dict()
    for i in range(0, n):
        valueMapping1[quandle1[i, i]] = i 
        valueMapping2[quandle2[i, i]] = i 
    
    quandle1Mapped = Matrix(quandle1)
    quandle2Mapped = Matrix(quandle2)
    for i in range(0, n):
        for j in range(0, n):
            quandle1Mapped[i, j] = valueMapping1[quandle1[i, j]]
            quandle2Mapped[i, j] = valueMapping2[quandle2[i, j]]

    values = range(0, n)

    # Need to try every mapping between values
    # For every possible bijection between quandles
    for perm in permutations(values):
        # Make a dict of mappings of index values
        mapping = dict(zip(values, perm))
        isomorphism = True

        # Check each column to see if it is correct under map
        for y in range(0, n):
            f_y = mapping[y]

            S_y = quandle1Mapped.column(y)
            S_fy = quandle2Mapped.column(f_y)

            # f o S_y = S_f(y) o f
            # Compose with permutation
            # for elements in S_y
            #   Save mapping[S_y] in its place
            image1 = [ mapping[x] for x in S_y ]
            # For elements in f map to where S_fy
            image2 = [ S_fy[mapping[x]] for x in values]

            if image1 != image2:
                isomorphism = False
                break

        if isomorphism == True:
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
        return False

    # Add a check for orbit sizes?? - Might save some time
    # Might also be negligable since this is so asymptoptically large

    subQuandles = list()

    for orbit in orbits:
        # Remove rows and columns of orbit
        keep = [i for i in range(0, quandle.nrows()) if (i + 1) not in orbit]
        subQ = quandle.matrix_from_rows(keep).matrix_from_columns(keep)
        subQuandles.append(subQ)

    # Check if all are isomorphic
    for i in range (0, len(subQuandles) - 1):
        if not isomorphismCheck(subQuandles[i], subQuandles[i+1]):
            return False

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
                if isomorphismCheck(q, quandle):
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

    start_time = time.perf_counter()

    # Axiom 1: Generate idempotency along diagonal:
    quandle = Matrix(ZZ, n, n, lambda i, j: i + 1 if i == j else -1)
    generate(quandle, 0, 0)
    
    duration = time.perf_counter() - start_time

    count = 0
    for M in valid:
        if isCohen(M):
            print(findOrbits(M))
            print(M, "\n")
            count += 1

    print(f"There are {len(valid)} quandles of order {n}")
    print(f"{count} of them are Cohen quandles")
    print(f"Generation took {duration} seconds")

    if args.save:
        # Save to file logic here
        pass 