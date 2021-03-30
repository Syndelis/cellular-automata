all: cythonModule

cythonModule: ca.pyx
	python3 setup.py build --build-lib .

clean:
	rm ca.cpython*
	rm *.o
