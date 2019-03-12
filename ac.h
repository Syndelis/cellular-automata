#ifndef AC_HEADER
#define AC_HEADER

enum RuleTypes {
    typeWolfram, type2D
};

// Represents the Elementary Cellular Automata
typedef struct _WolframRule {
    int behavior[8];
    // eight behaviors, from 0b000 to 0b111, which represent the state of
    // the left cell, center cell and right cell
} WolframRule;

typedef struct _GeneralRule {
    int type;
    WolframRule *wolfram;
} GeneralRule;

typedef struct _Cell {
    int state;
    // More to be added
} Cell;

Cell **applyRule(Cell **domain, int domain_length, GeneralRule *rule);


void _initRuleWolfram(GeneralRule *target, int rule_number);
GeneralRule *initRule(int type, void* param);

Cell **initDomain(GeneralRule *rule, int *domain_length);

void _displayDomain(Cell **domain, int domain_length);

#endif
