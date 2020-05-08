//Author: Saulo Henrique Cabral Silva

#ifndef PROC_HPA_H 
#define PROC_HPA_H

#include <QApplication>
#include <QtCore>
#include <string>
#include "luna.h"

#include "luaNeighborhood.h"
#include "luaCell.h"
#include "luaCellularSpace.h"

#include "luaEvent.h"
#include "luaMessage.h"
#include "luaTimer.h"

#include "luaAgent.h"
#include "luaTrajectory.h"
#include "luaGlobalAgent.h"
#include "luaLocalAgent.h"
#include "luaRule.h"
#include "luaJumpCondition.h"
#include "luaFlowCondition.h"
#include "luaControlMode.h"
#include "luaEnvironment.h"


using namespace std;

// Tiago - comentario
// A classe ProcHPA implementar o processo master da arquitetura TerraME HPA
// Ele executa a pilha principal do modelo lua e gerencia o trabalho dos workers.
class ProcHPA : public QThread {
private:

    //estado da funçao/modelo que vai ser executada (entrada da chamada externa)
    lua_State *funcLua;
    //nome do modelo traduzido
    string nameTranslatedModel;

public:

	ProcHPA();

	//quando uma função terminou
    void set_State(lua_State *Func);
    
	lua_State* getState();

	//nome da funcao que esta sendo executada (para controle do join)
    string getNameTranslated();

	//qual a próxima função a ser executada (lembre-se que esttou tentando fazer reuso das instâncias de worker's)
    void setNameTranslated(string);

	//Thread
    virtual void run();

};

#endif //PROC_HPA_H