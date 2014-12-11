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

#ifndef QTLUAQTLIB_HH_
#define QTLUAQTLIB_HH_

#include <QObject>
#include <QSizePolicy>

namespace QtLua {

  class State;

  void qtluaopen_qt(State *ls);

  /** Fake QSizePolicy class needed to expose Policy enum */
  class SizePolicy
    : public QObject
  {
    Q_OBJECT;

    Q_ENUMS(Policy);
  public:
    enum Policy
      {
	Fixed = ::QSizePolicy::Fixed,
	Minimum = ::QSizePolicy::Minimum,
	Maximum = ::QSizePolicy::Maximum,
	Preferred = ::QSizePolicy::Preferred,
	Expanding = ::QSizePolicy::Expanding,
	MinimumExpanding = ::QSizePolicy::MinimumExpanding,
	Ignored = ::QSizePolicy::Ignored,
      };
  };

}

#endif

