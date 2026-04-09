# Standard library imports:
import argparse
from itertools import permutations
import time
import ast
import re

# Library imports:
from sage.all import *

# Number of times that generate function is called
recursionCount = 0


# Returns True if two quandles are isomorphic
def isomorphismCheck(quandle1, quandle2):
    # Can't be isomorphic if sizes don't match
    if quandle1.nrows() != quandle2.nrows() or quandle1.ncols() != quandle2.ncols():
        return False

    # Perform a precheck based on invariants **HERE**
    orbits1 = findOrbits(quandle1)
    orbits2 = findOrbits(quandle2)
    if len(orbits1) != len(orbits2):
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
    # print(quandle1)
    # print(valueMapping1)
    for i in range(0, n):
        for j in range(0, n):
            quandle1Mapped[i, j] = valueMapping1[quandle1[i, j]]
            quandle2Mapped[i, j] = valueMapping2[quandle2[i, j]]

    values = range(0, n)

    # Need to try every mapping between values
    # For every possible bijection between quandles
    
    # We only care about permutations between orbits!!! Orbits must be mapped to another orbit
    # Orbits are mapped entirely to orbits under isomorphism
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
            #if v != -1:
            orbit.add(v)

        # See if orbit has new elements to add to existing orbit
        new = True
        for i in range(0, len(orbits)):
            intersection = orbit & orbits[i]
            if intersection and (len(intersection) > 1 or -1 not in intersection):
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

    subQuandles = list()

    for orbit in orbits:
        # Remove rows and columns of orbit
        keep = [i for i in range(0, quandle.nrows()) if i not in orbit]
        subQ = quandle.matrix_from_rows(keep).matrix_from_columns(keep)
        subQuandles.append(subQ)
        # print(subQ)
        # print()

    # Check if all are isomorphic
    for i in range (0, len(subQuandles) - 1):
        # print('\n', quandle)
        if not isomorphismCheck(subQuandles[i], subQuandles[i+1]):
            return False

    return True


def verifyAxiom3(quandle, n) -> bool:
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

def verifyAxiom2(quandle, i, j, n):
    k = quandle[i, j]

    # Axiom 2: Ensure operation is bijective (no repeating in columns)
    for c in range(0, n):
        # Matching element (ignoring our row)
        if c != i and k == quandle[c, j]:
                return False
    return True
    

