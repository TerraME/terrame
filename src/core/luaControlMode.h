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

/*! \file luaControlMode.h
    \brief This file definitions for the luaControlMode objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUACONTROLMODE_H )
#define LUACONTROLMODE_H

#include "luaJumpCondition.h"
#include "luaFlowCondition.h"
#include "luaUtils.h"

/**
* \brief  
*  Implementation for a luaControlMode object.
*
*/
class luaControlMode : public ControlMode
{
    Process uniqueProcess;

    // Antonio
    TypesOfSubjects subjectType;

public:
    ///< Data structure issued by Luna<T>
    static const char className[]; 
    
    ///< Data structure issued by Luna<T>
    static Luna<luaControlMode>::RegType methods[];
    
public:
    /// constructor
    luaControlMode( lua_State *)
    {
        ControlMode::add(uniqueProcess);
        subjectType = TObsUnknown;
    }

    /// Configures the luaControlMode object
    /// parameter: luaControlMode identifier
    int config( lua_State*L )
    {
        const char *name = luaL_checkstring(L, -1);
        string tempStr = name; // Raian: ControlMode::setControlModeName( string(name) );
        ControlMode::setControlModeName( tempStr );
        return 0;
    }

    /// Adds new rules to the luaControlMode object: luaJumpCondition and luaFlowCondition objects
    /// parameter: rule
    int add( lua_State* L)
    {
        void *ud;

        if( isudatatype (L, -1, "TeJump") )
        {
            luaJumpCondition* const jump = Luna<luaJumpCondition>::check(L, -1);
            uniqueProcess.JumpCompositeInterf::add( jump );
        }
        else
            if( (ud = luaL_checkudata(L, -1, "TeFlow")) != NULL )
            {
                luaFlowCondition* const flow = Luna<luaFlowCondition>::check(L, -1);
                uniqueProcess.FlowCompositeInterf::add( flow );
            }
        return 0;
    }

    /// Adds new luaJumpCondition objects to the luaControlMode object
    /// parameter: luaJumpCondition
    int addJump( lua_State* L)
    {
        luaJumpCondition* const jump = Luna<luaJumpCondition>::check(L, -1);
        uniqueProcess.JumpCompositeInterf::add( jump );
        return 0;
    }

    /// Adds new luaFlowCondition objects to the luaControlMode object
    /// parameter: luaFlowCondition
    int addFlow( lua_State* L)
    {
        luaFlowCondition* const flow = Luna<luaFlowCondition>::check(L, -1);
        uniqueProcess.FlowCompositeInterf::add( flow );
        return 0;
    }

    /// Gets the luaControlMode name
    int getName( lua_State* L)
    {
        lua_pushstring( L, ControlMode::getControlModeName().c_str() );
        return 1;
    }

};

#endif
