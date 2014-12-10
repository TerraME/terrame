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


#ifndef QTLUAREF_HH_
#define QTLUAREF_HH_

#ifndef __GNUC__
# warning GCC atomic operations are not available, QtLua::Ref will not be thread-safe
#endif

#include <QtGlobal> // for Q_UNUSED
#include <stdint.h>
#include <cassert>

namespace QtLua {

  template <class X>
  class Refobj;

  /**
   * @short Smart pointer with reference counter.
   * @header QtLua/Ref
   * @module {Base}
   *
   * This template class implements a smart pointer with reference
   * counter. 
   *
   * The @ref QtLua::UserData class and derived classes are commonly
   * used with this smart pointer class in QtLua to take advantages of
   * the lua garbage collector. This allows objects to be deleted when
   * no reference are left in both C++ code and lua interpreter state.
   *
   * This smart pointer template class can be used as pointer to
   * objects with class derived from the @ref QtLua::Refobj class. Most of the
   * time you need @ref QtLua::UserData based objects and you don't
   * want to inherit from the @ref QtLua::Refobj class directly.
   *
   * A @ref Ref pointer object can be assigned with an object
   * of type X or with an other @ref Ref pointer object.
   *
   * The @ref #QTLUA_REFNEW macro must be used to dynamically create
   * new objects. Objects allocated with this macro will be deleted
   * automatically when no more reference remains.
   *
   * Variable and member objects not allocated with the @ref
   * #QTLUA_REFNEW macro, can be handled too but they won't be
   * automatically deleted. They will still be checked for
   * remaining references when destroyed.
   *
   * Template parameters:
   * @param X Pointed object type, may be const.
   * @param Xnoconst Bare pointed object type. This parameter is optional, default is same as X.
   *
   * Two shortcuts to @tt{Ref<X, X>} and @tt{Ref<const X, X>} types
   * are provided for convenience, the @tt{X::ptr} and @tt{X::const_ptr} types
   * can be defined with the @ref #QTLUA_REFTYPE macro.
   */

  template <class X, class Xnoconst = X>
  class Ref
  {
    template <class, class> friend class Ref;

  public:

/**
 * This macro dynamically allocate and construct an object of
 * requested type with given constructor arguments and returns an
 * associated @ref QtLua::Ref object.
 * 
 * @param X object type to construct
 * @param ... constructor arguments
 *
 * Usage example:
 *
 * @example examples/cpp/userdata/ref.cc:3|5
 */
#define QTLUA_REFNEW(X, ...)			\
 (X::ptr::allocated(new X(__VA_ARGS__)))

/**
 * This macro may be used to declare the X::ptr and X::const_ptr
 * shortcuts to @ref QtLua::Ref types in class derived from @ref
 * QtLua::Refobj. It should be invoked from class body public part.
 *
 * @param X macro invocation class.
 *
 * Usage example:
 *
 * @example examples/cpp/userdata/ref.cc:1|2
 * @showcontent
 */
#define QTLUA_REFTYPE(X)					 \
 /** Shortcut for @ref QtLua::Ref smart pointer class to X type provided for convenience */ \
 typedef QtLua::Ref<const X, X> const_ptr;			 \
 /** Shortcut for @ref QtLua::Ref smart pointer class to X type provided for convenience */ \
 typedef QtLua::Ref<X, X> ptr;

    /** Construct a null reference. */
    Ref()
      : _obj(0)
    {
    }

    /** Construct a const Ref from non const Ref. */
    Ref(const Ref<Xnoconst, Xnoconst> & r)
      : _obj(r._obj)
    {
      if (_obj)
	_obj->_inc();
    }

    /** Construct a const Ref from const Ref. */
    Ref(const Ref<const Xnoconst, Xnoconst> & r)
      : _obj(r._obj)
    {
      if (_obj)
	_obj->_inc();
    }

    /** Construct a const Ref from derived class Ref. */
    template <class T>
    Ref(const Ref<T, T> & r)
      : _obj(r._obj)
    {
      if (_obj)
	_obj->_inc();
    }

