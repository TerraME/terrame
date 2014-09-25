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

Coord_ = {
	type_ = "Coord",
	--#- Return a table with (x,y) as values.
	-- @usage print(coord:get().x)
	-- print(coord:get().y)
	get = function(self) 
		local data = {}
		data.x, data.y = self.cObj_:get()
		return data
	end,
	--#-Return the coord x.
	--@usage x = cllrd:getX()
	getX = function(self) 
		local x, _ = self.cObj_:get()
		return x
	end,
	--#-Return the coord y.
	--@usage y = cllrd:getY()
	getY = function(self) 
		local _, y = self.cObj_:get()
		return y
	end,
	--#-Change the pair(x,y), or only one of its original values.
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

		if type(xValue) ~= "number" then
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

		if type(yValue) ~= "number" then
			incompatibleTypesErrorMsg("y", "positive integer number", type(yValue), 3)
		elseif yValue < 0 then
			incompatibleValuesErrorMsg("y", "positive integer number", yValue, 3)
		end	

		self.y = yValue
		self.cObj_:set(self:getX(), self.y)
		return true
	end
}

metaTableCoord_ = {__index = Coord_, __tostring = tostringTerraME}

--#-A spatial location, represented by a pair (x, y).
-- @param data.x A position on the horizontal axis of a two-dimensional Cartesian coordinate system. Defalt is 0.
-- @param data.y A position on the horizontal axis of a two-dimensional Cartesian coordinate system. Defalt is 0.
-- @usage coord = Coord()
-- coord2 = Coord{x = 2, y = 3}
-- print(coord2.x) -- nil
function Coord(data)
	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		namedParametersErrorMsg("Coord", 3)
	end

	if data.x == nil then
		data.x = 0
	elseif type(data.x) ~= "number" then
		incompatibleTypesErrorMsg("x", "number", type(data.x), 3)
	end

	if data.y == nil then
		data.y = 0
	elseif type(data.y) ~= "number" then
		incompatibleTypesErrorMsg("y", "number", type(data.y), 3)
	end
	data.cObj_ = TeCoord(data)
	setmetatable(data, metaTableCoord_)
	data.cObj_:setReference(data)

	data.x = nil
	data.y = nil
	return data
end
