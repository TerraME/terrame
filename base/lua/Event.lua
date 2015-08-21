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
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--#########################################################################################

local function Pair(data)
	if data == nil then data = {} end

	data.cObj_ = data
	return data
end

-- Set type to "Event"
TeEvent.type_ = "Event"

local function Action(data)
	local cObj = TeMessage()
	local metaAttr = {cObj_ = cObj}
	local metaTable = {__index = metaAttr, __tostring = _Gtme.tostring}
	if data.id ~= nil then cObj:config(data.id) end
	setmetatable(data, metaTable)
	cObj:setReference(data)
	return data
end

--- An Event represents a time instant when the simulation engine must execute some computation.
-- In order to be executed, Events must belong to a Timer. An Event is usually rescheduled to be
-- executed again according to its period, unless its action returns false.
-- @arg data.start A number representing the time instant when the
-- Event will occur for the first time. The default value is 1.
-- @arg data.period A positive number representing the periodicity of the Event.
-- The default value is 1.
-- @arg data.priority The priority of the Event over 
-- other Events. Smaller values have higher priority. The default value is 0. Priorities can also be defined
-- as strings:
-- @tabular priority
-- Value & Priority\
-- "verylow" & 10 \
-- "low" & 5 \
-- "medium" & 0 \
-- "high" & -5 \
-- "veryhigh" & -10
-- @arg data.action A function that will be executed when the Event is activated.
-- It has one single argument, the Event itself. If the action returns false,
-- the Event is removed from the Timer and will not be executed again. When the action will execute
-- a single function of a TerraME object, it is possible to use Utils:call(). Action can also be a TerraME
-- object. In this case, each type has its own set of functions that will be activated by
-- the Event. See below how the objects are activated. Arrows indicate the execution order:
-- @tabular action
-- Object & Function(s) activated by the Event \
-- Agent/Automaton & execute -> notify \
-- CellularSpace/Cell & synchronize -> notify \
-- function & function\
-- Society & execute -> synchronize \
-- Timer & notify \
-- Trajectory/Group & rebuild -> notify \
-- @usage event = Event {start = 1985, period = 2, priority = -1, action = function(event)
--     print(event:getTime())
-- end}
-- 
-- event2 = Event{
--     start = 2000,
--     action = my_society
-- }
function Event(data)
	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		verifyNamedTable(data)
	end

	local cObj = TeEvent()
	if data.message ~= nil then 
		customError("Argument 'message' is deprecated, use 'action' instead.")
	end

	verifyUnnecessaryArguments(data, {"start", "action", "priority", "period"})

	defaultTableValue(data, "start", 1)
	defaultTableValue(data, "period", 1)

	positiveTableArgument(data, "period")

	if type(data.priority) == "string" then
		switch(data, "priority"):caseof{
			verylow  = function() data.priority = 10  end,
			low      = function() data.priority = 5   end,
			medium   = function() data.priority = 0   end,
			high     = function() data.priority = -5  end,
			veryhigh = function() data.priority = -10 end
		}
	else
		defaultTableValue(data, "priority", 0)
	end

	cObj:config(data.start, data.period, data.priority)
	cObj:setReference(cObj)

	if data.action ~= nil then
		local targettype = type(data.action)
		if targettype == "function" then
			return Pair{cObj, Action{data.action}}
		elseif targettype == "Society" then
			if not data.action.execute then
				customError("The Society cannot be used as an action because it does not have an execute() method.")
			end

			local func = function(event)
				data.action:execute(event)
				data.action:synchronize(event:getPeriod())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Cell" then
			local func = function(event)
				data.action:notify(event)
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "CellularSpace" then
			local func = function(event)
				data.action:synchronize()
				data.action:notify(event)
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Agent" or targettype == "Automaton" then
			local func = function(event)
				data.action:execute(event)
				data.action:notify(event)
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Group" or targettype == "Trajectory" then
			local func = function(event)
				data.action:rebuild()
			end
			return Pair{cObj, Action{func}}
		else
			incompatibleTypeError("action", "one of the types from the set [Agent, Automaton, Cell, CellularSpace, function, Group, Society, Timer, Trajectory]", data.action)
		end
	else
		return cObj
	end
end

Event_ = {
	--- Return the current simulation time, according to the Timer it belongs.
	-- @usage event:getTime()
	getTime = function(self) end,
	--- Return the Timer that contains the Event.
	-- @usage timer = event:getParent()
	getParent = function(self) end,
	--#- Change the attributes of the Event. It will be rescheduled according to its new attributes.
	-- @arg time The time instant the Event will occur again (default is the current time of the
	-- Timer it will belong).
	-- @arg period The new periodicity of the Event (default is 1).
	-- @arg priority The new priority of the Event. The default priority is 0 (zero). Smaller
	--  values have higher priority.
	-- @usage event:config(1)
	-- event:config(1, 0.05)
	-- event:config(1, 0.05, -1)
	--config = function(self, time, period, priority) end,
	--- Return the period of the Event.
	-- @usage period = event:getPeriod()
	getPeriod = function(self) end,
	--- Return the priority of the Event.
	-- @usage timer = event:getPriority()
	getPriority = function(self) end
	--#- Change the priority of the Event. This change will take place as soon as the Event
	-- is rescheduled.
	-- @arg period The new periodicity of the Event (default is 1).
	-- @usage event:setPriority(4)
	-- setPriority = function(period) end,
	--#- Notify every Observer connected to the Event.
	-- @usage event:notify()
	-- notify = function() end,
}

