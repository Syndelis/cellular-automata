#ifndef CONWAY_HEADER
#define CONWAY_HEADER

#define PY_SSIZE_T_CLEAN
#include <python3.7m/Python.h>

typedef struct _ConwayRule {
    PyObject *pModule;
    int dimensions;
} ConwayRule;

#include "../ac.h"

void _initRuleConway(ConwayRule *target, void **param);
void _applyRuleConway(ConwayRule *rule);
void _displayRuleConway(ConwayRule *rule);
void _freeDomainConway(ConwayRule *rule);

#endif
