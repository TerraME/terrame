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
	--- Add a new Event to the timer. If the Event has a start time less than the current
	-- simulation time then add() will prompt a warning (but the Event will be added).
	-- @arg event An Event.
	-- @usage timer = Timer{}
	--
	-- timer:add(Event{action = function() end})
	add = function(self, event)
		mandatoryArgument(1, "Event", event)

		if event.time < self.time then
			local msg = "Adding an Event with time ("..event.time..
				") before the current simulation time ("..self.time..")."
			customWarning(msg)
		end

		local pos = 1
		local evp = self.events[pos]
		local quant = #self.events
		local time = event.time
		local prio = event.priority
		while pos <= quant and (time > evp.time or (time == evp.time and prio > evp.priority)) do
			pos = pos + 1
			evp = self.events[pos]
		end

		table.insert(self.events, pos, event)
		event.parent = self
	end,
	--- Add temporal replacements for a given attribute. Cells and Agents might have temporal
	-- data stored as attribute values, with time stored as part of the attribute name.
	-- This function adds a set of Events to update a given attribute from several temporal
	-- attributes. It is particularly useful when working with data loaded from files or databases.
	-- @arg data.target A CellularSpace or a Society.
	-- @arg data.select A vector of attributes that represent temporal data. This function will
	-- create one Event for each value in this vector.
	-- @arg data.attribute A string with an attribute name to be updated with the temporal data.
	-- @arg data.time A vector of times, with the same length of select. The events will be
	-- scheduled to execute in such times with priority "veryhigh".
	-- @usage c = Cell{
	--     dist = 1,
	--     dist10 = 2,
	--     dist20 = 3
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10,
	--     instance = c
	-- }
	--
	-- timer = Timer{}
	--
	-- timer:addReplacement{
	--     target = cs,
	--     select = {"dist10", "dist20"},
	--     attribute = "dist",
	--     time = {10, 20}
	-- }
	--
	-- print(cs:dist()) -- 100
	--
	-- timer:execute(13)
	-- print(cs:dist()) -- 200
	--
	-- timer:execute(20)
	-- print(cs:dist()) -- 300
	addReplacement = function(self, data)
		verifyNamedTable(data)

		if type(data.target) ~= "CellularSpace" and type(data.target) ~= "Society" then
			customError(incompatibleTypeMsg("target", "CellularSpace or Society", data.target))
		end

		mandatoryTableArgument(data, "select", "table")
		mandatoryTableArgument(data, "attribute", "string")
		mandatoryTableArgument(data, "time", "table")

		verify(#data.select == #data.time, "The size of argument 'time' should be "..#data.select..", got "..#data.time..".")

		if type(data.target) == "Society" then
			forEachElement(data.select, function(pos, attr)
				if data.target.agents[1][attr] == nil then
					customError("Attribute '"..attr.."' does not exist in the Agents.")
				end

				local target = data.target
				local attribute = data.attribute
				self:add(Event{start = data.time[pos], action = function()
					forEachAgent(target, function(agent)
						agent[attribute] = agent[attr]
					end)

					return false
				end})
			end)
		else -- CellularSpace
			forEachElement(data.select, function(pos, attr)
				if data.target.cells[1][attr] == nil then
					customError("Attribute '"..attr.."' does not exist in the Cells.")
				end

				local target = data.target
				local attribute = data.attribute
				self:add(Event{start = data.time[pos], action = function()
					forEachCell(target, function(cell)
						cell[attribute] = cell[attr]
					end)

					return false
				end})
			end)
		end
	end,
	--- Remove all the Events from the Timer.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:clear()
	clear = function(self)
		self.events = {}
	end,
	--- Execute the Timer until a final time. It manages the Event queue according to their execution
	-- time and priority. The Event that has lower execution time and lower priority is executed at
	-- each step. It this Event does not return false it is scheduled to execute again according to
	-- its period. The Timer then repeats its execution again and again. It stops only when all its
	-- Events are scheduled to execute after the final time, or when there is no remaining Events.
	-- @arg finalTime A number representing the final time of the simulation.
	-- This argument is mandatory.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:execute(10)
	execute = function(self, finalTime)
		mandatoryArgument(1, "number", finalTime)

		if finalTime < self.time then
			local msg = "Simulating until a time ("..finalTime..
				") before the current simulation time ("..self:getTime()..")."
			customWarning(msg)
		end

		while true do
			if getn(self.events) == 0 then return end

			local ev = self.events[1]
			if ev.time > finalTime then
				self.time = finalTime
				return
			end

			self.time = ev.time

			table.remove(self.events, 1)

			local result = ev.action(ev, self)

			if result == false then
				ev.parent = nil
			else
				ev.time = ev.time + ev.period

				local floor = math.floor(ev.time)
				local ceil = math.ceil(ev.time)

				if math.abs(ev.time - floor) < self.round then
					ev.time = floor
				elseif math.abs(ev.time - ceil) < self.round then
					ev.time = ceil
				end
				self:add(ev)
			end
		end
	end,
	--- Return a vector with the Events of the Timer.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- print(timer:getEvents()[1]:getTime())
	getEvents = function(self)
		return self.events
	end,
	--- Return the current simulation time.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:execute(10)
	-- print(timer:getTime())
	getTime = function(self)
		return self.time
	end,
	--- Notify every Observer connected to the Timer.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- Clock{target = timer}
	--
	-- timer:execute(10)
	--
	-- timer:notify()
	notify = function(self)
		local modelTime = self:getTime()
		self.cObj_:notify(modelTime)
	end,
	--- Reset the Timer to time minus infinite, keeping the same Event queue.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- Clock{target = timer}
	--
	-- timer:execute(10)
	--
	-- timer:reset()
	-- print(timer:getTime())
	reset = function(self)
		self.time = -math.huge
	end
}

