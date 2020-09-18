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

#ifndef BAG_OF_TASKS_H
#define BAG_OF_TASKS_H

extern "C" {
	#include <lua.h>
}

#include <string>
#include <QMutexLocker>
#include <list>
#include "paramsTask.h"

using namespace std;

static list<ParamTask> BAG;

static QMutex LOCK_BAG;

static int bagOfTask(list<ParamTask> *bag_, ParamTask *firtTask) {
	LOCK_BAG.lock();
	//neste caso sai um resultado para ser tratado no run (preciso refatorar aqui)
	if(bag_->empty()){
		LOCK_BAG.unlock();
		return 0;
	}
	else{
		firtTask = &bag_->front();
		bag_->pop_front();
	}
	LOCK_BAG.unlock();
	return 1;
}

//para obter quantidade de tasks agurdando execucao
static int bagSize(list<ParamTask> *bag_){
	int nTasks;
	LOCK_BAG.lock();
		nTasks = bag_->size();
	LOCK_BAG.unlock();
	return nTasks;
}

static void bagInsertion(list<ParamTask> *bag_, string toExec, string nameFunc, vector<string> params, vector<string> returns, lua_State* storeVals){
	LOCK_BAG.lock();

	ParamTask toIncludeBagP;
	toIncludeBagP.setCallTask(toExec);
	toIncludeBagP.setNameTask(nameFunc);
	toIncludeBagP.setSetParam(params);
	toIncludeBagP.setSetRet(returns);

	if(params.size() == 0)
		lua_close(storeVals);
	else
		toIncludeBagP.set_State(storeVals);

	bag_->push_back(toIncludeBagP);

	LOCK_BAG.unlock();
}

#endif