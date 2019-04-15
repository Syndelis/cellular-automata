#ifndef WOLFRAM_HEADER
#define WOLFRAM_HEADER

// Represents the Elementary Cellular Automata
typedef struct _WolframRule {
    // old implementation
    // int behavior[8];
    // This version used to use 32 bytes when only 1 was needed

    char behavior;
    // eight behaviors, from 0b000 to 0b111, which represent the state of
    // the left cell, center cell and right cell
} WolframRule;

#include "../ac.h"

void _initRuleWolfram(WolframRule *target, int rule_number);
void _applyRuleWolfram(Cell **domain, int domain_length, WolframRule *rule, Cell **new);
void _freeDomainWolfram(Cell **domain, int domain_length);

#endif
