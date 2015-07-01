globalSaveValue = 0
--[[
local function coordCoupling(cs1, cs2, name)
	_coordbyNeighborhood_ = true

	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood{id = name}
		local coord = Coord{x = cell.x, y = cell.y}
		local neighCell = cs2:getCell(coord)
		if neighCell then
			neighborhood:addCell(coord, cs2, 1)
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood{id = name}
		local coord = Coord{x = cell.x, y = cell.y}
		local neighCell = cs1:getCell(coord)
		if neighCell then 
			neighborhood:addCell(coord, cs1, 1)
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	_coordbyNeighborhood_ = false
end

local function createMooreNeighborhood(cs, name, self, wrap)
	_coordbyNeighborhood_ = true

	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood{id = name}
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do 
				if self or (lin ~= col or col ~= 0) then
					local index = nil
					if(wrap) then
						index = Coord{
							x = (((cell.x + col) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol),
							y = (((cell.y + lin) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)}
					else
						index = Coord{x = (cell.x + col), y = (cell.y + lin)}
					end
					if(neigh:addCell(index, cs, 0) ~= nil)then table.insert(indexes, index) end
				end

				col = col + 1
			end
			lin = lin + 1
		end

		local weight = 1/neigh:size()
		for i, index in ipairs(indexes) do
			neigh:setCellWeight(index, weight)
		end

		cell:addNeighborhood(neigh, name)
	end
	_coordbyNeighborhood_ = false
	return true
end

-- Creates a von Neumann neighborhood for each cell
local function createVonNeumannNeighborhood(cs, name, self, wrap)
	_coordbyNeighborhood_ = true

	for i, cell in ipairs(cs.cells) do
		local neigh = Neighborhood{id = name}
		local indexes = {}
		local lin = -1
		while lin <= 1 do
			local col = -1
			while col <= 1 do
				if ((lin == 0 or col == 0) and lin ~= col) or (self and lin == 0 and col == 0) then
					local index = nil
					if(wrap)then
						index = Coord{
							x = (((cell.x + col) - cs.minCol) % (cs.maxCol - cs.minCol + 1) + cs.minCol),
							y = (((cell.y + lin) - cs.minRow) % (cs.maxRow - cs.minRow + 1) + cs.minRow)}
					else
						index = Coord{x = (cell.x + col), y = (cell.y + lin)}
					end
					if(neigh:addCell(index, cs, 0) ~= nil)then table.insert(indexes, index) end
				end

				col = col + 1
			end
			lin = lin + 1
		end

		local weight = 1/neigh:size()
		for i, index in ipairs(indexes) do
			neigh:setCellWeight(index, weight)
		end

		cell:addNeighborhood(neigh, name)
	end
	_coordbyNeighborhood_ = false
end

-- Creates a neighborhood for each cell according to a modeler defined function
local function createNeighborhood(cs, filterF, weightF, name)
	_coordbyNeighborhood_ = true

	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood{id = name}
		forEachCell(cs, function(neighCell)
			if filterF(cell, neighCell) then
				neighborhood:addNeighbor(neighCell, weightF(cell, neighCell))
			end
		end)
		cell:addNeighborhood(neighborhood, name)
	end)
	_coordbyNeighborhood_ = false
end

-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function createMxNNeighborhood(cs, m, n, filterF, weightF, name)
	_coordbyNeighborhood_ = true

	m = math.floor(m/2)
	n = math.floor(n/2)

	local lin
	local col
	local i = 0

	forEachCell(cs, function(cell)
		local neighborhood = Neighborhood{id = name}
		for lin = -n, n, 1 do
			for col = -m, m, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)} 
				local neighCell = cs:getCell(coord)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs, weightF(cell,neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	_coordbyNeighborhood_ = false
	return true
end


-- Creates a M (collumns) x N (rows) stationary (couclelis) neighborhood bettween TWO different CellularSpace
-- filterF(cell,neigh):bool --> true, if the neighborhood relationship will be 
--                              included, otherwise false
-- weightF(cell,neigh):real --> calculates the neighborhood relationship weight
local function spatialCoupling(m, n, cs1, cs2, filterF, weightF, name)
	_coordbyNeighborhood_ = true

	m = math.floor(m/2)
	n = math.floor(n/2)

	local lin
	local col
	local i = 0
	forEachCell(cs1, function(cell)
		local neighborhood = Neighborhood{id = name}
		for lin = -n, n, 1 do
			for col = -m, m, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs2:getCell(coord)
				if neighCell then
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs2, weightF(cell,neighCell))
					end
				end
			end
		end
		cell:addNeighborhood(neighborhood, name)
	end)
	forEachCell(cs2, function(cell)
		local neighborhood = Neighborhood{id = name}
		for lin = -n, n, 1 do
			for col = -m, m, 1 do
				local coord = Coord{x = (cell.x + col), y = (cell.y + lin)}
				local neighCell = cs1:getCell(coord)
				if neighCell then 
					if filterF(cell, neighCell) then
						neighborhood:addCell(coord, cs1, weightF(cell,neighCell))
					end
				end
			end
		end	
		cell:addNeighborhood(neighborhood, name)
	end)
	_coordbyNeighborhood_ = false
	return true
end
--]]
CellularSpace_ = {
	type_ = "CellularSpace",
	--## ADICIONADO PEDRO REQUER Lua 4.2
	--__len = function(self) print(" BB" ) return table.getn(self.cells); end,
	--## ADICIONADO PEDRO REQUER Lua 4.2
	--__index = function(self, pos) print(">>"); return self.cells[pos] end, 
	--- Add a new Cell to the CellularSpace. It will be the last Cell of the CellularSpace.
	-- @param cell A Cell.
  -- @usage cs:add(cell)
	add = function(self, cell)
		if( cell.agents_ == nil ) then cell.agents_ = {} end
		if( cell.parent ~= nil) then 
			print("Warning: the cell already has a parent! It was replaced by the CellularSpace where it was added!") 
		end
		cell.parent = self
		self.cObj_:addCell(cell.x, cell.y, cell.cObj_)
		table.insert(self.cells, cell)
		self.minRow = math.min(self.minRow, cell.y)
		self.minCol = math.min(self.minCol, cell.x)
		self.maxRow = math.max(self.maxRow, cell.y)
		self.maxCol = math.max(self.maxCol, cell.x)
	end,
	--- Create a Neighborhood for each Cell of the CellularSpace. It gets a table as argument, with the following attributes:
	-- @param data A table
	-- @param data.strategy A string with the strategy to be used for creating the Neighborhood. See the table below.
	-- @tab strategy
	-- Strategy & Description & Parameters (bold are compulsory) \
	-- "3x3" & A 3x3 (Couclelis) Neighborhood. & name, filter,weight \
	-- "coord" & A bidirected relation between two CellularSpaces connecting Cells with the same (x, y) coordinates. & name, target \
	-- "function" & A Neighborhood based on a function where any other Cell can be a neighbor. & name, filter, weight \
	-- "moore"(defalt) & A Moore (queen) Neighborhood. & name, self \
	-- "mxn" & A MxN (columns x rows) Neighborhood within the CellularSpace or between two CellularSpaces if target is used. & name, M, N, filter, weight, target \
	-- "vonneumann" & A von Neumann (rook) Neighborhood. & name, self
	-- @param data.filter A function(Cell, Cell)->bool, where the first argument is the Cell itself and the other represent a possible neighbor. It returns true when the neighbor will be included in the relation. In the case of two CellularSpaces, this function is called twice for e ach pair of Cells, first filter(c1, c2) and then filter(c2, c1), where c1 belongs to cs1 and c2 belongs to cs2.
    -- @param data.m Number of columns. If m is even then it will be increased by one to keep the Cell in the center of the Neighborhood.
    -- @param data.n Number of rows. If n is even then it will be increased by one to keep the Cell in the center of the Neighborhood.
	-- @param data.name A string with the name of the Neighborhood to be created. Default is "1".
	-- @param data.self Add the Cell as neighbor of itself? Default is false. Note that the functions that do not require this argument always depend on a filter function, which will define whether the Cell can be neighbor of itself.
	-- @param data.target Another CellularSpace whose Cells will be used to create neighborhoods.
	-- @param data.weight A function(Cell, Cell)->number, where the first argument is the Cell itself and the other represent its neighbor. It calculates the weight of the relation. The weight will be computed only if filter returns true.
	-- @usage cs:createNeighborhood() -- moore 
	--
	-- cs:createNeighborhood {
	--     name = "moore"
	-- }	
	--
	-- cs:createNeighborhood {
	--     strategy = "vonneumann", 
	--     self = false
	-- }
	--
	-- cs:createNeighborhood {
	--     strategy = "mxn", 
	--     M = 4,
	--     N = 4
	-- }
	--
	-- -- c2 is nested in cs1
	-- cs1:createNeighborhood {
	--     strategy = "mxn", 
	--     target = cs2, -- other cs
	--     M = 3,
	--     N = 2,
	--     name = "spatialCoupling"
	-- }
	createNeighborhood = function(self, data)
		if(data == nil)then 
			data = {}
      defaultValueWarningMsg("#1", "table", "{}", 3) 
		elseif(type(data) ~= "table")then
 			customErrorMsg("Error: Incompatible types. Parameter should be a table, got "..type(data)..".", 3)
		end

		if(data.name == nil)then
			globalNeighborhoodIdCounter = globalNeighborhoodIdCounter + 1
			data.name = "neigh"..globalNeighborhoodIdCounter
			defaultValueWarningMsg("name", "string", data.name, 3)
		elseif type(data.name) ~= "string" then 
			incompatibleTypesErrorMsg("name", "string",type(data.name),3)
		end

    	if(data.strategy == nil)then
			data.strategy = "moore"
			defaultValueWarningMsg("strategy", "string", data.strategy, 3)
    	elseif(type(data.strategy) ~= "string") then
			incompatibleTypesErrorMsg("strategy","string",type(data.strategy),3)
    	elseif(type(data.strategy) == "string" and (not (data.strategy == "function") and not (data.strategy == "3x3") and not (data.strategy == "mxn") and not (data.strategy == "moore") and not (data.strategy == "vonneumann") and not (data.strategy == "coord")))then
			incompatibleValuesErrorMsg("strategy","one of the strings from the set ['function', '3x3', 'mxn', 'moore', 'vonneumann', 'coord']",(data.strategy),3)
		end

		return switch(data, "strategy") : caseof {
			["function"]   = function() 
		        if(data.filter == nil)then
		        	mandatoryArgumentErrorMsg("filter", 3)
		        elseif(type(data.filter) ~="function")then
	          		incompatibleTypesErrorMsg("filter", "function", type(data.filter), 3)
		      	end

				if data.weight == nil then
					data.weight = function() return 1 end
					defaultValueWarningMsg("weight", "function", "function() return 1 end", 3)
				elseif(type(data.weight) ~= "function")then
					incompatibleTypesErrorMsg("weight", "function", type(data.weight), 3)
				end

				return createNeighborhood(self, data.filter, data.weight, data.name) 
			end,
			["moore"]      = function()
        		if(data.self == nil)then
					data.self = false
					defaultValueWarningMsg("self", "boolean", data.self, 3)
        		elseif(type(data.self) ~= "boolean")then
					incompatibleTypesErrorMsg("self","boolean",type(data.self),3)
				end

        		if(data.wrap == nil)then
					data.wrap = false
					defaultValueWarningMsg("wrap", "boolean", data.wrap, 3)
	    		elseif(type(data.wrap) ~= "boolean") then
					incompatibleTypesErrorMsg("wrap","boolean",type(data.wrap),3)
				end

				return createMooreNeighborhood(self, data.name, data.self, data.wrap)
			end,
			["mxn"]        = function()
				if(data.m == nil)then
        			mandatoryArgumentErrorMsg("m", 3)
        		elseif(type(data.m) ~= "number")then
        			incompatibleTypesErrorMsg("m", "positive integer number (greater than zero)", type(data.m), 3)
        		elseif(data.m <= 0)then
        			incompatibleValuesErrorMsg("m", "positive integer number (greater than zero)", data.m, 3)
        		elseif(math.floor(data.m) ~= data.m)then
        			incompatibleValuesErrorMsg("m", "positive integer number (greater than zero)", "float number", 3)
        		elseif(data.m % 2 == 0)then
        			data.m = data.m + 1
        			customWarningMsg("Warning: Parameter 'm' is even. It was increased by 1 (one) to keep the Cell in the center of the Neighborhood.", 3)
				end

		        if(data.n == nil)then
		        	data.n = data.m
		        	defaultValueWarningMsg("n", "positive integer number", data.m, 3)
		        elseif(type(data.n) ~= "number")then
		        	incompatibleTypesErrorMsg("n", "positive integer number (greater than zero)", type(data.n), 3)
		        elseif(data.n <= 0)then
		        	incompatibleValuesErrorMsg("n", "positive integer number (greater than zero)", data.n, 3)
		        elseif(math.floor(data.n) ~= data.n)then
		        	incompatibleValuesErrorMsg("n", "positive integer number (greater than zero)", "float number", 3)
		        elseif(data.n % 2 == 0)then
		        	data.n = data.n + 1
		        	customWarningMsg("Warning: Parameter 'n' is even. It was increased by 1 (one) to keep the Cell in the center of the Neighborhood.", 3)
				end

		        if(data.filter == nil)then
		        	data.filter = function() return true end
		        	defaultValueWarningMsg("filter", "function", "function() return true end", 3)
		        elseif(type(data.filter) ~="function")then
					incompatibleTypesErrorMsg("filter","function",type(data.filter),3)
				end

				if(data.weight == nil)then
					data.weight = function() return 1 end
					defaultValueWarningMsg("weight", "function", "function() return 1 end", 3)
			  	elseif(type(data.weight) ~= "function")then
          			incompatibleTypesErrorMsg("weight", "function", type(data.weight), 3)
				end

				if(data.target == nil)then
					return createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name)
				else
					if(type(data.target) ~= "CellularSpace")then
						incompatibleTypesErrorMsg("target", "CellularSpace", type(data.target), 3)
					end
					return spatialCoupling(data.m, data.n, self, data.target, data.filter, data.weight, data.name)
				end
			end,
			["vonneumann"] = function() 
				if(data.self == nil)then
					data.self = false
					defaultValueWarningMsg("self", "boolean", data.self, 3)
        		elseif(type(data.self) ~= "boolean")then
					incompatibleTypesErrorMsg("self", "boolean", type(data.self), 3)
				end

        		if(data.wrap == nil)then
					data.wrap = false
					defaultValueWarningMsg("wrap", "boolean", data.wrap, 3)
	    		elseif(type(data.wrap) ~= "boolean") then
					  incompatibleTypesErrorMsg("wrap","boolean",type(data.wrap), 3)
				end

				return createVonNeumannNeighborhood(self, data.name, data.self, data.wrap) 
			end,
			["3x3"]        = function() 
				data.m = 3
				data.n = 3

				if(data.filter == nil)then
        			data.filter = function() return true end
        			defaultValueWarningMsg("filter", "function", "function() return true end", 3)
        		elseif(type(data.filter) ~="function")then
          			incompatibleTypesErrorMsg("filter", "function", type(data.filter), 3)
	      		end

				if(data.weight == nil)then
					data.weight = function() return 1 end
					defaultValueWarningMsg("weight","function", "function() return 1 end", 3)
				elseif(type(data.weight) ~= "function")then
					incompatibleTypesErrorMsg("weight","function", type(data.weight), 3)
				end

				return createMxNNeighborhood(self, data.m, data.n, data.filter, data.weight, data.name) 
			end,
			["coord"] 	   = function() 
				if(data.target == nil) then
					mandatoryArgumentErrorMsg("target", 3)
				elseif(type(data.target) ~= "CellularSpace")then
					incompatibleTypesErrorMsg("target", "CellularSpace", type(data.target), 3)
				end

				return coordCoupling(self, data.target, data.name) 
			end
		}
	end,
	--- Retrieve a Cell from the CellularSpace, given its index.
	-- @param index A Coord.
	-- @usage cs:getCell(coord)
	getCell = function(self, index)
		if type(index) ~= "Coord"then
			if index == nil then
				deniedOperationMsg("getCell",3)
				return nil
			else
				incompatibleTypesErrorMsg("index", "Coord", type(index), 3)
			end
		end
		return self.cObj_:getCell(index.cObj_)
	end,
	--- Retrieve a vector containing all Cells of the CellularSpace.
	-- @usage cells = cs:getCells()
	-- cell = cs:getCells()[1]
	getCells = function(self)
		return self.cells
	end,
	-- Esta funcao e necessaria para o loadNeighborhood a partir do Environment
	getCellByID = function(self, cellID)
		return self.cObj_:getCellByID(cellID)
	end,	
	--#- Retrieve the 'database' attribute of the cellular space
	getDataBase = function(self)
		return self.database
	end,
	--#- Retrieve the 'theme' attribute of the cellular space
	getTheme = function(self)
		return self.theme
	end,
	--#- Retrieve the 'getDBType' attribute of the cellular space
	getDBType = function(self)
		return self.dbType
	end,
	--#- Retrieve the 'host' attribute of the cellular space
	getHost = function(self)
		return self.host
	end,
	--#- Retrieve the 'port' attribute of the cellular space
	getPort = function(self)
		return self.port
	end,
	--#- Retrieve the 'user' attribute of the cellular space
	getUser = function(self)
		return self.user
	end,
	--#- Retrieve the 'password' attribute of the cellular space
	getPassword = function(self)
		return self.password
	end,
	--#- Retrieve the 'layer' attribute of the cellular space
	getLayer = function(self)
		return self.layer
	end,
	--#- Retrieve the 'autoLoad' attribute of the cellular space
	getAutoLoad = function(self)
		return self.autoload
	end,
	--#- Retrieve the 'select' attribute of the cellular space
	getSelect = function(self)
		return self.select
	end,
	--#- Retrieve the 'where' attribute of the cellular space
	getWhere = function(self)
		return self.where
	end,
	--- Retrieve the 'xDim' attribute of the cellular space
	-- @usage x = cs:getXDim()
	getXDim = function(self)
		return self.xdim
	end,
	--- Retrieve the 'yDim' attribute of the cellular space
	-- @usage y = cs:getYDim()
	getYDim = function(self)
		return self.ydim
	end,
	--#- Update the 'dataBase' attribute of the cellular space
	setDataBase = function(self,database)
		if(type(database) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(database), 3)
		end	
		self.database = database
		self.cObj_:setDataBase(database)
		return true
	end,
	--#- Update the 'theme' attribute of the cellular space
	setTheme = function(self,theme)
		if(type(theme) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(theme), 3)
		end	
		self.theme = theme
		self.cObj_:setTheme(theme)
		return true
	end,
	--#- Update the 'type' attribute of the cellular space
	setDBType = function(self,dbType)
		if(type(dbType) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(dbType), 3)
		end	
		self.dbType = dbType
		self.cObj_:setDBType(dbType)
		return true
	end,
	--#- Update the 'host' attribute of the cellular space
	setHost = function(self,host)
		if(type(host) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(host), 3)
		end	
		self.host = host
		self.cObj_setHost(host)
		return true
	end,
	--#- Update the 'port' attribute of the cellular space
	setPort = function(self,port)
		if(type(port) ~= "number") then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(port), 3)
    elseif port < 0 or port ~= math.floor(port) then
			incompatibleValuesErrorMsg("#1", "positive integer number", port, 3)
		end	
		self.port = port
		self.cObj_:setPort(port)
		return true
	end,
	--#- Update the 'user' attribute of the cellular space
	setUser = function(self,user)
		if(type(user) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(user), 3)
		end
		self.user = user
		self.cObj_:setUser(user)
		return true
	end,
	--#- Update the 'password' attribute of the cellular space
	setPassword = function(self, password)
		if(type(password) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(password), 3)
  	end
		self.password = password
		self.cObj_:setPassword(password)
		return true
	end,
	--#- Update the 'layer' attribute of the cellular space
	setLayer = function(self,layer)
		if(type(layer) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(layer), 3)
		end
		self.layer = layer
		self.cObj_:setLayer(layer)
		return true
	end,
	--#- Update the 'autoload' attribute of the cellular space
	setAutoLoad = function(self,autoload)
		if(type(autoload) ~= "boolean") then
			incompatibleTypesErrorMsg("#1", "boolean", type(autoload), 3)
		end
		self.autoload = autoload
		self.cObj_:setLoad(autoload)
		return true
	end,
	--#- Update the 'select' attribute of the cellular space
	setSelect = function(self,select)
		if(type(select) ~= "string" and type(select) ~= "table") then
			incompatibleTypesErrorMsg("#1", "string or table", type(select), 3)
		end
		self.select = select
		self.cObj_:setSelect(select) 
		return true
	end,
	--#- Update the 'where' attribute of the cellular space
	setWhere = function(self,where)
		if(type(where) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(where), 3)
		end
		self.where = where
		self.cObj_:setWhere(where) 
		return true
	end,
	--#- Update the 'xDim' attribute of the cellular space
	setXDim = function(self,xdim)
		if(type(xdim) ~= "number") then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(xdim), 3)
    elseif xdim < 0 or xdim ~= math.floor(xdim) then
			incompatibleValuesErrorMsg("#1", "positive integer number", xdim, 3)    
		end
		self.xdim=xdim
		self.cObj_:setXDim(xdim) 
		return true
	end,
	--#- Update the 'yDim' attribute of the cellular space
	setYDim = function(self,ydim)
		if(type(ydim) ~= "number") then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(ydim), 3)
    elseif ydim < 0 or ydim ~= math.floor(ydim) then
			incompatibleValuesErrorMsg("#1", "positive integer number", ydim, 3)    
		end
		self.ydim=ydim
		self.cObj_:setYDim(ydim) 
		return true
	end,
	--- Load the CellularSpace from the database. TerraME automatically executes this function when the CellularSpace is created, but one can execute this to load the attributes again, erasing each other attribute and relations created by the modeler.
	-- @usage cs:load()
	load = function(self)
		if(self.database:endswith("shp")) then
			return self:loadShape()
		end

		self.legend = {} 
		local x = 0
		local y = 0
		local legendStr = ""

		self.cells, self.minCol, self.minRow, self.maxCol, self.maxRow, legendStr = self.cObj_:load()

		-- tratamento de erros de conexao com banco de dados
		-- as variaveis self.cells e self.minCol foram reutilizadas com semanticas não adequadas neste ponto
		-- vide luaCellularSpace.cpp (método load)
		if (self.cells == -1) then
			customErrorMsg(self.minCol, 3)
			return false
		end

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
			tab.agents_ = {}
			tab.parent = self
			self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
		end
	end,
	--#- Load the CellularSpace from a shapefile.
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
			tab.agents_ = {}
			tab.parent = self
			self.cObj_:addCell(tab.x, tab.y, tab.cObj_)
		end
	end,
	--- Load a Neighborhood stored in an external source. Each Cell receives its own set of neighbors.
	-- @param data.name A string with the location of the Neighborhood 
	-- to be loaded. See below.
	-- @param tbAttrLoad.source A string with the name of the Neighborhood
	-- to be loaded within TerraME. Default is "1".
	-- @tab name
	-- Source & Description \
	--"*.gal" & Load a Neighborhood from contiguity relationships described as a GAL file.\
	-- "*.gwt" & Load a Neighborhood from a GWT (generalized weights) file.\
	-- "*.gpm" & Load a Neighborhood from a GPM (generalized proximity matrix) file. \
	-- Any other & Load a Neighborhood from table stored in the same database of the CellularSpace. \
	-- @usage cs:loadNeighborhood{
	--     source = "n.gpm"
	-- }
	-- 
	-- cs:loadNeighborhood{
	--     source = "mtab",
	--     name = "mtab"
	-- }
	loadNeighborhood = function(self, data)
		if(data == nil)then 
			customErrorMsg("Error: Parameter should be a table.", 3)
		elseif(type(data) ~= "table")then
 			customErrorMsg("Incompatible types. Parameter should be a table, got "..type(data), 3)
		end

		if(data.source == nil)then
			mandatoryArgumentErrorMsg("source", 3)
		elseif type(data.source) ~= "string" then 
			incompatibleTypesErrorMsg("source", "string",type(data.source), 3)
		end

		if data.source:endswith(".gal") or data.source:endswith(".gwt") or data.source:endswith(".gpm") then
			if not io.open(data.source,'r')then
				resourceNotFoundErrorMsg("source",data.source, 3)
			end
		end

		if(data.name == nil)then
			globalNeighborhoodIdCounter = globalNeighborhoodIdCounter + 1
			data.name = "neigh"..globalNeighborhoodIdCounter
			defaultValueWarningMsg("name", "string", data.name, 3)
		elseif type(data.name) ~= "string" then 
			incompatibleTypesErrorMsg("name","string", type(data.name), 3)
		end

		self.cObj_:loadNeighborhood(data.source, data.name)
	end,
	--- Notify every Observer connected to the CellularSpace.
	-- @param modelTime The time to be used by the Observer. Most of the strategies available ignore this value. 
	-- @usage cs:notify()
	-- cs:notify(event:getTime())
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
	--- Retrieve a random Cell from the CellularSpace.
	-- @param randomObj a Random object (optional).
	-- @usage cell = cs:sample()
	sample = function(self, randomObj)
		if type(randomObj) == "Random" then
			return self.cells[randomObj:integer(1, self:size())]                          
		else
			return self.cells[TME_GLOBAL_RANDOM:integer(1, self:size())]            
		end         
	end,
	--- Save the attributes of a CellularSpace into the same database it was retrieved.
	-- @param time A temporal value to be stored in the database, which can be different from the simulation time.
	-- @param outputTableName Name of the table to store the attributes of the Cells.
	-- @param attrNames A vector with the names of the attributes to be saved (default is all of them). When saving a single attribute, you can use attrNames = "attribute" instead of attrNames = {"attribute"}.
	-- @usage cs:save(20,"table")
	--
	-- cs:save(100, "ntab", "attr")
	save = function(self, time, outputTableName, attrNames)
		if type(time) ~= "number" then
			if time == nil then
				globalSaveValue = globalSaveValue + 1
				time = globalSaveValue
				defaultValueWarningMsg("#1", "positive integer number", time, 3)
			else
				incompatibleTypesErrorMsg("#1","positive integer number",type(time), 3)
			end
		elseif(time < 0) then
			incompatibleValuesErrorMsg("#1","positive integer number", time, 3)	  
		elseif(math.floor(time) ~= time) then
			incompatibleValuesErrorMsg("#1","positive integer number",time, 3)
		end

		if type(outputTableName) ~= "string" then 
			if outputTableName == nil then
				outputTableName = "theme_"
				defaultValueWarningMsg("#2", "string", outputTableName, 3)
			else
				incompatibleTypesErrorMsg("#2", "string", type(outputTableName), 3)
			end
		end

		if type(attrNames) ~= "string" and type(attrNames) ~= "table" then
  		incompatibleTypesErrorMsg("#3", "string", type(attrNames), 3)
		end   

		if (type(attrNames) == "string") then attrNames = {attrNames} end
		for _,attr in pairs(attrNames) do
		  if not self.cells[1][attr] then
		    customErrorMsg("Error: Attribute \""..attr.."\" not valid.",3)
		  end
		end
		local erros = self.cObj_:save(time, outputTableName, attrNames, self.cells)
	end,
	--- Save the attributes of a shapefile into the same file it was retrieved.
	-- @usage cs:saveShape()
	saveShape = function(self)
		local shapefileName = self.cObj_:getDBName()
		if(shapefileName=="") then customErrorMsg("Error: Shapefile must be loaded before being saved.", 3) end
		local shapeExists = io.open(shapefileName,"r") and io.open(shapefileName:sub(1,#shapefileName-3).."dbf")
		if shapeExists==nil then customErrorMsg("Error: Shapefile not found.", 3)
		else io.close(shapeExists)
		end
		local contCells = 0
		forEachCell(self, function(cell)
			for k,v in pairs(cell) do
				local type_
				if(type(v) == "number") then
					type_ = 1
				elseif(type(v) == "string") then
					type_ = 2
				else
					type_ = 0
				end
				self.cObj_:saveShape(cell.objectId_,k,v,type_)
			end
			contCells = contCells + 1
		end)
		print("\tnumber of saved cells: "..contCells..".")io.flush()
	end,
	--- Retrieve the number of Cells of the CellularSpace.
	-- @usage print(cs:size())
	size = function(self) return getn(self.cells); end,
	--- Split the CellularSpace into a table of Trajectories according to a classification strategy. The generated Trajectories have empty intersection and union equals to the whole CellularSpace (unless function below returns nil for some Cell). 
	-- @param argument A string or a function, as follows:
	-- @tab argument
	-- Type of argument & Description \
	-- string & The argument must represent the name of one attribute of the Cells of the CellularSpace. Split then creates one Trajectory for each possible value of the attribute using the value as index and fills them with the Cells that have the respective attribute value. \
	-- function & The argument is a function that receives a Cell as argument and returns a value with the index that contains the Cell. Trajectories are then indexed according to the returning value.\
	-- @usage ts = cs:split("cover")
	-- print(ts.forest:size())
	-- print(ts.pasture:size())
	-- 
	-- ts2 = cs:split(function(cell)
	--     if cell.forest > 0.5 then 
	--         return "gt" 
	--     else 
	--         return "lt" 
	--     end
	-- end)
	-- print(ts.gt:size())
	split = function(self, argument)

		if type(argument) ~= "function" and type(argument) ~= "string" then
			if argument == nil then
				incompatibleTypesErrorMsg("#1", "string or function", type(argument), 3)
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
			if result[class] == nil then
				result[class] = Trajectory{target = self, build = false, select = function() return true end}
			end
			table.insert(result[class].cells, cell)
			result[class].cObj_:add(i, cell.cObj_)
			i = i + 1
		end)
		return result
	end,
	--- Synchronize the CellularSpace, calling the function synchronize() for each of its Cells.
	-- @param values A string or a vector of strings with the attributes to be synchronized. If empty, TerraME synchronizes every attribute read from the database but the (x, y) coordinates and the attributes created along the simulation.
	-- @usage cs:synchronize()
	-- cs:synchronize("landuse")
	-- cs:synchronize{"water","use"}
	synchronize = function(self, values)
		if getn(self.cells) <= 0 then
			customErrorMsg("Error: CellularSpace needs to be loaded first.", 3)
		end
		if type(values) == "string" then values = {values} end
		if type(values) ~= "table" then 
			if values == nil then
				values = {}
        defaultValueWarningMsg("#1", "string or table", "{}", 3)
				customWarningMsg("Warning: Synchronizing with every attribute from the database.", 3)        
				local count = 1
				local cell = self.cells[1]
				for k,v in pairs(cell) do
					if k ~= "past" and k ~= "cObj_" and k ~= "agents_" and k ~= "x" and k ~= "y" then
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

		for _,v in pairs(values) do
			if type(v) == "string" then
				s = s..v.." = cell."..v..", "
			else
				customErrorMsg("Error: Parameter 'values' should contain only strings.", 3)
			end
		end

		s = s.."} end"

		forEachCell(self, load(s)())
	end
}

