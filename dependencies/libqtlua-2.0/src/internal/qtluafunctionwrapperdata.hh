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

#ifndef QTLUAFUNCTIONWRAPPERDATA_HH_
#define QTLUAFUNCTIONWRAPPERDATA_HH_

#include <QMetaMethod>
#include <QMetaType>
#include <QList>

#include <QtLua/String>
#include <QtLua/FunctionSignature>

namespace QtLua {

/**
 * @short function wrapper inner data class
 * @header internal/FunctionWrapperData
 * @module {Base}
 * @internal
 *
 * This internal class implements the wrapper which enables invocation
 * of function from lua.
 */
  class FunctionWrapperData
  {
  public:
#if QT_VERSION < QT_VERSION_CHECK(5, 2, 0)
    static const int defaultMaxCount = 11;
#else
    static const int defaultMaxCount = Q_METAMETHOD_INVOKE_MAX_ARGS + 1;
#endif
    FunctionWrapperData(FunctionSignature func, 
                        const QMetaType::Type argt_array[], int count);
    FunctionWrapperData(FunctionSignature func, 
                        const QList<String> argv);

  protected:
    FunctionSignature _func;
    String _return_type_name;
    String _argvs_type_name;
    int _argc;
  };

}

#endif