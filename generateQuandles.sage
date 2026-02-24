from sage.all import *


def ruleCheck():
    pass

def cohenCheck():
    pass

def isomorphismCheck():
    pass


def validCheck(quandle, i, j) -> bool:
    v = quandle[i, j]

    # Ensure operation is bijective (no repeating in columns)
    for c in quandle[:, j]:
        # print(c)
        if v == c:
            # print("here")
            return False

    return True


def generate(quandle, i, j):
    # Base Case: Matrix is full
    if (i >= n): 
        # Add quandle to output list
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
    n = 2
    valid = list()
    quandle = Matrix(ZZ, n, n, lambda i, j: i + 1 if i == j else -1)
    generate(quandle, 0, 0)
    
    for M in valid:
        print(M, "\n")