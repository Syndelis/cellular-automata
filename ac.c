#include "ac.h"
#include "rulesets/wolfram.h"
#include <stdio.h>
#include <stdlib.h>

Cell **applyRule(Cell **domain, int domain_length, GeneralRule *rule) {
    // Receives the current state of the domain and returns
    // the new state, based on the GeneralRule being used

    int i;
    Cell **new = NULL;
    switch (rule->type) {
        case typeWolfram:
            new = initDomain(rule, &domain_length);
            _applyRuleWolfram(domain, domain_length, rule->wolfram, new);
            _displayDomain(domain, domain_length);
            break;

        case typeConway:
            _applyRuleConway(rule->conway);
    }

    return new;
}

GeneralRule *initRule(int type, void **param) {
    GeneralRule *target = (GeneralRule*)malloc(sizeof(GeneralRule));
    switch (type) {
        case typeWolfram:
            target->type = typeWolfram;
            target->wolfram = (WolframRule*)malloc(sizeof(WolframRule));
            _initRuleWolfram(target->wolfram, *(int*)param[0]);
            break;

        case typeConway:
            target->type = typeConway;
            target->conway = (ConwayRule*)malloc(sizeof(ConwayRule));
            _initRuleConway(target->conway, param);
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
            if (!(*domain_length % 2)) (*domain_length)--;
            domain = (Cell**) malloc(sizeof(Cell*));
            *domain = (Cell*) malloc(sizeof(Cell) * *domain_length);

            int i;
            for (i = 0; i < *domain_length; i++)
                (*domain)[i].state = 0;

            (*domain)[*domain_length/2].state = 1;
            break;

        default:
            *domain_length = 0;
            break;
    }

    return domain;
}

void freeDomain(Cell **domain, int domain_length, GeneralRule *rule) {
    switch (rule->type) {
        case typeWolfram:
            _freeDomainWolfram(domain, domain_length);
            break;
        case typeConway:
            _freeDomainConway(rule->conway);
        default:
            break;
    }
}

void freeRule(GeneralRule *rule) {
    switch (rule->type) {
        case typeWolfram:
            free(rule->wolfram);
            break;

        case typeConway:
            free(rule->conway);
            break;
    }

    free(rule);
}

void _displayDomain(Cell **domain, int domain_length) {
    int i;
    for (i = 0; i < domain_length; i++)
        printf("\033[%dm  ", 47 + 2*(*domain)[i].state);
        //printf("%d", (*domain)[i].state);
    //printf("\n");
    printf("\033[m\n");
}
