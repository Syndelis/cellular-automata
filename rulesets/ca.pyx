from libc.stdio cimport printf, sprintf
from libc.stdlib cimport malloc, free, rand, srand
from libc.time cimport time
from collections.abc import Iterable
from typing import Callable

cdef class CA:
    """
    The base Cellular-Automata class for setting up rules, executing and
    displaying results.

    Methods that should be overwritten in order to change drawing, plotting and
    updating mechanisms will be annotated.


    Initialization:
    CA(size: int, values: int=2, random_values=True, random_seed=True)

        size: Integer representing the desired dimensions for the CA.
        values: Either an integer or an Iterable used for the initialization of
            the CA. If an integer, values will be picked from 0..n. 
            Whether these values will be assigned to positions randomly is
            defined by the `random_values` parameter
        random_values: Whether the CA should have random values picked for or 0.
        random_seed: Whether a random seed should be picked for random value
            assignment during initialization.

    
    In order to fully customize your CA, only the following methods must be
    overwritten: prettyPrint(self, x, y), rule(self, x, y).
    Read about these methods on their respective help.

    """ 

    cdef int **domain;
    cdef int **old;
    cdef int domain_size;

    def __cinit__(self, size, values=2, random_values=True, random_seed=True):
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
        self.values: List[int]
        if isinstance(random_seed, bool):
            if random_seed:
                srand(time(NULL))

        elif isinstance(random_seed, int):
            srand(random_seed)

        else:
            raise TypeError("Argumente `random` should be either bool or int.")

        if type(values) == int:
            self.values = list(range(values))

            if random_values:
                for i in range(0, size):
                    self.domain[i] = <int *> malloc(size * sizeof(int))
                    self.old[i] = <int *> malloc(size * sizeof(int))

                    for j in range(0, size):
                        self.domain[i][j] = rand()%values
                        self.old[i][j] = 0

            else:
                for i in range(0, size):
                    self.domain[i] = <int *> malloc(size * sizeof(int))
                    self.old[i] = <int *> malloc(size * sizeof(int))

                    for j in range(0, size):
                        self.domain[i][j] = 0
                        self.old[i][j] = 0

        elif isinstance(values, Iterable):
            self.values = list(values)
            k = len(values)

            if random_values:
                for i in range(0, size):
                    self.domain[i] = <int *> malloc(size * sizeof(int))
                    self.old[i] = <int *> malloc(size * sizeof(int))

                    for j in range(0, size):
                        self.domain[i][j] = values[rand()%k]
                        self.old[i][j] = 0
            else:
                for i in range(0, size):
                    self.domain[i] = <int *> malloc(size * sizeof(int))
                    self.old[i] = <int *> malloc(size * sizeof(int))

                    for j in range(0, size):
                        self.domain[i][j] = 0
                        self.old[i][j] = 0

        else: raise TypeError(
            "`values` parameter must be either an int or "
            "Iterable. Was %s" % str(type(values)))

    cpdef list getMatrix(self):
        """
        Returns the Matrix that represents the domain.
        """

        cdef int i, j
        return [
            [self.domain[i][j] for i in range(self.domain_size)] 
            for j in range(self.domain_size)
        ]

    def getOld(self, ind):
        """
        Returns the column `ind` of the previous state. Used to mimic
        the __getitem__ functionality with self[x][y].
        """
        return [self.old[ind][i] for i in range(0, self.domain_size)]

    def __getitem__(self, ind):
        """
        Returns the column `ind` of the current state. This was made so that
        `self[x][y]` becomes the primary way of accessing a value at [x, y].
        """
        return [self.domain[ind][i] for i in range(0, self.domain_size)]

    def __len__(self):
        """
        Returns the length of the domain.
        """
        return self.domain_size

    cpdef bytes prettyPrint(self, x, y):
        """
        Overwrittable.
        Defines how values are printed to the console. Must always return
        a bytes-like string.

        The default return is `b"%%d " %% self[x][y]` which is just the number
        of the state at a given [x, y] followed by a space character.
        One way of overwritting it would be to return 
        `b"\\033[%%dm  \\033[m" %% (41 + self[x][y])`. With this, you'll be able
        to print colored spaces in a terminal that accepts colors.
        """
        return b"%d " % self.domain[x][y]

    cpdef int stationary(self):
        """
        Overwrittable.
        Returns whether or not the current state differs from the previous one.
        It's useful to detect easy CAs that got into equilibrium. However, more
        previous states should be compared in order to guarantee a given CA has
        entered a loop.
        """

        cdef int i, j

        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                if (self.domain[i][j] != self.old[i][j]):
                    return False

        return True

    def rule(self, x, y):
        """
        Overwrittable
        The rule that is applied to every pair of [x, y]. The default rule is
        Conway's Game of Life.

        If you wish to change the set of rules, you are quite likely to need
        information about the neighborhood of the cell at [x, y]. For this
        purpose, you can use the function `ca.neighbors8(obj, x, y, old=True)` 
        in order to access them. It's recommended to store the neighborhood in a
        variable to prevent redundant function calls.
        """

        k = sum(self.__neighbors8__(x, y, old=True))

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

    cpdef void add(self, value: int=0, points: Iterable=[], size: tuple=(1, 1)):
        """
        def add(self, value=0, points=[], size=(1,1))

        value: The integer value you want to assign to multiple cells.
        points: a list of pairs (x, y) for the starting position (top-left)
            of the rectangles
        size: tuple of the dimensions all rectangles should have

        Assigns `value` for every cell in the rectangles
        [p[0], p[1], p[0]+size[0], p[1]+size[1]] for every p in points.

        This function should not be overwritten, as the behavior is already
        generic enough.
        """

        cdef int i, j
        p: Iterable
        cdef int x, y
        cdef int dx, dy
        dx = size[0]
        dy = size[1]

        for p in points:
            x, y = p
            for i in range(0, dx):
                for j in range(0, dy):
                    self.domain[(x+i) % self.domain_size]\
                               [(y+j) % self.domain_size] = value


    cpdef void __draw__(self) except *:
        """
        Called by function `ca.draw(obj)`.
        
        This function should not be overwritten, as it would cause a dramatic
        slow-down on the program.
        If you wish to modify how values are shown, look into overwritting
        `prettyPrint(self, x, y)` instead.
        """

        cdef int i, j
        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                printf("%s", self.prettyPrint(i, j))
            printf("\n")

    cpdef void __step__(self) except *:
        """
        Called by function `ca.step(obj)`

        This function should not be overwritten, as it would cause a dramatic
        slow-down on the program.
        If you wish to modify how values are decided, look into overwritting
        `rule(self, x, y)` instead. 
        """

        cdef int i, j

        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                self.old[i][j] = self.domain[i][j]

        for i in range(0, self.domain_size):
            for j in range(0, self.domain_size):
                self.domain[i][j] = self.rule(i, j)

    cpdef list __neighbors8__(self, x, y, old=False):
        """
        Called by function `ca.neighbors8`

        Overwritting this function would be redundant, as the expected behavior
        for Conway's neighbors8 definition is already fully implemented. Look
        into adding a new method if you want another type of neighborhood, such
        as neighbors4.
        """

        if old:
            return [
                self.old[(i+x) % self.domain_size][(j+y) % self.domain_size]
                for i in range(-1, 2) for j in range(-1, 2)
                if (
                    not (i == 0 and j == 0)
                    # and (i+x >= 0 and i+x < self.domain_size)
                    # and (j+y >= 0 and j+y < self.domain_size)
                )
            ]

        else:
            return [
                self.domain[(i+x) % self.domain_size][(j+y) % self.domain_size]
                for i in range(-1, 2) for j in range(-1, 2)
                if (
                    not (i == 0 and j == 0)
                    # and (i+x >= 0 and i+x < self.domain_size)
                    # and (j+y >= 0 and j+y < self.domain_size)
                )
            ]

