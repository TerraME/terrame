-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

local terralib = getPackage("terralib")

TeCoord.type_ = "Coord" -- We now use Coord only internally, but it is necessary to set its type.

local function loadNeighborhoodGAL(self, data)
	local file = openFile(data.source, "r")
	local header = file:read()
	local lineTest = CSVparseLine(header, "\t")
	local b
	if lineTest[2] ~= nil then 
		b = "\t"
	else 
		b = " " 
	end
	forEachCell(self, function(cell)
		cell:addNeighborhood(Neighborhood{}, data.name)
	end)
	local line_cell = file:read()
	while line_cell do
		if line_cell ~= nil then
			local line = CSVparseLine(line_cell, b)       
			local cell = self:get(line[1])
			if cell ~= nil then
				local neig = cell:getNeighborhood(data.name)
				local lineV = file:read()
				local lineID = CSVparseLine(lineV, b)
				for i = 1, tonumber(line[2]) do
					local n = self:get(lineID[i])
					neig:add(n)
				end
			end
		end
		line_cell = file:read()
	end
	closeFile(file)
end

local function loadNeighborhoodGPM(self, data)
	local file = openFile(data.source, "r")
	local header = file:read()
	local lineTest = CSVparseLine(header, "\t")
	local val
	if lineTest[4] == nil then 
		val = 1
	else 
		val = 2 
	end
	forEachCell(self, function(cell)
		cell:addNeighborhood(Neighborhood{}, data.name)
	end)
	local line_cell = file:read()
	while line_cell do
		if line_cell ~= nil then
			lineTest = CSVparseLine(line_cell, "\t")
			local b
			if lineTest[2] ~= nil then
				b = "\t"
			else 
				b = " " 
			end
			local line = CSVparseLine(line_cell, b)       
			local cell = self:get(line[1])
			if cell ~= nil then
				local neig = cell:getNeighborhood(data.name)
				local lineV = file:read()
				local lineID = CSVparseLine(lineV, b)
				local valfor = (tonumber(line[2]) * val)
				for i = 1, valfor, val do
					if lineID[i] ~= nil then
						local n = self:get(lineID[i])
						if val ~= 1 then 
							neig:add(n, tonumber(lineID[i+1]))
						else 
							neig:add(n) 
						end                        
					end
				end 
			end
		end
		line_cell = file:read()
	end
	closeFile(file)
end

local function loadNeighborhoodGWT(self, data)
	local file = openFile(data.source, "r")
	local header = file:read()
	local lineTest = CSVparseLine(header, "\t")
	local b
	if lineTest[2] ~= nil then
		b = "\t"
	else 
		b = " " 
	end
	forEachCell(self, function(cell)
		cell:addNeighborhood(Neighborhood{}, data.name)
	end)
	local line_cell = file:read()
	while line_cell do
		if line_cell ~= nil then
			local line = CSVparseLine(line_cell, b)       
			local cell = self:get(line[1])
			local neig = cell:getNeighborhood(data.name)
			local n = self:get(line[2])
			neig:add(n, tonumber(line[3]))
		end
		line_cell = file:read()
	end
	closeFile(file)
end

local function getCoordCoupling(_, data)
	return function(cell)
		local neighborhood = Neighborhood()
		local neighCell = data.target:get(cell.x, cell.y)
		if neighCell and not neighborhood:isNeighbor(neighCell) then
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
					local index
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.xMin) % (cs.xMax - cs.xMin + 1) + cs.xMin,
							((cell.y + lin) - cs.yMin) % (cs.yMax - cs.yMin + 1) + cs.yMin)
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
		for _, index in ipairs(indexes) do
			if not neigh:isNeighbor(index) then
				neigh:add(index, weight)
			end
		end

		return neigh
	end
end

local function getFunctionNeighborhood(cs, data)
	return function(cell)
		local neighborhood = Neighborhood()
		forEachCell(cs, function(neighCell)
			if data.filter(cell, neighCell) and not neighborhood:isNeighbor(cell) then
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
					local index
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.xMin) % (cs.xMax - cs.xMin + 1) + cs.xMin,
							((cell.y + lin) - cs.yMin) % (cs.yMax - cs.yMin + 1) + cs.yMin)
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
		for _, index in ipairs(indexes) do
			if not neigh:isNeighbor(index) then
				neigh:add(index, weight)
			end
		end
		return neigh
	end
