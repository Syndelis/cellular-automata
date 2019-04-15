all: main clear

test: test.c
	gcc test.c -o test -llua5.3 -I/lua_src

main: wolfram.o conway.o ac.o main.o
	gcc wolfram.o conway.o ac.o main.o -o main -llua5.3 -I/lua_src

main.o: main.c ac.c
	gcc -g -c main.c

ac.o: ac.c ac.h rulesets/wolfram.h
	gcc -g -c ac.c

wolfram.o: rulesets/wolfram.c rulesets/wolfram.h ac.h
	gcc -g -c rulesets/wolfram.c

conway.o: rulesets/conway.c rulesets/conway.h
	gcc -g -c rulesets/conway.c -llua5.3 -I/lua_src

clear:
	rm *.o