cpdef void draw(obj):
    """
    Calls obj.__draw__()
    """

    if isinstance(obj, CA):
        obj.__draw__()

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

cpdef void step(obj):
    """
    Calls obj.__step__()
    """

    if isinstance(obj, CA):
        obj.__step__()

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

cpdef list neighbors8(obj, x, y, old=False):
    """
    Calls obj.__neighbors8__()
    """

    if isinstance(obj, CA):
        return obj.__neighbors8__(x, y, old=old)

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

try:
    import matplotlib.pyplot as plt
    from matplotlib.colors import LinearSegmentedColormap
    from matplotlib.backends.backend_pdf import PdfPages

    def plot(obj, colors=None, N=10, fontsize=16, out='out.pdf'):
        """
        Plots k<=`N` iterations of `obj` into a pdf `out` with colors `colors`.
        """

        if isinstance(obj, CA):
            if colors != None:
                cmap = LinearSegmentedColormap.from_list(
                    'my_colormap', colors, N=len(obj.values))

            else: cmap = None

            i = 0
            with PdfPages(out) as pdf:
                while (not obj.stationary() and i < N):
                    fig = plt.figure(figsize=(10, 7))
                    plt.axis([0, len(obj)]*2)
                    plt.title('CA Plot')
                    plt.xlabel('x', fontsize=fontsize)
                    plt.ylabel('y', fontsize=fontsize)

                    plt.imshow(
                        obj.getMatrix(), interpolation='nearest',
                        vmin=min(obj.values), vmax=max(obj.values),
                        origin='lower',cmap=cmap
                    )
                        
                    plt.colorbar()

                    pdf.savefig(fig)
                    plt.close(fig)
                    step(obj)
                    i += 1

        else: raise TypeError("Object `obj` must be an instance/subclass of CA")

except (ImportError, ModuleNotFoundError):
    def plot(*args, **kwargs):
        """
        Raises an error, as Matplotlib is missing or badly configured.
        """

        raise ModuleNotFoundError("This machine does not include Matplotlib")