    /** Construct a const Ref from derived class const Ref. */
    template <class T>
    Ref(const Ref<const T, T> & r)
      : _obj(r._obj)
    {
      if (_obj)
	_obj->_inc();
    }

#ifdef Q_COMPILER_RVALUE_REFS
    /** Construct a const Ref from non const Ref. */
    Ref(Ref<Xnoconst, Xnoconst> && r)
      : _obj(r._obj)
    {
      r._obj = 0;
    }

    /** Construct a const Ref from const Ref. */
    Ref(Ref<const Xnoconst, Xnoconst> && r)
      : _obj(r._obj)
    {
      r._obj = 0;
    }

    /** Construct a const Ref from derived class Ref. */
    template <class T>
    Ref(Ref<T, T> && r)
      : _obj(r._obj)
    {
      r._obj = 0;
    }

    /** Construct a const Ref from derived class const Ref. */
    template <class T>
    Ref(Ref<const T, T> && r)
      : _obj(r._obj)
    {
      r._obj = 0;
    }
#endif

    /** Construct a Ref which points to specified object. */
    Ref(X & obj)
      : _obj(&obj)
    {
      _obj->_inc();
    }

    /**
     * Construct Ref from dynamically allocated object pointer.
     * Pointed object is marked as deletable when last reference is destroyed.

     * @internal
     */
    static Ref allocated(X * obj)
    {
      obj->ref_allocated();
      return Ref(obj);
    }

    /** Initialize Ref from Ref */
    Ref & operator=(const Ref &r)
    {
      X *tmp = _obj;
      _obj = 0;
      if (tmp)
	tmp->_drop();
      _obj = r._obj;
      if (_obj)
	_obj->_inc();
      return *this;
    }

#ifdef Q_COMPILER_RVALUE_REFS
    Ref & operator=(Ref &&r)
    {
      X *tmp = _obj;
      _obj = 0;
      if (tmp)
	tmp->_drop();
      _obj = r._obj;
      r._obj = 0;
      return *this;
    }
#endif

    /** Initialize Ref from object Reference */
    Ref & operator=(X & obj)
    {
      X *tmp = _obj;
      _obj = 0;
      if (tmp)
	tmp->_drop();
      _obj = &obj;
      assert(_obj);
      _obj->_inc();
      return *this;
    }

    /** Dynamic cast Ref to Ref of given type */
    template <class T>
    Ref<T, T> dynamiccast() const
    {
      return Ref<T, T>(dynamic_cast<T*>(_obj));
    }

    /** Dynamic cast Ref to const Ref of given type */
    template <class T>
    Ref<const T, T> dynamiccast_const() const
    {
      return Ref<const T, T>(dynamic_cast<const T*>(_obj));
    }

    /** Static cast Ref to Ref of given type */
    template <class T>
    Ref<T, T> staticcast() const
    {
      return Ref<T, T>(static_cast<T*>(_obj));
    }

    /** Static cast Ref to const Ref of given type */
    template <class T>
    Ref<const T, T> staticcast_const() const
    {
      return Ref<const T, T>(static_cast<const T*>(_obj));
    }

    /** Const cast const Ref to Ref of given type */
    template <class T>
    Ref<T, T> constcast() const
    {
      return Ref<T, T>(const_cast<T*>(_obj));
    }

    /** Drop a Ref */
    ~Ref()
    {
      if (_obj)
	_obj->_drop();
    }

    /** Invalidate Ref (set internal pointer to null) */
    void invalidate()
    {
      X *tmp = _obj;
      _obj = 0;
      if (tmp)
	tmp->_drop();
    }

    /** Test if Ref is valid (check if internal pointer is not null) */
    bool valid() const
    {
      return _obj != 0;
    }

    /** Access object */
    X & operator*() const
    {
      assert(_obj);
      return *_obj;
    }

    /** Access object */
    X * operator->() const
    {
      assert(_obj);
      return _obj;
    }

    /** Get Ref internal object pointer */
    X * ptr() const
    {
      return _obj;
    }

    /** Get object Reference count */
    int count() const
    {
      return _obj ? _obj->ref_count() : 0;
    }

    /** Test if pointed ojects are the same */
    bool operator==(const Ref &r) const
    {
      return _obj == r._obj;
    }

