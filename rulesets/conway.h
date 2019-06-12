#ifndef CONWAY_HEADER
#define CONWAY_HEADER

#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>

typedef struct _ConwayRule {
    lua_State *L;
    int dimensions;
} ConwayRule;

#include "../ac.h"

void _initRuleConway(ConwayRule *target, void **param);
void _applyRuleConway(ConwayRule *rule);
void _displayRuleConway(ConwayRule *rule);
void _freeDomainConway(ConwayRule *rule);

#endif
