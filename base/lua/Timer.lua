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

Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer.
	-- @param event An Event.
	-- @usage timer:add(Event{...})
	add = function (self, event)
		if type(event) == "table" then 
			if self.events == nil then self.events = {} end
			table.insert(self.events, event)
			self.cObj_:add(event.cObj_[1], event.cObj_[2].cObj_)
		elseif event == nil then
			mandatoryArgumentErrorMsg("#1", 3)
		else
			incompatibleTypesErrorMsg("#1", "Event or table", type(event), 3)
		end
	end,
	--- Retrieve the current simulation time.
	-- @return A positve integer number.
	-- @usage print(timer:getTime())
	getTime = function(self)
		return self.cObj_:getTime()
	end,
	--- Execute the Timer until a given time. Every event that does not return false is scheduled
	-- to execute again according to its period. The Timer stops only when all its event are
	-- scheduled to execute after the given time, or when there is no remaining events. It
	-- returns whether the events were sucessfully executed.
	-- @param finalTime A  number representing the time to stop the simulation.
	-- The timer will stop when there is no Event scheduled to a time less or equal to the
	-- final time. This argument is mandatory.
	-- @usage timer:execute(2013)
	execute = function(self, finalTime)
 	   if finalTime == nil then
			mandatoryArgumentErrorMsg("#1", 3)	
    	elseif type(finalTime) ~= "number" then 
			incompatibleTypesErrorMsg("#1","number", type(finalTime), 3)
		end
		self.cObj_:execute(finalTime)
	end,
	--TODO: this function was removed from the interface. Rethink about it.
	--#- Reset the Timer to time zero, keeping the same queue.
	-- @usage timer:reset()
	reset = function(self)
		self.cObj_:reset()
	end,
	--- Notify every Observer connected to the Timer.
	-- @param modelTime An positive integer number representing time to be used by the
	-- Observer. Default is the current simulation time 'self:getTime()'.
	-- @usage timer:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = self:getTime()
   		elseif type(modelTime) ~= "number" then
			if type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				incompatibleTypesErrorMsg("#1", "Event or positive number", type(modelTime), 3) 
			end
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1", "Event or positive number", modelTime, 3)   
		end
		self.cObj_:notify(modelTime)
	end,
	--TODO: this function was removed from the interface. Rethink about it.
	--#- Retrieve an Event from the Timer.
	-- @param index A positive integer number representing a index from an Event. Default is 1.
	getEvent = function(self, index)
    	if index == nil then
			index = 1
		elseif type(index)~= "number" then
			incompatibleTypesErrorMsg("index","positive integer number","float number", 3)      
		elseif index < 0 or math.floor(index) ~= index then
			incompatibleValuesErrorMsg("index","positive integer number","negative number", 3)
		end
		return self.cObj_:getEvent(index)
	end,
	--TODO: this function was removed from the interface. Rethink about it.
	--#- Retrieve a table containing all Events of the Timer.
	-- @usage timer:getEvents()[1]
	getEvents = function(self)
		return self.cObj_:getEvents()
	end,
	--TODO: this function was removed from the interface. Rethink about it.
	--#- Change one Event of the Timer. Returns a boolean value indicating whether the Event
	-- was sucessfully changed.
	-- @param index A positive integer number representing the index of the Event to be replaced.
	-- @param event An Event which will be setted.
	-- @usage timer:setEvent(1, Event{...})
	setEvent = function(self, index, event)
    	if index == nil then
			index = 1
		elseif type(index)~= "number" then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(index), 3)
		elseif index < 0 or math.floor(index) ~= index then
			incompatibleValuesErrorMsg("#1", "positive integer number", index, 3)       
		end

		local t = type(event)
		if t ~= "Pair" or t ~= "Event" then
			-- TODO: esta funcao foi feita para dar errado porque sempre vai entrar neste if
			incompatibleTypesErrorMsg("#2", "Event",type(event), 3)
		else
			return self.cObj_:setEvent(event)
		end
	end,
	--TODO: this function was removed from the interface. Rethink about it.
	--#- Update the set of events of the Timer.
	-- @param events A table of Events. Return a boolean value indicating whether all Events
	-- were sucessfully changed.
	setEvents = function(self, events)
		if type(events)~= "table" then
			incompatibleTypesErrorMsg("#1", "table", type(events), 3)
		end    
		for i = 1, getn(events) do
			setEvent(i, events[i])
		end
	end
}

-- TODO: implement operator #, that returns the number of Events of the Timer

metaTableTimer_ = {__index = Timer_, __tostring = tostringTerraME}

--- A Timer is an event-based scheduler that executes and controls the simulation. It contains a
-- set of Events. It allows the model to take into consideration processes that start
-- independently and act in different periodicities. It starts with time 0 and, once it is in a
-- given time, it ensures that all the Events before that time were already executed.
-- @param data A table containing all Events of the Timer.
-- @usage timer = Timer {
--     Event {...},
--     Event {...}
-- }
function Timer(data)
	local cObj = TeTimer()
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
 			tableParameterErrorMsg("Timer", 3)
 		end
	end
	
	data.cObj_ = cObj
	local eventTab = {}

	for i, ud in pairs(data) do
		io.flush()
		if type(ud) == "table" then 
			cObj:add(ud.cObj_[1], ud.cObj_[2].cObj_) 
			table.insert(eventTab, ud)
		elseif type(ud) ~= "userdata" then
			incompatibleTypesErrorMsg(tostring(i), "Event, table, or userdata", type(ud), 3)
		end
	end

	data.events = eventTab

	setmetatable(data, metaTableTimer_)
	cObj:setReference(data)
	return data
end

