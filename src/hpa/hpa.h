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

#ifndef HPA_H
#define HPA_H

#include "procHPA.h"
#include "procTask.h"
#include "envHPA.h"
#include "parserHPA.h"

#include <iostream>
#include <vector>
#include <iostream>
#include <string>

#include "bagOfTasks.h"

extern "C"{
	//#include <WinBase.h>
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
}
#include "luna.h"

using namespace std;

//vetor de trabalhadores (minhas threads)
static vector<ProcTask*> workers;

class HPA {
	int refGlobalHPA;

public:
	//para seguir o template do Luna
    static const char className[];
    static Luna<HPA>::RegType methods[];

private:
	//pilha de execucao principal
	ProcHPA *mainStack;
	string pathModel;

	list<ParamTask> *Bag;
	QMutex *lock_bag;

	//Hash para criacao das secoes criticas lembrar de utilizalos com o wait condition
	QHash<QString, QMutex*> lockSection;
	QHash<QString, bool> lockSectionUse;
	QMutex justOne;

	void createWorkers();
	void removeWorkers(lua_State *);
	void removeLockSections(void); // Tiago - remover leak
	lua_State* Read_Parameters(lua_State*, vector<string>);
	vector<string> findNamePar(string);
	string findNameFunc(string toExecut);

	//metodos para acessar e setar a bag para fora(public, like interface) para o controle de acesso tambe'm uma vez
	//que ele e' compartilhado
	void setBag(list<ParamTask>*);
	void setControlQMut(QMutex* controlMutex);

	list<ParamTask>* getBag();
	QMutex* getControlQMut();

	//QHash<QString, QMutex*> getLockSec();
	//QHash<QString, bool> getLockSecUse();
	//QMutex controlAcess();

public:
	//contrutor HPA, e' preciso passar como parametro o modelo instrumentado com as diretivas
	//metodo apenas para ref no lua

	// HPA(string pathModel); // Tiago -- comentei pq nao estva em uso
	HPA(string pathModel, lua_State *);
	int execute();

	//--------------------------implementacao das diretivas--------------------------
	//Executa o Join em todas as funcoes que estao executando ate' o ponto de chamada
    HPA(lua_State *L);

    int joinall(lua_State*);
    //Executa o Join na/nas funcoes name_func que esta/estao executando
    int join(lua_State*);
    //Corresponde a adicionar mais uma tarefa ao Bag of Task's para ser resolvida
    int parallel(lua_State*);
	//metodos para controlar acesso synchronized as variaveis globais
	int acquire(lua_State *now);
	int release(lua_State *now);
	int np(lua_State *now);

	int HPATests(lua_State * now);

	~HPA(); //Tiago -- necessario para resolver leaks de memoria gerado pelo Saulo
};

#endif
