-------------------------------------------------------------------------------------------
--TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
--Copyright © 2001-2010 INPE and TerraLAB/UFOP.
--
--This code is part of the TerraME framework.
--This framework is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library.
--
--The authors reassure the license terms regarding the warranties.
--They specifically disclaim any warranties, including, but not limited to,
--the implied warranties of merchantability and fitness for a particular purpose.
--The framework provided hereunder is on an "as is" basis, and the authors have no
--obligation to provide maintenance, support, updates, enhancements, or modifications.
--In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
--indirect, special, incidental, or consequential damages arising out of the use
--of this library and its documentation.
--
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--      Antonio Jose da Cunha Rodrigues
--      Raian Vargas Maretto


-- Execution modes for TerraME
TME_EXECUTION_MODES = {
	QUIET = 0,
	NORMAL = 1,
	DEBUG = 2,
	STRICT = 3
}

TME_MODE = 1
TME_CPP_MSG = nil

if( os.setlocale(nil, "all") ~= "C" ) then os.setlocale("C", "numeric") end

local TME_VERSION = "1_3_0"
TME_PATH = os.getenv("TME_PATH_" .. TME_VERSION)
local TME_LUA_PATH = TME_PATH .. "//bin//Lua"

TME_DB_VERSION="4_2_0"
TME_DIR_SEPARATOR = package.config:sub(1,1);

if (TME_PATH == nil or TME_PATH == "") then
	error("Error: TME_PATH_" .. TME_VERSION .." environment variable should exist and point to TerraME installation folder.", 2)
end

-- To keep compatibilities with old versions of Lua
local load = load
if (_VERSION ~= "Lua 5.2") then
	load = loadstring
end	

-- **********************************************************************************************
-- util math functions

-- rounds a number given its value and a precision
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

