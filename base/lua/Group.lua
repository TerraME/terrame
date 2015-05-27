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
	--- Add a new Agent to the Group. It will be added to the end of the list of Agents.
	-- @arg agent An Agent.
	-- @usage group:add(agent)
	add = function(self, agent)
		mandatoryArgument(1, "Agent", agent)

		table.insert(self.agents, agent)
	end,
	--- Return a copy of the Group. It has the same parent, select, greater and Agents.
	-- Any change in the cloned Group will not affect the original one.
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
	--- Apply a filter over the Society used as target for the Group. It replaces the previous
	-- set of Agents belonging to the Group.
	-- @arg f A function (Agent)->boolean, working in the same way of the argument select to
	-- create the Group. If this argument is missing, this function
	-- filters the Society with the function used as argument for the last call to filter itself,
	-- or then the value of argument select used to build the Group. When it cannot find any
	-- function to be used, this function will add all the Agents of the Society to the Group.
	-- @usage group:filter(function(agent)
	--     return agent.age >= 18
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
	--- Randomize the Agents of the Group. It will change the traversing order used by
	-- Utils:forEachAgent().
	-- @usage group:randomize()
	randomize = function(self)
		local randomObj = Random()

		local numagents = #self
		local agents = self.agents

		for i = numagents, 2, -1 do
			local r = randomObj:integer(1, i)
			agents[i], agents[r] = agents[r], agents[i]
		end
	end,
	--- Rebuild the Group from the Society used as target.
	-- It is a shortcut to Group:filter() and then Group:sort().
	-- @usage group:rebuild()
	rebuild = function(self)
		self:filter()
		self:sort()
	end,
	--- Sort the current Society subset. It updates the traversing order of the Group.
	-- @arg f An ordering function (Agent, Agent)->boolean, working in the same way of
	-- argument greater to create the Group. If this argument is missing, this function
	-- sorts the Group with the function used as argument for the last call to sort itself,
	-- or then the value of argument greater used to build the Group. When it cannot find
	-- any function to be used, it shows a warning.
	-- @see Utils:greaterByAttribute
	-- @usage group:sort(function(ag1, ag2)
	--     return ag1.age > ag2.age
	-- end)
	sort = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.greater = f end

		if type(self.greater) == "function" then
			table.sort(self.agents, self.greater)
		else
			customWarning("Cannot sort the Group because there is no previous function.")
		end
	end
}

setmetatable(Group_, metaTableSociety_)

metaTableGroup_ = {
	__index = Group_,
	--- Return the number of Agents in the Group.
	-- @usage print(#group)
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
-- @arg data.greater A function (Agent, Agent)->boolean to sort the Group. Such function must
-- return true if the first Agent has priority over the second one. When using this argument,
-- Group compares each pair of Agents to establish an execution order to be used by
-- Utils:forEachAgent(). As default, the Group will not be ordered and so Utils:forEachCell()
-- will run in the order the Agents were pushed into the Society. See
-- Utils:greaterByAttribute() for predefined options for this argument.
-- @arg data.build A boolean value indicating whether the Group should be computed when created.
-- The default value is true.
-- @usage group = Group{
--     target = society,
--     select = function(agent)
--         return agent.size > 90
--     end,
--     greater = function(a, b)
--         return a.size > b.size
--     end
-- }
--
-- groupBySize = Group{target = society, greater = function(a1, a2)
--     return a1.size > a2.size
-- end}
-- @output agents A vector with Agents of the Group.
-- @output parent The Society used by the Group (its target).
-- @output select The last function used to filter the Group.
-- @output greater The last function used to sort the Group.
function Group(data)
	verifyNamedTable(data)

	verifyUnnecessaryArguments(data, {"target", "build", "select", "greater"})

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
		data:filter()
		if data.greater then data:sort() end
		data.build = nil
	end

	return data
end

