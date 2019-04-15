#ifndef CONWAY_HEADER
#define CONWAY_HEADER


#include "../lua_src/lua.h"
#include "../lua_src/lualib.h"
#include "../lua_src/lauxlib.h"

typedef struct _ConwayRule {
    lua_State *L;
} ConwayRule;

#include "../ac.h"

void _initRuleConway(ConwayRule *target);
void _applyRuleConway(ConwayRule *rule);
void _displayRuleConway(ConwayRule *rule);
void _freeDomainConway(ConwayRule *rule);

#endif