end

local function getMxNNeighborhood(_, data)
	local m = math.floor(data.m / 2)
	local n = math.floor(data.n / 2)
	local cs = data.target

	return function(cell)
		local neighborhood = Neighborhood()
		for lin = -n, n do
			for col = -m, m do
				local neighCell

				if data.wrap then
					neighCell = cs:get(
						((cell.x + col) - cs.xMin) % (cs.xMax - cs.xMin + 1) + cs.xMin,
						((cell.y + lin) - cs.yMin) % (cs.yMax - cs.yMin + 1) + cs.yMin)
				else
					neighCell = cs:get(cell.x + col, cell.y + lin)
				end
	
				if neighCell then
					if data.filter(cell, neighCell) and not neighborhood:isNeighbor(neighCell) then
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
					local index
					if data.wrap then
						index = cs:get(
							((cell.x + col) - cs.xMin) % (cs.xMax - cs.xMin + 1) + cs.xMin,
							((cell.y + lin) - cs.yMin) % (cs.yMax - cs.yMin + 1) + cs.yMin)
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
		for _, index in ipairs(indexes) do
			if not neigh:isNeighbor(index) then
				neigh:add(index, weight)
			end
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

	defaultTableValue(self, "attrname", getFileName(self.file))
end

local function checkShape(self)
	local dbf = self.file:sub(1, self.file:len() - 3).."dbf"

	if not isFile(dbf) then
		customError("File '"..dbf.."' was not found.")
	end
end

local function checkVirtual(self)
	integerTableArgument(self, "xdim")
	positiveTableArgument(self, "xdim")

	defaultTableValue(self, "ydim", self.xdim)
	integerTableArgument(self, "ydim")
	positiveTableArgument(self, "ydim")
end

local function checkProject(self)
	defaultTableValue(self, "geometry", false)

	if type(self.layer) == "string" then
		if type(self.project) ~= "Project" then
			if type(self.project) == "string" then
				if not string.endswith(self.project, ".tview") then
					self.project = self.project..".tview"
				end

				if isFile(self.project) then
					local file = self.project
					self.project = terralib.Project{
						file = file
					}
				else
					customError("Project '"..self.project.."' was not found.")
				end
			else
				customError("Argument 'project' must be a Project or file path to a Project.")
			end
		end

		if not self.project.layers[self.layer] then
			customError("Layer '"..self.layer.."' does not exist in Project '"..self.project.file.."'.")
		end	

		self.layer = terralib.Layer{
			project = self.project,
			name = self.layer
		}
	else
		mandatoryTableArgument(self, "layer", "Layer")

		if self.project then
			customError("It is not possible to use Project when passing a Layer to CellularSpace.")
		end

		self.project = self.layer.project
	end
end

local function loadCsv(self)
	if self.yMin == nil then self.yMin = 100000 end
	if self.xMin == nil then self.xMin = 100000 end
	if self.xMax == nil then self.xMax = -self.xMin end
	if self.yMax == nil then self.yMax = -self.yMin end

	self.cells = {}
	self.cObj_:clear()
	local data = CSVread(self.file, self.sep)
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

local function loadMap(self)
	local i = 0
	local j = 0

	if self.yMin == nil then self.yMin = 100000 end
	if self.xMin == nil then self.xMin = 100000 end
	if self.xMax == nil then self.xMax = -self.xMin end
	if self.yMax == nil then self.yMax = -self.yMin end

	self.cells = {}
	self.cObj_:clear()
	for line in io.lines(self.file) do
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

	self.xdim = self.xMax
	self.ydim = self.yMax
end

