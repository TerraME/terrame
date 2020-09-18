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

#include "hpa.h"

#ifdef WIN32
	#include <Windows.h>
#elif __linux__
	#include <unistd.h>
#endif

void HPA::createWorkers(){
	//lua_settop(ModeloMain, 0);
	//lua_gc(ModeloMain, LUA_GCCOLLECT, 0);

	//iniciando os workers
	for(int i = 0; i < getNumCpu();i++){
		workers.push_back(new ProcTask()); // tiago - outra fonte de leak!
		workers.at(workers.size()-1)->set_State(lua_newthread(ModeloMain));
		workers.at(workers.size()-1)->setRefThread(luaL_ref(ModeloMain, LUA_REGISTRYINDEX));
		//setamos aqui o recurso compartilhado entre o processo principal hpa e os trabalhadores
		//(e' preciso efetuar o controle de acesso as tasks)
		workers.at(workers.size()-1)->setBag(&BAG);
		workers.at(workers.size()-1)->setControlQMut(&LOCK_BAG);
		lua_gc(workers.at(workers.size()-1)->getState(), LUA_GCSTOP, 0);
	}
}

// Tiago - Metodo do Saulo que eu considerei muito mal implementdo, entao comentei e fiz o meu a seguir
// void HPA::removeWorkers(lua_State *L){
// 	for(int i = 0; i < getNumCpu();i++){
// 		luaL_unref(L, workers.at(i)->getRefThread(),	LUA_REGISTRYINDEX);

// 		// Tiago -- necessario para remover leak de memoria geraso pelo saulo
// 		if (workers[i]) delete workers[i];
// 	}

// 	workers.clear();
// 	workers = vector<ProcTask*>(); // Tiago - nao faco ideia do que esta linha faz. Atribuindo um objeto local ao atributo da classe, para mim vai dar PROBLEMA!
//									// Mais doido ainda quando vemos que o vetor workers eh estatico'
// }

void HPA::removeWorkers(lua_State *L){
	vector<ProcTask*>::iterator it;

	for(it = workers.begin(); it != workers.end(); it++){
		luaL_unref(L, (*it)->getRefThread(), LUA_REGISTRYINDEX);

		// Tiago -- necessario para remover leak de memoria geraso pelo saulo
		delete *it;
	}

	workers.clear();

}

void HPA::removeLockSections( void ){
	QHash<QString, QMutex*>::iterator it;

	for (it = lockSection.begin(); it != lockSection.end(); ++it)  delete it.value();

	lockSection.clear();
	lockSectionUse.clear();
}

HPA::HPA(lua_State* L){
//
//	ModeloMain = L;
//	mainStack = new ProcHPA(); // Tiago - fonte de leak
//
//	mainStack->set_State(ModeloMain);
//
//#ifdef WIN32
//	//informacao sobre a quantidade de cores da maquina
//	SYSTEM_INFO sysinfo;
//	GetSystemInfo(&sysinfo);
//	setNumCpu(sysinfo.dwNumberOfProcessors);
//#else
//	int numberOfProcessors = sysconf(_SC_NPROCESSORS_ONLN);
//	setNumCpu(numberOfProcessors);
//#endif
//
//	createWorkers();
//	string pathModel = "D:/terrame/tests/hpa_model_test.lua";
//	qWarning(pathModel.c_str());
//	mainStack->setNameTranslated(pathModel.c_str());
//	qWarning("construtor HPA - fim");
//	//removendo todos os restos de conversao do path principal
//	//parser->cleanTranslate();

//////////////////////////////////////////////////////////////////////////////////////

	refGlobalHPA = luaL_ref(L, LUA_REGISTRYINDEX);

	luaL_dostring(L, "__T__"); // Tiago - achei que isto era codigo que o Saulo usou para debug e esqueceu de apagar, mas se tirar estas linha tudo para de funcionar

	int temp = luaL_ref(L, LUA_REGISTRYINDEX); // Tiago - achei que isto era codigo que o Saulo usou para debug e esqueceu de apagar, , mas se tirar estas linha tudo para de funcionar

	//aqui setamos o recurso compartilhado para o processo ou a pilha principal(dessa forma economizamos memo'ria)
	setBag(&BAG);
	setControlQMut(&LOCK_BAG);

	// Tiago - linha necessaria para resolver leak
	mainStack = NULL;

	//luaL_unref(L, LUA_REGISTRYINDEX, temp);
}

// Tiago -- comentei pq nao estava em uso
// HPA::HPA(string pathModel){
// 	ParserHPA *parser = new ParserHPA(pathModel);

// 	mainStack = new ProcHPA();
// 	ModeloMain = luaL_newstate();