metaTableCellularSpace_ = {__index = CellularSpace_}

--- A multivalued set of Cells. It can be retrieved from TerraLib databases or created
-- directly within TerraME (rectangular). These two ways of creating
-- CellularSpaces have different mandatory arguments: database and theme for reading
-- from a DBMS, and xdim and ydim for CellularSpaces only in memory. Cellular spaces
-- stored in databases need to be loaded to TerraME before using it. Calling forEachCell()
-- traverses CellularSpaces.
--
-- @param data A table.
-- @param data.database Name of the database. It can also describe the location of a shapefile. In thiscase, the other arguments will be ignored.
-- @param data.theme Name of the theme to be loaded.
-- @param data.dbType Name of DBMS. The default value depends on the database name. If it has a ".mdb" extension, the default value is "ado", otherwise it is "mysql"). TerraME always converts this string to lower case.
-- @param data.host Host where the database is stored (default is "localhost").
-- @param data.port Port number of the connection.
-- @param data.user Username (default is "").
-- @param data.password The password (default is "").
-- @param data.layer A boolean value indicating whether the CellularSpace will be loaded automatically (true, default value) or the user by herself will call load (false).
-- @param data.load A boolean value indicating whether the CellularSpace will be loaded automatically (true, default value) or the user by herself will call load (false).
-- @param data.select A table containing the names of the attributes to be retrieved (default is all attributes). When retrieving a single attribute, you can use select = "attribute" instead of select = {"attribute"}. It is possible to rename the attribute name using "as", for example, select= {"lc as landcover"} reads lc from the database but replaces the name to landcover in the Cells. Attributes that contain "." in their names (such as results of table joins) will be read with "_" replacing "." in order to follow Lua syntax to manipulate data.
-- @param data.where A SQL restriction on the properties of the Cells (default is "", applying no restriction. Only the Cells that reflect the established criteria will be loaded). The where argument ignores the "as" flexibility of select.
-- @param data.xdim Number of columns, in the case of creating a CellularSpace without needing to load from a database.
-- @param data.ydim Number of lines, in the case of creating a CellularSpace without needing to load from a database. Default is equal to xdim.
--
-- @output cells A vector of Cells pointed by the CellularSpace.
-- @output cObj_ A pointer to a C++ object.
-- @output parent The Environment it belongs.
-- @output type A string containing "CellularSpace".
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
	local cObj = TeCellularSpace()
	local shpFlag = false

	if(data.database ~= nil and type(data.autoload) ~= "boolean") then
		if(data.autoload == nil) then
			data.autoload = true
			defaultValueWarningMsg("autoload", "boolean", "true", 3)
		else
			incompatibleTypesErrorMsg("autoload","boolean",type(data.autoload), 3)
		end

	end    

	data.cells = {}
	data.cObj_= cObj
	if data.minRow == nil then data.minRow = 100000 end
	if data.minCol == nil then data.minCol = 100000 end
	if data.maxRow == nil then data.maxRow = -data.minRow end
	if data.maxCol == nil then data.maxCol = -data.minCol end

	if data.xdim or data.ydim   then -- rectangular "virtual" cellular spaceb
		if(type(data.xdim) ~= "number") then
			if(data.xdim == nil) then
				data.xdim = 0
				defaultValueWarningMsg("xdim", "positive integer number", data.xdim, 3)
			else
				incompatibleTypesErrorMsg("xdim","positive integer number", type(data.xdim), 3)
			end
		elseif(data.xdim < 0) or (math.floor(data.xdim) ~= data.xdim) then
			incompatibleValuesErrorMsg("xdim","positive integer number",data.xdim, 3)
		end

		if(type(data.ydim) ~= "number") then
			if(data.ydim == nil) then
				data.ydim = data.xdim
				defaultValueWarningMsg("ydim", "positive integer number", data.ydim, 3)
			else
				incompatibleTypesErrorMsg("ydim","positive integer number", type(data.ydim), 3)
			end
		elseif(data.ydim < 0) or (math.floor(data.ydim) ~= data.ydim)then
			incompatibleValuesErrorMsg("ydim","positive integer number",data.ydim, 3)
		end

		--RAIAN: Alterei os valores para ficar compatível com o x e o y das celulas
		data.minRow = 0
		data.minCol = 0
		data.maxRow = data.ydim - 1
		data.maxCol = data.xdim - 1
		--RAIAN: FIM

		data.load = function(self)
			self.cells = {}
			self.cObj_:clear()
			for i = 1, self.xdim do
				for j = 1, self.ydim do
					globalCellIdCounter = globalCellIdCounter + 1
					local c = Cell{ id="cell"..globalCellIdCounter, x = i-1, y = j-1}
					c.agents_ = {}
					c.parent = self
					--self:add(c)
					-- The line obove was replaced by the two following lines in order to get better performance
					self.cObj_:addCell(c.x, c.y, c.cObj_)
					table.insert(self.cells, c)
				end
			end
      data.load = function(self)
				customErrorMsg("Error: Cannot load volatile cellular spaces.", 3)
      end
		end
	else
		if not data.database or type(data.database) ~="string" then
			customErrorMsg("Error: Parameter 'database' is mandatory.", 3)
		elseif data.database:endswith(".shp") or data.database:endswith(".mdb") then
			local f=io.open(data.database,"r")
			if not f then
				customErrorMsg("Error: File '".. data.database .."' not found.", 3)
			end
		end		
		
		
		if data.dbType == nil then
			if data.database:endswith(".shp") or data.database:endswith(".mdb")then

				if not io.open(data.database,'r') then
					resourceNotFoundErrorMsg("database",data.database, 3)
				else
					if data.database:endswith(".shp") then
						data.dbType = "shp"
						defaultValueWarningMsg("dbType", "string", data.dbType, 3)
						shpFlag = true
					elseif data.database:endswith(".mdb") then
						data.dbType = "ado"
						defaultValueWarningMsg("dbType", "string", data.dbType, 3)
					end
					cObj:setDBType(string.lower(data.dbType))
					cObj:setDBName(data.database)
				end
			else
				data.dbType = "mysql"
				defaultValueWarningMsg("dbType", "string", data.dbType, 3)
			end
		elseif type(data.dbType) ~= "string" then
			incompatibleTypesErrorMsg("dbType", "string",type(data.dbType), 3)
		elseif data.dbType ~= "mysql" and data.dbType ~= "ado" and data.dbType ~= "shp" then
			incompatibleValuesErrorMsg("dbType","one of the strings from the set ['mysql','ado','shp']",data.dbType, 3)          
		end
	
		cObj:setDBType(string.lower(data.dbType))	
		cObj:setDBName(data.database)		

		if data.dbType == "mysql" then                    
			cObj:setDBName(data.database)
		elseif( not data.database:endswith(".shp") and not data.database:endswith(".mdb")) then
			local ext
			local pos = 0
			for i = 1, data.database:len(), 1 do if data.database:sub(i,i) == "." then pos = i break end end
			ext = data.database:sub(pos,data.database:len())
			incompatibleFileExtensionErrorMsg("database",ext, 3)
		end
		
		

		if data.database:endswith(".shp") then
			local dbname = data.database
			local shapeExists = io.open(dbname,"r") and io.open(dbname:sub(1,dbname:len()-3).."dbf")
			if not shapeExists then customErrorMsg("Error: Shapefile not found.", 3)
			else io.close(shapeExists)
			end
		else
			if data.dbType == "mysql" then
				-- até 1024 also 65535      	
				if type(data.port) ~= "number" then
					if data.port == nil then
						data.port = 3306
						defaultValueWarningMsg("port","positive integer number", data.port, 3)
					else
						incompatibleTypesErrorMsg("port", "positive integer number", type(data.port), 3)
					end
				elseif(data.port ~= math.floor(data.port) or data.port < 0) then
					incompatibleValuesErrorMsg("port", "positive integer number", data.port, 3)
				elseif(data.port < 1024) then
					customErrorMsg("Error: Parameter 'port' should have values above 1023 for avoid usage of system reserved port values.\nApplication reserved port values should be avoided as well (ex.: mysql 3306).", 3)
				end
				cObj:setPort(data.port)	 

				if type(data.host) ~= "string" then
					if data.host == nil then
						defaultValueWarningMsg("host", "string", "localhost", 3)  
						data.host = "localhost"
					else
						incompatibleTypesErrorMsg("host","string", type(data.host), 3)
					end
				end
				cObj:setHostName(data.host)

				if type(data.user) ~= "string" then
					if data.user == nil then
						data.user = "root"
						defaultValueWarningMsg("user", "string", data.user, 3)
					else
						incompatibleTypesErrorMsg("user","string",type(data.user), 3)
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
          defaultValueWarningMsg("layer", "string", data.layer, 3)
					customWarningMsg("Warning: Parameter 'layer' will be set when loading the TerraLib database.", 3)  
				else
					incompatibleTypesErrorMsg("layer","string", type(data.layer), 3)
				end
			end
			cObj:setLayer(data.layer)

			if(type(data.where) == "string") then 
				cObj:setWhereClause(data.where)
			elseif(data.where ~= nil)then
				incompatibleTypesErrorMsg("where","string or nil", type(data.where), 3)
			end

			if (type(data.select) ~= "string" and type(data.select) ~= "table" ) then
				if data.select ~= nil then
					incompatibleTypesErrorMsg("select","string, table with strings or nil", type(data.select), 3)
				end
			else
				if (type(data.select) == "string") then
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
	if(data.xdim) then
		data:load()
	else	
		if(data.database ~= nil and data.autoload) then
			data:load()
			-- needed for Environment's loadNeighborhood	
			data.layer = data.cObj_:getLayerName()
		end
	end
	return data
end
