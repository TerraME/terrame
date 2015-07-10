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

    Fork
    Copyright (C) 2015 (Li, Kwue-Ron) <likwueron@gmail.com>

*/


#ifndef QTLUASTATICFUNCTION_HH_
#define QTLUASTATICFUNCTION_HH_

#include <QMetaType>
#include <QList>
#include <QByteArray>

#include <internal/qtluamember.hh>
#include <internal/FunctionWrapperData>
#include <QtLua/FunctionSignature>

class QMetaObject;

namespace QtLua {

/**
 * @short static function wrapper class
 * @header internal/StaticFunction
 * @module {QObject wrapping}
 * @internal
 *
 * This internal class implements the wrapper which enables invocation
 * of static function for @ref QObject objects from lua.
 */
  class StaticFunction : public Member, FunctionWrapperData
  {
  public:
    QTLUA_REFTYPE(StaticFunction);

    StaticFunction(const QMetaObject *mo, 
                   const String &name, FunctionSignature func, 
                   const QMetaType::Type argt_array[], int argc);
    StaticFunction(const QMetaObject *mo, 
                   const String &name, FunctionSignature func, 
                   const QList<String> &argv);

  private:
    Value::List meta_call(State *ls, const Value::List &args);
    bool support(Value::Operation c) const;
    String get_type_name() const;
    String get_value_str() const;
    void completion_patch(String &path, String &entry, int &offset);
    
    String _name;
  };

}

#endif

