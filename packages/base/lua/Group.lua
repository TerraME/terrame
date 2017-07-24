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

Group_ = {
	type_ = "Group",
	--- Add a new Agent to the Group. It will be added to the end of the list of Agents.
	-- @arg agent An Agent.
	-- @usage agent = Agent{}
	-- group = Group{}
	--
	-- group:add(agent)
	add = function(self, agent)
		mandatoryArgument(1, "Agent", agent)

		table.insert(self.agents, agent)
	end,
	--- Return a copy of the Group. It has the same parent, select, greater and Agents.
	-- Any change in the cloned Group will not affect the original one.
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{
	--     target = soc,
	--     select = function(agent) return agent.age < 10 end
	-- }
	--
	-- group2 = group:clone()
	-- print(#group)
	-- print(#group2)
	clone = function(self)
		local cloneG = Group{
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}
		forEachAgent(self, function(agent)
			table.insert(cloneG.agents, agent)
		end)

		return cloneG
	end,
	--- Apply the filter again over the Society used as target for the Group.
	-- Agents that belong to the Society but do not belong to the
	-- Group are ignored. This way, this function creates a subset
	-- over the subset of the Society.
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1},
	--     execute = function(self)
	--         self.age = self.age + 1
	--     end
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{target = soc, select = function(agent)
	--     return agent.age >= 18
	-- end}
	--
	-- group:execute()
	-- group:filter()
	filter = function(self)
		local agents = self.agents
		self.agents = {}

		if type(self.select) == "function" then
			forEachElement(agents, function(_, agent)
				if self.select(agent) then
					table.insert(self.agents, agent)
				end
			end)
		else
			customError("Cannot filter a Group without a 'select' function.")
		end
	end,
	--- Randomize the Agents of the Group. It will change the traversing order used by
	-- Utils:forEachAgent().
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{
	--     target = soc
	-- }
	--
	-- group:randomize()
	randomize = function(self)
		local randomObj = Random()

		local numagents = #self
		local agents = self.agents

		for i = numagents, 2, -1 do
			local r = randomObj:integer(1, i)
			agents[i], agents[r] = agents[r], agents[i]
		end
	end,
	--- Rebuild the Group. It works as if the Group was declared again with the same arguments.
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{
	--     target = soc,
	--     select = function(agent) return agent.age < 10 end,
	--     greater = function(a1, a2) return a1.age > a2.age end
	-- }
	--
	-- forEachAgent(group, function(agent)
	--     agent.age = agent.age + 5
	-- end)
	--
	-- group:rebuild()
	rebuild = function(self)
		if self.parent == nil then
			customError("It is not possible to rebuild a Group without a parent.")
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

		if self.random then
			self:randomize()
		elseif self.greater then
			self:sort()
		end
	end,
	--- Sort the current Society subset. It updates the traversing order of the Group.
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1},
	--     execute = function(self)
	--         self.age = self.age + Random{min = 0, max = 2}:sample()
	--     end
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{target = soc, greater = function(ag1, ag2)
	--     return ag1.age > ag2.age
	-- end}
	--
	-- group:execute()
	-- group:sort()
	sort = function(self)
		if type(self.greater) == "function" then
			table.sort(self.agents, self.greater)
		else
			customError("Cannot sort a Group without a 'greater' function.")
		end
	end
}

setmetatable(Group_, metaTableSociety_)

metaTableGroup_ = {
	__index = Group_,
	--- Return the number of Agents in the Group.
	-- @usage agent = Agent{
	--     age = Random{min = 0, max = 50, step = 1}
	-- }
	--
	-- soc = Society{
	--     instance = agent,
	--     quantity = 20
	-- }
	--
	-- group = Group{
	--     target = soc,
	--     select = function(agent) return agent.age < 10 end
	-- }
	--
	-- print(#group)
	__len = function(self)
		return #self.agents
	end,
	__tostring = _Gtme.tostring
}

--- Type that defines an ordered selection over a Society. It inherits Society; therefore
-- it is possible to apply all functions of such type to a Group. For instance, calling
-- Utils:forEachAgent() also traverses Groups.
-- @inherits Society
-- @arg data.target The Society over which the Group will take place.
-- @arg data.select A function (Agent)->boolean indicating whether an Agent of the Society should
-- belong to the Group. If this function returns anything but false or nil for a given Agent, it
-- will be added to the Group. If this argument is missing, all Agents will be included
-- in the Group.
-- @arg data.random A boolean value indicating that the Group must be shuffled. The Group will be
-- shuffled every time one calls Group:rebuild() or when the Group is an action of an Event.
-- This argument cannot be combined with argument greater.
-- @arg data.greater A function (Agent, Agent)->boolean to sort the Group. Such function must
-- return true if the first Agent has priority over the second one. When using this argument,
-- Group compares each pair of Agents to establish an execution order to be used by
-- Utils:forEachAgent(). As default, the Group will not be ordered and so Utils:forEachCell()
-- will run in the order the Agents were pushed into the Society. See
-- Utils:greaterByAttribute() for predefined options for this argument.
-- @arg data.build A boolean value indicating whether the Group should be computed when created.
-- The default value is true.
-- @usage agent = Agent{
--     age = Random{min = 10, max = 50, step = 1}
-- }
--
-- soc = Society{
--     instance = agent,
--     quantity = 20
-- }
--
-- group = Group{
--     target = society,
--     select = function(agent)
--         return agent.age > 20
--     end
-- }
--
-- groupBySize = Group{
--     target = society,
--     greater = function(a1, a2)
--         return a1.age > a2.age
--     end
-- }
-- @output agents A vector with Agents of the Group.
-- @output parent The Society used by the Group (its target).
-- @output select The last function used to filter the Group.
-- @output greater The last function used to sort the Group.
function Group(data)
	verifyNamedTable(data)

	verifyUnnecessaryArguments(data, {"target", "build", "select", "greater", "random"})

	optionalTableArgument(data, "target", {"Society", "Group"})

	if data.greater and data.random then
		customError("It is not possible to use arguments 'greater' and 'random' at the same time.")
	end

	defaultTableValue(data, "build", data.target ~= nil)
	defaultTableValue(data, "random", false)

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

	if data.build then
		if not data.parent then
			customError("It is not possible to build a Group without a parent.")
		end

		data:rebuild()
	end

	data.build = nil
	return data
end

