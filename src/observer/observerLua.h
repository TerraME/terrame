/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

/*!
 * \file observerLua.h
 * \brief
 * \author Antonio Jose da Cunha Rodrigues
*/

#ifndef OBSERVER_LUA_H
#define OBSERVER_LUA_H

extern "C"
{
	#include <lua.h>
}
#include "luna.h"

#include <QHash>
#include <QByteArray>
#include "observer.h"

using namespace TerraMEObserver;

#ifdef TME_PROTOCOL_BUFFERS
//namespace ObserverDatagramPkg
//{
//	class SubjectAttribute;
//}
#include "protocol.pb.h"

#endif

/**
 * A global pop method for all subjects
 * \param luaL a pointer to current Lua stack
 * \param stackPosition the reference to the position of a subject into Lua stack
 * \param attribs a list of observed attributes
 * \param observedAttribs a hash of last value of all observed attributes
 */
 #ifdef TME_PROTOCOL_BUFFERS

 // Exemplo
 // QByteArray luaCellularSpace::pop(lua_State *luaL, const QStringList& attribs, 
	// ObserverDatagramPkg::SubjectAttribute *currSubj,
	// ObserverDatagramPkg::SubjectAttribute *parentSubj)
// {
	// bool valueChanged = false;
	
	// // recupero a referencia na pilha lua
	// lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
	// int cellSpacePos = lua_gettop(luaL);
	
	// // TO-DO: Insere o objeto previamente como um 
	// // subject interno. Isso evita um bug quando o 
	// // método popLua retorna mas define o objeto csSubj
	// // como NULL 
	// if ((parentSubj) && (! currSubj))
		// currSubj = parentSubj->add_internalsubject();

	// popLua(TObsCellularSpace, luaL, cellSpacePos, attribs, observedAttribs, valueChanged,
		// currSubj, parentSubj);  
	
	// if (valueChanged)
	// {
		// // TO-DO: melhor solução mas não esta funcionando.
		// // O objeto cellSubj é instanciado no metodo popLua
		// // mas quanda ela retorna, o csSubj esta com valor NULL
		// // Somente insere o objeto se ele contém alterações
		// // if ((parentSubj) && (! currSubj))
		// //	currSubj = parentSubj->add_internalsubject();

		// // id
		// currSubj->set_id(getId());

		// // subjectType
		// currSubj->set_type( ObserverDatagramPkg::TObsCellularSpace );

		// // #attrs
		// currSubj->set_attribsnumber( currSubj->rawattributes_size() );

		// // #elements
		// currSubj->set_itemsnumber( currSubj->internalsubject_size() );
	// }
	// else
	// {
// #ifdef DEBUG_OBSERVER			
			// qDebug() << "luaCellularSpace removeLast()";
// #endif

		// if (parentSubj)
			// parentSubj->mutable_internalsubject()->RemoveLast();
	// }

   // if (! parentSubj)
	// { 
		// QByteArray byteArray(currSubj->SerializeAsString().c_str(), currSubj->ByteSize());
		
// #ifdef DEBUG_OBSERVER
		// qDebug() << "\nluaCellularSpace:pop - size:" << currSubj->internalsubject_size();
		// std::cout << currSubj->DebugString();
		// std::cout.flush();
// #endif
		// return byteArray;
	// }

	// t = Statistic::getInstance().endMicroTime() - t;
	// Statistic::getInstance().addElapsedTime("pop lua", t);

	// return QByteArray();
// }
 
