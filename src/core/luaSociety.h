/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C) 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/
/*! \file luaSociety.h
	\brief This file definitions for the luaSociety objects.
		\author Tiago Garcia de Senna Carneiro
*/
#ifndef LUASOCIETY_H
#define LUASOCIETY_H

#include "societySubjectInterf.h"
#include "luaGlobalAgent.h"

extern "C"
{
#include <lua.h>
}
#include "luna.h"
#include "reference.h"

/**
* \brief
*
* Represents a set of Society in the Lua runtime environment.
*
*/
//class SocietySubjectInterf;

class luaSociety : public SocietySubjectInterf, public Reference<luaSociety>
{
	string objectId_; ///< luaSociety identifier

	TypesOfSubjects subjectType;
	lua_State *luaL; ///< Stores locally the lua stack location in memory
	QHash<QString, QString> observedAttribs;

	QString attrClassName, attrNeighName;
	luaCellularSpace *cellSpace;

	QByteArray getAll(QDataStream& in, const QStringList& attribs);
	QByteArray getChanges(QDataStream& in, const QStringList& attribs);
public:
	///< Data structure issued by Luna<T>
	static const char className[];

	///< Data structure issued by Luna<T>
	static Luna<luaSociety>::RegType methods[];

public:
	/// Constructor
	luaSociety(lua_State *L);

	/// destructor
	~luaSociety(void);

	/// Gets the luaSociety identifier
	int getID(lua_State *L);

	/// Sets the luaSociety identifier
	int setID(lua_State *L);

	/// Creates several types of observers
	/// parameters: observer type, observer attributes table, observer type parameters
	int createObserver(lua_State *L);

	/// Notifies observers about changes in the luaSociety internal state
	int notify(lua_State *L);

	/// Gets the subject's type
	const TypesOfSubjects getType() const;

	/// Gets the object's internal state (serialization)
	/// \param in the serialized object that contains the data that will be observed in the observer
	/// \param subject a pointer to a observed subject
	/// \param observerId the id of the observer
	/// \param attribs the list of attributes observed
	QDataStream& getState(QDataStream& in, Subject *subject, int observerID,
			const QStringList& attribs);

	/**
	 * Gets the attributes of Lua stack
	 * \param attribs the list of attributes observed
	*/
	QByteArray pop(lua_State *L, const QStringList& attribs,
			ObserverDatagramPkg::SubjectAttribute *csSubj,
		ObserverDatagramPkg::SubjectAttribute *parentSubj);

	/// Destroys the observer object instance
	int kill(lua_State *L);
};

/// Gets the luaSociety position of the luaSociety in the Lua stack
/// \param L is a pointer to the Lua stack
/// \param cell is a pointer to the cell within the Lua stack
void getReference(lua_State *L, luaSociety *cell);

#endif

