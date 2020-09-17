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

#ifndef PROC_HPA_H 
#define PROC_HPA_H

#include <QApplication>
#include <QtCore>
#include <string>
#include "luna.h"

#include "luaNeighborhood.h"
#include "luaCell.h"
#include "luaCellularSpace.h"

#include "luaEvent.h"
#include "luaMessage.h"
#include "luaTimer.h"

#include "luaAgent.h"
#include "luaTrajectory.h"
#include "luaGlobalAgent.h"
#include "luaLocalAgent.h"
#include "luaRule.h"
#include "luaJumpCondition.h"
#include "luaFlowCondition.h"
#include "luaControlMode.h"
#include "luaEnvironment.h"


using namespace std;

// Tiago - comentario
// A classe ProcHPA implementar o processo master da arquitetura TerraME HPA
// Ele executa a pilha principal do modelo lua e gerencia o trabalho dos workers.
class ProcHPA : public QThread {
private:

    //estado da funcao/modelo que vai ser executada (entrada da chamada externa)
    lua_State *funcLua;
    //nome do modelo traduzido
    string nameTranslatedModel;

public:

	ProcHPA();

	//quando uma funcao terminou
    void set_State(lua_State *Func);
    
	lua_State* getState();

	//nome da funcao que esta sendo executada (para controle do join)
    string getNameTranslated();

	//qual a pro'xima funcao a ser executada (lembre-se que esttou tentando fazer reuso das instâncias de worker's)
    void setNameTranslated(string);

	//Thread
    virtual void run();

};

#endif //PROC_HPA_H