// 	//esta aqui e' a pilha principal(ela efetua as chamadas)
// 	mainStack->set_State(ModeloMain);

// 	//informacao sobre a quantidade de cores da maquina
// 	#if defined ( TME_WIN32 )
// 		SYSTEM_INFO sysinfo;
// 		GetSystemInfo(&sysinfo);
// 		setNumCpu(sysinfo.dwNumberOfProcessors);
// 	#else
// 		int numberOfProcessors = sysconf( _SC_NPROCESSORS_ONLN );
// 		setNumCpu(numberOfProcessors);
// 	#endif

// 	createWorkers();

// 	luaL_openlibs(mainStack->getState());

// 	//esse aqui e' o novo modelo a ser executado (aqui ele ja' esta traduzido)
// 	pathModel = parser->getNewPath();

// 	Luna<luaCellIndex>::Register(mainStack->getState());

//     Luna<luaCell >::Register(mainStack->getState());
//     Luna<luaNeighborhood >::Register(mainStack->getState());
//     Luna<luaCellularSpace >::Register(mainStack->getState());

//     Luna<luaFlowCondition >::Register(mainStack->getState());
//     Luna<luaJumpCondition >::Register(mainStack->getState());
//     Luna<luaControlMode >::Register(mainStack->getState());
//     Luna<luaLocalAgent >::Register(mainStack->getState());
//     Luna<luaGlobalAgent >::Register(mainStack->getState());

//     Luna<luaTimer >::Register(mainStack->getState());
//     Luna<luaEvent >::Register(mainStack->getState());
//     Luna<luaMessage >::Register(mainStack->getState());
//     //registrar logo na cahamada dessa pilha
// 	Luna<HPA >::Register(mainStack->getState());

//     Luna<luaEnvironment >::Register(mainStack->getState());
//     Luna<luaTrajectory >::Register(mainStack->getState());

// 	mainStack->setNameTranslated(pathModel);

// 	//removendo todos os restos de conversao do path principal
// 	//parser->cleanTranslate();
// }

HPA::HPA(string pathModel, lua_State *L){
	//ParserHPA *parser = new ParserHPA(pathModel); // Tiago - fonte de leak
	//esta aqui e' a pilha principal(ela efetua as chamadas)
	ModeloMain = L;
	mainStack = new ProcHPA(); // Tiago - fonte de leak

	mainStack->set_State(ModeloMain);

	#ifdef WIN32
		//informacao sobre a quantidade de cores da maquina
		SYSTEM_INFO sysinfo;
		GetSystemInfo(&sysinfo);
		setNumCpu(sysinfo.dwNumberOfProcessors);
	#else
		int numberOfProcessors = sysconf( _SC_NPROCESSORS_ONLN );
		setNumCpu(numberOfProcessors);
	#endif

	createWorkers();

	//esse aqui e' o novo modelo a ser executado (aqui ele ja' esta traduzido)
	//pathModel = //"D:/terrame/tests/hpa_model_test.lua"; //parser->getNewPath();
	mainStack->setNameTranslated(pathModel.c_str());
	//removendo todos os restos de conversao do path principal
	//parser->cleanTranslate();

	// Tiago -- removendo leaks de memoria gerados pelo Saulo
	//delete parser;

}

// Tiago -- estava tentando remover leaks de memoria gerados pelo Saulo
// mas o codigo abaixo nao funcionou, parece que o HPA roda como variavel statica pq "this" tem sempre o mesmo valor
// e quando a pilha lua e' fehada por "lua_close()" no main(), o codigo abaixo gera um "segmentation fault"
// tive que fazer mainStack = NULL no construtor HPA( lusState*) chamado por lua
HPA::~HPA(){
	if(mainStack) {
		if( mainStack->getState() ) removeWorkers(mainStack->getState());
	    removeLockSections();
		delete mainStack;
	}
    else // so o objeto HPA criado em Lua tem referencia e nao tem mainStack
	{
		luaL_unref(L, LUA_REGISTRYINDEX, refGlobalHPA);
	}
}

int HPA::execute(){
	//execucao da thread aqui
	mainStack->start();
	mainStack->wait();
	return true;
}

// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_JOINALL(lua_State* L){
int HPA::joinall(lua_State* L){
	while(!Bag->empty()){
		for (int i = 0; i < getNumCpu(); i++) {
			if (!workers.at(i)->isRunning() && !Bag->empty())
                workers.at(i)->start();
		}

		for (int i = 0; i < getNumCpu(); i++){
			if (workers.at(i)->isRunning())
				workers.at(i)->wait();
		}
    }

	for (int i = 0; i < getNumCpu(); i++){
		if (!workers.at(i)->isRunning() && !Bag->empty())
			workers.at(i)->start();
	}

	for (int i = 0; i < getNumCpu(); i++){
		if (workers.at(i)->isRunning())
			workers.at(i)->wait();
	}

	/*
	if(lua_status(L) != 0 && lua_status(L) != 1){
		cerr << "error in main stack \n";
	}*/

	return 0;
}

