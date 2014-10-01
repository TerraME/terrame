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
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

-- Set type to "Event"
TeEvent.type_ = "Event"

--- An Event represents a time instant when the simulation engine must execute some computation.
-- In order to be executed, Events must belong to a Timer. An Event is usually rescheduled to be
-- executed again according to its period, unless its action returns false. The functions
-- available for Events can be used only along the simulation, when the Event is activated and
-- comes as a parameter of an action.
-- @param data.time A positive integer number representing the first instant of time when the
-- Event will occur. Default is 1.
-- @param data.period A positive integer number representing the periodicity of the Event. 
-- Default is 1.
-- @param data.priority A positive integer number defining the priority of the Event over 
-- other Events. Smaller values have higher priority. Default is 0.
-- @param data.action A function from where, in general, the simulation engine services are 
-- invoked. This function has one single argument, the Event itself. If the action returns false,
-- the Event is removed from the Timer and will not be executed again. Action can also be a TerraME
-- object. In this case, each type has its own set of functions that will be activated by
-- the Event. See below how the objects are activated. Arrows indicate the execution order:
-- @tab action
-- Object & Function(s) activated \
-- Agent/Automaton & execute -> notify \
-- CellularSpace/Cell & synchronize -> notify \
-- function & function\
-- Society & execute -> synchronize \
-- Timer & notify \
-- Trajectory/Group & rebuild -> notify \
-- @usage event = Event {time = 1985, period = 2, priority = -1, action = function(event)
--     print(event:getTime())
-- end}
-- 
-- event2 = Event {
--     time = 2000,
--     action = my_society
-- }
function Event(data)
	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		namedParametersError("Event")
	end

	local cObj = TeEvent()
	if data.message ~= nil then 
		customError("Parameter 'message' is deprecated, use 'action' instead.")
	end

	checkUnnecessaryParameters(data, {"time", "action", "priority", "period"})

	if data.time == nil then
		data.time = 1
	elseif type(data.time) ~= "number" then
		incompatibleTypeError("time", "positive number", data.time)
	--TODO: se adicionar estas linhas abaixo o Event aborta o TerraME
	--	elseif data.time == 1 then
	--		defaultValueWarning("time", "1", 3)
	end

	if data.period == nil then
		data.period = 1
	elseif type(data.period) ~= "number" then
		incompatibleTypeError("period", "positive number (except zero)", data.period)
	elseif data.period <= 0 then
		incompatibleValueError("period", "positive number (except zero)", data.period)
	--TODO: se adicionar estas linhas abaixo o Event aborta o TerraME
	--	elseif data.period == 1 then
	--		defaultValueWarning("period", "1", 3)
	end

	-- TODO: possibilitar priority descrito como string: "low", "medium", "high", "very..."
	-- mapeando estas strings para numeros
	if data.priority == nil then
		data.priority = 0
	elseif type(data.priority) ~= "number" then
		incompatibleTypeError("priority", "positive number (except zero)", data.priority)
	--TODO: se adicionar estas linhas abaixo o Event aborta o TerraME
	--	elseif data.priority == 0 then
	--		defaultValueWarning("priority", "0", 3)
	end

	cObj:config(data.time, data.period, data.priority)
	cObj:setReference(cObj)

	if data.action ~= nil then
		local targettype = type(data.action)
		if targettype == "function" then
			return Pair{cObj, Action{data.action}}
		elseif targettype == "Society" then
			local func = function(event)
				data.action:execute(event)
				data.action:synchronize(event:getPeriod())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Cell" then
			local func = function(event)
				data.action:notify(event:getTime())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "CellularSpace" then
			local func = function(event)
				data.action:synchronize()
				data.action:notify(event:getTime())
			end
			return Pair{cObj, Action{func}}
		elseif targettype == "Agent" or targettype == "Automaton" then
			local func = function(event)
				data.action:execute(event)
				--data.target:synchronize() 
				--data.target:notify(event:getTime())
				--TODO PEDRO: colocar o notify aqui!!
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
	-- @param time The time instant the Event will occur again (default is the current time of the
	-- Timer it will belong).
	-- @param period The new periodicity of the Event (default is 1).
	-- @param priority The new priority of the Event. The default priority is 0 (zero). Smaller
	--  values have higher priority.
	-- @usage event:config(1)
	-- event:config(1, 0.05)
	-- event:config(1, 0.05, -1)
	config = function(self, time, period, priority) end,
	--- Return the period of the Event.
	-- @usage period = event:getPeriod()
	getPeriod = function(self) end,
	--- Return the priority of the Event.
	-- @usage timer = event:getPriority()
	getPriority = function(self) end,
	--#- Change the priority of the Event. This change will take place as soon as the Event
	-- is rescheduled.
	-- @param period The new periodicity of the Event (default is 1).
	-- @usage event:setPriority(4)
	-- setPriority = function(period) end,
	--#- Notify every Observer connected to the Event.
	-- @usage event:notify()
	-- notify = function() end,
	--- Return "Event".
	-- @usage mtype = event:getType()
	getType = function() end
}

