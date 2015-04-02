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
-- Authors: Tiago Garcia de Senna Carneiro
--          Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Reis Pereira
--#########################################################################################

local deadAgentMetaTable_ = {__index = function()
	customError("Trying to use a function or an attribute of a dead Agent.")
end}

Agent_ = {
	type_ = "Agent",
	--- Add a Trajectory or State to the Agent.
	-- @arg object A State or Trajectory.
	-- @usage agent:add(state)
	--
	-- agent:add(trajectory)
	add = function(self, object)
		--if type(object) == "State" or type(object) == "Trajectory" then
		-- State is being considered userdata!
		if type(object) == "userdata" or type(object) == "Trajectory" then
			self.cObj_:add(object)
		else
			incompatibleTypeError(1, "State or Trajectory", object)
		end
	end,
	--- Add a SocialNetwork to the Agent. This function replaces previous SocialNetwork with the
	-- same id (if it exists) without showing any warning message.
	-- @arg set A SocialNetwork.
	-- @arg id Name of the relation. Default is "1".
	-- @usage agent:addSocialNetwork(network)
	--
	-- agent:addSocialNetwork(network, "friends")
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
	--- Check if the state machine was correctly defined, verifying
	-- whether the targets of Jump rules match the ids of the States. It is
	-- useful only when the Agent is described as a state machine.
	-- @usage agent:build()
	build = function(self)
		self.cObj_:build()
	end,
	---Kill the agent and remove it from the Society it belongs. The methods execute() and
	-- on_message() of the Agent are set to do nothing.
	-- @arg remove_placements A boolean value indicating whether the 
	-- relations of the Agent should be removed. Default is true, but it 
	-- only works with simple placements, where one Agent is connected to 
	-- a single Cell in each placement. If more complex relations are used 
	-- in the model, then the modeler should set this argument as false
	-- and remove the relations by himself/herself.
	-- @usage agent:die()
	die = function(self, remove_placements)
		optionalArgument(1, "boolean", remove_placements)
		if remove_placements == nil then remove_placements = true end

		if remove_placements and not self.parent then
			customError("Cannot remove the placements of an Agent that does not belong to a Society.")
		end

		-- remove all the placements
		if remove_placements and self.parent then
			forEachElement(self.parent.placements, function(placement)
				self:leave(nil, placement)
			end)
		end
		self.execute = function() customWarning("Trying to execute a dead agent.") end
		-- remove all the possible ways of getting delayed messages
		forEachElement(self, function(idx, _, mtype)
			if mtype == "function" and idx:sub(1, 3) == "on_" then
				self[idx] = function()
					customWarning("Trying to send a message to a dead Agent.")
				end
			end
		end)
		self.on_message = function()
			customWarning("Trying to send a message to a dead Agent.")
		end
		self.parent:remove(self)
		setmetatable(self, deadAgentMetaTable_)
	end,
	--- Put the Agent into a Cell, using their placements. If the Agent is already inside of a
	-- Cell, use Agent:move() instead. The agent needs to have a placement to be able to
	-- use Agent:enter(), Agent:leave(), or Agent:move().
	-- @arg cell A Cell.
	-- @arg placement A string representing the index to be used. Default is "placement".
	-- @usage agent:enter(newcell)
	--
	-- agent:enter(newcell, "renting")
	-- @see Environment:createPlacement
	enter = function(self, cell, placement)
		mandatoryArgument(1, "Cell", cell)

		optionalArgument(2, "string", placement)
		if placement == nil then placement = "placement" end

		if self[placement] then 
			self[placement].cells[1] = cell
		else
			customError("Placement '"..placement.."' was not found in the Agent.")
		end
		if cell[placement] then
			cell[placement]:add(self)
		else
			customError("Placement '"..placement.."' was not found in the Cell.")
		end
		self.cell = cell
	end,
	--- The entry point for executing a given Agent. When the Agent is described as a state
	-- machine, execute is automatically defined by TerraME. It activates the Jump of the
	-- current State while it jumps from State to State. After that, it executes all the Flows
	-- of the current State. Usually, this function is called within an Event, thus the time
	-- of the Event can be got directly from the Timer. When the Agent is not defined as a
	-- composition of States, the modeler should follow a signature to describe this function.
	-- @arg event An Event.
	-- @usage agent:execute()
	--
	-- agent:execute(event)
	--
	-- singleFooAgent = Agent {
	-- execute = function(self)
	--     self.size = self.size + 1
	--     self:walk() 
	-- end}
	execute = function(self, event)
		mandatoryArgument(1, "Event", event)

		self.cObj_:execute(event)
	end,
	--- Return the Cell where the Agent is located according to its placement. It assumes
	-- that each Agent belongs to at most one Cell.
	-- @arg placement  A string representing the index to be used. Default is "placement".
	-- @usage cell = agent:getCell()
	getCell = function(self, placement)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		if type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end
		return self[placement].cells[1]		
	end,
	--- Return the Cells pointed by the Agent according to its placement.
	-- @arg placement A string representing the index to be used. Default is "placement".
	-- @usage cell = agent:getCells()[1]
	getCells = function(self, placement)
		optionalArgument(1, "string", placement)
		if placement == nil then placement = "placement" end

		if type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end

		return self[placement].cells
	end,
	--- Return the unique identifier of the Agent.
	-- @usage id = agent:getId()
	-- @deprecated Agent.id
	getId = function(self)
		deprecatedFunction("getId", ".id")
	end,
	--- Return the time when the machine executed the transition to the current state.
	-- Before executing for the first time, the latency is zero. 
	-- This function is useful only when the Agent is described as a state machine.
	-- @usage latency = agent:getLatency()
	getLatency = function(self)
		return self.cObj_:getLatency()
	end,
	--- Returns a SocialNetwork of the Agent given its name.
	-- @arg id Name of the relation.
	-- @usage net = agent:getSocialNetwork("friends")
	-- @see Society:createSocialNetwork
	getSocialNetwork = function(self, id)
		optionalArgument(1, "string", id)
		if id == nil then id = "1" end

		local s = self.socialnetworks[id] 
		if type(s) == "function" then
			s = s(self)
		end
		return s
	end,
	--- Returns a string with the current state name. This function is useful only when the
	-- Agent is described as a state machine.
	-- @usage name = agent:getStateName()
	getStateName = function(self)
		return self.cObj_:getControlModeName()
	end,
	--- Return the status of the Trajectories of the Agent. 
	-- This function is useful only when the Agent is described as a state machine.
	-- @see Agent:setTrajectoryStatus
	-- @usage agent:getTrajectoryStatus()
	getTrajectoryStatus = function(self)
		return self.cObj_:getActionRegionStatus()
	end,
	--- A user-defined function that is used to initialize an Agent when it enters in a given Society (e.g. by calling Society:add()).
	-- @usage agent = Agent{
	--     init = function(self)
	--         self.age = math.random(1, 10) -- initial age chosen randomly
	--         self.wealth = math.random(50, 100) -- initial wealth chosen randomly
	--     end
	-- }
	-- 
	-- soc = Society{
	--     instance = agent,
	--     quantity = 10
	-- }
	--
	-- print(soc:sample().age)
	init = function(self) -- virtual function that might be implemented by the modeler
	end,
	--- Remove the Agent from a given Cell. 
	--The agent needs to have a placement to be able to use Agent:enter(), Agent:leave(), or Agent:move().
	-- @arg cell A Cell. Default is the first (or the only) Cell of the placement.
	-- @arg placement A string representing the index to be used. Default is "placement".
	-- @see Environment:createPlacement
	-- @usage agent:leave()
	--
	-- agent:leave(cell)
	--
	-- agent:leave(cell, "renting")
	leave = function(self, cell, placement)
		optionalArgument(1, "Cell", cell)
		if cell == nil then cell = self[placement].cells[1] end

		optionalArgument(2, "string", placement)
		if placement == nil then placement = "placement" end

		if self[placement] == nil then
			valueNotFoundError(1, placement)
		elseif type(self[placement]) ~= "Trajectory" then
			customError("Placement '".. placement.. "' should be a Trajectory, got "..type(self[placement])..".")
		end

		self.cell = nil
		if self[placement] then
			self[placement].cells[1] = nil
		end

		if cell and cell[placement] then
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
		end
	end,
	--- Send a message to another Agent as a table. The receiver will get a message through its
	-- Agent:on_message(). Messages can arrive exactly after they are sent (synchronous) or have
	-- some delay (asynchronous). In the latter case, it is necessary to call function
	-- Society:synchronize() from the Society they belong to activate the messages.
	-- @arg data.receiver The Agent that will get the message.
	-- @arg data.subject A string describing the function that will be called in the receiver.
	-- Given a string x, the receiver will get the message in a function called on_x. Default is
	-- "message". The function to receive the message must be implemented by the modeler. See
	-- Agent:on_message() for more details.
	-- @arg data.delay An integer indicating the number of times synchronize needs to be called
	-- before activating this message. Default is zero (no delay, no synchronization required).
	-- Whenever a delayed message is received, it comes with the element delay = true.
	-- @arg data.... Other arguments are allowed to this function, as the message is a table.
	-- The receiver will get all the attributes sent plus a sender value. 
	-- @usage agent:message {
	--     receiver = agent2,
	--     delay = 2,
	--     content = "money",
	--     quantity = 20
	-- }
	message = function(self, data)
		verifyNamedTable(data)

		data.sender = self
		mandatoryTableArgument(data, "receiver", "Agent")

		defaultTableValue(data, "delay", 0)
		positiveTableArgument(data, "delay", true)

		verify(type(self.parent) == "Society", "Agent must be within a Society to send messages with delay.")

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
	--- Move the Agent to a new Cell. The agent needs to have a placement to be able to use
	-- Agent:enter(), Agent:leave(), or Agent:move().
	-- @arg newcell The new Cell.
	-- @arg placement A string representing the index to be used. Default is "placement".
	-- @usage agent:move(newcell)
	--
	-- agent:move(newcell, "renting")
	-- @see Environment:createPlacement
	move = function(self, newcell, placement)
		mandatoryArgument(1, "Cell", newcell)

		optionalArgument(2, "string", placement)
		if placement == nil then placement = "placement" end

		if self[placement] == nil then
			valueNotFoundError(2, placement)
		elseif not self[placement].cells[1] then 
			customError("Agent is not inside of any Cell.")
		end

		self:leave(self[placement].cells[1], placement)
		self:enter(newcell, placement)
	end,
	--- Notify the Observers of the Agent.
	-- @arg modelTime An integer number representing the notification time.
	-- @usage agent:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
		elseif type(modelTime) ~= "number" then
			if type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				incompatibleTypeError(1, "Event or positive number", modelTime)
			end
		elseif modelTime < 0 then
			incompatibleValueError(1, "Event or positive number", modelTime)
		end

        if self.obsattrs then
            forEachElement(self.obsattrs, function(idx)
                self[idx.."_"] = self[idx](self)
            end)
        end

		self.cObj_:notify(modelTime)
	end,
	--- Signature of a function that can be implemented by the modelers when the
	-- Agents can receive messages from other ones.
	-- This function receives a message as argument, with the same content of the
	-- message sent plus the attribute sender, representing the Agent that has
	-- sent the message. In the case of non-delayed messages, the returning value
	-- of this function (executed by the receiver) is also returned as the result
	-- of message (executed by the sender). Note that, although in the description
	-- below on_message has only one argument, the signature has two arguments,
	-- the first one being the agent itself. This function is usually called by
	-- TerraME, as result of calls of Agent:message() by the modeler. Other
	-- functions on_ can be defined by the modeler, and will be called by
	-- TerraME according to the subject of the message.
	-- @see Agent:message
	-- @see Society:synchronize
	-- @usage agent = Agent{
	--     on_message = function(self, message)
	--         self.money = self.money + message.quantity
	--         self:message{receiver = message.sender, content = "thanks"}
	--     end,
	--     --...
	--     on_thanks = function(self, message)
	--         self:message{receiver = message.sender, content = "yourewelcome"}
	--     end
	--     --...
	-- }
	-- @arg message A table with the received message. It has an attribute called sender with
	-- the Agent that sent the message.
	on_message = function(self, message)
		customError("Agent "..self.id.." does not implement 'on_message'.")
	end,
	--- Execute a random walk to a neighbor Cell.
	-- @usage agent:randomWalk()
	-- @deprecated Agent:walk
	randomWalk = function(self)
		deprecatedFunction("randomWalk", "walk")
	end,
	--- Execute a random walk to a neighbor Cell.
	-- @arg placement A string representing the index to be used. Default is "placement".
	-- @arg neighborhood A string representing the index of the Neighborhood to be used.
	-- Default is "placement".
	-- @usage agent:walk()
	--
	-- agent:walk("moore")
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
	end,
	--- Create an Agent with the same behavior in the same Cell where the original Agent is
	-- (according to its placement). The new Agent is pushed into the same Society the original
	-- Agent belongs and placements created using the Society are instantiated with size zero if
	-- the only argument of reproduce does not contain such placements. This function returns
	-- the new Agent.
	-- @arg data An optional table with attributes of the new Agent.
	-- @usage child = agent:reproduce()
	--
	-- child = agent:reproduce{age=0}
	--
	-- child = agent:reproduce{
	--     age = 0,
	--     house = agent.house:clone() -- house is a placement
	-- }
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
	--- Returns a random Agent from a SocialNetwork of this Agent.
	-- @arg id Name of the relation.
	-- @usage ag_friend = agent:sample("friends")
	sample = function(self, id)
		optionalArgument(1, "string", id)
		if id == nil then id = "1" end

		local sn = self:getSocialNetwork(id)

		verify(sn, "Agent does not have a SocialNetwork named '"..id.."'.")

		return sn:sample()
	end,
	--- Set the unique identifier of the Agent.
	-- @arg name A string.
	-- @usage agent:setId("newid")
	-- @deprecated Agent.id
	setId = function(self, name)
		deprecatedFunction("setId", ".id")
	end,
	--- Activate or not the trajectories defined for a given Agent.
	-- @arg status Use or not the trajectories. As default, trajectories are turned off. If
	-- status is true, when executed, the Agent that contains States will automatically
	-- traverse all trajectories defined within it. This function is useful only when the
	-- Agent is described as a state machine.
	-- @usage agent:setTrajectoryStatus(true)
	setTrajectoryStatus = function(self, status)
		optionalArgument(1, "boolean", status)
		if status == nil then status = false end

		self.cObj_:setActionRegionStatus(status)
	end
}

