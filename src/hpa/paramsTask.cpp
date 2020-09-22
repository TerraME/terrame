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

//apenas uma insercao no vetor de parametros
void ParamTask::setParamCall(string param_){
	this->paramsOfCall.push_back(param_);
}

//apenas uma insercao no vetor de parametros
void ParamTask::setCallTask(string callTask_){
	this->codeCall = callTask_;
}

//apenas uma insercao no vetor de retorno de uma funcao
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

//e' possi'vel definir um conjunto de parametros por atribuicao (isso vai substituir todos os adicionados anteriormente)
void ParamTask::setSetParam(vector<string> SetParams_){
	this->paramsOfCall = SetParams_;
}

//
void ParamTask::setSetRet(vector<string> SetReturns_){
	this->paramsOfReturn = SetReturns_;
}

//e' possi'vel obter toda a lista de parametros
vector<string> ParamTask::getSetParam(){
	return paramsOfCall;
}

//retorna toda a lista de retorno(quais varia'veis vao ser atribuidas)
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
	this->nameFuncTask = nameTask_;
}
