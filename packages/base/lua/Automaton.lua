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

Automaton_ = {
	type_ = "Automaton",
	--- Add a new Trajectory or State to the Automaton. It returns a boolean value
	-- indicating whether the new element was successfully added.
	-- @arg object A Trajectory or State.
	-- @usage automaton:add(state)
	-- DONTRUN
	-- automaton:add(trajectory)
	add = function(self, object)
		if type(object) == "Trajectory" or type(object) == "State" then
			self.cObj_:add(object.cObj_)
		else
			incompatibleTypeError(1, "State or Trajectory", object)
		end
	end,
	--- Execute the State machine. First, it executes the Jump of the current State while it
	-- jumps from State to State. When the machine stops jumping, it executes all the Flows of
	-- the current State. Usually, this function is called within an Event, thus the time of the
	-- Event can be got from the Timer. It returns a boolean value indicating whether the Jumps
	-- were executed correctly.
	-- @arg event An Event.
	-- @usage -- DONTRUN
	-- automaton:execute(event)
	execute = function(self, event)
		mandatoryArgument(1, "Event", event)

		local cObj = TeEvent()
		cObj:config(event.time, event.period, event.priority)
		cObj:setReference(event)

		self.cObj_:execute(cObj)
	end,
	--- Return the unique identifier name of the Automaton.
	-- @usage automaton:getId()
	-- DONTRUN
	getId = function(self)
		return self.id
	end,
	--- Get a State of the Automaton according to a given position.
	-- @arg position A number indicating the position of the State to be retrieved.
	-- @usage -- DONTRUN
	-- state = automaton:getState(1)
	getState = function(self, position)
		mandatoryArgument(1, "number", position)

		integerArgument(1, position)
		positiveArgument(1, position)

		local statesVector = self:getStates()
		return statesVector[position]
	end,
	--- Return the name of the current State. As an Automaton has independent States in each Cell,
	-- it requires a location to return its State name.
	-- @arg cell A Cell.
	-- @usage -- DONTRUN
	-- id = automaton:getStateName(cell)
	getStateName = function(self, cell)
		mandatoryArgument(1, "Cell", cell)
		return cell.cObj_:getCurrentStateName(self.cObj_)
	end,
	--- Get all the States inside the Automaton. It returns a vector.
	-- @usage -- DONTRUN
	-- state = automaton:getStates()[1]
	getStates = function(self)
		local statesVector = {}
		for _, value in pairs(self) do
			if type(value) == "State" then
				table.insert(statesVector, element)
			end
		end
		return statesVector
	end,
	--- Notify every Observer connected to the Automaton.
	-- @arg modelTime An integer number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage -- DONTRUN
	-- automaton:notify()
	notify = function(self, modelTime)
		if modelTime == nil then
			modelTime = 0
		elseif type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		else
			optionalArgument(1, "number", modelTime)
			positiveArgument(1, modelTime, true)
		end

		self.cObj_:notify(modelTime)
	end,
	--- Set the unique identifier of the Automaton. Return a boolean value indicating whether
	-- the id was changed correctly.
	-- @arg id A string that names the Automaton.
	-- @usage -- DONTRUN
	-- automaton:setId("newid")
	setId = function(self, id)
		if id == nil then
			mandatoryArgument(1, "string", id)
		elseif type(id) ~= "string" then
			incompatibleTypeError(1, "string", id)
		end
		self.id = id
	end,
	--- Activate or not the Trajectories defined for the Automaton. Returns whether the
	-- change was successfully executed. When the Automaton is built its status is
	-- not activated.
	-- @arg status A boolean that indicates if the Trajectories will be activated.
	-- @usage -- DONTRUN
	-- automaton:setTrajectoryStatus(true)
	setTrajectoryStatus = function(self, status)
		if status == nil then
			status = false
		elseif type(status) ~= "boolean" then
			incompatibleTypeError(1, "boolean", status)
		end
		self.cObj_:setActionRegionStatus(status)
	end
}

metaTableAutomaton_ = {__index = Automaton_, __tostring = _Gtme.tostring}

--- A hybrid state machine that needs to be located on a CellularSpace, and is replicated over
-- each Cell of the space. It has independent States in each Cell.
-- @arg data.id A string that names the Automanton.
-- @output parent The Environment it belongs.
-- @usage -- DONTRUN
-- automaton = Automaton {
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
			customError(namedArgumentsMsg())
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
	for _, ud in pairs(data) do
		local t = type(ud)
		if t == "Trajectory" or t == "State" then cObj:add(ud.cObj_) end
	end
	cObj:build()
	data.cObj_ = cObj
	return data
end