metaTableTimer_ = {
	__index = Timer_,
	__tostring = _Gtme.tostring,
	--- Return the number of Events in the Timer.
	-- @usage timer = Timer{
	--     Event{action = function()
	--         print("each time step")
	--     end},
	--     Event{period = 2, action = function()
	--         print("each two time steps")
	--     end}
	-- }
	--
	-- print(#timer)
	__len = function(self)
		return #self.events
	end
}

--- A Timer is an Event-based scheduler that executes and controls the simulation. It contains a
-- set of Events, allowing the simulation to work with processes that start
-- independently and act in different periodicities. Once it has a given simulation time,
-- it ensures that all the Events before that time were already executed.
-- @arg data.round A number to work with Events that have period less than one. It rounds
-- the execution time of an Event that is going to be scheduled to be executed to
-- a time in the future if the difference between such time and the closest integer number
-- is less then the value of this argument. For example, an Event that starts in time one
-- and has period 0.1 might execute in time 1.999999999, as we are working with real numbers.
-- Round is then useful to make sure that such Event will be executed in time exactly two.
-- The default value is 0.00001 (1e-5).
-- @arg data.... A set of Events.
-- @output cObj_ A pointer to a C++ representation of the Timer. Never use this object.
-- @output events An ordered vector with the Events.
-- @output time The current simulation time.
-- @usage timer = Timer{
--     Event{action = function()
--         print("each time step")
--     end},
--     Event{period = 2, action = function()
--         print("each two time steps")
--     end},
--     Event{priority = "high", period = 4, action = function()
--         print("each four time steps")
--     end}
-- }
--
-- timer:execute(10)
function Timer(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			customError(tableArgumentMsg())
		end
	end

	local cObj = TeTimer()

	data.events = {}
	data.time = -math.huge

	setmetatable(data, metaTableTimer_)

	forEachOrderedElement(data, function(idx, value, mtype)
		if mtype == "Event" then
			data:add(value)
		elseif not belong(idx, {"events", "time"}) then
			incompatibleTypeError(idx, "Event", value)
		end
	end)
 
	defaultTableValue(data, "round", 1e-5)
	data.cObj_ = cObj
	cObj:setReference(data)
	return data
end

