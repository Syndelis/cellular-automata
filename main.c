#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ac.h"

int main(int argc, char **argv) {
    // the main program only processes wolfram ACs at the moment
    if (argc >= 3) {
        GeneralRule *rule;

        if (strcmp(argv[1], "wolfram") == 0) {
            void *rule_number = (void*)(int*)malloc(sizeof(int));
            *(int*)rule_number = atoi(argv[2]);
            rule = initRule(typeWolfram, rule_number);

            free(rule_number);
        }
        int domain_length = 0;
        Cell **domain = initDomain(rule, &domain_length);
        Cell **new;

        int times = argc > 3 ? atoi(argv[3]) : 10;
        int i, j;
        for (i = 0; i < times; i++) {
            new = applyRule(domain, domain_length, rule);

            for (j = 0; j < domain_length; j++)
                (*domain)[j].state = (*new)[j].state;
        }
    }
    else printf(
            "Insufficient number of parameters. "
            "%d were needed but %d were provided\n", 2, argc
        );

    return 0;
}
