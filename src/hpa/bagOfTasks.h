//author: Saulo Henrique Cabral Silva

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

//para obter quantidade de tasks agurdando execução
static int bagSize(list<ParamTask> *bag_){
	int nTasks;
	LOCK_BAG.lock();
		nTasks = bag_->size();
	LOCK_BAG.unlock();
	return nTasks;
}

static void bagInsertion(list<ParamTask> *bag_,string toExec, string nameFunc, vector<string> params, vector<string> returns, lua_State* storeVals){
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