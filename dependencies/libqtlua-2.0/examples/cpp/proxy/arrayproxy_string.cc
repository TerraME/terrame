/*
    This file is part of LibQtLua.

    LibQtLua is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    LibQtLua is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with LibQtLua.  If not, see <http://www.gnu.org/licenses/>.

    Copyright (C) 2008, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

// This example show how to use an ArrayProxy object to access a C array
// object from lua script.

#include <iostream>

#include <QtLua/State>
#include <QtLua/String>
#include <QtLua/ArrayProxy>

int main()
{
  try {
							/* anchor 1 */
    QtLua::String array[4];

    // Array proxy which provides access to our array from lua.
    QtLua::ArrayProxy<QtLua::String> proxy(array, 4);
							/* anchor 2 */

    QtLua::State state;
    state.openlib(QtLua::QtLuaLib);
							/* anchor end */
    state.enable_qdebug_print(true);
							/* anchor 2 */

    // Declare a lua global variable using our array proxy
    state["array"] = proxy;

    // Set a value in array
    array[0] = "foo";

    // Read/Write array from lua using the proxy object
    state.exec_statements("array[2] = array[1]..\"bar\" ");

							/* anchor 3 */
    // Read back value in array modified from lua script
    std::cout << array[1].constData() << std::endl;

    // Iterate through array from lua script
    state.exec_statements("for key, value in each(array) do print(key, value) end");
							/* anchor end */

  } catch (QtLua::String &e) {
    std::cerr << e.constData() << std::endl;
  }

}

