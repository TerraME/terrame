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

    Copyright (C) 2012, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef QTLUAPOOLARRAY_HH_
#define QTLUAPOOLARRAY_HH_

#include <stdint.h>

namespace QtLua {

  template <class X, int max_size>
  class PoolArray
  {
  public:
    PoolArray()
    {
      _i = 0;
    }

    ~PoolArray()
    {
      clear();
    }

    void clear()
    {
      X *o = (X*)_storage;

      for (int i = _i - 1; i >= 0; i--)
	(o + i)->~X();
    }

    X & operator[](int i)
    {
      X *o = (X*)_storage;
      return o[i];
    }

    const X & operator[](int i) const
    {
      const X *o = (const X*)_storage;
      return o[i];
    }

#define _QTLUA_POOL_ARRAY_CREATE(a, b, ...)		\
    __VA_ARGS__						\
    inline X & create a					\
    {							\
      X *o = (X*)_storage;				\
      o = new (o + _i)X b;				\
      _i++;						\
      return *o;					\
    }

    _QTLUA_POOL_ARRAY_CREATE((), (), );

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1), (p1), \
			     template <typename P1>);

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1, const P2 &p2), (p1, p2), \
			     template <typename P1, typename P2>);

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1, const P2 &p2, const P3 &p3), (p1, p2, p3),
			     template <typename P1, typename P2, typename P3>);

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1, const P2 &p2, const P3 &p3,
			     const P4 &p4),
			    (p1, p2, p3, p4),
			     template <typename P1, typename P2, typename P3,
			     typename P4>);

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1, const P2 &p2, const P3 &p3,
			     const P4 &p4, const P5 &p5),
			    (p1, p2, p3, p4, p5),
			     template <typename P1, typename P2, typename P3,
			     typename P4, typename P5>);

    _QTLUA_POOL_ARRAY_CREATE((const P1 &p1, const P2 &p2, const P3 &p3,
			     const P4 &p4, const P5 &p5, const P6 &p6),
			    (p1, p2, p3, p4, p5, p6),
			     template <typename P1, typename P2, typename P3,
			     typename P4, typename P5, typename P6>);

  private:
    uint64_t _storage[sizeof(X) * max_size / 8 + 8];
    int _i;
  };

}

#endif

