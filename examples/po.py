try:
    from ca import *

except ModuleNotFoundError:
    from sys import path
    path.insert(0, '..')
    from ca import *

from time import sleep
from random import random
from sys import argv

global k, p
k = 5
p = 1

class PO(CA):
    def rule(self, x, y):
        global k, p

        neighbors = neighbors8(self, x, y)
        exc = len([i for i in neighbors if i == 1])
        s = self[x, y]

        if s == 0: # normal
            if (random() < p and exc >= 2):
                return 1 # excitado
            else: return 0

        else: return (s+1) % k

    def prettyPrint(self, x, y):
        return b"\033[%dm  \033[m" % (self[x, y] + 41)

c = PO(30, values=k, random_values=False)
c.add(1, points=[(10, 10)], size=(10, 10))
c.add(0, points=[(11, 11)], size=(8, 8))

try:
    if len(argv) > 1:
        while (not c.stationary()):
            print("\033[H\033[2J")
            draw(c)
            step(c)
            sleep(0.8)

    else: plot(c, N=50, out="po.pdf")

except KeyboardInterrupt: pass
