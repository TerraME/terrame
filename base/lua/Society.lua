--#########################################################################################
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
--#########################################################################################

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
			if data.filter(agent, hint) then
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
	-- @arg agent The new Agent that will be added to the Society. If nil, the Society will add a 
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

			forEachOrderedElement(self.instance, function(idx, value, mtype)
				if mtype == "Choice" then
					agent[idx] = value:sample()
				end
			end)
		elseif mtype ~= "Agent" then
			incompatibleTypeError(1, "Agent or table", agent)
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
	-- @arg data.strategy A string with the strategy to be used for creating the SocialNetwork. 
	-- See the table below.
	-- @arg data.filter A function (Agent, Agent)->boolean that returns true if the first Agent 
	-- will have the second Agent in its SocialNetwork. When using this argument, the default
	-- value of strategy becomes "function".
	-- @arg data.name Name of the relation.
	-- @arg data.inmemory If tru (default), the SocialNetwork will be built and stored in
	-- each Agent of the Society. It means that the SocialNetwork will change only if the 
	-- modeler explicitly add or remove connections. If true, the SocialNetwork will be
	-- computed every time the simulation calls Agent:getSocialNetwork.
	-- It means that the SocialNetwork might change naturally along the simulation, according to 
	-- the adopted strategy. For instance, if the SocialNetwork of an Agent is based on its
	-- Neighborhood and the Agent walks to another Cell, an on-the-fly SocialNetwork will also be
	-- updated. A computational consequence of having on-the-fly SocialNetworks is that it saves
	-- memory (because the SocialNetworks are not explicitly represented), but it consumes more
	-- time, as it needs to be built again even if no changes occur in the simulation.
	-- @arg data.neighborhood A string with the name of the Neighborhood that will be used to
	-- create the SocialNetwork. Default is "1".
	-- @arg data.placement A string with the name of the Placement that will be used to
	-- create the SocialNetwork. Default is "placement".
	-- @arg data.probability A number between 0 and 1 indicating the probability of each
	-- connection. The probability is applied for each pair of Agents. When using this argument,
	-- the default value of strategy becomes "probability".
	-- @arg data.quantity A number indicating the number of connections each Agent will have,
	-- taking randomly from the whole Society. When using this argument, the default value of
	-- strategy becomes "quantity".
	-- @arg data.self A boolean value indicating whether the Agent can be connected to itself.
	-- Default is false.
	-- @arg data.random A Random object. Default is the internal random generator.
	-- @tabular strategy
	-- Strategy &
	-- Description &
	-- Compulsory arguments & Optional arguments \
	-- "cell" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- same Cell the Agent belongs. & &
	-- name, placement, self, inmemory \
	-- "function" &
	-- Create a SocialNetwork according to a membership function. & filter &
	-- name, inmemory \
	-- "neighbor" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- neighbor Cells of the one the Agent belongs. &
	-- & name, neighborhood, placement, inmemory \
	-- "probability" &
	-- Applies a probability for each pair of Agents (excluding the agent itself). &
	-- probability & name, random, inmemory \
	-- "quantity" &
	-- Number of connections randomly taken from the Society (excluding the agent itself). &
	-- quantity & name, random, inmemory \
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
			elseif data.filter ~= nil then
				data.strategy = "function"
			else
				customError("It was not possible to infer a value for argument 'strategy'.")
			end
		end

		defaultTableValue(data, "name", "1")

		if data.strategy ~= "void" then
			defaultTableValue(data, "inmemory", true)
		end

		if self.agents[1].socialnetworks[data.name] ~= nil then
			customError("SocialNetwork '"..data.name.."' already exists in the Society.")
		end

		switch(data, "strategy"):caseof{
			probability = function() 
				checkUnnecessaryArguments(data, {"strategy", "probability", "name", "random", "inmemory"})

				mandatoryTableArgument(data, "probability", "number")

				if data.probability <= 0 or data.probability > 1 then
					incompatibleValueError("probability", "a number between 0 and 1", data.probability)
				end

				data.mfunc = getSocialNetworkByProbability
			end,
			["function"] = function()
				checkUnnecessaryArguments(data, {"strategy", "filter", "name", "inmemory"})

				mandatoryTableArgument(data, "filter", "function")

				data.mfunc = getSocialNetworkByFunction
			end,
			cell = function()
				checkUnnecessaryArguments(data, {"strategy", "self", "name", "placement", "inmemory"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "placement", "placement")

				if self.agents[1][data.placement] == nil or self.agents[1][data.placement].cells[1] == nil then
					customError("Society has no placement. Use Environment:createPlacement() first.")
				end

				data.mfunc = getSocialNetworkByCell
			end,
			neighbor = function()
				checkUnnecessaryArguments(data, {"strategy", "neighborhood", "name", "placement", "inmemory"})

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
				checkUnnecessaryArguments(data, {"strategy", "quantity", "name", "random", "inmemory"})

				defaultTableValue(data, "quantity", 1)

				integerTableArgument(data, "quantity")
				positiveTableArgument(data, "quantity")

				data.mfunc = getSocialNetworkByQuantity
			end,
			void = function()
				checkUnnecessaryArguments(data, {"strategy", "name"})

				data.mfunc = getEmptySocialNetwork
			end
		}

		local func = data.mfunc(self, data)
		local name = data.name
		if data.inmemory then
			forEachAgent(self, function(agent)
				agent:addSocialNetwork(func(agent), name)
			end)
		else
			forEachAgent(self, function(agent)
				agent:addSocialNetwork(func, name)
			end)
		end
	end,
	--- Return a given Agent based on its index.
	-- @arg index The index of the Agent that will be returned.
	-- @usage agent = soc:getAgent("1")
	-- @deprecated Society:get
	getAgent = function(self, index)
		deprecatedFunction("getAgent", "get")
	end,
	--- Return a given Agent based on its index.
	-- @arg index The index of the Agent that will be returned.
	-- @usage agent = soc:get("1")
	get = function(self, index)
		mandatoryArgument(1, "number", index)

		integerArgument(1, index)
		positiveArgument(1, index)

		return self.agents[index]
	end,
	--- Return a vector with the Agents of the Society.
	-- @usage agent = soc:getAgents()[1]
	-- @deprecated Society.agents
	getAgents = function(self)
		deprecatedFunction("getAgents", ".agents")
	end,
	--- Notify all the Agents of the Society.
	-- @arg modelTime The notification time.
	-- @usage society:notify()
	notify = function (self, modelTime)
		if type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		end

		optionalArgument(1, "number", modelTime)

		if modelTime < 0 then
			incompatibleValueError(1, "positive number", modelTime)
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
	-- @arg arg The Agent that will be removed, or a function that takes an Agent as argument and
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
			incompatibleTypeError(1, "Agent or function", arg) 
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
	--- Return the number of Agents of the Society.
	-- @usage print(soc:size())
	-- @deprecated Society:#
	size = function(self)
		deprecatedFunction("size", "operator #")
	end,
	--- Split the Society into a set of Groups according to a classification strategy. The 
	-- generated Groups have empty intersection and union equals to the whole 
	-- CellularSpace (unless function below returns nil for some Agent). It works according 
	-- to the type of its only and compulsory argument, that can be:
	-- @arg argument string or function
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
		if type(argument) ~= "function" and type(argument) ~= "string" then
			if argument == nil then
				mandatoryArgumentError(1)
			else
				incompatibleTypeError(1, "string or function", argument)
			end
		end

		if type(argument) == "string" then
			if self:sample()[argument] == nil then
				customError("Attribute '"..argument.."' does not exist.")
			end

			local value = argument
			argument = function(agent)
				return agent[value]
			end
		end

		local result = {}
		local class_
    
		forEachAgent(self, function(agent)
			class_ = argument(agent)

			if result[class_] == nil then
				result[class_] = Group{
					target = self,
					build = false,
				}
			end
			table.insert(result[class_].agents, agent)
		end)
		return result
	end,
	--- Activate each asynchronous message sent by Agents belonging to the Society.
	-- @arg delay A number indicating the current delay to be delivered. Messages with delay less
	-- or equal this value are sent, while the others have their delays reduced by this value.
	-- Default is one.
	-- @usage soc:synchronize()
	-- soc:synchronize(2)
	synchronize = function(self, delay)
		optionalArgument(1, "number", delay)

		if delay == nil then
			delay = 1
		else
			positiveArgument(1, delay)
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
	-- @usage print(#soc)
	__len = function(self)
		return #self.agents
	end,
	__tostring = tostringTerraME
}
--- Type to create and manipulate a set of Agents. Each Agent within a Society has a 
-- unique id, which is initialized while creating the Society. There are different ways to 
-- create a Society. See the argument dbType for the options.
-- Calling Utils:forEachAgent() traverses Societies
-- Societies have additional functions related to its argument instance, according to the 
-- table below.
-- @tabular instance
-- Attribute of instance & Function within the Society \
-- function & Call the function of each of its Agents. \
-- number & Return the sum of the number in each of its Agents. \
-- boolean & Return the sum of true values in each of its Agents. \
-- string & Return a table with positions equal to the unique strings and values equal to the
-- number of occurrences in each of its Agents.
-- @arg data.database Name of the database.
-- @arg data.dbType A string with the name of the source the Society will be read from. 
-- TerraME always converts this string to lower case. See the table below:
-- @tabular dbType
-- dbType & Description & Compulsory arguments & Optional arguments \
-- "volatile" & Create agents from scratch. This is the default value when using the argument
-- quantity. & quantity, instance & \
-- "database" & Load agents from a database. This is the default value when using the argument
-- theme. & theme, database, instance & layer, host, password, select, where, user, port \
-- "csv" & Load agents from a csv file. This is the default value when value of argument
-- database ends with ".csv". & database, id, instance & sep
-- @arg data.host Host where the database is stored (default is "localhost").
-- @arg data.id The unique identifier attribute used when reading the Society from a file.
-- @arg data.instance An Agent with the description of attributes and functions. When using this
-- argument, each Agent will have attributes and functions according to the instance. The Society
-- calls Agent:init() from the instance for each of its Agents. 
-- Every attribute from the Cell that is a Choice will be converted into a sample from the Choice.
-- Additional functions are also
-- created to the Society, according to the attributes of the instance. For each attribute of the
-- instance, one function is created in the Society with the same name (note that attributes
-- declared exclusively in Agent:init() will not be mapped, as they do not belong to the
-- instance). The table below describes how each attribute is mapped:
-- @arg data.layer Name of the layer the theme was created from. It must be used to solve a
-- conflict when there are two themes with the same name (default is "").
-- @arg data.password The password (default is "").
-- @arg data.port Port number of the connection.
-- @arg data.sep A string with the file separator for reading a CSV (default is ",").
-- @arg data.quantity Number of Agents to be created. It is used when the Society will not be
-- loaded from a file or database.
-- @arg data.select A table containing the names of the attributes to be retrieved (default is
-- all attributes). When retrieving a single attribute, you can use select = "attribute" instead
-- of select = {"attribute"}. It is possible to rename the attribute name using "as", for
-- example, select = {"currentage as age"} reads currentage from the database but replaces the
-- name to age in the Agents.
-- @arg data.theme Name of the theme to be loaded.
-- @arg data.user Username (default is "").
-- @arg data.where A SQL restriction on the properties of the Agents (default is "", applying
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

	mandatoryTableArgument(data, "instance", "Agent")

	if data.instance.isinstance then
		customError("The same instance cannot be used by two Societies.")
	end

	local function createSummaryFunctions(agent)
		-- create functions for the society according to the attributes of its instance
		forEachElement(agent, function(attribute, value, mtype)
			if belong(attribute, {"id", "parent"}) then return
			elseif belong(attribute, {"messages", "instance", "autoincrement", "placements"}) then
				customWarning("Attribute '"..attribute.."' belongs to both Society and Agent.")
			elseif mtype == "function" then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(soc, args)
					forEachAgent(soc, function(agent)
						agent[attribute](agent, args)
					end)
				end
			elseif mtype == "number" or (mtype == "Choice" and (value.min or type(value.values[1]) == "number")) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(soc)
					local quantity = 0
					forEachAgent(soc, function(agent)
						quantity = quantity + agent[attribute]
					end)
					return quantity
				end
			elseif mtype == "boolean" then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(soc)
					local quantity = 0
					forEachAgent(soc, function(agent)
						if agent[attribute] then
							quantity = quantity + 1
						end
					end)
					return quantity
				end
			elseif mtype == "string" or (mtype == "Choice" and value.values and type(value.values[1]) == "string") then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

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
	end

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
			local csv = CSVread(data.database, data.sep)
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
		mandatoryTableArgument(data, "quantity", "number")
		integerTableArgument(data, "quantity")
		positiveTableArgument(data, "quantity")
	
		local quantity = data.quantity
		data.quantity = 0
		for i = 1, quantity do
			data:add({})
		end
	end

	local newAttTable = {}
	forEachElement(data.agents[1], function(idx, value)
		if data.instance[idx] == nil then
			newAttTable[idx] = value
		end
	end)

	createSummaryFunctions(newAttTable)

	setmetatable(data.instance, nil)
	createSummaryFunctions(data.instance)

	forEachElement(Agent_, function(idx, value)
		if belong(idx, {"execute", "init", "on_message"}) then
			if not data.instance[idx] then
				data.instance[idx] = value
			end
			return
		end

		if data.instance[idx] then
			if type(value) == "function" then
				customWarning("Function '"..idx.."()' from Agent is replaced in the instance.")
			end
		else
			data.instance[idx] = value
		end
	end)

	local metaTableInstance = {__index = data.instance, __tostring = tostringTerraME}

	data.instance.type_ = "Agent"
	data.instance.isinstance = true

	forEachAgent(data, function(agent)
		setmetatable(agent, metaTableInstance)
	end)

	return data
end

