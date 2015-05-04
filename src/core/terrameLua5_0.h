/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.
*************************************************************************************/
#include "environment.h"
#include "agent.h"
#include "cellularSpace.h"
#include "scheduler.h"
#include "region.h"
#include "imageCompare.h"

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include "luna.h"


lua_State * L;
class luaCell;
void getReference(lua_State *L, luaCell *cell);
class luaCell;
class luaCellularSpace;
luaCell * findCell(luaCellularSpace*, CellIndex&);

//****************************** SPACE **********************************************//
///////////////////////////////////////////////////////////////////////////////////////
class luaCellIndex 
{
    int ref;
public:
    int x, y;
    luaCellIndex(lua_State *L) {
        x = y = 0;
        if(lua_istable(L, -1))
        {
            lua_pushstring(L, "x"); lua_gettable(L, -2); x = (int) luaL_checknumber(L, -1); lua_pop(L, 1);
            lua_pushstring(L, "y"); lua_gettable(L, -2); y = (int) luaL_checknumber(L, -1); lua_pop(L, 1);
        }
    }
    int set(lua_State *L) { x = (int)luaL_checknumber(L, -2);  y = (int) luaL_checknumber(L, -1); return 0;}
    int get(lua_State *L) { lua_pushnumber(L, x); lua_pushnumber(L, y); return 2;}

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

    static const char className[];
    static Luna<luaCellIndex>::RegType methods[];
}; 

///////////////////////////////////////////////////////////////////////////////////////
class luaCell;
class luaCellularSpace;
class luaNeighborhood : public CellNeighborhood
{
    CellNeighborhood::iterator it;
public:
    luaNeighborhood(lua_State *L) {

        it = CellNeighborhood::begin();

        int count = 0;
        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            lua_pop(L, 1);
            count++;
        }
        if(count) // if the table received as parameter is not empty
        {
            lua_pushstring(L, "cells");
            lua_gettable(L, -2);
            luaNeighborhood* neigh = (luaNeighborhood*) lua_touserdata(L, -1);
            *this = *neigh;
            //this->CellNeighborhood::pImpl_= neigh->CellNeighborhood::pImpl_;
        }
    }

    // parameters: cell index,  cell, weight
    // return luaCell
    int addCell(lua_State *L) {
        double weight = luaL_checknumber(L, -1);
        luaCellularSpace *cs = Luna<luaCellularSpace>::check(L, -2);
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -3);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        luaCell *cell = ::findCell(cs, cellIndex);
        if(cell != NULL) {
            CellNeighborhood::add(cellIndex, (Cell*)cell, weight);
            ::getReference(L, cell);
        }
        else lua_pushnil(L);
        return 1;
    }

    // parameters: cell index
    int eraseCell(lua_State *L) {
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        CellNeighborhood::erase(cellIndex);
        return 0;
    }
    // parameters: cell index,
    // return weight
    int getCellWeight(lua_State *L) {
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        lua_pushnumber(L, CellNeighborhood::getWeight(cellIndex));
        return 1;
    }

    // parameters: cell index,
    // return luaCell
    int getCellNeighbor(lua_State *L) {
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        luaCell *cell = (luaCell*)(*CellNeighborhood::pImpl_)[ cellIndex ];
        if(cell) ::getReference(L, cell);
        else lua_pushnil(L);
        return 1;
    }

    // no parameters
    int getWeight(lua_State *L)
    {
        double weight = 0;
        CellIndex cellIndex;
        if(it != CellNeighborhood::end()){
            cellIndex = it->first;
            weight = CellNeighborhood::getWeight(cellIndex);
        }
        lua_pushnumber(L, weight);
        return 1;
    }

    // no parameters
    int getNeighbor(lua_State *L)
    {
        CellIndex cellIndex;
        if(it != CellNeighborhood::end()){
            cellIndex = it->first;
            luaCell *cell = (luaCell*) it->second;
            ::getReference(L, cell);
            return 1;
        }
        lua_pushnil(L);
        return 1;
    }

    // parameters: cell index, weight
    int setCellWeight(lua_State *L) {
        double weight = luaL_checknumber(L, -1);
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -2);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        CellNeighborhood::setWeight(cellIndex, weight);
        return 0;
    }

    // parameters: weight
    int setWeight(lua_State *L) {
        double weight = luaL_checknumber(L, -1);
        CellIndex cellIndex;
        if(it != CellNeighborhood::end()){
            cellIndex = it->first;
            CellNeighborhood::setWeight(cellIndex, weight);
        }
        return 0;
    }

    // no parameters
    int first(lua_State *L)
    {
        it = CellNeighborhood::begin();
        return 0;
    }

    // no parameters, if at end of the neighborhood return TRUE, else return FALSE
    int  last(lua_State *L)
    {
        lua_pushboolean(L, it == CellNeighborhood::end());
        return  1;
    }

    // no parameters
    int next(lua_State *L)
    {
        if(it != CellNeighborhood::end()) it++;
        return 0;
    }

    // no parameters, return current neighbor coords
    int getCoord(lua_State *L)
    {
        int x = 0, y = 0;
        if (it != CellNeighborhood::end())
        {
            x = it->first.first;
            y = it->first.second;
        }
        lua_pushnumber(L, y);
        lua_pushnumber(L, x);
        return 2;
    }

    // parameters: void
    int isEmpty(lua_State *L) {
        lua_pushboolean(L, CellNeighborhood::empty());
        return 1;
    }
    int clear(lua_State *L) {
        CellNeighborhood::clear();
        return 0;
    }
    int size(lua_State *L) {
        lua_pushnumber(L, CellNeighborhood::size());
        return 1;
    }

    static const char className[];
    static Luna<luaNeighborhood>::RegType methods[];

    //void cellNeigh2luaNeigh(CellNeighborhood& neigh)
    //{
    //  CellNeighborhood::clear();
    //  CellNeighborhood::iterator it = neigh.begin();
    //  while(it != neigh.end())
    //  {
    //	  CellIndex cI = (*it).first;
    //	  Cell* cell = (*it).second;
    //	  double weight = neigh.getWeight(cI);
    //	  CellNeighborhood::add(cI, cell, weight);
    //	  it++;
    //  }
    //}

};
//////////////////////////////////////////////////////////////////////////////////////
class luaCell : public Cell
{
    int ref;
public:
    // Lua interface
    luaCell(lua_State *L) { }
    ~luaCell(void) { luaL_unref(L, LUA_REGISTRYINDEX, ref); }