# Will need to try to explore the most beneficial states first (ie the ones that lead to us filling in many spaces)
def validCheck(quandle, i, j, filledIn, n) -> bool:
    k = quandle[i, j]

    # Axiom 2: Ensure operation is bijective (no repeating in columns)
    if not verifyAxiom2(quandle, i, j, n):
        return False
    
    # Verify all 3 rules that this will lead to a valid Quandle
    
    # print("\n", quandle)

    # Rule 1:
    # First conditional eliminates too many
    # Other two can add duplicate values to a column
    # print(quandle, "\n")
    for a in range(0, n):
        k_a = quandle[k, a]
        j_a = quandle[j, a]
        i_a = quandle[i, a]

        if j_a == -1 or i_a == -1:
            continue

        i_a_j_a = quandle[i_a, j_a]
        

        if i_a_j_a == -1 and k_a != -1:
            # Case 1
            # What row contains the value k_a in the i_a th column
            # if inverseOperation(quandle, k_a, i_a) != -1:
            #     # print(f"{k_a} -* {i_a} = {inverseOperation(quandle, k_a, i_a)}")
            #     #Invalid
            #     return False # False positives
            # else:
            quandle[i_a, j_a] = k_a
            filledIn.append((i_a, j_a))

            if not verifyAxiom2(quandle, i_a, j_a, n):
                    return False

        if i_a_j_a != -1 and k_a == -1:
            # Case 2
            # if inverseOperation(quandle, i_a_j_a, a) != -1:
            #     return False
            # else:
            quandle[k, a] = i_a_j_a # Does not respect bijectivity of column
            filledIn.append((k, a))
            if not verifyAxiom2(quandle, k, a, n):
                    return False
        
        if i_a_j_a != -1 and k_a != -1:
            if i_a_j_a != k_a:
                return False

    # Rule 2:
    for a in range (0, n):
        a_i = quandle[a, i]
        a_j = quandle[a, j]

        if a_i == -1 or a_j == -1:
            continue

        a_i_j = quandle[a_i, j]
        a_j_k = quandle[a_j, k]

        if a_j_k == -1 and a_i_j != -1:
            if inverseOperation(quandle, a_i_j, k) != -1:
                return False
            else:
                quandle[a_j, k] = a_i_j
                filledIn.append((a_j, k))

        if a_j_k != -1 and a_i_j == -1:
            if inverseOperation(quandle, a_j_k, j) != -1:
                return False
            else:
                quandle[a_i, j] = a_j_k
                filledIn.append((a_i, j))

        if a_j_k != -1 and a_i_j != -1:
            if a_i_j != a_j_k:
                return False


    # Rule 3:
    for a in range(0, n):
        i_a = quandle[i, a]
        a_j = quandle[a, j]

        if i_a == -1 or a_j == -1:
            continue

        i_a_j = quandle[i_a, j]
        k_a_j = quandle[k, a_j]

        if k_a_j == -1 and i_a_j != -1:
            if inverseOperation(quandle, i_a_j, a_j) != -1:
                return False
            else:
                quandle[k, a_j] = i_a_j
                filledIn.append((k, a_j))

        if k_a_j != -1 and i_a_j == -1:
            if inverseOperation(quandle, k_a_j, j) != -1:
                return False
            else:
                quandle[i_a, j] = k_a_j
                filledIn.append((i_a, j))

        if k_a_j != -1 and i_a_j != -1:
            if i_a_j != k_a_j:
                return False


    # Rule 4:
    for a in range(0, n):
        i_inv_a = inverseOperation(quandle, i, a)
        j_inv_a = inverseOperation(quandle, j, a)

        if i_inv_a == -1 or j_inv_a == -1:
            continue

        i_inv_a_j_inv_a = quandle[i_inv_a, j_inv_a]

        if i_inv_a_j_inv_a == -1:
            continue

        i_inv_a_j_inv_a_a = quandle[i_inv_a_j_inv_a, a]

        if i_inv_a_j_inv_a_a == -1:
            if inverseOperation(quandle, k, a) != -1:
                return False
            else:
                quandle[i_inv_a_j_inv_a, a] = k
                filledIn.append((i_inv_a_j_inv_a, a))
        else:
            if i_inv_a_j_inv_a_a != k:
                return False


    # Rule 5:
    for a in range(0, n):
        i_inv_a = inverseOperation(quandle, i, a)
        a_j = quandle[a, j]

        if i_inv_a == -1 or a_j == -1:
            continue

        i_inv_a_j = quandle[i_inv_a, j]
        if i_inv_a_j == -1:
            continue

        i_inv_a_j_a_i = quandle[i_inv_a_j, a_j]

        if i_inv_a_j_a_i == -1:
            if inverseOperation(quandle, k, a_j) != -1:
                return False
            else:
                quandle[i_inv_a_j, a_j] = k
                filledIn.append((i_inv_a_j, a_j))
        else:
            if i_inv_a_j_a_i != k:
                return False
        

    # Cohen check
    #     Ensure size of largest orbit * # orbits <= n (order of quandle)
    #     Something with ensuring "finshed" orbits must be factors of n?

    # orbits = findOrbits(quandle)
    # finishedSize = 0
    # largestIncomplete = 0
    # completedOrbits = list()
    # for orb in orbits:
    #     orbSize = len(orb)
    #     if -1 in orb:
    #         largestIncomplete = max(largestIncomplete, orbSize - 1)
    #     else:
    #         completedOrbits.append(orb)

    #         if finishedSize == 0:
    #             finishedSize = orbSize

    #         if orbSize != finishedSize:
    #             return False
    
    # # If we don't have any finished orbits
    # if finishedSize == 0:
    #     finishedSize = largestFactor

    # # If not a multiple, then not good
    # if n % finishedSize != 0: 
    #     return False

    # # Ensure all incomplete can still be made to be correct size
    # if largestIncomplete > finishedSize:
    #     return False
    
    # # If we have more than 2 finisihed, check that X\O is isomorphic
    # # This would be a lot of repeated computations!!!!!
    # for i in range(1, len(completedOrbits)):
    #     O_1 = completedOrbits[i-1]
    #     O_2 = completedOrbits[i]

        # Compute X\O1 and X\O2

        # Check if they are isomorphic
            # If not, return False

    return True


