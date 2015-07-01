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
--      Rodrigo Reis Pereira

globalSocialNetworkIdCounter = 0

SocialNetwork_ = {
	type_ = "SocialNetwork",
	--- Add a new connection to the SocialNetwork.
	-- @param connection An Agent.
	-- @param weight A number representing the weight of the connection (default nil - no weight).
	-- @usage sn:add(agent)
	-- sn:add(agent, 0.5)
	add = function(self, connection, weight)
		-- if the modeller does not use weight, then the position in the table will be nil
		if type(connection) ~= "Agent" then
			incompatibleTypesErrorMsg("#1","Agent", type(connection), 3)
		end

    if weight == nil then
			weight = 1
			defaultValueWarningMsg("#2", "number", weight, 3)      
		elseif type(weight) ~= "number"  then
			incompatibleTypesErrorMsg("#2","positive number", type(weight), 3)
    elseif weight < 0 then
			incompatibleValuesErrorMsg("#2","positive number", weight, 3)      
		end

		id = connection:getId()
		if self.connections[id] ~= nil then return false end
		self.connections[id] = connection
		self.weights[id] = weight
		self.count = self.count + 1
		return true
	end,
	--- Remove all Agents from the SocialNetwork. In practice, it has almost the same behavior as calling SocialNetwork() again.
	-- @usage sn:clear()
	clear = function(self)
		self.count = 0
		self.connections = {}
		self.weights = {}
	end,
	--- Return the weight of a given connection.
	-- @param connection An Agent.
	-- @return A number
	-- @usage print(sn:getWeight(agent))
	getWeight = function(self, connection)
		if type(connection) ~= "Agent" then
			incompatibleTypesErrorMsg("#1","Agent", type(connection), 3)
		end
		return self.weights[connection:getId()]
	end,
	--- Return a connection given its id. 
	-- @param id The unique identifier of an Agent.
	-- @usage sn = getConnection("1")
	getConnection = function(self, id)
		if type(id) ~= "string" then
			incompatibleTypesErrorMsg("#1", "string", type(id), 3)
		end
		if self.connections[id] == nil then
			resourceNotFoundErrorMsg("id",id, 3)
		end
		return self.connections[id]
	end,
	--- Return whether a given Agent belongs to the SocialNetwork.
	-- @param connection An Agent.
	-- @usage if sn:isConnection(agent) then
	--     print("not connected")
	-- end
	isConnection = function(self, connection)
		if type(connection) ~= "Agent" then
			incompatibleTypesErrorMsg("#1", "Agent", type(connection), 3)
		end
		return self.connections[connection:getId()] ~= nil
	end,
	--- Return whether the SocialNetwork does not contain any connection.
	-- @usage if sn:isEmpty() then
	--     print("empty")
	-- end
	isEmpty = function(self)
		return self.count == 0
	end,
	-- Remove an Agent from the SocialNetwork.
	-- @param connection An Agent.
	-- @usage sn:remove(agent)
	remove = function(self, connection)
		if type(connection) ~= "Agent" then
			incompatibleTypesErrorMsg("#1", "Agent", type(connection), 3)
		end
		id = connection:getId()
		if self.connections[id] == nil then return end
		self.connections[id] = nil
		self.weights[id] = nil
		self.count = self.count - 1
    return true
	end,
	--- Return the unique identifier of the SocialNetwork. 
	-- @usage print(sn:getID())
	getId = function(self)
		return self.id
	end,
	--- Return a random Agent from the SocialNetwork.
	-- @randomObj A random object.
	-- @usage agent = sn:sample()
	sample = function(self, randomObj)
		local pos = nil
		if type(randomObj) == "Random" then
			pos = randomObj:integer(self.count)                          
		else
			pos = TME_GLOBAL_RANDOM:integer(self.count)            
		end

		count = 1
		for i, j in ipairs(self.connections) do
			if count <= pos then return j end
			count = count + 1
		end
	end,
	--- Set the unique identifier of the SocialNetwork. 
	-- @param id A string.
	setId = function(self, id)
		if(type(id) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(id), 3)
		end
		self.id = id
    return true
	end,
	-- Update the weight of a connection.
	-- @param connection An Agent.
	-- @param weight A number pointing out the new weight.
	-- @usage sn:setWeight(agent, 0.001)
	setWeight = function(self, connection, weight)
		if type(connection) ~= "Agent" then
			incompatibleTypesErrorMsg("#1", "Agent", type(connection), 3)
		end
		if type(weight) ~= "number"  then
			incompatibleTypesErrorMsg("#2","number", type(weight), 3)
    elseif weight < 0 then
			incompatibleValuesErrorMsg("#2","positive number", weight, 3)
		end
		self.weights[connection:getId()] = weight
    return true
	end,
	--- Retrieve the number of connections of the SocialNetwork.
	-- @usage print(sn:size())
	size = function(self)
		return self.count
	end
}

metaTableSocialNetwork_ = {__index = SocialNetwork_}
--- Social networks represent relations between Agents. A 
-- SocialNetwork is a set of pairs (connection, weight), where connection is an Agent
-- and weight is a number storing the relation’s strength. Calling forEachConnection()
-- from an Agent traverses one of its SocialNetworks. SocialNetworks can be built directly
-- from a Society by calling Society:createSocialNetwork().
-- @param data A table that contains the SocialNetwork attributes.
-- @param data.id The name that identify the SocialNetwork.
-- @param data.connections The connections with the Agents of the SocialNetWork.
-- @param data.weights The weights of the Agents in the SocialNetwork.
-- @param data.count The number of Agents in the SocialNetwork.
-- @usage sn = SocialNetwork()
-- @see Society:createSocialNetwork
-- @see Agent:addSocialNetwork
function SocialNetwork(data)
	if type(data) ~= "table" then
		data = {}
		defaultValueWarningMsg("#1","table", "{}", 3)
	end

	if data.id == nil then
		globalSocialNetworkIdCounter = globalSocialNetworkIdCounter+1
		data.id = "sntw".. globalSocialNetworkIdCounter
		defaultValueWarningMsg("id", "string", data.id, 3)
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("id", "string", type(data), 3) 
	end

	setmetatable(data, metaTableSocialNetwork_)
	data:clear()

	data.connections = {}
	data.weights = {}
	data.count = 0
	return data
end

