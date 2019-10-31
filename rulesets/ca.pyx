from libc.stdio cimport printf, sprintf
from libc.stdlib cimport malloc, free, rand, srand
from libc.time cimport time
from collections.abc import Iterable
from typing import Callable

cdef class CA:
    """
    The Cellular-Automata class for setting up rules, executing and displaying
    results.
    """ 

    cdef int **domain;
    cdef int **old;
    cdef int domain_size;

    def __cinit__(self, size, values=2, random=True):
        """
        C-based initialization.
        CA(self, size: int, values: int=2, random=True)

        size: Integer representing the desired dimensions of the CA.
        values: Integer representing the amount of different states
            (starting from 0) or Iterable (list, tuple, dict, set, ...)
            of integers containing all desired starting states.
        random: Boolean for randomness or fixed seed or Integer for the seed
            you want to use.
        """

        cdef int i, j, k
        self.domain_size = size
        self.domain = <int **> malloc(size * sizeof(int*))
        self.old = <int **> malloc(size * sizeof(int*))
        if isinstance(random, bool):
            if random:
                srand(time(NULL))

        elif isinstance(random, int):
            srand(random)

        else:
            raise TypeError("Argumente `random` should be either bool or int.")

        if type(values) == int:
            for i in range(0, size):
                self.domain[i] = <int *> malloc(size * sizeof(int))
                self.old[i] = <int *> malloc(size * sizeof(int))

                for j in range(0, size):
                    self.domain[i][j] = rand()%values
                    self.old[i][j] = self.domain[i][j]

        elif isinstance(values, Iterable):
            k = len(values)
            for i in range(0, size):
                self.domain[i] = <int *> malloc(size * sizeof(int))
                self.old[i] = <int *> malloc(size * sizeof(int))

                for j in range(0, size):
                    self.domain[i][j] = values[rand()%k]
                    self.old[i][j] = self.domain[i][j]

        else: raise TypeError(
            "`values` parameter must be either an int or "
            "Iterable. Was %s" % str(type(values)))

    def getOld(self, ind):
        return [self.old[ind][i] for i in range(0, self.domain_size)]

    def __getitem__(self, ind):
        return [self.domain[ind][i] for i in range(0, self.domain_size)]

    def __len__(self): return self.domain_size

    cpdef bytes prettyPrint(self, x, y):
        return b"%d " % self.domain[x][y]

    def rule(self, x, y):
        """
        Conway's Game of Life set of rules
        """
        # print(f"Received rule for {x},{y}")

        k = sum(self.__neighbors8__(x, y, old=True))

        # print(f"Neighbors returned {k}")

        if self[x][y] == 1:
            
            # Any live cell with fewer than 2 or more than 3 neighbors dies,
            # as if by underpopulation and overpopulation
            if k < 2 or k > 3: return 0
            else: return 1

        else:

            # Any dead cell with exactly 3 live neighbors becomes alive,
            # as if by reproduction
            if k == 3: return 1
            else: return 0

    cpdef void __draw__(self) except *:
        cdef int i, j
        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                printf("%s", self.prettyPrint(i, j))
            printf("\n")

    cpdef void __step__(self) except *:
        cdef int i, j

        # print("Copying values to old")

        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                # print(f"Copied [{i}][{j}]")
                self.old[i][j] = self.domain[i][j]

        # print("Running rule")
        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                # print(f"Running for [{i}][{j}]")
                self.domain[i][j] = self.rule(i, j)

    cpdef list __neighbors8__(self, x, y, old=False):
        if old:
            return [
                self.old[i+x][j+y] for i in range(-1, 2) for j in range(-1, 2)
                if (
                    not (i == 0 and j == 0)
                    and (i+x >= 0 and i+x < self.domain_size)
                    and (j+y >= 0 and j+y < self.domain_size)
                )
            ]

        else:
            return [
                self.domain[i+x][j+y] for i in range(-1, 2) for j in range(-1, 2)
                if (
                    not (i == 0 and j == 0)
                    and (i+x >= 0 and i+x < self.domain_size)
                    and (j+y >= 0 and j+y < self.domain_size)
                )
            ]

cpdef void draw(obj):
    if isinstance(obj, CA):
        obj.__draw__()

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

cpdef void step(obj):
    if isinstance(obj, CA):
        obj.__step__()

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

cpdef list neighbors8(obj, x, y, old=False):
    if isinstance(obj, CA):
        return obj.__neighbors8__(x, y, old=old)

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")
