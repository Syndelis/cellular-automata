all: cythonModule

cythonModule: ca.pyx
	python3 setup.py build --build-lib .

clear:
	rm *.o
