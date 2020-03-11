from ca import *
from random import randint
from time import sleep

class SAND(CA):

    def rule(self, x, y):
        x2 = x + randint(0, 3)-1
        if (x2 < len(self) and x2 >= 0 and y-1 < len(self) and y > 0):
            neighbor = self[x2, y-1]
            if neighbor == 0:
                self.move(x, y, x2, y-1)

        return self[x, y]

c = SAND(30, random_values=False)
c.add(value=1, points=[(10, 10)], size=(5, 5))
plot(c, N=20, out="sand.pdf", graphic=True)