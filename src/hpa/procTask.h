//Author: Saulo Henrique Cabral Silva

#ifndef PROC_TASK_H 
#define PROC_TASK_H

extern "C"{
	#include <lua.h>
}

//#include <QApplication>
#include <QtCore>

#include "paramsTask.h"
#include "bagOfTasks.h"

using namespace std;

// Tiago - comentario
// A classe ProcTask implementa os workers da arquitetura TerraME HPA
class ProcTask : public QThread {
private:
	//estado da funçao/modelo que vai ser executada
    lua_State *funcLua;

    //nome da funcao que foi chamada
    string nameFunc;

	//parametros de chamada da task
	vector<string> paramOfCham;

	//variaveis de retorno da task
	vector<string> paramOfReturn;
	
	int refOfReturn;
	//State em que se encontram os parametros que seram passados para o metodo
	//tava com problema em pegar os parametros antigos
	lua_State *storeVal;

	int isRunning_;

	//referencia para enganar garbage collector
	int refThread;

	list<ParamTask> *Bag;

	QMutex *lock_bag;

public:
	
	ProcTask();

    //quando um a função terminou
    void set_State(lua_State *Func);
    
	lua_State* getState();

	//nome da funcao
    string getName();
    
	//nome da nova função a ser executada
	void setName(string);

	//parametros para a execução da próxima função
	void setParms(vector<string>,vector<string>,int,int,lua_State*);
	void setParms(vector<string>,vector<string>,int,lua_State*);

	vector<string> getParamOfCham();
	vector<string> getParamOfReturn();

	void setParamOfCham(vector<string> paramOfCham_);
	void setParamOfReturn(vector<string> paramOfReturn_);

	void w_stack();

	//thread
	void run();

	//set o estado corrente da task em execução
	void setRunState(int runState_);

	int getRunState();

	void setRefThread(int ref_);
	int getRefThread();

	//metodos para acessar e setar a bag para fora(public, like interface) para o controle de acesso também uma vez 
	//que ele é compartilhado
	void setBag(list<ParamTask>*);
	void setControlQMut(QMutex* controlMutex);

	list<ParamTask>* getBag();
	QMutex* getControlQMut();
};


#endif //PROC_HPA_H
