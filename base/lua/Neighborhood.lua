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
	--- Add a new Cell to the Neighborhood. 
	-- It returns a boolean value indicating whether the Cell was correctly added.
	-- @param cell A Cell to be added.
	-- @param weight A number representing the weight of the connection. Default is zero.
	-- @usage n:add(cell, 0.02)
	add = function(self, cell, weight)
		if cell == nil then
			mandatoryArgumentError(1)
		elseif type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		end

		if weight == nil then
			weight = 1
		elseif type(weight) ~= "number" then
			incompatibleTypeError(2, "number", weight)
		end

		verify(not self:isNeighbor(cell), "Cell ("..cell.x..","..cell.y..") already belongs to the Neighborhood.")

		return self.cObj_:addNeighbor(cell.x, cell.y, cell.cObj_, weight)
	end,
	--- Add a new Cell to the Neighborhood. Deprecated. Use Neighborhood:add instead.
	-- @param weight A number representing the weight of the connection. Default is zero.
	addNeighbor = function(self, cell, weight)
		deprecatedFunctionWarning("addNeighbor", "add")
		self:add(cell, weight)
	end,
	--- Add a new Cell to the Neighborhood. Deprecated. Use Neighborhood:add instead.
	-- @param xIndex A number.
	-- @param yIndex A number.
	-- @param weight A number representing the weight of the connection. Default is zero.
	addCell = function(self, xIndex, yIndex, cellularSpace, weight)
		deprecatedFunctionWarning("addCell", "add")
		local cell = cellularSpace:getCell(xIndex, yIndex)
		self:add(cell, weight)
	end,
	--- Remove all Cells from the Neighborhood. In practice, it has almost the same behavior
	-- as calling Neighborhood() again.
	-- @usage n:clear()
	clear = function(self)
		self.cObj_:clear()
	end,
	--- Remove a Cell from the Neighborhood. Deprecated. Use remove instead.
	-- @param xIndex A number.
	-- @param yIndex A number.
	eraseCell = function(self, xIndex, yIndex)
		deprecatedFunctionWarning("eraseCell", "remove")
	end,
	--- Remove a Cell from the Neighborhood. Deprecated. Use remove instead.
	eraseNeighbor = function(self, cell)
		deprecatedFunctionWarning("eraseNeighbor", "remove")
		self:remove(cell)
	end,
	--- Remove a Cell from the Neighborhood.
	-- @param cell A cell which will be removed.
	-- @usage n:remove(cell)
	remove = function(self, cell)
		if cell == nil then
			mandatoryArgumentError(1)
		elseif type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		end

		if not self:isNeighbor(cell) then

		end

		local result = self.cObj_:eraseNeighbor(cell.x, cell.y, cell.cObj_)

		if not result then
			customError("Trying to remove a Cell that does not belong to the Neighborhood.")
		end
	end,
	--- Remove a Cell from the Neighborhood. Deprecated. Use Neighborhood:remove and
	-- Neighborhood:add instead.
	-- @param index A number.
	-- @param cell A Cell.
	setCellNeighbor = function(self, index, cell)
		deprecatedFunctionWarning("setCellNeighbor", "remove and add")
	end,
	--- Retrieve the weight of the connection to a given neighbour Cell. Deprecated.
	-- @param xIndex A number.
	-- @param yIndex A number.
	-- Use getWeight instead.
	getCellWeight = function(self, xIndex, yIndex)
		deprecatedFunctionWarning("getCellWeight", "getWeight")
		return 0
	end,
	--- Retrieve the weight of the connection to a given neighbour Cell. It returns nil when
	-- the Cell is not a neighbor.
	-- @param cell A Cell.
	-- @usage w = n:getWeight(cell)
	getWeight = function(self, cell)
		if cell == nil then
			mandatoryArgumentError(1)
		elseif type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		end

		local result = self.cObj_:getNeighWeight(cell.x, cell.y, cell.cObj_)

		if result == nil then
			customError("Cell ("..cell.x..","..cell.y..") does not belong to the Neighborhood.")
		end
		return result
	end,
	--- Retrieve the weight of the connection to a given neighbour Cell. Deprecated. 
	-- Use getWeight instead.
	-- @param cell A Cell.
	getNeighWeight = function(self, cell)
		deprecatedFunctionWarning("getNeighWeight", "getWeight")
		return self:getWeight(cell)
	end,
	--- Return whether the Neighborhood does not contain any Cell.
	-- @usage if n:isEmpty() then
	--     print("is empty")
	-- end
	isEmpty = function(self)
		return self.cObj_:isEmpty()
	end,
	--- Return whether a given Cell belongs to the Neighborhood.
	-- @param cell A Cell.
	-- @usage if n:isNeighbor() then
	--     -- ...
	-- end
	isNeighbor = function(self, cell)
		if cell == nil then
			mandatoryArgumentError(1)
		elseif type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		end

		return self.cObj_:isNeighbor(cell.x, cell.y, cell.cObj_)
	end,
	--- Retrieve a random Cell from the Neighborhood.
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
	--- Update a weight of the connection to a given neighbor Cell.
	-- @param cell A Cell.
	-- @param weight The new weight.
	-- @usage n:setWeight(cell, 0.01)
	setWeight = function(self, cell, weight)
		if cell == nil then
			mandatoryArgumentError(1)
		elseif type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		end

		if weight == nil then
			mandatoryArgumentError(2)
		elseif type(weight) ~= "number" then
			incompatibleTypeError(2, "number", weight)
		end
	
		local result = self.cObj_:setNeighWeight(cell.x, cell.y, cell.cObj_, weight)

		if not result then
			customError("Cell ("..cell.x..","..cell.y..") does not belong to the Neighborhood.")
		end
	end,
	--- Update a weight of the connection to a given neighbor Cell.
	-- Deprecated. Use Neighborhood:setWeight instead.
	-- @param xIndex A number.
	-- @param yIndex A number.
	-- @param weight A number representing the weight of the connection. Default is zero.
	setCellWeight = function(self, xIndex, yIndex, weight)
		deprecatedFunctionWarning("setCellWeight", "setWeight")
		self:setWeight(xIndex, yIndex, weight)
	end,
	--- Update a weight of the connection to a given neighbor Cell.
	-- Deprecated. Use Neighborhood:setWeight instead.
	-- @param cell A Cell.
	-- @param weight A number representing the weight of the connection. Default is zero.
	setNeighWeight = function(self, cell, weight)
		deprecatedFunctionWarning("setNeighWeight", "setWeight")
		self:setWeight(xIndex, yIndex, weight)
	end,
	--- Retrieve the number of Cells of the Neighborhood.
	-- Deprecated. Use # instead.
	size = function(self)
		deprecatedFunctionWarning("size", "operator #")
		return #self
	end,
	--- Return the parent of the Neighborhood, which is the last Cell where the Neighborhood
	-- was added.
	-- @usage neigh:getParent()
	getParent = function(self)
		return self.cObj_:getParent()
	end
}

metaTableNeighborhood_ = {
	__index = Neighborhood_,
	--- Retrieve the number of Cells of the Neighborhood.
	-- @name #
	-- @usage print(#n)
	__len = function(self)
		return self.cObj_:size()
	end,
	__tostring = tostringTerraME
}

--- Each Cell has one or more Neighborhoods to represent proximity relations. A Neighborhood is a
-- set of pairs (cell, weight), where cell is a neighbor Cell and weight is a number storing the
-- relation's strength. This type is used to create Neighborhoods from scratch to be used by
-- Cell:addNeighborhood(). To create well established neighborhoods see
-- CellularSpace:createNeighborhood(). Neighborhoods can also be loaded from external soures
-- using CellularSpace:loadNeighborhood(). Calling Utils:forEachNeighbor()
-- from a Cell traverses one of its Neighborhoods.
-- @usage n = Neighborhood()
function Neighborhood()
	local data = {}

	data.cObj_ = TeNeighborhood()
	data.cObj_:setReference(data)

	setmetatable(data, metaTableNeighborhood_)
	return data
end

