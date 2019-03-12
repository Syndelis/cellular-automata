#include "ac.h"
#include <stdio.h>
#include <stdlib.h>

Cell **applyRule(Cell **domain, int domain_length, GeneralRule *rule) {
    // Receives the current state of the domain and returns
    // the new state, based on the GeneralRule being used

    int i;
    _displayDomain(domain, domain_length);
    Cell **new = initDomain(rule, &i); // dummy 'i'

    switch (rule->type) {
        case typeWolfram:
            for (i = 0; i < domain_length; i++) {
                if (i == 0)
                    (*new)[i].state = rule->wolfram->behavior[
                        2*((*domain)[i].state) + (*domain)[i+1].state
                    ];
                else if (i == domain_length-1)
                    (*new)[i].state = rule->wolfram->behavior[
                        4*((*domain)[i-1].state) + 2*((*domain)[i].state)
                    ];
                else
                    (*new)[i].state = rule->wolfram->behavior[
                        4*((*domain)[i-1].state) +
                        2*((*domain)[i].state) +
                           (*domain)[i+1].state
                    ];
            }
            break;
    }

    return new;
}

void _initRuleWolfram(GeneralRule *target, int rule_number) {
    int i;
    for (i = 0; i < 8; i++)
        target->wolfram->behavior[i] = ((1 << i) & rule_number) > 0;
}

GeneralRule *initRule(int type, void *param) {
    GeneralRule *target = (GeneralRule*)malloc(sizeof(GeneralRule));
    switch (type) {
        case typeWolfram:
            target->type = typeWolfram;
            target->wolfram = (WolframRule*)malloc(sizeof(WolframRule));
            _initRuleWolfram(target, *(int*)param);
            break;

        default:
            break;
    }

    return target;
}

Cell **initDomain(GeneralRule *rule, int *domain_length) {
    Cell **domain;

    switch (rule->type) {
        case typeWolfram:
            domain = (Cell**)malloc(sizeof(Cell*));
            *domain = (Cell*)malloc(sizeof(Cell) * 31); // 0 to 30

            int i;
            for (i = 0; i < 31; i++)
                (*domain)[i].state = 0;

            (*domain)[15].state = 1;
            *domain_length = 31;
            break;

        default:
            break;
    }

    return domain;
}

void _displayDomain(Cell **domain, int domain_length) {
    int i;
    for (i = 0; i < domain_length; i++)
        printf("\033[%dm  ", 47 + 2*(*domain)[i].state);
        //printf("%d", (*domain)[i].state);
    //printf("\n");
    printf("\033[m\n");
}
