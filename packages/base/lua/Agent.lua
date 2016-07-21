-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

local deadAgentMetaTable_ = {__index = function()
	customError("Trying to use a function or an attribute of a dead Agent.")
end}

Agent_ = {
	type_ = "Agent",
	--- Add a Trajectory or a State to the Agent.
	-- @arg object A State or a Trajectory.
	-- @usage ag = Agent{}
	-- cs = CellularSpace{xdim = 5}
	-- traj = Trajectory{target = cs}
	--
	-- ag:add(traj)
	add = function(self, object)
		local t = type(object)
		if t == "Trajectory" or t == "State" then
			self.cObj_:add(object.cObj_)
		else
			incompatibleTypeError(1, "State or Trajectory", object)
		end
	end,
	--- Add a SocialNetwork to the Agent. This function replaces previous SocialNetwork with the
	-- same id (if it exists) without showing any warning message.
	-- @arg set A SocialNetwork.
	-- @arg id Name of the relation. The default value is "1".
	-- @usage agent = Agent{}
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 30
	-- }
	--
	-- agent = soc:sample()
	-- friend1 = soc:sample()
	-- friend2 = soc:sample()
	--
	-- sn = SocialNetwork()
	-- sn:add(friend1)
	-- sn:add(friend2)
	-- agent:addSocialNetwork(sn)
	-- @see Utils:forEachConnection
	addSocialNetwork = function(self, set, id)
		if type(set) ~= "SocialNetwork" and type(set) ~= "function" then
			if set == nil then
				mandatoryArgumentError(1)
			else
				incompatibleTypeError(1, "SocialNetwork", set)
			end
		end

		optionalArgument(2, "string", id)
		if id == nil then id = "1" end

		self.socialnetworks[id] = set
	end,
	--- Kill the agent and remove it from the Society it belongs. It also
	-- removes any basic placements from the agents (those used by Agent:enter(), Agent:leave(),
	-- and Agent:move()). After executing this function, it will not be possible to call any
	-- function from the Agent anymore. Therefore, if there is any complex placement in the model,
	-- it should be removed manually before calling this function.
	-- @usage agent = Agent{
	--     execute = function(self)
	--         if self.energy <= 0 then
	--             agent:die()
	--         end
	--     end
	-- }
	die = function(self)
		self.execute = function() customWarning("Trying to execute a dead agent.") end

		-- remove all the possible ways of getting delayed messages
		forEachElement(self, function(idx, _, mtype)
			if mtype == "function" and idx:sub(1, 3) == "on_" then
				self[idx] = function()
					customWarning("Trying to send a message to a dead Agent.")
				end
			end
		end)

		if self.parent then
			forEachElement(self.parent.placements, function(placement)
				if #self[placement].cells > 0 then
					self:leave(placement)
				end
			end)

			self.parent:remove(self)
		end

		setmetatable(self, deadAgentMetaTable_)
	end,
	--- Put the Agent into a Cell. This function supposes that each Agent can be in one and
	-- only one Cell along the simulation. If the Agent is already inside of a
	-- Cell, use Agent:move() instead. The agent needs to have a placement to be able to
	-- use Agent:enter(), Agent:leave(), Agent:move(), or Agent:walk().
	-- @arg cell A Cell.
	-- @arg placement A string representing the name of the placement to be used.
	-- The default value is "placement".
	-- @usage soc = Society{
	--     instance = Agent{},
	--     quantity = 30
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- env = Environment{soc, cs}
	-- env:createPlacement{strategy = "void"}
	-- 
	-- agent = soc:sample()
	-- agent:enter(cs:sample())
	-- @see Environment:createPlacement
	enter = function(self, cell, placement)
		mandatoryArgument(1, "Cell", cell)

		optionalArgument(2, "string", placement)
		if placement == nil then placement = "placement" end

		if self[placement] then 
			if self[placement].cells[1] then
				customWarning("Agent is already inside of a Cell. Use Agent:move() instead.")
			end
			self[placement].cells[1] = cell
			self.cell = cell
		else
			customError("Placement '"..placement.."' was not found in the Agent.")
		end

		if cell[placement] then
			cell[placement]:add(self)
		else
			customError("Placement '"..placement.."' was not found in the Cell.")
		end
	end,
	--- The entry point for executing a given Agent. When the Agent is not defined as a
    -- composition of States, it is an user-defined function to describe
    -- the behavior of an Agent.When the Agent is described as a State
	-- machine, execute is automatically defined by TerraME. It activates the Jump of the
	-- current State while it jumps from State to State. After that, it executes all the Flows
	-- of the current State. Usually, this function is called within an Event, thus the time
	-- of the Event can be got directly from the Timer.
	-- @arg event An Event.
	-- @usage agent = Agent{
	--     size = 5,
	--     execute = function(self)
	--         self.size = self.size + 1
	--     end
	-- }
	--
	-- agent:execute()
	execute = function(self, event)
		mandatoryArgument(1, "Event", event)

		local cObj = TeEvent()
		cObj:config(event.time, event.period, event.priority)
		cObj:setReference(event)

		self.cObj_:execute(cObj)
	end,
	--- Return the Cell where the Agent is located according to its placement. It assumes
	-- that each Agent belongs to at most one Cell.
	-- @arg placement A string representing the name of the placement to be used.
	-- The default value is "placement".
	-- @usage soc = Society{
	--     instance = Agent{},
	--     quantity = 30
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- env = Environment{soc, cs}
	-- env:createPlacement{}
	-- 
	-- agent = soc:sample()
	-- cell = agent:getCell()
	getCell = function(self, placement)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		if type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end
		return self[placement].cells[1]
	end,
	--- Return a vector with the Cells pointed by the Agent.
	-- @arg placement A string representing the name of the placement to be used.
	-- The default value is "placement".
	-- @usage soc = Society{
	--     instance = Agent{},
	--     quantity = 30
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- env = Environment{soc, cs}
	-- env:createPlacement{}
	-- 
	-- agent = soc:sample()
	--
	-- cell = agent:getCells()[1]
	getCells = function(self, placement)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		if type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end

		return self[placement].cells
	end,
	--- Return the unique identifier of the Agent.
	-- @usage -- id = agent:getId()
	-- @deprecated Agent.id
	getId = function()
		deprecatedFunction("getId", ".id")
	end,
	--- Return the time when the State machine executed the transition to the current state.
	-- Before executing for the first time, the latency is zero.
	-- This function is useful only when the Agent is described as a State machine.
	-- @usage -- latency = agent:getLatency()
	getLatency = function(self)
		return self.cObj_:getLatency()
	end,
	--- Return a SocialNetwork of the Agent given its name.
	-- @arg name Name of the SocialNetwork.
	-- @usage agent = Agent{}
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 100
	-- }
	--
	-- soc:createSocialNetwork{probability = 0.5, name = "friends"}
	-- ag = soc:sample()
	-- ag:getSocialNetwork("friends")
	-- @see Society:createSocialNetwork
	-- @see Utils:forEachConnection
	getSocialNetwork = function(self, name)
		optionalArgument(1, "string", name)
		if name == nil then name = "1" end

		local s = self.socialnetworks[name]
		if type(s) == "function" then
			s = s(self)
		end

		return s
	end,
	--- Return a string with the current State name. This function is useful only when the
	-- Agent is described as a state machine.
	-- @usage -- DONTRUN
	-- name = agent:getStateName()
	getStateName = function(self)
		return self.cObj_:getControlModeName()
	end,
	--- Return the status of the Trajectories of the Agent. 
	-- This function is useful only when the Agent is described as a State machine.
	-- @see Agent:setTrajectoryStatus
	-- @usage -- DONTRUN
	-- agent:getTrajectoryStatus()
	getTrajectoryStatus = function(self)
		return self.cObj_:getActionRegionStatus()
	end,
	--- User-defined function that is used to initialize an Agent when it enters in a
	-- given Society (e.g. when the Society is created, or when one calls Society:add()).
	-- @usage agent = Agent{
	--     age = Random{min = 1, max  = 50, step = 1},
	--     init = function(self)
	--         if self.age > 40 then
	--             self.wealth = Random():integer(50, 100)
	--         else
	--             self.wealth = Random():integer(5, 10)
	--         end
	--     end
	-- }
	-- 
	-- soc = Society{
	--     instance = agent,
	--     quantity = 10
	-- }
	--
	-- print(soc:sample().age)
	-- @see Random
	init = function() -- virtual function that might be implemented by the modeler
	end,
	--- Remove the Agent from its current Cell. If the Agent does not belong to any Cell then it will
	-- stop with an error. This function supposes that each Agent can be in one and
    -- only one Cell along the simulation. The Agent needs to have a placement to be
	-- able to use Agent:enter(), Agent:leave(), Agent:move(), and Agent:walk().
	-- @arg placement A string representing the name of the placement to be used.
	-- The default value is "placement".
	-- @usage ag1 = Agent{}
	-- cs = CellularSpace{xdim = 3}
	-- myEnv = Environment{cs, ag1}
	-- myEnv:createPlacement()
	-- ag1:leave()
	-- @see Environment:createPlacement
	leave = function(self, placement)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		if self[placement] == nil then
			valueNotFoundError(1, placement)
		elseif type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end

		local cell = self[placement].cells[1]

		if cell == nil then
			customError("Agent should belong to a Cell in order to leave().")
		end

		self[placement].cells[1] = nil
		self.cell = nil

		local ags = cell[placement].agents

		if getn(ags) == 0 then
			return true
		end

		for i = 1, #ags do
			if self.id == ags[i].id and self.parent == ags[i].parent then
				table.remove(ags, i)
				return true
			end
		end
	end,
	--- Send a message to another Agent. The receiver will get a message as a table through its
	-- Agent:on_message() (as default). Messages can arrive exactly after they are sent
	-- (synchronous) or have some delay (asynchronous). In the latter case, it is necessary to
	-- call function Society:synchronize() from the Society they belong to deliver the messages.
	-- @arg data.receiver The Agent that will get the message.
	-- @arg data.subject A string describing the function that will be called in the receiver.
	-- Given a string x, the receiver will get the message in a function called on_x. The default
	-- value is "message". The function to receive the message must be implemented by the
	-- modeler. See Agent:on_message() for more details.
	-- @arg data.delay A number indicating temporal delay before activating this message.
	-- The efault value is zero (no delay, no synchronization required).
	-- Whenever a delayed message is received, it comes with an attribute delay equals to true.
	-- @arg data.... Other arguments are allowed to this function, as the message is a table.
	-- The receiver will get all the attributes sent plus an attribute called sender. 
	-- @usage agent1 = Agent{
	--     on_message = function(self, message)
	--         print("Got money:"..message.quantity)
	--     end
	-- }
	--
	-- agent2 = Agent{}
	--
	-- agent2:message{
	--     receiver = agent1,
	--     content = "money",
	--     quantity = 20
	-- }
	message = function(self, data)
		verifyNamedTable(data)

		data.sender = self
		mandatoryTableArgument(data, "receiver", "Agent")

		defaultTableValue(data, "delay", 0)
		positiveTableArgument(data, "delay", true)

		if data.delay > 0 then
			verify(type(self.parent) == "Society", "Agent must be within a Society to send messages with delay.")
		end

		if data.delay == 0 then
			if data.subject then
				if type(data.subject) ~= "string" then
					incompatibleTypeError("subject", "string", data.subject)
				end
				local call = "on_"..data.subject
				if type(data.receiver[call]) ~= "function" then
					customError("Receiver (id = '".. data.receiver.id .."') does not implement function "..call ..".")
				else
					return data.receiver[call](data.receiver, data)
				end
			else
				return data.receiver:on_message(data)
			end
		else
			table.insert(self.parent.messages, data)
		end
	end,
	--- Move the Agent to a new Cell. This function supposes that each Agent can be in one and
    -- only one Cell along the simulation. The agent needs to have a placement to be able to use
	-- Agent:enter(), Agent:leave(), Agent:move(), or Agent:walk().
	-- @arg newcell The new Cell.
	-- @arg placement A string representing the placement to be used. The default
	-- value is "placement".
	-- @usage ag1 = Agent{}
	-- cs = CellularSpace{xdim = 3}
	-- soc = Society{
	--     instance = ag1,
	--     quantity = 5
	-- }
	--
	-- myEnv = Environment{cs, ag1}
	-- myEnv:createPlacement()
	--
	-- ag = soc:sample()
	-- cell = cs:sample()
	-- ag:move(cell)
	-- @see Environment:createPlacement
	move = function(self, newcell, placement)
		mandatoryArgument(1, "Cell", newcell)
		optionalArgument(2, "string", placement)

		if placement == nil then placement = "placement" end

		if self[placement] == nil then
			valueNotFoundError(2, placement)
		elseif not self[placement].cells[1] then 
			customError("Agent should belong to a Cell in order to move().")
		end

		self:leave(placement)
		self:enter(newcell, placement)
	end,
	--- Notify the Observers of the Agent.
	-- @arg modelTime A number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage agent = Agent{
	--     value = 1
	-- }
	--
	-- Chart{target = agent}
	-- agent:notify(1)
	-- agent:notify(2)
	notify = function(self, modelTime)
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
				if type(self[idx]) ~= "function" then
					customError("Could not execute function '"..idx.."' from Agent because it was replaced by a '"..type(self[idx]).."'.")
				end

				self[idx.."_"] = self[idx](self)
			end)
		end

		self.cObj_:notify(modelTime)
	end,
	--- User-defined function that can be implemented to allow Agents to exchange messages.
	-- It is executed every time a receiver gets a message.
	-- The received message has the same content of the
	-- sent message, plus an attribute called sender with the Agent that
	-- sent the message. In the case of non-delayed messages, the returning value
	-- of this function (executed by the receiver) is also returned as the result
	-- of message (executed by the sender). Note that, although in the description
	-- below on_message has only one argument, the signature has two arguments,
	-- the first one being the agent itself. This function is usually called internally by
	-- TerraME, as result of calls of Agent:message() by the modeler. Other
	-- functions on_ can be defined by the modeler, and will be called by
	-- TerraME according to the subject of the message.
	-- @see Agent:message
	-- @see Society:synchronize
	-- @usage agent = Agent{
	--     money = 0,
	--     on_message = function(self, message)
	--         self.money = self.money + message.quantity
	--         self:message{receiver = message.sender, subject = "thanks"}
	--     end,
	--     on_thanks = function(self, message)
	--         print("thanks")
	--         self:message{receiver = message.sender, subject = "yourewelcome"}
	--     end,
	--     on_yourewelcome = function()
	--         print("yourewelcome")
	--     end
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 10
	-- }
	--
	-- soc:sample():message{
	--     receiver = soc:sample(),
	--     quantity = 20
	-- }
	-- @arg message A table with the received message. It has an attribute called sender with
	-- the Agent that sent the message.
	on_message = function(self, message)
		customError("Agent '"..tostring(self.id).."' cannot get a message from '"..tostring(message.sender.id).."' because it does not implement 'on_message'.")
	end,
	--- Execute a random walk to a neighbor Cell.
	-- @deprecated Agent:walk
	randomWalk = function()
		deprecatedFunction("randomWalk", "walk")
	end,
	--- Create an Agent with the same behavior in the same Cell where the original Agent is
	-- (according to its placement). The new Agent is pushed into the same Society the original
	-- Agent belongs and placements created using the Society are instantiated with size zero if
	-- the only argument of reproduce does not contain such placements. This function returns
	-- the new Agent.
	-- @arg data An optional table with attributes of the new Agent.
	-- If this table do not contay some of the placements registered in its Society,
	-- then they are instantiated and the newborn will be placed in the same Cell of its
	-- parent. This functionality supposes that an Agent can be in one and only one Cell
	-- for each placement along the simulation.
	-- @usage agent = Agent{}
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 100
	-- }
	--
	-- soc.agents[1]:reproduce()
	-- print(#soc)
	reproduce = function(self, data)
		verify(type(self.parent) == "Society", "Agent should belong to a Society to be able to reproduce.")

		if type(data) ~= "table" then
			if data == nil then
				data = {}
			else
				verifyNamedTable(data)
			end
		end
		local ag = self.parent:add(data)

		if self.placement ~= nil then
			forEachElement(self.parent.placements, function(idx)
				if idx == "placement" then
					ag:enter(self:getCell())
				else
					ag:enter(self:getCell(idx), idx)
				end
			end)
		end
		return ag
	end,
	--- Return a random Agent from a SocialNetwork of the Agent.
	-- @arg id A string with the name of the SocialNetwork. The default value is "1".
	-- @see Agent:getSocialNetwork
	-- @usage ag = Agent{}
	-- soc = Society{instance = ag, quantity = 5}
	--
	-- sn = SocialNetwork()
	-- forEachAgent(soc, function(agent)
	--     sn:add(agent)
	-- end)
	--
	-- ag:addSocialNetwork(sn)
	-- friend = ag:sample()
	sample = function(self, id)
		optionalArgument(1, "string", id)
		if id == nil then id = "1" end

		local sn = self:getSocialNetwork(id)

		verify(sn, "Agent does not have a SocialNetwork named '"..id.."'.")

		return sn:sample()
	end,
	--- Set the unique identifier of the Agent.
	-- @deprecated Agent.id
	setId = function()
		deprecatedFunction("setId", ".id")
	end,
	--- Activate or not the Trajectories defined for a given Agent.
	-- @arg status Use or not the Trajectories. As default, Trajectories are turned off. If
	-- status is true, when executed, the Agent that contains States will automatically
	-- traverse all trajectories defined within it, which means that Agent:execute() will
	-- be executed once for each of its Cells. This function is useful only when the
	-- Agent is described as a State machine.
	-- @usage -- agent:setTrajectoryStatus(true)
	setTrajectoryStatus = function(self, status)
		optionalArgument(1, "boolean", status)
		if status == nil then status = false end

		self.cObj_:setActionRegionStatus(status)
	end,
	--- Execute a random walk to a neighbor Cell. This function supposes that each Agent can be in
	-- one and only one Cell along the simulation. The Agent needs to have a placement to be
	-- able to use Agent:enter(), Agent:leave(), Agent:move(), and Agent:walk().
	-- @arg placement A string representing the placement to be used. The default value
	-- is "placement".
	-- @arg neighborhood A string representing the Neighborhood to be used.
	-- The default value is "1.
	-- @usage singleFooAgent = Agent{}
	--
	-- cs = CellularSpace{xdim = 10}
	-- cs:createNeighborhood()
	--
	-- e = Environment{cs, singleFooAgent}
	-- e:createPlacement()
	-- 
	-- singleFooAgent:walk()
	-- singleFooAgent:walk()
	-- @see Environment:createPlacement
	walk = function(self, placement, neighborhood)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		optionalArgument(2, "string", neighborhood)
		if neighborhood == nil then neighborhood = "1" end

		if type(self[placement]) ~= "Trajectory" then
			valueNotFoundError(1, placement)
		end

		local c1 = self:getCell(placement)
		local c2 = c1:getNeighborhood(neighborhood)
		if c2 == nil then
			valueNotFoundError(2, neighborhood)
		end
		self:move(c2:sample(), placement)
	end
}

