from sage.all import *


n = 3

F = FreeGroup(2*n+1, names=['a{}'.format(i) for i in range(2*n+1)])
generators = F.gens()


# Make relations (ie quandle table section)
relations = []
for i in range(0, 2*n):
    for j in range(i+1, 2*n+1):
        # print(f"{i} * {j}")
        i_x_j = (3*(i+j)) % (2*n+1)

        a_ixj = generators[i_x_j]
        a_i = generators[i]
        a_j = generators[j]
        relations.append(a_ixj * (a_j*a_i*a_j^-1)^-1)

print(relations)
print(len(relations))

Adj = (F / relations).simplified()

# T = Adj.tietze_transformations()
# T.simplify()
# Adj_simplified = T.group()
print(Adj)
# print(Adj.is_cyclic())
print(Adj.order())
# print(Adj.structure_description())


#B_n = FreeGroup