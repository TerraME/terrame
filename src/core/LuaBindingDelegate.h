/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

/*! 
	\brief	A Singleton for inject the bindings.
*/

#ifndef LUA_BINDING_DELEGATE_H
#define LUA_BINDING_DELEGATE_H

class lua_State;

#include "LuaBinding.h"

namespace terrame
{
	namespace lua
	{
		template <typename T>
		class LuaBindingDelegate : public LuaBinding<T>
		{
			public:
				static LuaBindingDelegate<T>& getInstance()
				{
					static terrame::lua::LuaBindingDelegate<T> instance;
					return instance;
				}	

				void setBinding(LuaBinding<T>* binding)
				{
					this->binding = binding;
				}

				T* check(lua_State *L, int narg)
				{
					checkBinding();
					return binding->check(L, narg);
				}

				int setReference(lua_State *L)
				{
					checkBinding();
					return binding->setReference(L);
				}

				int getReference(lua_State *L)
				{
					checkBinding();
					return binding->getReference(L);
				}

				void dispose()
				{
					if(binding)
					{
						binding = 0;
					}
				}			
				
			private:
				LuaBinding<T>* binding;

				LuaBindingDelegate() {}
				LuaBindingDelegate(const LuaBindingDelegate& old);
				const LuaBindingDelegate &operator=(const LuaBindingDelegate& old);				
				~LuaBindingDelegate() {}		

				void checkBinding() 
				{
					if(!binding)
						throw std::runtime_error("Binding is not set. Please, set it firstly.");
				} 
		};
	}
}
#endif // LUA_BINDING_DELEGATE_H