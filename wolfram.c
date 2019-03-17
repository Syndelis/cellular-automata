#include "wolfram.h"
#include "ac.h"

void _initRuleWolfram(WolframRule *target, int rule_number) {
    int i;
    for (i = 0; i < 8; i++)
        target->behavior[i] = ((1 << i) & rule_number) > 0;
}

void _applyWolframRule(Cell **domain, int domain_length, WolframRule *rule, Cell **new) {
    int i;
    for (i = 0; i < domain_length; i++) {
        if (i == 0)
            (*new)[i].state = rule->behavior[
                2*((*domain)[i].state) + (*domain)[i+1].state
            ];
        else if (i == domain_length-1)
            (*new)[i].state = rule->behavior[
                4*((*domain)[i-1].state) + 2*((*domain)[i].state)
            ];
        else
            (*new)[i].state = rule->behavior[
                4*((*domain)[i-1].state) +
                2*((*domain)[i].state) +
                   (*domain)[i+1].state
            ];
    }
}
