#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>
#include "cfunctions.h"

int _neighbors8(lua_State *L) {
    int dx, dy, u, v, k, x, y;
    lua_settop(L, 3);

    lua_setglobal(L, "paramtable");
    x = lua_tonumber(L, -2);
    y = lua_tonumber(L, -1);

    lua_createtable(L, 8, 0);
    lua_setglobal(L, "ret");

    for (k = 1, dx = -1, u = 0; dx <= 1; dx++, u++) {
        for (dy = -1, v = 0; dy <= 1; dy++, v++, k++) {
            if (!(dx == 0 && dy == 0)) {
                lua_settop(L, 0);
                lua_getglobal(L, "ret");
                lua_pushinteger(L, k);

                lua_getglobal(L, "paramtable");
                lua_pushinteger(L, x+dx);
                lua_gettable(L, -2); // Retrieves the array in the x+dx row of the matrix

                if (lua_type(L, -1) == LUA_TNIL) lua_pushnil(L);
                else {
                    lua_pushinteger(L, y+dy);
                    lua_gettable(L, -2);
                }

                // _stackDump(L);

                lua_remove(L, 3);
                lua_remove(L, 3);

                lua_settable(L, 1);
            } else k--;
        }
    }
    lua_settop(L, 0);

    lua_getglobal(L, "ret");

    lua_pushnil(L);
    lua_setglobal(L, "ret");
    
    lua_pushvalue(L, -1);
    return 1;
}