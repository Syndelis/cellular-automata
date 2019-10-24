
cdef class CA:
    """
    The Cellular-Automata class for setting up rules, executing and displaying
    results.
    """

    # Initialization: Domain Size, Initialization method and Rule function
    cdef __cinit__(self, int size): pass

    # C method for executing a step
    # `cpdef` because it needs to be visible to Python, but fast as C
    # (needs to be overwritten by subclass)
    cpdef __step__(self): pass

    # Python method for getting the Neighbors from said position
    def __neighbors8__(self, int x, int y): pass

    # C method for drawing the result
    # `cpdef` beucase it needs to be visible to Python, but fast as C
    # (needs to be overwritten by subclass)
    cpdef __draw__(self): pass