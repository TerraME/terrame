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
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--#########################################################################################

Trajectory_ = {
	type_ = "Trajectory",
	--- Add a new Cell to the Trajectory. It will be added to the end of the list of Cells.
	-- @arg cell A Cell.
	-- @usage traj:add(cell)
	add = function(self, cell)
		mandatoryArgument(1, "Cell", cell)

		if self:get(cell.x, cell.y) then
			customError("Cell ("..cell.x..", "..cell.y..") already belongs to the Trajectory.")
		end

		table.insert(self.cells, cell)
		self.cObj_:add(#self, cell.cObj_)
	end,
	--- Add a new Cell to the Trajectory.
	-- @arg cell A Cell that will be added.
	-- @usage traj:addCell(cell)
	-- @deprecated Trajectory:add
	addCell = function(self, cell)
		deprecatedFunction("addCell", "add")
	end,
	--- Return a copy of the Trajectory. It has the same parent, select, greater and Cells.
	-- Any change in the cloned Trajectory will not affect the original one.
	-- @usage copy = traj:clone()
	clone = function(self)
		local cloneT = Trajectory{
			target = self.parent,
			select = self.select,
			greater = self.greater,
			build = false
		}

		forEachCell(self, function(cell)
			cloneT:add(cell)
		end)
		return cloneT
	end,
	--- Apply a filter over the CellularSpace used as target for the Trajectory. It replaces the
	-- previous set of Cells belonging to the Trajectory.
	-- @arg f A function (Cell)->boolean, working in the same way of the argument select to
	-- create the Trajectory. If this argument is missing, this function filters the CellularSpace
	-- with the function used as argument for the last call to filter itself, or then the value of
	-- argument select used to build the Trajectory. When it cannot find any function to be used,
	-- this function will add all the Cells of the CellularSpace to the Trajectory.
	-- @usage traj:filter(function(cell)
	--     return cell.cover = "forest"
	-- end)
	filter = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.select = f end

		self.cells = {}
		self.cObj_:clear()

		if type(self.select) == "function" then
			for i, cell in ipairs(self.parent.cells) do
				if self.select(cell) then 
					table.insert(self.cells, cell)
					self.cObj_:add(i, cell.cObj_)
				end
			end
		else
			for i, cell in ipairs(self.parent.cells) do
				table.insert(self.cells, cell)
				self.cObj_:add(i, cell.cObj_)
			end
		end
	end,
	--- Return a Cell from the Trajectory given its x and y locations.
	-- If the Cell does not belong to the Trajectory then it will return nil.
	-- @arg xIndex The x location.
	-- @arg yIndex The y location.
	-- @usage traj:get(1, 1)
	get = function(self, xIndex, yIndex)
		mandatoryArgument(1, "number", xIndex)
		mandatoryArgument(2, "number", yIndex)

		local result
		forEachCell(self, function(cell)
			if cell.x == xIndex and cell.y == yIndex then
				result = cell
				return false
			end
		end)
		return result
	end,
	--- Return a cell given its x and y locations.
	-- @arg index a Coord.
	-- @usage traj:getCell(index)
	-- @deprecated Trajectory:get
	getCell = function(self, index)
		deprecatedFunction("getCell", "get")
	end,
	--- Randomize the Cells of the Trajectory. It will change the traversing order used by
	-- Utils:forEachCell().
	-- @usage traj:randomize()
	randomize = function(self)
		local randomObj = Random()

		local numcells = #self
		local cells = self.cells

		for i = numcells, 2, -1 do
			local r = randomObj:integer(1, i)
			cells[i], cells[r] = cells[r], cells[i]
		end
	end,
	--- Rebuild the Trajectory from the CellularSpace used as target.
	-- It is a shortcut to Trajectory:filter() and then Trajectory:sort().
	-- @usage traj:rebuild()
	rebuild = function(self)
		self:filter()
		self:sort()
	end,
	--- Sort the current CellularSpace subset. It updates the traversing order of the Trajectory.
	-- @arg f An ordering function (Cell, Cell)->boolean, working in the same way of
	-- argument greater to create the Trajectory. If this argument is missing, this function
	-- sorts the Trajectory with the function used as argument for the last call to sort itself,
	-- or then the value of argument greater used to build the Trajectory. When it cannot find
	-- any function to be used, it shows a warning.
	-- @see Utils:greaterByAttribute
	-- @see Utils:greaterByCoord
	-- @usage traj:sort(function(c, d)
	--     return c.dist < d.dist
	-- end)
	sort = function(self, f)
		optionalArgument(1, "function", f)

		if f then self.greater = f end

		if type(self.greater) == "function" then
			table.sort(self.cells, self.greater)
			self.cObj_:clear()
			for i, cell in ipairs(self.cells) do
				self.cObj_:add(i, cell.cObj_)
			end
		else
			customWarning("Cannot sort the Trajectory because there is no previous function.")
		end
	end
}

setmetatable(Trajectory_, metaTableCellularSpace_)
metaTableTrajectory_ = {
	__index = Trajectory_,
	--- Retrieve the number of Cells in the Trajectory.
	-- @usage print(#traj)
	__len = function(self)
		return #self.cells
	end,
	__tostring = tostringTerraME
}

--- Type that defines an ordered selection over a CellularSpace. It inherits CellularSpace;
-- therefore it is possible to apply all functions of such type to a Trajectory. For instance,
-- calling Utils:forEachCell() also traverses Trajectories.
-- @inherits CellularSpace
-- @arg data.target The CellularSpace over which the Trajectory will take place.
-- @arg data.select A function (Cell)->boolean indicating whether an Cell of the CellularSpace
-- should belong to the Trajectory. If this function returns anything but false or nil for a given
-- Cell, it will be added to the Trajectory. If this argument is missing, all Cells will be
-- included in the Trajectory.
-- @arg data.greater A function (Cell, Cell)->boolean to sort the Trajectory. Such function must
-- return true if the first Cell has priority over the second one. When using this argument,
-- Trajectory compares each pair of Cells to establish an execution order to be used by
-- Utils:forEachCell(). As default, the Trajectory will not be ordered and so Utils:forEachCell()
-- will run in the order the Cells were pushed into the CellularSpace. See
-- Utils:greaterByAttribute() for predefined options for this argument.
-- @arg data.build A boolean value indicating whether the Trajectory should be computed when
-- created. The default value is true.
-- @output cells A vector of Cells pointed by the Trajectory.
-- @output parent The CellularSpace where the Trajectory takes place.
-- @output select The last function used to filter the Trajectory.
-- @output greater The last function used to sort the Trajectory.
-- @usage traj = Trajectory{
--     target = cs,
--     select = function(c)
--         return c.cover == "forest"
--     end,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory{
--     target = cs,
--     greater = function(c, d)
--         return c.dist < d.dist
--     end
-- }
-- 
-- traj = Trajectory{
--     target = cs,
--     build = false
-- }
function Trajectory(data)
	verifyNamedTable(data)

	checkUnnecessaryArguments(data, {"target", "build", "select", "greater"})

	if data.target == nil then
		mandatoryArgumentError("target")
	elseif type(data.target) ~= "CellularSpace" and type(data.target) ~= "Trajectory" then
		incompatibleTypeError("target", "CellularSpace or Trajectory", data.target)
	end

	defaultTableValue(data, "build", true)

	data.parent = data.target

	-- Copy the functions from the parent to the Trajectory (only those that do not exist)
	forEachElement(data.parent, function(idx, value, mtype)
		if mtype == "function" and data[idx] == nil then
			data[idx] = value
		end
	end)

	data.target = nil

	optionalTableArgument(data, "select", "function")
	optionalTableArgument(data, "greater", "function")

	local cObj = TeTrajectory()
	data.cObj_ = cObj
	data.cells = {}

	setmetatable(data, metaTableTrajectory_)

	if data.build then
		data:filter()
		if data.greater then data:sort() end
		data.build = nil
	end

	cObj:setReference(data)

	return data
end

