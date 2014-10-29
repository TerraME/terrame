-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

local getSocialNetworkByQuantity = function(soc, data)
	return function(agent)
		local quant = 0
		local rs = SocialNetwork()
		local rand = Random()

		while quant < data.quantity do
			local randomagent = soc:sample(rand)
			if randomagent ~= agent and not rs:isConnection(randomagent) then
				rs:add(randomagent, 1)
				quant = quant + 1
			end
		end
		return rs
	end
end

local getSocialNetworkByProbability = function(soc, data)
	return function(agent)
		local rs = SocialNetwork()
		local rand = Random()

		forEachAgent(soc, function(hint)
			if hint ~= agent and rand:number() < data.probability then
				rs:add(hint, 1)
			end
		end)
		return rs
	end
end

local getEmptySocialNetwork = function()
	return function()
		return SocialNetwork()
	end
end

local getSocialNetworkByFunction = function(soc, data)
	return function(agent)
		local rs = SocialNetwork()

		forEachAgent(soc, function(hint)
			if data.func(agent, hint) then
				rs:add(hint, 1)
			end
		end)
		return rs
	end
end

local getSocialNetworkByCell = function(soc, data)
	return function(agent)
		local  rs = SocialNetwork()
		forEachAgent(agent:getCell(data.placement), function(agentwithin)
			if agent ~= agentwithin or data.self then
				rs:add(agentwithin, 1)
			end
		end)
		return rs
	end
end

local getSocialNetworkByNeighbor = function(soc, data)
	return function(agent)
		local rs = SocialNetwork()
		forEachNeighbor(agent:getCell(data.placement), data.neighborhood, function(cell, neigh)
			forEachAgent(neigh, function(agentwithin)
				rs:add(agentwithin, 1)
			end)
		end)
		return rs
	end
end

