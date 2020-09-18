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

#ifndef PROC_TASK_H
#define PROC_TASK_H

extern "C"{
	#include <lua.h>
}

//#include <QApplication>
#include <QtCore>

#include "paramsTask.h"
#include "bagOfTasks.h"

using namespace std;

// Tiago - comentario
// A classe ProcTask implementa os workers da arquitetura TerraME HPA
class ProcTask : public QThread {
private:
	//estado da funcao/modelo que vai ser executada
    lua_State *funcLua;

    //nome da funcao que foi chamada
    string nameFunc;

	//parametros de chamada da task
	vector<string> paramOfCham;

	//variaveis de retorno da task
	vector<string> paramOfReturn;

	int refOfReturn;
	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	lua_State *storeVal;

	int isRunning_;

	//referencia para enganar garbage collector
	int refThread;

	list<ParamTask> *Bag;

	QMutex *lock_bag;

public:
	ProcTask();

    //quando um a funcao terminou
    void set_State(lua_State *Func);

	lua_State* getState();

	//nome da funcao
    string getName();

	//nome da nova funcao a ser executada
	void setName(string);

	//parametros para a execucao da pro'xima funcao
	void setParms(vector<string>, vector<string>, int, int, lua_State*);
	void setParms(vector<string>, vector<string>, int, lua_State*);

	vector<string> getParamOfCham();
	vector<string> getParamOfReturn();

	void setParamOfCham(vector<string> paramOfCham_);
	void setParamOfReturn(vector<string> paramOfReturn_);

	void w_stack();

	//thread
	void run();

	//set o estado corrente da task em execucao
	void setRunState(int runState_);

	int getRunState();

	void setRefThread(int ref_);
	int getRefThread();

	//metodos para acessar e setar a bag para fora(public, like interface) para o controle de acesso tambe'm uma vez
	//que ele e' compartilhado
	void setBag(list<ParamTask>*);
	void setControlQMut(QMutex* controlMutex);

	list<ParamTask>* getBag();
	QMutex* getControlQMut();
};

#endif //PROC_HPA_H
