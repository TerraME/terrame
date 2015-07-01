-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
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
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
globalTrajectoryIdCounter = 0

Trajectory_ = {
	type_ = "Trajectory",
	--- Retrieve a copy of the Trajectory, with the same parent, select, greater, and Cells.
	-- @usage copy = traj:clone()
	clone = function(self)
		t = Trajectory {
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}
		forEachCell(self, function(cell)
			t:add(cell)
		end)
		return t
	end,

	--- Apply a filter over the original CellularSpace. It returns true if the function was applied sucessfully.
	--@param f A function (Cell)->boolean to filter the CellularSpace, adding to the Trajectory only those Cells whose returning value is true. The default value is the previous filter applied to the Trajectory. 
	-- @usage traj:filter(function(cell)
	--     return cell.cover = "forest"
	-- end)
	filter = function(self, f)
		if type(f) == "function" then
			self.select = f
		elseif type(self.select) ~= "function" then
			return false
		else
			f = self.select
		end
		self.cells = {}
		self.cObj_:clear()
		for i, cell in ipairs(self.parent.cells) do
			if f(cell) then 
				table.insert(self.cells, cell)
				self.cObj_:add(i, cell.cObj_)
			end
		end
		return true
	end,

	--- Retrieve a Cell in Trajectory given by Coord index. It returns nil if the cell was not found.
	--@param index Coord A coord where the cell is.
	getCell = function(self, index)
		local t = type(index)

		if index == nil then
			index = 1
			defaultValueWarningMsg("#1","positive integer number or Coord", index, 3)
		elseif t ~= "Coord" and t ~= "number" then
			incompatibleTypesErrorMsg("#1","positive integer number or Coord", t, 3)
		elseif t == "number" then
			if(index <= 0) then
				incompatibleValuesErrorMsg("#1","positive integer number or Coord", index, 3)
			elseif(math.floor(index) ~= index) then
				incompatibleValuesErrorMsg("#1","positive integer number or Coord", index, 3)
			end
			return self.cells[index]
		elseif t == "Coord" then
			local x, y = index:get().x, index:get().y
			for i, cell in ipairs(self.cells) do
				if cell.x == x and cell.y == y then
					return cell
				end
			end
			return nil   
		end
		return nil
	end,

	---Retrieve the last function used to sort the Trajectory.
	getGreater = function(self)
		return self.greater
	end,

	---Retrieve the last function used to filter the Trajectory.
	getSelect = function(self)
		return self.select
	end,

	--#-Retrieve whether a Trajectory was builded.
	getBuild = function(self)
		return self.build
	end,

	--#-Update wheter a Trajectory will be built in initialize.
	--@param build boolean A boolean.
	setBuild = function(self, build)
		if(type(build) ~= "boolean") then
			incompatibleTypesErrorMsg("#1", "boolean", type(build), 3)
		end
		self.build = build
	end,

	--#-Retrieve the CellularSpace where the Trajectory takes place.
	getTarget = function(self)
		return self.target
	end,

	--#-Update the CellularSpace where the Trajectory takes place. It returns a boolean value indicating whether the CellularSpace was sucessfully changed.
	--@param target A CellularSpace.
	setTarget = function(self,target)
		if(type(target) ~= "CellularSpace") then
			incompatibleTypesErrorMsg("#1", "CellularSpace", type(target), 3)
		end
		self.target = target
		return true
	end,

	--- Add a new Cell to the Trajectory. It returns boolean valure indicating whether the Cell was added.
	--@param index A position where cell will be placed.
	--@param cell A Cell wich will be updated.
	addCell = function(self, index, cell)
		if index == nil then
			index = 1
			defaultValueWarningMsg("#1", "positive integer number", index, 3)   
		elseif(type(index) ~="number") then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(index), 3)      
		elseif(index < 0) then
			incompatibleValuesErrorMsg("#1", "positive integer number", index, 3) 
		elseif(math.floor(index) ~= index) then
			incompatibleValuesErrorMsg("#1", "positive integer number", index, 3) 
		end

		if(type(cell) ~="Cell") then
			incompatibleTypesErrorMsg("#2", "Cell", type(cell), 3)
		end

		self.cObj_:add(index, cell.cObj_)
		return true
	end,

	--- Notify every Observer connected to the Trajectory.
	--@param time The time to be used in the observer. Most of the strategies available ignore this value; therefore it can be left empty. See the Observer documentation for details.
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
			defaultValueWarningMsg("#1", "positive number", modelTime, 3)
    elseif type(modelTime) ~= "number" then
      incompatibleTypesErrorMsg("#1", "positive number", type(modelTime), 3) 
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1","positive number", modelTime, 3)   
		end
		self.cObj_:notify(modelTime)
	end,

	--- Randomize the Cells, changing their traversing order.
	--@param randomObj A Random object. As default, TerraME uses its internal random number generator.
	--@usage traj:randomize()
	randomize = function(self, randomObj)
		if(not randomObj or type(randomObj) ~= "Random") then
			randomObj = TME_GLOBAL_RANDOM      
		end
		local numcells = self:size()
		for i = 1, numcells do
			local pos1 = randomObj:integer(1, numcells)
			local pos2 = randomObj:integer(1, numcells)
			local cell1 = self.cells[pos1]
			self.cells[pos1] = self.cells[pos2]
			self.cells[pos2] = cell1
		end
	end,

	--- Rebuild the Trajectory from the original data using the last filter and sort functions.
	-- @usage traj:rebuild()
	rebuild = function(self)
		if type(self.select) == "function" then
			self:filter(self.select)
		else
			self:filter(function(cell) return type(cell) == "Cell" end)
		end
		if self.greater ~= nil then	self:sort(self.greater) end
	end,

	--- Sort the current CellularSpace subset of the Trajectory. It returns a boolean value indicating whether the Trajectory was sucessfully sorted.
	--@param greaterThan A function (Cell, Cell)->boolean to sort the generated subset of Cells. It returns true if the first one has priority over the second one. Default: No sorting function will be applied.
	--@see Utils:greaterByAttribute
	--@see Utils:greaterByCoord
	--@usage traj:sort(function(c, d)
	--     return c.dist < d.dist
	-- end)
	sort = function(self, greaterThan)
		if type(greaterThan) == "function" then
			self.greater = greaterThan
		elseif self.greater == nil then
			return false
		else
			greaterThan = self.greater
		end
		table.sort(self.cells, greaterThan)
		self.cObj_:clear()
		for i, cell in ipairs(self.cells) do
			self.cObj_:add(i, cell.cObj_)
		end

		return true
	end
}

