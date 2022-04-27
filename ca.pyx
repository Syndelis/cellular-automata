from libc.stdio cimport printf, sprintf
from libc.stdlib cimport malloc, calloc, free, rand, srand
from libc.time cimport time
from libc.string cimport memcmp, memcpy

from collections.abc import Iterable
from typing import Callable
from random import random

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

    cdef int **domain
    cdef int **old
    cdef int size
    cdef public object values

    def __cinit__(self, size, dimensions=2, values=2,
                random_values=True, random_seed=True, min_=0, max_=None):

        """
        C-based initialization.
        CA(self, size: int, dimensions: int=2, values: int=2, random=True)

        size: Integer representing the desired dimensions of the CA.
        [dimensions]: Integer representing the amount of dimensions.
            Currently, only 2 dimensions are supported and plottable. However,
            1 dimension support is being worked on to produce results as seen
            with Wolfram's CAs.
        [values]: Integer representing the amount of different states
            (starting from 0) or Iterable (list, tuple, dict, set, ...)
            of integers containing all desired starting states.
        [random_values]: Boolean that controls wether or not the CA should be
            filled randomly with values in startup. Values used are defined via
            the `values` parameter.
        [random_seed]: Boolean for randomness or fixed seed, or Integer for the
            seed you want to use.
        """

        cdef int i, j, k
        self.size = size
        self.values: List[int]
        self.min = min_
        self.max = max_

        if max_ is None:
            self.max = max(values) if isinstance(values, Iterable) else (values - 1)

        # Argument Check: random_seed ------------------------------------------
        if isinstance(random_seed, bool):
            if random_seed: srand(time(NULL))

        elif isinstance(random_seed, int):
            srand(random_seed)

        else:
            raise TypeError(
                "Argument \033[4mrandom\033[m should be either bool or int.")

        
        # Memory allocation ----------------------------------------------------
        self.domain = <int **> malloc(self.size * sizeof(int *))
        self.old    = <int **> malloc(self.size * sizeof(int *))

        for i in range(0, size):
            self.domain[i] = <int *> calloc(self.size, sizeof(int))
            self.old[i]    = <int *> calloc(self.size, sizeof(int))

        # Argument Check: values -----------------------------------------------
        if random_values:

            if type(values) is int:

                self.values = list(range(values))

                for i in range(0, size):
                    for j in range(0, size):
                        self.domain[i][j] = rand()%values

            elif isinstance(values, Iterable):
                k =  len(values)

                self.values = values
                
                for i in range(0, size):
                    for j in range(0, size):
                        self.domain[i][j] = values[rand()%k]

            else:

                raise TypeError(
                    'Non [int, Iterable] '
                    'parameter \033[4mvalues\033[m'
                )


        else:

            if isinstance(values, Iterable):
                k =  len(values)
                
                if k < self.size*self.size:
                    raise TypeError(
                        "Iterable of incorrect size passed for "
                        "\033[4mvalues\033[m. "
                        f"Should be {self.size}×{self.size} (={self.size**2})"
                    )


                self.values = values
                
                for i in range(0, size):
                    for j in range(0, size):
                        self.domain[i][j] = values[i*self.size + j]

            elif type(values) is int:
                self.values = list(range(values))

            else:
                raise TypeError(
                    'Non [int, Iterable] '
                    'parameter \033[4mvalues\033[m'
                )


    def __dealloc__(self):
        cdef int i

        for i in range(0, self.size):
            free(self.domain[i])
            free(self.old[i])

        free(self.domain)
        free(self.old)


    cpdef list getMatrix(self):
        """
        Returns the Matrix that represents the domain.
        """

        cdef int i, j
        return [
            [self.domain[i][j] for i in range(self.size)]
            for j in range(self.size)
        ]


    def getOld(self, ind, indy=None):
        """
        This functions operates in two ways:

        1- parameter `indy` is not given:
        Returns the column `ind` of the previous state.

        2- parameter `indy` is given:
        Returns the position at (ind, indy) of the previous state.
        """
        if indy == None:
            return [self.old[ind][i] for i in range(0, self.size)]
        else: return self.old[ind][indy]


    def __getitem__(self, ind):
        """
        This function operates in two ways:

        1- Ind is a number:
        Returns the column `ind` of the current state.

        2- Ind is an iterable:
        Returns the value at (ind[0], ind[1]) of the current state.
        """
        if isinstance(ind, Iterable):
            return self.domain[ind[0]][ind[1]]

        elif isinstance(ind, int):
            return [self.domain[ind][i] for i in range(0, self.size)]

        else:
            raise TypeError(
                f"Parameter \033[4mind\033[m must be either an int or an "
                f"Iterable. Received `{type(ind)}`"
            )


    def __len__(self):
        """
        Returns the length of the domain.
        """
        return self.size


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


    cpdef void move(self, x0, y0, x1, y1, clear=None):
        cdef int v0 = self.domain[x0][y0]
        cdef int v1
        if clear: v1 = clear
        else: v1 = self.domain[x1][y1]

        self.domain[x0][y0] = v1
        self.domain[x1][y1] = v0


    cpdef int stationary(self):
        """
        Overwrittable.
        Returns whether or not the current state differs from the previous one.
        It's useful to detect easy CAs that got into equilibrium. However, more
        previous states should be compared in order to guarantee a given CA has
        entered a loop.
        """

        cdef int i, j

        for i in range(0, self.size):
            if (memcmp(self.domain[i], self.old[i], self.size * sizeof(int)) != 0):
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

        if self.domain[x][y] == 1:

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
                    self.domain[(x+i) % self.size][(y+j) % self.size] = value


    cpdef void addrandomvalues(self, value: int=0, state: int=0, N: int=100, p: float=1):
       """
       addrandomvalues(self, value: int=0, state: int=0, N: int=100, p: float=1):

       value: The integer value you want to assign to multiple random cells.
       state: The integer state that can be overwritten.
       N: An integer representing the number of attempts made.
       p: A float between 0 and 1 representing the probability of assignment the value where cells have the state passed
       as an argument.


       Assigns `value` for every randomly generated cell with the state given

       This function should not be overwritten, as the behavior is already
       generic enough.
       """
       cdef int i, j
       cdef int x, y

       N = self.size # Reassignment of parameter. Old value not used

       i = 0
       j = 0
       if (p < 0): p = 0
       if (p > 1): p = 1

       while (rand() < p and i < N):
           x = rand() % self.size
           y = rand() % self.size

           while (j < self.size**2 and self.domain[x][y] != state):
               x = rand() % self.size
               y = rand() % self.size
               j += 1

           if (j != self.size**2):
               self.domain[x][y] = value
           i += 1


    cpdef list events(self, odds=1.):
       """
        cpdef list __events__(self, odds=1.):
        Return true or false for a list of probabilities representing a sequence of probabilistic events.

        odds: one/List of probabilities (values between 0 and 1)
       """
       odds_l = []
        # Test odds values to verify negative values?

       if isinstance(odds, float):

           if rand() < odds: return True
           else: return False


       elif isinstance(odds, Iterable):

           for i in odds:
               if rand() < i: odds_l.append(True)
               else: odds_l.append(False)

           return odds_l


       else: raise TypeError(
               "`odds` parameter must be either an int or "
               "Iterable. Was %s" % str(type(odds)))


    cpdef void __draw__(self) except *:
        """
        Called by function `ca.draw(obj)`.

        This function should not be overwritten, as it would cause a dramatic
        slow-down on the program.
        If you wish to modify how values are shown, look into overwritting
        `prettyPrint(self, x, y)` instead.
        """

        cdef int i, j
        for j in range(0, self.size):
            for i in range(0, self.size):
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

        for i in range(0, self.size):
            memcpy(self.old[i], self.domain[i], self.size * sizeof(int))


        for i in range(0, self.size):
            for j in range(0, self.size):
                self.domain[i][j] = self.rule(i, j)


    cpdef list __neighbors8__(self, x, y, old=True, pos=False):
        """
        Called by function `ca.neighbors8`

        Overwritting this function would be redundant, as the expected behavior
        for Conway's neighbors8 definition is already fully implemented. Look
        into adding a new method if you want another type of neighborhood, such
        as neighbors4.
        """
        if pos:
            return [
                ((i+x) % self.size, (j+y) % self.size)
                for i in range(-1, 2) for j in range(-1, 2)
                if (not (i == 0 and j == 0))
            ]


        elif old:
            return [
                self.old[(i+x) % self.size][(j+y) % self.size]
                for i in range(-1, 2) for j in range(-1, 2)
                if (not (i == 0 and j == 0))
            ]


        else:
            return [
                self.domain[(i+x) % self.size][(j+y) % self.size]
                for i in range(-1, 2) for j in range(-1, 2)
                if (not (i == 0 and j == 0))
            ]


    cpdef list __neighbors8_states__(self, x, y, old=False, n_states=1):
        """
        Called by function `ca.neighbors8_states`
        Return a list containing the number of neighbors in each state.

        Deprecated. Use collections.Counter(neighbors8(self)) instead.
        """

        raise Exception(
            "Function removed. "
            "Use collections.Counter(neighbors8(self)) instead."
        )


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

