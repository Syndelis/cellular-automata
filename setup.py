# Cython compiler

from distutils.core import setup
from Cython.Build import cythonize

setup(name="Cython class module",
      ext_modules=cythonize("rulesets/ca.pyx"))