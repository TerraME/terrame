Coord_ = {
	type_ = "Coord",
	--- Return a table with (x,y) as values.
	-- @usage print(coord:get().x)
	-- print(coord:get().y)
	get = function(self) 
		local data = {}
		data.x, data.y = self.cObj_:get()
		return data
	end,
	---Return the coord x.
	getX = function(self) 
		x, _ = self.cObj_:get()
		return x
	end,
	---Return the coord y.
	getY = function(self) 
		_, y = self.cObj_:get()
		return y
	end,
	---Change the pair(x,y), or only one of its original values.
	-- @param data.x A position in the horizontal axis. Defalt is not changing.
	-- @param data.y A position in the vertical axis. Defalt is not changing.
	-- @return 'true' if the coord was sucessfully setted, 'false' otherwise.
	-- @usage coord:set{x = 3, y = 2}
	-- coord:set{x = 4}
	set = function(self, data)
		--local xOld, yOld = self.cObj_:get()
    if data == nil then
      mandatoryArgumentErrorMsg("#1", 3)
    elseif type(data) ~= "table"  then
		  incompatibleTypesErrorMsg("#1", "table", type(data), 3)
		end

		if type(data.x) ~= "number" then
			incompatibleTypesErrorMsg("x", "positive integer number", type(data.x), 3)
		elseif data.x < 0 or math.floor(data.x) ~= data.x then
			incompatibleValuesErrorMsg("x", "positive integer number", data.x,3)
			return false
		end

		if type(data.y) ~= "number" then
			incompatibleTypesErrorMsg("y", "positive integer number", type(data.y), 3)
		elseif data.y < 0 or math.floor(data.y) ~= data.y then
			incompatibleValuesErrorMsg("y", "positive integer number",data.y, 3)
			return false
		end		

		self.x = data.x
		self.y = data.y
		self.cObj_:set(data.x, data.y)
		return true
	end,

	setX = function(self, xValue)
		local xOld, _ = self.cObj_:get()

		if(type(xValue) ~= "number") then
			incompatibleTypesErrorMsg("x", "positive integer number", type(xValue), 3)
		elseif xValue < 0 or math.floor(xValue) ~= xValue then
			incompatibleValuesErrorMsg("x", "positive integer number", xValue, 3)
  	end	

		self.x = xValue
		self.cObj_:set(self.x, self:getY())
		return true
	end,

	setY = function(self, yValue)
		local _, yOld = self.cObj_:get()

		if(type(yValue) ~= "number") then
			incompatibleTypesErrorMsg("y", "positive integer number", type(yValue), 3)
		elseif yValue < 0 then
			incompatibleValuesErrorMsg("y", "positive integer number", yValue, 3)
		end	

		self.y = yValue
		self.cObj_:set(self:getX(), self.y)
		return true
	end
}

local metaTableCoord_ = {__index = Coord_}

---A spatial location, represented by a pair (x, y).
-- @param data.x A position on the horizontal axis of a two-dimensional Cartesian coordinate system. Defalt is 0.
-- @param data.y A position on the horizontal axis of a two-dimensional Cartesian coordinate system. Defalt is 0.
-- @usage coord = Coord()
-- coord2 = Coord{x = 2, y = 3}
-- print(coord2.x) -- nil
function Coord(data)
	if data == nil then
		data = {}
		defaultValueWarningMsg("#1","table", "{}",3)    
	elseif(type(data) ~= "table")   then
		incompatibleTypesErrorMsg("#1", "table", type(data), 3)
	end

	if data.x == nil then
		data.x = 0
		defaultValueWarningMsg("x", "positive integer number", data.x, 3)
	elseif(type(data.x) ~= "number") then
		incompatibleTypesErrorMsg("x", "positive integer number", type(data.x), 3)
		-- _coordbyNeighborhood_: variavel definida em CellularSpace que permite ao createNeighborhood criar Coords negativas
	elseif not _coordbyNeighborhood_ and  data.x < 0 then
		incompatibleValuesErrorMsg("x", "positive integer number", data.x, 3)
	end

	if data.y == nil then
		data.y = 0
		defaultValueWarningMsg("y", "positive integer number", data.y, 3)
	elseif(type(data.y) ~= "number") then
		incompatibleTypesErrorMsg("y", "positive integer number", type(data.y), 3)
		-- _coordbyNeighborhood_: variavel definida em CellularSpace que permite ao createNeighborhood criar Coords negativas
	elseif not _coordbyNeighborhood_ and data.y < 0 then
		incompatibleValuesErrorMsg("y", "positive integer number", data.y, 3)
	end
	data.cObj_ = TeCoord(data)
	setmetatable(data, metaTableCoord_)
	data.cObj_:setReference(data)

	data.x = nil
	data.y = nil
	return data
end
