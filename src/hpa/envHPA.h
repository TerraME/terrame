//author: Saulo Henrique Cabral Silva

#ifndef ENV_HPA
#define ENV_HPA

#include <iostream>
#include <vector>
#include <lua.h>
#include "luna.h"

#include <QMutexLocker>

using namespace std;

/////////////////////////////////////////////////////////////////////////VAR's GLOBAIS////////////////////////////////////////////////////

//tenho que ver como tratar isso aqui (primeira solução para o carrinho de rolimã andar... :D)

//modelo do usuário a ser executado luaState
static lua_State *ModeloMain;

//quantidade de núcleos da máquina que esta sendo utilizada
static int numCPU;

static QMutex LOCK_ACESS;

//1p tentativa de controle de variáveis globais
//QHash<QString,lua_State*> Table_VarGlobal;

///////////////////////////////////////////////////////////////////////////TOOLS////////////////////////////////////////////////////////////
//metodo S. Tokenizen para utilizaão no parser
static void S_Tokenize(const string& linha, vector<string>& tokens, const string& delimitadores = " ") {
    string::size_type lastPos = linha.find_first_not_of(delimitadores, 0);
    string::size_type pos = linha.find_first_of(delimitadores, lastPos);

	//tentar otimizar aqui
    while (string::npos != pos || string::npos != lastPos) {
        tokens.push_back(linha.substr(lastPos, pos - lastPos));
        lastPos = linha.find_first_not_of(delimitadores, pos);
        pos = linha.find_first_of(delimitadores, lastPos);
    }
}

#define LOAD_BUF_SIZE (10 * 1024)
struct load_buf
{
	unsigned char* cur;
	unsigned char* buf;
};

static int writer(lua_State* L, const void* b, long size, void* B)
{
	load_buf* buf = (load_buf*)B;
	//assert(LOAD_BUF_SIZE - (buf->cur - buf->buf) >= size);
	memcpy(buf->cur, b, size);
	buf->cur += size;
	return 1;
}

static const char* reader(lua_State* L, void* ud, size_t* size)
{
	load_buf* buf = (load_buf*)ud;
	*size = buf->cur - buf->buf;
	return (const char*)buf->buf;
}

//geral exceto para table
static int HPAxcopy_aux(lua_State *Principal, lua_State *To_Stack, int idx)
{
	switch (lua_type(Principal,idx))
	{
		case LUA_TNIL:
			lua_pushnil(To_Stack);
			break;
		case LUA_TBOOLEAN:
			lua_pushboolean(To_Stack,lua_toboolean(Principal,idx));
			break;
		case LUA_TNUMBER:
			lua_pushnumber(To_Stack,lua_tonumber(Principal,idx));
			break;
		case LUA_TSTRING:
			lua_pushlstring(To_Stack,lua_tostring(Principal,idx),lua_rawlen(Principal,idx));
			break;
		case LUA_TLIGHTUSERDATA:
			lua_pushlightuserdata(To_Stack,(void*)lua_touserdata(Principal,idx));
			break;
		default:
			//tem que ver como sao os tipos de Tiago
			break;
	}
	return 1;
}

//troca de paramtros entre pilhas de execução
static int HPAxcopy(lua_State *Principal, lua_State *To_Stack, int idx)
{
	int top;
	lua_newtable(To_Stack);
	top = lua_gettop(To_Stack);
	lua_pushnil(Principal);  

	while (lua_next(Principal, idx) != 0) {
		HPAxcopy_aux(Principal,To_Stack,-2);
		//tabela de tabela de ...
		if (lua_type(Principal,-1) == LUA_TTABLE)
			HPAxcopy(Principal,To_Stack,lua_gettop(Principal));
		else
			HPAxcopy_aux(Principal,To_Stack,-1);

		//if para possivel tratamento
		if(lua_type(To_Stack,top) == LUA_TTABLE)
			lua_settable(To_Stack,top);
		
		lua_pop(Principal,1);
	}
	return 1;
}

static void hpaLoadParams(lua_State *now, vector<string>Par,lua_State *now_par) {

    //para inserir estas variaveis para a funcao que deve ser executada
    string my_var;
    string name_Var;
    bool is_global = false;

	//Espace_MAIN.acquire(1);

    for (int co = 0; co < Par.size(); co++) {

        name_Var = Par[co];
        //apenas para conversao dos contadores de cada novo parametro 
        char aaux[BUFSIZ];
        
		#ifdef WIN32
			//para windows
			itoa((co + 1), aaux, 10);
		#else
			//para linux(falta itoa)
			sprintf (aaux, "%ld", (co + 1));  
		#endif

        string aux = aaux;

        my_var = "__HPA_VAR__" + aux;

		//verifico se a variavel esta na pilha auxiliar de parametros
		lua_getglobal(now_par,name_Var.c_str());
		if(lua_type(now_par,-1)!=0)
			is_global = true;
		
        if (is_global) {
            is_global = false;

            //tentar acessar os valores da variavel na piha principal do lua
            lua_getglobal(now_par, name_Var.c_str());

			if(lua_type(now_par,-1) != LUA_TTABLE)
				HPAxcopy_aux(now_par,now,-1);
			else{
				//todo tipo de tiago tem este identficador
				lua_getglobal(now_par,(name_Var + "_is_ref").c_str());

				//se e tipo de tiago vamso so mover
				if(lua_type(now_par,-1) != 0){
					lua_pop(now_par,1);
					lua_xmove(now_par,now,1);
				}else{
					lua_pop(now_par,1);
					//tenho que verificar se é tipo de tiago se for preciso usar x_move			
					HPAxcopy(now_par,now,-2);
				}
			}

			lua_setglobal(now,my_var.c_str());
			//luaL_loadstring(now,("local " + my_var + " = " + my_var).c_str());
			//string changePrior = "local "+my_var+"="+my_var;
			//luaL_dostring(now,changePrior.c_str());
			//luaL_dostring(now,changePrior.c_str());
//			luaL_ref(now,LUA_REGISTRYINDEX);

        } else {
			//my_var = "local "+my_var + "=";
			my_var = my_var + "=";
            my_var = my_var + name_Var;
            luaL_dostring(now, my_var.c_str());
         }
	}

	//Espace_MAIN.release(1);
}


/////////////////////////////////////////////////////////////////////////ENV/////////////////////////////////////////////////////////////////

//metodos para manipular a quantidade de threads que o hpa ira utilizar para a execução do modelo (será possível alterar utilizando diretiva)
static int getNumCpu(){
	return numCPU;
}

static void setNumCpu(int numCpu_){
	numCPU = numCpu_;
}

//metodos para acesso e manipulação da pilha principal do modelo
static void setMainStack(lua_State* ModeloMain_){
	ModeloMain = ModeloMain_;
}

static lua_State* getMainStack(){
	return ModeloMain;
}

//////////////////////////////////////////////////////////////////////LOCK///////////////////////////////////////////////////////////////////

static QMutex lockAcess;


#endif