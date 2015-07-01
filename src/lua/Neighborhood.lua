globalNeighborhoodIdCounter = 0

Neighborhood_ = {
	type_ = "Neighborhood",
	--Função que adiciona um vizinho à estrutura de vizinhança de uma célula recebendo como parâmetro uma referência para a célula.
	---Add a new Cell to the Neighborhood. 
	-- It returns a boolean value indicating whether the Cell was correctly added.
	--@param cell  A Cell to be added.
	--@param weight A number representing the weight of the connection. Default is zero.
	--@usage n:addNeighbor(cell, 0.02)
	addNeighbor = function( self, cell, weight)
		if(cell == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
		end

		if(weight == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(weight) ~= "number")then
			incompatibleTypesErrorMsg("#2", "number", type(weight), 3)
		end

		if( not self:isNeighbor(cell) ) then
			return self.cObj_:addNeighbor( cell.x, cell.y, cell.cObj_, weight)
		else
			self.cObj_:setNeighWeight( cell.x, cell.y, cell.cObj_, weight)
		end
		return true
	end,
	--#- Add a new Cell to the Neighborhood.
	-- It returns a boolean value indicating whether the Cell was correctly added.
	-- @param index Coord A Coord where a cell will be added.
	-- @param cellularSpace The CellularSpace that contains the Cell to be added.
	-- @param weight number A number representing the weight of the connection. Default is '0'.
	-- @usage n:addCell(coord, cs)
	-- n:addCell(coord, cs, 0.001)
	addCell = function(self, index, cellularSpace, weight)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		if(cellularSpace == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(cellularSpace) ~= "CellularSpace")then
			incompatibleTypesErrorMsg("#2", "CellularSpace", type(cellularSpace), 3)
		end

		if(weight == nil)then
			mandatoryArgumentErrorMsg("#3", 3)
		elseif(type(weight) ~= "number")then
			incompatibleTypesErrorMsg("#3", "number", type(weight), 3)
		end

		return self.cObj_:addCell(index.cObj_, cellularSpace.cObj_, weight)
	end,
	--Funcao que adiciona um vizinho a estrutura de vizinhanca de uma celula recebendo como parametro uma referencia para a celula.
	--- Remove all Cells from the Neighborhood. In practice, it has almost the same behavior as calling Neighborhood() again.
	-- @usage n:clear()
	clear = function(self)
		self.cObj_:clear()
	end,
	--#- Remove a Cell from the Neighborhood.
	-- It returns a boolean value indicating whether the Cell was correctly added.
	-- @param index A Coord where a cell will be removed.
	-- @usage n:eraseCell(coord)
	eraseCell = function(self, index)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		return self.cObj_:eraseCell(index.cObj_)
	end,
	-- Funcao que retira uma celula da estrutura de vizinhanca de outra celula recebendo como parametro uma referencia para a celula.
	--- Remove Cell to the Neighborhood.
	-- It returns a boolean value indicating whether the Cell was correctly added.
	-- @param cell A cell which will be removed.
	-- @usage n:eraseNeighbor(cell)
	eraseNeighbor = function(self, cell)
		if(cell == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
		end

		self.cObj_:eraseNeighbor(cell.x, cell.y, cell.cObj_)
	end,
	--- Retrieve a Cell, given its index. It returns nil if the Cell does not belong to the Neighborhood.
	-- @param index A Coord where a cell is located.
	-- @usage cell = n:getCell(coord)
	getCell = function(self, index)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		return self:getCells()[index]
	end,
	--- Update a Cell from the Neighborhood.
	-- @param index A Coord where a Cell will be updated.
	-- @param cell A Cell.
	-- @usage n:setCell(coord, cell)
	setCell = function(self,index,cell)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		if(cell == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#2", "Cell", type(cell), 3)
		end

		self.cObj_:setCells(index.cObj_,cell.cObj_)
		return true
	end,
	--- Retrieve a table with all cells in this neighborhood. The neighbors are indexed by their Coords.
	--@usage cells = n:getCells()
	getCells = function(self)
		return self.cObj_:getCells()
	end,

	--- Update all cells in the table.
	-- It returns a boolean value indicating whether the Cell was correctly updated.
	--@param cells A table whith the new cells.
	--@usage n:setCells(cells)
	setCells = function(self,cells)
		if(cells == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cells) ~= "table")then
			incompatibleTypesErrorMsg("#1", "table", type(cells), 3)
		end

		self.cObj_:setCells(index.cObj_,cells.cObj_)
		return true
	end,

	--- Start a neighbor iterator, pointing to the first Cell in the neighbors list.
	-- @usage n:first()
	first = function(self)
		self.cObj_:first()
	end,

	--#- Retrieve a neighbor, given its coords.
	-- @param index A Coord where a cell is.
	-- @usage n:getCellNeighbor(coord)
	-- @return Cell Retrieve a neighbor if a cell is in neighborhood or 'nil' otherwise.
	getCellNeighbor = function(self, index)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		return self.cObj_:getCellNeighbor(index.cObj_)
	end,

	--#- Update a neighbor from the Neighborhood.
	-- It returns a boolean value indicating whether the Cell was correctly updated.
	--@param index A Coord where a Cell will be updated.
	--@param cell A Cell which will be setted.
	--@usage n:setCellNeighbor(coord, cell)
	setCellNeighbor = function(self, index, cell)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		if(cell == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#2", "Cell", type(cell), 3)
		end
		self.cObj_:setCellNeighbor(index.cObj_, cell.cObj_)
		return true
	end,

	--- Retrieve the weight of the connection to a given neighbor Cell. If the Cell is not neighbor, it returns nil.
	-- @param index A Coord where a Cell is located.
	-- @usage n:getCellWeight(coord)
	getCellWeight = function(self, index)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		return self.cObj_:getCellWeight(index.cObj_)
	end,

	---Retrieve a Coord with the coordinates of the neighbor pointed by the current iterator.
	--@usage coord = n:getCoord()
	getCoord = function(self)
		return self.cObj_:getCoord()
	end,

	---Retrieve the name of the Neighborhood in the last Cell it was added.
	-- @usage c1:addNeighborhood(n, "n")
	-- c2:addNeighborhood(n, "n2")
	-- id = n:getId() -- "n2"
	getId = function(self)
		return self.cObj_:getID()
	end,

	---Retrieve the neighbor pointed by the current iterator.
	-- @usage neigh = n:getNeighbor()
	getNeighbor = function(self)
		return self.cObj_:getNeighbor()
	end,

	--- Retrieve the weight of the connection to a given neighbour Cell. It returns nil when the Cell is not a neighbor.
	--@param cell A Cell.
	--@usage w = n:getNeighWeight(cell)
	getNeighWeight = function(self, cell)
		if(cell == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
		end

		return self.cObj_:getNeighWeight(cell.x, cell.y, cell.cObj_)
	end,

	--- Retrieve the weight of the connection to a neighbor pointed by the current iterator.
	-- @usage weight = n:getWeight()
	getWeight = function(self)
		return self.cObj_:getWeight()
	end,

	--- Return whether the Neighborhood does not contain any Cell.
	--@usage if n:isEmpty() then
	--     print("is empty")
	-- end
	isEmpty = function(self)
		return self.cObj_:isEmpty()
	end,

	--- Return whether the neighbor iterator is pointing to the first Cell of the list.
	-- @usage bool = n:isFirst()
	isFirst = function(self)
		return self.cObj_:isFirst()
	end,

	--- Return whether the neighbor iterator has already passed by the last Cell of the list, or whether the iterator does not exist.
	-- @usage if n:isLast() then
	--     print("is last")
	-- end
	isLast = function(self)
		return self.cObj_:isLast()
	end,

	--- Return whether a given Cell belongs to the Neighborhood.
	--@param cell A Cell.
	--@usage if n:isNeighbor() then
	--     ...
	-- end
	isNeighbor = function(self, cell)
		if(cell == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
		end

		return self.cObj_:isNeighbor(cell.x, cell.y, cell.cObj_)
	end,

	--- Set the neighbor iterator to the last element in the neighborhood.
	-- @usage n:last()
	last = function(self)
		self.cObj_:last()
	end,

	--- Change the neighbor iterator to the next Cell of the neighborhood.
	-- @usage n:next()
	next = function(self)
		self.cObj_:next()
	end,
	--RAIAN
	previous = function(self)
		self.cObj_:previous()
	end,
	--RAIAN: FIM
	-- Funcao que reconfigura a estrutura de vizinhanca
	-- Parametros: 1 - cellularSpace: Espaco Celular
	--             2 - fCondition: Funcao que determina se a celula faz parte ou nao da vizinhanca
	--             3 - fWeight: Funcao que calcula o peso da relacao
	--#- Reconfigure the sctruct of Neighborhood.
	--@param celullarSpace A CellularSpace.
	--@param fCondition A function which will determine whether a Cell is in Neighborhood.
	--@param fWeight A function which calculate the weight of relation.
	reconfigure = function(self, cellularSpace, fCondition, fWeight)
		if(cellularSpace == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cellularSpace) ~= "CellularSpace")then
			incompatibleTypesErrorMsg("#1", "CellularSpace", type(cellularSpace), 3)
		end

		if(fCondition == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(fCondition) ~= "function")then
			incompatibleTypesErrorMsg("#2", "function", type(fCondition), 3)
		end

		if(fWeight == nil)then
			mandatoryArgumentErrorMsg("#3", 3)
		elseif(type(fWeight) ~= "function")then
			incompatibleTypesErrorMsg("#3", "function", type(fWeight), 3)
		end

		self:first()
		while (not self:isLast()) do
			neighbor = self:getNeighbor()
			if (not fCondition(self:getParent(), neighbor)) then
				self:eraseNeighbor(neighbor)
			end
			self:next()
		end
		for i, cell in ipairs(cellularSpace.cells) do
			if (fCondition(self:getParent(), cell)) then
				self:addNeighbor(cell, fWeight(self:getParent(), cell))
			end
		end
	end,

	--- Retrieve a random Cell from the Neighborhood.
	--@param randomObj A Random object. As default, TerraME uses its internal random number generator.
	--@usage cell = n:sample()
	sample = function(self, randomObj)
		local pos = nil
		if(type(randomObj) == "Random") then
			pos = randomObj:integer(1, self:size())                          
		else
			pos = TME_GLOBAL_RANDOM:integer(1, self:size())            
		end

		local count = 1
		self:first()
		while (not self:isLast()) do
			neigh = self:getNeighbor()
			if count == pos then return neigh end
			self:next()
			count = count + 1
		end
	end,

	--- Update the weight of the connection to a neighbor.
	--@param index A Coord where a Cell is located.
	--@param weight A number representing the new weight.
	--@usage n:setCellWeight(coord, 0.001)
	setCellWeight = function(self, index, weight)
		if(index == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(index) ~= "Coord")then
			incompatibleTypesErrorMsg("#1", "Coord", type(index), 3)
		end

		if(weight == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(weight) ~= "number")then
			incompatibleTypesErrorMsg("#2", "number", type(weight), 3)
		end

		self.cObj_:setCellWeight(index.cObj_, weight)
	end,
	--- Update a weight of the connection to a given neighbor Cell. It returns a boolean value indicating whether the weight was successfully changed.
	--@param cell A Cell.
	--@param weight The new weight.
	--@usage n:setNeighWeigh(cell, 0.01)
	setNeighWeight = function(self, cell, weight)
		if(cell == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(cell) ~= "Cell")then
			incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
		end

		if weight == nil then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(weight) ~= "number")then
			incompatibleTypesErrorMsg("#2", "number", type(weight), 3)
		end
		return self.cObj_:setNeighWeight(cell.x, cell.y, cell.cObj_,weight)
	end,

	--- Update the weight of the connection to a neighbor pointed by the current iterator.
	-- @param weight A number representing the new weight.
	-- @usage n:setWeight(0.001)  
	setWeight = function(self, weight)  		
		if(weight == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(weight) ~= "number")then
			incompatibleTypesErrorMsg("#1", "number", type(weight), 3)
		end
		self.cObj_:setWeight(weight)
	end,

	---Retrieve the number of Cells of the Neighborhood.
	--@usage print(n:size())
	size = function(self)
		return self.cObj_:size()
	end,
	-- RAIAN
	-- returns the parent of the neighborhood (the "central" cell)
	getParent = function(self)
		return self.cObj_:getParent()
	end
}

local metaTableNeighborhood_ = {__index = Neighborhood_}

--- Each Cell has one or more Neighborhoods to represent proximity relations. A Neighborhood is a set of pairs (cell, weight), where cell is a neighbor Cell and weight is a number storing the relation's strength. This type is used to create neighborhoods from scratch. To create well established neighborhoods, see the functions available for CellularSpaces.
-- @param data.id a unique identifier for the neighborhood. As default, TerraME uses a string with an auto incremented number.
--@see Cell:addNeighborhood
--@see CellularSpace:createNeighborhood
--@see CellularSpace:loadNeighborhood
-- @usage n = Neighborhood()
function Neighborhood(data)
	if(data == nil)then 
			data = {} 
	elseif type(data) ~= "table" then
    incompatibleTypesErrorMsg("#1", "table", type(data), 3)
	end

	if(data.id == nil) then
		globalNeighborhoodIdCounter = globalNeighborhoodIdCounter +1
		data.id = "neigh".. globalNeighborhoodIdCounter
	end

	local cObj = nil
	if (data.cObj_ == nil) then
		cObj = TeNeighborhood()
		data.cObj_ = cObj
	else
		cObj = data.cObj_
	end
	setmetatable(data, metaTableNeighborhood_)
	cObj:setReference(data)
	return data
end
