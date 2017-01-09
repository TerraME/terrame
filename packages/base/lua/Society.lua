-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

local terralib = getPackage("terralib")

local function getEmptySocialNetwork()
	return function()
		return SocialNetwork()
	end
end

local function getSocialNetworkByCell(_, data)
	return function(agent)
		local rs = SocialNetwork()
		forEachAgent(agent:getCell(data.placement), function(agentwithin)
			if agent ~= agentwithin or data.self then
				rs:add(agentwithin, 1)
			end
		end)
		return rs
	end
end

local function getSocialNetworkByFunction(soc, data)
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

local function getSocialNetworkByNeighbor(_, data)
	return function(agent)
		local rs = SocialNetwork()
		forEachNeighbor(agent:getCell(data.placement), data.neighborhood, function(_, neigh)
			forEachAgent(neigh, function(agentwithin)
				rs:add(agentwithin, 1)
			end)
		end)
		return rs
	end
end

local function getSocialNetworkByProbability(soc, data)
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

local function getSocialNetworkByQuantity(soc, data)
	return function(agent)
		local quant = 0
		local rs = SocialNetwork()

		while quant < data.quantity do
			local randomagent = soc:sample()
			if randomagent ~= agent and not rs:isConnection(randomagent) then
				rs:add(randomagent, 1)
				quant = quant + 1
			end
		end
		return rs
	end
end

