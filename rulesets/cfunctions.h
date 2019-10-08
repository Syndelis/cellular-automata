#ifndef LUA_C_HEADER
#define LUA_C_HEADER

#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>

int _neighbors8(lua_State *L);
void _stackDump(lua_State *L);

#endif