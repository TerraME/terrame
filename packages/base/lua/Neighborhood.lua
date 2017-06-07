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

Neighborhood_ = {
	type_ = "Neighborhood",
	--- Add a new Cell to the Neighborhood. If the Neighborhood already contains such Cell
	-- then it will stop with an error.
	-- @arg cell A Cell to be added.
	-- @arg weight A number representing the weight of the connection. The default value is 1.
	-- @usage n = Neighborhood()
	-- c = Cell{}
	-- n:add(c, 0.02)
	add = function(self, cell, weight)
		mandatoryArgument(1, "Cell", cell)
		optionalArgument(2, "number", weight)

		if weight == nil then weight = 1 end

		local id = cell:getId()
		if id == nil then
			customError("Cell should have an id in order to be added to a Neighborhood.") -- SKIP
		end

		for i = 1, #self do
			if self.connections[i] == cell then
				customWarning("Cell '"..id.."' already belongs to the Neighborhood.")
			end
		end

		table.insert(self.connections, cell)
		table.insert(self.weights, weight)
	end,
	--- Remove all Cells from the Neighborhood. In practice, it has the same behavior
	-- as calling Neighborhood() again if the Neighborhood was not added to any Cell.
	-- @usage n = Neighborhood()
	-- n:clear()
	clear = function(self)
		self.connections = {}
		self.weights = {}
	end,
	--- Return the weight of the connection to a given neighbor Cell. It returns nil when
	-- the Cell is not a neighbor.
	-- @arg cell A Cell.
	-- @usage c = Cell{}
	-- n = Neighborhood()
	-- n:add(c, 0.5)
	--
	-- print(n:getWeight(c))
	getWeight = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		local id = cell:getId()

		if id == nil then
			customError("Cell does not belong to the Neighborhood because it does not have an id.")
		end

		for i = 1, #self do
			if self.connections[i] == cell then
				return self.weights[i]
			end
		end

		customError("Cell '"..id.."' does not belong to the Neighborhood.")
	end,
	--- Return whether the Neighborhood does not contain any Cell.
	-- @usage n = Neighborhood()
	--
	-- if n:isEmpty() then
	--     print("is empty")
	-- end
	isEmpty = function(self)
		return #(self.connections) == 0
	end,
	--- Return whether a given Cell belongs to the Neighborhood.
	-- @arg cell A Cell.
	-- @usage n = Neighborhood()
	-- c = Cell{}
	--
	-- n:add(c)
	-- if n:isNeighbor(c) then
	--     print("is neighbor")
	-- end
	isNeighbor = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		for i = 1, #self do
			if self.connections[i] == cell then return true end
		end

		return false
	end,
	--- Remove a Cell from the Neighborhood.
	-- @arg cell The Cell that is going to be removed.
	-- @usage c1 = Cell{id = "1"}
	-- c2 = Cell{id = "2"}
	--
	-- n = Neighborhood()
	-- n:add(c1)
	-- n:add(c2)
	--
	-- print(#n)
	-- n:remove(c1)
	-- print(#n)
	remove = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		for i = 1, #self do
			if self.connections[i] == cell then
				table.remove(self.connections, i)
				table.remove(self.weights, i)
				return true
			end
		end

		customWarning("Trying to remove a Cell that does not belong to the Neighborhood.")
	end,
	--- Return a random Cell from the Neighborhood.
	-- @usage c1 = Cell{id = "1"}
	-- c2 = Cell{id = "2"}
	--
	-- n = Neighborhood()
	-- n:add(c1)
	-- n:add(c2)
	--
	-- cell = n:sample()
	-- print(type(cell))
	sample = function(self)
		if self:isEmpty() then
			customError("It is not possible to sample the Neighborhood because it is empty.")
		end

		return self.connections[Random():integer(1, #self)]
	end,
	--- Update a weight of the connection to a given neighbor Cell.
	-- @arg cell A Cell.
	-- @arg weight A number with the new weight.
	-- @usage c = Cell{}
	-- n = Neighborhood()
	-- n:add(c, 0.5)
	--
	-- print(n:getWeight(c))
	-- n:setWeight(c, 0.01)
	-- print(n:getWeight(c))
	setWeight = function(self, cell, weight)
		mandatoryArgument(1, "Cell", cell)
		mandatoryArgument(2, "number", weight)

		local id = cell:getId()

		if id == nil then
			customError("Cell does not belong to the Neighborhood because it does not have an id.")
		end

		for i = 1, #self do
			if self.connections[i] == cell then
				self.weights[i] = weight
				return true
			end
		end

		customError("Cell '"..id.."' does not belong to the Neighborhood.")
	end
}

metaTableNeighborhood_ = {
	__index = Neighborhood_,
	--- Return the number of Cells in the Neighborhood.
	-- @usage n = Neighborhood()
	--
	-- print(#n)
	__len = function(self)
		return #self.connections
	end,
	__tostring = _Gtme.tostring
}

--- A Neighborhood is a set of pairs (cell, weight), where cell is a neighbor Cell and weight
-- is a number storing the relation's strength.
-- Each Cell can have one or more Neighborhoods to represent its proximity relations. \
-- This type is used to create Neighborhoods from scratch to be used by
-- Cell:addNeighborhood(). To create well-established Neighborhoods see
-- CellularSpace:createNeighborhood(). Neighborhoods can also be loaded from external soures
-- using CellularSpace:loadNeighborhood().
-- It is recommended that a Neighborhood should contain only Cells that belong to the same
-- CellularSpace, as it guarantees that all its Cells have unique identifiers.
-- Calling Utils:forEachNeighbor() from a Cell traverses one of its Neighborhoods.
-- @usage n = Neighborhood()
-- n = Neighborhood{}
function Neighborhood()
	local data = {}

	setmetatable(data, metaTableNeighborhood_)
	data:clear()

	return data
end

