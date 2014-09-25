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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

local function coordCoupling(cs1, cs2, name)
	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood()
		local neighCell = cs2:get(cell.x, cell.y)
		if neighCell then
			neighborhood:add(neighCell, 1)
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood()
		local neighCell = cs1:get(cell.x, cell.y)
		if neighCell then 
			neighborhood:add(neighCell, 1)
		end
		cell:addNeighborhood(neighborhood, name)
	end)
end

local function createMooreNeighborhood(cs, name, self, wrap)
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				if self or (lin ~= col or col ~= 0) then
					local index = nil
					if wrap then
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

		cell:addNeighborhood(neigh, name)
	end
end

-- Creates a von Neumann neighborhood for each cell
local function createVonNeumannNeighborhood(cs, name, self, wrap)
	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood()
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do
				if ((lin == 0 or col == 0) and lin ~= col) or (self and lin == 0 and col == 0) then
					local index = nil
					if wrap then
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

		cell:addNeighborhood(neigh, name)
	end
end

-- Creates a neighborhood for each cell according to a modeler defined function
local function createNeighborhood(cs, filterF, weightF, name)
	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood()
		forEachCell(cs, function(neighCell)
			if filterF(cell, neighCell) then
				neighborhood:add(neighCell, weightF(cell, neighCell))
			end
		end)
		cell:addNeighborhood(neighborhood, name)
	end)
end

