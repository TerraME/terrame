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

Event_ = {
	type_ = "Event",
	--- Return the current simulation time, according to the Timer it belongs.
	-- @usage event = Event {start = 1985, period = 2, priority = -1, action = function(event)
    --     print(event:getTime())
    -- end}
	-- 
	-- time = event:getTime()
	-- print(time)
	getTime = function(self)
		return self.time
	end,
	--- Return the Timer that contains the Event.
	-- @usage event = Event {action = function(event)
	--     print(event:getTime())
	-- end}
	--
	-- timer = Timer{event}
	--
	-- parent = event:getParent()
	-- if parent == timer then
	--     print("equal")
	-- end
	getParent = function(self)
		return self.parent
	end,
	--- Change the attributes of the Event. It will be rescheduled according to its new attributes if
	-- this function is called while the action is being executed. Be careful when using this function
	-- outside the events's action, because the scheduler will not update its queue. In this case, it
	-- is recommended to replace the Event by another one.
	-- @arg data.time The time instant the Event will occur.
	-- @arg data.period The new periodicity of the Event.
	-- @arg data.priority The new priority of the Event.
	-- @usage event = Event{start = 2, action = function() end}
	-- 
	-- event:config{priority = -1}
	-- event:config{time = 10, period = 2}
	config = function(self, data)
		verifyNamedTable(data)
		verifyUnnecessaryArguments(data, {"time", "priority", "period"})

		if data.time ~= nil then
			optionalTableArgument(data, "time", "number")
			self.time = data.time
		end

		if data.period ~= nil then
			optionalTableArgument(data, "period", "number")
			positiveTableArgument(data, "period")
			self.period = data.period
		end

		if data.priority ~= nil then
			optionalTableArgument(data, "priority", "number")
			self.priority = data.priority
		end
	end,
	--- Return the period of the Event.
	-- @usage event = Event {start = 1985, period = 2, priority = -1, action = function(event)
    --     print(event:getTime())
    -- end}
	-- 
	-- period = event:getPeriod()
	-- print(period)
	getPeriod = function(self)
		return self.period
	end,
	--- Return the priority of the Event.
	-- @usage event = Event {start = 1985, period = 2, priority = -1, action = function(event)
    --     print(event:getTime())
    -- end}
	--
	-- priority = event:getPriority()
	-- print(priority)
	getPriority = function(self)
		return self.priority
	end
	--#- Change the priority of the Event. This change will take place as soon as the Event
	-- is rescheduled.
	-- @arg period The new periodicity of the Event (default is 1).
	-- @usage event:setPriority(4)
	-- setPriority = function(period) end,
	--#- Notify every Observer connected to the Event.
	-- @usage event:notify()
	-- notify = function() end,
}

metaTableEvent_ = {
	__index = Event_,
	__tostring = _Gtme.tostring
}

--- An Event represents a time instant when the simulation engine must execute some computation.
-- In order to be executed, Events must belong to a Timer. An Event is usually rescheduled to be
-- executed again according to its period, unless its action explicitly returns false.
-- @arg data.start A number representing the time instant when the
-- Event will occur for the first time. The default value is one, except
-- when using graphics (Chart, Map, Clock, etc.) as action. In this case the default value is zero,
-- plotting the initial state of the simulation.
-- @arg data.period A positive number representing the periodicity of the Event.
-- The default value is 1.
-- @arg data.priority The priority of the Event over 
-- other Events. Smaller values have higher priority. The default value is zero for all actions but
-- those related to graphics (Chart, Map, Clock, etc.). In this case, the default value is 10.
-- Priorities can also be defined as strings:
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
-- Agent/Automaton & execute \
-- CellularSpace/Cell & synchronize and then execute (if exists) \
-- Chart/Map/Clock/LogFile/InternetSender/VisualTable/TextScreen & update \
-- function & the function itself \
-- Model & execute (if exists) \
-- Society & synchronize and then execute (if exists) \
-- Trajectory/Group & rebuild \
-- @usage event = Event {start = 1985, period = 2, priority = -1, action = function(event)
--     print(event:getTime())
-- end}
-- 
-- agent = Agent{
--     execute = function()
--         print("executing")
--     end
-- }
--
-- event2 = Event{
--     start = 2000,
--     action = agent
-- }
--
-- timer = Timer{event, event2}
-- timer:run(10)
function Event(data)
	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		verifyNamedTable(data)
	end

	if data.message ~= nil then 
		customError("Argument 'message' is deprecated, use 'action' instead.")
	end

	verifyUnnecessaryArguments(data, {"start", "action", "priority", "period"})

	if type(data.priority) == "string" then
		switch(data, "priority"):caseof{
			verylow  = function() data.priority = 10  end,
			low      = function() data.priority = 5   end,
			medium   = function() data.priority = 0   end,
			high     = function() data.priority = -5  end,
			veryhigh = function() data.priority = -10 end
		}
	end

	if belong(type(data.action), {"Chart", "Map", "InternetSender", "VisualTable", "Clock", "FileSystem", "TextScreen"}) then
		defaultTableValue(data, "priority", 10)
		defaultTableValue(data, "start", 0)
	else
		defaultTableValue(data, "priority", 0)
		defaultTableValue(data, "start", 1)
	end

	defaultTableValue(data, "period", 1)
	positiveTableArgument(data, "period")

	data.time = data.start
	data.start = nil

	if data.action == nil then
		customError("Argument 'action' is mandatory.")
	else
		local targettype = type(data.action)
		local maction = data.action
		if targettype == "Society" then
			if data.action.execute then
				if type(data.action.execute) ~= "function" then
					customError("Incompatible types. Attribute 'execute' from "..targettype.." should be a function, got "..type(data.action.execute)..".")
				end

				data.action = function(event)
					maction:synchronize(event:getPeriod())
					maction:execute(event)
				end
			else
				data.action = function(event)
					maction:synchronize(event:getPeriod())
				end
			end
		elseif targettype == "Cell" or targettype == "CellularSpace" then
			if data.action.execute then
				if type(data.action.execute) ~= "function" then
					customError("Incompatible types. Attribute 'execute' from "..targettype.." should be a function, got "..type(data.action.execute)..".")
				end
				data.action = function(event)
					maction:synchronize()
					maction:execute(event)
				end
			else
				data.action = function()
					maction:synchronize()
				end
			end
		elseif targettype == "Agent" or targettype == "Automaton" then
			if type(data.action.execute) ~= "function" then
				customError("Incompatible types. Attribute 'execute' from "..targettype.." should be a function, got "..type(data.action.execute)..".")
			end

			data.action = function(event)
				maction:execute(event)
			end
		elseif targettype == "Group" or targettype == "Trajectory" then
			data.action = function()
				maction:rebuild()
			end
		elseif isModel(maction) then
			if data.action.execute then
				data.action = function(event)
					maction:execute(event)
				end
			else
				data.action = function()
				end
			end
		elseif belong(type(data.action), {"Chart", "Map", "InternetSender", "VisualTable", "Clock", "FileSystem", "TextScreen"}) then
			data.action = function(event)
				maction:update(event)
			end
		elseif targettype ~= "function" then
			incompatibleTypeError("action", "one of the TerraME types or a function", data.action)
		end
	end

	setmetatable(data, metaTableEvent_)
	return data
end

