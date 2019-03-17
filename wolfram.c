#include "wolfram.h"
#include "ac.h"
#include <stdlib.h>
#include <stdio.h>


void _initRuleWolfram(WolframRule *target, int rule_number) {
    // old implementation
    // int i;
    // for (i = 0; i < 8; i++)
    //     target->behavior[i] = ((1 << i) & rule_number) > 0;
    target->behavior = rule_number;
}

void _applyRuleWolfram(Cell **domain, int domain_length, WolframRule *rule, Cell **new) {
    int i;
    for (i = 0; i < domain_length; i++) {
        if (i == 0)
            // old implementation
            // (*new)[i].state = rule->behavior[
            //     2*((*domain)[i].state) + (*domain)[i+1].state
            // ];
            (*new)[i].state = (rule->behavior &\
                (1 << (2*((*domain)[i].state) + (*domain)[i+1].state))) > 0;
        else if (i == domain_length-1)
            // old implementation
            // (*new)[i].state = rule->behavior[
            //     4*((*domain)[i-1].state) + 2*((*domain)[i].state)
            // ];
            (*new)[i].state = (rule->behavior &\
                (1 << (4*((*domain)[i-1].state) + 2*((*domain)[i].state)))) > 0;
        else
            // old implementation
            // (*new)[i].state = rule->behavior[
            //     4*((*domain)[i-1].state) +
            //     2*((*domain)[i].state) +
            //        (*domain)[i+1].state
            // ];
            (*new)[i].state = (rule->behavior &\
                (1 << (4*((*domain)[i-1].state) + 2*((*domain)[i].state) +\
                ((*domain)[i+1].state)))) > 0;
    }
}

void _freeDomainWolfram(Cell **domain, int domain_length) {
    free(*domain);
    free(domain);
}