    /** Test if pointed ojects are not the same */
    bool operator!=(const Ref &r) const
    {
      return _obj != r._obj;
    }

  protected:

    explicit Ref(X * obj)
      : _obj(obj)
    {
      if (_obj)
	_obj->_inc();
    }

    X *_obj;
  };

  /**
   * @short Referenced objects base class
   * @header QtLua/Ref
   * @module {Base}
   * @internal
   */
  class RefobjBase
  {
    template <class, class> friend class Ref;
    template <class> friend class RefObj;
    /** @internal Reference counter value */
    uintptr_t _state;

    static const uintptr_t REF_DELETE = 1;
    static const uintptr_t REF_DELEGATE = 2;
    static const uintptr_t REF_ONE = 4;
    static const uintptr_t REF_MASK = ~3;

  protected:

    virtual ~RefobjBase()
    {
    }

    RefobjBase()
      : _state(0)
    {
    }

    /** @internal */
    void _inc() const
    {
      RefobjBase *y = const_cast<RefobjBase*>(this);

      while (y->_state & REF_DELEGATE)
	y = (RefobjBase*)(y->_state & REF_MASK);

#ifdef __GNUC__
      __sync_add_and_fetch(&y->_state, REF_ONE);
#else
      y->_state += REF_ONE;
#endif
    }

    /** @internal */
    void _drop() const
    {
      RefobjBase *y = const_cast<RefobjBase*>(this);

      while (y->_state & REF_DELEGATE)
	y = (RefobjBase*)(y->_state & REF_MASK);

#ifdef __GNUC__
      intptr_t count = __sync_sub_and_fetch(&y->_state, REF_ONE) >> 2;
#else
      y->_state -= REF_ONE;
      intptr_t count = y->_state >> 2;
#endif

      assert(count >= 0);

      if (y->_state & REF_DELETE)
	{
	  switch (count)
	    {
	    case 0:
	      delete y;
	      return;
	    case 1:
	      y->ref_single();
	      break;
	    }
	}
    }

    void ref_allocated()
    {
      assert(!(_state & REF_DELEGATE));
      _state |= REF_DELETE;
    }

    /** This function is called when a dynamically allocated object
	has its reference count decreased to 1. */
    virtual void ref_single()
    {
    }

  public:

    /** This function set the passed object as references counter in
	place of @tt this object. The reference counter of @tt this
	object is disabled and all @ref Ref pointing to @tt this
	contribute to reference counter of specified object instead.

	This function must be used when an object is instantiated as a
	member of an other object so that references to the member
	object are used to keep the container object alive. */
    void ref_delegate(RefobjBase *o)
    {
      while (o->_state & REF_DELEGATE)
	o = (RefobjBase*)(o->_state & REF_MASK);

      assert(!_state && !((uintptr_t)o & 3));
      _state = REF_DELEGATE | (uintptr_t)o;
    }

    /** Check if @ref ref_delegate has been used on this object. */
    bool ref_is_delegate() const
    {
      const RefobjBase *y = this;

      return (y->_state & REF_DELEGATE) != 0;
    }

    /** Get object current reference count */
    int ref_count() const
    {
      const RefobjBase *y = this;

      while (y->_state & REF_DELEGATE)
	y = (RefobjBase*)(y->_state & REF_MASK);

      return y->_state >> 2;
    }
  };

  /**
   * @short Referenced objects template base class
   * @header QtLua/Ref
   * @module {Base}
   *
   * This template class must be a base class for any class which may
   * be referenced by the @ref QtLua::Ref smart pointer.
   * @see QtLua::UserData.
   */
  template <class X>
  class Refobj : public RefobjBase
  {
  public:
    QTLUA_REFTYPE(X);

    Refobj()
      : RefobjBase()
    {
    }

    Refobj(const Refobj &r)
      : RefobjBase()
    {
    }

    Refobj & operator=(const Refobj &r)
    {
      assert(ref_count() == 0 || !"Can not overwrite object with live references");
      return *this;
    }

    ~Refobj()
    {
      assert(ref_count() == 0 || !"Can not destruct object with live references");
    }
  };


}

#endif