    int setLatency(lua_State *L) { Cell::setLatency(luaL_checknumber(L, 1)); return 0; }
    int getLatency(lua_State *L) { lua_pushnumber(L, Cell::getLatency()); return 1; }
    int setNeighborhood(lua_State *L) {
        luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
        return 0;
    }
    int getNeighborhood(lua_State *L) {

        NeighCmpstInterf& neighs = Cell::getNeighborhoods();

        // Get and test parameters
        int index = luaL_checknumber(L, -1);
        if(index < 0 || index >= neighs.size()) lua_pushnil(L); // return nil
        else
        {
            // Get the cell	neighborhood
            luaNeighborhood& neighRef = (luaNeighborhood&) neighs[index];
            luaNeighborhood* neigh = &neighRef;

            // Put the Neighborhood on the stack top
            lua_getglobal(L, "Neighborhood");
            if(!lua_isfunction(L, -1))
            {
                cout << "Error: Event constructor not found!"  << endl;
                return 0;
            };

            // puts the neighborhood on the stack top
            lua_newtable(L);
            lua_pushstring(L, "cells");
            //typedef struct { luaNeighborhood *n; } userDataType;
            //userDataType *ud = static_cast<userDataType*>(lua_newuserdata(L, sizeof(userDataType)));
            //ud->n = neigh;
            //luaL_getmetatable(L, luaNeighborhood::className);  // lookup metatable in Lua registry
            //lua_setmetatable(L, -2);
            lua_pushlightuserdata(L, (void*) neigh);
            lua_settable(L, -3);


            // calls the Neighborhood constructor
            if(lua_pcall(L, 1, 1, 0) != 0)
            {
                cout << " Error: Neighborhood constructor not found in the stack" << endl;
                return 0;
            }
            // Return cell
            //typedef struct { luaNeighborhood *n; } userDataType;
            //userDataType *ud = static_cast<userDataType*>(lua_newuserdata(L, sizeof(userDataType)));
            //ud->n = neigh;
            //luaL_getmetatable(L, luaNeighborhood::className);  // lookup metatable in Lua registry
            //lua_setmetatable(L, -2);
        }

        return 1;
    }

