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

#include "procTask.h"
#include "envHPA.h"

ProcTask::ProcTask(){
	isRunning_ = 0;
}

void ProcTask::set_State(lua_State *now) {
    //qual lua state deve estar sendo executado
    this->funcLua = now;
}

lua_State* ProcTask::getState(){
	return funcLua;
}

void ProcTask::setName(string _name) {
    //nome da funcao que vai ser executada
    this->nameFunc = _name;
}

string ProcTask::getName(){
	return nameFunc;
}

//acesso dos vetores com os respectivos parametros para a execucao
vector<string> ProcTask::getParamOfCham(){
		return this->paramOfCham;
}

vector<string> ProcTask::getParamOfReturn(){
	return this->paramOfReturn;
}

//set parametros para execucao e para retorno
void ProcTask::setParamOfCham(vector<string> paramOfCham_){
	this->paramOfCham = paramOfCham_;
}

void ProcTask::setParamOfReturn(vector<string> paramOfRet_){
	this->paramOfReturn = paramOfReturn;
}

int ProcTask::getRunState(){
	return isRunning_;
}

void ProcTask::setRefThread(int refThread_){
	this->refThread = refThread_;
}

int ProcTask::getRefThread(){
	return this->refThread;
}

void ProcTask::setRunState(int runState_){
	this->isRunning_ = runState_;
}

void ProcTask::w_stack(){
	QTime now;
	double calc_t;
	//for(int ind = 0; ind < this->n_execute_clock; ind++)
	for(int ind = 0; ind < 1000; ind++)
		calc_t = QTime::currentTime().toString().toDouble();
}

void ProcTask::setParms(vector<string> param_of_cham_, vector<string> param_of_return_, int ID_by_executed_, int ref_of_return_, lua_State* store_val_){
	//tilizamos os valores setados pois nao e' necessa'rio acessar a bag para este
	//use_Params_Set = true;

	this->paramOfCham = param_of_cham_;
	this->paramOfReturn = param_of_return_;

	//local onde o retorno da funcao eecutada em paralelo dev ser dado
	//Sualo refactoring verificar passagem destes parametros no HPA
	//this->refOfReturn = ref_of_return_;

	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	this->storeVal = store_val_;

}

void ProcTask::setParms(vector<string> param_of_cham_, vector<string> param_of_return_, int ID_by_executed_, lua_State* store_val_){
	//tilizamos os valores setados pois nao e' necessa'rio acessar a bag para este
	//use_Params_Set = true;

	this->paramOfCham = param_of_cham_;
	this->paramOfReturn = param_of_return_;

	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	this->storeVal = store_val_;
}

void ProcTask::run() {
	bool just_one = false;

	//thread comecou a consumir
	this->isRunning_ = 1;

	while(!Bag->empty()){
		lock_bag->lock();

		if(Bag->size() <= getNumCpu()){
			just_one = true;
		}

		ParamTask tempParam;

		//SAULO
		//bagOfTask(tempParam);
		//neste caso sai um resultado para ser tratado no run (preciso refatorar aqui)

		if(Bag->empty()){
			lock_bag->unlock();
			return;
		}else{
			tempParam = Bag->front();
			//primeira task a ser tratada
			Bag->pop_front();
		}
		//lock_bag->unlock();

		//lockAcess.lock();
		this->setName(tempParam.getNameTask());

		//tenho que tentar liberar a memoria gasta para temp_Param.store_val
		if (tempParam.getSetParam().size() > 0) {
			hpaLoadParams(funcLua, tempParam.getSetParam(), tempParam.get_State());
			lua_settop(tempParam.get_State(), 0);
			//fechamento ocorre so' aqui (uma vez, se a pilha nao recebe parametros ela nao e' declarada)
			lua_close(tempParam.get_State());
		}

		lua_getglobal(funcLua, this->nameFunc.c_str());
//lua_Debug ar; // Tiago
//lua_getinfo(funcLua, ">n", &ar); // Tiago
//qWarning("Aqui");
//qWarning(ar.name);
//char buffer[10];
//sprintf(buffer, "%d" , ar.currentline);
//qWarning(buffer);

		for(int ind = 0;ind < tempParam.getSetParam().size();ind++){
			string par_Now = "__HPA_VAR__";
			char C_aux_par[BUFSIZ];

			#ifdef WIN32
				//para windows
				itoa(ind+1, C_aux_par, 10);
			#else
				//para linux(nao existe itoa em linux)
				sprintf (C_aux_par, "%ld", (ind+1));
			#endif

			string S_aux_par = C_aux_par;
			par_Now += S_aux_par;
			lua_getglobal(getState(), par_Now.c_str());
		}

		//lockAcess.unlock();
		lock_bag->unlock();

		//lua_call(funcLua, tempParam.getSetParam().size(), 1);
		int that_ok = lua_resume(this->funcLua, this->funcLua, tempParam.getSetParam().size()); //(funcLua, tempParam.getSetParam().size(), 1);

		lockAcess.lock();
		//QMutexLocker locker(&lockAcess);

		//chamada de um metodo de return entra agora
		if(tempParam.getSetRet().size() > 0){
			//voltar a versao antiga
			/*lua_getref(Execute_HPA->MAIN->Func_Lua, temp_Param.ref_of_return);
			lua_xmove(Func_Lua, Execute_HPA->MAIN->Func_Lua, temp_Param.param_of_return.size());
			lua_unref(Execute_HPA->MAIN->Func_Lua, temp_Param.ref_of_return);*/
			hpaLoadParams(getState(), tempParam.getSetRet(), tempParam.get_State());
		}else{
			//necessito retirar a chamada da funcao do topo
			lua_pop(getState(), 1);
		}

		lua_settop(getState(), 0);

		//lua_gc(getState(), LUA_GCSTOP, 0);

		//qualquer estado diferebte exige desalocacao e temos que construir uma nova co-routine
		if(lua_status(getState()) != 0 && lua_status(getState()) != 1 && that_ok != 0 && that_ok != 1){
		//if(lua_status(getState()) != 0 && lua_status(getState()) != 1){
			//lua_Debug ar; // Tiago
			//int erron = lua_getstack(getState(), 1, &ar ); // Tiago
			//lua_getinfo(getState(), "n", &ar); // Tiago
			cerr << "Verify the call just below the directive hpa parallel, named: " << this->nameFunc.c_str() << endl; //- near to " << ar.name << ar.source << ":"<<  ar.currentline << ":"<< " defined at line:"<< ar.linedefined << endl; // Tiago
			cerr.flush();
			lua_yield(getState(), 0);
			//lua_settop(Func_Lua, 0);
			luaL_unref(getState(), getRefThread(), LUA_REGISTRYINDEX);
			set_State(lua_newthread(ModeloMain));
			setRefThread(luaL_ref(ModeloMain, LUA_REGISTRYINDEX));
		}

		lockAcess.unlock();
		if(just_one){
			break;
		}

	}
	setRunState(0);
}

//metodos para setar e acessar os recursos da bag
void ProcTask::setBag(list<ParamTask>* Bag_){
	Bag = Bag_;
}

void ProcTask::setControlQMut(QMutex* controlMutex_){
	lock_bag = controlMutex_;
}

list<ParamTask>* ProcTask::getBag(){
	return Bag;
}

QMutex* ProcTask::getControlQMut(){
	return lock_bag;
}