metaTableAgent_ = {__index = Agent_, __tostring = tostringTerraME}

--- An autonomous entity that is capable of performing actions as well as interact with other
-- Agents and the spatial representation of the model. The Agent constructor gets a table
-- containing the attributes and functions of the Agent. It can be  described as a simple table
-- or as a hybrid state machine that has a unique internal state. When the agent has a set of
-- states, the initial State will be the first declared State. When the agent does not have
-- states, there is a set of signatures that can be implemented by the modeller,
-- such as Agent:init(), Agent:on_message(), and Agent:execute().
-- An Agent can belong to a Society and can have SocialNetworks.
-- @arg data.id The unique identifier of the Agent. Default is a string with a numeric auto increment.
-- @arg data.init A function to be executed when the Agent enters in a Society (optional, see below).
-- @arg data.execute A function describing the behavior of the agent each time step it is
-- executed (optional, see below).
-- @arg data.on_message A function describing the behavior of the agent when it receives a
-- message (optional, see below).
-- @output cells A vector of Cells necessary to use Utils:forEachCell(). This value is the same
-- of "agent.placement.cells".
-- @output id The unique identifier of the Agent within the Society (only when the Agent was not
-- loaded from an external source).
-- @output parent The Society it belongs.
-- @output placement A Trajectory representing the default placement of the Agent (only when the
-- Agent belongs to an Environment, be itself directly or belonging to a Society that belongs to
-- an Environment).
-- @output socialnetworks A set of SocialNetworks with the connections of the Agent.
-- @see Environment:createPlacement
-- @see Utils:forEachConnection
-- @usage agent = Agent {
--     id = "MyAgent",
--     State {...},
--     -- ...
--     State {...}
-- }
--
-- singleFooAgent = Agent {
--     size = 10,
--     name = "foo",
--     execute = function(self)
--         self.size = self.size + 1
--         self:walk()
--     end,
--     on_hello = function(self, m)
--         self:message {
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

	for i, ud in pairs(data) do
		if type(ud) == "Trajectory" then cObj:add(ud.cObj_) end
		if type(ud) == "userdata" then cObj:add(ud); end
	end

	cObj:build()
	data.socialnetworks = {}
	return data
end

