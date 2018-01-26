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

local instance

local function timeToString(t)
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

local createBlock = function(name)
	return {
		type_ = "Block",
		name = name,
		running = false,
		count = 0,
		steps = 0,
		total = 0,
		uptime = function(self)
			if self.running then
				return self.total + os.time() - self.startTime
			else
				return self.total
			end
		end,
		report = function(self)
			return { -- SKIP
				name = self.name, -- SKIP
				count = self.count, -- SKIP
				time = timeToString(self:uptime()), -- SKIP
				average = timeToString(self:uptime() / math.max(1, self.count)) -- SKIP
			} -- SKIP
		end,
		eta = function(self)
			if self.steps == 0 then
				customError("'Profiler():steps(\""..self.name.."\")' must be set before calling 'Profiler():eta(\""..self.name.."\")'.")
			end

			return (self.steps - self.count) * (self:uptime() / math.max(1, self.count))
		end,
		start = function(self)
			self.startTime = os.time()
			self.count = self.count + 1
			self.running = true
		end,
		stop = function(self)
			if self.running then
				self.endTime = os.time()
				self.total = self.total + self.endTime - self.startTime
				self.running = false
			end

			return self.endTime - self.startTime
		end
	}
end

local Stack = {
	top = function(stack)
		return stack[#stack]
	end,
	push = function(stack, value)
		table.insert(stack, value)
	end,
	pop = function(stack)
		local value = stack[#stack]
		table.remove(stack)
		return value
	end,
	remove = function(stack, value)
		for i, v in pairs(stack) do
			if v == value then
				table.remove(stack, i)
				break
			end
		end
	end
}

Profiler_ = {
	type_ = "Profiler",
	blocks = {},
	stack = {},
	--- Create and start a new block.
	-- @arg name A string with the block name.
	-- @usage Profiler():start("block")
	-- Profiler():stop("block")
	start = function(self, name)
		mandatoryArgument(1, "string", name)
		local block = self.blocks[name]
		if block and block.running then
			customWarning(string.format("Block '%s' has already been started. Please, stop the block before re-start it.", block.name))
			stop(block.name)
		elseif not block then
			block = createBlock(name)
			self.blocks[name] = block
		end

		block:start()
		Stack.push(self.stack, block)
	end,
	--- Return the current block.
	-- @usage Profiler():start("block")
	-- print(Profiler():current().name) -- block
	-- Profiler():stop("block")
	current = function(self)
		return Stack.top(self.stack)
	end,
	--- Return how many times a given block has started.
	-- @arg name A string with the block name. If the name is not informed, then it returns the count of the current block.
	-- @usage Profiler():start("block")
	-- print(Profiler():count("block")) -- 1
	-- Profiler():stop("block")
	count = function(self, name)
		optionalArgument(1, "string", name)
		local block = self.blocks[name or self:current().name]
		if not block then
			customError(string.format("Block '%s' was not found.", name))
		end

		return block.count
	end,
	--- Return how much time was spent on the block up to last stop.
	-- It returns two representations: a string with a human-like representation of the time
	-- and a number with the time in seconds.
	-- @arg name A string with the block name. If the name is not informed, then it returns the uptime of the current block.
	-- @usage Profiler():start("block")
	-- Profiler():stop("block")
	-- stringTime, numberTime = Profiler():uptime("block")
	uptime = function(self, name)
		optionalArgument(1, "string", name)
		local block = self.blocks[name or self:current().name]
		if not block then
			customError(string.format("Block '%s' was not found.", name))
		end

		local time = block:uptime()
		return timeToString(time), time
	end,
	--- Stop to measure the time of a given block. It also returns how much time was spent with the block since it was started.
	-- in two representations: a string with a human-like representation of the time and a number with the time in seconds.
	-- @arg name A string with the block name. If the name is not informed, then it stops and return the uptime of the current block.
	-- @usage Profiler():start("block")
	-- stringTime, numberTime = Profiler():stop("block")
	stop = function(self, name)
		optionalArgument(1, "string", name)
		if name == "main" or (not name and self:current() and self:current().name == "main") then
			customWarning("The block 'main' cannot be stopped.")
			return self:uptime(name)
		end

		local block
		if not name then
			block = Stack.pop(self.stack)
		elseif self.blocks[name] then
			block = self.blocks[name]
			Stack.remove(self.stack, block)
		else
			customError(string.format("Block '%s' was not found.", name))
		end

		local time = block:stop()
		return timeToString(time), time
	end,
	--- Clean the Profiler, removing all blocks and restarting its execution time.
	-- @usage -- DONTRUN
	-- Profiler():clean()
	clean = function(self)
		self.blocks = {}
		self.stack = {}
		self:start("main")
	end,
	--- Show a report with the time and amount of times each block was executed.
	-- @usage Profiler():report()
	report = function(self)
		print(string.format("%-30s%-20s%-30s%s", "Block", "Count", "Time", "Average")) -- SKIP
		forEachOrderedElement(self.blocks, function(_, block)
			local report = block:report() -- SKIP
			print(string.format("%-30s%-20d%-30s%s", report.name, report.count, report.time, report.average)) -- SKIP
		end)

		local total = self:uptime("main")
		print("Total execution time: "..total) -- SKIP
	end,
	--- Define how many times a given block will be executed.
	-- @arg name A string with the block name.
	-- @arg quantity Number of steps a given block will execute.
	-- @usage Profiler():start("block")
	-- Profiler():steps("block", 5)
	-- Profiler():stop("block")
	steps = function(self, name, quantity)
		mandatoryArgument(1, "string", name)
		mandatoryArgument(2, "number", quantity)
		integerArgument(2, quantity)
		positiveArgument(2, quantity)
		if not self.blocks[name] then -- allows to set steps before start (useful?)
			self.blocks[name] = createBlock(name)
		end

		self.blocks[name].steps = quantity
	end,
	--- Estimate and return the time to execute all repetitions of a given block. It returns in two representations:
	-- a string with a human-like representation of the time and a number with the time in seconds.
	-- @arg name A string with the block name. If the name is not informed, then it returns the "eta" of the current block.
	-- @usage Profiler():steps("block", 5)
	-- Profiler():start("block")
	-- Profiler():stop("block")
	-- eta_string, eta_number = Profiler():eta("block")
	-- print(eta_string.." left...")
	-- print(eta_number.." seconds to finish...")
	eta = function(self, name)
		optionalArgument(1, "string", name)
		local block = self.blocks[name or self:current().name]
		if not block then
			customError(string.format("Block '%s' was not found.", name))
		end

		local time = block:eta()
		return timeToString(time), time
	end
}

metaTableProfiler_ = {
	__index = Profiler_
}

--- The type Profiler is used to measure the simulation/execution time of a model or the time to execute small blocks of a model.
-- The user can inform Profiler how many times a block will execute. Thus it can estimate the time left to finish the execution of
-- a block. This type also summaries all its measures and show a report containing how many times a block was executed, the time
-- to execute all repetitions of this block and the average time of these repetitions.
-- @usage Profiler():start("test")
-- Profiler():stop("test")
-- print(Profiler():uptime("test"))
function Profiler()
	if instance then
		return instance
	end

	local data = {}
	setmetatable(data, metaTableProfiler_) -- SKIP
	instance = data -- SKIP
	instance:clean()
	return data
end
