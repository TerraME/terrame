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

Cell_ = {
	type_ = "Cell",
	--- Add a new Neighborhood to the Cell. This function replaces previous Neighborhood with the
	-- same name (if it exists) without showing any warning message.
	-- @arg neigh A Neighborhood.
	-- @arg id Neighborhood's name. The default value is "1".
	-- @see Neighborhood
	-- @usage cell:addNeighborhood(n)
	-- cell:addNeighborhood(n, "east")
	addNeighborhood = function(self, neigh, id)
		if neigh == nil then
			mandatoryArgumentError(1)
		elseif type(neigh) ~= "Neighborhood" and type(neigh) ~= "function" then
			incompatibleTypeError(1, "Neighborhood", neigh)
		end

		if id == nil then id = "1" end
		mandatoryArgument(2, "string", id)

		if self.neighborhoods == nil then self.neighborhoods = {} end
		self.neighborhoods[id] = neigh

		if type(neigh) == "Neighborhood" then
			self.cObj_:addNeighborhood(id, neigh.cObj_)
		end
	end,
	--- Compute the Euclidean distance to a given Cell. It uses the attributes x and y of both Cells.
	-- @arg cell A Cell.
	-- @usage c2 = Cell{x = 10, y = 10}
	-- cell:distance(c2)
	distance = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		return math.sqrt((self.x - cell.x) ^ 2 + (self.y - cell.y) ^ 2)
	end,
	--- Return an Agent that belongs to the Cell. It assumes that there is at most one Agent per Cell.
	-- If there is no Agent within the cell then it returns nil.
	-- @arg placement A string with the name of the placement. The default value is "placement".
	-- @usage agent = cell:getAgent()
	getAgent = function(self, placement)
		return self:getAgents(placement)[1]
	end,
	--- Return the Agents that belong to the Cell. Agents are indexed by numeric positions.
	-- @arg placement A string with the name of the placement. The default value is "placement".
	-- @usage agent = cell:getAgents()[1]
	getAgents = function(self, placement)
		if placement == nil then placement = "placement" end
		mandatoryArgument(1, "string", placement)

		if type(self[placement]) == "Group" then
			return self[placement].agents
		elseif self[placement] == nil then
			customError("Placement '".. placement.. "' does not exist. Use Environment:createPlacement first.")
		else
			customError("Placement '".. placement.. "' should be a Group, got "..type(self[placement])..".")
		end
	end,
	--- Return a string with the unique identifier of the Cell.
	-- @usage id = cell:getId()
	getId = function(self)
		return self.cObj_:getID()
	end,
	--- Return a Neighborhood of the Cell. If the Neighborhood does not exist then it returns nil.
	-- @arg index A string with the neighborhood's name to be retrieved. The default value is "1".
	-- @usage n = cell:getNeighborhood()
	-- n = cell:getNeighborhood("moore")
	getNeighborhood = function(self, index)
		if index == nil then
			index = "1"
		elseif type(index) ~= "string" then
			incompatibleTypeError(1, "string", index)
		end

		if self.neighborhoods then
			local s = self.neighborhoods[index]
			if type(s) == "function" then
				return s(self)
			end
		end

		return self.cObj_:getNeighborhood(index)
	end,
	--- User-defined function that is used to initialize a Cell when a CellularSpace is
	-- created. This function gets the Cell itself as argument.
	-- @usage cell = Cell{
	--     init = function(self)
	--         self.population = Random():integer(1, 100) -- initial population chosen randomly
	--     end,
	--     -- ...
	-- }
	-- 
	-- cs = CellularSpace{
	--     xdim = 10,
	--     instance = cell
	-- }
	--
	-- print(cs:sample().population)
	-- @see Random
	init = function(self) -- virtual function that might be implemented by the modeler
	end,
	--- Return whether the cell is empty according to a given placement.
	-- @arg placement A string with the name of the placement. The default value is "placement".
	-- @usage print(cell:isEmpty())
	-- print(cell:isEmpty("workingplace"))
	isEmpty = function(self, placement)
		return #self:getAgents(placement) == 0
	end,
	--- Notify every Observer connected to the Cell.
	-- @arg modelTime A positive number representing the notification time.
	-- The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage cell:notify()
	notify = function(self, modelTime)
		if modelTime == nil then
			modelTime = 0
		elseif type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		else
			optionalArgument(1, "number", modelTime)
			positiveArgument(1, modelTime, true)
		end

		if self.obsattrs_ then
			forEachElement(self.obsattrs_, function(idx)
				self[idx.."_"] = self[idx](self)
			end)
		end

		self.cObj_:notify(modelTime)
	end,
	--- Return a random Cell from a Neighborhood of the Cell.
	-- @arg id A string with the name of the Neighborhood. The default value is "1".
	-- @usage cell_neighbor = cell:sample()
	-- cell_neighbor = cell:sample("myneighborhood")
	-- @see Cell:getNeighborhood
	sample = function(self, id)
		local randomObj = Random()
		if id == nil then id = "1" end
		mandatoryArgument(1, "string", id)

		local neigh = self:getNeighborhood(id)

		if neigh == nil then
			customError("Cell does not have a Neighborhood named '"..id.."'.")
		end
		return neigh:sample(randomObj)
	end,
	--- Update the unique identifier of the Cell.
	-- @arg id A string with the new unique identifier.
	-- @usage cell:setId("newid")
	setId = function(self, id)
		mandatoryArgument(1, "string", id)
		self.id = id
		self.cObj_:setID(self.id)
	end,
	--- Return the number of Neighborhoods in the Cell.
	-- @usage size = #cell
	-- @deprecated Cell:#
	size = function(self)
		deprecatedFunction("size", "operator #")
	end,
	--- Synchronizes the Cell. TerraME can keep two copies of the attributes of a Cell in memory:
	-- one stores the past values and the other stores the current (present) values. Synchronize
	-- copies the current values to a table named past, within the Cell. The previous past is
	-- therefore overwritten.
	-- @usage cell:synchronize()
	-- @see CellularSpace:synchronize
	synchronize = function(self)
		self.past = {}
		for k, v in pairs(self) do
			if k ~= "past" then
				self.past[k] = v
			end
		end
	end
}

