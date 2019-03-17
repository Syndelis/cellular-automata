#include "ac.h"
#include "wolfram.h"
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
            _applyRuleWolfram(domain, domain_length, rule->wolfram, new);
            break;
    }

    return new;
}

GeneralRule *initRule(int type, void *param) {
    GeneralRule *target = (GeneralRule*)malloc(sizeof(GeneralRule));
    switch (type) {
        case typeWolfram:
            target->type = typeWolfram;
            target->wolfram = (WolframRule*)malloc(sizeof(WolframRule));
            _initRuleWolfram(target->wolfram, *(int*)param);
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

void freeDomain(Cell **domain, int domain_length, GeneralRule *rule) {
    switch (rule->type) {
        case typeWolfram:
            _freeDomainWolfram(domain, domain_length);
            break;
        default:
            break;
    }
}

void _displayDomain(Cell **domain, int domain_length) {
    int i;
    for (i = 0; i < domain_length; i++)
        printf("\033[%dm  ", 47 + 2*(*domain)[i].state);
        //printf("%d", (*domain)[i].state);
    //printf("\n");
    printf("\033[m\n");
}
