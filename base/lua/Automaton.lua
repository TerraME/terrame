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
--          Rodrigo Reis Pereira
--#########################################################################################

Automaton_ = {
	type_ = "Automaton",
	--- Add a new Trajectory or State to the Automaton. It returns a boolean value
	-- indicating whether the new element was successfully added.
	-- @arg object A Trajectory or State.
	-- @usage automaton:add(state)
	-- automaton:add(trajectory)
	add = function(self, object)
		if type(object) == "Trajectory" or type(object) == "State" then
			self.cObj_:add(object)
		else
			incompatibleTypeError(1, "State or Trajectory", object)  
		end
	end,
	--- Check if the state machine was correctly defined. It verifies whether the targets of Jump 
	-- rules match the ids of the States.
	-- @usage automaton:build()
	build = function(self)
		self.cObj_:build()
	end,
	--- Execute the state machine. First, it executes the Jump of the current State while it
	-- jumps from State to State. When the machine stops jumping, it executes all the Flows of
	-- the current State. Usually, this function is called within an Event, thus the time of the
	-- Event can be got from the Timer. It returns a boolean value indicating whether the Jumps
	-- were executed correctly.
	-- @arg event An Event.
	-- @usage automaton:execute(event)
	execute = function(self, event)
		local t = type(event)
		-- if t == "userdata" or t == "Pair" then
		if t == "Event" or t == "Pair" then
			self.cObj_:execute(event)
		else
			incompatibleTypeError(1, "Event", event)
		end
	end,
	--- Retrieves the time when the machine executed the transition to the current state. Before
	-- running, the latency is zero.
	-- @usage latency = automaton:getLatency()
	getLatency = function(self) 
		return self.cObj_:getLatency()
	end,
	--- Retrieves the name of the current State.
	-- @usage id = automaton:getStateName()
	getStateName = function(self)
		return "Where?"
	end,
	--- Notify every Observer connected to the Automaton.
	-- @arg modelTime The time to be used by the Observer.
	-- @usage automaton:notify()
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
			incompatibleValueError(1, "positive number", modelTime)   
		end
		self.cObj_:notify(modelTime)
	end,
	--- Activate or not the Trajectories defined for the Automata. Returns whether the
	-- change  was successfully executed.
	-- @arg status A boolean that indicates if the Trajectories will be activated.
	-- @usage automaton:setTrajectoryStatus(true)
	setTrajectoryStatus = function(self, status)
		if status == nil then
			status = false
		elseif type(status) ~= "boolean" then
			incompatibleTypeError(1, "boolean", status)
		end
		self.cObj_:setActionRegionStatus(status)
	end,
	--- Set the unique identifier of the Automaton. Return a boolean value indicating whether
	-- the id was changed correctly.
	-- @arg id A string that names the Automaton.
	-- @usage automaton:setId("newid")
	setId = function(self,id)
		if id == nil then
		elseif type(id) ~= "string" then
			incompatibleTypeError("id", "string", id)
		end
		self.id = id
	end,
	--- Retrieves the unique identifier name of the Automaton.
	-- @usage automaton:getId()
	getId = function(self)
		return self.id
	end,
	--- Get all the States inside the Automaton. It returns a vector indexed by numeric positions.
	-- @usage state = automaton:getStates()[1]
	getStates = function(self)
		local statesVector = {}
		for key, value in pairs(self) do
			if type(value) == "State" then
				statesVector[key] = element
			end
		end
		return statesVector
	end,
	--- Get a State of the Automaton according to a given position.
	-- @arg index A number indicating the position of the State to be retrieved.
	-- @usage state = automaton:getState(1)
	getState = function(self, index)
		if index == nil then
			index = 1
		elseif type(index) ~= "number" then
			incompatibleTypeError(1, "positive integer number", index)
		elseif index < 0 then
			incompatibleValueError(1, "positive integer number", index)
		end
		local statesVector = self:getStates()
		return statesVector[index]
	end
}

metaTableAutomaton_ = {__index = Automaton_, __tostring = tostringTerraME}

--- A hybrid state machine that needs to be located on a CellularSpace, and is replicated over 
-- each Cell of the space. It has independent States in each Cell.
-- @arg data.id A string that names the Automanton.
-- @output parent The Environment it belongs.
-- @usage automaton = Automaton {
--     id = "MyAutomaton",
--     State {...},
--     -- ...
--     State {...}
-- }
function Automaton(data)
	if type(data) ~= "table" then
		if data == nil then
 			customError(tableArgumentMsg())
		else
 			customError(namedParametersMsg())
 		end
	end

	local cObj = TeLocalAutomaton()

	if data.id == nil then
		data.id = "1"
	elseif type(data.id) ~= "string" then
		incompatibleTypeError("id", "string", data.id)
	end

	setmetatable(data, metaTableAutomaton_)
	cObj:setReference(data)
	for i, ud in pairs(data) do 
		if type(ud) == "Trajectory" then cObj:add(ud.cObj_) end
		if type(ud) == "userdata" then cObj:add(ud) end
	end
	cObj:build()
	data.cObj_ = cObj
	return data
end

