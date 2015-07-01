globalCellIdCounter = 0

Cell_ = {
	type_ = "Cell",
	--- Add a new Neighborhood to the Cell. It returns a boolean value indicating whether the Neighborhood was successfully added.
	-- @param neigh A Neighborhood.
	-- @param id Neighborhood's name. Default is "neigh1".
	-- @see Neighborhood
	-- @usage cell:addNeighborhood(n)
	-- cell:addNeighborhood(n, "east")
	addNeighborhood = function(self, neigh, id)
		if(neigh == nil)then
			mandatoryArgumentErrorMsg("#1", 3)
		elseif(type(neigh) ~= "Neighborhood")then
			incompatibleTypesErrorMsg("#1", "Neighborhood", type(neigh), 3)
		end

		if(id == nil)then
			mandatoryArgumentErrorMsg("#2", 3)
		elseif(type(id) ~= "string")then
			incompatibleTypesErrorMsg("#2", "string", type(id), 3)
		end

		if(self.neighborhoods == nil) then self.neighborhoods = {} end
		self.neighborhoods[id] = neigh

		return self.cObj_:addNeighborhood(id, neigh.cObj_)
	end,
	--- Start a neighborhood iterator, pointing to the first element of the Neighborhood list.
	-- @usage cell:first()
	first = function(self)
		return self.cObj_:first()
	end,	
	--- Retrieve an Agent that belongs to the Cell. It assumes that there is at least one Agent per Cell.
	-- @param placement a string. Default is 'placement'.
	-- @usage agent = cell:getAgent()
	getAgent = function(self, placement)
		if placement == nil then placement = "placement" end
		return self[placement].agents[1]
	end,
	--- Retrieve the Agents that belong to the Cell. Agents are indexed by numeric positions.
	-- @param placement A string. Default is 'placement'.
	-- @usage agent = cell:getAgents()[1]
	getAgents = function(self, placement)
		if placement == nil then
      placement = "placement"
      defaultValueWarningMsg("#1", "string", placement, 3)
    end
		if(self[placement]) then 		
			return self[placement].agents
		else
			return self.agents_
		end
	end,
	--- Retrieve the Neighborhood currently pointed by the Neighborhood iterator, or nil otherwise.
	-- @see Neighborhood.
	-- @usage cell:getCurrentNeighborhood()
	getCurrentNeighborhood = function(self)
		return self.cObj_:getCurrentNeighborhood()
	end,
	--- Retrieve a string with the unique identifier of the Cell.
	-- @usage id = cell:getId()
	getId = function(self)
		return self.cObj_:getID()
	end,
	--- Retrieve a Neighborhood of the Cell.
	-- @param index A string with the neighborhood’s name to be retrieved. Default is "neigh1".
	-- @usage n = cell:getNeighborhood()
	-- n = cell:getNeighborhood("moore")
	getNeighborhood = function(self, index)
		if(index == nil)then
			index = "neigh1"
			defaultValueWarningMsg("#1", "string", index, 3)
		elseif type(index) ~= "string" then 
			incompatibleTypesErrorMsg("#1", "string", type(index), 3)
		end

		return self.cObj_:getNeighborhood(index)
	end,
	--- Retrieve a table with the attributes of the Cell in the last time synchronize() was called.
	-- @usage cover = cell:getPast().cover
	-- @see Cell:synchronize.
	getPast = function(self)
		return self.past
	end,
	--- Retrieve a random Agent from the Cell.
	-- @usage agent = cell:getRandomAgent()
	getRandomAgent = function(self)
		local randomObj = Random {}
		return self.agents_[randomObj:integer(1, #self.agents_)]
	end,
	--- Retrieve the name of the current state of a given Agent.
	-- @param agent an Agent.
	-- @usage name = cell:getStateName()
	getStateName = function(self, agent)
		return self.cObj_:getCurrentStateName(agent.cObj_)
	end, 
	--- Retrieve a positive integer number representing the 'x'  coord of the Cell.
	-- @usage x = cell:getX()
	getX = function(self)
		return self.x
	end,
	--- Retrieve a positive integer number representing the 'y' coord of the Cell.
	-- @usage y = cell:getY()
	getY = function(self)
		return self.y
	end,
	--- Retrieve whether the neighborhood iterator is pointing to the first Neighborhood of the list.
	-- @usage if cell:isFirst() then
	--     ...
	-- end
	isFirst = function(self) 
		return self.cObj_:isFirst()
	end,
	--- Return whether the Neighborhood iterator has already passed by the last Neighborhood of the list, or whether the iterator does not exist.
	-- @usage l = cell:isLast()
	isLast = function(self)
		return self.cObj_:isLast()
	end,
	--- Set the Neighborhood iterator to the last element of the Neighborhood list.
	-- @usage last = cell:last()
	last = function(self) 
		return self.cObj_:last()
	end,
	--- Update the Neighborhood iterator to the next Neighborhood of the list.
	-- @usage cell:next()
	next = function(self) 
		return self.cObj_:next()
	end,
	--- Notify every Observer connected to the Cell.
	-- @param modelTime The time to be used by the Observer. Most of the strategies available ignore this value; therefore it can be left empty. See the Observer documentation for details.
	-- @usage cell:notify()
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
	--- Retrieve the number of Agents in a cell.
	-- @return a positive integer number
	-- @usage quantity = cell:getNumberOfAgents()
	numberOfAgents = function(self)
		return #self.agents_
	end,
	--- Update the 'id' of the cell.
	-- @param id A string.
	-- @usage cell:setId("newid")
	setId = function(self, id)
		if id == nil then
			globalCellIdCounter = globalCellIdCounter + 1
			self.id = globalCellIdCounter
			defaultValueWarningMsg("#1", "string", self.id, 3)   
		elseif type(id) ~= "string" then
			incompatibleTypesErrorMsg("#1", "string", type(id), 3)  
		end
		self.id = id
		self.cObj_:setID(self.id)
		self.objectId_ = data.cObj_:getID()
	end,
	--#- Update the attribute 'x' of the cell.
	-- @param coordx A position in the horizontal axis. Defalt is not changing.
	setX = function(self, coordx)
		if coordx == nil then
			self.x = 0 
			defaultValueWarningMsg("#1", "positive integer number", self.x, 3)
		elseif type(coordx) ~= "number" then
			incompatibleTypesErrorMsg("#1","positive integer number",type(coordx),3)      
		elseif coordx < 0 or math.floor(coordx) ~= coordx then
			incompatibleValuesErrorMsg("#1","positive integer number",coordx,3) 
		end
		self.x = coordx
		self.cObj_:setIndex(self.x, self.y)
	end,
	--#- Update the attribute 'y' of the cell.
	-- @param coordy A position in the horizontal axis. Defalt is not changing.
	setY = function(self, coordy)
		if coordy == nil then
			coordy = 0 
			defaultValueWarningMsg("#1", "positive integer number", coordy, 3)
		elseif type(coordy) ~= "number" then
			incompatibleTypesErrorMsg("#1", "positive integer number", type(coordy), 3)
		elseif coordy < 0 or math.floor(coordy) ~= coordy then            
			incompatibleValuesErrorMsg("#1", "positive integer number", coordy, 3)
		end

		self.y = coordy
		self.cObj_:setIndex(self.x, self.y,3)
	end,
	--- Retrieve the number of Neighborhoods of the Cell.
	-- @return a positive integer number
	-- @usage size = cell:size()
	size = function(self)
		return self.cObj_:size()
	end,
	--- Synchronizes the Cell. TerraME can keep two copies of the attributes of a Cell in memory: one stores the past values and the other stores the current (present) values. Synchronize copies the current values to a table named past, within the Cell.
	-- @usage cell:synchronize()
	-- @see CellularSpace:synchronize
	synchronize = function(self) 
		self.past = {}
		for k,v in pairs(self) do if(k ~= "past") then self.past[k] = v; end end
	end
}

local metaTableCell_ = {__index = Cell_}

--- A spatial location with homogeneous internal content.
-- It is a table that may contain nearness relations as well as persistent and runtime attributes. 
-- Persistent attributes are loaded from and saved
-- to databases, while runtime attributes exist only along the simulation.
-- @param data.x A positive integer number starting in 0 (default).
-- @param data.y A positive integer number starting in 0 (default).
-- @output past a copy of the attributes at the time of the last synchronization.
-- @output parent the CellularSpace it belongs.
-- @output type a string containing "Cell".
-- @output placement a Group representing the default placement of the Cell (only when its CellularSpace belongs to an Environment.)
-- @output agents a vector of Agents necessary to use forEachAgent(cell) (only when its CellularSpace belongs to an Environment). 
-- @see Utils:forEachNeighborhood
-- @usage cell = Cell {
--     cover = "forest",
--     soilWater = 0
-- }
function Cell(data)
	if data == nil then data = {} end
	if data.id == nil then
		globalCellIdCounter = globalCellIdCounter + 1
		data.id = "cell".. globalCellIdCounter
		defaultValueWarningMsg("id", "string", data.id, 3)
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("id", "string", type(data.id), 3)
	end

	data.cObj_ = TeCell()
	data.past = {}
	data.agents_ = {}

	setmetatable(data, metaTableCell_)
	data.cObj_:setReference(data)

	if(data.objectId_ ~= nil) then
		data.cObj_:setID(data.objectId_)
	else
		if data.x == nil then
			data.x = 0 
			defaultValueWarningMsg("x", "positive integer number", data.x, 3)
		elseif type(data.x) ~= "number" then
			incompatibleTypesErrorMsg("x", "positive integer number",type(data.x), 3)      
		elseif data.x < 0 or math.floor(data.x) ~= data.x then
			incompatibleValuesErrorMsg("x", "positive integer number",data.x, 3)      
		end

		if data.y == nil then
			data.y = 0 
			defaultValueWarningMsg("y", "positive integer number", data.y, 3)
		elseif type(data.y) ~= "number" then
			incompatibleTypesErrorMsg("y","positive integer number",type(data.y), 3)      
		elseif data.y < 0 or math.floor(data.y) ~= data.y then
			incompatibleValuesErrorMsg("y","positive integer number",data.y, 3)      
		end

		data.cObj_:setID("C"..data.x.."L"..data.y)
		data.objectId_ = data.cObj_:getID()
	end
	data.cObj_:setIndex(data.x, data.y)
	return data
end