//me'todo para setar quantidade de cores a serem utilizados na execucao(para testes TDD)
// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_NP(lua_State* L){
int HPA::np(lua_State* L){
	int newQuantProc = lua_tonumber(L, 1);

	if(!newQuantProc || (newQuantProc == numCPU))
	{
		lua_pushinteger(L, numCPU);
		return 1;
	}
	//e' preciso esperar todas as threads terminarem pois estas serao destrui'das para a criacao de novas
	HPA::joinall(L);

	removeWorkers(L);
	numCPU = newQuantProc;

	createWorkers();
	return 0;
}

// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_Acquire(lua_State *L){
int HPA::acquire(lua_State *L){
	int temp_par = lua_tonumber(L, 1);

	char resultConvert[16];
	sprintf(resultConvert, "%d", temp_par);
	string nameSec = resultConvert;

	justOne.lock();

	//aqui entra a parte de verificacao na HASH principal
	if(!lockSection.contains(nameSec.c_str())){
		lockSection.insert(nameSec.c_str(), new QMutex());  // Tiago -- esse mutex vai gerar leak
	}

	justOne.unlock();

	lockSection[nameSec.c_str()]->lock();

	return 0;
}

// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_Release(lua_State *L){
int HPA::release(lua_State *L){
	int temp_par = lua_tonumber(L, 1);

	char resultConvert[16];
	sprintf(resultConvert, "%d", temp_par);
	string nameSec = resultConvert;

	justOne.lock();
	lockSection[nameSec.c_str()]->unlock();
	justOne.unlock();

	return 0;
}

// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_JOIN(lua_State* L){
int HPA::join(lua_State* L){
	string nameFuncJoin = lua_tostring(L, 1);

	//dos workers que estao executando existe algum qeu esta a executar esta funcao?
	for(int i = 0;i < workers.size();i++){
		if(!workers.at(i)->getName().compare(nameFuncJoin)){
			workers.at(i)->wait();
		}
	}

	bool thereATask = false;
	//agora preciso verificar se a bag recebeu alguma chamada dessa funcao

	justOne.lock();
	int sizeBag = Bag->size();

	for (std::list<ParamTask>::iterator it = Bag->begin(); it != Bag->end(); it++){
		if(!it->getNameTask().compare(nameFuncJoin)){
			thereATask = true;
			break;
		}
	}
	justOne.unlock();

	//existe processo na bag com este nome e temos que aguardar a sua execucao
	if(thereATask){
		for(int i = 0; i < workers.size();i++){
			workers.at(i)->wait();
		}
	}

	if(lua_status(L) != 0 && lua_status(L) != 1){
		cerr << "error in main stack \n";
	}

	return 0;
}

//metodo auxiliar para o TerraMEHPA para leitura dos parâmetros de entrada da chamada paralela
lua_State* HPA::Read_Parameters(lua_State* L, vector<string>name_of_par){
	//estado que vai armezanar temporariamente o valor dos parametros
	lua_State *store_val = luaL_newstate();

	//percorrer cada parametro
	int positionOfParam = 2;

	//leitura deve ser realizada aqui passar por todos os parametros
	for(int ind = 0; ind < name_of_par.size();ind++){
		if(lua_type(L, positionOfParam) != LUA_TTABLE)
		{
			HPAxcopy_aux(L, store_val, positionOfParam);
		}
		else
		{
			//todo tipo de tiago para aqui
			lua_getfield(L, -1, "cObj_");

			//caso em que tenho um cellular space
			if(lua_type(L, -1) == 7)
			{
				//para este caso preciso inserir uma variavel de controle onde possa
				//consultar para efetuar o xmove
				luaL_dostring(store_val, (name_of_par[ind]+"_is_ref = 1").c_str());

				lua_pop(L, 1);
				lua_xmove(L, store_val, 1);
			}
			else
			{
				lua_pop(L, 1);
				HPAxcopy(L, store_val, positionOfParam);
			}
		}

		lua_setglobal(store_val, name_of_par[ind].c_str());
		//luaL_ref(store_val, LUA_REGISTRYINDEX);
		positionOfParam++;
	}

	return store_val;
}