setmetatable(Trajectory_, metaTableCellularSpace_)
local metaTableTrajectory_ = {__index = Trajectory_}

---Type that defines a spatial trajectory over the Cells of a CellularSpace. It inherits CellularSpace; therefore it is possible to use all functions of such type within a Trajectory. For instance, calling forEachCell() also traverses Trajectories, and it is possible to create a Trajectory from another Trajectory.
-- @param data.target The CellularSpace over which the Trajectory will take place.
-- @param data.select A function (Cell)->boolean to filter the CellularSpace, adding to the Trajectory only those Cells whose returning value is true. If this argument is missing, all Cells will be included in the Trajectory.
-- @param data.greater A function (Cell, Cell)->boolean to sort the generated subset of Cells. It returns true if the first one has priority over the second one. If this argument is missing, no sorting function will be applied. See greaterByAttribute() and greaterByCoord() as predefined options to sort objects.
-- @param data.build A boolean value indicating whether the Trajectory will be computed or not when created. Default is true.
--
-- @output cells A vector of Cells pointed by the Trajectory.
-- @output parent The CellularSpace where the Trajectory takes place.
-- @output select The last function used to filter the Trajectory.
-- @output greater The last function used to sort the Trajectory.
-- @see Utils:forEachCell
-- @see Utils:greaterByCoord
-- @see Utils:greaterByAttribute
--
-- @usage traj = Trajectory {
--     target = cs,
--     select = function(c)
--         return c.cover == "forest"
--     end,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory {
--     target = cs,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory {
--     target = cs,
--     build = false
-- }
function Trajectory(data)
	if data == nil then
		data = {}
		defaultValueWarningMsg("#1", "{}", 3)
	elseif type(data) ~= "table" then
		incompatibleTypesErrorMsg("#1", "table", type(data), 3)    
	end

	--TODO id
	if type(data.target) ~= "CellularSpace" then
		incompatibleTypesErrorMsg("target", "CellularSpace", type(data.target), 3)
	end

	if data.build == nil then
		data.build = true
		defaultValueWarningMsg("build", "boolean", "true", 3)
	elseif type(data.build) ~= "boolean" then
		incompatibleTypesErrorMsg("build", "boolean", type(data.build), 3)
	end

	data.parent = data.target
	data.target = nil

	if data.select == nil then
		data.select = function(cell) return type(cell) == "Cell" end
		defaultValueWarningMsg("select", "function", "bool = function(cell) return type(cell) == \"Cell\" end", 3)
	elseif type(data.select) ~= "function" then
		incompatibleTypesErrorMsg("select","function",type(data.select), 3)
	end

	if data.greater and type(data.greater) ~= "function" then
		data.greater = function(cellA,cellB)
			return cellA.id > cellB.id
		end
		defaultValueWarningMsg("greater", "function", "function(cellA,cellB) return return cellA.id > cellB.id end", 3)
	end

	local cObj = TeTrajectory()
	data.cObj_ = cObj
	data.cells = {}

	setmetatable(data, metaTableTrajectory_)

	if data.build then
		data:rebuild()
		data.build = nil
	end

	cObj:setReference(data)

	return data
end