inline void popLua(const TypesOfSubjects &subjectType, lua_State *luaL, int &stackPosition, 
	const QStringList &attribs, QHash<QString, QString>& observedAttribs, bool &valueChanged,
	ObserverDatagramPkg::SubjectAttribute *currSubj, ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
	QByteArray key, valueTmp;
	char result[20];
	
	double num = 0.0;
		
	ObserverDatagramPkg::RawAttribute *raw = 0;

	lua_pushnil(luaL);
	while(lua_next(luaL, stackPosition) != 0)
	{
		if(lua_type(luaL, -2) == LUA_TSTRING)
		{
			key = luaL_checkstring(luaL, -2);
		}
		else
		{
			if (lua_type(luaL, -2) == LUA_TNUMBER)
				key = QByteArray::number(luaL_checknumber(luaL, -2));
		}

		if(attribs.contains(key) || (key == "cells"))
		{
			switch(lua_type(luaL, -1))
			{
				case LUA_TBOOLEAN:
				valueTmp = QByteArray::number(lua_toboolean(luaL, -1));

				if(observedAttribs.value(key) != valueTmp)
				{
					if((parentSubj) && (! currSubj))
						currSubj = parentSubj->add_internalsubject();

					raw = currSubj->add_rawattributes();
					raw->set_key(key);
					raw->set_number(valueTmp.toDouble());

					valueChanged = true;
					observedAttribs.insert(key, valueTmp);
				}
				break;

				case LUA_TNUMBER:
				{
					num = luaL_checknumber(luaL, -1);
					doubleToText(num, valueTmp, 20);

					if(observedAttribs.value(key) != valueTmp)
					{
// #ifdef DEBUG_OBSERVER
						// qDebug() << getId() << qPrintable(key) << ": " 
							// << qPrintable(observedAttribs.value(key)) << " == " << qPrintable(valueTmp);
// #endif
					
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						raw->set_key(key);
						raw->set_number(num);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					break;
				}

				case LUA_TSTRING:
				{
					valueTmp = luaL_checkstring(luaL, -1);

					if(observedAttribs.value(key) != valueTmp)
					{
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						// raw->set_key(key.constData());
						raw->set_key((valueTmp.isEmpty() || valueTmp.isNull() ? 
							VALUE_NOT_INFORMED : valueTmp));

						raw->set_text(valueTmp);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					break;
				}
			
				case LUA_TTABLE:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1) );
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						raw->set_key(key);
						raw->set_text(LUA_ADDRESS_TABLE + valueTmp);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					
					if ((subjectType == TObsCellularSpace)
						// || (subjectType == TObsTrajectory)
						// || (subjectType == TObsSociety)
					)
					{
						int top = lua_gettop(luaL);

						lua_pushnil(luaL);
						while(lua_next(luaL, top) != 0)
						{
							int cellTop = lua_gettop(luaL);
							lua_pushstring(luaL, "cObj_");
							lua_gettable(luaL, cellTop);

							luaCell* cell;
							cell = (luaCell*)Luna<luaCell>::check(L, -1);
							lua_pop(luaL, 1);

							// luaCell->pop(...) requer uma celula no topo da pilha

							// cellMsg = cell->pop(L, attribs);
							int internalCount = currSubj->internalsubject_size();
							cell->pop(L, attribs, 0, currSubj);

							if(currSubj->internalsubject_size() > internalCount)
								valueChanged = true;
							
							lua_pop(luaL, 1);
						}
					}
					break;
				}

				case LUA_TUSERDATA:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						raw->set_key(key);
						raw->set_text(LUA_ADDRESS_USER_DATA + valueTmp);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					break;
				}

				case LUA_TFUNCTION:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						raw->set_key(key);
						raw->set_text(LUA_ADDRESS_FUNCTION + valueTmp);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					break;
				}

				default:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						if((parentSubj) && (! currSubj))
							currSubj = parentSubj->add_internalsubject();

						raw = currSubj->add_rawattributes();
						raw->set_key(key);
						raw->set_text(LUA_ADDRESS_OTHER + valueTmp);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);
					}
					break;
				}
			}
		}
		lua_pop(luaL, 1);
	}
}

#else

