try:
    from ca import *

except ModuleNotFoundError:
    from sys import path
    path.insert(0, '..')
    from ca import *

from random import randint

class MOVE(CA):
    def rule(self, x, y):
        s = self[x, y]
        if s == self.getOld(x, y):
            if s == 1:
                n = [i for i in neighbors8(self, x, y, pos=True) if self[i] !=1]
                p = n[randint(0, len(n)-1)]
                self.move(x, y, *p)
                return self[x, y]

            else: return s
        else: return s

c = MOVE(30, values=[0]*200+[1])
plot(c, N=50, out="movement.pdf")
