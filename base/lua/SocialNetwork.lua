-------------------------------------------------------------------------------------------
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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

SocialNetwork_ = {
	type_ = "SocialNetwork",
	--- Add a new connection to the SocialNetwork.
	-- @param connection An Agent.
	-- @param weight A number representing the weight of the connection (default nil - no weight).
	-- @usage sn:add(agent)
	-- sn:add(agent, 0.5)
	add = function(self, connection, weight)
		if type(connection) ~= "Agent" then
			if connection == nil then
				mandatoryArgumentError("#1")
			else
				incompatibleTypeError("#1", "Agent", connection)
			end
		end

		if weight == nil then
			weight = 1
		elseif type(weight) ~= "number"  then
			incompatibleTypeError("#2", "positive number", weight)
		elseif weight < 0 then
			incompatibleValueError("#2", "positive number", weight)
		end

		local id = connection.id
		if id == nil then
			customError("Agent should have an id in order to be added to a SocialNetwork.")
		elseif self.connections[id] ~= nil then
			customWarning("Agent '"..id.."' already belongs to the SocialNetwork.")
			return false
		end
		
		self.connections[id] = connection
		self.weights[id] = weight
		self.count = self.count + 1
	end,
	--- Remove all Agents from the SocialNetwork. In practice, it has almost the same behavior
	-- as calling SocialNetwork() again.
	-- @usage sn:clear()
	clear = function(self)
		self.count = 0
		self.connections = {}
		self.weights = {}
	end,
	--- Return a number with the weight of a given connection.
	-- @param connection An Agent.
	-- @usage print(sn:getWeight(agent))
	getWeight = function(self, connection)
		if type(connection) ~= "Agent" then
			if connection == nil then
				mandatoryArgumentError("#1")
			else
				incompatibleTypeError("#1", "Agent", connection)
			end
		end

		local id = connection.id

		if id == nil then
			customError("Agent does not belong to the SocialNetwork because it does not have an id.")
		elseif self.connections[id] == nil then
			customError("Agent '"..id.."' does not belong to the SocialNetwork.")
		end

		return self.weights[id]
	end,
	--- Return whether a given Agent belongs to the SocialNetwork.
	-- @param connection An Agent.
	-- @usage if sn:isConnection(agent) then
	--     print("not connected")
	-- end
	isConnection = function(self, connection)
		if type(connection) ~= "Agent" then
			if connection == nil then
				mandatoryArgumentError("#1")
			else
				incompatibleTypeError("#1", "Agent", connection)
			end
		end
		return self.connections[connection.id] ~= nil
	end,
	--- Return whether the SocialNetwork does not contain any connection.
	-- @usage if sn:isEmpty() then
	--     print("empty")
	-- end
	isEmpty = function(self)
		return self.count == 0
	end,
	--- Remove an Agent from the SocialNetwork.
	-- @param connection An Agent.
	-- @usage sn:remove(agent)
	remove = function(self, connection)
		if type(connection) ~= "Agent" then
			if connection == nil then
				mandatoryArgumentError("#1")
			else
				incompatibleTypeError("#1", "Agent", connection)
			end
		end

		local id = connection.id
		if self.connections[id] == nil then
			customWarning("Trying to remove an Agent that does not belong to the SocialNetwork.")
		else
			self.connections[id] = nil
			self.weights[id] = nil
			self.count = self.count - 1
		end
	end,
	--- Return a random Agent from the SocialNetwork.
	-- @usage agent = sn:sample()
	sample = function(self)
		if self:isEmpty() then
			customError("It is not possible to sample the SocialNetwork because it is empty.")
		end

		local pos = Random():integer(1, self.count)

		local count = 1
		local result
		forEachOrderedElement(self.connections, function(_, value)
			if count == pos then
				result = value
				return false
			end
			count = count + 1
		end)
		return result
	end,
	--- Update the weight of a connection.
	-- @param connection An Agent.
	-- @param weight A number pointing out the new weight.
	-- @usage sn:setWeight(agent, 0.001)
	setWeight = function(self, connection, weight)
		if type(connection) ~= "Agent" then
			if connection == nil then
				mandatoryArgumentError("#1")
			else
				incompatibleTypeError("#1", "Agent", connection)
			end
		elseif type(weight) ~= "number" then
			if weight == nil then
				mandatoryArgumentError("#2")
			else
				incompatibleTypeError("#2", "positive number", weight)
			end
		elseif weight < 0 then
			incompatibleValueError("#2", "positive number", weight)
		end

		local id = connection.id

		if id == nil then
			customError("Agent does not belong to the SocialNetwork because it does not have an id.")
		elseif self.connections[id] == nil then
			customError("Agent '"..id.."' does not belong to the SocialNetwork.")
		end

		self.weights[id] = weight
	end,
	--- Retrieve the number of connections of the SocialNetwork. Deprecated. Use # instead.
	-- @usage sn:size()
	size = function(self)
		deprecatedFunctionWarning("size", "operator #")
		return #self
	end
}

metaTableSocialNetwork_ = {
	__index = SocialNetwork_,
	--- Retrieve the number of connections of the SocialNetwork.
	-- @name #
	-- @usage print(#sn)
	__len = function(self)
		return self.count
	end,
	__tostring = tostringTerraME
}

--- SocialNetwork represents relations between Agents. It is a set of pairs (connection, 
-- weight), where connection is an Agent and weight
-- is a number storing the relation's strength. This type is used to create relations from
-- scratch to be used by Agent:addSocialNetwork(). To create well established SocialNetworks see
-- Society:createSocialNetwork(). Calling Utils:forEachConnection()
-- from an Agent traverses one of its SocialNetworks.
-- @output connections The connections with the Agents of the SocialNetWork.
-- @output weights The weights of the Agents in the SocialNetwork.
-- @output count The number of Agents in the SocialNetwork.
-- @usage sn = SocialNetwork()
--  sn = SocialNetwork{}
function SocialNetwork(data)
	if data == nil then
		data = {}
	else
		verifyNamedTable(data)
	end

	checkUnnecessaryParameters(data, {""}) -- this function takes zero parameters

	setmetatable(data, metaTableSocialNetwork_)
	data:clear()

	return data
end