    int addNeighborhood(lua_State *L)
    {
        luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
        NeighCmpstInterf& neighs = Cell::getNeighborhoods();
        neighs.add((CellNeighborhood&)*neigh);
        return 0;
    }

    int synchronize(lua_State *L) {
        Cell::synchronize(sizeof(luaCell)); 
        return 0;
    }

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

    static const char className[];
    static Luna<luaCell>::RegType methods[];

};

void getReference(lua_State *L, luaCell *cell)
{
    cell->getReference(L);
}

//////////////////////////////////////////////////////////////////////////////////////
class luaCellularSpace : public CellularSpace
{
    string dbType;
    string host;
    string dbName;
    string user;
    string pass;
    string inputLayerName;
    string inputThemeName;
    vector<string> attrNames;
    string whereClause;

    int ref;
public:
    // Lua interface
    luaCellularSpace(lua_State *L)
    {
        dbType = "mysql";
        host = "localhost";
        dbName = "";
        user = "";
        pass = "";
        inputLayerName = "";
        inputThemeName = "";
    }

    int setDBType(lua_State *L)   { 	dbType =  string(lua_tostring(L, -1)); return 0; }
    int setHostName(lua_State *L) { 	host =  string(lua_tostring(L, -1));  return 0; }
    int setDBName(lua_State *L)   { 	dbName =  string(lua_tostring(L, -1)); return 0; }
    int setUser(lua_State *L)     { 	user =  string(lua_tostring(L, -1)); return 0; }
    int setPassword(lua_State *L) { 	pass =  string(lua_tostring(L, -1)); return 0; }
    int setLayer(lua_State *L)    { 	inputLayerName =  string(lua_tostring(L, -1)); return 0; }
    int setTheme(lua_State *L)	 { 	inputThemeName  =  string(lua_tostring(L, -1)); return 0; }
    int clearAttrName(lua_State *L) { attrNames.clear(); return 0; }
    int addAttrName(lua_State *L)  {  attrNames.push_back(lua_tostring(L, -1)); return 0; }
    int setWhereClause(lua_State *L) { whereClause =  string(lua_tostring(L, -1)); return 0; }
    int load(lua_State *L);
    int save(lua_State *L);
    int clear(lua_State *L)		 { CellularSpace::clear(); return 0; }
    int loadNeighborhood(lua_State *L);
    int addCell(lua_State *L)
    {
        CellIndex indx;
        luaCell *cell = Luna<luaCell>::check(L, -1);
        indx.second = luaL_checknumber(L, -2);
        indx.first = luaL_checknumber(L, -3);
        CellularSpace::add(indx, cell);

        return 0;
    }
    // parameters: cell index
    int getCell(lua_State *L) {
        luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
        CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
        luaCell *cell = ::findCell(this, cellIndex);
        if(cell != NULL) ::getReference(L, cell);
        else lua_pushnil(L);
        return 1;
    }
    int size(lua_State* L)
    {
        lua_pushnumber(L, CellularSpace::size());
        return 1;
    }
    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

    static const char className[];
    static Luna<luaCellularSpace>::RegType methods[];

};

luaCell * findCell(luaCellularSpace* cs, CellIndex& cellIndex)
{
    Region<CellIndex>::iterator it = cs->find(cellIndex);
    if(it != cs->end()) return (luaCell*)it->second;
    return (luaCell*)0;
}


//****************************** TIMER **********************************************//
class luaEvent : public Event
{
    int ref;
public:
    luaEvent(lua_State *L) {};
    ~luaEvent(void) { luaL_unref(L, LUA_REGISTRYINDEX, ref); }

    luaEvent(Event &event) { Event::config(event.getTime(), event.getFrequency()); }

    int config(lua_State *L) {
        double time = luaL_checknumber(L, -2);
        double period = luaL_checknumber(L, -1);
        Event::config(time, period);
        return 0;
    }

    int getTime(lua_State *L) {
        double time = Event::getTime();
        lua_pushnumber(L, time);
        return 1;
    }

    int getPriority(lua_State *L) {
        int priority = Event::getPriority();
        lua_pushnumber(L, priority);
        return 1;
    }

    int setPriority(lua_State *L) {
        int priority= luaL_checknumber(L, -1);
        Event::setPriority(priority);
        return 0;
    }