-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function createMxNNeighborhood(cs, m, n, filterF, weightF, name)
	m = math.floor(m/2)
	n = math.floor(n/2)

	local lin
	local col
	local i = 0

	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood()
		for lin = -n, n do
			for col = -m, m do
				local neighCell = cs:get(cell.x + col, cell.y + lin)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:add(neighCell, weightF(cell, neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
end

-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood bettween TWO different CellularSpace
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function spatialCoupling(m, n, cs1, cs2, filterF, weightF, name)
	m = math.floor(m / 2)
	n = math.floor(n / 2)

	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood()
		for lin = -n, n do
			for col = -m, m do
				local neighCell = cs2:get(cell.x + col, cell.y + lin)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:add(neighCell, weightF(cell, neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood()
		for lin = -n, n do
			for col = -m, m do
				local neighCell = cs1:get(cell.x + col, cell.y + lin)
				if neighCell then 
					if filterF(cell, neighCell) then
						neighborhood:add(neighCell, weightF(cell, neighCell))
					end
				end
			end
		end	
		cell:addNeighborhood(neighborhood, name)
	end)
end

CellularSpace_ = {
	type_ = "CellularSpace",
	--- Add a new Cell to the CellularSpace. It will be the last Cell of the CellularSpace.
	-- @param cell A Cell.
	-- @usage cs:add(cell)
	add = function(self, cell)
		if cell.parent ~= nil then 
			customWarningMsg("The cell already had a parent and it was replaced.", 3)
			-- TODO: I believe that a cell must belong to one, and only one, cs. Therefore the line above should be an error
		end
		cell.parent = self
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		table.insert(self.cells, cell)
		self.minRow = math.min(self.minRow, cell.y)
		self.minCol = math.min(self.minCol, cell.x)
		self.maxRow = math.max(self.maxRow, cell.y)
		self.maxCol = math.max(self.maxCol, cell.x)
	end,
	--- Create a Neighborhood for each Cell of the CellularSpace. It gets a table as argument, with 
	-- the following attributes:
	-- @param data A table
	-- @param data.strategy A string with the strategy to be used for creating the Neighborhood. 
	-- See the table below.
	-- @tab strategy
	-- Strategy & Description & Compulsory Parameters & Optional Parameters \
	-- "3x3" & A 3x3 (Couclelis) Neighborhood. & & name, filter, weight \
	-- "coord" & A bidirected relation between two CellularSpaces connecting Cells with the same 
	-- (x, y) coordinates. & target & name\
	-- "function" & A Neighborhood based on a function where any other Cell can be a neighbor. & 
	-- filter & name, weight \
	-- "moore"(default) & A Moore (queen) Neighborhood, connecting each Cell to its (at most) 
	-- eight touching Cells. & & name, self, wrap \
	-- "mxn" & A m (columns) by n (rows) Neighborhood within the CellularSpace or between two
	-- CellularSpaces if target is used. & m & name, n, filter, weight, target \
	-- "vonneumann" & A von Neumann (rook) Neighborhood, connecting each Cell to its (at most)
	-- four ortogonally surrounding Cells. & & name, self, wrap
	-- @param data.filter A function(Cell, Cell)->bool, where the first argument is the Cell itself
	-- and the other represent a possible neighbor. It returns true when the neighbor will be
	-- included in the relation. In the case of two CellularSpaces, this function is called twice
	-- for e ach pair of Cells, first filter(c1, c2) and then filter(c2, c1), where c1 belongs to
	-- cs1 and c2 belongs to cs2. The default is a function that returns true.
	-- @param data.m Number of columns. If m is even then it will be increased by one to keep the
	-- Cell in the center of the Neighborhood.
	-- @param data.n Number of rows. If n is even then it will be increased by one to keep the Cell
	-- in the center of the Neighborhood.
	-- @param data.name A string with the name of the Neighborhood to be created. 
	-- The default is "1".
	-- @param data.self Add the Cell as neighbor of itself? Default is false. Note that the 
	-- functions that do not require this argument always depend on a filter function, which will
	-- define whether the Cell can be neighbor of itself.
	-- @param data.target Another CellularSpace whose Cells will be used to create neighborhoods.
	-- @param data.weight A function(Cell, Cell)->number, where the first argument is the Cell
	-- itself and the other represent its neighbor. It calculates the weight of the relation. The
	-- weight will be computed only if filter returns true.
	-- @param data.wrap Whether Cells in the borders will be connected to the Cells in the
	-- opposite border. Default is false.
	-- @usage cs:createNeighborhood() -- moore
	--
	-- cs:createNeighborhood {
	--     name = "moore"
	-- }
	--
	-- cs:createNeighborhood {
	--     strategy = "vonneumann",
	--     self = true
	-- }
	--
	-- cs:createNeighborhood {
	--     strategy = "mxn",
	--     m = 4,
	--     n = 4
	-- }
	--
	-- -- c2 overlaps cs1
	-- cs1:createNeighborhood {
	--     strategy = "mxn",
	--     target = cs2, -- other cs
	--     m = 3,
	--     n = 2,
	--     name = "spatialCoupling"
	-- }
	createNeighborhood = function(self, data)
		if type(data) ~= "table" then
			if data == nil then 
				data = {} 
			else
	 			namedParametersErrorMsg("createNeighborhood", 3)
			end
		end

		if data.name == nil then
			data.name = "1"
		elseif type(data.name) ~= "string" then 
			incompatibleTypesErrorMsg("name", "string", type(data.name), 3)
		elseif data.name == "1" then
			defaultValueWarningMsg("name", "1", 3)
		end

		if self.cells[1] and #self.cells[1] > 0 then
			-- TODO: bug aqui porque se nao tiver a vizinhanca ele retorna erro no proprio get
			if self.cells[1]:getNeighborhood(data.name) ~= nil then
				local msg = "Neighborhood '"..data.name.."' already exists."
				customWarningMsg(msg, 5)
			end
		end

		if data.strategy == nil then
			data.strategy = "moore"
		elseif type(data.strategy) ~= "string" then
			incompatibleTypesErrorMsg("strategy","string",type(data.strategy), 3)
		end

		return switch(data, "strategy"):caseof{
			["function"]   = function() 
				checkUnnecessaryParameters(data, {"filter", "weight", "name", "strategy"}, 3)
				if data.filter == nil then
					mandatoryArgumentErrorMsg("filter", 3)
				elseif type(data.filter) ~="function" then
					incompatibleTypesErrorMsg("filter", "function", type(data.filter), 3)
				end

				if data.weight == nil then
					data.weight = function() return 1 end
				elseif type(data.weight) ~= "function" then
					incompatibleTypesErrorMsg("weight", "function", type(data.weight), 3)
				end

				return createNeighborhood(self, data.filter, data.weight, data.name) 
			end,
			moore = function()
				checkUnnecessaryParameters(data, {"self", "wrap", "name", "strategy"}, 3)
				if data.self == nil then
					data.self = false
				elseif type(data.self) ~= "boolean" then
					incompatibleTypesErrorMsg("self","boolean",type(data.self),3)
				end

				if data.wrap == nil then
					data.wrap = false
				elseif type(data.wrap) ~= "boolean" then
					incompatibleTypesErrorMsg("wrap","boolean",type(data.wrap),3)
				end

				return createMooreNeighborhood(self, data.name, data.self, data.wrap)
			end,
			mxn = function()
				checkUnnecessaryParameters(data, {"filter", "weight", "name", "strategy", "m", "n", "target"}, 3)
				if data.m == nil then
					mandatoryArgumentErrorMsg("m", 3)
				elseif type(data.m) ~= "number" then
					incompatibleTypesErrorMsg("m", "positive integer number (greater than zero)", type(data.m), 3)
				elseif data.m <= 0 then
					incompatibleValuesErrorMsg("m", "positive integer number (greater than zero)", data.m, 3)
				elseif math.floor(data.m) ~= data.m then
					incompatibleValuesErrorMsg("m", "positive integer number (greater than zero)", "real number", 3)
				elseif data.m % 2 == 0 then
					data.m = data.m + 1
					customWarningMsg("Parameter 'm' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.", 3)
				end

				if data.n == nil then
					data.n = data.m
				elseif type(data.n) ~= "number" then
					incompatibleTypesErrorMsg("n", "positive integer number (greater than zero)", type(data.n), 3)
				elseif data.n <= 0 then
					incompatibleValuesErrorMsg("n", "positive integer number (greater than zero)", data.n, 3)
				elseif math.floor(data.n) ~= data.n then
					incompatibleValuesErrorMsg("n", "positive integer number (greater than zero)", "real number", 3)
				elseif data.n % 2 == 0 then
					data.n = data.n + 1
					customWarningMsg("Parameter 'n' is even. It will be increased by one to keep the Cell in the center of the Neighborhood.", 3)
				end

				if data.filter == nil then
					data.filter = function() return true end
				elseif type(data.filter) ~="function" then
					incompatibleTypesErrorMsg("filter","function",type(data.filter),3)
				end

				if data.weight == nil then
					data.weight = function() return 1 end
				elseif type(data.weight) ~= "function" then
					incompatibleTypesErrorMsg("weight", "function", type(data.weight), 3)
				end

				if data.target == nil then
					return createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name)
				else
					if type(data.target) ~= "CellularSpace" then
						incompatibleTypesErrorMsg("target", "CellularSpace or nil", type(data.target), 3)
					end
					return spatialCoupling(data.m, data.n, self, data.target, data.filter, data.weight, data.name)
				end
			end,
			vonneumann = function() 
				checkUnnecessaryParameters(data, {"name", "strategy", "wrap", "self"}, 3)
				if data.self == nil then
					data.self = false
				elseif type(data.self) ~= "boolean" then
					incompatibleTypesErrorMsg("self", "boolean", type(data.self), 3)
				end

				if data.wrap == nil then
					data.wrap = false
				elseif type(data.wrap) ~= "boolean" then
					incompatibleTypesErrorMsg("wrap","boolean",type(data.wrap), 3)
				end

				return createVonNeumannNeighborhood(self, data.name, data.self, data.wrap) 
			end,
			["3x3"]        = function() 
				checkUnnecessaryParameters(data, {"name", "strategy", "filter", "weight"}, 3)
				data.m = 3
				data.n = 3

				if data.filter == nil then
					data.filter = function() return true end
				elseif type(data.filter) ~="function" then
					incompatibleTypesErrorMsg("filter", "function", type(data.filter), 3)
				end

				if data.weight == nil then
					data.weight = function() return 1 end
				elseif type(data.weight) ~= "function" then
					incompatibleTypesErrorMsg("weight","function", type(data.weight), 3)
				end

				return createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name) 
			end,
			coord = function() 
				checkUnnecessaryParameters(data, {"name", "strategy", "target"}, 3)
				if data.target == nil then
					mandatoryArgumentErrorMsg("target", 3)
				elseif type(data.target) ~= "CellularSpace" then
					incompatibleTypesErrorMsg("target", "CellularSpace", type(data.target), 3)
				end

				return coordCoupling(self, data.target, data.name) 
			end
		}
	end,
	getCell = function(self, xIndex, yIndex)
		deprecatedFunctionWarningMsg("getCell", "get", 2)
		return self:get(xIndex, yIndex)
	end,
	--- Retrieve a Cell from the CellularSpace, given its id or its x and y.
	-- @param xIndex A number indicating x coord. It can also be a string with the object id.
	-- @param yIndex A number indicating y coord. This argument is unnecessary when the first 
	-- argument is a string.
	-- @usage cs:get(2, 2)
	-- cs:get("5")
	get = function(self, xIndex, yIndex)
		if type(xIndex) == "string" then
			if yIndex ~= nil then
				customWarningMsg("As #1 is string, #2 should be nil, got a "..type(yIndex)..".")
			end

			return self.cObj_:getCellByID(xIndex)
		elseif type(xIndex) ~= "number" or math.floor(xIndex) ~= xIndex then
			if xIndex == nil then
				mandatoryArgumentErrorMsg("#1", 3)
			else
				incompatibleTypesErrorMsg("#1", "positive integer number", type(xIndex), 3)
			end
		elseif type(yIndex) ~= "number" or math.floor(yIndex) ~= yIndex then
			if yIndex == nil then
				mandatoryArgumentErrorMsg("#2", 3)
			else
				incompatibleTypesErrorMsg("#2", "positive integer number", type(yIndex), 3)
			end
		end

		local index = Coord {x = xIndex, y = yIndex}
		return self.cObj_:getCell(index.cObj_)
	end,
	getCells = function(self)
		deprecatedFunctionWarningMsg("getCells", ".cells", 2)
		return self.cells
	end,
	getCellByID = function(self, cellID)
		deprecatedFunctionWarningMsg("getCellByID", "get", 2)
		return self:get(cellID)
	end,	
	--- Load the CellularSpace from the database. TerraME automatically executes this function when
	-- the CellularSpace is created, but one can execute this to load the attributes again, erasing
	-- each other attribute and relations created by the modeler. This function can not be used
	-- with volatile CellularSpace.
	-- @usage cs:load()
	load = function(self)
		if self.database:endswith("shp") then
			return self:loadShape()
		elseif self.database:endswith(".csv") then
			self.cells = {}
			self.cObj_:clear()
			local data = readCSV(self.database, self.sep)
			local cellIdCounter = 0
			for i = 1, #data do
				cellIdCounter = cellIdCounter + 1
				data[i].id = tostring(cellIdCounter)
				local cell = Cell(data[i])
				self:add(cell)
			end
			return 
		end

		self.legend = {} 
		local x = 0
		local y = 0
		local legendStr = ""

		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow, legendStr = self.cObj_:load()

		-- tratamento de erros de conexao com banco de dados
		-- as variaveis self.cells e self.minCol foram reutilizadas com semanticas não adequadas neste ponto
		-- vide luaCellularSpace.cpp (método load)
		if self.cells == -1 then
			customErrorMsg(self.minCol, 3)
		end

		-- TODO: load legend was removed - investigate whether this is really necessary.
		--self.legend = load(legendStr)()


		if self.cells == nil then
			customErrorMsg("It was not possible to load the CellularSpace", 4)
		end

		-- A ordenacao eh necessaria pq o TerraView ordena os 
		-- objectIDs como strings:..., C00L10, C00L100, C00L11...
		-- TODO: porque tem o table.sort aqui, se um cellularspace pode ser percorrido de qualquer forma?
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
	end,
	--#- Load the CellularSpace from a shapefile. This is an internal function and should not be documented.
	loadShape = function(self)
		self.legend = {} 
		local x = 0
		local y = 0
		local legendStr = ""
		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow = self.cObj_:loadShape()

		self.legend = load(legendStr)()
		-- A ordenacao eh necessaria pq o TerraView ordena os 
		-- objectIDs como strings:..., C00L10, C00L100, C00L11...
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
	end,
	--- Load a Neighborhood stored in an external source. Each Cell receives its own set of 
	-- neighbors.
	-- @param data.name A string with the location of the Neighborhood 
	-- to be loaded. See below.
	-- @param tbAttrLoad.source A string with the name of the Neighborhood
	-- to be loaded within TerraME. Default is "1".
	-- @tab name
	-- Source & Description \
	--"*.gal" & Load a Neighborhood from contiguity relationships described as a GAL file.\
	-- "*.gwt" & Load a Neighborhood from a GWT (generalized weights) file.\
	-- "*.gpm" & Load a Neighborhood from a GPM (generalized proximity matrix) file. \
	-- Any other & Load a Neighborhood from table stored in the same database of the 
	-- CellularSpace. \
	-- @usage cs:loadNeighborhood{
	--     source = "n.gpm"
	-- }
	-- 
	-- cs:loadNeighborhood{
	--     source = "mtab",
	--     name = "mtab"
	-- }
	loadNeighborhood = function(self, data)
		if type(data) ~= "table" then
			if data == nil then 
				tableParameterErrorMsg("loadNeighborhood", 3)
			else
	 			namedParametersErrorMsg("loadNeighborhood", 3)
			end
		end

		if data.source == nil then
			mandatoryArgumentErrorMsg("source", 3)
		elseif type(data.source) ~= "string" then 
			incompatibleTypesErrorMsg("source", "string",type(data.source), 3)
		end

		if data.source:endswith(".gal") or data.source:endswith(".gwt") or data.source:endswith(".gpm") then
			if not io.open(data.source, 'r')then
				resourceNotFoundErrorMsg("source", data.source, 3)
			end
		end

		if data.name == nil then
			data.name = "1"
		elseif type(data.name) ~= "string" then 
			incompatibleTypesErrorMsg("name", "string", type(data.name), 3)
		end

		self.cObj_:loadNeighborhood(data.source, data.name)
	end,
	--- Notify every Observer connected to the CellularSpace.
	-- @param modelTime The time to be used by the Observer. Most of the strategies available 
	-- ignore this value. 
	-- @usage cs:notify()
	-- cs:notify(event:getTime())
	notify = function (self, modelTime)
		if type(self.attrfunc_) == "table" then
			forEachCell(self, function(cell)
				cell[self.attrfunc_[1].."_"] = cell[self.attrfunc_[1]](cell)
			end)
		end
		if modelTime == nil then
			modelTime = 1
		elseif type(modelTime) ~= "number" then
			if(type(modelTime == "Event")) then
				modelTime = modelTime:getTime()
			else
				incompatibleTypesErrorMsg("#1", "Event or positive number", type(modelTime), 3) 
			end
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1","positive number", modelTime, 3)   
		end
		self.cObj_:notify(modelTime)
	end,
	--- Retrieve a random Cell from the CellularSpace.
	-- @param randomObj a Random object (optional).
	-- @usage cell = cs:sample()
	sample = function(self, randomObj)
		if type(randomObj) == "Random" then
			return self.cells[randomObj:integer(1, #self)]                          
		else
			return self.cells[TME_GLOBAL_RANDOM:integer(1, #self)]            
		end         
	end,
	--- Save the attributes of a CellularSpace into the same database it was retrieved.
	-- @param time A temporal value to be stored in the database, which can be different from
	-- the simulation time.
	-- @param outputTableName Name of the table to store the attributes of the Cells.
	-- @param attrNames A vector with the names of the attributes to be saved (default is all
	-- of them). When saving a single attribute, you can use attrNames = "attribute" instead
	-- of attrNames = {"attribute"}.
	-- @usage cs:save(20,"table")
	--
	-- cs:save(100, "ntab", "attr")
	save = function(self, time, outputTableName, attrNames)
		if type(time) ~= "number" then
			if time == nil then
				mandatoryArgumentErrorMsg("#1", 3)
			else
				incompatibleTypesErrorMsg("#1", "positive integer number", type(time), 3)
			end
		elseif time < 0 then
			incompatibleValuesErrorMsg("#1", "positive integer number", time, 3)	  
		elseif math.floor(time) ~= time then
			incompatibleValuesErrorMsg("#1", "positive integer number", time, 3)
		end

		if type(outputTableName) ~= "string" then 
			if outputTableName == nil then
				mandatoryArgumentErrorMsg("#2", 3)
			else
				incompatibleTypesErrorMsg("#2", "string", type(outputTableName), 3)
			end
		end

		if type(attrNames) ~= "string" and type(attrNames) ~= "table" then
			if attrNames == nil then
				mandatoryArgumentErrorMsg("#3", 3)
			else
  				incompatibleTypesErrorMsg("#3", "string", type(attrNames), 3)
			end
		end   

		if type(attrNames) == "string" then attrNames = {attrNames} end
		for _, attr in pairs(attrNames) do
			if not self.cells[1][attr] then
				customErrorMsg("Attribute '"..attr.."' does not exist in the CellularSpace.", 3)
			end
		end
		local erros = self.cObj_:save(time, outputTableName, attrNames, self.cells)
	end,
	--#- Save the attributes of a shapefile into the same file it was retrieved.
	-- @usage cs:saveShape()
	saveShape = function(self)
		local shapefileName = self.cObj_:getDBName()
		if shapefileName == "" then
			customErrorMsg("Shapefile must be loaded before being saved.", 3)
		end
		local shapeExists = io.open(shapefileName,"r") and io.open(shapefileName:sub(1,#shapefileName-3).."dbf")
		if shapeExists == nil then
			customErrorMsg("Shapefile not found.", 3)
		else
			io.close(shapeExists)
		end
		local contCells = 0
		forEachCell(self, function(cell)
			for k,v in pairs(cell) do
				local type_
				if type(v) == "number" then
					type_ = 1
				elseif type(v) == "string" then
					type_ = 2
				else
					type_ = 0
				end
				self.cObj_:saveShape(cell.objectId_,k,v,type_)
			end
			contCells = contCells + 1
		end)
		print("\tnumber of saved cells: "..contCells..".")
		io.flush()
	end,
	-- Retrieve the number of Cells of the CellularSpace.
	-- @usage print(#cs)
	size = function(self)
		deprecatedFunctionWarningMsg("size()", "operator #", 3)
		return #self
	end,
	--- Split the CellularSpace into a table of Trajectories according to a classification 
	-- strategy. The generated Trajectories have empty intersection and union equals to the
	-- whole CellularSpace (unless function below returns nil for some Cell). 
	-- @param argument A string or a function, as follows:
	-- @tab argument
	-- Type of argument & Description \
	-- string & The argument must represent the name of one attribute of the Cells of the
	-- CellularSpace. Split then creates one Trajectory for each possible value of the attribute
	-- using the value as index and fills them with the Cells that have the respective attribute
	-- value. \
	-- function & The argument is a function that receives a Cell as argument and returns a value
	-- with the index that contains the Cell. Trajectories are then indexed according to the
	-- returning value. Every time this function returns nil for a given Cell, such Cell will not
	-- be included in any Trajectory.
	-- @usage ts = cs:split("cover")
	-- print(#ts.forest)
	-- print(#ts.pasture)
	-- 
	-- ts2 = cs:split(function(cell)
	--     if cell.forest > 0.5 then 
	--         return "gt" 
	--     else 
	--         return "lt" 
	--     end
	-- end)
	-- print(#ts.gt)
	split = function(self, argument)
		if type(argument) ~= "function" and type(argument) ~= "string" then
			if argument == nil then
				mandatoryArgumentErrorMsg("#1", 3)
			else
				incompatibleTypesErrorMsg("#1", "string or function", type(argument), 3)
			end
		end

		if type(argument) == "string" then
			local value = argument
			argument = function(cell)
				return cell[value]
			end
		end

		local result = {}
		local class
		local i = 1
		forEachCell(self, function(cell)
			class = argument(cell)
			if class == nil then return end
			-- TODO: se retirar esta linha acima aparece um erro estranho nos testes que nao deveria acontecer

			if result[class] == nil then
				result[class] = Trajectory{target = self, build = false}
			end
			table.insert(result[class].cells, cell)
			result[class].cObj_:add(i, cell.cObj_)
			i = i + 1
		end)
		return result
	end,
	--- Synchronize the CellularSpace, calling the function synchronize() for each of its Cells.
	-- @param values A string or a vector of strings with the attributes to be synchronized. If 
	-- empty, TerraME synchronizes every attribute read from the database but the (x, y) 
	-- coordinates and the attributes created along the simulation.
	-- @usage cs:synchronize()
	-- cs:synchronize("landuse")
	-- cs:synchronize{"water","use"}
	synchronize = function(self, values)
		if #self <= 0 then
			customErrorMsg("CellularSpace needs to be loaded first.", 3)
		end
		if type(values) == "string" then values = {values} end
		if type(values) ~= "table" then 
			if values == nil then
				values = {}
				local count = 1
				local cell = self.cells[1]
				for k, v in pairs(cell) do
					if k ~= "past" and k ~= "cObj_" and k ~= "x" and k ~= "y" then
						values[count] = k
						count = count + 1
					end
				end
			else
				incompatibleTypesErrorMsg("#1", "string, table or nil", type(values), 3)
			end
		end
		local s = "return function(cell)\n"
		s = s.."cell.past = {"

		for _, v in pairs(values) do
			if type(v) == "string" then
				s = s..v.." = cell."..v..", "
			else
				customErrorMsg("Parameter 'values' should contain only strings.", 3)
			end
		end

		s = s.."} end"

		forEachCell(self, load(s)())
	end
}

metaTableCellularSpace_ = {
	__index = CellularSpace_,
	--- Retrieve the number of Cells of the CellularSpace.
	-- @name #
	-- @usage print(#cs)
	__len = function(self)
		return #self.cells
	end,
	__tostring = tostringTerraME
}

--- A multivalued set of Cells. It can be retrieved from databases, files, or created
-- directly within TerraME. 
-- See the table below with the description and the arguments of each data source.
-- Every Cell of a CellularSpace has an (x, y) location, starting from (0, 0). This Cell
-- represents the upper right location.  Note that CellularSpaces loaded from
-- databases might not have this cell, according to the original geometry that was used to
-- create the CellularSpace. Calling Utils:forEachCell() traverses CellularSpaces.
--
-- @param data A table.
-- @param data.database Name of the database. It can also describe the location of a
-- shapefile. In thiscase, the other arguments will be ignored.
-- @param data.theme Name of the theme to be loaded.
-- @param data.dbType Name of the data source. It tries to infer the data source according
-- to the extension of the parameter database. When it does not have an extension or when the
-- extension is not recognized it will read data from a MySQL database. The default value depends
-- on the database name. If it has a ".mdb" extension, the default value is "ado". If it has a
-- "shp" extension it will load a shapefile. Otherwise it is "mysql"). TerraME always converts
-- this string to lower case.
-- @param data.host Host where the database is stored (default is "localhost").
-- @param data.port Port number of the connection.
-- @param data.user Username (default is "").
-- @param data.sep A string with the file separator for reading a CSV (default is ",").
-- @param data.password The password (default is "").
-- @param data.layer A boolean value indicating whether the CellularSpace will be loaded
-- automatically (true, default value) or the user by herself will call load (false).
-- @param data.autoload A boolean value indicating whether the CellularSpace will be loaded
-- automatically (true, default value) or the user by herself will call load (false).
-- @param data.select A table containing the names of the attributes to be retrieved (default is
-- all attributes). When retrieving a single attribute, you can use select = "attribute" instead
-- of select = {"attribute"}. It is possible to rename the attribute name using "as", for example,
-- select= {"lc as landcover"} reads lc from the database but replaces the name to landcover in
-- the Cells. Attributes that contain "." in their names (such as results of table joins) will be
-- read with "_" replacing "." in order to follow Lua syntax to manipulate data.
-- @param data.where An SQL restriction on the properties of the Cells (default is "", applying no
-- restriction. Only the Cells that reflect the established criteria will be loaded). For example,
-- the operator to compare value is "=" and not "==". This parameter can only be used when reading
-- data from a database.
-- @param data.instance A Cell with the description of attributes and functions. 
-- When using this parameter, each Cell will have attributes and functions according to the
-- instance. The CellularSpace calls Cell:init() from the instance for each of its Cells.
-- Additional functions are also created to the CellularSpace, according to the attributes of the
-- instance. For each attribute of the instance, one function is created in the CellularSpace with
-- the same name (note that attributes declared exclusively in Cell:init() will not be mapped, as
-- they do not belong to the instance). The table below describes how each attribute is mapped:
-- @tab instance
-- Attribute of instance & Function within the CellularSpace \
-- function & Call the function of each of its Cells. \
-- number & Return the sum of the number in each of its Cells. \
-- boolean & Return the sum of true values in each of its Cells. \
-- string & Return a table with positions equal to the unique strings and values equal to the
-- number of occurrences in each of its Cells.
-- @param data.xdim Number of columns, in the case of creating a CellularSpace without needing to
-- load from a database.
-- @param data.ydim Number of lines, in the case of creating a CellularSpace without needing to
-- load from a database. Default is equal to xdim.
--
-- @tab data
-- Data source & Description & Compulsory parameters & Optional parameters\
-- Access & Load from a Microsoft Access database (.mdb)  file. & database, theme & layer, select,
-- where \
-- CSV & Load from a Comma-separated value (.csv) file. Each column will become an attribute. It
-- requires at least two attributes: x and y. & database & sep\
-- MySQL & Load from a TerraLib database stored in a MySQL database. & database, theme & host, 
-- layer, password, port, select, user, where \
-- Shapefile & Load data from a shapefile. It requires three files with the same name and 
-- different extensions: .shp, .shx, and .dbf. The argument database must contain the file with
-- extension .shp.& database & \
-- Volatile & Create a rectangular cellular space from scratch. Cells will be instantiated with
-- only two attributes: x and y. & xdim & ydim 
-- @output cells A vector of Cells pointed by the CellularSpace.
-- @output parent The Environment it belongs.
--
-- @usage cs = CellularSpace {
--     database = "amazonia",
--     theme = "cells",
--     user = "root"
-- }
-- 
-- cs2 = CellularSpace {
--     database = "d:\\db.mdb",
--     layer = "cells_10",
--     theme = "cells_10",
--     select = "height3 as h",
--     where = "height3 > 2"
-- }
-- 
-- cs3 = CellularSpace {
--     database = "d:\\file.shp",
-- }
-- 
-- cs4 = CellularSpace {
--     xdim = 20,
--     ydim = 20
-- }
function CellularSpace(data)
	if type(data) ~= "table" then
		if data == nil then
			tableParameterErrorMsg("CellularSpace", 3)
		else
 			namedParametersErrorMsg("CellularSpace", 3)
 		end
	elseif getn(data) == 0 then
		customErrorMsg("CellularSpace needs more information to be created.", 3)
	end

	local cObj = TeCellularSpace()

	if data.database ~= nil and type(data.autoload) ~= "boolean" then
		if data.autoload == nil then
			data.autoload = true
		else
			incompatibleTypesErrorMsg("autoload", "boolean", type(data.autoload), 3)
		end
	end    

	data.cells = {}
	data.cObj_= cObj
	if data.minRow == nil then data.minRow = 100000 end
	if data.minCol == nil then data.minCol = 100000 end
	if data.maxRow == nil then data.maxRow = -data.minRow end
	if data.maxCol == nil then data.maxCol = -data.minCol end

	if data.xdim or data.ydim then -- rectangular "virtual" cellular space
		if type(data.xdim) ~= "number" then
			if data.xdim == nil then
				data.xdim = 0
			else
				incompatibleTypesErrorMsg("xdim", "positive integer number", type(data.xdim), 3)
			end
		elseif data.xdim <= 0 or math.floor(data.xdim) ~= data.xdim then
			incompatibleValuesErrorMsg("xdim", "positive integer number", data.xdim, 3)
		end

		if type(data.ydim) ~= "number" then
			if data.ydim == nil then
				data.ydim = data.xdim
			else
				incompatibleTypesErrorMsg("ydim", "positive integer number", type(data.ydim), 3)
			end
		elseif data.ydim <= 0 or math.floor(data.ydim) ~= data.ydim then
			incompatibleValuesErrorMsg("ydim", "positive integer number", data.ydim, 3)
		end

		data.minRow = 0
		data.minCol = 0
		data.maxRow = data.ydim - 1
		data.maxCol = data.xdim - 1

		data.load = function(self)
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
			data.load = function(self)
				customErrorMsg("Cannot load volatile cellular spaces.", 3)
			end
		end
	else
		if type(data.database) ~= "string" then
			if data.database == nil then
				mandatoryArgumentErrorMsg("database", 3)
			else
				incompatibleTypesErrorMsg("database", "string", type(data.database), 3)
			end
		elseif data.database:endswith(".shp") or data.database:endswith(".mdb") or data.database:endswith(".csv") then
			local f = io.open(data.database, "r")
			if not f then
				customErrorMsg("File '".. data.database .."' not found.", 3)
			end
		end		
		
		if data.dbType == nil then
			if data.database:endswith(".shp") or data.database:endswith(".mdb") or data.database:endswith(".csv") then
				if not io.open(data.database, 'r') then
					resourceNotFoundErrorMsg("database", data.database, 3)
				else
					if data.database:endswith(".shp") then
						data.dbType = "shp"
					elseif data.database:endswith(".mdb") then
						data.dbType = "ado"
					elseif data.database:endswith(".csv") then
						data.dbType = "csv"					
					end
					cObj:setDBType(string.lower(data.dbType))
					cObj:setDBName(data.database)
				end
			else
				data.dbType = "mysql"
			end
		elseif type(data.dbType) ~= "string" then
			incompatibleTypesErrorMsg("dbType", "string",type(data.dbType), 3)
		elseif data.dbType ~= "mysql" and data.dbType ~= "ado" and data.dbType ~= "shp" then
			incompatibleValuesErrorMsg("dbType", "one of the strings from the set ['mysql','ado','shp']", data.dbType, 3)          
		end
	
		cObj:setDBType(string.lower(data.dbType))	
		cObj:setDBName(data.database)		

		if data.dbType == "mysql" then                    
			cObj:setDBName(data.database)
		elseif not data.database:endswith(".shp") and not data.database:endswith(".mdb") and not data.database:endswith(".csv") then
			local ext
			local pos = 0
			for i = 1, data.database:len() do
				if data.database:sub(i,i) == "." then
					pos = i
					break
				end
			end
			ext = data.database:sub(pos,data.database:len())
			incompatibleFileExtensionErrorMsg("database",ext, 3)
		end
		
		if data.database:endswith(".shp") then
			local dbname = data.database
			local shapeExists = io.open(dbname, "r") and io.open(dbname:sub(1, dbname:len() - 3).."dbf")
			if not shapeExists then
				customErrorMsg("Shapefile not found.", 3)
			else
				io.close(shapeExists)
			end
		elseif data.database:endswith(".csv") then
			if data.sep and type(data.sep) ~= "string" then
				incompatibleTypesErrorMsg("sep", "string", type(data.sep), 3)
			end
		else
			if data.dbType == "mysql" then
				-- until 1024 also 65535
				if type(data.port) ~= "number" then
					if data.port == nil then
						data.port = 3306
					else
						incompatibleTypesErrorMsg("port", "positive integer number", type(data.port), 3)
					end
				elseif data.port ~= math.floor(data.port) or data.port < 0 then
					incompatibleValuesErrorMsg("port", "positive integer number", data.port, 3)
				elseif data.port < 1024 then
					customErrorMsg("Parameter 'port' should have values above 1023 to avoid using system reserved values.\nApplication reserved port values should be avoided as well (ex.: MySQL 3306).", 3)
				end
				cObj:setPort(data.port)	 

				if type(data.host) ~= "string" then
					if data.host == nil then
						data.host = "localhost"
					else
						incompatibleTypesErrorMsg("host", "string", type(data.host), 3)
					end
				end
				cObj:setHostName(data.host)

				if type(data.user) ~= "string" then
					if data.user == nil then
						data.user = "root"
					else
						incompatibleTypesErrorMsg("user", "string", type(data.user), 3)
					end
				end
				cObj:setUser(data.user)

				if data.password == nil then
					mandatoryArgumentErrorMsg("password", 3)
				elseif type(data.password) ~= "string" then
					incompatibleTypesErrorMsg("password", "string", type(data.password), 3)
				end
				cObj:setPassword(data.password)
			end

			if data.theme == nil then
				mandatoryArgumentErrorMsg("theme", 3)
			elseif type(data.theme) ~= "string" then 
				incompatibleTypesErrorMsg("theme", "string", type(data.theme), 3)
			end
			cObj:setTheme(data.theme) 

			if type(data.layer) ~= "string" then
				if data.layer == nil then
					data.layer = ""
				else
					incompatibleTypesErrorMsg("layer", "string", type(data.layer), 3)
				end
			end
			cObj:setLayer(data.layer)

			if type(data.where) == "string" then 
				cObj:setWhereClause(data.where)
			elseif data.where ~= nil then
				incompatibleTypesErrorMsg("where", "string or nil", type(data.where), 3)
			end

			if type(data.select) ~= "string" and type(data.select) ~= "table" then
				if data.select ~= nil then
					incompatibleTypesErrorMsg("select", "string, table with strings or nil", type(data.select), 3)
				end
			else
				if type(data.select) == "string" then
					data.select = {data.select}
				end
				cObj:clearAttrName()
				for i in ipairs(data.select) do
					cObj:addAttrName(data.select[i])
				end
			end

		end
	end
	setmetatable(data, metaTableCellularSpace_)
	cObj:setReference(data)

	-- load and autoload parameter verification	
	if data.xdim then
		data:load()
	elseif data.database ~= nil and data.autoload then
			data:load()
			-- needed for Environment's loadNeighborhood	
			data.layer = data.cObj_:getLayerName()
	end

	if data.instance ~= nil then
		if type(data.instance) ~= "Cell" then
			incompatibleTypesErrorMsg("instance", "Cell", type(data.instance), 3)
		end

		forEachCell(data, function(cell)
			setmetatable(cell, {__index = data.instance})
			-- TODO: Verificar a real necessidade
			forEachElement(data.instance, function(attribute, value, mtype)
				if attribute ~= "objectId_" and attribute ~= "x" and attribute ~= "id" and attribute ~= "y" and attribute ~= "past" and attribute ~= "cObj_" and attribute ~= "agents_" then 
					cell[attribute] = value
				end
			end)
			cell:init()
		end)

		forEachElement(data.instance, function(attribute, value, mtype)
			-- TODO: Verificar a real necessidade de or attribute == "objectId_"
			if attribute == "id" or attribute == "parent" or attribute == "objectId_" then return
			elseif mtype == "function" then
				data[attribute] = function(cs, args)
					forEachCell(cs, function(cell)
						cell[attribute](cell, args)
					end)
				end
			elseif mtype == "number" then
				if attribute ~= "x" and attribute ~= "y" then -- TODO remove this line as soon as #981 is solved
				data[attribute] = function(cs)
					local quantity = 0
					forEachCell(cs, function(cell)
						quantity = quantity + cell[attribute]
					end)
					return quantity
				end
				end
			elseif mtype == "boolean" then
				data[attribute] = function(cs)
					local quantity = 0
					forEachCell(cs, function(cell)
						if cell[attribute] then
							quantity = quantity + 1
						end
					end)
					return quantity
				end
			elseif mtype == "string" then
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
	return data
end

