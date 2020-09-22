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

#ifndef PARAMS_TASK
#define PARAMS_TASK

#include <iostream>
#include <vector>

extern "C"{
	#include <lua.h>
}

#include "luna.h"

#include <list>

using namespace std;

class ParamTask{
private:
	//chamada da task igual a pilha principal
	string codeCall;

	vector<string> paramsOfCall;
	vector<string> paramsOfReturn;
	string nameFuncTask;
	//int ID_by_executed;
	//local onde o retorno da funcao eecutada em paralelo deve ser empilhado
	int refOfReturn;
	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	lua_State *store_val;

public:
	ParamTask();

	~ParamTask();

	//insercao da chamada da funcao, como foi feita na pilha principal
	void setCallTask(string param_);

	//apenas uma insercao no vetor de parametros
	void setParamCall(string param_);

	//apenas uma insercao no vetor de retorno de uma funcao
	void setParamRet(string param_);

	//chamada da funcao, como foi feita na pilha principal
	string getCallTask();

	//apenas acesso a um elemento do vetor de parametro
	string getParamCall(int position_);

	//apenas acesso a um elemento do vetor de retorno
	string getParamRet(int position_);

	//e' possi'vel definir um conjunto de parametros por atribuicao (isso vai substituir todos os adicionados anteriormente)
	void setSetParam(vector<string> SetParams_);

	//
	void setSetRet(vector<string> SetReturns_);

	//e' possi'vel obter toda a lista de parametros
	vector<string> getSetParam();

	//retorna toda a lista de retorno(quais varia'veis vao ser atribuidas)
	vector<string> getSetRet();

	lua_State* get_State();

	void set_State(lua_State*);

	string getNameTask();

	void setNameTask(string nameTask);
};

#endif