vector<string> HPA::findNamePar(string toExecut){
	vector<string> executeClean;
    vector<string> namesPar;

    S_Tokenize(toExecut, executeClean, "( , )");

    for(int i = 1;i < executeClean.size();i++){
        if(i == executeClean.size()-1){
			if(executeClean.at(i).compare(";")){
                namesPar.push_back(executeClean.at(i));
			}
		}else{
			namesPar.push_back(executeClean.at(i));
		}
    }

	return namesPar;
}

string HPA::findNameFunc(string toExecut){
	vector<string> executeClean;

    S_Tokenize(toExecut, executeClean, "(");

	if(executeClean.empty()){
		exit(0);
		return "";
	}

	return executeClean.at(0);
}

// Tiago - comentei linha abaixo para manter coerencia com a nomenclarura adotada no TerraME
//int HPA::HPA_PARALLEL(lua_State* L){
int HPA::parallel(lua_State* L){
	int q_paramet = lua_gettop(L);

	//aqui vem a chamada da funcao e seus parâmetros
	string to_execute = lua_tostring(L, 1);

	//chamada do metodo para tratar o retorno de resultado aqui (to_execute)
	//Sera' implementado posteriormente uma vez que ainda e' preciso pensar em Cena'rios para esta antes de implementar (TDD)

	//funcao para reconhecer os respectivos nomes dos parametros passados (retornamos um vetor com os nomes)
	vector<string> namesOfPar = findNamePar(to_execute);

	//nome da funcao que sera executa (caso em que temos retorno isso aqui vai alterar)
	string nameFuncToExec = findNameFunc(to_execute);

	//declaracao de um vetor para retorno da funcao (o tratamento da chamada da funcao deve aqui)
	vector<string> varReturn;

	//insercao na bag aqui para baixo (mudanca agora na insercao do nome da funcao a que a task corresponde)
	//stack com o valor dos parametros para serem passados
	lua_State *tempStackVals = Read_Parameters(L, namesOfPar);

	//bagInsertion(to_execute, nameFuncToExec, namesOfPar, varReturn, tempStackVals);

	//isso aqui faz parte do metodo de baginsertion
	lock_bag->lock();

	ParamTask toIncludeBagP;
	toIncludeBagP.setCallTask(to_execute);
	toIncludeBagP.setNameTask(nameFuncToExec);
	toIncludeBagP.setSetParam(namesOfPar);
	toIncludeBagP.setSetRet(varReturn);

	if(namesOfPar.size() == 0)
		lua_close(tempStackVals);
	else
		toIncludeBagP.set_State(tempStackVals);

	Bag->push_back(toIncludeBagP);
	lock_bag->unlock();

	//fim do metodo insertion aqui

	//aqui verificamos se existe algum worker parado e efetuamos a inicializacao de algum deles para tratar a requisicao caso algum esteja ocioso
	for(int i = 0; i < workers.size();i++){
		if(!workers.at(i)->isRunning()){
			workers.at(i)->start();
			break;
		}
	}

	return 0;
}

lua_State *getthread (lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;
  }
}

int HPA::HPATests(lua_State * now){
	//string s = lua_tostring(now, 1);
	/*
	lua_newtable(now);
	lua_pushinteger(now, 1337);
	lua_setfield(now, -2, "tablekey");
	lua_setfield(now, LUA_REGISTRYINDEX, "mynewtable");
	*/
	/*
	lua_Debug luaDebug;
	lua_getstack(now, 0, &luaDebug);
	lua_setlocal(now, &luaDebug, 0);
	*/

	lua_pushinteger(now, 98);
	lua_setglobal(now, "teste");
	lua_getglobal(now, "teste");

	int arg;
	lua_State *L1 = getthread(now, &arg);
	lua_Debug ar;

	if (!lua_getstack(L1, luaL_checkinteger(now, arg+1), &ar))
		return luaL_argerror(now, arg+1, "level out of range");

	luaL_checkany(now, arg+3);
	lua_settop(now, arg+3);
	lua_xmove(now, L1, 1);
	lua_pushstring(now, lua_setlocal(L1, &ar, luaL_checkinteger(now, arg+2)));
	cerr << "oi" << endl;

	return 1;

	//luaL_dostring(now, "teste = 10");
	//lua_pushinteger(now, 10);
	//return 1;
}

//metodos para setar e acessar os recursos da bag
void HPA::setBag(list<ParamTask>* Bag_){
	Bag = Bag_;
}

void HPA::setControlQMut(QMutex* controlMutex_){
	lock_bag = controlMutex_;
}

list<ParamTask>* HPA::getBag(){
	return Bag;
}

QMutex* HPA::getControlQMut(){
	return lock_bag;
}
