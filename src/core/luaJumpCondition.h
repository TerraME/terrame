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
/*! \file luaJumpCondition.h
    \brief This file definitions for the luaJumpCondition objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUAJUMPCONDITION_H )
#define LUAJUMPCONDITION_H

#include "luaCell.h"
#include "luaRule.h"
#include "luaGlobalAgent.h"
#include "luaEvent.h"

#include <iostream>
using namespace std;

/**
* \brief  
*  Implementation for a luaJumpCondition object.
*
*/
class luaJumpCondition : public JumpCondition, public luaRule
{
private:
    // Antonio
    TypesOfSubjects subjectType;

public:
    ///< Data structure issued by Luna<T>
    static const char className[]; 

    ///< Data structure issued by Luna<T>
    static Luna<luaJumpCondition>::RegType methods[]; 

public:
    /// Constructor
    luaJumpCondition( lua_State *)
    {
        subjectType = TObsUnknown;
    }

    /// Sets luaJumpCondition object target luaControlMode
    /// parameter: luaControlMode identifier
    int setTargetControlModeName(lua_State* L){

        const char* ctrlName = luaL_checkstring( L , -1);
        JumpCondition::setTargetControlModeName( string( ctrlName ) );
        return 0;
    }

    /// Executes the luaJumpCondition object
    /// \param event is the Event which has triggered this luaJumpCondition object
    /// \param agent is the Agent been executed
    /// \param cellIndexPair is the Cell - CellIndex pair where the luaJumpCondition is being executed
    /// \return A booleand value: true if the rule transits, otherwise false.
    bool execute ( Event &event, Agent *agent, pair<CellIndex,Cell*> &cellIndexPair )
    {
        try {

            bool isGlobalAgent = false;
            luaGlobalAgent *agG;
            luaLocalAgent *agL;
            int result = 0;
            luaEvent *ev = (luaEvent*)&event;
            luaCell  *cell = (luaCell*) cellIndexPair.second;

            //puts the excute function of the rule on stack top
            luaRule::getReference(L);
            //lua_pushstring(L, "execute");
            lua_pushnumber(L, 1);
            lua_gettable(L, -2);

            // puts the rule parameters on stack top
            ev->getReference(L);
            if( dynamic_cast<luaGlobalAgent*>(agent) )
            {
                isGlobalAgent = true;
                luaGlobalAgent* ag = (luaGlobalAgent*) agent;
                ag->getReference(L);
                if( cell != NULL ) cell->getReference(L);
                else lua_pushnil(L);
                agG = ag;
            }
            else
            {
                luaLocalAgent* ag = (luaLocalAgent*) agent;
                ag->getReference(L);
                if( cell != NULL ) cell->getReference(L);
                else lua_pushnil(L);
                agL = ag;
            }


            // calls the "execute" function of the rule
            if( lua_pcall( L, 3, 1, 0) != 0 )
            {
                cout << " Error: rule can not be executed: " << lua_tostring(L,-1) << endl;
                return 0;
            }

            result = lua_toboolean( L, -1);
            lua_pop(L, 1);  // pop returned value

            if( result ){
                if( isGlobalAgent ) { ::jump( event, agG, JumpCondition::getTarget() );	}
                else { JumpCondition::jump( agL, cell ); }
            }

            return result;
        }
        catch(...)
        {
            return false;
        }

    }

};


#endif
