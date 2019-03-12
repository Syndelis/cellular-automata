all: main clear

main: ac.o main.o
	gcc ac.o main.o -o main

main.o: main.c ac.c
	gcc -g -c main.c

ac.o: ac.c ac.h
	gcc -g -c ac.c


clear:
	rm *.o
