//Author: Saulo Henrique Cabral Silva
#ifndef HPA_H 
#define HPA_H 

#include "procHPA.h"
#include "procTask.h"
#include "envHPA.h"
#include "parserHPA.h"

#include <iostream>
#include <vector>
#include <iostream>
#include <string>

#include "bagOfTasks.h"

extern "C"{
	//#include <WinBase.h>
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
}
#include "luna.h"

using namespace std;

//vetor de trabalhadores (minhas threads)
static vector<ProcTask*> workers;


class HPA { 

	
	int refGlobalHPA;

public:
	//para seguir o template do Luna
    static const char className[];
    static Luna<HPA>::RegType methods[];
		
private:

	//pilha de execução principal
	ProcHPA *mainStack;
	string pathModel;
	
	list<ParamTask> *Bag;
	QMutex *lock_bag;

	//Hash para criação das seções criticas lembrar de utilizalos com o wait condition
	QHash<QString,QMutex*> lockSection;
	QHash<QString,bool> lockSectionUse;
	QMutex justOne;

	void createWorkers();
	void removeWorkers(lua_State *);
	void removeLockSections(void); // Tiago - remover leak
	lua_State* Read_Parameters(lua_State*, vector<string>);
	vector<string> findNamePar(string);
	string findNameFunc(string toExecut);

	//metodos para acessar e setar a bag para fora(public, like interface) para o controle de acesso também uma vez 
	//que ele é compartilhado
	void setBag(list<ParamTask>*);
	void setControlQMut(QMutex* controlMutex);

	list<ParamTask>* getBag();
	QMutex* getControlQMut();

	//QHash<QString,QMutex*> getLockSec();
	//QHash<QString,bool> getLockSecUse();
	//QMutex controlAcess();

public:
	//contrutor HPA, é preciso passar como parâmetro o modelo instrumentado com as diretivas
	//metodo apenas para ref no lua
	
	// HPA(string pathModel); // Tiago -- comentei pq nao estva em uso
	HPA(string pathModel, lua_State *);
	int execute();

	//--------------------------implementação das diretivas--------------------------
	//Executa o Join em todas as funções que estão executando até o ponto de chamada
    HPA(lua_State *L);
	

    int joinall(lua_State*);
    //Executa o Join na/nas funções name_func que esta/estão executando
    int join(lua_State*);
    //Corresponde a adicionar mais uma tarefa ao Bag of Task's para ser resolvida
    int parallel(lua_State*);
	//metodos para controlar acesso synchronized as variaveis globais
	int acquire(lua_State *now);
	int release(lua_State *now);
	int np(lua_State *now);


	int HPATests(lua_State * now);

	~HPA(); //Tiago -- necessario para resolver leaks de memoria gerado pelo Saulo
};

#endif