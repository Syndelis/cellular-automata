#include "wolfram.h"
#include "../ac.h"
#include <stdlib.h>
#include <stdio.h>


void _initRuleWolfram(WolframRule *target, int rule_number) {
    target->behavior = rule_number;
}

void _applyRuleWolfram(Cell **domain, int domain_length, WolframRule *rule, Cell **new) {
    int i;
    for (i = 0; i < domain_length; i++) {
        if (i == 0)
            (*new)[i].state = (rule->behavior &\
                (1 << (2*((*domain)[i].state) + (*domain)[i+1].state))) > 0;
        else if (i == domain_length-1)
            (*new)[i].state = (rule->behavior &\
                (1 << (4*((*domain)[i-1].state) + 2*((*domain)[i].state)))) > 0;
        else
            (*new)[i].state = (rule->behavior &\
                (1 << (4*((*domain)[i-1].state) + 2*((*domain)[i].state) +\
                ((*domain)[i+1].state)))) > 0;
    }
}

void _freeDomainWolfram(Cell **domain, int domain_length) {
    free(*domain);
    free(domain);
}