def neighbors8(obj, x, y, **kwargs):
    """
    Calls obj.__neighbors8__()
    """

    if isinstance(obj, CA):
        return obj.__neighbors8__(x, y, **kwargs)

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

def neighbors8_states(obj, x, y, **kwargs):
    """
    Calls obj.__neighbors8_states__()
    """

    if isinstance(obj, CA):
        return obj.__neighbors8_states__(x, y, **kwargs)

    else: raise TypeError("Object `obj` must be an instance/subclass of CA")

try:
    import matplotlib.pyplot as plt
    from matplotlib.colors import LinearSegmentedColormap
    from matplotlib.cm import ScalarMappable
    from matplotlib.backends.backend_pdf import PdfPages
    import matplotlib as mpl

    def plotPart(obj, colors=None, N=10, fontsize=16, vmax=0, names=None, **kwargs):

        if colors != None:
            cmap = LinearSegmentedColormap.from_list(
                'my_colormap', colors, N=(vmax or max(obj.values))+1)

        else: cmap = None

        i = 0
        span = list(range(obj.min, obj.max+1))

        while (not obj.stationary() and i < N):

            fig, ax = plt.subplots()
            cax = ax.imshow(
                obj.getMatrix(), interpolation='nearest',
                vmin=obj.min, vmax=obj.max, cmap=cmap
            )

            ax.set_title('CA Plot')
            ax.set_xlabel('x', fontsize=10)
            ax.set_ylabel('y', fontsize=10)

            cbar = fig.colorbar(cax, ticks=span)

            if names:
                cbar.ax.set_yticklabels(names)

            yield fig

            plt.close(fig)
            step(obj)
            i += 1

            # fig = plt.figure(figsize=(10, 7))
            # plt.axis([0, len(obj)]*2)
            # plt.title('CA Plot')
            # plt.xlabel('x', fontsize=fontsize)
            # plt.ylabel('y', fontsize=fontsize)

            # ax = fig.gca()
            # cax = ax.imshow(
            #     obj.getMatrix(), interpolation='nearest',
            #     vmin=min(obj.values), vmax=vmax or max(obj.values),
            #     origin='lower', cmap=cmap, **kwargs
            # )

            # plt.colorbar()

            # yield fig

            # plt.close(fig)
            # step(obj)
            # i += 1


    def plot(obj, colors=None, N=10, fontsize=16, out='out.pdf', vmax=0,
             graphic=False, names=None, plot_zero=True, **kwargs):
        """
        Plots k<=`N` iterations of `obj` into a pdf `out` with colors `colors`.

        Use keyword argument `vmax` to set the maximum possible value in the CA
        if it wasn't included in the object's initialization.

        Setting keyword argument `graphic` to True will plot an additional
        graphic, at the end, showing the concentration of each different
        population during the simulation.

        The keyword argument `plot_zero` is a boolean that determines if the
        zero-th population should be plotted in the concentration graphic. For
        Some CA's, the value zero might mean nothing rather than another
        population, and as such may be an unwanted plot.
        """

        if isinstance(obj, CA):

            if colors != None:
                cmap = LinearSegmentedColormap.from_list(
                    'my_colormap', colors, N=(vmax or max(obj.values))+1)

            else: cmap = None

            i = 0
            with PdfPages(out) as pdf:
                figgen = plotPart(obj, colors=colors, N=N,
                    fontsize=fontsize, vmax=vmax, names=names)

                if not graphic:
                    for fig in figgen: pdf.savefig(fig)

                else:
                    v = (obj.max - obj.min) + 1
                    popcount = []
                    maxv = 0

                    for fig in figgen:
                        popcount.append([0]*v)
                        pdf.savefig(fig)

                        for y in range(len(obj)):
                            for x in range(len(obj)):
                                popcount[i][obj[x, y]] += 1

                        for j in range(1,v):
                            if popcount[i][j] > maxv:
                                maxv = popcount[i][j]

                        i += 1

                    fig = plt.figure(figsize=(10, 7))
                    plt.axis((0, i, 0, maxv))
                    plt.title('Concentration of populations')
                    plt.xlabel('Time', fontsize=fontsize)
                    plt.ylabel('Concentration', fontsize=fontsize)

                    if colors is None:
                        sm = ScalarMappable(
                            cmap=cmap or plt.rcParams['image.cmap'],
                            norm=plt.Normalize(
                                vmin=min(obj.values),
                                vmax=max(obj.values)
                            )
                        )

                        cm = sm.get_cmap()
                        colors = [cm(i/(v-1)) for i in range(v)]

                    if names != None:
                        for pop in range(1 - plot_zero, v):
                            plt.plot(
                                range(i), [popcount[j][pop] for j in range(i)], label=names[pop],
                                color=colors[pop]
                            )
                    else:
                        for pop in range(1 - plot_zero, v):
                            plt.plot(
                                range(i), [popcount[j][pop] for j in range(i)], label=pop,
                                color=colors[pop]
                            )

                    #plt.colorbar(sm)
                    plt.legend()
                    pdf.savefig(fig)
                    plt.close(fig)

        else: raise TypeError("Object `obj` must be an instance/subclass of CA")

except (ImportError, ModuleNotFoundError):
    def plot(*args, **kwargs):
        """
        Raises an error, as Matplotlib is missing or badly configured.
        """

        raise ModuleNotFoundError("This machine does not include Matplotlib")
