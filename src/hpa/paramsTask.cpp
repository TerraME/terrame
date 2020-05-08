//Author: Saulo Henrique Cabral Silva

#include "paramsTask.h"

#include <iostream>

ParamTask::ParamTask(){
	paramsOfCall = vector<string>();
	paramsOfReturn = vector<string>();
	//store_val = luaL_newstate();
	refOfReturn = 0;
}

ParamTask::~ParamTask(){

	paramsOfCall.clear();
	paramsOfReturn.clear();
	nameFuncTask.clear();
	codeCall.clear();
	refOfReturn = NULL;
}

//apenas uma inser��o no vetor de parametros
void ParamTask::setParamCall(string param_){
	this->paramsOfCall.push_back(param_);
}

//apenas uma inser��o no vetor de parametros
void ParamTask::setCallTask(string callTask_){
	this->codeCall = callTask_;
}

//apenas uma inser��o no vetor de retorno de uma fun��o
void ParamTask::setParamRet(string param_){
	this->paramsOfReturn.push_back(param_);
}

string ParamTask::getCallTask(){
	return this->codeCall;
}

//apenas acesso a um elemento do vetor de parametro
string ParamTask::getParamCall(int position_){
	return paramsOfCall.at(position_);
}

//apenas acesso a um elemento do vetor de retorno
string ParamTask::getParamRet(int position_){
	return paramsOfReturn.at(position_);
}

//� poss�vel definir um conjunto de parametros por atribui��o (isso vai substituir todos os adicionados anteriormente)
void ParamTask::setSetParam(vector<string> SetParams_){
	this->paramsOfCall = SetParams_;
}

//
void ParamTask::setSetRet(vector<string> SetReturns_){
	this->paramsOfReturn = SetReturns_;
}

//� poss�vel obter toda a lista de par�metros
vector<string> ParamTask::getSetParam(){
	return paramsOfCall;
}

//retorna toda a lista de retorno(quais vari�veis v�o ser atribuidas)
vector<string> ParamTask::getSetRet(){
	return paramsOfReturn;
}

lua_State* ParamTask::get_State(){
	return store_val;
}

void ParamTask::set_State(lua_State* store_val_){
	this->store_val = store_val_;
}

string ParamTask::getNameTask(){
	return nameFuncTask;
}

void ParamTask::setNameTask(string nameTask_){
	//cerr << "set: " << nameTask_ << endl;
	this->nameFuncTask = nameTask_;
}

