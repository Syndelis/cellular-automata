#include <stdio.h>
#include <stdlib.h>
#include "lua_src/lua.h"
#include "lua_src/lualib.h"
#include "lua_src/lauxlib.h"


int main() {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
    luaL_dostring(L, "x = {{1,2,3},{4,5,6},{7,8,9},{10,11,12},{13,14,15}}");

	int i, j;
	for (i = 0; i < 5; i++) {
		lua_getglobal(L, "x");
		lua_pushinteger(L, i+1);
		lua_gettable(L, -2);
		for (j = 0; j < 3; j++) {
			printf("x[%d][%d]: ", i+1, j+1);
			lua_pushinteger(L, j+1);
			lua_gettable(L, -2-j);
			printf("%d\n", (int)lua_tonumber(L,-1));
		}
	}
	printf("Now lua\n");
	luaL_dostring(L, "for i=1,5 do for j=1,3 do print('x[' .. i .. '][' .. j .. ']: ' .. x[i][j]) end end");
	// for (i = 0; i < 3; i++) {
	// 	lua_getglobal(L, "x");
	// 	lua_pushinteger(L, i+1);
	// 	lua_gettable(L, -2);
	// 	printf("i step %d, ", i);
	// 	for (j = 0; j < 3; j++) {
	// 		lua_pushinteger(L, j+1);
	// 		lua_gettable(L, -2-j*2);
	// 		printf("j step %d\n", j);
	// 		printf("%f ", lua_tonumber(L, -1));
	// 	}
	// 	printf("\n");
	// }

    lua_close(L);
	return 0;
}
