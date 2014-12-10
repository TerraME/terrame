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

#ifndef QTLUASTRING_HXX_
#define QTLUASTRING_HXX_

namespace QtLua {

  String::String()
  {
  }

  String::String(const char *s)
    : QByteArray(s)
  {
  }

  String::String(const char *s, int size)
    : QByteArray(s, size)
  {
  }

  String::String(const QByteArray &s)
    : QByteArray(s)
  {
  }

  String::String(const QString &s)
    : QByteArray(s.toUtf8())
  {
  }

  String & String::arg(const QByteArray &a)
  {
    int i = indexOf('%');

    if (i >= 0)
      replace(i, 1, a);

    return *this;
  }

  String & String::arg(const QString &a)
  {
    int i = indexOf('%');

    if (i >= 0)
      replace(i, 1, a.toUtf8());

    return *this;
  }

  String & String::arg(const char *a)
  {
    int i = indexOf('%');

    if (i >= 0)
      replace(i, 1, a);

    return *this;
  }

  String & String::arg(int a)
  {
    int i = indexOf('%');

    if (i >= 0)
      replace(i, 1, QByteArray::number(a));

    return *this;
  }

  String::operator const char * () const
  {
    return constData();
  }

  QString String::to_qstring () const
  {
    return QString::fromUtf8(constData(), size());
  }

}

#endif