    int getPeriod(lua_State *L) {
        double time = Event::getFrequency();
        lua_pushnumber(L, time);
        return 1;
    }

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

    static const char className[];
    static Luna<luaEvent>::RegType methods[];

};
//////////////////////
class luaMessage : public Message
{
    int ref;
    string msg;
public:
    luaMessage(lua_State *L) {};
    ~luaMessage(void) { luaL_unref(L, LUA_REGISTRYINDEX, ref); }

    int config(lua_State *L) {
        msg = lua_tostring(L, -1);
        return 0;
    }

    bool execute(Event& event) {

        // puts the message table on the top of the lua stack
        getReference(L);
        if(!lua_istable(L, -1))
        {
            cout << "Error: message " << msg << " not defined!"  << endl;
            return 0;
        };

        // puts the function 'execute' on the top of the stack
        //--lua_pushstring(L, "execute");
        lua_pushnumber(L, 1);
        lua_gettable(L, -2);

        // puts the event parameter on stack top
        //luaEvent *ev = (luaEvent*)&event;
        //ev->getReference(L);

        // puts the Event constructor on the top of the lua stack
        lua_getglobal(L, "Event");
        if(!lua_isfunction(L, -1))
        {
            cout << "Error: Event constructor not found!"  << endl;
            return 0;
        };

        // builds the table parameter of the constructor
        lua_newtable(L);
        lua_pushstring(L, "time");
        lua_pushnumber(L, event.getTime());
        lua_settable(L, -3);
        lua_pushstring(L, "period");
        lua_pushnumber(L, event.getFrequency());
        lua_settable(L, -3);

        // calls the event constructor
        if(lua_pcall(L, 1, 1, 0) != 0)
        {
            cout << " Error: Event constructor not found in the stack" << endl;
            return 0;
        }

        // calls the function 'execute'
        if(lua_pcall(L, 1, 1, 0) != 0)
        {
            cout << " Error: message function not found in the stack: " << lua_tostring(L, -1) << endl;
            return 0;
        }

        // retrieve the message result value from the lua stack
        int result = 0;
        if(lua_type(L, -1) == LUA_TBOOLEAN)
        {
            result = lua_toboolean(L, -1);
            lua_pop(L, 1);  // pop returned value
        }
        else
        {
            cout << " Error: message must return \"true\" or \"false\"" << endl;
            return 0;
        }

        return result;
    }

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }
    static const char className[];
    static Luna<luaMessage>::RegType methods[];

};
//////////////////////
class luaTimer : public Scheduler
{
public:
    // Lua interface
    luaTimer(lua_State *L) {  }
    int getTime(lua_State *L) { lua_pushnumber(L, Scheduler::getTime()); return 1; }
    int isEmpty(lua_State *L) { lua_pushnumber(L, Scheduler::empty()); return 1; }
    //  int execute(lua_State *L) { Scheduler::execute(); return 0; }
    int add(lua_State *L) {
        luaEvent* event = Luna<luaEvent>::check(L, -2);
        luaMessage* message = Luna<luaMessage>::check(L, -1);

        Scheduler::add(*event, message);
        return 0;
    }
    int reset(lua_State* L) { Scheduler::reset(); return 0; }

    static const char className[];
    static Luna<luaTimer>::RegType methods[];

};
//****************************** BEHAVIOR *******************************************//
///////////////////////////////////////////////////////////////////////////////////////
class luaAgent
{
    int ref;
public:
    //luAgent(lua_State* L){ }
    ~luaAgent(void) { luaL_unref(L, LUA_REGISTRYINDEX, ref); }

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

};
///////////////////////////////////////////////////////////////////////////////////////
class luaControlMode;
class luaGlobalAgent : public GlobalAgent, public luaAgent
{
public:
    // Lua interface
    luaGlobalAgent(lua_State *L) { }

    int getLatency(lua_State *L)
    {
        float time = GlobalAgent::getLastChangeTime();
        lua_pushnumber(L, time);
        return 1;
    }

