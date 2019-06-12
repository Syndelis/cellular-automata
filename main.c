#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ac.h"

int main(int argc, char **argv) {

    // Parameters:
    // ./main -m wolfram (-r rule_number) [-d domain_length] [-n iterations]
    // ./main -m conway (-f filename) [-d domain_dimensions] [-n iterations]

    if (argc < 3) {
        printf(
            "Insufficient number of parameters. "
            "%d were needed but %d were provided\n", 3, argc
        );
        return 0;
    }

    int c;

    int DOMAIN_LENGTH = 32, ITER = 10;
    int WOLFRAM_RULENUMBER = -1;
    char *CONWAY_FILE = NULL, *MODE = NULL;

    while ((c = getopt(argc, argv, ":m:r:f:d:n:")) != -1)
        switch (c) {
            case 'm':
                MODE = (char*) malloc(sizeof(char)*(strlen(optarg)+1));
                strcpy(MODE, optarg);
                break;

            case 'r':
                WOLFRAM_RULENUMBER = atoi(optarg);
                break;

            case 'f':
                CONWAY_FILE = (char*) malloc(sizeof(char)*(strlen(optarg))+1);
                strcpy(CONWAY_FILE, optarg);
                break;

            case 'd':
                DOMAIN_LENGTH = atoi(optarg);
                break;
            
            case 'n':
                ITER = atoi(optarg);
                break;

            case '?':
                printf("Unknown option `%c`. Ignoring...\n", optopt);
                break;
        }

    GeneralRule *rule;

    if (strcmp(MODE, "wolfram") == 0) {
        void *rule_number = (void*)(int*)malloc(sizeof(int));
        *(int*)rule_number = WOLFRAM_RULENUMBER;
        rule = initRule(typeWolfram, &rule_number);

        free(rule_number);
    }
    else if (strcmp(MODE, "conway") == 0) {
        void **param = (void**)malloc(sizeof(void*)*2);
        param[0] = (void*)(int*)malloc(sizeof(int));
        param[1] = (void*)(char*)malloc(sizeof(char)*30);

        *(int*)(param[0]) = DOMAIN_LENGTH;
        
        if (CONWAY_FILE) strcpy((char*)param[1], CONWAY_FILE);
        else strcpy((char*)(param[1]), "conway.lua");

        rule = initRule(typeConway, param);
    }
    else {
        printf("Unknown mode `%s`. Aborting...\n", MODE);
        if (MODE) free(MODE);
        return 0;
    }

    int domain_length = DOMAIN_LENGTH;
    Cell **domain = initDomain(rule, &domain_length);
    Cell **new;

    int i, j;
    for (i = 0; i < ITER; i++) {
        new = applyRule(domain, domain_length, rule);
        for (j = 0; j < domain_length; j++)
            (*domain)[j].state = (*new)[j].state;

        if (new != NULL) freeDomain(new, domain_length, rule);
    }

    freeDomain(domain, domain_length, rule);
    freeRule(rule);
    free(MODE);
    if (CONWAY_FILE) free(CONWAY_FILE);

    return 0;
}
