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
-- Author: Pedro R. Andrade (pedro.andrade@inpe.br)
--#########################################################################################

Group_ = {
	type_ = "Group",
	--- Add a new Agent to the Group. It returns a boolean value indicating whether the Agent was 
	-- sucessfully added.
	-- @param agent The Agent to be added.
	-- @usage group:add(agent)
	add = function(self, agent)
		mandatoryArgument(1, "Agent", agent)

		table.insert(self.agents, agent)
	end,
	--- Clone the Group. It returns a copy  with the same parent, select, greater and Agents.
	-- @usage group:clone()
	clone = function(self)
		local cloneG = Group{
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}
		forEachAgent(self, function(agent)
			cloneG:add(agent)
		end)
		return cloneG
	end,
	--- Apply a filter over the original Society.
	-- @param f A function(agent)-> boolean, such as the argument select.
	-- @usage group:filter(function(agent)
	--     return agent.age > 18
	-- end)
	filter = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.select = f end

		if self.parent == nil then
			customError("It is not possible to filter a Group without a parent.")
		end
		self.agents = {}

		if type(self.select) == "function" then
			forEachAgent(self.parent, function(agent)
				if self.select(agent) then
					table.insert(self.agents, agent)
				end
			end)
		else
			forEachAgent(self.parent, function(agent)
				table.insert(self.agents, agent)
			end)
		end
	end,
	--- Randomizes the Agents, changing the traversing order.
	-- @usage group:randomize()
	randomize = function(self)
		local randomObj = Random()

		local numagents = #self
		for i = 1, numagents do
			local pos1 = randomObj:integer(1, numagents)
			local pos2 = randomObj:integer(1, numagents)
			local agent1 = self.agents[pos1]
			self.agents[pos1] = self.agents[pos2]
			self.agents[pos2] = agent1
		end
	end,
	--- Rebuild the Group from the original data using the last filter and sort functions.
	-- @usage group:rebuild()
	rebuild = function(self)
		self:filter()
		self:sort()
	end,
	--- Sort the current Society subset. It returns whether the current Society was sorted.
	-- @param f A function(ag1, ag2)-> boolean, an ordering function with the same 
	-- signature of argument greater.
	-- @see Utils:greaterByAttribute
	-- @usage group:sort(function(ag1, ag2)
	--     return ag1.money > ag2.money
	-- end)
	sort = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.greater = f end

		if type(self.greater) == "function" then
			table.sort(self.agents, self.greater)
		end
	end
}

setmetatable(Group_, metaTableSociety_)

metaTableGroup_ = {
	__index = Group_,
	--- Return the number of Agents of the Group.
	-- @usage print(#group)
	__len = function(self)
		return #self.agents
	end,
	__tostring = tostringTerraME
} 

--- Type that defines an ordered selection over a Society. It inherits Society; therefore 
-- it is possible to apply all functions of such type to a Group. For instance, calling 
-- Utils:forEachAgent() also traverses Groups.
-- @param data.target The Society over which the Group will take place.
-- @param data.select A function(Agent)->boolean, to filter the Society. Note that, according 
-- to Lua language, if this function returns anything but false or nil, the Agent will be added 
-- to the Group. If this argument is missing, all Agents will be included in the Group.
-- @param data.greater A function(Agent, Agent)->boolean, to sort the generated subset of Agents. It 
-- returns true if the first one has priority over the second one. See Utils:greaterByAttribute() 
-- as a predefined option to sort objects. 
-- @param data.build A boolean value indicating whether the Group will be computed or not when created.
-- @usage group = Group {
--     target = society,
--     select = function(agent)
--         return agent.money > 90
--     end,
--     greater = function(a, b)
--         return a.money > b.money
--     end
-- }
--
-- groupBySize = Group {target = society, greater = function(a1, a2)
--     return a1.size > a2.size
-- end}
-- @output agents A vector of Agents pointed by the Group.
-- @output parent The Society where the Group takes place.
-- @output select The last function used to filter the Group.
-- @output greater The last function used to sort the Group.
function Group(data)
	verifyNamedTable(data)

	checkUnnecessaryArguments(data, {"target", "build", "select", "greater"})

	if type(data.target) ~= "Society" and type(data.target) ~= "Group" and data.target ~= nil then
		incompatibleTypeError("target", "Society, Group, or nil", data.target)
	end

	defaultTableValue(data, "build", true)

	data.parent = data.target
	if data.parent ~= nil then
		-- Copy the functions from the parent to the Group (only those that do not exist)
		forEachElement(data.parent, function(idx, value, mtype)
			if mtype == "function" and data[idx] == nil then
				data[idx] = value
			end
		end)
	end

	data.target = nil

	optionalTableArgument(data, "select", "function")
	optionalTableArgument(data, "greater", "function")

	data.agents = {}

	setmetatable(data, metaTableGroup_)

	if data.build and data.parent then
		data:rebuild()
		data.build = nil
	end

	return data
end

