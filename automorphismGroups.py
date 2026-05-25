# Library imports:
from sage.all import *

from reorderOutput import readFile



def calculateAutoGroup(quandle: Matrix):
     # For every permutation on n elements (n!)
          # Check if automorphism n^2
     
     if quandle.nrows() != quandle.ncols():
          raise Exception("Quandle matrix is not square")
     
     n = quandle.ncols()

     # Generate Inner permutation group
     Inn = calculateInnerGroup(quandle)
     Inn_gap = Inn._gap_()
     Sn = SymmetricGroup(n)
     Sn_gap = Sn._gap_()
     N_gap = Sn_gap.Normalizer(Inn_gap)
     N = PermutationGroup(gap_group=N_gap)

     Inn_gens = Inn.gens() # TODO** THIS MAY STILL BE AN ISSUE

     autos = []

     for g in N:
          valid = True
          g_inverse = g.inverse()

          for Sj in Inn_gens:
               conj = g * Sj * (g_inverse)
               if conj not in Inn:
                    valid = False
                    break

          if valid:
               autos.append(g)

     Aut = PermutationGroup(autos)

     # print(AutQ.order())
     # print(AutQ.structure_description())

     return Aut




def calculateInnerGroup(quandle: Matrix):
     if quandle.nrows() != quandle.ncols():
          raise Exception("Quandle matrix is not square")
     
     n = quandle.ncols()
     generators = []

     for j in range(n):
          R = [quandle[i, j] for i in range(n)]
          generators.append(R)

     # print(generators)

     return PermutationGroup(generators)


# def matrixToString(M: Matrix):
#      result = ""
#      for row in M.rows():
#           result += (str(row) + "\n")
#      return result

def printBoth(file, str: str):
     file.write(str + "\n")
     print(str)


if __name__ == "__main__":

     for i in range(3, 11):
          quandles = readFile(f"./output/cohen{i}.txt")

          with open(f"./output/aut-groups/order{i}.txt", "w") as file:

               printBoth(file, f"Order {i}:\n")

               for j in range(len(quandles)):
                    X = quandles[j]
                    # Dihedral Quandle
                    # n = 3
                    # X = Matrix([
                    # [(2*j - i) % n + 1 for j in range(n)]
                    # for i in range(n)
                    # ])

                    printBoth(file, f"Index: {j + 1}")
                    printBoth(file, str(X))

                    Inn = calculateInnerGroup(X)
                    printBoth(file, "Inner Group:")
                    printBoth(file, f"Isomorphic to: {Inn.structure_description()}")
                    printBoth(file, str(Inn))
                    printBoth(file, f"Orbits: {Inn.orbits()}")
                    printBoth(file, f"Order: {Inn.order()}\n")
                    
                    Aut = calculateAutoGroup(X)
                    printBoth(file, "Automorphism Group:")
                    printBoth(file, f"Isomorphic to: {Aut.structure_description()}")
                    # printBoth(file, str(Aut))
                    printBoth(file, f"Orbits: {Aut.orbits()}")
                    printBoth(file, f"Order: {Aut.order()}\n\n")


     # Do they all have automorphism mapping 1 orbit into the other???
     # What would this automorphism group look like?????? 
     # there is a cycle mapping all elements into elements of other orbits
     # there is a cycle in the group that is of the form:
     # a in orbit1, b in orbit2, c in orbit3 ...
     # (a b c) (element orbit1  element orbit2  element orbit3) ...
     # also if (S3 x S3) : C2, then inner groups are mapped to others???????? semidirect product of S3 x S3 by C2 aljsdfhaskjfhasj

     # Just iterate through all element of the group and see if there is one that takes the orbit subset to another orbit subset?
     # Must do so if automorphism group does not equal inner group???? So if sizes are different, since orbits map to orbits under automorphisms



     # | Notation | Meaning                   |
     # | -------- | ------------------------- |
     # | `A x B`  | direct product            |
     # | `A : B`  | semidirect product        |
     # | `A . B`  | unspecified extension     |
     # | `C_n`    | cyclic group of order (n) |
     # | `D_n`    | dihedral group            |
     # | `Q_8`    | quaternion group          |