local function setCellsByTerraLibDataSet(self, dSet)
	self.xMax = 0
	self.yMin = 0
	self.yMax = 0
	self.xMin = 0
	
	self.cells = {}
	self.cObj_:clear()

	for i = 0, #dSet do
		local row = 0
		local col = 0

		if dSet[i].row then
			row = tonumber(dSet[i].row)
			col = tonumber(dSet[i].col)
		elseif dSet[i].Lin then
			row = tonumber(dSet[i].Lin) -- SKIP
			col = tonumber(dSet[i].Col) -- SKIP
		elseif dSet[i].lin then
			row = tonumber(dSet[i].lin) -- SKIP
			col = tonumber(dSet[i].col) -- SKIP
		end

		self.xMin = math.min(self.xMin, col)
		self.xMax = math.max(self.xMax, row)
		self.yMin = math.min(self.yMin, row)
		self.yMax = math.max(self.yMax, col)		
	end

	for i = 0, #dSet do
		local row = tonumber(dSet[i].row)
		local col = tonumber(dSet[i].col)

		if not row then -- compatibility with shapes exported from TerraLLib 4
			if dSet[i].Lin then
				row = tonumber(dSet[i].Lin) -- SKIP
				col = tonumber(dSet[i].Col) -- SKIP
			elseif dSet[i].lin then
				row = tonumber(dSet[i].lin) -- SKIP
				col = tonumber(dSet[i].col) -- SKIP
			end
		else
			row = self.xMax - row + self.xMin
		end

		local cell = Cell{id = tostring(i), x = col, y = row}
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		
		for k, v in pairs(dSet[i]) do
			if (k == "OGR_GEOMETRY") or (k == "geom") then
				if self.geometry then
					cell.geom = v
				end
			else
				cell[k] = v
			end
		end
		
		if cell.object_id0 then
			cell:setId(cell.object_id0)
		elseif cell.object_id_ then
			cell:setId(cell.object_id_)
		end

		table.insert(self.cells, cell)
	end
end

local function loadShape(self)
	local tlib = terralib.TerraLib{}
	local dSet = tlib:getShpByFilePath(self.file)
	self.geometry = true
	setCellsByTerraLibDataSet(self, dSet)
	local temp = ""

	for i = self.file:len(), 1, -1 do
		if self.file:sub(i, i) ~= sessionInfo().separator then
			temp = self.file:sub(i, i)..temp
		else
			break
		end
	end

	self.layer = temp
	self.cObj_:setLayer(self.layer)
end

local function loadVirtual(self)
	self.yMin = 0
	self.xMin = 0
	self.xMax = self.xdim - 1
	self.yMax = self.ydim - 1

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

local function loadLayer(self)
	local tlib = terralib.TerraLib{}

	local dset = tlib:getDataSet(self.project, self.layer.name)
	setCellsByTerraLibDataSet(self, dset)
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
	mandatoryTableArgument(data, "source", "string")

	CellularSpaceDrivers[data.source] =  data
end

registerCellularSpaceDriver{
	source = "shp",
	load = loadShape,
	check = checkShape
}

registerCellularSpaceDriver{
	source = "virtual",
	extension = false,
	compulsory = "xdim",
	optional = "ydim",
	load = loadVirtual,
	check = checkVirtual
}

registerCellularSpaceDriver{
	source = "csv",
	optional = "sep",
	load = loadCsv,
	check = checkCsv
}

registerCellularSpaceDriver{
	source = "map",
	optional = {"sep", "attrname"},
	load = loadMap,
	check = checkMap
}

