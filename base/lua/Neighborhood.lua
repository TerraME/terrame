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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Rodrigo Reis Pereira
--#########################################################################################

Neighborhood_ = {
	type_ = "Neighborhood",
	--- Add a new Cell to the Neighborhood. If the Neighborhood already contains such Cell
	-- then it will stop with an error.
	-- @arg cell A Cell to be added.
	-- @arg weight A number representing the weight of the connection. The default value is 1.
	-- @usage n:add(cell, 0.02)
	add = function(self, cell, weight)
		mandatoryArgument(1, "Cell", cell)
		optionalArgument(2, "number", weight)

		if weight == nil then weight = 1 end

		verify(not self:isNeighbor(cell), "Cell ("..cell.x..", "..cell.y..") already belongs to the Neighborhood.")

		self.cObj_:addNeighbor(cell.x, cell.y, cell.cObj_, weight)
	end,
	--- Add a new Cell to the Neighborhood.
	-- @arg xIndex A number with the x value of the Cell.
	-- @arg yIndex A number with the y value of the Cell.
	-- @arg cellularSpace A CellularSpace.
	-- @arg weight A number representing the weight of the connection.
	-- @usage n:addCell(2, 2, cs, 0.5)
	-- @deprecated Neighborhood:add
	addCell = function(self, xIndex, yIndex, cellularSpace, weight)
		deprecatedFunction("addCell", "add")
	end,
	--- Add a new Cell to the Neighborhood.
	-- @arg cell A Cell.
	-- @arg weight A number representing the weight of the connection.
	-- @usage n:addNeighbor(cell, 0.7)
	-- @deprecated Neighborhood:add
	addNeighbor = function(self, cell, weight)
		deprecatedFunction("addNeighbor", "add")
	end,
	--- Remove all Cells from the Neighborhood. In practice, it has the same behavior
	-- as calling Neighborhood() again if the Neighborhood was not added to any Cell.
	-- @usage n:clear()
	clear = function(self)
		self.cObj_:clear()
	end,
	--- Remove a Cell from the Neighborhood.
	-- @arg xIndex A number with the x value of the Cell.
	-- @arg yIndex A number with the y value of the Cell.
	-- @usage n:eraseCell(2, 2)
	-- @deprecated Neighborhood:remove
	eraseCell = function(self, xIndex, yIndex)
		deprecatedFunction("eraseCell", "remove")
	end,
	--- Remove a Cell from the Neighborhood.
	-- @arg cell A string with the unique identifier of the Cell.
	-- @usage n:eraseNeighbor("2")
	-- @deprecated Neighborhood:remove
	eraseNeighbor = function(self, cell)
		deprecatedFunction("eraseNeighbor", "remove")
	end,
	--- Return the weight of the connection to a given neighbor Cell.
	-- @arg xIndex A number with the x value of the Cell.
	-- @arg yIndex A number with the y value of the Cell.
	-- @usage n:getCellWeight(2, 2)
	-- @deprecated Neighborhood:getWeight
	getCellWeight = function(self, xIndex, yIndex)
		deprecatedFunction("getCellWeight", "getWeight")
	end,
	--- Return the unique identifier of the Neighborhood. It represents
	-- the index if the Neighborhood in the Cell it was added.
	-- @usage n:getID()
	getID = function(self)
		return self.cObj_:getID()
	end,
	--- Return the weight of the connection to a given neighbor Cell.
	-- @arg cell A Cell.
	-- @usage n:getNeighWeight(cell)
	-- @deprecated Neighborhood:getWeight
	getNeighWeight = function(self, cell)
		deprecatedFunction("getNeighWeight", "getWeight")
	end,
	--- Return the parent of the Neighborhood, which is the last Cell where the Neighborhood
	-- was added.
	-- @usage neigh:getParent()
	getParent = function(self)
		return self.cObj_:getParent()
	end,
	--- Return the weight of the connection to a given neighbor Cell. It returns nil when
	-- the Cell is not a neighbor.
	-- @arg cell A Cell.
	-- @usage w = n:getWeight(cell)
	getWeight = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		local result = self.cObj_:getNeighWeight(cell.x, cell.y, cell.cObj_)
		verify(result, "Cell ("..cell.x..","..cell.y..") does not belong to the Neighborhood.")

		return result
	end,
	--- Return whether the Neighborhood does not contain any Cell.
	-- @usage if n:isEmpty() then
	--     print("is empty")
	-- end
	isEmpty = function(self)
		return self.cObj_:isEmpty()
	end,
	--- Return whether a given Cell belongs to the Neighborhood.
	-- @arg cell A Cell.
	-- @usage if n:isNeighbor() then
	--     -- ...
	-- end
	isNeighbor = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		return self.cObj_:isNeighbor(cell.x, cell.y, cell.cObj_)
	end,
	--- Remove a Cell from the Neighborhood.
	-- @arg cell The Cell that is going to be removed.
	-- @usage n:remove(cell)
	remove = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		verify(self:isNeighbor(cell), "Trying to remove a Cell that does not belong to the Neighborhood.")

		local result = self.cObj_:eraseNeighbor(cell.x, cell.y, cell.cObj_)
	end,
	--- Return a random Cell from the Neighborhood.
	-- @usage cell = n:sample()
	sample = function(self)
		if self:isEmpty() then
			customError("It is not possible to sample the Neighborhood because it is empty.")
		end

		local pos = Random():integer(1, #self)

		local count = 1
		self.cObj_:first()
		while not self.cObj_:isLast() do
			local neigh = self.cObj_:getNeighbor()
			if count == pos then return neigh end
			self.cObj_:next()
			count = count + 1
		end
	end,
	--- Remove a Cell from the Neighborhood replacing it by another Cell.
	-- @arg index A positive integer number with the position of the Cell.
	-- @arg cell The new Cell.
	-- @usage n:setCellNeighbor(2, "2")
	-- @deprecated Neighborhood:remove() and Neighborhood:add()
	setCellNeighbor = function(self, index, cell)
		deprecatedFunction("setCellNeighbor", "remove and add")
	end,
	--- Update the weight of a connection to a given neighbor Cell.
	-- @arg xIndex A number with the x value of the Cell.
	-- @arg yIndex A number with the y value of the Cell.
	-- @arg weight A number representing the new weight of the connection.
	-- @usage n:setCellWeight(2, 2, 0.5)
	-- @deprecated Neighborhood:setWeight
	setCellWeight = function(self, xIndex, yIndex, weight)
		deprecatedFunction("setCellWeight", "setWeight")
	end,
	--- Update a weight of the connection to a given neighbor Cell.
	-- @arg cell A Cell.
	-- @arg weight A number representing the weight of the connection.
	-- @usage n:setNeighWeight(cell, 0.3)
	-- @deprecated Neighborhood:setWeight
	setNeighWeight = function(self, cell, weight)
		deprecatedFunction("setNeighWeight", "setWeight")
	end,
	--- Update a weight of the connection to a given neighbor Cell.
	-- @arg cell A Cell.
	-- @arg weight A number with the new weight.
	-- @usage n:setWeight(cell, 0.01)
	setWeight = function(self, cell, weight)
		mandatoryArgument(1, "Cell", cell)
		mandatoryArgument(2, "number", weight)
	
		local result = self.cObj_:setNeighWeight(cell.x, cell.y, cell.cObj_, weight)

		verify(result, "Cell ("..cell.x..","..cell.y..") does not belong to the Neighborhood.")
	end,
	--- Return the number of Cells in the Neighborhood.
	-- @usage n:size()
	-- @deprecated Neighborhood:#
	size = function(self)
		deprecatedFunction("size", "operator #")
	end
}

metaTableNeighborhood_ = {
	__index = Neighborhood_,
	--- Return the number of Cells in the Neighborhood.
	-- @usage print(#n)
	__len = function(self)
		return self.cObj_:size()
	end,
	__tostring = tostringTerraME
}

--- A Neighborhood is a set of pairs (cell, weight), where cell is a neighbor Cell and weight 
-- is a number storing the relation's strength.
-- Each Cell can have one or more Neighborhoods to represent its proximity relations.
-- This type is used to create Neighborhoods from scratch to be used by
-- Cell:addNeighborhood(). To create well-established Neighborhoods see
-- CellularSpace:createNeighborhood(). Neighborhoods can also be loaded from external soures
-- using CellularSpace:loadNeighborhood().
-- It is recommended that a Neighborhood should contain only Cells that belong to the same
-- CellularSpace, as it guarantees that all its Cells have unique identifiers.
-- Calling Utils:forEachNeighbor() from a Cell traverses one of its Neighborhoods.
-- @arg data.... Attributes with only internal purposes. They should not be used explicitly by the user.
-- @usage n = Neighborhood()
-- n = Neighborhood{}
function Neighborhood(data)
	if data == nil then
		data = {}
	end

	if not data.cObj_ then
		data.cObj_ = TeNeighborhood()
	end

	data.cObj_:setReference(data)
	setmetatable(data, metaTableNeighborhood_)
	return data
end

