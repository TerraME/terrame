Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer. Returns a boolean value indicating whether the the event was sucessfully added.
	-- @param event An Event.
	-- @usage timer:add(Event{...})
	add = function (self, event)
		--[[
		local t = type(event)
		if t ~= "Pair" and t ~= "userdata" then 
		incompatibleTypesMsg("event","Pair or userdata",type(event))      
		deniedOperationMsg("add")
		return false
		end
		print("---<<", type(event), type(event.cObj_))
		print("---<<", event.cObj_[1])
		print("---<<", event.cObj_[2])
		print("---<<", event.cObj_[2].cObj_)
		self.cObj_:add(event.cObj_[1],event.cObj_[2].cObj_)
		return true
		--]]
		if type(event) == "table" then self.cObj_:add(event.cObj_[1],event.cObj_[2].cObj_) end
	end,
	--- Retrieve the current simulation time.
	-- @return A positve integer number.
	-- @usage print(timer:getTime())
	getTime = function(self) return self.cObj_:getTime() end,

	--- Execute the Timer until a given time. Every event that does not return false is scheduled to execute again according to its period. The Timer stops only when all its event are scheduled to execute after the given time, or when there is no remaining events. It returns whether the events were sucessfully executed.
	-- @param finalTime A positive integer number representing the time to stop the simulation. The timer will stop when there is no Event scheduled to a time less or equal to the final time. Default is '1'
	-- @usage timer:execute(2013)
	execute = function(self, finalTime)
    if finalTime == nil then
			finalTime = 1
			defaultValueWarningMsg("#1", "integer number", finalTime, 3)
    elseif type(finalTime) ~= "number" then 
			incompatibleTypesErrorMsg("#1","integer number", type(finalTime), 3)
		elseif finalTime ~= math.floor(finalTime) then
			incompatibleValuesErrorMsg("#1","integer number", finalTime, 3)
		end
		self.cObj_:execute(finalTime)
	end,

	--- Reset the Timer to time zero, keeping the same queue.
	-- @usage timer:reset()
	reset = function(self) self.cObj_:reset() end,

	--- Notify every Observer connected to the Timer.
	-- @param modelTime An positive integer number representing time to be used by the Observer.
	-- @usage timer:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
			defaultValueWarningMsg("#1", "positive number", modelTime, 3)
    elseif type(modelTime) ~= "number" then
      incompatibleTypesErrorMsg("#1", "positive number", type(modelTime), 3) 
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1","positive number", modelTime, 3)   
		end
		self.cObj_:notify(modelTime)
	end,

	--- Retrieve an Event from the Timer.
	-- @param index A positive integer number representing a index from an Event. Default is 1.
	getEvent = function(self, index)
    if index == nil then
			index = 1
			defaultValueWarningMsg("#1", "positive integer number", index, 3)
		elseif(type(index)~= "number") then
			incompatibleTypesErrorMsg("index","positive integer number","float number", 3)      
		elseif(index < 0 or math.floor(index) ~= index) then
			incompatibleValuesErrorMsg("index","positive integer number","negative number", 3)
		end
		return self.cObj_:getEvent(index)
	end,

	--- Retrieve a table containing all Events of the Timer.
	-- @usage timer:getEvents()[1]
	getEvents = function(self)
		return self.cObj_:getEvents()
	end,

	--- Change one Event of the Timer. Returns a boolean value indicating whether the Event was sucessfully changed.
	-- @param index A positive integer number representing the index of the Event to be replaced.
	-- @param event An Event which will be setted.
	-- @usage timer:setEvent(1, Event{...})
	setEvent = function(self, index, event)
    if index == nil then
			index = 1
			defaultValueWarningMsg("#1", "positive integer number", index, 3)      
		elseif(type(index)~= "number") then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(index), 3)
		elseif(index < 0 or math.floor(index) ~= index) then
			incompatibleValuesErrorMsg("#1", "positive integer number", index, 3)       
		end

		local t = type(event)
		if(t ~= "Pair" or t ~= "userdata") then
			incompatibleTypesErrorMsg("#2","Event",type(event), 3)
			return false
		else
			return self.cObj_:setEvent(event)
		end
	end,

	--- Update the set of events of the Timer.
	-- @param events A table of Events. Return a boolean value indicating whether all Events were sucessfully changed.
	setEvents = function(self, events)
		if(type(events)~= "table") then
			incompatibleTypesErrorMsg("#1", "table", type(events), 3)
		end    
		for i=1,getn(events) do
			setEvent(i,events[i])
		end
		return true
	end
}

local metaTableTimer_ = {__index = Timer_}

--- A Timer is an event-based scheduler that executes and controls the simulation. It contains a set of Events. It allows the model to take into consideration processes that start independently and act in different periodicities. It starts with time 0 and, once it is in a given time, it ensures that all the Events before that time were already executed.
-- @param data A table containing all Events of the Timer.
-- @usage timer = Timer {
--     Event {...},
--     Event {...}
-- }
function Timer(data)
	local cObj = TeTimer()
	--TODO imprimir ou não warning?
	if data == nil then data = {} end
	data.cObj_ = cObj

	for i, ud in pairs(data) do
		io.flush()
		if type(ud) == "table" then cObj:add(ud.cObj_[1], ud.cObj_[2].cObj_) end
	end
	setmetatable(data, metaTableTimer_)
	cObj:setReference(data)
	return data
end
