/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

/*! \file luaFlowCondition.h
    \brief This file definitions for the luaFlowCondition objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUAFLOWCONDITION_H
#define LUAFLOWCONDITION_H

#include "luaRule.h"


/**
* \brief  
*  Implementation for a FlowCondition object.
*
*/
class luaFlowCondition : public FlowCondition, public luaRule
{
private:
    TypesOfSubjects subjectType;

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<luaFlowCondition>::RegType methods[];

public:
    /// Constructor
    luaFlowCondition(lua_State *)
    {
        subjectType = TObsUnknown;
    }

    /// Executes the luaFlowCondition object
    /// \param event is the Event which has triggered this luaFlowCondition object
    /// \param agent is the Agent been executed
    /// \param cellIndexPair is the Cell - CellIndex pair where the luaJumpCondition is being executed
    /// \return A booleand value: true if the rule does not throw a exception, otherwise false.
    bool execute(Event &event, Agent *agent, pair<CellIndex, Cell*> &cellIndexPair)
    {
        try {

            int result = 0;
            luaEvent *ev =(luaEvent*)&event;
            luaCell  *cell =(luaCell*) cellIndexPair.second;

            //puts the excute function of the rule on stack top
            luaRule::getReference(L);
            //lua_pushstring(L, "execute");
            lua_pushnumber(L, 1);
            lua_gettable(L, -2);

            // puts the rule parameters on stack top
            ev->getReference(L);
            if (dynamic_cast<luaGlobalAgent*>(agent))
            {
                luaGlobalAgent* ag =(luaGlobalAgent*) agent;
                ag->getReference(L);
                if (cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
            }
            else
            {
                luaLocalAgent* ag =(luaLocalAgent*) agent;
                ag->getReference(L);
                if (cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
            }

            // calls the "execute" function of the rule
            if (lua_pcall(L, 3, 1, 0) != 0)
            {
                string err_out = string(" Error: rule can not be executed ") + string(lua_tostring(L, -1)) + string("\".\n");
                lua_getglobal(L, "customError");
                lua_pushstring(L, err_out.c_str());
                lua_pushnumber(L, 4);
                lua_call(L, 2, 0);
                return 0;
            }

            result = lua_tonumber(L, -1);
            lua_pop(L, 1);  // pop returned value

            return result;
        }
        catch(...)
        {
            return false;
        }

    }
};


#endif
