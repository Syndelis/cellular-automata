from ca import *
from time import sleep

class CGL(CA):
    def prettyPrint(self, x, y):
        return b"\033[%dm  \033[m" % (47+2*self[x][y])

c = CGL(30)

for i in range(100):
    draw(c)
    step(c)
    sleep(0.15)