metaTableCell_ = {
	__index = Cell_,
	--- Return the number of Neighborhoods in the Cell.
	-- @usage size = #cell
	__len = function(self)
		return self.cObj_:size()
	end,
	__tostring = tostringTerraME
}

--- A spatial location with homogeneous internal content.
-- It is a table that may contain nearness relations as well as persistent and runtime attributes.
-- Persistent attributes can be loaded from databases using CellularSpace, 
-- while runtime attributes can be created along the simulation.
-- @arg data.init An optional function that describes how to initialize a Cell that is going
-- to be used as an instance of a CellularSpace. See Cell:init().
-- @arg data.x An integer number with the x location of the Cell. The default value is 0.
-- @arg data.y An integer number with the y location of the Cell. The default value is 0.
-- @arg data.... Any other attribute or function for the Cell.
-- @output past a copy of the attributes at the time of the last synchronization.
-- @output parent the CellularSpace it belongs.
-- @output placement a Group representing the default placement of the Cell (only when its
-- CellularSpace belongs to an Environment).
-- @output agents a vector of Agents necessary to use Utils:forEachAgent() with the Cell
-- (only when Environment:createPlacement() was used).
-- @see Utils:forEachNeighborhood
-- @usage cell = Cell {
--     cover = "forest",
--     soilWater = 0
-- }
function Cell(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
			verifyNamedTable(data)
		end
	end

	optionalTableArgument(data, "id", "string")

	data.cObj_ = TeCell()
	data.past = {}

	setmetatable(data, metaTableCell_)
	data.cObj_:setReference(data)

	if data.x == nil then
		data.x = 0 
	else
		mandatoryTableArgument(data, "x", "number")
		integerTableArgument(data, "x")
	end

	if data.y == nil then
		data.y = 0 
	else
		mandatoryTableArgument(data, "y", "number")
		integerTableArgument(data, "y")
	end

	if not data.id then
		local id = "C"
		if data.x < 10 then id = id.."0" end
		id = id..data.x.."L"
		if data.y < 10 then id = id.."0" end
		id = id..data.y
		data.id = id
	end

	data.cObj_:setID(data.id)
	data.id = nil
--	data.id = data.cObj_:getID()

	data.cObj_:setIndex(data.x, data.y)
	return data
end

