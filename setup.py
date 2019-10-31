# Cython compiler

from distutils.core import setup
from Cython.Build import cythonize

setup(name='CA base class', ext_modules=cythonize("rulesets/ca.pyx"))