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

Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer.
	-- @arg event An Event.
	-- @usage timer:add(Event{...})
	add = function (self, event)
		if type(event) == "table" then 
			if self.events == nil then self.events = {} end
			table.insert(self.events, event)
			self.cObj_:add(event.cObj_[1], event.cObj_[2].cObj_)
		elseif event == nil then
			mandatoryArgumentError(1)
		else
			incompatibleTypeError(1, "Event or table", event)
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
	-- @arg finalTime A  number representing the time to stop the simulation.
	-- The timer will stop when there is no Event scheduled to a time less or equal to the
	-- final time. This argument is mandatory.
	-- @usage timer:execute(2013)
	execute = function(self, finalTime)
		mandatoryArgument(1, "number", finalTime)
		self.cObj_:execute(finalTime)
	end,
	--- Notify every Observer connected to the Timer.
	-- @arg modelTime An positive integer number representing time to be used by the
	-- Observer. Default is the current simulation time 'self:getTime()'.
	-- @usage timer:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = self:getTime()
   		elseif type(modelTime) ~= "number" then
			if type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				incompatibleTypeError(1, "Event or positive number", modelTime) 
			end
		elseif modelTime < 0 then
			incompatibleValueError(1, "Event or positive number", modelTime)   
		end
		self.cObj_:notify(modelTime)
	end,
}

metaTableTimer_ = {__index = Timer_, __tostring = tostringTerraME}

--- A Timer is an event-based scheduler that executes and controls the simulation. It contains a
-- set of Events. It allows the model to take into consideration processes that start
-- independently and act in different periodicities. It starts with time 0 and, once it is in a
-- given time, it ensures that all the Events before that time were already executed.
-- @arg data A table containing all Events of the Timer.
-- @usage timer = Timer {
--     Event {...},
--     Event {...}
-- }
function Timer(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
 			customError(tableArgumentMsg())
 		end
	end
	
	local cObj = TeTimer()
	data.cObj_ = cObj
	local eventTab = {}

	for i, ud in pairs(data) do
		io.flush()
		if type(ud) == "table" then 
			cObj:add(ud.cObj_[1], ud.cObj_[2].cObj_) 
			table.insert(eventTab, ud)
		elseif type(ud) ~= "userdata" then
			incompatibleTypeError(tostring(i), "Event, table, or userdata", ud)
		end
	end

	data.events = eventTab

	setmetatable(data, metaTableTimer_)
	cObj:setReference(data)
	return data
end

