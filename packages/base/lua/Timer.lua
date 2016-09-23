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

Timer_ = {
	type_ = "Timer",
	--- Add a new Event to the timer. If the Event has a start time less than the current
	-- simulation time then add() will prompt a warning (but the Event will be added).
	-- @arg event An Event or table.
	-- When adding a table, this function converts the table into an Event.
	-- @usage timer = Timer{}
	--
	-- timer:add(Event{action = function() end})
	add = function(self, event)
		if type(event) == "table" then
			event = Event(event)
		end

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
		while pos <= quant and (time > evp.time or (time == evp.time and prio >= evp.priority)) do
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
	-- timer:run(13)
	-- print(cs:dist()) -- 200
	--
	-- timer:run(20)
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
	--- Remove all the Events from the Timer. Note that, when this function is called
	-- within an action of an Event, if such function does not return false, it
	-- will be added to the Timer again after the end of its execution. This
	-- means that the simulation will continue with a single Event until its final time.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:clear()
	clear = function(self)
		self.events = {}
	end,
	--- Run the simulation.
	-- @deprecated Timer:run
	execute = function()
		deprecatedFunction("execute", "run")
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
	-- timer:run(10)
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
	-- timer:run(10)
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
	-- timer:run(10)
	--
	-- timer:reset()
	-- print(timer:getTime())
	reset = function(self)
		self.time = -math.huge
	end,
	--- Run the Timer until a given final time. It manages the Event queue according to their execution
	-- times and priorities. The Event with lower time will be executed in each step. If there are two
	-- Events to be executed at the same time, it executes the one with lower priority. If both have
	-- the same priority, it executes the one that was scheuled first for that time.
	-- In order to activate an Event, the Timer executes its action, passing the Event itself as argument.
	-- If the action of the Event does not return false, the Event is scheduled to execute again according to
	-- its period. The Timer then repeats its execution again and again. It stops only when all its
	-- Events are scheduled to execute after the final time, or when there are no remaining Events.
	-- @arg finalTime A number representing the final time of the simulation.
	-- This argument is mandatory.
	-- @usage timer = Timer{
	--     Event{action = function() print("step") end}
	-- }
	--
	-- timer:run(10)
	run = function(self, finalTime)
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

				if math.abs(ev.time - floor) < sessionInfo().round then
					ev.time = floor
				elseif math.abs(ev.time - ceil) < sessionInfo().round then
					ev.time = ceil
				end
				self:add(ev)
			end
		end
	end,

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

--- A Timer is an event-based scheduler that runs the simulation. It contains a
-- set of Events, allowing the simulation to work with processes that start
-- independently and act in different periodicities. As default, it execute the Events
-- in the order they were declared, but the arguments of Event (start, priority, and period)
-- can change this order. Once a Timer has a given simulation time, it ensures that all the
-- Events before that time were already executed. See Timer:run() for more details.
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
-- timer:run(10)
function Timer(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			customError(tableArgumentMsg())
		end
	end

	local cObj = TeTimer()

	local mdata = {
		events = {},
		time = -math.huge,
	}

	setmetatable(mdata, metaTableTimer_)

	forEachOrderedElement(data, function(idx, value, mtype)
		if mtype == "Event" then
			mdata:add(value)
		else
			incompatibleTypeError(idx, "Event", value)
		end
	end)
 
	mdata.cObj_ = cObj
	cObj:setReference(mdata)
	return mdata
end

