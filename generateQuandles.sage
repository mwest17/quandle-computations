# Standard library imports:
import argparse
from itertools import permutations
import time
import ast
import re

# Library imports:
from sage.all import *



# Returns True if two quandles are isomorphic
def isomorphismCheck(quandle1, quandle2):
    # Can't be isomorphic if sizes don't match
    if quandle1.nrows() != quandle2.nrows() or quandle1.ncols() != quandle2.ncols():
        return False
    

    # Perform a precheck based on invariants **HERE**
    # **TODO**


    n = quandle1.nrows()

    # Make values match the index valuescomp (so I don't go insane with indexing)
    valueMapping1 = dict()
    valueMapping2 = dict()
    for i in range(0, n):
        valueMapping1[quandle1[i, i]] = i 
        valueMapping2[quandle2[i, i]] = i 
    
    quandle1Mapped = Matrix(quandle1)
    quandle2Mapped = Matrix(quandle2)
    # print(quandle1)
    # print(valueMapping1)
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
    n = quandle.nrows()

    for row in range(0, n):
        # find orbit with our row in it
        orbit = set()

        for col in range(0,n):
            v = quandle[row, col]
            if v != -1:
                orbit.add(v)

        # See if orbit has new elements to add to existing orbit
        new = True
        for i in range(0, len(orbits)):
            if orbit & orbits[i]:
                # print("here ", existingOrbit, " ", orbit)
                orbits[i] = orbit | orbits[i]
                # print(existingOrbit)
                new = False
                break

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
        keep = [i for i in range(0, quandle.nrows()) if i not in orbit]
        subQ = quandle.matrix_from_rows(keep).matrix_from_columns(keep)
        subQuandles.append(subQ)

    # Check if all are isomorphic
    for i in range (0, len(subQuandles) - 1):
        # print('\n', quandle)
        if not isomorphismCheck(subQuandles[i], subQuandles[i+1]):
            return False

    return True


def verifyAxiom3(quandle) -> bool:
    # For all x, y, z, (x * y) * z = (x * z) * (y * z)
    for x in range(0, n):
        for y in range(0, n):
            for z in range(0, n):
                x_y = quandle[x, y]
                result = quandle[x_y, z]

                x_z = quandle[x, z]
                y_z = quandle[y, z]

                if result != quandle[x_z, y_z]:
                    return False

    return True


def inverseOperation(quandle, i, j):
    for r in range(0, quandle.nrows()):
        if quandle[r, j] == i:
            return r
    return -1

# Will need to try to explore the most beneficial states first (ie the ones that lead to us filling in many spaces)
def validCheck(quandle, i, j) -> bool:
    k = quandle[i, j]

    # Axiom 2: Ensure operation is bijective (no repeating in columns)
    for c in range(0, n):
        # Matching element (ignoring our column)
        if c != i and k == quandle[c, j]:
                return False
    
    # Verify all 3 rules that this will lead to a valid Quandle
    
    # Rule 1:
    # First conditional eliminates too many
    # Other two can add duplicate values to a column
    for a in range(0, n):
        k_a = quandle[k, a]
        j_a = quandle[j, a]
        i_a = quandle[i, a]

        if j_a == -1 or i_a == -1:
            continue

        i_a_j_a = quandle[i_a, j_a]
        

        # if i_a_j_a == -1 and k_a != -1:
        #     # Case 1
        #     # What row contains the value k_a in the i_a th column
        #     if inverseOperation(quandle, k_a, i_a) != -1:
        #         #Invalid
        #         return False # False positives
        #     else:
        #         quandle[i_a_j_a] = k_a

        # if i_a_j_a != -1 and k_a == -1:
        #     # Case 2
        #     if inverseOperation(quandle, i_a_j_a, a) != -1:
        #         return False
        #     else:
        #         quandle[k_a] = i_a_j_a # Does not respect bijectivity of column
        
        if i_a_j_a != -1 and k_a != -1:
            if i_a_j_a != k_a:
                return False


    # Rule 2:


    # Rule 3:


    # Cohen check
        # Ensure size of largest orbit * # orbits <= n (order of quandle)
        # Something with ensuring "finshed" orbits must be factors of n?


    return True


def generate(quandle, i, j):
    # Base Case: We've reached end of matrix (ie no more positions to fill)
    if (i >= n): 
        # Verify complete table satisfies axiom 3
        if verifyAxiom3(quandle):
            for q in valid: # Compare with already found to see if duplicate
                if isomorphismCheck(q, quandle):
                    return
            valid.append(quandle)
        return

    nextJ = (j + 1) % n
    nextI = i + (1 if (nextJ == 0) else 0) # If we've reached end of the row, go down to next row

    if quandle[i,j] != -1: # position i, j has already been filled in by axioms
        generate(quandle, nextI, nextJ)
        return

    for v in range(0, n):
        newQuandle = Matrix(quandle)
        newQuandle[i, j] = v
        if validCheck(newQuandle, i, j): # Fill in and verify potential based on axioms
            generate(newQuandle, nextI, nextJ)
    
    return


def readFile(inputFile):
    with open(inputFile, 'r') as file:
        text = file.read()

    text = re.sub(r'printf\(.*?\);?\s*', '', text)
    text = re.sub(r'\w+:=map\(Matrix,', '', text)
    text = text.rstrip(':; \n')
    text = text.rstrip('):')


    data = ast.literal_eval(text)

    matrices = [Matrix(m) for m in data]
    return matrices


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-o", "--output",
        help="Save quandles to file"
    )

    parser.add_argument(
        "-n", "--order",
        #required=True,
        help="Order of quandles to generate"
    )
    
    parser.add_argument(
        "-f", "--file",
        help="Path to input file"
    )

    args = parser.parse_args()


    cohen = list()

    if args.file != None:
        quandles = readFile(args.file)
        for q in quandles:
            ones = Matrix(q.nrows(), q.nrows(), lambda i, j: 1)
            tmp = q - Matrix(q.nrows(), q.nrows(), ones)
            if isCohen(tmp):
                cohen.append(q)

    else:
        n = int(args.order)
        print(f"Generating all Quandles of order {n} ....")

        valid = list()

        start_time = time.perf_counter()

        # Axiom 1: Generate idempotency along diagonal:
        quandle = Matrix(ZZ, n, n, lambda i, j: i if i == j else -1)
        generate(quandle, 0, 0)
        
        duration = time.perf_counter() - start_time

        count = 0
        for M in valid:
            print(findOrbits(M))
            print(M)
            if isCohen(M):
                print("Is Cohen")
                cohen.append(M)
            print()

        print(f"There are {len(valid)} quandles of order {n}")
        print(f"Generation took {duration} seconds")


    if args.output != None:
        with open(args.output, 'w') as file:
            file.write(f"There are {len(cohen)} Cohen quandles of order {cohen[0].nrows()}\n\n")
            for c in cohen:
                file.write(str(findOrbits(c)))
                file.write("\n")
                file.write(str(c))
                file.write("\n\n")

    for c in cohen:
        print(c, '\n')


    print(f"{len(cohen)} of them are Cohen quandles")        

    
        