inline static QByteArray popLua(const TypesOfSubjects &subjectType, lua_State *luaL, int &stackPosition, const QStringList &attribs,
			QHash<QString, QString>& observedAttribs, bool &valueChanged, int &attrCounter, 
			QByteArray &elements = "", int &elementCounter = 0)
{
	QByteArray msg, attrs, key, valueTmp; //, text;
	char result[20];

	int attrCounter = 0;
	double num = 0.0;

	lua_pushnil(luaL);
	while(lua_next(luaL, stackPosition ) != 0)
	{
		if(lua_type(luaL, -2) == LUA_TSTRING)
		{
			ky = luaL_checkstring(luaL, -2);
		}
		else
		{
			if(lua_type(luaL, -2) == LUA_TNUMBER)
				key = QByteArray::number(luaL_checknumber(luaL, -2));
		}
		
		if (attribs.contains(key) || (key == "cells"))
		{
			switch(lua_type(luaL, -1))
			{
				case LUA_TBOOLEAN:
				{
					valueTmp = QByteArray::number( lua_toboolean(luaL, -1));

					if(observedAttribs.value(key) != valueTmp)
					{
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append("0"); // QString::number(TObsBool));
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append(valueTmp);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}

				case LUA_TNUMBER:
				{
					num = luaL_checknumber(luaL, -1);
					doubleToText(num, valueTmp, 20);		 
					
					if(observedAttribs.value(key) != valueTmp)
					{
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append("1");  // TObsNumberChar // QString::number(TObsNumber)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append(valueTmp);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}

				case LUA_TSTRING:
				{
					valueTmp = luaL_checkstring(luaL, -1);

					if(observedAttribs.value(key) != valueTmp)
					{
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append("3"); // QString::number(TObsText)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append((valueTmp.isEmpty() || valueTmp.isNull() ? VALUE_NOT_INFORMED : valueTmp));
						// attrs.append(valueTmp);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}

				case LUA_TTABLE:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if (observedAttribs.value(key) != valueTmp)
					{					
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append("3"); // QString::number(TObsText)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append("Lua-Address(TB): ");
						attrs.append(result);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					
					if((subjectType == TObsCellularSpace)
						|| (subjectType == TObsTrajectory) 
						|| (subjectType == TObsSociety))
					{
						int top = lua_gettop(luaL);

						lua_pushnil(luaL);
						while(lua_next(luaL, top) != 0)
						{
							int cellTop = lua_gettop(luaL);
							lua_pushstring(luaL, "cObj_");
							lua_gettable(luaL, cellTop);

							luaCell*  cell;
							cell = (luaCell*)Luna<luaCell>::check(L, -1);
							lua_pop(luaL, 1);

							// luaCell->pop(...) requer uma celula no topo da pilha
							cellMsg = cell->pop(L, attribs);
							if(! cellMsg.isEmpty())
							{
								// valueChanged = true;
								elements.append(cellMsg);
								elementCounter++;
							}
							lua_pop(luaL, 1);
						}
					}
					
					break;
				}

				case LUA_TUSERDATA:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append("3"); // QString::number(TObsText)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append("Lua-Address(UD): ");
						attrs.append(result);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}

				case LUA_TFUNCTION:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append(key);
						attrs.append("3"); // QString::number(TObsText)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append("Lua-Address(FT): ");
						attrs.append(result);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}

				default:
				{
					sprintf(result, "%p", lua_topointer(luaL, -1));
					valueTmp = result;

					if(observedAttribs.value(key) != valueTmp)
					{					
						attrCounter++;
						attrs.append(key);
						attrs.append(PROTOCOL_SEPARATOR);

						valueChanged = true;
						observedAttribs.insert(key, valueTmp);

						attrs.append("3"); // QString::number(TObsText)
						attrs.append(PROTOCOL_SEPARATOR);
						attrs.append("Lua-Address(O): ");
						attrs.append(result);
						attrs.append(PROTOCOL_SEPARATOR);
					}
					break;
				}
			}
		}
		lua_pop(luaL, 1);
	}
  
	return msg;
}

#endif
#endif // OBSERVER_LUA_H

