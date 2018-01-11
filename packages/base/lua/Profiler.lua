-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

local instance = nil
local START_TIME = sessionInfo().time

--- Function that returns the time in a higher-level representation.
-- @arg t The time in seconds.
-- @usage
-- local t = 3670
-- print(timeToString(t)) -- 1 hour and 1 minute
function timeToString(t)
	mandatoryArgument(1, "number", t)
	local seconds = t
	local minutes = math.floor(t / 60);     seconds = math.floor(seconds % 60)
	local hours = math.floor(minutes / 60); minutes = math.floor(minutes % 60)
	local days = math.floor(hours / 24);    hours = math.floor(hours % 24)
	local hasDay = false
	local hasHour = false
	local hasMin = false
	local str = ""
	if days > 0 then
		hasDay = true
		if days == 1 then
			str = str.."1 day"
		else
			str = str..days.." days"
		end
	end

	if hours > 0 then
		hasHour = true
		if hasDay then str = str.." and " end
		if hours == 1 then
			str = str.."1 hour"
		else
			str = str..hours.." hours"
		end
	end

	if not hasDay and minutes > 0 then
		hasMin = true
		if hasHour then str = str.." and " end
		if minutes == 1 then
			str = str.."1 minute"
		else
			str = str..minutes.." minutes"
		end
	end

	if not hasDay and not hasHour and (seconds > 0 or not hasMin) then
		if hasMin then str = str.." and " end
		if seconds == 1 then
			str = str.."1 second"
		elseif seconds < 1 then
			str = "less than one second"
		else
			str = str..string.format("%0.f seconds", seconds)
		end
	end

	return str
end

Profiler_ = {
	type_ = "Profiler",
	--- Return the execution time since TerraME was started in two representations a string with human-like representation and a number with the time in seconds.
	-- @usage elapsedTimeText, elapsedTimeNumber = Profiler():uptime()
	uptime = function(self)
		local difference = sessionInfo().time - self.startTime
		return timeToString(difference), difference
	end
}

metaTableProfiler_ = {
	__index = Profiler_
}

--- The type Profiler is used to measure the simulation/execution time of a model or the time to execute small blocks of a model.
-- The user can inform Profiler how many times a block will execute. Thus it can estimate the time left to finish the execution of
-- a block. This type also summaries all its measures and show a report containing how many times a block was executed, the time
-- to execute all repetitions of this block and the average time of these repetitions.
-- @usage print(Profiler():uptime())
function Profiler()
	if instance then
		return instance
	end

	local data = {}
	setmetatable(data, metaTableProfiler_) -- SKIP
	data.startTime = START_TIME -- SKIP
	instance = data -- SKIP
	return data
end
