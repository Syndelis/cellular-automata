// #include "../lua_src/lua.h"
// #include "../lua_src/lualib.h"
// #include "../lua_src/lauxlib.h"
#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>
#include "../ac.h"
#include "conway.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void _stackDump(lua_State *L) {
    int i;
    int top = lua_gettop(L);
    for (i = 1; i <= top; i++) {  /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {

          case LUA_TSTRING:  /* strings */
            printf("`%s'", lua_tostring(L, i));
            break;

          case LUA_TBOOLEAN:  /* booleans */
            printf(lua_toboolean(L, i) ? "true" : "false");
            break;

          case LUA_TNUMBER:  /* numbers */
            printf("%g", lua_tonumber(L, i));
            break;

          default:  /* other values */
            printf("%s", lua_typename(L, t));
            break;

        }
        printf("  ");  /* put a separator */
     }
     printf("\n");  /* end the listing */
}

static int _neighbors8(lua_State *L) {
    int i, j, u, v, k, x, y;

    x = lua_tonumber(L, -1);
    y = lua_tonumber(L, -1);

    lua_createtable(L, 8, 0);
    lua_setglobal(L, "ret");

    for (k = 1, i = -1, u = 0; i <= 1; i++, u++) {
        lua_getglobal(L, "ret");
        lua_getglobal(L, "inst");
        lua_getfield(L, -1, "domain");
        lua_pushinteger(L, x+i);
        lua_gettable(L, -2);
        for (j = -1, v = 0; j <= 1; j++, v++, k++) {
            lua_pushinteger(L, y+j);
            lua_gettable(L, -2 -v);
            lua_pushinteger(L, k);
            lua_pushvalue(L, -2);
            lua_settable(L, -7 -v);
        }
        lua_settop(L, 0);
    }

    lua_getglobal(L, "ret");

    // new block, may cause problems
    lua_pushnil(L);
    lua_setglobal(L, "ret");
    lua_pushvalue(L, -2);
    return 1;
}

void _initLuaEnv(lua_State *L) {
    lua_pushnil(L);
    lua_setglobal(L, "os");

    lua_pushcfunction(L, _neighbors8);
    lua_setglobal(L, "neighbors8");
}

void _initRuleConway(ConwayRule *target, void **param) {

    target->dimensions = *(int*)param[0];

    target->L = luaL_newstate();
    luaL_openlibs(target->L);
    _initLuaEnv(target->L); // new compared to master
    luaL_dofile(target->L, (char*)param[1]);
    lua_setglobal(target->L, "conway");
    lua_settop(target->L, 0);

    lua_newtable(target->L);
    lua_setglobal(target->L, "inst");

    lua_getglobal(target->L, "conway");
    lua_getfield(target->L, -1, "onInit");
    lua_getglobal(target->L, "inst");
    lua_pushinteger(target->L, target->dimensions);
    lua_call(target->L, 2, 0); // Breaking the program
    lua_settop(target->L, 0);
}

void _applyRuleConway(ConwayRule *rule) {
    _displayRuleConway(rule);
    lua_getglobal(rule->L, "conway");
    lua_getfield(rule->L, -1, "onUpdate");
    lua_getglobal(rule->L, "inst");
    lua_call(rule->L, 1, 0);
}

void _displayRuleConway(ConwayRule *rule) {
    // lua_getglobal(rule->L, "conway");
    // lua_getfield(rule->L, -1, "onDisplay");
    // lua_getglobal(rule->L, "inst");
    // lua_call(rule->L, 1, 0);

    int i, j;
    char str[2];

    usleep(125000);
    system("clear");

    for (i = 0; i < rule->dimensions; i++) {
        lua_getglobal(rule->L, "inst");
        lua_getfield(rule->L, -1, "domain");
        lua_pushinteger(rule->L, i+1);
        lua_gettable(rule->L, -2);
        for (j = 0; j < rule->dimensions; j++) {
            lua_pushinteger(rule->L, j+1);
            lua_gettable(rule->L, -2-j);
            printf("\033[%dm  ", 47+2*((int)lua_tonumber(rule->L, -1)));
            // printf("%d ", (int)lua_tonumber(rule->L, -1));
        }
        lua_settop(rule->L, 0);
        printf("\033[m\n");
    }

}

void _freeDomainConway(ConwayRule *rule) {
    lua_close(rule->L);
}
