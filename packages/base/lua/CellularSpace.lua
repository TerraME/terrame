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

TeCoord.type_ = "Coord" -- We now use Coord only internally, but it is necessary to set its type.

local function getCoordCoupling(cs, data)
	return function(cell)
		local neighborhood = Neighborhood()
		local neighCell = data.target:get(cell.x, cell.y)
		if neighCell then
			neighborhood:add(neighCell, 1)
		end
		return neighborhood
	end
end

local function getDiagonalNeighborhood(cs, data)
	return function(cell)
		local neigh = Neighborhood()
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do
				if (lin ~= 0 and col ~= 0) or (data.self and lin == 0 and col == 0) then
					local index = nil
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol,
							((cell.y + lin) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
					else
						index = cs:get(cell.x + col, cell.y + lin)
					end
					if index ~= nil then
						table.insert(indexes, index)
					end
				end

				col = col + 1
			end
			lin = lin + 1
		end

		local weight = 1 / #indexes
		for i, index in ipairs(indexes) do
			neigh:add(index, weight)
		end

		return neigh
	end
end

local function getFunctionNeighborhood(cs, data)
	return function(cell)
		local neighborhood = Neighborhood()
		forEachCell(cs, function(neighCell)
			if data.filter(cell, neighCell) then
				neighborhood:add(neighCell, data.weight(cell, neighCell))
			end
		end)
		return neighborhood
	end
end

local function getMooreNeighborhood(cs, data)
	return function(cell)
		local neigh = Neighborhood()
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				if data.self or (lin ~= col or col ~= 0) then
					local index = nil
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol,
							((cell.y + lin) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
					else
						index = cs:get(cell.x + col, cell.y + lin)
					end
					if index ~= nil then
						table.insert(indexes, index)
					end
				end

				col = col + 1
			end
			lin = lin + 1
		end

		local weight = 1 / #indexes
		for i, index in ipairs(indexes) do
			neigh:add(index, weight)
		end
		return neigh
	end
end

local function getMxNNeighborhood(cs, data)
	local m = math.floor(data.m / 2)
	local n = math.floor(data.n / 2)

	return function(cell)
		local neighborhood = Neighborhood()
		for lin = -n, n do
			for col = -m, m do
				local neighCell = data.target:get(cell.x + col, cell.y + lin)
				if neighCell then
					if data.filter(cell, neighCell) then
						neighborhood:add(neighCell, data.weight(cell, neighCell))
					end
				end
			end
		end
		return neighborhood
	end
end

local function getVonNeumannNeighborhood(cs, data)
	return function(cell)
		local neigh = Neighborhood()
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do
				if ((lin == 0 or col == 0) and lin ~= col) or (data.self and lin == 0 and col == 0) then
					local index = nil
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol,
							((cell.y + lin) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)
					else
						index = cs:get(cell.x + col, cell.y + lin)
					end
					if index ~= nil then
						table.insert(indexes, index)
					end
				end

				col = col + 1
			end
			lin = lin + 1
		end

		local weight = 1 / #indexes
		for i, index in ipairs(indexes) do
			neigh:add(index, weight)
		end

		return neigh
	end
end

local function checkCsv(self)
	defaultTableValue(self, "sep", ",")
end

local function checkMap(self)
	defaultTableValue(self, "sep", " ")

	local getFileName = function(filename)
		for i = 1, filename:len() do
			if filename:sub(i, i) == "." then
				return filename:sub(1, i - 1)
			end
		end
		return filename
	end

	defaultTableValue(self, "attrname", getFileName(self.database))
end

local function checkMdb(self)
	mandatoryTableArgument(self, "theme", "string") -- SKIP
	defaultTableValue(self, "layer", "") -- SKIP
	defaultTableValue(self, "where", "") -- SKIP

	self.cObj_:setTheme(self.theme) -- SKIP
	self.cObj_:setLayer(self.layer) -- SKIP
	self.cObj_:setWhereClause(self.where) -- SKIP

	if type(self.select) == "string" then -- SKIP
		self.select = {self.select}
	end

	defaultTableValue(self, "select", {})

	for i in ipairs(self.select) do -- SKIP
		self.cObj_:addAttrName(self.select[i]) -- SKIP
	end
end

local function checkMySQL(self)
	-- until 1024 also 65535
	defaultTableValue(self, "port", 3306)
	defaultTableValue(self, "host", "localhost")
	defaultTableValue(self, "user", "root")
	mandatoryTableArgument(self, "password", "string")
	mandatoryTableArgument(self, "database", "string")

	verify(self.database ~= "", "Invalid database name.")

	integerTableArgument(self, "port")
	positiveTableArgument(self, "port")

	if self.port < 1024 then
		customError("Argument 'port' should have values above 1023 to avoid using system reserved values.")
	end

	self.cObj_:setUser(self.user)
	self.cObj_:setHostName(self.host)
	self.cObj_:setPassword(self.password)
	self.cObj_:setPort(self.port)

	mandatoryTableArgument(self, "theme", "string")
	defaultTableValue(self, "layer", "")
	defaultTableValue(self, "where", "")

	self.cObj_:setTheme(self.theme) 
	self.cObj_:setLayer(self.layer)
	self.cObj_:setWhereClause(self.where)

	if type(self.select) == "string" then
		self.select = {self.select}
	end

	defaultTableValue(self, "select", {})

	for i in ipairs(self.select) do
		self.cObj_:addAttrName(self.select[i])
	end
end

local function checkShape(self)
	local dbf = self.database:sub(1, self.database:len() - 3).."dbf"
	local f = io.open(dbf)
	if not f then
		customError("File '"..dbf.."' not found.")
	else
		io.close(f)
	end
end

local function checkVirtual(self)
	integerTableArgument(self, "xdim")
	positiveTableArgument(self, "xdim")

	defaultTableValue(self, "ydim", self.xdim)
	integerTableArgument(self, "ydim")
	positiveTableArgument(self, "ydim")
end

local function loadCsv(self)
	if self.minRow == nil then self.minRow = 100000 end
	if self.minCol == nil then self.minCol = 100000 end
	if self.maxRow == nil then self.maxRow = -self.minRow end
	if self.maxCol == nil then self.maxCol = -self.minCol end

	self.cells = {}
	self.cObj_:clear()
	local data = CSVread(self.database, self.sep)
	local cellIdCounter = 0
	for i = 1, #data do
		cellIdCounter = cellIdCounter + 1
		data[i].id = tostring(cellIdCounter)
		local cell = Cell(data[i])
		self:add(cell)
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
	end
	return 
end

local function loadDb(self)
	self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow = self.cObj_:load()

	if self.cells == nil then
		customError("It was not possible to load the CellularSpace.") -- SKIP
	end

	table.sort(self.cells, function(a, b) 
		if a.x < b.x then return true; end
		if a.x > b.x then return false; end
		return a.y < b.y
	end)

	self.xdim = self.maxCol
	self.ydim = self.maxRow
	self.cObj_:clear()
	for _, tab in pairs(self.cells) do
		tab.parent = self
		self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
	end
end

local function loadMap(self)
	local i = 0
	local j = 0

	if self.minRow == nil then self.minRow = 100000 end
	if self.minCol == nil then self.minCol = 100000 end
	if self.maxRow == nil then self.maxRow = -self.minRow end
	if self.maxCol == nil then self.maxCol = -self.minCol end

	self.cells = {}
	self.cObj_:clear()
	for line in io.lines(self.database) do
		j = 0

		local res = CSVparseLine(line, self.sep)

		forEachElement(res, function(_, value)
			local p = Cell {x = j, y = i} 
		 	p[self.attrname] = tonumber(value)
			self:add(p)
			self.cObj_:addCell(p.x, p.y, p.cObj_)
			j = j + 1
		end)
		i = i + 1
	end

	self.xdim = self.maxRow
	self.ydim = self.maxCol
end

local function loadShape(self)
	self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow = self.cObj_:loadShape()

	table.sort(self.cells, function(a, b) 
		if a.x < b.x then return true; end
		if a.x > b.x then return false; end
		return a.y < b.y
	end)

	self.xdim = self.maxCol
	self.ydim = self.maxRow
	self.cObj_:clear()
	for i, tab in pairs(self.cells) do
		tab.parent = self
		self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
	end
end

local function loadVirtual(self)
	self.minRow = 0
	self.minCol = 0
	self.maxRow = self.ydim - 1
	self.maxCol = self.xdim - 1

	self.cells = {}
	self.cObj_:clear()
	local cellIdCounter = 1
	for i = 1, self.xdim do
		for j = 1, self.ydim do
			local c = Cell{id = tostring(cellIdCounter), x = i - 1, y = j - 1}
			cellIdCounter = cellIdCounter + 1
			c.parent = self
			self.cObj_:addCell(c.x, c.y, c.cObj_)
			table.insert(self.cells, c)
		end
	end
end

local CellularSpaceDrivers = {}

local function registerCellularSpaceDriver(data)
	if type(data.compulsory) == "string" then
		data.compulsory = {data.compulsory}
	end

	defaultTableValue(data, "compulsory", {})
	defaultTableValue(data, "extension", true)

	mandatoryTableArgument(data, "load", "function")
	mandatoryTableArgument(data, "check", "function")
	mandatoryTableArgument(data, "dbType", "string")

	CellularSpaceDrivers[data.dbType] =  data
end

registerCellularSpaceDriver{
	dbType = "mdb",
	load = loadDb,
	check = checkMdb
}

registerCellularSpaceDriver{
	dbType = "shp",
	load = loadShape,
	check = checkShape
}

registerCellularSpaceDriver{
	dbType = "virtual",
	extension = false,
	compulsory = "xdim",
	optional = "ydim",
	load = loadVirtual,
	check = checkVirtual
}

registerCellularSpaceDriver{
	dbType = "csv",
	optional = "sep",
	load = loadCsv,
	check = checkCsv
}

registerCellularSpaceDriver{
	dbType = "map",
	optional = {"sep", "attrname"},
	load = loadMap,
	check = checkMap
}

registerCellularSpaceDriver{
	dbType = "mysql",
	extension = false,
	compulsory = "password",
	optional = {"host", "user", "port"},
	load = loadDb,
	check = checkMySQL
}

CellularSpace_ = {
	type_ = "CellularSpace",
	--- Add a new Cell to the CellularSpace. It will be the last Cell of the CellularSpace when one uses Utils:forEachCell().
	-- @arg cell A Cell.
	-- @usage cs = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- cell = Cell{x = 10, y = 11}
	-- cs:add(cell)
	add = function(self, cell)
		if type(cell) ~= "Cell" then
			incompatibleTypeError(1, "Cell", cell)
		elseif cell.parent ~= nil then 
			customError("The cell already has a parent.")
		end

		verify(not self:get(cell.x, cell.y), "Cell ("..cell.x..", "..cell.y..") already belongs to the CellularSpace.")

		cell.parent = self
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		table.insert(self.cells, cell)
		self.minRow = math.min(self.minRow, cell.y)
		self.minCol = math.min(self.minCol, cell.x)
		self.maxRow = math.max(self.maxRow, cell.y)
		self.maxCol = math.max(self.maxCol, cell.x)
	end,
	--- Create a Neighborhood for each Cell of the CellularSpace.
	-- @arg data.inmemory If true (default), a Neighborhood will be built and stored for
	-- each Cell of the CellularSpace. The Neighborhoods will change only if the
	-- modeler add or remove neighbors explicitly. If false, a Neighborhood will be
	-- computed every time the simulation calls Cell:getNeighborhood(), for
	-- example when using Utils:forEachNeighbor(). In this case, if any of the attributes 
	-- the Neighborhood is based on changes then the resulting Neighborhood might be different.
	-- Neighborhoods not in memory also help the simulation to run with larger datasets,
	-- as they are not explicitly represented, but they consume more
	-- time as they need to be built again and again along the simulation.
	-- @arg data.strategy A string with the strategy to be used for creating the Neighborhood. 
	-- See the table below.
	-- @tabular strategy
	-- Strategy & Description & Compulsory Arguments & Optional Arguments \
	-- "3x3" & A 3x3 (Couclelis) Neighborhood (Deprecated. Use mxn instead). & & name, filter, weight, inmemory \
	-- "coord" & A bidirected relation between two CellularSpaces connecting Cells with the same 
	-- (x, y) coordinates. & target & name, inmemory\
	-- "diagonal" & Connect each Cell to its (at most) four diagonal neighbors.
	-- & & name, self, wrap, inmemory \
	-- "function" & A Neighborhood based on a function where any other Cell can be a neighbor. & 
	-- filter & name, weight, inmemory \
	-- "moore"(default) & A Moore (queen) Neighborhood, connecting each Cell to its (at most) 
	-- eight touching Cells. & & name, self, wrap, inmemory \
	-- "mxn" & A m (columns) by n (rows) Neighborhood within the CellularSpace or between two
	-- CellularSpaces if target is used. & & m, name, n, filter, weight, target, inmemory \
	-- "vonneumann" & A von Neumann (rook) Neighborhood, connecting each Cell to its (at most)
	-- four ortogonally surrounding Cells. & & name, self, wrap, inmemory
	-- @arg data.filter A function(Cell, Cell)->bool, where the first argument is the Cell itself
	-- and the other represent a possible neighbor. It returns true when the neighbor will be
	-- included in the relation. In the case of two CellularSpaces, this function is called twice
	-- for e ach pair of Cells, first filter(c1, c2) and then filter(c2, c1), where c1 belongs to
	-- cs1 and c2 belongs to cs2. The default value is a function that returns true.
	-- @arg data.m Number of columns. If m is even then it will be increased by one to keep the
	-- Cell in the center of the Neighborhood. The default value is 3.
	-- @arg data.n Number of rows. If n is even then it will be increased by one to keep the Cell
	-- in the center of the Neighborhood. The default value is m.
	-- @arg data.name A string with the name of the Neighborhood to be created. 
	-- The default value is "1".
	-- @arg data.self Add the Cell as neighbor of itself? The default value is false. Note that the 
	-- functions that do not require this argument always depend on a filter function, which will
	-- define whether the Cell can be neighbor of itself.
	-- @arg data.target Another CellularSpace whose Cells will be used to create neighborhoods.
	-- @arg data.weight A function (Cell, Cell)->number, where the first argument is the Cell
	-- itself and the other represent its neighbor. It returns the weight of the relation. This
	-- function will be called only if filter returns true.
	-- @arg data.wrap Will the Cells in the borders be connected to the Cells in the
	-- opposite border? The default value is false.
	-- @usage cell = Cell{
	--     height = Random{min = 0, max = 100}
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10,
	--     instance = cell
	-- }
	--
	-- cs:createNeighborhood() -- moore
	--
	-- cs:createNeighborhood{
	--     name = "moore"
	-- }
	--
	-- cs:createNeighborhood{
	--     strategy = "vonneumann",
	--     name = "vonneumann",
	--     self = true
	-- }
	--
	-- cs:createNeighborhood{
	--     strategy = "mxn",
	--     m = 5,
	--     name = "5",
	--     filter = function(cell, candidate)
	--         return cell.height > candidate.height
	--     end,
	--     weight = function(cell, candidate)
	--         return (cell.height - candidate.height) / 100
	--     end
	-- }
	--
	--
	-- cs2 = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- cs:createNeighborhood{
	--     strategy = "mxn",
	--     target = cs2,
	--     m = 5,
	--     name = "spatialCoupling"
	-- }
	createNeighborhood = function(self, data)
		if data == nil then
			data = {}
		else
			verifyNamedTable(data)
		end

		defaultTableValue(data, "name", "1")

		if self.cells[1] and #self.cells[1] > 0 then
			if self.cells[1]:getNeighborhood(data.name) ~= nil then
				customError("Neighborhood '"..data.name.."' already exists.")
			end
		end

		defaultTableValue(data, "strategy", "moore")
		defaultTableValue(data, "inmemory", true)

		switch(data, "strategy"):caseof{
			diagonal = function()
				verifyUnnecessaryArguments(data, {"self", "wrap", "name", "strategy", "inmemory"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "wrap", false)

				data.func = getDiagonalNeighborhood
			end,
			["function"] = function() 
				verifyUnnecessaryArguments(data, {"filter", "weight", "name", "strategy", "inmemory"})

				mandatoryTableArgument(data, "filter", "function")
				defaultTableValue(data, "weight", function() return 1 end)

				data.func = getFunctionNeighborhood
			end,
			moore = function()
				verifyUnnecessaryArguments(data, {"self", "wrap", "name", "strategy", "inmemory"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "wrap", false)

				data.func = getMooreNeighborhood
			end,
			mxn = function()
				verifyUnnecessaryArguments(data, {"filter", "weight", "name", "strategy", "m", "n", "target", "inmemory"})

				defaultTableValue(data, "filter", function() return true end)
				defaultTableValue(data, "weight", function() return 1 end)
				defaultTableValue(data, "target", self)

				defaultTableValue(data, "m", 3)
				integerTableArgument(data, "m")
				positiveTableArgument(data, "m")

				if data.m % 2 == 0 then
					data.m = data.m + 1
					customWarning("Argument 'm' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")
				end

				defaultTableValue(data, "n", data.m)
				integerTableArgument(data, "n")
				positiveTableArgument(data, "n")
				if data.n % 2 == 0 then
					data.n = data.n + 1
					customWarning("Argument 'n' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.")
				end

				data.func = getMxNNeighborhood
			end,
			vonneumann = function() 
				verifyUnnecessaryArguments(data, {"name", "strategy", "wrap", "self", "inmemory"})

				defaultTableValue(data, "self", false)
				defaultTableValue(data, "wrap", false)

				data.func = getVonNeumannNeighborhood
			end,
			["3x3"] = function() 
				deprecatedFunction("createNeighborhood with strategy 3x3", "mxn")
			end,
			coord = function() 
				verifyUnnecessaryArguments(data, {"name", "strategy", "target", "inmemory"})

				mandatoryTableArgument(data, "target", "CellularSpace")

				data.func = getCoordCoupling
			end
		}

		local func = data.func(self, data)

		if data.inmemory then
			forEachCell(self, function(cell)
				cell:addNeighborhood(func(cell), data.name)
			end)
		else
			forEachCell(self, function(cell)
				cell:addNeighborhood(func, data.name)
			end)
		end

		local mtarget = data.target

		if mtarget and mtarget ~= self then
			local data2 = {}

			forEachElement(data, function(idx, value)
				data2[idx] = value
			end)

			data2.target = self

			local func = data.func(mtarget, data2)

			if data.inmemory then
				forEachCell(mtarget, function(cell)
					cell:addNeighborhood(func(cell), data2.name)
				end)
			else
				forEachCell(mtarget, function(cell)
					cell:addNeighborhood(func, data2.name)
				end)
			end
		end
	end,
	--- Cut the CellularSpace according to maximum and minimum coordinates.
	-- It returns a Trajectory with the selected Cells.
	-- @arg data.xmin A number with the minimum value of x.
	-- @arg data.xmax A number with the maximum value of x.
	-- @arg data.ymin A number with the minimum value of y.
	-- @arg data.ymax A number with the maximum value of y.
	-- @usage cs = CellularSpace{xdim = 10}
	--
	-- cs2 = cs:cut{xmin = 3, ymax = 8}
	-- print(#cs2)
	cut = function(self, data)
		if data == nil then
			data = {}
		else
			verifyNamedTable(data)
		end

		verifyUnnecessaryArguments(data, {"xmin", "xmax", "ymin", "ymax"})

		defaultTableValue(data, "xmin", self.minCol)
		defaultTableValue(data, "xmax", self.maxCol)
		defaultTableValue(data, "ymin", self.minRow)
		defaultTableValue(data, "ymax", self.maxRow)

		local result = Trajectory{target = self, build = false}

		forEachCell(self, function(cell)
			if cell.x >= data.xmin and cell.x <= data.xmax and
			   cell.y >= data.ymin and cell.y <= data.ymax then
				result:add(cell)
			end
		end)
		return result
	end,
	--- Return a Cell from the CellularSpace, given its unique identifier or its location. If the Cell
	-- does not belong to the CellularSpace then it will return nil.
	-- @arg xIndex A number indicating an x coordinate. It can also be a string with the object id.
	-- @arg yIndex A number indicating a y coordinate. This argument is unnecessary when the first 
	-- argument is a string.
	-- @usage cs = CellularSpace{xdim = 10}
	--
	-- cell = cs:get(2, 2)
	-- print(cell.x)
	-- print(cell.y)
	--
	-- cell = cs:get("5")
	-- print(cell.id)
	get = function(self, xIndex, yIndex)
		if type(xIndex) == "string" then
			if yIndex ~= nil then
				customWarning("As #1 is string, #2 should be nil, but got "..type(yIndex)..".")
			end

			return self.cObj_:getCellByID(xIndex)
		end

		mandatoryArgument(1, "number", xIndex)
		integerArgument(1, xIndex)

		mandatoryArgument(2, "number", yIndex)
		integerArgument(2, yIndex)

		local data = {x = xIndex, y = yIndex}
		local cObj_ = TeCoord(data)

		return self.cObj_:getCell(cObj_)
	end,
	--- Return a Cell from the CellularSpace given its x and y location.
	-- @arg xIndex A number with the x location of the Cell to be returned.
	-- @arg yIndex A number with the y location of the Cell to be returned.
	-- @deprecated CellularSpace:get
	getCell = function(self, xIndex, yIndex)
		deprecatedFunction("getCell", "get")
	end,
	--- Return a Cell from the CellularSpace given its id.
	-- @arg cellID A string with the unique identifier of the Cell to be returned.
	-- @deprecated CellularSpace:get
	getCellByID = function(self, cellID)
		deprecatedFunction("getCellByID", "get")
	end,
	--- Return all the Cells of the CellularSpace as a non-named table.
	-- @deprecated CellularSpace.cells
	getCells = function(self)
		deprecatedFunction("getCells", ".cells")
	end,
	--- Load the CellularSpace from the database. TerraME automatically executes this function when
	-- the CellularSpace is created, but one can execute this to load the attributes again, erasing
	-- all attributes and relations created by the modeler.
	-- @usage cs = CellularSpace{xdim = 10}
	-- cs:load()
	load = function(self)
		customError("Load function was not implemented.")
	end,
	--- Load a Neighborhood stored in an external source. Each Cell receives its own set of 
	-- neighbors.
	-- @arg data.name A string with the location of the Neighborhood 
	-- to be loaded. See below.
	-- @arg data.check A boolean value indicating whether this function should match the
	-- layer name of the CellularSpace with the one described in the source. The default value is true.
	-- @arg tbAttrLoad.source A string with the name of the Neighborhood
	-- to be loaded within TerraME. The default value is "1".
	-- @tabular name
	-- Source & Description \
	--"*.gal" & Load a Neighborhood from contiguity relationships described as a GAL file.\
	-- "*.gwt" & Load a Neighborhood from a GWT (generalized weights) file.\
	-- "*.gpm" & Load a Neighborhood from a GPM (generalized proximity matrix) file. \
	-- Any other & Load a Neighborhood from table stored in the same database of the 
	-- CellularSpace. \
	-- @usage -- DONTRUN
	-- config = getConfig() 
	-- mhost = config.host
	-- muser = config.user
	-- mpassword = config.password
	-- mport = config.port
	--
	-- cs = CellularSpace{
	--     host = mhost,
	--     user = muser,
	--     password = mpassword,
	--     port = mport,
	--     database = "cabecadeboi",
	--     theme = "cells900x900"
	-- }
	--
	-- cs:loadNeighborhood{source = file("cabecadeboi-neigh.gpm", "base")}
	loadNeighborhood = function(self, data)
		verifyNamedTable(data)
		verifyUnnecessaryArguments(data, {"source", "name", "check"})

		mandatoryTableArgument(data, "source", "string")

		if data.source:endswith(".gal") or data.source:endswith(".gwt") or data.source:endswith(".gpm") then
			if not io.open(data.source, "r") then
				resourceNotFoundError("source", data.source)
			end
		else
			local ext = string.match(data.source, "(([^%.]+))$")

			if ext == data.source then
				customError("Argument 'source' does not have an extension.")
			else
				invalidFileExtensionError("source", ext)
			end
		end

		defaultTableValue(data, "name", "1")
		defaultTableValue(data, "check", true)

		self.cObj_:loadNeighborhood(data.source, data.name, data.check)
	end,
	--- Notify every Observer connected to the CellularSpace.
	-- @arg modelTime A number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage cs = CellularSpace{
	--     xdim = 10,
	--     value = 5
	-- }
	--
	-- Chart{target = cs}
	--
	-- cs:notify()
	-- cs:notify()
	notify = function(self, modelTime)
		if modelTime == nil then
			modelTime = 0
		elseif type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		else
			optionalArgument(1, "number", modelTime)
			positiveArgument(1, modelTime, true)
		end

		local midx = ""
		local typename = ""
		local ok, result = pcall(function()
			if self.obsattrs_ then
				typename = "CellularSpace"
				forEachElement(self.obsattrs_, function(idx)
					midx = idx
					self[idx.."_"] = self[idx](self)
				end)
			end

			if self.cellobsattrs_ then
				typename = "Cell"
				forEachElement(self.cellobsattrs_, function(idx)
					midx = idx
					forEachCell(self, function(cell)
						cell[idx.."_"] = cell[idx](cell)
					end)
				end)
			end
		end)

		if not ok then
			local str = _Gtme.cleanErrorMessage(result)
			local msg = "Could not execute function '"..midx.."' from "..typename..": "..str.."."

			customError(msg)
		end

		self.cObj_:notify(modelTime)
	end,
	--- Return a random Cell from the CellularSpace.
	-- @usage cs = CellularSpace{
	--     xdim = 10
	-- }
	--
	-- cell = cs:sample()
	-- print(type(cell))
	sample = function(self)
		return self.cells[Random():integer(1, #self)]
	end,
	--- Save the attributes of a CellularSpace into the same database it was loaded from.
	-- @arg time A number indicating a temporal value to be stored in the database, 
	-- which can be different from the simulation time.
	-- @arg outputTableName Name of the table to store the attributes of the Cells.
	-- @arg attrNames A vector with the names of the attributes to be saved.
	-- When saving a single attribute, you can use
	-- attrNames = "attribute" instead of attrNames = {"attribute"}.
	-- @usage -- DONTRUN
	-- config = getConfig()
	-- mhost = config.host
	-- muser = config.user
	-- mpassword = config.password
	-- mport = config.port
	--
	-- cs = CellularSpace{
	--     host = mhost,
	--     user = muser,
	--     password = mpassword,
	--     port = mport,
	--     database = "cabecadeboi",
	--     theme = "cells900x900"
	-- }
	--
	-- cs:save(2, "themeName", "height_")
	save = function(self, time, outputTableName, attrNames)
		if type(time) == "Event" then
			time = time:getTime()
		else
			mandatoryArgument(1, "number", time)
			positiveArgument(1, time, true)
			integerArgument(1, time)
		end

		mandatoryArgument(2, "string", outputTableName)

		if type(attrNames) == "string" then attrNames = {attrNames} end

		mandatoryArgument(3, "table", attrNames)

		for _, attr in pairs(attrNames) do
			if not self.cells[1][attr] then
				customError("Attribute '"..attr.."' does not exist in the CellularSpace.")
			end
		end
		local erros = self.cObj_:save(time, outputTableName, attrNames, self.cells)
	end,
	--- Return the number of Cells in the CellularSpace.
	-- @deprecated CellularSpace:#
	size = function(self)
		deprecatedFunction("size", "operator #")
	end,
	--- Split the CellularSpace into a table of Trajectories according to a classification 
	-- strategy. The Trajectories will have empty intersection and union equal to the
	-- whole CellularSpace (unless function below returns nil for some Cell). It works according
    -- to the type of its only and compulsory argument.
	-- @arg argument A string or a function, as follows:
	-- @tabular argument
	-- Type of argument & Description \
	-- string & The argument must represent the name of one attribute of the Cells of the
	-- CellularSpace. Split then creates one Trajectory for each possible value of the attribute
	-- using the value as name and fills them with the Cells that have the respective attribute
	-- value. If the CellularSpace has an instance and the respective attribute in the instance
	-- is a Random value with discrete or categorical strategy, it will use the possible values
	-- to create Trajectories, which means that the returning Trajectories can have size zero in
	-- this case. \
	-- function & The argument is a function that gets a Cell as argument and returns a
	-- name for the Cell, which can be a number, string, or boolean value.
	-- Trajectories are then named according to the
	-- returning value.
	-- @usage cell = Cell{
	--     cover = Random{"pasture", "forest"},
	--     forest = Random{min = 0, max = 1}
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 20,
	--     instance = cell
	-- }
	--
	-- ts = cs:split("cover")
	-- print(#ts.forest) -- can be zero because it comes from an instance
	-- print(#ts.pasture) -- also
	-- 
	-- ts2 = cs:split(function(cell)
	--     if cell.forest > 0.5 then 
	--         return "gt" 
	--     else 
	--         return "lt" 
	--     end
	-- end)
	--
	-- if ts2.gt then -- might not exist as it does not come from an instance
	--     print(#ts2.gt)
	-- end
	split = function(self, argument)
		if type(argument) ~= "function" and type(argument) ~= "string" then
			if argument == nil then
				mandatoryArgumentError(1)
			else
				incompatibleTypeError(1, "string or function", argument)
			end
		end

		local result = {}
		local class

		if type(argument) == "string" then
			if self:sample()[argument] == nil then
				customError("Attribute '"..argument.."' does not exist.")
			end

			if self.instance and type(self.instance[argument]) == "Random" and self.instance[argument].values then
				forEachElement(self.instance[argument].values, function(_, value)
					 result[value] = Trajectory{target = self, build = false}
				end)
			end

			local value = argument
			argument = function(cell)
				return cell[value]
			end
		end

		forEachCell(self, function(cell)
			class = argument(cell)
			if class == nil then return end -- the cell will not belong to any Trajectory

			if result[class] == nil then
				result[class] = Trajectory{target = self, build = false}
			end
			table.insert(result[class].cells, cell)
			result[class].cObj_:add(#result[class], cell.cObj_)
		end)

		return result
	end,
	--- Synchronize the CellularSpace, calling the function synchronize() for each of its Cells.
	-- @arg values A string or a vector of strings with the attributes to be synchronized. If 
	-- empty, TerraME synchronizes every attribute of the Cells but the (x, y) coordinates.
	-- @usage cell = Cell{
	--     forest = Random{min = 0, max = 1}
	-- }
	--
	-- cs = CellularSpace{
	--     xdim = 10,
	--     instance = cell
	-- }
	--
	-- cs:synchronize()
	-- c = cs:sample()
	-- print(c.forest)
	-- print(c.past.forest)
	synchronize = function(self, values)
		if type(values) == "string" then values = {values} end
		if type(values) ~= "table" then 
			if values == nil then
				values = {}
				local cell = self.cells[1]
				for k, v in pairs(cell) do
					if not belong(k, {"past", "cObj_", "x", "y"}) then
						table.insert(values, k)
					end
				end
			else
				incompatibleTypeError(1, "string, table or nil", values)
			end
		end
		local s = "return function(cell)\n"
		s = s.."cell.past = {"

		for _, v in pairs(values) do
			if type(v) == "string" then
				s = s..v.." = cell."..v..", "
			else
				customError("Argument 'values' should contain only strings.")
			end
		end

		s = s.."} end"

		forEachCell(self, load(s)())
	end
}

metaTableCellularSpace_ = {
	__index = CellularSpace_,
	--- Return the number of Cells in the CellularSpace.
	-- @usage cs = CellularSpace{xdim = 5}
	--
	-- print(#cs)
	__len = function(self)
		return #self.cells
	end,
	__tostring = _Gtme.tostring
}

--- A multivalued set of Cells. It can be retrieved from databases, files, or created
-- directly within TerraME. 
-- Every Cell of a CellularSpace has an (x, y) location. The Cell with lower (x, y)
-- represents the upper left location.
-- See the table below with the description and the arguments of each data source.
-- Calling Utils:forEachCell() traverses CellularSpaces.
-- @arg data.database Name of the database or the location of a
-- file. See Package:file() for loading CellularSpaces from packages.
-- @arg data.theme A string with the name of the theme to be loaded.
-- @arg data.dbType A string with the name of the data source. It tries to infer the data source
-- according to the extension of the argument database. When it does not have an extension or
-- when the extension is not recognized it will read data from a MySQL database.
-- TerraME always converts this string to lower case.
-- @arg data.host String with the host where the database is stored.
-- The default value is "localhost".
-- @arg data.port Number with the port of the connection. The default value is the standard port
-- of the DBMS. For example, MySQL uses 3306 as standard port.
-- @arg data.user String with the username. The default value is "".
-- @arg data.sep A string with the file separator. The default value is ",".
-- @arg data.password A string with the password. The default value is "".
-- @arg data.layer A string with the name of the database layer. This argument is necessary only
-- when there are two or more themes with the same name in the database. The default value is "". 
-- @arg data.autoload A boolean value indicating whether the CellularSpace will be loaded
-- automatically (true, default value) or the user by herself will call load (false).
-- If false, TerraME will not create the automatic functions based on the attributes of the Cells
-- (see argument instance).
-- @arg data.select A table containing the names of the attributes to be retrieved (as default it
-- will read all attributes). When retrieving a single attribute, you can use select = "attribute"
-- instead of select = {"attribute"}. It is possible to rename attributes using "as", for example,
-- select = {"lc as landcover"} reads lc from the database but replaces the name to landcover in
-- the Cells. Attributes that contain "." in their names (for example, when the theme is composed
-- by more than one table) will be
-- read with "_" replacing "." in order to follow Lua syntax to manipulate data.
-- @arg data.where An SQL restriction on the properties of the Cells (as default it applies no
-- restriction). Only the Cells that reflect the established criteria will be loaded. Note that SQL
-- uses the operator "=" to compare values, instead of "==". This argument can only be used when
-- reading data from a database.
-- @arg data.attrname A string with an attribute name.
-- @arg data.... Any other attribute or function for the CellularSpace.
-- @arg data.instance A Cell with the description of attributes and functions. 
-- When using this argument, each Cell will have attributes and functions according to the
-- instance. It also calls Cell:init() from the instance for each of its Cells.
-- Every attribute from the Cell that is a Random will be converted into Random:sample().
-- Additional functions are also created to the CellularSpace, according to the attributes of the
-- instance. For each attribute of the instance, one function is created in the CellularSpace with
-- the same name (note that attributes declared exclusively in Cell:init() will not be mapped, as
-- they do not belong to the instance). The table below describes how each attribute is mapped:
-- @tabular instance
-- Type of attribute & Function within the CellularSpace \
-- function & Call the function of each of its Cells. \
-- number & Return the sum of the number in each of its Cells. \
-- boolean & Return the quantity of true values in its Cells. \
-- string & Return a table with positions equal to the unique strings and values equal to the
-- number of occurrences in each of its Cells.
-- @arg data.xdim Number of columns, in the case of creating a CellularSpace without needing to
-- load from a database.
-- @arg data.ydim Number of lines, in the case of creating a CellularSpace without needing to
-- load from a database. The default value is equal to xdim.
-- @tabular dbType
-- dbType & Description & Compulsory arguments & Optional arguments\
-- "mdb" & Load from a Microsoft Access database (.mdb)  file. & database, theme & layer,
-- select, where, autoload, ... \
-- "map" & Load from a text file where Cells are stored as numbers with its attribute value.
-- & & sep, attrname \
-- "csv" & Load from a Comma-separated value (.csv) file. Each column will become an attribute. It
-- requires at least two attributes: x and y. & database & sep, autoload, ...\
-- "mysql" & Load from a TerraLib database stored in a MySQL database. & database, theme & host, 
-- layer, password, port, select, user, where, autoload, ... \
-- "shp" & Load data from a shapefile. It requires three files with the same name and 
-- different extensions: .shp, .shx, and .dbf. The argument database must contain the file with
-- extension .shp.& database & autoload, ... \
-- "virtual" & Create a rectangular CellularSpace from scratch. Cells will be instantiated with
-- only two attributes, x and y, starting from (0, 0). & xdim & ydim, autoload, ...
-- @output cells A vector of Cells pointed by the CellularSpace.
-- @output parent The Environment it belongs.
-- @usage cs = CellularSpace{
--     xdim = 20,
--     ydim = 25
-- }
--
-- config = getConfig()
-- mhost = config.host
-- muser = config.user
-- mpassword = config.password
-- mport = config.port
--
-- cs2 = CellularSpace{
--     host = mhost,
--     user = muser,
--     password = mpassword,
--     port = mport,
--     database = "cabecadeboi",
--     theme = "cells900x900"
-- }
function CellularSpace(data)
	verifyNamedTable(data)

	if data.dbType == nil then
		if data.database == nil then -- virtual cellular space
			local candidates = {}
			forEachElement(CellularSpaceDrivers, function(idx, value)
				local all = true
				forEachElement(value.compulsory, function(midx, mvalue)
					if data[mvalue] == nil then
						all = false
					end
				end)

				if value.extension and (not data.database or getExtension(data.database) ~= idx) then
					all = false
				end
				if all then
					table.insert(candidates, idx)
				end
			end)

			if #candidates == 0 then
				customError("Not enough information to build the CellularSpace.")
			elseif #candidates == 1 then
				data.dbType = candidates[1]
			else
				-- TODO: unskip the lines below after updating to TerraLib 5
				str = "" -- SKIP
				forEachElement(candidates, function(idx, value)
					str = str..value..", " -- SKIP
				end)
				customError("More than one candidate: "..str) -- SKIP
			end
		else
			local ext = getExtension(data.database)

			data.dbType = "mysql"
			if CellularSpaceDrivers[ext] ~= nil then
				data.dbType = ext
			end
		end
	else
		mandatoryTableArgument(data, "dbType", "string")
		
		if CellularSpaceDrivers[data.dbType] == nil then
			local word = "It must be a string from the set ["
			forEachOrderedElement(CellularSpaceDrivers, function(a)
				word = word.."'"..a.."', "
			end)
			word = string.sub(word, 0, string.len(word) - 2).."]."
			customError("'"..data.dbType.."' is an invalid value for argument 'dbType'. "..word)
		elseif CellularSpaceDrivers[data.dbType].extension then
			mandatoryTableArgument(data, "database", "string")
			if getExtension(data.database) ~= data.dbType then
				customError("dbType and file extension should be the same.")
			end

			local f = io.open(data.database, "r") 
			if not f then
				resourceNotFoundError("database", data.database)
			else
				io.close(f)
			end
		end
	end

	defaultTableValue(data, "autoload", true)

	local cObj = TeCellularSpace()
	data.cObj_= cObj

	cObj:setDBType(data.dbType)

	if data.database then 
		mandatoryTableArgument(data, "database", "string")
		verify(data.database ~= "", "Empty database name.")
		cObj:setDBName(data.database)
	end

	if CellularSpaceDrivers[data.dbType].check then
		CellularSpaceDrivers[data.dbType].check(data)
	end

	data.load = CellularSpaceDrivers[data.dbType].load

	setmetatable(data, metaTableCellularSpace_)
	cObj:setReference(data)

	local function callFunc(func, mtype, attribute)
		local status, result = pcall(func) 

		if not status then
			local str = _Gtme.cleanErrorMessage(result)
			local msg

			if mtype == "function" then
				msg = "Could not execute function '"..attribute.."' from the Cells: "..str.."."
			else
				msg = "Could not find attribute '"..attribute.."' in all the Cells."
			end

			customError(msg)
		end
		return result
	end

	local function createSummaryFunctions(cell)
		forEachElement(cell, function(attribute, value, mtype)
			if attribute == "id" or attribute == "parent" or string.endswith(attribute, "_") then return
			elseif mtype == "function" then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(cs, args)
					local func = function()
						return forEachCell(cs, function(cell)
							return cell[attribute](cell, args)
						end)
					end

					return callFunc(func, "function", attribute)
				end
			elseif mtype == "number" or (mtype == "Random" and value.distrib ~= "categorical" and (value.distrib ~= "discrete" or type(value[1]) == "number")) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				if attribute ~= "x" and attribute ~= "y" then
					data[attribute] = function(cs)
						local func = function()
							local quantity = 0
							forEachCell(cs, function(cell)
								quantity = quantity + cell[attribute]
							end)
							return quantity
						end

						return callFunc(func, "number", attribute)
					end
				end
			elseif mtype == "boolean" then
					if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(cs)
					local quantity = 0
					forEachCell(cs, function(cell)
						if cell[attribute] then
							quantity = quantity + 1
						end
					end)
					return quantity
				end
			elseif mtype == "string" or (mtype == "Random" and (value.distrib == "categorical" or (value.distrib == "discrete" and type(value[1]) == "string"))) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(cs)
					local result = {}
					forEachCell(cs, function(cell)
						local value = cell[attribute]
						if result[value] then
							result[value] = result[value] + 1
						else
							result[value] = 1
						end
					end)
					return result
				end
			end
		end)
	end

	if data.autoload then
		data:load()
		-- needed for Environment's loadNeighborhood
		if data.database then
			data.layer = data.cObj_:getLayerName()
		end
		data.autoload = nil
	else
		data.cells = {}
	end

	if data.instance ~= nil then
		if data.autoload == false then
			customError("Parameter 'instance' can only be used with 'autoload = true'.")
		end

		mandatoryTableArgument(data, "instance", "Cell")

		if data.instance.isinstance then
			customError("The same instance cannot be used in two CellularSpaces.")
		end

		forEachCell(data, function(cell)
			setmetatable(cell, {__index = data.instance})
			forEachElement(data.instance, function(attribute, value, mtype)
				if not string.endswith(attribute, "_") and not belong(attribute, {"x", "id", "y", "past"}) then 
					cell[attribute] = value
				end
			end)

			forEachOrderedElement(data.instance, function(idx, value, mtype)
				if mtype == "Random" then
					cell[idx] = value:sample()
				end
			end)

			cell:init()
		end)

		createSummaryFunctions(data.instance)

		local newAttTable = {}
		forEachElement(data.cells[1], function(idx, value)
			if data.instance[idx] == nil then
				newAttTable[idx] = value
			end
		end)

		setmetatable(data.instance, nil)
		createSummaryFunctions(newAttTable)

		forEachElement(Cell_, function(idx, value)
			if idx == "init" then
				if not data.instance[idx] then
					data.instance[idx] = value
				end
				return
			end

			if data.instance[idx] then
				if type(value) == "function" then
					customWarning("Function '"..idx.."()' from Cell is replaced in the instance.")
				end
			else
				data.instance[idx] = value
			end
		end)

		local metaTableInstance = {__index = data.instance, __tostring = _Gtme.tostring}

		data.instance.type_ = "Cell"
		data.instance.isinstance = true

		forEachCell(data, function(cell)
			setmetatable(cell, metaTableInstance)
		end)
	end
	return data
end