--- Implements the Heun (Euler Second Order) Method to integrate ordinary differential equations.
--- It is a method of type Predictor-Corrector.
-- @param df The differential equantion.
-- @param initCond The initial condition that must be satisfied.
-- @param a The value of 'a' in the interval [a,b[.
-- @param b The value of 'b' of in the interval [a,b[.
-- @param delta The step of the independent variable.
function integrationHeun(df, initCond, a, b, delta)
	if type(df) == "function" then
		local x = a
		local y = initCond
		local y1 = 0
		local val = 0
		local bb = b - delta
		for x = a, bb, delta do
			val = df(x, y)
			y1 = y + delta * val
			y = y + 0.5 * delta * (val + df(x + delta, y1))
		end
		return y
	else
		local x = a
		local y = initCond
		local y1 = 0
		local val = 0
		local bb = b - delta
		local sizeDF = #df
		for x = a, bb, delta do
			local val = {}
			local y1  = {}
			for i = 1, sizeDF do
				val[i] = df[i](x, y)
				y1[i] = y[i] + delta * val[i]
			end
			local values = {}
			for i = 1, sizeDF do
				values[i] = df[i](x + delta, y1)
			end
			for i = 1, sizeDF do
				y[i] = y[i] + 0.5 * delta * (val[i] + values[i])
			end
		end
		return y
	end
end

--- Implements the Runge-Kutta Method (Fourth Order) to integrate ordinary differential equations.
-- @param df The differential equantion.
-- @param initCond The initial condition that must be satisfied.
-- @param a The value of 'a' in the interval [a,b[.
-- @param b The value of 'b' of in the interval [a,b[.
-- @param delta The step of the independent variable.
function integrationRungeKutta(df, initCond, a, b, delta)
	local i = 0
	if type(df) == "function" then
		local x = a
		local y = initCond
		local y1 = 0
		local y2 = 0
		local y3 = 0
		local y4 = 0
		local bb = b - delta
		local midDelta = 0.5 * delta
		for x = a, bb, delta do
			y1 = df(x, y)
			y2 = df(x + midDelta, y + midDelta * y1)
			y3 = df(x + midDelta, y + midDelta * y2)
			y4 = df(x + delta, y + delta* y3)
			y = y + delta * (y1 + 2 * y2 + 2 * y3 + y4)/6
		end
		return y
	else
		local x = a
		local y = initCond
		local y1 = 0
		local y2 = 0
		local y3 = 0
		local y4 = 0
		local bb = b - delta
		local midDelta = 0.5 * delta
		local sizeDF = #df
		for x = a, bb, delta do
			local yTemp = {}
			local values = {}
			for i = 1, sizeDF do
				yTemp[i] = y[i]
			end
			for i = 1, sizeDF do
				y1 = df[i](x, y)
				yTemp[i] = y[i] + midDelta * y1
				y2 = df[i](x + midDelta, yTemp )
				yTemp[i] = y[i] + midDelta * y2
				y3 = df[i](x + midDelta, yTemp )
				yTemp[i] = y[i] + delta * y3
				y4 = df[i](x + delta, yTemp)
				values[i] = y[i] + delta * (y1 + 2 * y2 + 2 * y3 + y4)/6
			end
			for i = 1, sizeDF do
				y[i] = values[i]
			end
		end
		return y

	end
end

--- Implements the Euler (Euler-Cauchy) Method to integrate ordinary differential equations.
-- @param df The differential equantion.
-- @param initCond The initial condition that must be satisfied.
-- @param a The value of 'a' in the interval [a,b[.
-- @param b The value of 'b' of in the interval [a,b[.
-- @param delta The step of the independent variable.
function integrationEuler(df, initCond, a, b, delta)
	if type(df) == "function" then
		local y = initCond
		local x = a
		local bb = b - delta
		for x = a, bb, delta do
			y = y + delta * df(x, y)
		end
		return y
	else
		local i = 0
		local y = initCond
		local x = a
		local bb = b - delta
		local values = {} -- each equation must ne computed from the same "past" value ==> o(n2), onde n é o numero de equações
		for x = a, bb, delta do
			for i = 1, #df do
				values[i] =  df[i](x, y)
			end
			for i = 1, #df do
				y[i] = y[i] + delta * values[i]
			end
		end

		return y
	end
end

-- Global constant to define the used integration method & step size
INTEGRATION_METHOD = integrationEuler
DELTA = 0.2

-- Constructor for an ordinary differential equation
function d(data)
	local result = 0
	local delta = DELTA

	if data == nil then data = {}; end

	local sizedata = getn(data)
	if sizedata < 4 then 
		local str = "Error: bad arguments in diferential equation constructor \"d{arguments}\". "..
		"TerraME has found ".. #data.." arguments.\n"..
		" - the first attribute of a differential equantion must be a function which return a number. "..
		"It can also be a table of functions like that,\n"..
		" - the second one must be the initial condition value. "..
		"It can also be a table of initial conditions,\n"..
		" - the third one must be the lower integration limit value,\n"..
		" - the fourth one must be the upper integration limit value, and\n"..
		" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"..
		" - the fifth, OPTIONAL, must be the integration incretement value(default = "..DELTA.." ).\n"
		error(str, 2)
	end
	if sizedata == 5 then
		delta = data[5]
	end

	if ( type( data[1] ) == "table" ) then
		if( #data[1] ~= #data[2] ) then 
			error("Error: You should provide the same number of differential equations and initial conditions.",2)
			return nil
		end
	end

	local y = INTEGRATION_METHOD(data[1], data[2], data[3], data[4], delta)

	if ( type( data[1] ) == "table" ) then

		local str = "return "..y[1]
		for i = 2, #y do
			str = str ..", "..y[i]
		end
		return load(str)()

	else
		return y
	end
end

--- A second order function to numerically solve ordinary differential equations with a given initial value.
-- @param attrs.method the name of a numeric algorithm to solve the ordinary differential equations in a given [a,b[  interval. See the options below.
-- @tab attrs.method
-- Method & Description \
-- "euler" (default) & Euler method \
-- "heun" & Heun (Second Order Euler) \
-- "rungekutta" & Runge-Kutta Method (Fourth Order)
-- @param attrs.equation A differential equation or a vector of differential equations. Each equation is described as a function of one or two parameters that returns a value of its derivative f(t, y), where t is the time instant, and y starts with the value of attribute initial and changes according to the result of f() and the chosen method. The calls to f will use the first parameter (t) in the interval [a,b[, according to the parameter step.
-- @param attrs.initial The initial condition, or a vector of initial conditions, which must be satisfied. Each initial condition represents the value of y when t (first parameter of f) is equal to the value of parameter a.  
-- @param attrs.a The beginning of the interval.
-- @param attrs.b The end of the interval.
-- @param attrs.step The step within the interval (optional, using 0.1 as default). It must satisfy the condition that (b - a) is a multiple of step.
-- @param attrs.event An Event, that can be used to set parameters a and b with values event:getTime() - event:getPeriodicity() and event:getTime(), respectively.  The period of the event must be a multiple of step. Note that the first execution of the event will compute the equation relative to a time interval between event.time - event.period and event.time. Be careful about that.
-- @usage v = integrate {
--     equation = function(t, y)
--         return t - 0.1 * y
--     end,
--     method = "euler",
--     initial = 0,
--     a = 0,
--     b = 100,
--     step = 0.1
-- }
integrate = function(attrs)
	if attrs.event ~= nil then
		attrs.a = attrs.event:getTime() - attrs.event:getPeriod() 
		if attrs.a < 1 then attrs.a = 1 end
		attrs.b = attrs.event:getTime()
	end

	if type(attrs.equation) == "table" then
		if type(attrs.initial) == "table" then
			if getn(attrs.equation) ~= getn(attrs.initial) then
				error("Error: Tables equation and initial shoud have the same size.", 2)
			end
		else
			error("Error: As equation is a table, initial should also be a table, got "..type(attrs.initial)..".", 2)
		end
	end

	if attrs.step == nil  then attrs.step = 0.1      end
	if attrs.method == nil then attrs.method = "euler" end

	local result = switch(attrs, "method"): caseof {
		["euler"] = function() return integrationEuler(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		["rungekutta"] = function() return integrationRungeKutta(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		["heun"] = function() return integrationHeun(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end
	}

	if type(attrs.equation) == "table" then
		local str = "return "..result[1]
		for i = 2, getn(attrs.equation) do
			str = str ..", "..result[i]
		end
		return load(str)()
	end
	return result
end

-- **********************************************************************************************
-- string distance 
function levenshtein(s, t)
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
			d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

-- **********************************************************************************************
-- TerraME syntactic sugar constructs

-- implements switch for lua
function switch(data, att)
	if (type(data) == "number") then
		local swtbl = {
			casevar = data,
			caseof = function(self, code)
				local f
				if (self.casevar) then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end

				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						error("Error: case "..tostring(self.casevar).." not a function")
					end
				end
			end
		}
		return swtbl
	else
		local swtbl = {
			casevar = data[att],
			caseof = function(self, code)
				local f
				if self.casevar then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end
				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						error("Error: case "..tostring(self.casevar).." should be a function.")
					end
				else
					local distance = string.len(self.casevar)
					local word
					forEachElement(code, function(a)
						local d = levenshtein(a, self.casevar) 
						if d < distance then
							distance = d
							word = a
						end
					end)
					if distance < string.len(self.casevar) * 0.6 then
						word = "'. Do you mean '"..word.."'?"
					else
						word = "'. It must be one of "
						forEachElement(code, function(a)
							word = word.."'"..a.."', "
						end)
						word = string.sub(word, 0, string.len(word) - 2).."."
					end
					error("Error: Invalid value for parameter "..att..": '"..self.casevar..word, 3)
				end
			end
		}
		return swtbl
	end
end

-- Attribute name suggestion based on levenshtein string distance
function suggest(typedValues, possibleValues)  
	local strMsg = ""  
	for k,v in pairs(typedValues) do
		local notCorrectParameters = {}
		local correctedSuggestions = {}    
		if(not contains(possibleValues, k)) then
			table.insert(notCorrectParameters,k)        
			local moreSimilar = "" 
			local moreSimilarDistance = 1000000          
			for j=1,#possibleValues do
				local distance = levenshtein(k, possibleValues[j])
				if(distance <= moreSimilarDistance) then
					moreSimilarDistance = distance
					moreSimilar = possibleValues[j]
				end
			end
			table.insert(correctedSuggestions, moreSimilar)
		end

		for i = 1, getn(notCorrectParameters), 1 do
			customWarningMsg("Warning: Attribute '".. notCorrectParameters[i] .."' not found. Did you mean '".. correctedSuggestions[i].."'?", 4)
		end
	end
end

function delay_s(delay)
	delay = delay or 1
	local time_to = os.time() + delay
	while os.time() < time_to do end
end

function euclideanDistance(cellA,cellB)
	return math.sqrt((cellA.x - cellB.x)^2 + (cellA.y - cellB)^2)
end

-- USER WARNING AND ERROR MESSSAGES FUNCTIONS
function randomValueWarningMsg(attr,usedRandomValue,level)
	if type(usedRandomValue) == nil then usedRandomValue = "nil" end
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		print(str..":".. info.currentline ..": Warning: Using random value '".. usedRandomValue .."' for parameter '".. attr .."'.")
	end
	io.flush()
end

function defaultValueWarningMsg(attr, expectedType, usedDefaultValue, level)
	if type(usedDefaultValue) == nil then usedDefaultValue = "nil" end
  if level == nil or type(level) ~= "number" or level ~= math.floor(level) then error("Error: Parameter #3 expected a positive integer number.", 2) end
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local t = type(usedDefaultValue)
		if t =="table" then
			usedDefaultValue = "table"
		elseif t == "boolean" then
			if usedDefaultValue then
				usedDefaultValue = "true"
			else
				usedDefaultValue = "false"
			end
		elseif t=="nil" then
			usedDefaultValue = "nil"
		end
		local str = string.match(info.short_src, "[^/]*$")
		print(str..":".. info.currentline ..": Warning: Parameter '".. attr .."' expected ".. expectedType ..". Using default value '".. usedDefaultValue .."'.")
  elseif TME_MODE == TME_EXECUTION_MODES.STRICT then
		error("Error: Parameter '".. attr .."' expected ".. expectedType ..".", level)    
	end
	io.flush()
end

function customErrorMsg(msg, level)
  if type(msg) ~= "string" then error("Error: Message should be a string.", 2) end
  if type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
    error("Error: Level should be a positive integer number.", 2)
  end
	error(msg, level)
end

function customWarningMsg(msg,level)
  if type(msg) ~= "string" then error("Error: Message should be a string.", 2) end
  if type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
    error("Error: Level should be a positive integer number.", 2)
  end
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")	  
		print(str..":".. info.currentline ..": "..msg)
	end
	io.flush()
end

function deniedOperationMsg(operation, level)
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")	
		print(str..":".. info.currentline ..": Warning: Could not complete operation '" .. operation.."'.")
	elseif TME_MODE == TME_EXECUTION_MODES.STRICT then
		error("Error: Could not complete operation '" .. operation.."'.",level)
	end
	io.flush()
end

function incompatibleTypesWarningMsg(attr, expectedTypesString,gottenType, level)
	if type(expectedValues) == nil then expectedValues = "nil" end
	if type(gottenValue) == nil then gottenValue = "nil" end

	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		print(str..":".. info.currentline ..": Warning: Incompatible types. Parameter '"..attr.."' expected ".. expectedTypesString ..", got ".. gottenType ..".")
		io.flush()
	elseif TME_MODE == TME_EXECUTION_MODES.STRICT then
		error("Error: Incompatible types. Parameter '"..attr.."' expected ".. expectedTypesString ..", got ".. gottenType ..".",level)
	end
	io.flush()  
end

function incompatibleTypesErrorMsg(attr, expectedTypesString,gottenType, level)
	if type(expectedTypesString) == nil then expectedTypesString = "nil" end
	if type(gottenType) == nil then gottenType = "nil" end
	error("Error: Incompatible types. Parameter '"..attr.."' expected ".. expectedTypesString ..", got ".. gottenType ..".",level)
	io.flush()
end

function incompatibleValuesWarningMsg(attr, expectedValues, gottenValue, level)
	if type(expectedValues) == nil then expectedValues = "nil" end
	if type(gottenValue) == nil then gottenValue = "nil" end
  if level == nil or type(level) ~= "number" or level ~= math.floor(level) then
    error("Error: Level expected a positive integer number.", 2)
  end
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		print(str..":".. info.currentline ..": Warning: Incompatible values. Parameter '".. attr .."' expected ".. expectedValues ..", got '".. gottenValue .."'.")
	elseif TME_MODE == TME_EXECUTION_MODES.STRICT then
		error("Error: Incompatible types. Parameter '"..attr.."' expected ".. expectedValues ..", got '".. gottenValue .."'.",level)
	end
	io.flush()
end

function incompatibleValuesErrorMsg(attr, expectedValues, gottenValue, level)
	if type(expectedValues) == nil then expectedValues = "nil" end
	if type(gottenValue) == nil then gottenValue = "nil" end
	error("Error: Incompatible values. Parameter '"..attr.."' expected ".. expectedValues ..", got ".. gottenValue ..".",level)
	io.flush()
end

function incompatibleFileExtensionErrorMsg(attr,ext, level)
	error("Error: Parameter '".. attr .."' does not support '"..ext.."'.",level)
	io.flush() 
end

function resourceNotFoundErrorMsg(attr, path, level)
	error("Error: Resource '"..path.."' not found for parameter '"..attr.."'.",level)
	io.flush()
end

function valueNotFoundErrorMsg(attr, value, level)
	if type(value) == nil then value = "nil" end
	error("Error: Value '"..value.."' not found for parameter '"..attr.."'.",level)
	io.flush()
end

function valueNotFoundWarningMsg(attr, value, level)
	if type(value) == nil then value = "nil" end
	if TME_MODE == TME_EXECUTION_MODES.DEBUG then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")  
		print(str..":".. info.currentline ..": Warning: Value '"..value.."' not found for parameter '"..attr.."'.") 
	elseif TME_MODE == TME_EXECUTION_MODES.STRICT then
		error("Error: Value '"..value.."' not found for parameter '"..attr.."'.",level)
	end
	io.flush()
end

function mandatoryArgumentErrorMsg(attr, level)
	error("Error: Parameter '"..attr.."' is mandatory.",level)
	io.flush()
end
-- fim Utils.lua
--############################################################
--Utilities functions---------------------------------------------------
function coordCoupling(cs1, cs2, name)
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

function createMooreNeighborhood(cs, name, self, wrap)
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
function createVonNeumannNeighborhood(cs, name, self, wrap)
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
function createNeighborhood(cs, filterF, weightF, name)
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
function createMxNNeighborhood(cs, m, n, filterF, weightF, name)
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
function spatialCoupling(m, n, cs1, cs2, filterF, weightF, name)
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


-- Traverses "cs" applying the "f(cell)" function to each cell
---Second order function to transverse a given CellularSpace, applying a given
--function on each of its Cells. It returns true if no call to the function taken as
--argument returns false.
-- @param cs A CellularSpace, Trajectory, or Agent. Agents need to have a placement in order to execute this function.
-- @param f A function that takes a Cell as argument. If it returns false when processing a given Cell, forEachCell() stops and does not process any other Cell.
-- @usage forEachCell(cellularspace, function(cell)
--     cell.water = cell.water + 1
-- end)
-- @see Environment:createPlacement
function forEachCell(cs, f)
	local t = type(cs)
	if t ~= "CellularSpace" and t ~= "Trajectory" and t ~= "Agent" then
		customErrorMsg("Error: First parameter should be a CellularSpace, a Trajectory, or an Agent, got "..t..".", 2)
	end
	if type(f) ~= "function" then
		customErrorMsg("Error: Second parameter should be a function, got "..type(f)..".", 2)
	end
	for i, cell in ipairs(cs.cells) do
		result = f(cell, i)
		if result == false then return false end
	end
	return true
end

-- Traverses the cellular spaces "cs1" and "cs2" applying the 
-- "f(cell1, cell2)" function to each correspondent cell pair.
-- "cell1" belongs to "cs1" and "cell2" belongs to "cs2".
-- The cellular spaces must have the same size.
---Second order function to transverse two CellularSpaces with the same resolution
--and number of Cells, applying a function that receives as argument two Cells, one
--from each CellularSpace, that share the same (x, y). It returns true if no call to the
--function taken as argument returns false.
-- @param cs1 A CellularSpace.
-- @param cs2 Another CellularSpace.
-- @param f A function that takes two Cells as arguments, one coming from cs1 and the other from cs2. If some call returns false, forEachCellPair() stops and does not process any other pair of Cells.
-- @usage forEachCellPair(cs1, cs2, function(cell1, cell2)
--     cell1.water = cell1.water + cell2.water
--     cell2.water = 0
-- end)
function forEachCellPair(cs1, cs2, f)
	for i, cell1 in ipairs(cs1.cells) do
		cell2 = cs2.cells[i]
		result = f(cell1, cell2, i)
		if result == false then return false end
	end
	return true
end

-- Transverse the neighborhood "index" from cell "cell" applying the
-- function "f( cell, neigh, weight )" to each neighbor.
---Second order function to transverse a given Neighborhood of a Cell, applying a
--function in each of its neighbors. It returns true if no call to the function taken as
--argument returns false. There are two ways of using this function because the
--second argument is optional.
--@param cell A Cell.
--@param index (Optional) A string with the name of the Neighborhood to be transversed.
--Default is "neigh1".
--@param f A function that takes three arguments: the Cell itself, the neighbor Cell, and the connection weight. If some call to f returns false, forEachNeighbor() stops and does not process any other neighbor. In the case where the second argument is missing, this function becomes the second argument.
--@usage forEachNeighbor(cell, function(cell, neighbor)
--     if neighbor.deforestation > 0.9 then
--         cell.deforestation = cell.deforestation * 1.01
--     end
-- end)
--
-- neigh_deforestation = 0
-- forEachNeighbor(cell, "roads", function(cell, neighbor)
--     neigh_deforestation = neigh_deforestation + neighbor.deforestation
-- end)
--@see CellularSpace:createNeighborhood
--@see CellularSpace:loadNeighborhood
function forEachNeighbor(cell, index, f)
	if type(index) == "function" then
		f = index
		--index = "1"
		index = "neigh1"
	end

	if type(cell) ~= "Cell" then
		incompatibleTypesErrorMsg("cell","Cell",type(cell),3)
	end
	if type(f) ~= "function" then
		incompatibleTypesErrorMsg("f","function",type(f),3)
	end
	local neighborhood = cell:getNeighborhood(index)
	if neighborhood == nil then return false; end
	neighborhood:first()
	while not neighborhood:isLast() do
		neigh = neighborhood:getNeighbor()
		weight = neighborhood:getWeight()
		result = f(cell, neigh, weight)
		if result == false then return false end
		neighborhood:next()
	end
	return true
end

-- Transverse all neighborhoods from a Cell applying the
-- function  to each neighborhood.
---Second order function to transverse all Neighborhoods of a Cell, applying a given function on them. It returns true if no call to the function taken as argument returns false.
--@param cell A Cell.
--@param f A function that receives a Neighborhood as parameter.
--@usage forEachNeighborhood(cell, function(neighborhood)
--     print(neighborhood:getId())
-- end)
function forEachNeighborhood(cell, f)
	cell:first()
	while not cell:isLast() do
		local nh = cell:getCurrentNeighborhood()
		result = f(nh)
		if result == false then return false end
		cell:next()
	end
	return true
end

--- Second order function to transverse the connections of a given Agent, applying a function to each of them. It returns true if no call to the function taken as argument returns false. There are two ways of using this function because the second argument is optional.
-- @param agent An Agent.
-- @param index A string with the name of the SocialNetwork to be transversed. Default is "sntw1".
-- @param f A function that takes three arguments: the Agent itself, its connection, and the connection weight. If some call to f returns false, forEachConnection() stops and does not process any other connection. In the case where the second argument is missing, this function becomes the second argument.
-- @usage forEachConnection(agent, function(agent, connection, weight)
--     agent:message {
--         receiver = connection,
--         content = "sugar",
--         quantity = 2 * weight
--     }
-- end)
--
-- sugarfriends = 0
-- forEachConnection(agent, "friends", function(agent, friend)
--     sugarfriends = sugarfriends + friend.sugar
-- end)
-- @see Society:createSocialNetwork
function forEachConnection(agent, index, f)
	if type(index) == "function"  then
		f = index
		index = "sntw1"
	elseif type(f) ~= "function" then
		customErrorMsg("Error: Last parameter should be a function, got "..type(f)..".", 3)
	end

	if type(agent) ~= "Agent" then
		customErrorMsg("Error: First parameter should be an Agent, got "..type(f)..".", 3)
	end

	local socialnetwork = agent:getSocialNetwork(index)
	if not socialnetwork then
		customErrorMsg("Error: Agent does not have a SocialNetwork named "..index, 3)
	end
	for index, connection in pairs(socialnetwork.connections) do
		weight = socialnetwork.weights[index]
		result = f(agent, connection, weight)
		if result == false then return false end
	end
	return true
end

--- Second order function to traverse a Society, Group, or Cell, applying a function to each of its agents.
-- It returns true if no call to the function taken as argument returns false.
-- @param obj A Society, Group, or Cell. Cells need to have a placement in order to execute this function.
-- @param func A function that takes one single Agent as argument. If some call to it returns false, forEachAgent() stops and does not process any other Agent.
-- @usage forEachAgent(group, function(agent)
--     agent.age = agent.age + 1
-- end)
-- @see Environment:createPlacement
function forEachAgent(obj, func)
	local t = type(obj)
	if t ~= "Society" and t ~= "Cell" and t ~= "Group" then
		incompatibleTypesErrorMsg("1", "Society, Group, or Cell", t, 3)
	end
	local ags = obj.agents
	if ags == nil then 
		customErrorMsg("Error: Could not get agents from the Society", 3)
	end
	-- forEachAgent needs to be different from the other forEachs because the
	-- ageng can die along its own execution and it shifts back all the other
	-- agents in society.agents. If ipairs was used instead, forEach would
	-- skip the next agent of the vector after the removed agent.
	local k = 1
	for i = 1,#ags do
		local ag = ags[k]
		if ag and func(ag) == false then return false end
		if ag == ags[k] then k = k + 1 end
	end
	return true
end

---Return a function that compares two tables (which can be, for instance, Agents or Cells). The function returns which one has a priority over the other, according to an attribute of the objects and a given operator. If the function was not built successfully it returns nil.
--@param attribute A string with the name of the attribute.
--@param operator A string with the operator, which can be ">", "<", "<=", or ">=". Default is "<".
-- @usage t = Trajectory {
--     target = cs,
--     sort = greaterByAttribute("cover")
-- }

greaterByAttribute = function(attribute, operator)
	if operator == nil then operator = "<" end
	if(not attribute) then
		incompatibleTypesErrorMsg("attribute","string",type(attribute), 4)
		return nil
	end
	str = "return function(o1, o2) return o1."..attribute.." "..operator.." o2."..attribute.." end"
	return load(str)()
end

---Return a function that compares two tables with x and y attributes (basically two regular Cells). The function returns which one has a priority over the other, according to a given operator.
--@param operator A string with the operator, which can be ">", "<", "<=", or ">=". Default is "<".
--@usage t = Trajectory {
--     target = cs,
--     sort = greaterByCoord()
-- }
greaterByCoord = function(operator)
	if operator == nil then operator = "<" end
	str = "return function(a,b)\n"
	str = str .. "if a.x"..operator.."b.x then return true end\n"
	str = str .. "if a.x == b.x and a.y"..operator.."b.y then return true end\n"
	str = str .. "return false end"	
	return load(str)()
end

---Convert the position where the Cell is stored in the CellularSpace's vector of Cells into two values (x, y). They represent the position of the Cell in a squared and regular CellularSpace.
-- @param idx The position of the Cell in the vector of Cells.
-- @param xMax Number of columns of the CellularSpace.
-- @usage mx, my = index2coord(7, 10)
-- c = Coord{x = mx, y = my}
-- cs:getCell(c).value = 3
-- print(cs.cells[7].value) -- 3
function index2coord(idx, xMax)
	local term = math.floor((idx-1)/(xMax+1))
	local y =(idx-1) - xMax*term
	local x = term
	return x, y
end

---Convert a pair (x, y), which represents a position in a squared and regular CellularSpace, into the position where the Cell is stored in the CellularSpace's vector of Cells.
-- @param x The x position.
-- @param y The y position.
-- @param xMax Number of columns of the CellularSpace. This value must be greater than the second parameter.
-- @usage cs = CellularSpace{xdim = 10, ydim = 10}
-- idx = coord2index(2, 3, 10)
-- c = Coord{x = 2, y = 3}
-- cs:getCell(c).value = 3
-- print(cs.cells[idx].value) -- 3
function coord2index(x, y, xMax)
	return (y + 1) + x * xMax 
end

---Second order function to transverse a given object, applying a function to each of its elements. It can be used for instance to trasverse all the elements of an Agent or an Enviroment. It returns true if no call to the function taken as argument returns false.
-- @param obj A TerraME object or a table.
-- @param func A function that takes three arguments: the index of the element, the element itself, and the type of the element.
-- @usage forEachElement(agent, print)
-- 
-- forEachElement(cell, function(idx, element, etype)
--     print(element, etype)
-- end)
forEachElement = function(obj, func)
	for k, ud in pairs(obj) do
		local t = type(ud)
		func(k, ud, t)
	end
end

-- Format time of CPU utilization in (days:hours:minutes:seconds)
---Convert the time from the os library to a more readable value, a string in the format "hours:minutes:seconds", or "days:hours:minutes:seconds" if the elapsed time is more than one day.
-- @param s A number to be converted.
-- @usage print(elapsedTime(100)) -- 00:01:40
function elapsedTime(s)
	local floor = math.floor
	local seconds = s
	local minutes = floor(s / 60);     seconds = floor(seconds % 60)
	local hours = floor(minutes / 60); minutes = floor(minutes % 60)
	local days = floor(hours / 24);    hours = floor(hours % 24)

	if days > 0 then
		return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
	else
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	end
end

-- extents to the string class
-- TODO
-- @param self TODO
-- @param send TODO
-- @return TODO
function string.endswith(self, send)
	return #self >= #send and self:find(send, #self-#send+1, true) and true or false
end

-- extents to table class
-- TODO
-- @param t TODO
-- @param value TODO
function contains(t,value)
	if(t == nil) then return false end
	for _,v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false  
end

-- substitute for table.getn
-- TODO
-- @para t TODO
-- @return TODO
function getn(t)
	local n = 0
	for k, v in pairs(t) do
		n = n +1
	end
	return n
end


--############################################################
type__ = type


--- Return the type of an object. It extends the original Lua type() to support TerraME objects, whose type name (for instance "CellularSpace" or "Agent") is returned instead of "table".
-- @param data Any object or value.
-- @usage c = Cell{value = 3}
-- print(type(c)) -- "Cell"
type = function(data)
	local t = type__(data)
	if t == "table" then
		if data.type_ ~= nil then
			return data.type_
		else
			return "table"
		end
	else
		return t
	end
end

--Extra
dofile(TME_LUA_PATH .. "//Random.lua")

-- THIS A GLOBAL RANDOM OBJECT
TME_GLOBAL_RANDOM = Random { seed = os.time() }

dofile(TME_LUA_PATH .. "//Legend.lua")
dofile(TME_LUA_PATH .. "//Observer.lua")
dofile(TME_LUA_PATH .. "//SocialNetwork.lua")
dofile(TME_LUA_PATH .. "//Society.lua")
dofile(TME_LUA_PATH .. "//Group.lua")

-- KERNEL'S COMPONENTS 

--Space ----------------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Coord.lua")
dofile(TME_LUA_PATH .. "//Cell.lua")
dofile(TME_LUA_PATH .. "//CellularSpace.lua")
dofile(TME_LUA_PATH .. "//Neighborhood.lua")

--Time -----------------------------------------------------------------------------------
-- The constructor Event, differently of the others, does not return a table.
-- Instead, it returns a C++ object TeEvent. This makes sense since there is 
-- no meaning on the modeller's command: ev.time = 1. This because any attribute of
-- an Event is controled by the C++ simulation engine, including the attribute ev.time.
dofile(TME_LUA_PATH .. "//Pair.lua")
dofile(TME_LUA_PATH .. "//Event.lua")
dofile(TME_LUA_PATH .. "//Action.lua")
dofile(TME_LUA_PATH .. "//Timer.lua")

--Behavior -------------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Jump.lua")
dofile(TME_LUA_PATH .. "//Flow.lua")
dofile(TME_LUA_PATH .. "//State.lua")
dofile(TME_LUA_PATH .. "//Automaton.lua")
dofile(TME_LUA_PATH .. "//Agent.lua")
dofile(TME_LUA_PATH .. "//Trajectory.lua")

--Evironment -----------------------------------------------------------------------------
dofile(TME_LUA_PATH .. "//Environment.lua")
