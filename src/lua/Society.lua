-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  ABM extension for TerraME
--  Last change: April/2012
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors:
--      Pedro Andrade
--      Rodrigo Reis Pereira

globalSocietyIdCounter = 0

local createSocialNetworkByQuantity = function(soc, quantity, name, randomObj)
	forEachAgent(soc, function(agent)
		quant = 0
		rs = SocialNetwork{id = name}
    local rand = nil
    if type(randomObj) == "Random" then
  		rand = randomObj
    else
      rand = TME_GLOBAL_RANDOM
    end
		while quant < quantity do
      randomagent = soc:sample(rand)
			if randomagent ~= agent and not rs:isConnection(randomagent) then
				rs:add(randomagent, 1)
				quant = quant + 1
			end
		end
		agent:addSocialNetwork(rs, name)
	end)
end

local createSocialNetworkByProbability = function(soc, probability, name, randomObj)
	forEachAgent(soc, function(agent)
		rs = SocialNetwork{
			id = name
		}
    local rand = nil
    if type(randomObj) == "Random" then
  		rand = randomObj
    else
      rand = TME_GLOBAL_RANDOM
    end
		forEachAgent(soc, function(hint)
			if hint ~= agent and rand:number() < probability then
				rs:add(hint,1)
			end
		end)
		agent:addSocialNetwork(rs, name)
	end)
end

local function createSocialNetworkByFunction(society, func, self, name)
	forEachAgent(society, function(agent)
		rs = SocialNetwork{id = name}

		forEachAgent(society, function(hint)
			if func(agent, hint) then
				rs:add(hint, 1)
			end
		end)
		agent:addSocialNetwork(rs, name)
	end)
end

local function createDynamicSocialNetworkByFunction(society, func, name)
	forEachAgent(society, function(agent)
		agent:addSocialNetwork(func, name)
	end)
end

local function createDynamicSocialNetworkByCell(society, self, name)
	if self == nil then self = false end
	if name == nil then name = "sntw1" end
	local runfunction = function(agent)
		local  rs = SocialNetwork{
			id = name
		}
		forEachAgent(agent:getCell("placement"), function(agentwithin)
			if agent ~= agentwithin or self then
				rs:add(agentwithin,1)
			end
		end)
		return rs
	end
	createDynamicSocialNetworkByFunction(society, runfunction, name)
end

local function createDynamicSocialNetworkByNeighbor(society, neighborhoodName, name)
	if name == nil then name = "sntw1" end
	if neighborhoodName == nil then neighborhoodName = "neigh1" end
	local runfunction = function(agent)
		local rs = SocialNetwork{ id = name }
		forEachNeighbor(agent:getCell("placement"),neighborhoodName, function(cell, neigh)
			forEachAgent(neigh, function(agentwithin)
				rs:add(agentwithin,1)
			end)
		end)
		return rs
	end
	createDynamicSocialNetworkByFunction(society, runfunction, name)
end

