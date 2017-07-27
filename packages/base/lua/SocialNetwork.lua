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

SocialNetwork_ = {
	type_ = "SocialNetwork",
	--- Add a new connection to the SocialNetwork.
	-- @arg connection An Agent.
	-- @arg weight A number representing the weight of the connection). The default value is 1.
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2, 0.5)
	-- print(#sn)
	add = function(self, connection, weight)
		mandatoryArgument(1, "Agent", connection)
		optionalArgument(2, "number", weight)

		if weight == nil then weight = 1 end

		local id = connection.id
		if id == nil then
			customError("Agent should have an id in order to be added to a SocialNetwork.")
		elseif self.connections[id] ~= nil then
			customError("Agent '"..id.."' already belongs to the SocialNetwork.")
		else
			self.connections[id] = connection
			self.weights[id] = weight
			self.count = self.count + 1
		end
	end,
	--- Remove all Agents from the SocialNetwork. In practice, it has the same behavior
	-- of calling SocialNetwork() again if the SocialNetwork was not added to any Agent.
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2)
	--
	-- sn:clear()
	-- print(#sn)
	clear = function(self)
		self.count = 0
		self.connections = {}
		self.weights = {}
	end,
	--- Return a number with the weight of a given connection.
	-- @arg connection An Agent.
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2, 0.5)
	--
	-- print(sn:getWeight(agent1))
	-- print(sn:getWeight(agent2))
	getWeight = function(self, connection)
		mandatoryArgument(1, "Agent", connection)

		local id = connection.id

		if id == nil then
			customError("Agent does not belong to the SocialNetwork because it does not have an id.")
		elseif self.connections[id] == nil then
			customError("Agent '"..id.."' does not belong to the SocialNetwork.")
		end

		return self.weights[id]
	end,
	--- Return whether a given Agent belongs to the SocialNetwork.
	-- @arg connection An Agent.
	-- @usage sn = SocialNetwork()
	-- agent = Agent{id = "1"}
	--
	-- sn:add(agent)
	--
	-- if sn:isConnection(agent) then
	--     print("connected")
	-- end
	isConnection = function(self, connection)
		mandatoryArgument(1, "Agent", connection)
		return self.connections[connection.id] ~= nil
	end,
	--- Return whether the SocialNetwork does not contain any Agent.
	-- @usage sn = SocialNetwork()
	--
	-- if sn:isEmpty() then
	--     print("empty")
	-- end
	isEmpty = function(self)
		return self.count == 0
	end,
	--- Remove an Agent from the SocialNetwork.
	-- @arg connection An Agent.
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2)
	--
	-- sn:remove(agent1)
	-- print(#sn)
	remove = function(self, connection)
		mandatoryArgument(1, "Agent", connection)

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
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2)
	--
	-- agent = sn:sample()
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
	-- @arg connection An Agent.
	-- @arg weight A number with the new weight.
	-- @usage sn = SocialNetwork()
	-- agent1 = Agent{id = "1"}
	-- agent2 = Agent{id = "2"}
	--
	-- sn:add(agent1)
	-- sn:add(agent2, 0.5)
	-- sn:setWeight(agent1, 0.001)
	--
	-- print(sn:getWeight(agent1))
	setWeight = function(self, connection, weight)
		mandatoryArgument(1, "Agent", connection)
		mandatoryArgument(2, "number", weight)

		local id = connection.id

		if id == nil then
			customError("Agent does not belong to the SocialNetwork because it does not have an id.")
		elseif self.connections[id] == nil then
			customError("Agent '"..id.."' does not belong to the SocialNetwork.")
		end

		self.weights[id] = weight
	end
}

metaTableSocialNetwork_ = {
	__index = SocialNetwork_,
	--- Retrieve the number of connections in the SocialNetwork.
	-- @usage sn = SocialNetwork()
	-- print(#sn)
	__len = function(self)
		return self.count
	end,
	__tostring = _Gtme.tostring
}

--- SocialNetwork represents relations between A gents. It is a set of pairs (connection,
-- weight), where connection is an A gent and weight
-- is a number storing the relation's strength. \
-- This type is used to create relations from
-- scratch to be used by Agent:addSocialNetwork(). To create well-established SocialNetworks see
-- Society:createSocialNetwork().
-- It is recommended that a SocialNetwork should contain only Agents that belong to the same Society,
-- as it guarantees that all its Agents have unique identifiers.
-- Calling Utils:forEachConnection()
-- from an Agent traverses one of its SocialNetworks.
-- @output connections The connections with the Agents of the SocialNetWork.
-- @output weights The weights of the Agents in the SocialNetwork.
-- @output count The number of Agents in the SocialNetwork.
-- @usage sn = SocialNetwork()
-- sn = SocialNetwork{}
-- @see Society:createSocialNetwork
function SocialNetwork()
	local data = {}

	setmetatable(data, metaTableSocialNetwork_)
	data:clear()

	return data
end