metaTableAgent_ = {__index = Agent_, __tostring = _Gtme.tostring}

--- An autonomous entity that is capable of performing actions as well as interacting with other
-- Agents and the spatial representation of the model. The Agent constructor gets a table
-- containing the attributes and functions of the Agent. It can be described as a simple table
-- or as a hybrid State machine that has a unique internal state. When the Agent has a set of
-- States, the initial State will be the one declared first. When the agent does not have
-- States, there is a set of user-defined functions that have an associated semantics in TerraME.
-- An Agent can belong to a Society and can have SocialNetworks.
-- @arg data.id A string with the unique identifier of the Agent. Agents used as instance for
-- a Society cannot have id as the Society will create the ids for each of its Agents.
-- @arg data.init An optional function to be executed when the Agent enters in a Society.
-- See Agent:init().
-- @arg data.execute An optional function to describe the behavior of the agent each time step it is
-- executed. See Agent:execute().
-- @arg data.on_message An optional function describing the behavior of the agent when it receives a
-- message. See Agent:on_message().
-- @arg data.... Any other attribute or function for the Agent. It can have, for instance, other
-- "on_x" functions to get messages with subject "x" (see Agent:message()).
-- @output state_ An internal state for the Agent. Never use this object.
-- @output cObj_ A pointer to a C++ representation of the Agent. Never use this object.
-- @output cells A vector with the Cells representing the default placement of the Agent.
-- It is necessary to use Utils:forEachCell(). This value is the same of "agent.placement.cells".
-- @output id The unique identifier of the Agent. This attribute only exists when the agent belongs
-- to a Society.
-- @output parent The Society it belongs (if any).
-- @output placement A Trajectory representing the default placement of the Agent (only when a call to
-- Environment:createPlacement() use the Agent).
-- @output socialnetworks A set of SocialNetworks with the connections of the Agent.
-- This value only exists if the Agent has at least one SocialNetwork.
-- @usage singleFooAgent = Agent{
--     size = 10,
--     name = "foo",
--     execute = function(self)
--         self.size = self.size + 1
--         self:walk()
--     end,
--     on_hello = function(self, m)
--         self:message{
--             receiver = m.sender,
--             content = "hi"
--         }
--     end
-- }
function Agent(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			customError(tableArgumentMsg())
		end
	end

	setmetatable(data, metaTableAgent_)

	optionalTableArgument(data, "id", "string")

	local cObj = TeGlobalAutomaton()
	data.cObj_ = cObj
	cObj:setReference(data)

	for _, ud in pairs(data) do
		local t = type(ud)
		if t == "Trajectory" or t == "State" then cObj:add(ud.cObj_) end
	end

	cObj:build()
	data.socialnetworks = {}
	return data
end

