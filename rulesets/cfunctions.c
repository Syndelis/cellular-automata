#include <lua5.3/lua.h>
#include <lua5.3/lualib.h>
#include <lua5.3/lauxlib.h>
#include "cfunctions.h"

int _neighbors8(lua_State *L) {
    int dx, dy, u, v, k, x, y;
    int n = lua_gettop(L); // Number of parameters passed

    // _stackDump(L);

    lua_setglobal(L, "paramtable");
    x = lua_tonumber(L, -n+1);
    y = lua_tonumber(L, -n+2);

    int function_argument = n > 3;
    if (function_argument)
        lua_setglobal(L, "_filter"); // Function used to filter neighbors

    int function_return = 0;

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

                // _stackDump(L);

                lua_gettable(L, -2); // Retrieves the array in the x+dx row of the matrix

                if (lua_type(L, -1) == LUA_TNIL) lua_pushnil(L);
                else if (function_argument) {
                    lua_getglobal(L, "_filter");
                    lua_pushvalue(L, -2);
                    lua_pushinteger(L, x+dx);
                    lua_pushinteger(L, y+dy);                    
                    lua_call(L, 3, 1);
                    function_return = lua_toboolean(L, -1);

                    if (function_return) {
                        lua_pushinteger(L, y+dy);
                        lua_gettable(L, -2);
                    }
                    else lua_pushnil(L);
                }
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