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
--          Antonio Jose da Cunha Rodrigues
--          Raian Vargas Maretto
-------------------------------------------------------------------------------------------

--@header Some basic and useful functions for modeling.

if os.setlocale(nil, "all") ~= "C" then os.setlocale("C", "numeric") end

if sessionInfo().path == nil or sessionInfo().path == "" then
	error("Error: TME_PATH environment variable should exist and point to TerraME installation folder.", 2)
end

-- To keep compatibilities with old versions of Lua
local load = load
if _VERSION ~= "Lua 5.2" then
	load = loadstring
end	

-- **********************************************************************************************
-- util math functions

-- rounds a number given its value and a precision
-- TODO: add error messages for this function
function round(num, idp)
	local mult = 10 ^ (idp or 0)
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
			local y1 = {}
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
				values[i] = df[i](x, y)
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

	if type(data[1]) == "table" then
		if #data[1] ~= #data[2] then 
			customErrorMsg("You should provide the same number of differential equations and initial conditions.", 2)
		end
	end

	local y = INTEGRATION_METHOD(data[1], data[2], data[3], data[4], delta)

	if type(data[1]) == "table" then
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
-- @param attrs.method the name of a numeric algorithm to solve the ordinary differential equations in a given [a,b[ interval. See the options below.
-- @tab method
-- Method & Description \
-- "euler" (default) & Euler method \
-- "heun" & Heun (Second Order Euler) \
-- "rungekutta" & Runge-Kutta Method (Fourth Order)
-- @param attrs.equation A differential equation or a vector of differential equations. Each equation is described as a function of one or two parameters that returns a value of its derivative f(t, y), where t is the time instant, and y starts with the value of attribute initial and changes according to the result of f() and the chosen method. The calls to f will use the first parameter (t) in the interval [a,b[, according to the parameter step.
-- @param attrs.initial The initial condition, or a vector of initial conditions, which must be satisfied. Each initial condition represents the value of y when t (first parameter of f) is equal to the value of parameter a.
-- @param attrs.a The beginning of the interval.
-- @param attrs.b The end of the interval.
-- @param attrs.step The step within the interval (optional, using 0.1 as default). It must satisfy the condition that (b - a) is a multiple of step.
-- @param attrs.event An Event, that can be used to set parameters a and b with values event:getTime() - event:getPeriodicity() and event:getTime(), respectively. The period of the event must be a multiple of step. Note that the first execution of the event will compute the equation relative to a time interval between event.time - event.period and event.time. Be careful about that.
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
				customErrorMsg("Tables equation and initial shoud have the same size.", 2)
			end
		else
			customErrorMsg("As equation is a table, initial should also be a table, got "..type(attrs.initial)..".", 2)
		end
	end

	if attrs.step == nil then attrs.step = 0.1 end
	if attrs.method == nil then attrs.method = "euler" end

	local result = switch(attrs, "method"): caseof {
		euler = function() return integrationEuler(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		rungekutta = function() return integrationRungeKutta(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end,
		heun = function() return integrationHeun(attrs.equation, attrs.initial, attrs.a, attrs.b, attrs.step) end
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
-- TODO: add error messages for this function
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

function switch(data, att)
	if type(data) == "number" then
		local swtbl = {
			casevar = data,
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
						customErrorMsg("Case "..tostring(self.casevar).." not a function.", 2)
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
						customErrorMsg("Case "..tostring(self.casevar).." should be a function.", 2)
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
						word = "Do you mean '"..word.."'?"
					else
						word = "It must be a string from the set ["
						forEachOrderedElement(code, function(a)
							word = word.."'"..a.."', "
						end)
						word = string.sub(word, 0, string.len(word) - 2).."]."
					end
					customErrorMsg("'"..self.casevar.."' is an invalid value for parameter '"..att.."'. "..word, 3)
				end
			end
		}
		return swtbl
	end
end

-- Attribute name suggestion based on levenshtein string distance
function suggest(typedValues, possibleValues)
	local strMsg = ""
	for k, v in pairs(typedValues) do
		local notCorrectParameters = {}
		local correctedSuggestions = {}
		if not belong(k, possibleValues) then
			table.insert(notCorrectParameters,k)
			local moreSimilar = "" 
			local moreSimilarDistance = 1000000
			for j = 1, #possibleValues do
				local distance = levenshtein(k, possibleValues[j])
				if distance <= moreSimilarDistance then
					moreSimilarDistance = distance
					moreSimilar = possibleValues[j]
				end
			end
			table.insert(correctedSuggestions, moreSimilar)
		end

		for i = 1, getn(notCorrectParameters) do
 			local dst = levenshtein(notCorrectParameters[i], correctedSuggestions[i])
 			if dst < math.floor(#notCorrectParameters[i] * 0.6) then
 				customWarningMsg("Attribute '".. notCorrectParameters[i] .."' not found. Do you mean '".. correctedSuggestions[i].."'?", 4)
 			end
		end
	end
end

function delay(delay_s)
	delay_s = delay_s or 1
	local time_to = os.time() + delay_s
	while os.time() < time_to do end
end

function belong(value, values)
	if type(values) ~= "table" then
		incompatibleTypesErrorMsg("#2", "table", type(values), 2)
	end

	if values == nil then return false end
	local found = false
	forEachElement(values, function(_, mvalue)
		if mvalue == value then
			found = true
			return false
		end
	end)
	return found
end

-- TODO: think about this kind of function. Today it is only used by Model.
verify = function(condition, msg)
	if not condition then
		customErrorMsg(msg, 3)
	end
end

function checkUnnecessaryParameters(data, parameters, level)
	forEachElement(data, function(value)
		if not belong(value, parameters) then
			customWarningMsg("Parameter '"..value.."' is unnecessary.", level + 3)
		end
	end)
end

function customErrorMsg(msg, level)
	if type(msg) ~= "string" then
		error("Error: #1 should be a string.", 2)
	elseif type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
		error("Error: #2 should be a positive integer number.", 2)
	end
	error("Error: "..msg, level)
end

function customWarningMsg(msg,level)
	if type(msg) ~= "string" then
		error("Error: #1 should be a string.", 2)
	elseif type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
		error("Error: #2 should be a positive integer number.", 2)
	elseif sessionInfo().mode == "normal" then
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		print(str..":".. info.currentline ..": Warning: "..msg)
	elseif sessionInfo().mode == "debug" then
		customErrorMsg(msg, level + 1)
	end
	io.flush()
end

function defaultValueWarningMsg(parameter, value, level)
	if type(parameter) ~= "string" then
		error("Error: #1 should be a string.", 2)
	elseif type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
		error("Error: #2 should be a positive integer number.", 2)
	end

	customWarningMsg("Parameter '"..parameter.."' could be removed as it is the default value ("..value..").", level + 1)
end

function deprecatedFunctionWarningMsg(functionName, functionExpected, level)
	if type(functionName) ~= "string" then
		error("Error: #1 should be a string.", 2)
	end

	if type(functionExpected) ~= "string" then
		error("Error: #2 should be a string.", 2)
	end

	if type(level) ~= "number" or level < 0 or math.floor(level) ~= level then
		error("Error: #3 should be a positive integer number.", 2)
	end

	local text = "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
	customWarningMsg(text, level + 1)
end

function incompatibleTypesErrorMsg(attr, expectedTypesString, gottenType, level)
	if expectedTypesString == nil then expectedTypesString = "nil" end
	if gottenType == nil then gottenType = "nil" end

	local text = "Incompatible types. Parameter '"..attr.."' expected "..
		expectedTypesString..", got "..gottenType.."."

	customErrorMsg(text, level + 1)
end

function incompatibleValuesErrorMsg(attr, expectedValues, gottenValue, level)
	if expectedValues == nil then expectedValues = "nil" end

	local msg = "Incompatible values. Parameter '"..attr.."' expected ".. expectedValues ..", got "
	if type(gottenValue) == "string" then
		msg = msg.."'"..gottenValue.."'."
	elseif gottenValue == nil then
		msg = msg.."nil."
	else
		msg = msg..gottenValue.."."
	end
	customErrorMsg(msg, level + 1)
end

function incompatibleFileExtensionErrorMsg(attr, ext, level)
	customErrorMsg("Parameter '".. attr .."' does not support '"..ext.."'.", level + 1)
end

function resourceNotFoundErrorMsg(attr, path, level)
	customErrorMsg("Resource '"..path.."' not found for parameter '"..attr.."'.",level + 1)
end

function valueNotFoundErrorMsg(attr, value, level)
	if type(value) == nil then value = "nil" end
	customErrorMsg("Value '"..value.."' not found for parameter '"..attr.."'.",level + 1)
end

function mandatoryArgumentErrorMsg(attr, level)
	customErrorMsg("Parameter '"..attr.."' is mandatory.", level + 1)
end

function namedParametersErrorMsg(funcName, level)
	customErrorMsg("Parameters for '"..funcName.."' must be named.", level + 1)
end

function tableParameterErrorMsg(funcName, level)
	customErrorMsg("Parameter for '"..funcName.."' must be a table.", level + 1)
end

--############################################################
--Utilities functions---------------------------------------------------

--- Second order function to transverse a given CellularSpace, Trajectory, or Agent, 
-- applying a given function on each of its Cells. If any of the function calls returns 
-- false, forEachCell() stops and returns false, otherwise it returns true.
-- @param cs A CellularSpace, Trajectory, or Agent. Agents need to have a placement 
-- in order to execute this function.
-- @param f A user-defined function that takes a Cell as argument. 
-- It can optionally have a second argument with a positive number representing the  position of
-- the Cell in the vector of Cells. If it returns false when processing a given Cell, 
-- forEachCell() stops and does not process any other Cell.
-- @usage forEachCell(cellularspace, function(cell)
--     cell.water = cell.water + 1
-- end)
--
-- forEachCell(cellularspace, function(cell, i)
--     print(i) -- 1, 2, 3, ...
-- end)
-- @see Environment:createPlacement
function forEachCell(cs, f)
	local t = type(cs)
	if t ~= "CellularSpace" and t ~= "Trajectory" and t ~= "Agent" then
		incompatibleTypesErrorMsg("#1", "CellularSpace, Trajectory, or Agent", t, 3)
	end
	if type(f) ~= "function" then
		incompatibleTypesErrorMsg("#2", "function", type(f), 3)
	end
	for i, cell in ipairs(cs.cells) do
		result = f(cell, i)
		if result == false then return false end
	end
	return true
end

--- Second order function to transverse two CellularSpaces with the same resolution and
-- number of Cells. It applies a function that receives as argument two Cells, one from each
-- CellularSpace, that share the same (x, y). The cellular spaces must have the same size.
-- It returns true if no call to the function taken as argument returns false.
-- @param cs1 A CellularSpace.
-- @param cs2 Another CellularSpace.
-- @param f A user-defined function that takes two Cells as arguments, one coming from #1 
-- and the other from #2. If some call returns false, forEachCellPair() stops and does not 
-- process any other pair of Cells.
-- @usage forEachCellPair(cs1, cs2, function(cell1, cell2)
--     cell1.water = cell1.water + cell2.water
--     cell2.water = 0
-- end)
function forEachCellPair(cs1, cs2, f)
	if type(cs1) ~= "CellularSpace" then
		incompatibleTypesErrorMsg("#1", "CellularSpace", type(cs1), 3)
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypesErrorMsg("#2", "CellularSpace", type(cs2), 3)
	elseif type(f) ~= "function" then
		incompatibleTypesErrorMsg("#3", "function", type(f), 3)
	end

	for i, cell1 in ipairs(cs1.cells) do
		local cell2 = cs2.cells[i]
		result = f(cell1, cell2, i)
		if result == false then return false end
	end
	return true
end

---Second order function to transverse a given Neighborhood of a Cell, applying a
--function in each of its neighbors. It returns true if no call to the function taken as
--argument returns false. There are two ways of using this function because the
--second argument is optional.
--@param cell A Cell.
--@param index (Optional) A string with the name of the Neighborhood to be transversed.
--Default is "1".
-- @param f A user-defined function that takes three arguments: the Cell itself, the neighbor
-- Cell, and the connection weight. If some call to it returns false, forEachNeighbor() stops
-- and does not process any other neighbor. In the case where the second argument is missing,
-- this function becomes the second argument.
--@usage forEachNeighbor(cell, function(cell, neighbor)
--     if neighbor.deforestation > 0.9 then
--         cell.deforestation = cell.deforestation * 1.01
--     end
-- end)
--
-- neigh_deforestation = 0
-- forEachNeighbor(cell, "roads", function(cell, neighbor, weight)
--     neigh_deforestation = neigh_deforestation + neighbor.deforestation * weight
-- end)
--@see CellularSpace:createNeighborhood
--@see CellularSpace:loadNeighborhood
function forEachNeighbor(cell, index, f)
	if type(cell) ~= "Cell" then
		incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
	end

	if type(index) == "function" then
		f = index
		index = "1"
	elseif type(index) ~= "string" then
		incompatibleTypesErrorMsg("#2", "function or string", type(index), 3)
	elseif type(f) ~= "function" then
		incompatibleTypesErrorMsg("#3", "function", type(f), 3)
	end
	local neighborhood = cell:getNeighborhood(index)
	if neighborhood == nil then
		customErrorMsg("Neighborhood '"..index.."' does not exist.", 3)
	end
	neighborhood.cObj_:first()
	while not neighborhood.cObj_:isLast() do
		local neigh = neighborhood.cObj_:getNeighbor()
		local weight = neighborhood.cObj_:getWeight()
		local result = f(cell, neigh, weight)
		if result == false then return false end
		neighborhood.cObj_:next()
	end
	return true
end

--- Second order function to transverse all Neighborhoods of a Cell, applying a given function
-- on them. It returns true if no call to the function taken as argument returns false.
--@param cell A Cell.
--@param f A function that receives a Neighborhood as parameter.
--@usage forEachNeighborhood(cell, function(neighborhood)
--     print(neighborhood:getId())
-- end)
function forEachNeighborhood(cell, f)
	if type(cell) ~= "Cell" then
		incompatibleTypesErrorMsg("#1", "Cell", type(cell), 3)
	end
	if type(f) ~= "function" then
		incompatibleTypesErrorMsg("#2", "function", type(f), 3)
	end

	cell.cObj_:first()
	while not cell.cObj_:isLast() do
		local nh = cell.cObj_:getCurrentNeighborhood()
		result = f(nh)
		if result == false then return false end
		cell.cObj_:next()
	end
	return true
end

--- Second order function to transverse the connections of a given Agent, applying a function to
-- each of them. It returns true if no call to the function taken as argument returns false.
-- There are two ways of using this function because the second argument is optional.
-- @param agent An Agent.
-- @param index A string with the name of the SocialNetwork to be transversed. Default is "1".
-- @param f A function that takes three arguments: the Agent itself, its connection, and the
-- connection weight. If some call to f returns false, forEachConnection() stops and does not
-- process any other connection. In the case where the second argument is missing, this
-- function becomes the second argument.
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
	if type(agent) ~= "Agent" then
		incompatibleTypesErrorMsg("#1", "Agent", type(agent), 3)
	end

	if type(index) == "function" then
		f = index
		index = "1"
	elseif type(index) ~= "string" then
		incompatibleTypesErrorMsg("#2", "function or string", type(index), 3)
	elseif type(f) ~= "function" then
		incompatibleTypesErrorMsg("#3", "function", type(f), 3)
	end

	local socialnetwork = agent:getSocialNetwork(index)
	if not socialnetwork then
		customErrorMsg("Agent does not have a SocialNetwork named '"..index.."'.", 3)
	end
	for index, connection in pairs(socialnetwork.connections) do
		local weight = socialnetwork.weights[index]
		local result = f(agent, connection, weight)
		if result == false then return false end
	end
	return true
end

--- Second order function to traverse a Society, Group, or Cell, applying a function to each of
-- its agents. It returns true if no call to the function taken as argument returns false.
-- @param obj A Society, Group, or Cell. Cells need to have a placement in order to execute
-- this function.
-- @param func A function that takes one single Agent as argument. If some call to it returns
-- false, forEachAgent() stops and does not process any other Agent. 
-- This function can optionally get a second argument with a positive number representing the
-- position of the agent in the vector of Agents.
-- @usage forEachAgent(group, function(agent)
--     agent.age = agent.age + 1
-- end)
-- @see Environment:createPlacement
function forEachAgent(obj, func)
	local t = type(obj)
	if t ~= "Society" and t ~= "Cell" and t ~= "Group" then
		incompatibleTypesErrorMsg("#1", "Society, Group, or Cell", t, 3)
	end

	if type(func) ~= "function" then
		incompatibleTypesErrorMsg("#2", "function", type(func), 3)
	end

	local ags = obj.agents
	if ags == nil then 
		customErrorMsg("Could not get agents from the "..type(obj)..".", 3)
	end
	-- forEachAgent needs to be different from the other forEachs because the
	-- ageng can die along its own execution and it shifts back all the other
	-- agents in society.agents. If ipairs was used instead, forEach would
	-- skip the next agent of the vector after the removed agent.
	local k = 1
	for i = 1,#ags do
		local ag = ags[k]
		if ag and func(ag, i) == false then return false end
		if ag == ags[k] then k = k + 1 end
	end
	return true
end

--- Return a function that compares two tables (which can be, for instance, Agents or Cells).
-- The function returns which one has a priority over the other, according to an attribute of the
-- objects and a given operator. If the function was not built successfully it returns nil.
--@param attribute A string with the name of the attribute.
--@param operator A string with the operator, which can be ">", "<", "<=", or ">=". Default is "<".
-- @usage t = Trajectory {
--     target = cs,
--     sort = greaterByAttribute("cover")
-- }
greaterByAttribute = function(attribute, operator)
	if operator == nil then
		operator = "<"
	elseif not belong(operator, {"<", ">", "<=", ">="}) then
		incompatibleValuesErrorMsg("#2", "<, >, <=, or >=", operator, 3)
	end

	if type(attribute) ~= "string" then
		incompatibleTypesErrorMsg("attribute", "string", type(attribute), 3)
	end
	local str = "return function(o1, o2) return o1."..attribute.." "..operator.." o2."..attribute.." end"
	return load(str)()
end

--- Return a function that compares two tables with x and y attributes (basically two regular
-- Cells). The function returns which one has a priority over the other, according to a given
-- operator.
--@param operator A string with the operator, which can be ">", "<", "<=", or ">=". Default is "<".
--@usage t = Trajectory {
--     target = cs,
--     sort = greaterByCoord()
-- }
greaterByCoord = function(operator)
	if operator == nil then
		operator = "<"
	elseif not belong(operator, {"<", ">", "<=", ">="}) then
		incompatibleValuesErrorMsg("#1", "<, >, <=, or >=", operator, 3)
	end

	local str = "return function(a,b)\n"
	str = str .. "if a.x"..operator.."b.x then return true end\n"
	str = str .. "if a.x == b.x and a.y"..operator.."b.y then return true end\n"
	str = str .. "return false end"	
	return load(str)()
end

--- Second order function to transverse a given object, applying a function to each of its
-- elements. It can be used for instance to trasverse all the elements of an Agent or an
-- Environment. It returns true if no call to the function taken as argument returns false.
-- @param obj A TerraME object or a table.
-- @param func A user-defined function that takes three arguments: the index of the element,
-- the element itself, and the type of the element. If some call to this function returns
-- false then forEachElement() stops.
-- @usage forEachElement(cell, function(idx, element, etype)
--     print(element, etype)
-- end)
forEachElement = function(obj, func)
	if obj == nil then mandatoryArgumentErrorMsg("#1", 2) end
	if func == nil then mandatoryArgumentErrorMsg("#2", 2) end

	if type(func) ~= "function" then
		incompatibleTypesErrorMsg("#2", "function", type(func), 2)
	end

	for k, ud in pairs(obj) do
		local t = type(ud)
		func(k, ud, t)
	end
end

--TODO: esta funcao ignora elementos que possuem o mesmo lower case (ex: aAa e aaa). Tratar este caso.
forEachOrderedElement = function(obj, func)
	if obj == nil then mandatoryArgumentErrorMsg("#1", 2) end

	if type(func) ~= "function" then
		incompatibleTypesErrorMsg("#2", "function", type(func), 2)
	end

	local strk

	local order = {}
	local reference = {}
	for k, ud in pairs(obj) do
		strk = tostring(k):lower()
		order[#order + 1] = strk
		reference[strk] = k
	end

	table.sort(order)

	for k = 1, #order do
		local idx = reference[order[k]]
		if func(idx, obj[idx], type(obj[idx])) == false then return false end
	end
end

---Convert the time from the os library to a more readable value. It returns a string in the format 
-- "hours:minutes:seconds", or "days:hours:minutes:seconds" if the elapsed time is more than one day.
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
	-- case insensitve
	local send = send:lower().."$"
	local match = self:lower():match(send)
	return match and true or false
	-- return #self >= #send and self:find(send, #self-#send+1, true) and true or false
end

-- substitute for table.getn
-- TODO
-- @para t TODO
-- @return TODO
function getn(t)
	if type(t) ~= "table" then
		incompatibleTypesErrorMsg("#1", "table", type(t), 2)
	end

	local n = 0
	for k, v in pairs(t) do
		n = n +1
	end
	return n
end

--############################################################
-- Parses a single CSV line.
-- Source: http://lua-users.org/wiki/LuaCsv
-- @param line A string from the CSV file
-- @param sep The value separator. Default is ','
-- @return A tuple (table) of values
local function ParseCSVLine(line, sep)
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line, pos, pos)
		if c == "" then break end
		if c == '"' then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line, '^%b""', pos)
				txt = txt..string.sub(line, startp + 1, endp - 1)
				pos = endp + 1
				c = string.sub(line, pos, pos)
				if c == '"' then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				-- value1,"blub""blip""boing",value3 will result in blub"blip"boing for the middle
			until (c ~= '"')
			table.insert(res, txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp, endp = string.find(line, sep, pos)
			if startp then 
				table.insert(res,string.sub(line, pos, startp - 1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res, string.sub(line, pos))
				break
			end 
		end
	end
	for i = 1, #res do
		res[i] = res[i]:match("^%s*(.-)%s*$")
	end
	return res
end

-- Read a CSV file and return an array of tables.
-- The first line of the file list the attributes of each table.
-- @param file A string, adress of the CSV file.
-- @param sep The value separator. Default is ','
-- @return A array of tables.
function readCSV(filename, sep)
	local data = {}
	local file = io.open(filename)
	local fields = ParseCSVLine(file:read(), sep)
	local line = file:read()
	while line do
		local element = {}
		local tuple = ParseCSVLine(line, sep)
		if #tuple == #fields then
			for k, v in ipairs(fields) do
				element[v] = tonumber(tuple[k]) or tuple[k]
			end
			table.insert(data, element)
		end
		line = file:read()
	end
	file:close()
	return data
end

function writeCSV(data, filename, sep)
	sep = sep or ","
	local file = io.open(filename, "w")
	local fields = {}
	for k in pairs(data[1]) do
		table.insert(fields, k)
	end
	file:write(table.concat(fields, sep))
	file:write("\n")
	for _, tuple in ipairs(data) do
		local line = {}
		for _, k in ipairs(fields) do
			local value = tuple[k]
			local t = type(value)
			if t ~= "number" then
				value = "\""..tostring(value) .."\""
			end
			table.insert(line, value)
		end
		file:write(table.concat(line, sep))
		file:write("\n")
	end
	file:close()
end

TME_GLOBAL_RANDOM = Random{seed = os.time()}

