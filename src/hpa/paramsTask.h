//author: Saulo Henrique Cabral Silva

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
	//local onde o retorno da funçao eecutada em paralelo deve ser empilhado
	
	int refOfReturn;
	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	lua_State *store_val;

public:
	ParamTask();

	~ParamTask();

	//inserção da chamada da função, como foi feita na pilha principal
	void setCallTask(string param_);

	//apenas uma inserção no vetor de parametros
	void setParamCall(string param_);

	//apenas uma inserção no vetor de retorno de uma função
	void setParamRet(string param_);

	//chamada da função, como foi feita na pilha principal
	string getCallTask();

	//apenas acesso a um elemento do vetor de parametro
	string getParamCall(int position_);

	//apenas acesso a um elemento do vetor de retorno
	string getParamRet(int position_);

	//é possível definir um conjunto de parametros por atribuição (isso vai substituir todos os adicionados anteriormente)
	void setSetParam(vector<string> SetParams_);

	//
	void setSetRet(vector<string> SetReturns_);

	//é possível obter toda a lista de parâmetros
	vector<string> getSetParam();

	//retorna toda a lista de retorno(quais variáveis vão ser atribuidas)
	vector<string> getSetRet();

	lua_State* get_State();

	void set_State(lua_State*);

	string getNameTask();

	void setNameTask(string nameTask);

};

#endif