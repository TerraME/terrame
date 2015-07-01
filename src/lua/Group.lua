-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  ABM extension for TerraME
--  Last change: April/2012 
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
--      Pedro Andrade
globalGroupIdCounter = 0

Group_ = {
	type_ = "Group",
	--- Add a new Agent to the Group. It returns a boolean value indicating whether the Agent was sucessfully added.
	-- @param agent The Agent to be added.
	-- @usage group:add(agent)
	add = function(self, agent)
		if type(agent) ~= "Agent" then
			incompatibleTypesErrorMsg("#1","Agent", type(agent), 3)
		else
			table.insert(self.agents, agent)
			return true
		end
	end,

	--- Clone the Group. It returns a copy  with the same parent, select, greater and Agents.
	-- @usage group:clone()
	clone = function(self)
		globalGroupIdCounter = globalGroupIdCounter + 1
		local cloneG = Group{
			id = "grp".. globalGroupIdCounter,
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
		local lv = 3
		--if flagRebuild then lv = 4 end

		if f == nil then     
			if self.select then
				f = self.select
				defaultValueWarningMsg("#1","function", "self.select", lv)
			else
				incompatibleTypesErrorMsg("#1","function", type(f), lv)
			end
		elseif type(f) ~= "function" then
			incompatibleTypesErrorMsg("f","function", type(f), lv) 
		end
		self:clear()

		forEachAgent(self.parent, function(agent)
			if f(agent) then self:add(agent) end
		end)
		return true
	end,

	--- Randomizes the Agents, changing the traversing order.
	-- @param randomObj a Random object. As default, TerraME uses its internal random number generator.
	-- @usage group:randomize()
	randomize = function(self, randomObj)
		if(not randomObj or type(randomObj) ~= "Random") then
			randomObj = TME_GLOBAL_RANDOM      
		end

		local numagents = self:size()
		for i = 1, numagents do
			local pos1 = randomObj:integer(1, numagents)
			local pos2 = randomObj:integer(1, numagents)
			local ag1 =  self:getAgent(pos1)
			self.agents[pos1] = self:getAgent(pos2)
			self.agents[pos2] = ag1
		end
	end,

	--- Rebuild the Group from the original data using the last filter and sort functions.
	-- @usage group:rebuild()
	rebuild = function(self)
		if self.select ~= nil then
			flagRebuild = true
			self:filter(self.select)
			flagRebuild = false
		end
		if self.greater ~= nil then	self:sort(self.greater) end
	end,

	--- Sort the current Society subset. It returns whether the current Society was sorted.
	-- @param greaterThan A function(ag1, ag2)-> boolean, an ordering function with the same signature of argument greater.
	--@see Utils:greaterByAttribute
	-- @usage group:sort(function(ag1, ag2)
	--     return ag1.money > ag2.money
	-- end)
	sort = function(self, greaterThan)
		if type(greaterThan) == "function" then
			self.greater = greaterThan
		elseif self.greater == nil then
			return false
		else
			greaterThan = self.greater
		end
		table.sort(self.agents, greaterThan)
	end,
	--#- Set the argument target on the constructor.
	-- @param target The Society over which the Group will take place.
	-- @return 'true' if the target was associated, 'false' otherwise.
	setTarget = function(self,target)
		if type(target) ~= "Society" then
			incompatibleTypesErrorMsg("target", "Society", type(target), 3)
		end
		self.target = target
		return true
	end,  
	--#- Retrieves the target argument on constructor
	getTarget = function(self)
		return self.target
	end,
	--- Retrieves the select argument constructor.
	getSelect = function(self)
		return self.select
	end,
	--- Retrieves the greater argument on constructor.
	getGreater = function(self)
		return self.greater
	end,
	--#- Set the argument build on the constructor.
	-- @param build A boolean value indicating whether the Group will be computed
	-- or not when created. Default is true.
	-- @return 'true' if the build was associated, 'false' otherwise.
	setBuild = function(self, build)
    if build == nil then
      build = false
      defaultValueWarningMsg("#1", "boolean", "false", 3)
		elseif type(build) ~= "boolean" then
			incompatibleTypesErrorMsg("build", "boolean", type(build), 3)
		end
		self.build = build
		return true
	end,

	--#- Retrieves the build argument on constructor.
	getBuild = function(self)
		return self.build
	end
}

setmetatable(Group_, metaTableSociety_)
local metaTableGroup_ = {__index = Group_} 


--- A Group Type that defines an ordered selection over a Society. It inherits Society; therefore 
-- it is possible to apply all functions of such type to a Group. For instance, calling forEachAgent() also traverses Groups.
-- @param data.target The Society over which the Group will take place.
-- @param data.select A function(Agent) : boolean, to filter the Society, adding to the Group only those Agents whose returning value is true.
-- @param data.greater A function(Agent, Agent) : boolean, to sort the generated subset of Agents. It returns true if the first one has priority over the second one.
-- @param data.build A boolean value indicating whether the Group will be computed or not when created.  
-- @see Utils:forEachAgent
-- @see Utils:greaterByAttribute
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
Group = function(data)
	if data == nil then customErrorMsg("Error: Attribute table is nil.", 3) end
	if data.id == nil then
		globalGroupIdCounter = globalGroupIdCounter + 1
		data.id = "grp".. globalGroupIdCounter
		defaultValueWarningMsg("#1", "string", data.id, 3)  
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("#1", "string", type(data.id), 3)
	end  

	if type(data.target) ~= "Society" and data.build ~= false then
		incompatibleTypesErrorMsg("target", "Society", type(data.target), 3)
	end

	if data.select == nil then
		data.select = function(cell) return true end
		defaultValueWarningMsg("select", "function", "function 'bool = function(cell) return true end'", 3)    
	elseif type(data.select) ~= "function" then
		incompatibleTypesErrorMsg("select","function",type(data.select), 3)
	end

	if data.build == nil then
		data.build = true
		defaultValueWarningMsg("build", "boolean", "true", 3)  
	elseif type(data.build) ~= "boolean" then
		incompatibleTypesErrorMsg("build","boolean", type(data.build), 3)   
	end	

	if data.greater == nil then
		data.greater = function (ag1, ag2) return ag1.id > ag2.id end
		defaultValueWarningMsg("greater", "function", "function bool = function (ag1, ag2) return ag1.id > ag2.id end", 3)     
	elseif type(data.greater) ~= "function" then
		incompatibleTypesErrorMsg("greater","function",type(data.greater), 3)
	end

	setmetatable(data, metaTableGroup_)
	data.parent = data.target
	data.target = nil
	data.agents = {}
	data.placements = {}

	if data.build then
		data:rebuild()
		data.build = nil
	end

	return data
end