def generate(quandle, i, j, n, valid):
    # Base Case: We've reached end of matrix (ie no more positions to fill)
    if (i >= n): 
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

    # Increase count of generate calls
    global recursionCount
    recursionCount = recursionCount + 1

    nextJ = (j + 1) % n
    nextI = i + (1 if (nextJ == 0) else 0) # If we've reached end of the row, go down to next row

    if quandle[i,j] != -1: # position i, j has already been filled in by axioms
        generate(quandle, nextI, nextJ, n, valid)
        return

    filledIn = list()
    for v in range(0, n):
        # Make a list of (i,j) indecies where new values are added
        quandle[i, j] = v
        if validCheck(quandle, i, j, filledIn, n): # Fill in and verify potential based on axioms
            generate(quandle, nextI, nextJ, n, valid)

        while filledIn:
            r, c = filledIn.pop()
            quandle[r, c] = -1
    quandle[i, j] = -1
    
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



def readOrder9(filename):
    with open(filename) as f:
        text = f.read()

    # Extract every [[ ... ]] block
    matrices = re.findall(r'\[\[(?:.|\n)*?\]\]', text)

    # Convert each to a Sage matrix
    return [Matrix(ast.literal_eval(m)) for m in matrices]


def saveCohen(filename, cohen):
    with open(filename, 'w') as file:
        file.write(f"There are {len(cohen)} Cohen quandles of order {cohen[0].nrows()}\n\n")
        for i in range(len(cohen)):
            c = cohen[i]
            file.write(str(findOrbits(c)))
            file.write("\n")
            file.write(str(c))
            file.write(f"\nIndex: {i + 1}")
            file.write("\n\n")


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
    index = list()

    if args.file != None:
        quandles = readFile(args.file)
        for i in range(len(quandles)):
            q = quandles[i]
            ones = Matrix(q.nrows(), q.nrows(), lambda i, j: 1)
            tmp = q - Matrix(q.nrows(), q.nrows(), ones)
            if isCohen(tmp):
                cohen.append(q)
                index.append(i)

    else:
        n = int(args.order)
        print(f"Generating all Quandles of order {n} ....")

        largestFactor = 1
        for i in range(2, n):
            if n % i == 0:
                largestFactor = i

        valid = list()

        import cProfile

        profiler = cProfile.Profile()
        profiler.enable()
        start_time = time.perf_counter()

        # Axiom 1: Generate idempotency along diagonal:
        quandle = Matrix(ZZ, n, n, lambda i, j: i if i == j else -1)
        generate(quandle, 0, 0, n, valid)
        
        duration = time.perf_counter() - start_time

        count = 0
        for M in valid:
            # print(findOrbits(M))
            # print(M)
            if isCohen(M):
                # print("Is Cohen")
                cohen.append(M)
            # print()

        profiler.disable()
        profiler.dump_stats("data.prof")

        import pstats
        stats = pstats.Stats(profiler)
        stats.strip_dirs()      # Remove full library paths
        # stats.sort_stats("cumulative")  # Sort by total time spent (including called functions)
        stats.sort_stats("tottime")
        stats.print_stats(20)   # Print top 20 functions


        print(f"There are {len(valid)} quandles of order {n}")
        print(f"Generation took {duration} seconds")


    if args.output != None:
        saveCohen(args.output, cohen)

    # for c in cohen:
    #     print(c, '\n')


    print(f"{len(cohen)} of them are Cohen quandles")        
    print(f"generate() was called {recursionCount} times")