try:
    from ca import *

except ModuleNotFoundError:
    from sys import path
    path.insert(0, '..')
    from ca import *
    
from time import sleep
from sys import argv

class CGL(CA):
    def prettyPrint(self, x, y):
        return b"\033[%dm  \033[m" % (47+2*self[x, y])

c = CGL(30)

try:
    if len (argv) > 1:
        while not c.stationary():
            draw(c)
            step(c)
            sleep(0.15)

    else: plot(c, N=50, colors=['white', 'black'], out='game-of-life.pdf')

except KeyboardInterrupt: pass