Society_ = {
	type_ = "Society",
	--- Add a new Agent to the Society. It will be the last Agent of the Society when one
	-- uses Utils:forEachAgent().
	-- @arg agent The new Agent that will be added to the Society. If nil, the Society will add a
	-- copy of its instance. In this case, the Society converts Random values into samples and executes
	-- Agent:init().
	-- @usage ag = Agent{
	--     age = Random{min = 1, max = 50, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- soc:add()
	-- print(#soc)
	-- agent = soc:add()
	-- print(agent.age)
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
			local metaTable = {__index = self.instance, __tostring = _Gtme.tostring}
			setmetatable(agent, metaTable)

			forEachOrderedElement(self.instance, function(idx, value, mmtype)
				if mmtype == "Random" then
					agent[idx] = value:sample()
				end
			end)

			agent.parent = self
			agent:init()
		elseif mtype ~= "Agent" then
			incompatibleTypeError(1, "Agent or table", agent)
		else
			agent.parent = self
		end

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

		if self.observerdata_ then
			local mdata = self.observerdata_
			agent.state_ = "alive"
			agent.cObj_:createObserver(mdata[1], mdata[2], mdata[3])
		end

		return agent
	end,
	--- Remove all the Agents from the Society.
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- print(#soc)
	-- soc:clear()
	-- print(#soc)
	clear = function(self)
		self.agents = {}
		self.autoincrement = 1
	end,
	--- Create a directed SocialNetwork for each Agent of the Society.
	-- @arg data.strategy A string with the strategy to be used for creating the SocialNetwork.
	-- See the table below.
	-- @arg data.filter A function (Agent, Agent)->boolean that returns true if the first Agent
	-- will have the second Agent in its SocialNetwork. When using this argument, the default
	-- value of strategy becomes "function".
	-- @arg data.name Name of the relation.
	-- @arg data.inmemory If true (default), a SocialNetwork will be built and stored for
	-- each Agent of the Society. The SocialNetworks will change only if the
	-- modeler add or remove connections explicitly. If false, a SocialNetwork will be
	-- computed every time the simulation calls Agent:getSocialNetwork(), for
	-- example when using Utils:forEachConnection(). In this case, if any of the attributes
	-- the SocialNetwork is based on changes then the resulting SocialNetwork might be different.
	-- For instance, if the SocialNetwork of an Agent is based on its Neighborhood and the Agent
	-- walks to another Cell, a SocialNetwork not inmemory will also be updated.
	-- SocialNetworks not inmemory also help the simulation to run with larger datasets,
	-- as they are not explicitly represented, but they consume more
	-- time as they need to be built again and again along the simulation.
	-- Note that not inmemory relations cannot be changed manually (for example by using
	-- SocialNetwork:add()), because the relation is recomputed every time it is needed.
	-- @arg data.neighborhood A string with the name of the Neighborhood that will be used to
	-- create the SocialNetwork. The default value is "1".
	-- @arg data.placement A string with the name of the placement that will be used to
	-- create the SocialNetwork. The default value is "placement".
	-- @arg data.probability A number between 0 and 1 indicating a probability. The
	-- semantics associated to the probability depends on the argument strategy.
	-- When using this argument,
	-- the default value of strategy becomes "probability".
	-- @arg data.quantity A number indicating a quantity of connections. The semantics associated
	-- to this value depends on the argument strategy.
	-- When using this argument, the default value of strategy becomes "quantity".
	-- @arg data.self A boolean value indicating whether the Agent can be connected to itself.
	-- The default value is false.
	-- @arg data.start The number of agents without any connection in the initial group. New
	-- agents are connected to agents in this group and then added to the group. This argument
	-- is useful only for "barabasi" strategy.
	-- @arg data.symmetric A boolean value indicating that, if Agent a is connected to Agent b,
	-- then Agent b will be connected to Agent a. In practice, if this option is used, the
	-- number of connections double. For example, if one use this with 20% of probability,
	-- on average, Agents will be connected with 40% of probability. The default value is false.
	-- @tabular strategy
	-- Strategy &
	-- Description &
	-- Compulsory arguments & Optional arguments \
	-- "barabasi" & Create a SocialNetwork according to the strategy proposed by Barabasi and
	-- Albert "Emergence of scaling in random networks" Science 286 509-512 (1999). &
	-- strategy, start, quantity & name \
	-- "cell" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- same Cell the Agent belongs. & &
	-- name, placement, self, inmemory \
	-- "erdos" & Create a SocialNetwork with a given number of random connections. This strategy implements
	-- the algorithm proposed by Erdos and Renyi (1959) "On random graphs I". Publicationes Mathematicae
	-- 6: 290-297 & strategy, quantity & name \
	-- "function" &
	-- Create a SocialNetwork according to a filter function applied to each Agent of the Society. & filter &
	-- name, inmemory \
	-- "neighbor" &
	-- Create a dynamic SocialNetwork for each Agent of the Society with every Agent within the
	-- neighbor Cells of the one the Agent belongs. &
	-- & name, neighborhood, placement, inmemory \
	-- "probability" &
	-- Applies a probability for each pair of Agents to be connected (excluding the Agent itself). &
	-- probability & name, inmemory, symmetric \
	-- "quantity" &
	-- Each Agent will be connected to a given number of other Agents randomly taken from the Society
	-- (excluding the Agent itself). &
	-- quantity & name, inmemory, symmetric \
	-- "void" &
	-- Create an empty SocialNetwork for each Agent of the Society. &
	-- & name \
	-- "watts" & Create a SocialNetwork according to the strategy proposed by
	-- Watts and Strogarz (1998) Collective dynamics of 'small-world' networks. Nature 393, 440-442.
	-- & probability, quantity, strategy & name  \
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 20
	-- }
	--
	-- soc:createSocialNetwork{
	--     quantity = 2
	-- }
	--
	-- soc:createSocialNetwork{
	--     probability = 0.15,
	--     name = "random"
	-- }
	--
	-- cs = CellularSpace{xdim = 10}
	-- cs:createNeighborhood()
	-- env = Environment{soc, cs}
	-- env:createPlacement()
	--
	-- soc:createSocialNetwork{
	--    strategy = "neighbor",
	--    name = "byneighbor"
	-- }
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
			elseif data.neighborhood ~= nil then
				data.strategy = "neighbor"
			else
				customError("It was not possible to infer a value for argument 'strategy'.")
			end
		end

		defaultTableValue(data, "name", "1")

		if belong(data.strategy, {"void", "erdos", "barabasi", "watts"}) then
			verify(data.inmemory == nil, "Argument 'inmemory' does not work with strategy '"..data.strategy.."'.")
		else
			defaultTableValue(data, "inmemory", true)
		end

		if self.agents[1].socialnetworks[data.name] ~= nil then
			customError("SocialNetwork '"..data.name.."' already exists in the Society.")
		end

		switch(data, "strategy"):caseof{
			probability = function()
				verifyUnnecessaryArguments(data, {"strategy", "probability", "name", "inmemory", "symmetric"})

				mandatoryTableArgument(data, "probability", "number")
				defaultTableValue(data, "symmetric", false)

				if data.probability <= 0 or data.probability > 1 then
					incompatibleValueError("probability", "a number between 0 and 1", data.probability)
				end

				data.mfunc = getSocialNetworkByProbability
			end,
			["function"] = function()
				verifyUnnecessaryArguments(data, {"strategy", "filter", "name", "inmemory"})

				mandatoryTableArgument(data, "filter", "function")

				data.mfunc = getSocialNetworkByFunction
			end,
			cell = function()
				verifyUnnecessaryArguments(data, {"strategy", "self", "name", "placement", "inmemory"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "placement", "placement")

				if self.agents[1][data.placement] == nil or self.agents[1][data.placement].cells[1] == nil then
					if data.placement == "placement" then
						customError("Society has no placement. Please call Environment:createPlacement() first.")
					else
						customError("Placement '"..data.placement.."' does not exist. Please call Environment:createPlacement() first.")
					end
				end

				data.mfunc = getSocialNetworkByCell
			end,
			neighbor = function()
				verifyUnnecessaryArguments(data, {"strategy", "neighborhood", "name", "placement", "inmemory"})

				defaultTableValue(data, "neighborhood", "1")
				defaultTableValue(data, "placement", "placement")

				if self.agents[1][data.placement] == nil or self.agents[1][data.placement].cells[1] == nil then
					if data.placement == "placement" then
						customError("Society has no placement. Please call Environment:createPlacement() first.")
					else
						customError("Placement '"..data.placement.."' does not exist. Please call Environment:createPlacement() first.")
					end
				elseif self.agents[1].placement.cells[1]:getNeighborhood(data.neighborhood) == nil then
					if data.neighborhood == "1" then
						customError("CellularSpace has no Neighborhood. Please call CellularSpace:createNeighborhood() first.")
					else
						customError("CellularSpace has no Neighborhood named '"..data.neighborhood.."'. Please call CellularSpace:createNeighborhood() first.")
					end
				end

				data.mfunc = getSocialNetworkByNeighbor
			end,
			quantity = function()
				verifyUnnecessaryArguments(data, {"strategy", "quantity", "name", "inmemory", "symmetric"})

				defaultTableValue(data, "quantity", 1)
				defaultTableValue(data, "symmetric", false)

				if data.quantity > #self then
					local merror = "It is not possible to connect such amount of agents ("..data.quantity.."). "..
						"The Society only has "..#self.." agents."
					customError(merror)
				elseif data.quantity > #self * 0.9 then
					customWarning("Connecting more than 90% of the Agents randomly might take too much time.")
				end

				integerTableArgument(data, "quantity")
				positiveTableArgument(data, "quantity")

				data.mfunc = getSocialNetworkByQuantity
			end,
			erdos = function()
				verifyUnnecessaryArguments(data, {"strategy", "name", "quantity"})

				mandatoryTableArgument(data, "quantity", "number")
				integerTableArgument(data, "quantity")
				positiveTableArgument(data, "quantity")

				local name = data.name
				if name == "1" then name = nil end
				self:createSocialNetwork{strategy = "void", name = name}

				for _ = 1, data.quantity do
					local ag1 = self:sample()
					local ag2 = ag1

					while ag2 == ag1 or ag2:getSocialNetwork(data.name):isConnection(ag1) do
						ag2 = self:sample()
					end

					ag1:getSocialNetwork(data.name):add(ag2, 1)
					ag2:getSocialNetwork(data.name):add(ag1, 1)
				end
			end,
			barabasi = function()
				verifyUnnecessaryArguments(data, {"strategy", "start", "name", "quantity"})

				mandatoryTableArgument(data, "start", "number")
				integerTableArgument(data, "start")
				positiveTableArgument(data, "start")

				mandatoryTableArgument(data, "quantity", "number")
				integerTableArgument(data, "quantity")
				positiveTableArgument(data, "quantity")

				verify(data.start < #self, "Argument 'start' should be less than the total of Agents in the Society.")
				verify(data.quantity < data.start, "Argument 'quantity' should be less than 'start'.")

				local name = data.name
				if name == "1" then name = nil end
				self:createSocialNetwork{strategy = "void", name = name}

				local count = data.start

				for i = data.start + 1, #self do
					local agent = self.agents[i]
					local sn = agent:getSocialNetwork(data.name)

					while #sn < data.quantity do
						local value = Random():integer(1, count)
						local position = 0

						while value > 0 do
							position = position + 1
							value = value - #self.agents[position]:getSocialNetwork(data.name) - 1
						end

						local candidate = self.agents[position]

						if not sn:isConnection(candidate) then
							candidate:getSocialNetwork(data.name):add(agent)
							sn:add(candidate)
							count = count + 1
						end
					end

					count = count + data.quantity + 1
				end
			end,
			watts = function()
				verifyUnnecessaryArguments(data, {"strategy", "name", "quantity", "probability"})

				mandatoryTableArgument(data, "quantity", "number")
				integerTableArgument(data, "quantity")
				positiveTableArgument(data, "quantity")

				mandatoryTableArgument(data, "probability", "number")
				verify(data.probability >= 0 and data.probability <= 1, "Argument 'probability' should be between 0 and 1.")

				local name = data.name
				if name == "1" then name = nil end
				self:createSocialNetwork{strategy = "void", name = name}

				for i = 1, #self do
					local ag1 = self.agents[i]
					local sn = ag1:getSocialNetwork(data.name)
					local ag2

					for dist = 1, data.quantity do
						if Random():number() < data.probability then
							ag2 = ag1
						else
							ag2 = self.agents[((i - 1 + dist) % #self) + 1]
						end

						while ag2 == ag1 or sn:isConnection(ag2) do
							ag2 = self:sample()
						end

						ag2:getSocialNetwork(data.name):add(ag1)
						sn:add(ag2)
					end
				end
			end,
			void = function()
				verifyUnnecessaryArguments(data, {"strategy", "name"})

				data.mfunc = getEmptySocialNetwork
				data.inmemory = true
			end
		}

		if not data.mfunc then return end

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

		if data.symmetric then
			forEachAgent(self, function(agent)
				forEachConnection(agent, name, function(magent, connection)
					local sn = connection:getSocialNetwork(name)

					if not sn:isConnection(magent) then
						sn:add(magent)
					end
				end)
			end)
		end
	end,
	--- Return a given Agent based on its position.
	-- @arg position The position of the Agent that will be returned. It can be a number
	-- (with the position of the Agent in the vector of Agents) or a string (with the
	-- id of the Agent).
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- agent = soc:get("1")
	-- print(agent.id)
	get = function(self, position)
		if type(position) == "string" then
			if not self.idindex or not self.idindex[position] then
				self.idindex = {}
				forEachAgent(self, function(agent)
					self.idindex[agent.id] = agent
				end)
			end

			local result = self.idindex[position]
			if not result then
				customError("Agent '"..position.."' does not belong to the Society.")
			end
			return result
		end

		mandatoryArgument(1, "number", position)

		integerArgument(1, position)
		positiveArgument(1, position)

		return self.agents[position]
	end,
	--- Return a given Agent based on its position.
	-- @deprecated Society:get
	getAgent = function()
		deprecatedFunction("getAgent", "get")
	end,
	--- Return a vector with the Agents of the Society.
	-- @deprecated Society.agents
	getAgents = function()
		deprecatedFunction("getAgents", ".agents")
	end,
	--- Notify all the Agents of the Society.
	-- @arg modelTime A positive number representing the notification time. The default value is 0.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- soc:notify()
	-- soc:add()
	-- soc:add()
	-- soc:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 0
		elseif type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		else
			optionalArgument(1, "number", modelTime)
			positiveArgument(1, modelTime, true)
		end

		if self.obsattrs_ then
			forEachElement(self.obsattrs_, function(idx)
				if idx == "quantity_" then
					self.quantity_ = #self
				else
					if type(self[idx]) ~= "function" then
						customError("Could not execute function '"..idx.."' from Society because it was replaced by a '"..type(self[idx]).."'.")
					end

					self[idx.."_"] = self[idx](self)
				end
			end)
		end

		forEachAgent(self, function(agent)
			agent:notify(modelTime)
		end)

		self.cObj_:notify(modelTime)
	end,
	--- Remove a given Agent from the Society.
	-- @arg arg The Agent that will be removed, or a function that takes an Agent as argument and
	-- returns true if the Agent must be removed.
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- print(#soc)
	-- soc:remove(soc:sample())
	-- print(#soc)
	remove = function(self, arg)
		if type(arg) == "Agent" then
			for k, v in pairs(self.agents) do
				if v.id == arg.id and v == arg then
					table.remove(self.agents, k)

					return arg.cObj_:kill(-1)
				end
			end

			customError("Could not remove the Agent (id = '"..tostring(arg.id).."').")
		elseif type(arg) == "function" then
			for i = #self.agents, 1, -1  do
				if arg(self.agents[i]) == true then
					self:remove(self.agents[i])
				end
			end
		else
			incompatibleTypeError(1, "Agent or function", arg)
		end
	end,
	--- Return a random Agent from the Society.
	-- @usage agent = Agent{}
	-- soc = Society{
	--     instance = agent,
	--     quantity = 10
	-- }
	--
	-- sample = soc:sample()
	sample = function(self)
		return self.agents[Random():integer(1, #self.agents)]
	end,
	--- Return the number of Agents in the Society.
	-- @deprecated Society:#
	size = function()
		deprecatedFunction("size", "operator #")
	end,
	--- Split the Society into a set of Groups according to a classification strategy. The
	-- Groups will have empty intersection and union equal to the whole
	-- Society (unless function below returns nil for some Agent). It works according
	-- to the type of its only and compulsory argument.
	-- @arg argument A string or a function, working as follows:
	-- @tabular argument
	-- Type of argument &
	-- Description \
	-- string &
	-- The argument must represent the name of one attribute of the Agents of the Society. Split
	-- then creates one Group for each possible value of the attribute using the value as name
	-- and fills them with the Agents that have the respective attribute value. If the Society
	-- has an instance and the respective attribute in the instance is a Random value with discrete
	-- or categorical strategy, it will use the possible values to create Groups, which means
	-- that the returning Groups can have size zero in this case. \
	-- function &
	-- The argument is a function that gets an Agent as argument and returns a
	-- name for the Agent, which can be a number, string, or boolean value.
	-- Groups are then named according to the returning value.
	--
	-- @usage ag = Agent{
	--     gender = Random{"male", "female"},
	--     age = Random{min = 1, max = 80, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 50
	-- }
	--
	-- groups = soc:split("gender")
	-- print(#groups.male) -- can be zero because it comes from an instance
	-- print(#groups.female) -- also
	--
	-- groups2 = soc:split(function(ag)
	--     if ag.age > 60 then
	--         return "old"
	--     else
	--         return "notold"
	--     end
	-- end)
	--
	-- if groups2.old then -- might not exist as it does not come from an instance
	--     print(#groups2.old)
	-- end
	split = function(self, argument)
		if type(argument) ~= "function" and type(argument) ~= "string" then
			if argument == nil then
				mandatoryArgumentError(1)
			else
				incompatibleTypeError(1, "string or function", argument)
			end
		end

		local result = {}
		local class_

		if type(argument) == "string" then
			if self:sample()[argument] == nil then
				customError("Attribute '"..argument.."' does not exist.")
			end

			if self.instance and type(self.instance[argument]) == "Random" and self.instance[argument].values then
				forEachElement(self.instance[argument].values, function(_, value)
					 result[value] = Group{target = self, build = false}
				end)
			end

			local value = argument
			argument = function(agent)
				return agent[value]
			end
		end

		forEachAgent(self, function(agent)
			class_ = argument(agent)

			if result[class_] == nil then
				result[class_] = Group{
					target = self,
					build = false
				}
			end

			table.insert(result[class_].agents, agent)
		end)

		return result
	end,
	--- Deliver asynchronous messages sent by Agents belonging to the Society.
	-- @arg delay A number indicating the current delay to be delivered. Messages with delay less
	-- or equal this value are sent, while the others have their delays reduced by this value.
	-- The default value is one.
	-- @usage nonFooAgent = Agent{
	--     received = 0,
	--     on_message = function(self)
	--         self.received = self.received + 1
	--     end
	-- }
	--
	-- soc = Society{
	--     instance = nonFooAgent,
	--     quantity = 15
	-- }
	--
	-- soc:createSocialNetwork{quantity = 5}
	--
	-- forEachAgent(soc, function(agent)
	--     forEachConnection(agent, function(self, friend)
	--         self:message{receiver = friend, delay = 5}
	--     end)
	-- end)
	--
	-- otheragent = soc:sample()
	-- print(otheragent.received)
	-- soc:synchronize(4)
	-- print(otheragent.received)
	-- soc:synchronize(2)
	-- print(otheragent.received)
	synchronize = function(self, delay)
		optionalArgument(1, "number", delay)

		if delay == nil then
			delay = 1
		else
			positiveArgument(1, delay)
		end

		local k = 1
		for _ = 1, getn(self.messages) do
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
	--- Return the number of Agents in the Society.
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 2
	-- }
	--
	-- print(#soc)
	__len = function(self)
		return #self.agents
	end,
	__tostring = _Gtme.tostring
}

--- Type to create and manipulate a set of Agents. Each Agent within a Society has a
-- unique id, which is initialized while creating the Society. There are different ways to
-- create a Society. See the argument source for the options.
-- Calling Utils:forEachAgent() traverses Societies.
-- @arg data.file A File or a string with the name of the file where data related to the
-- Agents is stored.
-- @arg data.source A string with the name of the source the Society will be read from.
-- TerraME always converts this string to lower case. See the table below:
-- @tabular source
-- source & Description & Compulsory arguments & Optional arguments \
-- "volatile" & Create agents from scratch. This is the default value when using the argument
-- quantity. & quantity, instance & ...\
-- "shp" & Load agents from a shapefile. & file, instance &  ... \
-- "csv" & Load agents from a csv file. This is the default value when value of argument
-- database ends with ".csv". & file, id, instance & sep, ...
-- @arg data.id The unique identifier attribute used when reading the Society from a file.
-- @arg data.... Any other attribute or function for the Society.
-- @arg data.instance An Agent with the description of attributes and functions. When using this
-- argument, each Agent of the Society will have attributes and functions according to the
-- instance. The attributes of the instance will be copyed to the Agent and Society
-- calls Agent:init() for each of its Agents.
-- Every attribute from the Agent that is a Random will be converted into a Random:sample().
-- When using this argument, additional functions are also
-- created to the Society. For each attribute of the its Agents (after calling Agent:init()),
-- one function is created in the Society with the same name. The table below describes how each
-- attribute is mapped from the Agent to the Society:
-- @tabular instance
-- Type of attribute & Function within the Society \
-- function & Call the function of each of its Agents. \
-- number & Return the sum of the number in each of its Agents. \
-- boolean & Return the quantity of true values in its Agents. \
-- string & Return a table with positions equal to the unique strings and values equal to the
-- number of occurrences in each of its Agents.
-- @arg data.sep A string with the file separator for reading a CSV (default is ",").
-- @arg data.quantity Number of Agents to be created. It is used when the Society will not be
-- loaded from a file or database.
-- @output agents A vector of Agents pointed by the Society.
-- @output instance The Agent that describes attributes and functions of each Agent belonging to
-- the Society. This Agent must not be executed.
-- @output autoincrement unique identifier used to represent the last Agent added to the Society.
-- The next Agent will have 'autoincrement + 1' as id.
-- @output messages A vector that contains the delayed messages.
-- @output parent The Environment it belongs.
-- @output cObj_ A pointer to a C++ representation of the Society. Never use this object.
-- @output placements A vector with the names of the placements created using this object (see
-- Environment:createPlacement()).
-- @usage instance = Agent{
--     execute = function() end,
--     run = function() end,
--     age = Random{min = 1, max = 50, step = 1}
-- }
--
-- s = Society{
--     instance = instance,
--     quantity = 20
-- }
--
-- s:execute() -- call execute for each agent
-- s:run() -- call run for each agent
-- print(s:age()) -- sum of the ages of each agent
-- print(#s)
--
-- instance = Agent{
--     execute = function() end
-- }
--
-- s = Society{
--     instance = instance,
--     file = filePath("agents.csv", "base")
-- }
--
-- print(#s)
function Society(data)
	verifyNamedTable(data)

	data.cObj_ = TeSociety()
	data.agents = {}
	data.messages = {}
	data.autoincrement = 1
	data.placements = {}

	setmetatable(data, metaTableSociety_)
	data.cObj_:setReference(data)

	mandatoryTableArgument(data, "instance", "Agent")

	if data.instance.isinstance then
		customError("The same instance cannot be used by two Societies.")
	end

	if data.instance.id ~= nil then
		customError("Argument 'instance' should not have attribute 'id'.")
	end

	if data.instance.parent ~= nil then
		customError("Argument 'instance' should not have attribute 'parent'.")
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
					return forEachAgent(soc, function(magent)
						if type(magent[attribute]) ~= "function" then
							incompatibleTypeError(attribute, "function", magent[attribute])
						end

						return magent[attribute](magent, args)
					end)
				end
			elseif mtype == "number" or (mtype == "Random" and value.distrib ~= "categorical" and (value.distrib ~= "discrete" or type(value[1]) == "number")) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(soc)
					local quantity = 0
					forEachAgent(soc, function(magent)
						if type(magent[attribute]) ~= "number" then
							incompatibleTypeError(attribute, "number", magent[attribute])
						end

						quantity = quantity + magent[attribute]
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
					forEachAgent(soc, function(magent)
						if magent[attribute] then
							quantity = quantity + 1
						end
					end)
					return quantity
				end
			elseif mtype == "string" or (mtype == "Random" and (value.distrib == "categorical" or (value.distrib == "discrete" and type(value[1]) == "string"))) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(soc)
					local result = {}
					forEachAgent(soc, function(magent)
						local mvalue = magent[attribute]
						if result[mvalue] then
							result[mvalue] = result[mvalue] + 1
						else
							result[mvalue] = 1
						end
					end)
					return result
				end
			end
		end)
	end

	if type(data.file) == "string" then
		data.file = File(data.file)
	end

	if type(data.file) == "File" then
		if data.file:extension() == "csv" then
			if data.sep and type(data.sep) ~= "string" then
				incompatibleTypeError("sep", "string", data.sep)
			end

			local csv = data.file:readTable(data.sep)
			for i = 1, #csv do
				data:add(csv[i])
			end
		else
			local tlib = terralib.TerraLib{}
			local dSet = tlib:getOGRByFilePath(tostring(data.file))

			for i = 0, #dSet do
				data:add(dSet[i])
			end
		end
	else
		mandatoryTableArgument(data, "quantity", "number")
		integerTableArgument(data, "quantity")
		positiveTableArgument(data, "quantity", true)

		local quantity = data.quantity
		for _ = 1, quantity do
			data:add{}
		end
	end

	if not (data.quantity and data.quantity == 0) then
		local newAttTable = {}
		forEachElement(data.agents[1], function(idx, value)
			if data.instance[idx] == nil then
				newAttTable[idx] = value
			end
		end)

		createSummaryFunctions(newAttTable)

		local mt = getmetatable(data.instance)
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

		setmetatable(data.instance, mt)
	end

	data.quantity = nil
	local metaTableInstance = {__index = data.instance, __tostring = _Gtme.tostring}

	data.instance.type_ = "Agent"
	data.instance.isinstance = true

	forEachAgent(data, function(agent)
		setmetatable(agent, metaTableInstance)
	end)

	return data
end

