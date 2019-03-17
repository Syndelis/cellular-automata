all: main clear

main: wolfram.o ac.o main.o
	gcc wolfram.o ac.o main.o -o main

main.o: main.c ac.c
	gcc -g -c main.c

ac.o: ac.c ac.h wolfram.h
	gcc -g -c ac.c

wolfram.o: wolfram.c wolfram.h ac.h
	gcc -g -c wolfram.c

clear:
	rm *.o
