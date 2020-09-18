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

#include "procHPA.h"
#include "envHPA.h"

extern  char* TME_PATH; // Tiago

//#define TME_WIN32

extern "C"
{
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
}

#include "luna.h"

ProcHPA::ProcHPA(){
	funcLua = luaL_newstate();
	luaL_openlibs(funcLua);
}

void ProcHPA::set_State(lua_State *now) {
    //qual lua state deve estar sendo executado
	lua_close(this->funcLua);
	this->funcLua = now;
}

lua_State* ProcHPA::getState(){
	return this->funcLua;
}

void ProcHPA::setNameTranslated(string _name) {
    //nome da funcao que vai ser executada
	this->nameTranslatedModel = _name;
}

string ProcHPA::getNameTranslated(){
	return nameTranslatedModel;
}

void ProcHPA::run(){
	luaL_dostring(funcLua, "__HPA_MODEL_ID_ = 0;");
	//olhar esta chamada
	int erroTrad = luaL_loadfile(funcLua, nameTranslatedModel.c_str());
	if( ! erroTrad ) {
	}
	else {
		string msg = lua_tostring(funcLua, -1);
		size_t firstPos = msg.find_first_of(":");
		size_t lastPos = msg.find_first_of(":", firstPos+1);
		string originalLineNumber = msg.substr(firstPos+1, (lastPos-firstPos)-1);
		int lineNumber = atoi(originalLineNumber.c_str()) - 1;
		char newLineNumber[10];
		sprintf(newLineNumber, "%d", lineNumber);
		string newMsg = nameTranslatedModel;
		#ifdef WIN32
		    int fileNamePos = nameTranslatedModel.find_last_of("\\");
		#else
		    int fileNamePos = nameTranslatedModel.find_last_of("/");
		#endif
		newMsg = newMsg + ":" + newLineNumber + ":" + msg.substr(lastPos+1);
		newMsg.erase(fileNamePos+1, 4);

		cerr << "Error: " << erroTrad << " msg: \n" << msg << "\n" << firstPos << ", " << lastPos << ", " <<  originalLineNumber  << ", "<< lineNumber<<"\n" << newMsg << endl;
	}

	// Tiago - Comente a linha abaixo se quiser ver o codigo traduzido
	//remove(nameTranslatedModel.c_str());

	//aqui ja' tenho a execucao do modelo principal
	if (lua_pcall(funcLua, 0, 0, 0))
	{
		string msg = lua_tostring(funcLua, -1);
		//size_t firstPos = msg.find_first_of(":");
		//size_t lastPos = msg.find_first_of(":", firstPos+1);
		//string originalLineNumber = msg.substr(firstPos+1, (lastPos-firstPos)-1);
		//int lineNumber = atoi(originalLineNumber.c_str()) - 1;
		//char newLineNumber[10];
		//sprintf(newLineNumber, "%d", lineNumber);
		//string newMsg = nameTranslatedModel;
		#ifdef WIN32
		    int fileNamePos = nameTranslatedModel.find_last_of("\\");
		#else
		    int fileNamePos = nameTranslatedModel.find_last_of("/");
		#endif
		//newMsg = newMsg + ":" + newLineNumber + ":" + msg.substr(lastPos+1);
		string newMsg = msg;
		newMsg.erase(fileNamePos+1, 4);
	}
	/*
	lua_getglobal(funcLua, "SAULO");
	cerr << lua_tointeger(funcLua, -1) << endl;
	*/
}