    int add(lua_State *L) {
        void *ud;
        if((ud = luaL_checkudata(L, -1, "TeState")) != NULL)
        {
            ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
            ControlMode &cm = *lcm;
            GlobalAgent::add(cm);
        }
        else
        {
            try
            {
                // add a spatial iterator that must be at the stack top
                Region<CellIndex> actRegion;
                CellIndex indx;
                indx.first = 1; indx.second = 0;
                actRegion.clear();
                lua_pushnil(L);
                while(lua_next(L, -2) != 0)
                {
                    lua_pushstring(L, "cObj_");
                    lua_gettable(L, -2);
                    luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
                    actRegion.add(indx, cell);
                    indx.first++;
                    lua_pop(L, 2);
                }
                ActionRegionCompositeInterf& actRegions = luaGlobalAgent::getActionRegions();
                actRegions.add(actRegion);
            }
            catch(...){ cout << "Warning: ivalid spatial iterator!" << endl; return 0; }
        }
        return 0;
    }

    int setActionRegionStatus(lua_State* L)
    {
        bool status = lua_toboolean(L, -1);
        GlobalAgent::setActionRegionStatus(status);
        return 0;
    }

    int execute(lua_State* L){
        luaEvent* ev = Luna<luaEvent>::check(L, -1);
        GlobalAgent::execute(*ev);
        return 0;
    }

    int build(lua_State* L){
        if(! Agent::build())
        {
            cout << "Error: a control mode must be added to the agent before use it as a jump condition target...";
        }

        return 0;
    }

    int getControlModeName(lua_State* L){
        lua_pushstring(L, GlobalAgent::getControlModeName().c_str());
        return 1;
    }
    static const char className[];
    static Luna<luaGlobalAgent>::RegType methods[];

};
///////////////////////////////////////////////////////////////////////////////////////
class luaLocalAgent : public LocalAgent, public luaAgent
{
public:
    // Lua interface
    luaLocalAgent(lua_State *L) { }

    int getLatency(lua_State *L)
    {
        float time = LocalAgent::getLastChangeTime();
        lua_pushnumber(L, time);
        return 1;
    }

    int add(lua_State *L) {
        void *ud;
        if((ud = luaL_checkudata(L, -1, "TeState")) != NULL)
        {
            //cout << "aqui" << endl;
            ControlMode* lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
            ControlMode &cm = *lcm;
            LocalAgent::add(cm);

        }
        else
        {
            try
            {
                // add a spatial iterator that must be at the stack top
                Region<CellIndex> actRegion;
                CellIndex indx;
                indx.first = 1; indx.second = 0;
                actRegion.clear();
                lua_pushnil(L);
                while(lua_next(L, -2) != 0)
                {
                    lua_pushstring(L, "cObj_");
                    lua_gettable(L, -2);
                    luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
                    actRegion.add(indx, cell);
                    indx.first++;
                    lua_pop(L, 2);
                }
                ActionRegionCompositeInterf& actRegions = luaLocalAgent::getActionRegions();
                actRegions.add(actRegion);
            }
            catch(...){ cout << "Warning: ivalid spatial iterator!" << endl; return 0; }
        }
        return 0;
    }

    int execute(lua_State* L){
        luaEvent* ev = Luna<luaEvent>::check(L, -1);
        LocalAgent::execute(*ev);
        return 0;
    }

    int setActionRegionStatus(lua_State* L)
    {
        bool status = lua_toboolean(L, -1);
        LocalAgent::setActionRegionStatus(status);
        return 0;
    }

    int build(lua_State* L){
        if(! Agent::build())
        {
            cout << "Error: you must add a control mode to the agent before use it as a jump condition targert...";
            return 0;
        }
        return 0;
    }

    static const char className[];
    static Luna<luaLocalAgent>::RegType methods[];

};
///////////////////////////////////////////////////////////////////////////////////////
class luaRule 
{
protected:
    int ref;
public:

    ~luaRule(void) { luaL_unref(L, LUA_REGISTRYINDEX, ref); }

    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

};
///////////////////////////////////////////////////////////////////////////////////////
class luaJumpCondition : public JumpCondition, public luaRule
{
public:
    luaJumpCondition(lua_State* L) { }

    int setTargetControlModeName(lua_State* L){

        const char* ctrlName = luaL_checkstring(L , -1);
        JumpCondition::setTargetControlModeName(string(ctrlName));
        return 0;
    }

