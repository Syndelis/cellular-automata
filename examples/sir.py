try:
    from ca import *

except ModuleNotFoundError:
    from sys import path
    path.insert(0, '..')
    from ca import *
    
from time import sleep
from sys import argv

# 41 -> red     infected
# 42 -> green   sucsetible
# 43 -> yellow  immune

class SIR(CA):
    def rule(self, x, y):
        s = self[x, y]
        n = neighbors8(self, x, y)

        inf = 0
        suc = 0
        imm = 0

        for i in n:
            if   i == 0: inf += 1
            elif i == 1: suc += 1
            else:        imm += 1

        if s == 0: # infected
            if imm > 1: return 2 # immune
            else: return 0

        elif s == 1: # sucsetible
            if   imm > 3: return 2
            elif inf > 1: return 0
            else: return 1

        elif s == 2: return 2

    def prettyPrint(self, x, y):
        return b"\033[%dm  \033[m" % (41+self[x, y])

c = SIR(30, values=(1, 1, 1, 1, 1, 0, 2))

try:
    if len(argv) > 1:
        while not c.stationary():
            draw(c)
            step(c)
            sleep(0.3)
    else:
        plot(
            c, N=50, out='sir.pdf', graphic=True, vmax=2,
            colors=['red', 'green', 'orange'],
            names=['infected', 'susceptible', 'immune']
        )

except KeyboardInterrupt: pass
