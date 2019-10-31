from ca import *
from time import sleep

class CGL(CA):
    def prettyPrint(self, x, y):
        return b"\033[%dm  \033[m" % (47+2*self[x][y])

c = CGL(30)

while not c.stationary():
    draw(c)
    step(c)
    sleep(0.15)