    bool execute (Event &event, Agent *agent, pair<CellIndex, Cell*> &cellIndexPair)
    {
        try {

            bool isGlobalAgent = false;
            luaGlobalAgent *agG;
            luaLocalAgent *agL;
            int result = 0;
            luaEvent *ev = (luaEvent*)&event;
            luaCell  *cell = (luaCell*) cellIndexPair.second;

            //puts the execute function of the rule on stack top
            luaRule::getReference(L);
            //lua_pushstring(L, "execute");
            lua_pushnumber(L, 1);
            lua_gettable(L, -2);

            // puts the rule parameters on stack top
            ev->getReference(L);
            if(dynamic_cast<luaGlobalAgent*>(agent))
            {
                isGlobalAgent = true;
                luaGlobalAgent* ag = (luaGlobalAgent*) agent;
                ag->getReference(L);
                if(cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
                agG = ag;
            }
            else
            {
                luaLocalAgent* ag = (luaLocalAgent*) agent;
                ag->getReference(L);
                if(cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
                agL = ag;
            }


            // calls the "execute" function of the rule
            if(lua_pcall(L, 3, 1, 0) != 0)
            {
                cout << " Error: rule can not be executed: " << lua_tostring(L, -1) << endl;
                return 0;
            }

            result = lua_toboolean(L, -1);
            lua_pop(L, 1);  // pop returned value

            if(result){
                if(isGlobalAgent) { ::jump(event, agG, JumpCondition::getTarget());	}
                else { JumpCondition::jump(agL, cell); }
            }

            return result;
        }
        catch(...)
        {
            return false;
        }

    }

    static const char className[];
    static Luna<luaJumpCondition>::RegType methods[];

};
///////////////////////////////////////////////////////////////////////////////////////
class luaFlowCondition : public FlowCondition, public luaRule
{
public:

    luaFlowCondition(lua_State* L) { }

    bool execute (Event &event, Agent *agent, pair<CellIndex, Cell*> &cellIndexPair)
    {
        try {

            int result = 0;
            luaEvent *ev = (luaEvent*)&event;
            luaCell  *cell = (luaCell*) cellIndexPair.second;

            //puts the execute function of the rule on stack top
            luaRule::getReference(L);
            //lua_pushstring(L, "execute");
            lua_pushnumber(L, 1);
            lua_gettable(L, -2);

            // puts the rule parameters on stack top
            ev->getReference(L);
            if(dynamic_cast<luaGlobalAgent*>(agent))
            {
                luaGlobalAgent* ag = (luaGlobalAgent*) agent;
                ag->getReference(L);
                if(cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
            }
            else
            {
                luaLocalAgent* ag = (luaLocalAgent*) agent;
                ag->getReference(L);
                if(cell != NULL) cell->getReference(L);
                else lua_pushnil(L);
            }

            // calls the "execute" function of the rule
            if(lua_pcall(L, 3, 1, 0) != 0)
            {
                cout << " Error: rule can not be executed: " << lua_tostring(L, -1) << endl;
                return 0;
            }

            result = lua_tonumber(L, -1);
            lua_pop(L, 1);  // pop returned value

            return result;
        }
        catch(...)
        {
            return false;
        }

    }

    static const char className[];
    static Luna<luaFlowCondition>::RegType methods[];

};
///////////////////////////////////////////////////////////////////////////////////////
class luaControlMode : public ControlMode
{
    Process uniqueProcess;
public:

    luaControlMode(lua_State* L) {
        ControlMode::add(uniqueProcess);
    }

    int config(lua_State*L)
    {
        const char *name = luaL_checkstring(L, -1);
        string tempStr = name; // Raian: ControlMode::setControlModeName(string(name));
        ControlMode::setControlModeName(tempStr);
        return 0;
    }

    int add(lua_State* L)
    {

        void *ud;

        if((ud = luaL_checkudata(L, -1, "TeJump")) != NULL)
        {
            luaJumpCondition* const jump = Luna<luaJumpCondition>::check(L, -1);
            uniqueProcess.JumpCompositeInterf::add(jump);
        }
        else
            if((ud = luaL_checkudata(L, -1, "TeFlow")) != NULL)
            {
                luaFlowCondition* const flow = Luna<luaFlowCondition>::check(L, -1);
                uniqueProcess.FlowCompositeInterf::add(flow);
            }
        return 0;
    }

    int addJump(lua_State* L)
    {
        luaJumpCondition* const jump = Luna<luaJumpCondition>::check(L, -1);
        uniqueProcess.JumpCompositeInterf::add(jump);
        return 0;
    }


    int addFlow(lua_State* L)
    {
        luaFlowCondition* const flow = Luna<luaFlowCondition>::check(L, -1);
        uniqueProcess.FlowCompositeInterf::add(flow);
        return 0;
    }

    int getName(lua_State* L)
    {
        lua_pushstring(L, ControlMode::getControlModeName().c_str());
        return 1;
    }

    static const char className[];
    static Luna<luaControlMode>::RegType methods[];

};

//****************************** ENVIRONMENT ****************************************//
///////////////////////////////////////////////////////////////////////////////////////
class luaEnvironment : public Environment
{
	string id;
public:
    // Lua interface
    luaEnvironment(lua_State *L) {
        id = lua_tostring(L, -1);
        Environment::envId = id;
        cout << "Scale: "<< id << endl;
    }

    int add(lua_State *L) {
        void *ud;
        if((ud = luaL_checkudata(L, -1, "TeTimer")) != NULL)
        {
            pair<float, Scheduler>  timeSchedulerPair;
            Scheduler* pTimer = Luna<luaTimer>::check(L, -1);

            timeSchedulerPair.first = pTimer->getTime();
            timeSchedulerPair.second = *pTimer;

            Environment::add(timeSchedulerPair);
        }
        else
            if((ud = luaL_checkudata(L, -1, "TeCellularSpace")) != NULL)
            {
                CellularSpace* pCS = Luna<luaCellularSpace>::check(L, -1);
                Environment::add(*pCS);
            }
            else
                if((ud = luaL_checkudata(L, -1, "TeLocalAutomaton")) != NULL)
                {

                    LocalAgent* pAg = Luna<luaLocalAgent>::check(L, -1);
                    Environment::add(*pAg);
                }
                else
                    if((ud = luaL_checkudata(L, -1, "TeGlobalAutomaton")) != NULL)
                    {
                        GlobalAgent* pAg = Luna<luaGlobalAgent>::check(L, -1);
                        Environment::add(*pAg);
                    }
                    else
                        if((ud = luaL_checkudata(L, -1, "TeScale")) != NULL)
                        {
                            pair<float, Environment>  timeEnvPair;
                            Environment* pEnv = Luna<luaEnvironment>::check(L, -1);

                            timeEnvPair.first = pEnv->getTime();
                            timeEnvPair.second = *pEnv;

                            Environment::add(timeEnvPair);
                        }
        return 0;
    }

    int addTimer(lua_State *L) {
        pair<float, Scheduler>  timeSchedulerPair;
        Scheduler* pTimer = Luna<luaTimer>::check(L, -1);

        timeSchedulerPair.first = lua_tonumber(L, -2);
        timeSchedulerPair.second = *pTimer;

        Environment::add(timeSchedulerPair);

        return 0;
    }

    int addCellularSpace(lua_State *L) {
        CellularSpace* pCS = Luna<luaCellularSpace>::check(L, -1);
        Environment::add(*pCS);

        return 0;
    };

    int addLocalAgent(lua_State *L) {
        LocalAgent* pAg = Luna<luaLocalAgent>::check(L, -1);
        Environment::add(*pAg);

        return 0;
    };

    int addGlobalAgent(lua_State *L) {
        GlobalAgent* pAg = Luna<luaGlobalAgent>::check(L, -1);
        Environment::add(*pAg);

        return 0;
    };

    int config(lua_State *L)
    {
        float finalTime = lua_tonumber(L, -1);
        Environment::config(finalTime);

        return 0;
    }

    int execute(lua_State *L)
    {
        Environment::execute();
        return 0;
    }
    /*  // parameters: environment
  int addEnvironment(lua_State *L) {
          luaEnvironment *env = Luna<luaEnvironment>::check(L, -1);
        return 0;
  }

  // parameters: cellular space
  int addCellularSpace(lua_State *L) {
          luaCellularSpace *cellSpace = Luna<luaCellularSpace>::check(L, -1);
          return 0;
  }

  // parameters: agent
  int addAgent(lua_State *L) {
          luaAgent *agent = Luna<luaAgent>::check(L, -1);
          return 0;
  }

  // parameters: timer
  int addTimer(lua_State *L) {
          luaTimer *timer = Luna<luaTimer>::check(L, -1);
          return 0;
  }
  */
    static const char className[];
    static Luna<luaEnvironment>::RegType methods[];

};

