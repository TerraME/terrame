--- An Event represents a time instant when the simulation engine must execute some computation.
-- @param data.time A positive integer number representing the first instant of time when the Event will occur. Default is 1.
-- @param data.period A positive integer number representing the periodicity of the Event. Default is 1.
-- @param data.priority A positive integer number defining the priority of the Event over other Events. Smaller values have higher priority. Default is 0.
-- @param data.action A function from where, in general, the simulation engine services are invoked. This function has one single argument, the Event itself. If the action returns false, the Event is removed from the Timer and will not be executed again. Action can also be a TerraME object. In this case, each type has its own set of functions that will be activated by the Event.
-- See below how the objects are activated. Arrows indicate the execution order:
-- @tab action
-- Object & Function(s) activated \
-- Agent/Automaton & execute -> notify \
-- CellularSpace/Cell & synchronize -> notify \
-- function & function\
-- Society & execute -> synchronize \
-- Timer & notify \
-- Trajectory/Group & rebuild -> notify \
-- @see Agent
-- @see Automaton
-- @see CellularSpace
-- @see Cell
-- @see Society
-- @see Timer
-- @see Trajectory
-- @see Group
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
    defaultValueWarningMsg("#1", "table", "{}", 3)
  elseif type(data) ~= "table" then
    incompatibleTypesErrorMsg("#1", "table", type(data), 3)
  end  
	local cObj = TeEvent()
	if data.message ~= nil then customErrorMsg("Error: Parameter 'message' is deprecated, use 'action' instead.", 3) end

	if data.time == nil then
		data.time = 1
		defaultValueWarningMsg("time", "positive number", data.time, 3)
	elseif type(data.time) ~= "number" then
		incompatibleTypesErrorMsg("time", "positive number", type(data.time), 3)
	end

  if data.period == nil then
		data.period = 1
		defaultValueWarningMsg("period", "positive number (except zero)", data.period, 3)    
	elseif type(data.period) ~= "number" then
		incompatibleTypesErrorMsg("period", "positive number (except zero)", type(data.period), 3)
	elseif data.period <= 0 then
		incompatibleValuesErrorMsg("period","positive number (except zero)", data.period, 3)
	end

  if data.priority == nil then
		data.priority = 0
		defaultValueWarningMsg("priority", "positive number", data.priority,3)    
	elseif type(data.priority) ~= "number" then
		incompatibleTypesErrorMsg("priority", "positive number (except zero)", type(data.priority), 3)
	elseif(data.priority < 0) then
		incompatibleValuesErrorMsg("priority", "positive number (except zero)", data.priority, 3)  
	end

	cObj:config(data.time, data.period, data.priority)
	cObj:setReference(cObj)

	if data.action ~= nil then
		targettype = type(data.action)
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
			incompatibleTypesErrorMsg("action","one of the types from the set [Agent, Automaton, Cell, CellularSpace, function, Group, Society, Timer, Trajectory]", type(data.action), 3)
		end
	else
		return cObj
	end
end
