#ifndef AC_HEADER
#define AC_HEADER


enum RuleTypes {
    typeWolfram, type2D
};

typedef struct _Cell {
    int state;
    // More to be added
} Cell;

#include "wolfram.h"

typedef struct _GeneralRule {
    int type;
    union {
        WolframRule *wolfram;
    };
} GeneralRule;

Cell **applyRule(Cell **domain, int domain_length, GeneralRule *rule);
GeneralRule *initRule(int type, void* param);

Cell **initDomain(GeneralRule *rule, int *domain_length);
void _displayDomain(Cell **domain, int domain_length);

#endif