Society_ = {
	type_ = "Society",
	--- Add a new Agent to the Society.
	-- @param agent The new Agent that will be added to the Society. If nil, the Soceity will add a copy of the instance used to build the Society. In this case, the Society executes the method Agent:init() after creating a copy.
	-- @usage soc:add(agent)
	-- @see Agent:init
	add = function(self, agent)
		if type(agent) ~= "Agent" and type(agent) ~= "table" then
			incompatibleTypesErrorMsg("agent","Agent", type(agent), 3)
		end

		local mtype = type(agent)
		if mtype == "table" then
			agent.xxx = State{id="aa"} -- remove this in the next version
			globalAgentIdCounter = globalAgentIdCounter + 1
			agent.id = "ag".. globalAgentIdCounter
			agent.class = "undefined"
			agent = Agent(agent)            
			local metaTable = {__index = self.instance}
			setmetatable(agent, metaTable)
			agent:init()
		elseif mtype ~= "Agent" then
			customErrorMsg("Error: Invalid type '"..mtype.."'. It should be an Agent or a table.", 3)
		end

		agent.parent = self
		table.insert(self.agents, agent)
		self.autoincrement = self.autoincrement + 1

		if agent.id == nil then agent.id = self.autoincrement end
		forEachElement(self.placements, function(placement, cs)
			if agent[placement] == nil then
				-- if the agent already has this placement then
				-- it does not need to be built again
				agent[placement] = Trajectory{target = cs, build = false, select = function() return true end }
				agent[placement].cells = {}
				if placement == "placement" then
					agent.cells = agent.placement.cells
				end
			end
		end)
		return agent

	end,
	--- Remove all the Agents from the Society.
	-- @usage soc:clear()
	clear = function(self)
		self.agents = {}
		self.autoincrement = 1
	end,
	--- Create a directed SocialNetwork for each Agent of the Society. The following arguments represent the strategies, which must be only one for call:
	-- @param data.strategy A string with the strategy to be used for creating the SocialNetwork. See the table below.
	-- @param data.func A function (Agent, Agent) -> boolean that returns true if the first Agent will have the second Agent in its SocialNetwork. When using this argument, the default value of strategy becomes "func".
	-- @param data.name Name of the relation.
	-- @param data.neighborhood A string with the index of the Neighborhood that will be used to compute the network.
	-- @param data.probability A number between 0 and 1 indicating the probability of each connection. The probability is applied for each pair of Agents. When using this argument, the default value of strategy becomes "probability".
	-- @param data.quantity A number indicating the number of connections each Agent will have, taking randomly from the whole Society. When using this argument, the default value of strategy becomes "quantity".
	-- @param data.self A boolean value indicating whether the Agent can be connected to itself. Default is false.
	-- @tab strategy
	-- Strategy &
	-- Description &
	-- Parameters (bold are compulsory) \
	-- "cell" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the same Cell the Agent belongs. &
	-- name, self \
	-- "func" &
	-- Create a SocialNetwork according to a membership function. &
	-- name, func \
	-- "neighbor" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the neighbor Cells of the one the Agent belongs. &
	-- name, neighborhood \
	-- "probability" &
	-- Applies a probability for each pair of Agents. &
	-- name, self, probability \
	-- "quantity" &
	-- Number of connections randomly taken from the Society. &
	-- name, self, quantity \
	createSocialNetwork = function(self, data, randomObj)
		if type(data) ~= "table" then
		  incompatibleTypesErrorMsg("data", "table", type(data), 3)
		end
		if data.strategy == nil then
			if data.probability ~= nil then
				data.strategy = "probability"
			elseif data.quantity ~= nil then
				data.strategy = "quantity"
			elseif data.func ~= nil then
				data.strategy = "func"
			else
				customErrorMsg("Error: Argument 'strategy' is missing.", 3)
			end
		end

		if type(data.id) ~= "string" then
			if type(data.id) == "nil" then
				globalSocietyIdCounter = globalSocietyIdCounter + 1
				data.id = "sntw".. globalSocietyIdCounter
				defaultValueWarningMsg("id", "string", data.id, 3)
			else
				incompatibleTypesErrorMsg("id", "string", type(data.id), 3)
			end
		end

		if data.self == nil then data.self = false end

		if data.strategy == "probability" then
			if type(data.probability) ~= "number" then
				incompatibleTypesErrorMsg("probability", "a number between 0 and 1", type(data.probability), 3)
			elseif data.probability < 0 or data.probability > 1 then
				incompatibleValuesErrorMsg("probability","a number between 0 and 1",data.probability, 3)
			end
		elseif data.strategy == "quantity" then
			if type(data.quantity) ~= "number" then
				incompatibleTypesErrorMsg("quantity","positive integer number (except zero)", type(data.quantity), 3)
			elseif data.quantity <= 0 then
				incompatibleValuesErrorMsg("quantity", "positive integer number (except zero)", data.quantity, 3)
			elseif math.floor(data.quantity) ~= data.quantity then
				incompatibleValuesErrorMsg("quantity", "positive integer number (except zero)", data.quantity, 3)
			end
		end

		switch(data, "strategy"): caseof {
			["probability"] = function() createSocialNetworkByProbability(self, data.probability, data.id, randomObj) end,
			["quantity"]    = function() createSocialNetworkByQuantity(self, data.quantity, data.id, randomObj) end,
			["func"]        = function() createSocialNetworkByFunction(self, data.func, data.self, data.id) end,
			["cell"]        = function() createDynamicSocialNetworkByCell(self, data.self, data.id) end,
			["neighbor"]    = function() createDynamicSocialNetworkByNeighbor(self, data.neighborhood, data.id) end
		}
	end,
	--- Execute the Society, activating execute() for each of its Agents.
	-- @param event The Event that will be executed.
	-- @usage soc:execute()
	execute = function(self, event)
		forEachAgent(self, function(single)
			if(event == nil)then
				single:execute()
			else
				single:execute(event)
			end
		end)
	end,
	--- Return a given Agent based on its index.
	-- @param index The index of the Agent that will be returned.
	-- @usage agent = soc:getAgent("1")
	getAgent = function(self, index)
		if type(index) ~= "number" then
			incompatibleValuesErrorMsg("index", "positive integer number", type(index), 3)
		elseif index < 0 then
			incompatibleValuesErrorMsg("index", "positive integer number", "negative number", 3)
		elseif math.floor(index) ~= index then
			incompatibleValuesErrorMsg("index", "positive integer number", "float number", 3)
		end
		return self.agents[index]
	end,
	--- Return a vector with the Agents of the Society.
	-- @usage agent = soc:getAgents()[1]
	getAgents = function(self)
		return self.agents
	end,
	--- Notify all the Agents of the Society.
	-- @param modelTime The notification time.
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
			defaultValueWarningMsg("#1", "positive number", modelTime, 3)
    elseif type(modelTime) ~= "number" then
      incompatibleTypesErrorMsg("#1", "positive number", type(modelTime), 3) 
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1","positive number", modelTime, 3)   
		end
		forEachAgent(self, function(agent)
			agent:notify(modelTime)
		end)
		self.cObj_:notify(modelTime)
	end,
	--[[
	self
	arg Agent
	--: * incompatible types. Parameter 'arg' expected Agent, got {type(arg)}.
	: string incompatible types. Parameter 'arg' expected Agent, got string.
	: nil
	--]]

	--- Remove a given Agent from the Society. It returns whether the agent was sucessfully removed.
	-- @param arg The Agent that will be removed.
	remove = function(self, arg)
		if type(arg) == "Agent" then
			-- remove agent from agents's table
			for k, v in pairs(self.agents) do
				if v.id == arg.id and v == arg then
					table.remove(self.agents, k)

					-- Kills the agent arg in the observer identified by observerId
					return arg.cObj_:kill(self.observerId)
				end
			end
			return false
		else
			-- It uses the function func
			local ret = false
			for i = #self.agents, 1, -1  do
				if (arg(self.agents[i])) then
					ret = self:remove(self.agents[i])
					if (ret == false) then
						return false
					end
				end
			end
			return ret
		end
	end,
	--- Return a random Agent from the Society.
	-- @param randomObj A random object.
	-- @usage agent = soc:sample()
	sample = function(self,randomObj)
		if #self.agents > 0 then
			if type(randomObj) == "Random" then
				return self.agents[randomObj:integer(1, #self.agents)]
			else
				return self.agents[TME_GLOBAL_RANDOM:integer(1, #self.agents)]
			end
		else
			return nil
		end
	end,
	--- Return the number of Agents of the Society.
	-- @usage print(soc:size())
	size = function(self)
		return #self.agents
	end,
	--- Split the Society into a set of Groups according to a classification strategy. The 
	-- generated Groups have empty intersection and union equals to the whole 
	-- CellularSpace (unless function below returns nil for some Agent). It works according 
	-- to the type of its only and compulsory argument, that can be:
	-- @param argument string or function
	--
	-- @tab argument
	-- Type of argument &
	-- Description \
	-- string &
	-- The argument must represent the name of one attribute of the Agents of the Society. Split then creates one Group for each possible value of the attribute using the value as index and fills them with the Agents that have the respective attribute value. \
	-- function &
	-- The argument is a function that receives an Agent as argument and returns a value with the index that contains the Agent. Groups are then indexed according to the returning value. \
	--
	-- @usage gs = soc:split("sex")
	-- print(gs.male:size())
	-- print(gs.female:size())
	-- 
	-- gs2 = soc:split(function(ag)
	--     if ag.age > 60 then 
	--         return "old" 
	--     else 
	--         return "notold" 
	--     end
	-- end)
	-- print(ts.old:size())
	split = function(self, argument)
		if type(argument) == "string" then
			local value = argument
			argument = function(agent)
				if agent[value] then return agent[value] end
				return nil
			end
		end

		if type(argument) ~= "function" then
			incompatibleTypesErrorMsg("argument", "string or function", type(argument), 3)
		end

		local result = {}
		local class_
		local i = 1
    
		forEachAgent(self, function(agent)
			class_ = argument(agent)

			if result[class_] == nil then
				globalGroupIdCounter = globalGroupIdCounter + 1
				result[class_] = Group {
					id = "grp"..globalGroupIdCounter,
					target = self,
					build = false,
					select = function() return true end,
          greater = function (ag1, ag2) return ag1.id > ag2.id end
				}
			end
			table.insert(result[class_].agents, agent)
			i = i + 1
		end)
		return result
	end,
	--- Activate each asynchronous message sent by Agents belonging to the Society.
	-- @param delay A number indicating the current delay to be delivered. Messages with delay less 
	-- or equal this value are sent, while the others have their delays reduced by this value.
	-- Default is one.
	-- @usage soc:synchronize()
	-- soc:synchronize(2)
	synchronize = function(self, delay)
		if type(delay) ~= "number"then
			if type(delay) == "nil" then
				delay = 1
			else
				incompatibleTypesErrorMsg("delay", "positive number", type(delay), 3)
			end
		elseif delay <= 0 then
			incompatibleValuesErrorMsg("delay", "positive number", delay, 3)
		end

		local k = 1
		for i = 1, getn(self.messages) do
			local kmessage = self.messages[k]
			kmessage.delay = kmessage.delay - delay

			if kmessage.delay <= 0 then
				kmessage.delay = true
				if kmessage.subject then
					kmessage.receiver["on_"..kmessage.subject](kmessage.receiver, kmessage)
				else
					kmessage.receiver:on_message(kmessage)
				end
				table.remove(self.messages, k)
			else
				k = k + 1
			end
		end
	end
}

metaTableSociety_ = {__index = Society_}
--- Type to create and manipulate a set of Agents. Each Agent within a Society has a 
-- unique id, which is initialized while creating the Society. There are three ways to 
-- create a Society: the first one uses a "quantity" to indicate the number of copies of the 
-- instance to be created. The second uses "data" with positions representing basic 
-- attributes of each Agent to be created. The last one uses a "layer" from a database to 
-- load attributes to the Agents. Calling forEachAgent() traverses Societies.
--
-- @param data.database Name of the database.
-- @param data.dbType Name of DBMS. The default value depends on the database name. If it has a ".mdb" extension, the default value is "ado", otherwise it is "mysql"). TerraME always converts this string to lower case.
-- @param data.file A filename (.csv) where the Society is stored.
-- @param data.host Host where the database is stored (default is "localhost").
-- @param data.id The unique identifier attribute used when reading the Society from a file.
-- @param data.instance A table with the description of the attributes and functions of an Agent. Some functions that may have internal TerraME use are:
-- @param data.layer Name of the layer the theme was created from. It must be used to solve a conflict when there are two themes with the same name (default is "").
-- @param data.password The password (default is "").
-- @param data.port Port number of the connection.
-- @param data.quantity Number of Agents to be created. It is used when the Society will not be loaded from a file or database.
-- @param data.select A table containing the names of the attributes to be retrieved (default is all attributes). When retrieving a single attribute, you can use select = "attribute" instead of select = {"attribute"}. It is possible to rename the attribute name using "as", for example, select = {"lc as landcover"} reads lc from the database but replaces the name to landcover in the Cells.
-- @param data.theme Name of the theme to be loaded.
-- @param data.user Username (default is "").
-- @param data.where A SQL restriction on the properties of the Agents (default is "", applying no restriction. Only the Agents that reflect the established criteria will be loaded). This argument ignores the "as" flexibility of select. 
--
-- @output agents A vector of Agents pointed by the Society.
-- @output instance A function used to build the Agent.
-- @output counter unique identifier used to represent the last Agent added to the Society. The next Agent will have 'counter+1' as id.
-- @output lastSynchronize the last time synchronize() was activated. It has zero as initial value.
-- @output messages a vector that contains the delayed messages.
-- @output parent The Environment it belongs.
--
-- @tab instance
-- Function & Description \
-- execute(self) & a function with the behavior of the Agent when activated. \
-- init(self) & a function called at the end of the instantiation process. \
-- on_*(self, message) & a function called when the Agent receives a message. See Agent:message() for more details. \
--
-- @usage my_instance = Agent {
--     -- ...
-- }
-- 
-- s = Society {
--     instance = my_instance,
--     quantity = 20
-- }
-- 
-- s = Society {
--     instance = my_instance,
--     database = "c:\\datab.mdb",
--     layer = "farmers"
-- }
-- 
-- mydata = readCSV(...)
-- 
-- s = Society {
--     instance = my_instance,
--     data = mydata
-- }
-- @see Utils:forEachAgent
function Society(data)
	if data == nil then
    data = {}
    defaultValueWarningMsg("#1", "table", "{}", 3)
  end

	data.cObj_ = TeSociety()
	data.agents = {}
	data.messages = {}
	data.observerId = -1 --## PEDRO: para que serve isto?
	data.autoincrement = 1
	data.placements = {}

	setmetatable(data, metaTableSociety_)
	data.cObj_:setReference(data)

	if type(data.id) ~= "string" then
		if type(data.id) == "nil" then
			globalSocietyIdCounter = globalSocietyIdCounter + 1
			data.id = "soc"..globalSocietyIdCounter
			defaultValueWarningMsg("id", "string", data.id, 3)
		else
			incompatibleTypesErrorMsg("id", "string", type(data.id), 3)
		end
	end

	--if data.instance == nil then error("Error: Any Society requires an 'instance', got nil.", 2) end
	if type(data.instance) ~= "Agent" then
		if type(data.instance) == "nil" then
			mandatoryArgumentErrorMsg("instance", 3)
		else
			incompatibleTypesErrorMsg("instance", "Agent", type(data.instance), 3)
		end
	end

	if type(data.quantity) ~= "number" then
		if type(data.quantity) == "nil" then
			mandatoryArgumentErrorMsg("quantity", 3)
		else
			incompatibleTypesErrorMsg("quantity","positive integer number (except zero)", type(data.quantity), 3)
		end
	elseif data.quantity <= 0 or math.floor(data.quantity) ~= data.quantity then
		incompatibleValuesErrorMsg("quantity","positive integer number (except zero)", data.quantity, 3)
	end

	local quantity = data.quantity
	data.quantity = 0
	for i = 1, quantity do
		data:add({})
	end
	--[[
	local quantity = data.quantity
	data.quantity = 0
	for i = 1, quantity do
	if type(data.id) ~= "string" then
	incompatibleTypesMsg("id","string", type(data.id))
	globalSocietyIdCounter = globalSocietyIdCounter + 1
	data.id = "soc".. globalSocietyIdCounter
	defaultValueWarningMsg("id",data.id)
	end
	data:add()
	end
	--]]

	return data
end
