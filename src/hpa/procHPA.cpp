//Author: Saulo Henrique Cabral Silva
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
qWarning("ProcHPA iniciou");
//	QString tmePath(getenv("TME_PATH"));
//
//	#if defined ( TME_WIN32 )
//    //tmePath.append("\\bin\\Lua\\TerraME.lua");
//	#else
//qWarning("LINUX!!!!");
//		tmePath.append("/bin/Lua/TerraME.lua");
//	#endif

	//luaL_openlibs(funcLua);
//qWarning(tmePath.toAscii().constData());
	//isso aqui deve encontrar o TME_PATH
	//luaL_loadfile(funcLua, tmePath.toStdString().c_str()) //.toAscii().constData()) 
	//				|| lua_pcall(funcLua, 0, 0, 0);
	luaL_dostring(funcLua,"__HPA_MODEL_ID_ = 0;");
qWarning(nameTranslatedModel.c_str());
	//olhar esta chamada
	int erroTrad = luaL_loadfile(funcLua, nameTranslatedModel.c_str());
	if( ! erroTrad ) {
qWarning("arquivo traduzido carregado com sucesso");	
	}
	else {
qWarning("erro sintatico no arquivo traduzido");	
		string msg = lua_tostring(funcLua,-1);
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

	//aqui já tenho a execução do modelo principal
	if( !lua_pcall(funcLua, 0, 0, 0)) {
qWarning("arquivo executado com sucesso");	
	}
	else {
qWarning("arquivo nao pode ser executado");	
		string msg = lua_tostring(funcLua,-1);
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
		qWarning(newMsg.c_str());
	}

qWarning("ProcHPA terminou");
	/*
	lua_getglobal(funcLua,"SAULO");
	cerr << lua_tointeger(funcLua,-1) << endl;
	*/
}

