#include <python3.7m/Python.h>
#include "../ac.h"
#include "conway.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * https://docs.python.org/3/extending/embedding.html
 * https://cython.readthedocs.io/en/latest/src/quickstart/cythonize.html
 * https://cython.readthedocs.io/en/latest/src/tutorial/cdef_classes.html
 * https://cython.readthedocs.io/en/latest/src/userguide/special_methods.html
 * https://cython.readthedocs.io/en/latest/src/userguide/extension_types.html#existing-pointers-instantiation
 */

void _initRuleConway(ConwayRule *target, void **param) {
    
    target->dimensions = *(int*)param[0];
    PyObject *pName = PyUnicode_DecodeFSDefault((char*)param[1]);

    target->pModule = PyImport_Import(pName);
    Py_DECREF(pName);

    if (target->pModule != NULL); // Do setup stuff

    /*
     * At the end, the function must have:
     *      Initialized Python/Cython
     *      Ran whichever `file.py` was passed as parameter
     *      Instantiated the main class on `file.py` with given `**param`
     */
}

// void _applyRuleConway(ConwayRule *rule) -> Calls CA().__step__()

// void _displayRuleConway(ConwayRule *rule) -> Calls CA().__draw__()

// void _freeDomainConway(ConwayRule *rule) {
//     lua_close(rule->L);
// }
