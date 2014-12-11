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

// This example show how to use the QtLua::DispatchProxy class to
// create a composite UserData object.

#include <iostream>

#include <QMap>

#include <QtLua/State>
#include <QtLua/QHashProxy>
#include <QtLua/DispatchProxy>

							/* anchor 1 */
typedef QMap<QtLua::String, QtLua::String> Container;

class Composite : public QtLua::DispatchProxy
{
public:

  Composite()
    : _c1_proxy(_c1)
    , _c2_proxy(_c2)
  {
    // references to underlying objects will count as a reference to this
    _c1_proxy.ref_delegate(this);
    _c2_proxy.ref_delegate(this);

    // populate read-only hash c1
    _c1.insert("a", "1");
    _c1.insert("b", "2");

    // populate hash c2
    _c2.insert("c", "3");
    _c2.insert("d", "4");

    // register hash proxies
    add_target(&_c1_proxy);
    add_target(&_c2_proxy);
  }

private:
  Container _c1;
  QtLua::QHashProxyRo<Container> _c1_proxy;
  Container _c2;
  QtLua::QHashProxy<Container> _c2_proxy;
};
							/* anchor end */
/* ... */
int main()
{
  try {
							/* anchor 2 */
    Composite proxy;

    QtLua::State state;
    state.openlib(QtLua::QtLuaLib);
							/* anchor end */
    state.enable_qdebug_print(true);
							/* anchor 2 */

    // Declare a lua global variable using our composite proxy
    state["composite"] = proxy;

    // Iterate through Composite object from lua script
    state.exec_statements("for key, value in each(composite) do print(key, value) end");
							/* anchor end */

  } catch (QtLua::String &e) {
    std::cerr << e.constData() << std::endl;
  }

}
