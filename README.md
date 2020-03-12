### cellular-automata
An object oriented Cython-based Python library for making and visualizing [Cellular Automata](https://en.wikipedia.org/wiki/Cellular_automaton). It should be able to execute and plot any Wolfram (**WIP**) or 2D automaton.

[TOC]

#### Compiling
If you wish to not use the pre-built binaries and compile the code yourself, good news! It's fairly simple. All you need to do is meet the dependencies:
- Python 3.7+
- python3-dev
- cython
- [Optional for graphical plot] matplotlib

#### Usage
To get started, you'll need to import the library and instantiate the CA class. The only required parameter is the dimension of the *square* grid.
```python
>>> from ca import *
>>> c = CA(30) # Initializes a 30x30 grid.
```
With that done, you can proceed to plot the automaton.
```python
>>> plot(c)
```
That will create the file "out.pdf" which contains *up to* 10 steps from a randomly generated 30x30 board. By default, the CA rule is [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).
<br />
Of course, Conway's Game of Life may not be the only thing you want to plot, so you'll want to modify the rules. In order to do so, you need to inherit from the base CA class and overwrite the `rule()` method.
```python
from ca import *

class T(CA):

	# This function is ran for each cell in the grid and expects the
	# new value for the cell to be returned
	def rule(self, x, y):
		s = self[x, y] # Gets the current value from the cell at (x, y) on the grid
		if (s > 0): s -= 1
		
		return s # Updates such cell by returning a new value

c = T(30, values=5) # Creates a 30x30 grid with random values ranging from 0 to 4
plot(c)
```
If you run the above example, you'll get something that looks like this
![](https://i.imgur.com/fDZTkF6.png)
<br />
For more examples to help you understand the parameters and how they work, check the examples folder. You may also check the description of methods and classes with the `help()` function.
```python
>>> import ca
>>> help(ca)
```