Society_ = {
	type_ = "Society",
	--- Add a new Agent to the Society.
	-- @param agent The new Agent that will be added to the Society. If nil, the Society will add a 
	-- copy of the instance used to build the Society. In this case, the Society executes 
	-- Agent:init() after creating the copy.
	-- @usage soc:add(agent)
	-- @see Agent:init
	add = function(self, agent)
		if agent == nil then
			agent = {}
		end

		local mtype = type(agent)
		if mtype == "table" then
			agent.state_ = State{id = "state"} -- remove this in the next version
			agent.id = tostring(self.autoincrement)
			agent = Agent(agent)            
			local metaTable = {__index = self.instance, __tostring = tostringTerraME}
			setmetatable(agent, metaTable)
			agent:init()
		elseif mtype ~= "Agent" then
			incompatibleTypeError("#1", "Agent or table", agent)
		end

		agent.parent = self
		table.insert(self.agents, agent)
		if agent.id == nil then agent.id = tostring(self.autoincrement) end
		self.autoincrement = self.autoincrement + 1

		forEachElement(self.placements, function(placement, cs)
			if agent[placement] == nil then
				-- if the agent already has this placement then
				-- it does not need to be built again
				agent[placement] = Trajectory{target = cs, build = false}
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
	--- Create a directed SocialNetwork for each Agent of the Society. The following arguments 
	-- represent the strategies, which must be only one for call:
	-- @param data.strategy A string with the strategy to be used for creating the SocialNetwork. 
	-- See the table below.
	-- @param data.func A function (Agent, Agent)->boolean that returns true if the first Agent 
	-- will have the second Agent in its SocialNetwork. When using this argument, the default
	-- value of strategy becomes "func".
	-- @param data.name Name of the relation.
	-- @param data.onthefly If false (default), the SocialNetwork will be built and stored in
	-- each Agent of the Society. It means that the SocialNetwork will change only if the 
	-- modeler explicitly add or remove connections. If true, the SocialNetwork will be
	-- computed every time the simulation calls Agent:getSocialNetwork.
	-- It means that the SocialNetwork might change naturally along the simulation, according to 
	-- the adopted strategy. For instance, if the SocialNetwork of an Agent is based on its
	-- Neighborhood and the Agent walks to another Cell, an on-the-fly SocialNetwork will also be
	-- updated. A computational consequence of having on-the-fly SocialNetworks is that it saves
	-- memory (because the SocialNetworks are not explicitly represented), but it consumes more
	-- time, as it needs to be built again even if no changes occur in the simulation.
	-- @param data.neighborhood A string with the name of the Neighborhood that will be used to
	-- create the SocialNetwork. Default is "1".
	-- @param data.placement A string with the name of the Placement that will be used to
	-- create the SocialNetwork. Default is "placement".
	-- @param data.probability A number between 0 and 1 indicating the probability of each
	-- connection. The probability is applied for each pair of Agents. When using this argument,
	-- the default value of strategy becomes "probability".
	-- @param data.quantity A number indicating the number of connections each Agent will have,
	-- taking randomly from the whole Society. When using this argument, the default value of
	-- strategy becomes "quantity".
	-- @param data.self A boolean value indicating whether the Agent can be connected to itself.
	-- Default is false.
	-- @param data.random A Random object. Default is the internal random generator.
	-- @tabular strategy
	-- Strategy &
	-- Description &
	-- Compulsory parameters & Optional parameters \
	-- "cell" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- same Cell the Agent belongs. & &
	-- name, self \
	-- "func" &
	-- Create a SocialNetwork according to a membership function. & func &
	-- name \
	-- "neighbor" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- neighbor Cells of the one the Agent belongs. &
	-- & name, neighborhood \
	-- "probability" &
	-- Applies a probability for each pair of Agents (excluding the agent itself). &
	-- probability & name, random \
	-- "quantity" &
	-- Number of connections randomly taken from the Society (excluding the agent itself). &
	-- quantity & name, random \
	-- "void" &
	-- Create an empty SocialNetwork for each Agent of the Society. &
	-- & name \
	-- @usage soc:createSocialNetwork {
	--     quantity = 2
	-- }
	--
	-- soc:createSocialNetwork {
	--     probability = 0.15
	--     name = "random"
	-- }
	--
	-- soc:createSocialNetwork {
	--    neighbor = "1"
	--    name = "byneighbor"
	--}
	createSocialNetwork = function(self, data)
		verifyNamedTable(data)

		if data.strategy == nil then
			if data.probability ~= nil then
				data.strategy = "probability"
			elseif data.quantity ~= nil then
				data.strategy = "quantity"
				if data.quantity == 1 then data.quantity = nil end
			elseif data.func ~= nil then
				data.strategy = "func"
			else
				customError("It was not possible to infer a value for argument 'strategy'.")
			end
		end

		defaultTableValue(data, "name", "1")
		defaultTableValue(data, "onthefly", false)

		if self.agents[1].socialnetworks[data.name] ~= nil then
			customError("SocialNetwork '"..data.name.."' already exists in the Society.")
		end

		switch(data, "strategy"):caseof{
			probability = function() 
				checkUnnecessaryParameters(data, {"strategy", "probability", "name", "random", "onthefly"})

				mandatoryTableArgument(data, "probability", "number")

				if data.probability <= 0 or data.probability > 1 then
					incompatibleValueError("probability", "a number between 0 and 1", data.probability)
				end

				data.mfunc = getSocialNetworkByProbability
			end,
			func = function()
				checkUnnecessaryParameters(data, {"strategy", "func", "name", "onthefly"})

				mandatoryTableArgument(data, "func", "function")

				data.mfunc = getSocialNetworkByFunction
			end,
			cell = function()
				checkUnnecessaryParameters(data, {"strategy", "self", "name", "placement", "onthefly"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "placement", "placement")

				if self.agents[1][data.placement] == nil or self.agents[1][data.placement].cells[1] == nil then
					customError("Society has no placement. Use Environment:createPlacement() first.")
				end

				data.mfunc = getSocialNetworkByCell
			end,
			neighbor = function()
				checkUnnecessaryParameters(data, {"strategy", "neighborhood", "name", "placement", "onthefly"})

				defaultTableValue(data, "neighborhood", "1")
				defaultTableValue(data, "placement", "placement")

				if self.agents[1][data.placement] == nil or self.agents[1][data.placement].cells[1] == nil then
					customError("Society has no placement. Use Environment:createPlacement() first.")
				elseif self.agents[1].placement.cells[1]:getNeighborhood(data.neighborhood) == nil then
					customError("CellularSpace has no Neighborhood named '"..data.neighborhood.."'. Use CellularSpace:createNeighborhood() first.")
				end

				data.mfunc = getSocialNetworkByNeighbor
			end,
			quantity = function()
				checkUnnecessaryParameters(data, {"strategy", "quantity", "name", "random", "onthefly"})

				defaultTableValue(data, "quantity", 1)

				if data.quantity <= 0 then
					incompatibleValueError("quantity", "positive number (except zero)", data.quantity)
				elseif math.floor(data.quantity) ~= data.quantity then
					incompatibleValueError("quantity", "integer number", data.quantity)
				end

				data.mfunc = getSocialNetworkByQuantity
			end,
			void = function()
				checkUnnecessaryParameters(data, {"strategy", "name", "onthefly"})

				data.mfunc = getEmptySocialNetwork
			end
		}

		local func = data.mfunc(self, data)
		local name = data.name
		if data.onthefly then
			forEachAgent(self, function(agent)
				agent:addSocialNetwork(func, name)
			end)
		else
			forEachAgent(self, function(agent)
				agent:addSocialNetwork(func(agent), name)
			end)
		end
	end,
	--- Return a given Agent based on its index. Deprecated. Use Society:get instead.
	-- @param index The index of the Agent that will be returned.
	-- @usage agent = soc:getAgent("1")
	getAgent = function(self, index)
		deprecatedFunctionWarning("getAgent", "get")
		return self:get(index)
	end,
	--- Return a given Agent based on its index.
	-- @param index The index of the Agent that will be returned.
	-- @usage agent = soc:get("1")
	get = function(self, index)
		--TODO: implementar a funcao getAgentByID, que gera uma tabela [ID] -> posicao em soc.agents
		-- depois coloca esta tabela na propria sociedade, e entao atualiza o getAgentByID para retornar
		-- uma consulta a esta tabela. Fazer o mesmo para o CellularSpace, com um getCellByID
		if type(index) ~= "number" then
			incompatibleTypeError("index", "positive integer number", index)
		elseif index < 0 then
			incompatibleValueError("index", "positive integer number", "negative number")
		elseif math.floor(index) ~= index then
			incompatibleValueError("index", "positive integer number", "float number")
		end
		return self.agents[index]
	end,
	--- Return a vector with the Agents of the Society. Deprecated. Use .agents instead.
	-- @usage agent = soc:getAgents()[1]
	getAgents = function(self)
		deprecatedFunctionWarning("getAgents", ".agents")
		return self.agents
	end,
	--- Notify all the Agents of the Society.
	-- @param modelTime The notification time.
	-- @usage society:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
		elseif type(modelTime) ~= "number" then
			if type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				incompatibleTypeError("#1", "Event or positive number", modelTime) 
			end
		elseif modelTime < 0 then
			incompatibleValueError("#1", "Event or positive number", modelTime)   
		end

		if self.obsattrs then
			forEachElement(self.obsattrs, function(idx)
				if idx == "quantity_" then
					self.quantity_ = #self
				else
					self[idx.."_"] = self[idx](self)
				end
			end)
		end

		forEachAgent(self, function(agent)
			agent:notify(modelTime)
		end)
		self.cObj_:notify(modelTime)
	end,
	--- Remove a given Agent from the Society. It returns whether the agent was sucessfully removed.
	-- @usage soc:remove(agent)
	-- @param arg The Agent that will be removed, or a function that takes an Agent as argument and
	-- returns true if the Agent must be removed.
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
			customError("Could not remove the Agent (id = '"..tostring(arg.id).."').")
			return false
		elseif type(arg) == "function" then
			-- It uses the function func
			local ret = false
			for i = #self.agents, 1, -1  do
				if arg(self.agents[i]) == true then
					ret = self:remove(self.agents[i])
				end
			end
		else
			incompatibleTypeError("#1", "Agent or function", arg) 
		end
	end,
	--- Return a random Agent from the Society.
	-- @usage agent = soc:sample()
	sample = function(self)
		if #self.agents > 0 then
			return self.agents[Random():integer(1, #self.agents)]
		else
			customError("Trying to sample an empty Society.")
		end
	end,
	--- Return the number of Agents of the Society. Deprecated. Use # instead.
	-- @usage print(soc:size())
	size = function(self)
		deprecatedFunctionWarning("size", "operator #")
		return #self
	end,
	--- Split the Society into a set of Groups according to a classification strategy. The 
	-- generated Groups have empty intersection and union equals to the whole 
	-- CellularSpace (unless function below returns nil for some Agent). It works according 
	-- to the type of its only and compulsory argument, that can be:
	-- @param argument string or function
	--
	-- @tabular argument
	-- Type of argument &
	-- Description \
	-- string &
	-- The argument must represent the name of one attribute of the Agents of the Society. Split 
	-- then creates one Group for each possible value of the attribute using the value as index
	-- and fills them with the Agents that have the respective attribute value. \
	-- function &
	-- The argument is a function that receives an Agent as argument and returns a value with the
	-- index that contains the Agent. Groups are then indexed according to the returning value.
	--
	-- @usage gs = soc:split("gender")
	-- print(#gs.male)
	-- print(#gs.female)
	-- 
	-- gs2 = soc:split(function(ag)
	--     if ag.age > 60 then 
	--         return "old" 
	--     else 
	--         return "notold" 
	--     end
	-- end)
	-- print(#ts.old)
	split = function(self, argument)
		if type(argument) == "string" then
			local value = argument
			argument = function(agent)
				if agent[value] then return agent[value] end
				return nil
			end
		end

		if type(argument) ~= "function" then
			incompatibleTypeError("#1", "string or function", argument)
		end

		local result = {}
		local class_
		local i = 1
    
		forEachAgent(self, function(agent)
			class_ = argument(agent)

			if result[class_] == nil then
				result[class_] = Group{
					target = self,
					build = false,
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
				incompatibleTypeError("#1", "positive number", delay)
			end
		elseif delay <= 0 then
			incompatibleValueError("#1", "positive number", delay)
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

metaTableSociety_ = {
	__index = Society_,
	--- Return the number of Agents of the Society.
	-- @name #
	-- @usage print(#soc)
	__len = function(self)
		return #self.agents
	end,
	__tostring = tostringTerraME
}
--- Type to create and manipulate a set of Agents. Each Agent within a Society has a 
-- unique id, which is initialized while creating the Society. There are different ways to 
-- create a Society. See the parameter dbType for the options.
-- Calling Utils:forEachAgent() traverses Societies
-- Societies have additional functions related to its parameter instance, according to the 
-- table below.
-- @tabular instance
-- Attribute of instance & Function within the Society \
-- function & Call the function of each of its Agents. \
-- number & Return the sum of the number in each of its Agents. \
-- boolean & Return the sum of true values in each of its Agents. \
-- string & Return a table with positions equal to the unique strings and values equal to the
-- number of occurrences in each of its Agents.
-- @param data.database Name of the database.
-- @param data.dbType A string with the name of the source the Society will be read from. 
-- TerraME always converts this string to lower case. See the table below:
-- @tabular dbType
-- dbType & Description & Compulsory parameters & Optional parameters \
-- "volatile" & Create agents from scratch. This is the default value when using the argument
-- quantity. & quantity, instance & \
-- "database" & Load agents from a database. This is the default value when using the argument
-- theme. & theme, database, instance & layer, host, password, select, where, user, port \
-- "csv" & Load agents from a csv file. This is the default value when value of parameter
-- database ends with ".csv". & database, id, instance & sep
-- @param data.host Host where the database is stored (default is "localhost").
-- @param data.id The unique identifier attribute used when reading the Society from a file.
-- @param data.instance An Agent with the description of attributes and functions. When using this
-- parameter, each Agent will have attributes and functions according to the instance. The Society
-- calls Agent:init() from the instance for each of its Agents. Additional functions are also
-- created to the Society, according to the attributes of the instance. For each attribute of the
-- instance, one function is created in the Society with the same name (note that attributes
-- declared exclusively in Agent:init() will not be mapped, as they do not belong to the
-- instance). The table below describes how each attribute is mapped:
-- @param data.layer Name of the layer the theme was created from. It must be used to solve a
-- conflict when there are two themes with the same name (default is "").
-- @param data.password The password (default is "").
-- @param data.port Port number of the connection.
-- @param data.sep A string with the file separator for reading a CSV (default is ",").
-- @param data.quantity Number of Agents to be created. It is used when the Society will not be
-- loaded from a file or database.
-- @param data.select A table containing the names of the attributes to be retrieved (default is
-- all attributes). When retrieving a single attribute, you can use select = "attribute" instead
-- of select = {"attribute"}. It is possible to rename the attribute name using "as", for
-- example, select = {"currentage as age"} reads currentage from the database but replaces the
-- name to age in the Agents.
-- @param data.theme Name of the theme to be loaded.
-- @param data.user Username (default is "").
-- @param data.where A SQL restriction on the properties of the Agents (default is "", applying
-- no restriction. Only the Agents that reflect the established criteria will be loaded). This
-- argument ignores the "as" flexibility of select. 
--
-- @output agents A vector of Agents pointed by the Society.
-- @output instance The Agent that describes attributes and functions of each Agent belonging to
-- the Society. This Agent must not be executed.
-- @output autoincrement unique identifier used to represent the last Agent added to the Society.
-- The next Agent will have 'autoincrement+1' as id.
-- @output messages A vector that contains the delayed messages.
-- @output parent The Environment it belongs.
--
-- @usage my_instance = Agent {
--     execute = function(...),
--     run = function(...),
--     age = 0
-- }
-- 
-- s = Society {
--     instance = my_instance,
--     quantity = 20
-- }
-- 
-- s:execute() -- call execute for each agent
-- s:run() -- call run for each agent
-- print(s:age()) -- sum of the ages of each agent
--
-- s = Society {
--     instance = my_instance,
--     database = "c:\\datab.mdb",
--     layer = "farmers"
-- }
-- 
-- s = Society {
--     instance = my_instance,
--     database = "file.csv"
-- }
function Society(data)
	verifyNamedTable(data)

	data.cObj_ = TeSociety()
	data.agents = {}
	data.messages = {}
	data.observerId = -1
	data.autoincrement = 1
	data.placements = {}

	setmetatable(data, metaTableSociety_)
	data.cObj_:setReference(data)

	if type(data.id) ~= "string" then
		if type(data.id) == "nil" then
		else
			incompatibleTypeError("id", "string", data.id)
		end
	end

	if type(data.instance) ~= "Agent" then
		if type(data.instance) == "nil" then
			mandatoryArgumentError("instance")
		else
			incompatibleTypeError("instance", "Agent", data.instance)
		end
	end

	-- create functions for the society according to the attributes of its instance
	forEachElement(data.instance, function(attribute, value, mtype)
		if attribute == "id" or attribute == "parent" then return
		elseif attribute == "messages" or attribute == "instance" or 
               attribute == "autoincrement" or attribute == "placements" then
			customWarning("Attribute '"..attribute.."' belong to both Society and Agent.")
			return
		elseif mtype == "function" then
			data[attribute] = function(soc, args)
				forEachAgent(soc, function(agent)
					agent[attribute](agent, args)
				end)
			end
		elseif mtype == "number" then
			data[attribute] = function(soc)
				-- TODO: verify the type of soc and return error. implement alternative tests to all the cases
				local quantity = 0
				forEachAgent(soc, function(agent)
					quantity = quantity + agent[attribute]
				end)
				return quantity
			end
		elseif mtype == "boolean" then
			data[attribute] = function(soc)
				local quantity = 0
				forEachAgent(soc, function(agent)
					if agent[attribute] then
						quantity = quantity + 1
					end
				end)
				return quantity
			end
		elseif mtype == "string" then
			data[attribute] = function(soc)
				local result = {}
				forEachAgent(soc, function(agent)
					local value = agent[attribute]
					if result[value] then
						result[value] = result[value] + 1
					else
						result[value] = 1
					end
				end)
				return result
			end
		end
	end)

	if type(data.database) == "string" then
		if data.database:endswith(".csv") then
			if data.sep and type(data.sep) ~= "string" then
				incompatibleTypeError("sep", "string", data.sep)
			end			
			local f = io.open(data.database)
			if not f then
				resourceNotFoundError("database", data.database)
			end
			f:close()
			local csv = readCSV(data.database, data.sep)
			for i = 1, #csv do
				data:add(csv[i])
			end
		else
			local cs = CellularSpace{
				database = data.database, 
				port = data.port, 
				user = data.user, 
				host = data.host,
				dbType = data.dbType,
				password = data.password
			}
			forEachCell(cs, function(cell)
				cell.type_ = "table"
				cell.cObj_ = nil
				data:add(cell)
			end)
		end
	else
		if type(data.quantity) ~= "number" then
			if data.quantity == nil then
				mandatoryArgumentError("quantity")
			else
				incompatibleTypeError("quantity", "positive integer number (except zero)", data.quantity)
			end
		elseif data.quantity <= 0 or math.floor(data.quantity) ~= data.quantity then
			incompatibleValueError("quantity", "positive integer number (except zero)", data.quantity)
		end
	
		local quantity = data.quantity
		data.quantity = 0
		for i = 1, quantity do
			data:add({})
		end
	end
	--[[
	local quantity = data.quantity
	data.quantity = 0
	for i = 1, quantity do
	if type(data.id) ~= "string" then
	incompatibleTypes("id","string", data.id)
	end
	data:add()
	end
	--]]

	return data
end