registerCellularSpaceDriver{
	source = "proj",
	extension = false,
	load = loadLayer,
	compulsory = "layer",
	optional = "project",
	check = checkProject
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
		self.yMin = math.min(self.yMin, cell.y)
		self.xMin = math.min(self.xMin, cell.x)
		self.xMax = math.max(self.xMax, cell.x)
		self.yMax = math.max(self.yMax, cell.y)
		self.index_id_ = nil
		self.index_xy_ = nil
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
	-- CellularSpaces if target is used. & & m, name, n, filter, weight, wrap, target, inmemory \
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
				verifyUnnecessaryArguments(data, {"filter", "weight", "wrap", "name", "strategy", "m", "n", "target", "inmemory"})

				defaultTableValue(data, "filter", function() return true end)
				defaultTableValue(data, "weight", function() return 1 end)
				defaultTableValue(data, "target", self)
				defaultTableValue(data, "wrap", false)

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

			local mfunc = data.func(mtarget, data2)

			if data.inmemory then
				forEachCell(mtarget, function(cell)
					cell:addNeighborhood(mfunc(cell), data2.name)
				end)
			else
				forEachCell(mtarget, function(cell)
					cell:addNeighborhood(mfunc, data2.name)
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

		defaultTableValue(data, "xmin", self.xMin)
		defaultTableValue(data, "xmax", self.xMax)
		defaultTableValue(data, "ymin", self.yMin)
		defaultTableValue(data, "ymax", self.yMax)

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

			if not self.index_id_ then
				local index_id = {}

				forEachCell(self, function(cell)
					index_id[cell:getId()] = cell
				end)

				self.index_id_ = index_id
			end

			return self.index_id_[xIndex]
		end

		mandatoryArgument(1, "number", xIndex)
		integerArgument(1, xIndex)

		mandatoryArgument(2, "number", yIndex)
		integerArgument(2, yIndex)

		if not self.index_xy_ then
			local index_xy = {}

			forEachCell(self, function(cell)
				if not index_xy[cell.x] then
					index_xy[cell.x] = {}
				end

				index_xy[cell.x][cell.y] = cell
			end)

			self.index_xy_ = index_xy
		end

		if self.index_xy_[xIndex] then
			return self.index_xy_[xIndex][yIndex]
		end
	end,
	--- Return a Cell from the CellularSpace given its x and y location.
	-- @deprecated CellularSpace:get
	getCell = function()
		deprecatedFunction("getCell", "get")
	end,
	--- Return a Cell from the CellularSpace given its id.
	-- @deprecated CellularSpace:get
	getCellByID = function()
		deprecatedFunction("getCellByID", "get")
	end,
	--- Return all the Cells of the CellularSpace as a vector.
	-- @deprecated CellularSpace.cells
	getCells = function()
		deprecatedFunction("getCells", ".cells")
	end,
	--- Load the CellularSpace from the database. TerraME automatically executes this function when
	-- the CellularSpace is created, but one can execute this to load the attributes again, erasing
	-- all attributes and relations created by the modeler.
	-- @usage cs = CellularSpace{xdim = 10}
	-- cs:load()
	load = function()
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
	-- @usage cs = CellularSpace{
	--     file = filePath("cabecadeboi900.shp", "base")	
	-- }
	--
	-- cs:loadNeighborhood{source = filePath("cabecadeboi-neigh.gpm", "base")}
	loadNeighborhood = function(self, data)
		verifyNamedTable(data)
		verifyUnnecessaryArguments(data, {"source", "name", "check"})

		if data.source:endswith(".gal") or data.source:endswith(".gwt") or data.source:endswith(".gpm") then
			if not isFile(data.source) then
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
        
		local file = openFile(data.source, "r")
		if file == nil then 
			resourceNotFoundError("source", file)
		end
        
		if data.source:endswith(".gal") then
			loadNeighborhoodGAL(self, data)
		elseif data.source:endswith(".gwt") then
			loadNeighborhoodGWT(self, data)
		elseif data.source:endswith(".gpm") then
			loadNeighborhoodGPM(self, data)
		else
			customError("Could not read the file. It is not the expected type.")
		end
        
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
	-- cs:notify(1)
	-- cs:notify(2)
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
				if type(self[idx]) ~= "function" then
					customError("Could not execute function '"..idx.."' from CellularSpace because it was replaced by a '"..type(self[idx]).."'.")
				end

				self[idx.."_"] = self[idx](self)
			end)
		end

		if self.cellobsattrs_ then
			forEachElement(self.cellobsattrs_, function(idx)
				forEachCell(self, function(cell)
					if type(cell[idx]) ~= "function" then
						customError("Could not execute function '"..idx.."' from Cell because it was replaced by a '"..type(cell[idx]).."'.")
					end

					cell[idx.."_"] = cell[idx](cell)
				end)
			end)
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
	-- @arg newLayerName Name of the TerraLib layer to store the saved attributes.
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
	-- cs:save("themeName", "height_")
	save = function(self, newLayerName, attrNames)
		mandatoryArgument(1, "string", newLayerName)
		
		if (attrNames ~= nil) and (attrNames ~= "") then
			if type(attrNames) == "string" then 
				attrNames = {attrNames} 
			elseif type(attrNames) ~= "table" then
				customError("Incompatible types. Argument '#2' expected table or string.")
			end
			
			for _, attr in pairs(attrNames) do
				if not self.cells[1][attr] then
					customError("Attribute '"..attr.."' does not exist in the CellularSpace.")
				end
			end
		end
		
		if self.project then
			local tlib = terralib.TerraLib{}
			
			if not self.geometry then
				local dset = tlib:getDataSet(self.project, self.layer.name)

				for i = 0, #dset do
					for k, v in pairs(dset[i]) do
						if (k == "OGR_GEOMETRY") or (k == "geom") then
							self.cells[i+1][k] = v
						end
					end		
				end
			else
				local dset = tlib:getDataSet(self.project, self.layer.name)
				local isOgr = false

				for k in pairs(dset[0]) do
					if k == "OGR_GEOMETRY" then
						isOgr = true
					end
				end	
				
				if isOgr then
					for i = 0, #dset do
						for k, v in pairs(dset[i]) do
							if k == "OGR_GEOMETRY" then
								self.cells[i+1]["geom"] = nil
								self.cells[i+1][k] = v
							end
						end		
					end
				end	
			end
			
			tlib:saveDataSet(self.project, self.layer.name, self.cells, newLayerName, attrNames)
		else
			customError("The CellularSpace must have a valid Project. Please, check the documentation.")
		end
	end,
	--- Return the number of Cells in the CellularSpace.
	-- @deprecated CellularSpace:#
	size = function()
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
	-- If the CellularSpace has an instance and it implements Cell:on_synchronize() then it
	-- will be called for each Cell.
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
		if values == nil then
			values = {}
			local cell = self.cells[1]
			for k in pairs(cell) do
				if not belong(k, {"past", "cObj_", "x", "y", "geom"}) then
					table.insert(values, k)
				end
			end
		end

		if type(values) == "string" then
			values = {values}
		elseif type(values) ~= "table" then 
			incompatibleTypeError(1, "string, table or nil", values)
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

		s = s.."} "
		s = s.."if type(cell.on_synchronize) == 'function' then cell:on_synchronize() end "
		s = s.."end"

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
-- @arg data.sep A string with the file separator. The default value is ",".
-- @arg data.layer A string with the name of the layer stored in a TerraLib project. 
-- @arg data.project A string with the name of the TerraLib project to be used. 
-- If this name does not ends with ".tview", this extension will be added to the name
-- of the file. It can also be an object of type Project from package terralib.
-- @arg data.attrname A string with an attribute name. It is useful for files that have 
-- only one attribute value for each cell but no attribute name.
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
-- @arg data.geometry A boolean value indicating whether the geometry should also be loaded.
-- The default value is false. If true, each cell will have an attribute called geom with a TerraLib object. 
-- @arg data.ydim Number of lines, in the case of creating a CellularSpace without needing to
-- load from a database. The default value is equal to xdim.
-- @arg data.file A string with a file name (if it is stored in the current directory), or the complete
-- path to a given file.
-- @arg data.source A string with the name of the data source. It tries to infer the data source
-- according to the arguments passed to the function.
-- @tabular source
-- source & Description & Compulsory arguments & Optional arguments\
-- "map" & Load from a text file where Cells are stored as numbers with its attribute value.
-- & & sep, attrname \
-- "csv" & Load from a Comma-separated value (.csv) file. Each column will become an attribute. It
-- requires at least two attributes: x and y. & file & source, sep, geometry, ...\
-- "proj" & Load from a layer within a TerraLib project. See the documentation of package terralib for
-- more information. & project, layer & source, geometry, ... \
-- "shp" & Load data from a shapefile. It requires three files with the same name and 
-- different extensions: .shp, .shx, and .dbf. The argument file must contain the
-- extension .shp. Each loaded Cell will have its (x, y) location according to the attributes
-- (row, col) or (Lin, Col) from the shapefile. The first pair keeps compatibility with TerraLib 5, 
-- while the last one is related to TerraLib 4. & file & source, geometry, ... \
-- "virtual" & Create a rectangular CellularSpace from scratch. Cells will be instantiated with
-- only two attributes, x and y, starting from (0, 0). & xdim & ydim, geometry, ...
-- @output cells A vector of Cells pointed by the CellularSpace.
-- @output cObj_ A pointer to a C++ representation of the CellularSpace. Never use this object.
-- @output parent The Environment it belongs.
-- @output xMax The maximum value of the attribute x of its Cells.
-- @output yMax The maximum value of the attribute y of its Cells.
-- @output xMin The minimum value of the attribute x of its Cells.
-- @output yMin The minimum value of the attribute y of its Cells.
-- @usage cs = CellularSpace{
--     xdim = 20,
--     ydim = 25
-- }
--
-- states = CellularSpace{
--     file = filePath("brazilstates.shp", "base")
-- }
function CellularSpace(data)
	verifyNamedTable(data)
	
	local candidates = {}

	forEachOrderedElement(CellularSpaceDrivers, function(idx, value)
		local all = true

		forEachElement(value.compulsory, function(_, mvalue)
			if data[mvalue] == nil then
				all = false
			end
		end)

		if value.extension and (not data.file or (type(data.file) == "string" and getExtension(data.file) ~= idx)) then
			all = false
		end

		if all then
			table.insert(candidates, idx)
		end
	end)

	if data.source == nil then
		if #candidates == 0 then
			customError("Not enough information to infer argument 'source'.")
		elseif #candidates == 1 then
			data.source = candidates[1]
		else
			local str = ""
			forEachElement(candidates, function(_, value)
				str = str.."'"..value.."', "
			end)

			str = string.sub(str, 1, -3).."."

			customError("More than one candidate to argument 'source': "..str)
		end
	else
		if #candidates == 1 then
			defaultTableValue(data, "source", candidates[1])
		else
			mandatoryTableArgument(data, "source", "string")
		end
	end

	if CellularSpaceDrivers[data.source] == nil then
		local word = "It must be a string from the set ["
		forEachOrderedElement(CellularSpaceDrivers, function(a)
			word = word.."'"..a.."', "
		end)
		word = string.sub(word, 0, string.len(word) - 2).."]."
		customError("'"..data.source.."' is an invalid value for argument 'source'. "..word)
	elseif CellularSpaceDrivers[data.source].extension then
		mandatoryTableArgument(data, "file", "string")

		if getExtension(data.file) ~= data.source then
			customError("source and file extension should be the same.")
		end

		if not isFile(data.file) then
			resourceNotFoundError("file", data.file)
		end
	end

	local cObj = TeCellularSpace()
	data.cObj_= cObj

	cObj:setDBType(data.source)

	if CellularSpaceDrivers[data.source].check then
		CellularSpaceDrivers[data.source].check(data)
	end

	data.load = CellularSpaceDrivers[data.source].load

	setmetatable(data, metaTableCellularSpace_)
	cObj:setReference(data)

	local function createSummaryFunctions(cell)
		forEachElement(cell, function(attribute, value, mtype)
			if attribute == "id" or attribute == "parent" or string.endswith(attribute, "_") then return
			elseif mtype == "function" then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(cs, args)
					return forEachCell(cs, function(mcell)
						if type(mcell[attribute]) ~= "function" then
							incompatibleTypeError(attribute, "function", mcell[attribute])
						end

						return mcell[attribute](mcell, args)
					end)
				end
			elseif mtype == "number" or (mtype == "Random" and value.distrib ~= "categorical" and (value.distrib ~= "discrete" or type(value[1]) == "number")) then
				if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				if attribute ~= "x" and attribute ~= "y" then
					data[attribute] = function(cs)
						local quantity = 0
						forEachCell(cs, function(mcell)
							if type(mcell[attribute]) ~= "number" then
								incompatibleTypeError(attribute, "number", mcell[attribute])
							end

							quantity = quantity + mcell[attribute]
						end)
						return quantity
					end
				end
			elseif mtype == "boolean" then
					if data[attribute] then
					customWarning("Attribute '"..attribute.."' will not be replaced by a summary function.")
					return
				end

				data[attribute] = function(cs)
					local quantity = 0
					forEachCell(cs, function(mcell)
						if mcell[attribute] then
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
					forEachCell(cs, function(mcell)
						local mvalue = mcell[attribute]
						if result[mvalue] then
							result[mvalue] = result[mvalue] + 1
						else
							result[mvalue] = 1
						end
					end)
					return result
				end
			end
		end)
	end

	data:load()

	if data.instance ~= nil then
		mandatoryTableArgument(data, "instance", "Cell")

		if data.instance.isinstance then
			customError("The same instance cannot be used in two CellularSpaces.")
		end

		forEachCell(data, function(cell)
			setmetatable(cell, {__index = data.instance})
			forEachElement(data.instance, function(attribute, value)
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
				if type(value) == "function" and idx ~= "on_synchronize" then
					strictWarning("Function '"..idx.."()' from Cell is replaced in the instance.")
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

