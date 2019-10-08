all: main clear

test: test.c
	gcc test.c -o test -llua5.3

main: wolfram.o cfunctions.o conway.o ac.o main.o
	gcc wolfram.o cfunctions.o conway.o ac.o main.o -o main -llua5.3

main.o: main.c ac.c
	gcc -g -c main.c

ac.o: ac.c ac.h rulesets/wolfram.h rulesets/conway.h
	gcc -g -c ac.c

wolfram.o: rulesets/wolfram.c rulesets/wolfram.h ac.h
	gcc -g -c rulesets/wolfram.c

cfunctions.o: rulesets/cfunctions.c rulesets/cfunctions.h
	gcc -g -c rulesets/cfunctions.c -llua5.3

conway.o: rulesets/conway.c rulesets/conway.h rulesets/cfunctions.h
	gcc -g -c rulesets/conway.c -llua5.3

clear:
	rm *.o
