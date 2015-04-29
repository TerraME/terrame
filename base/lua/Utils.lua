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
--          Antonio Jose da Cunha Rodrigues
--          Raian Vargas Maretto
--#########################################################################################

-- @header Some basic and useful functions for modeling.

-- Implements the Heun (Euler Second Order) Method to integrate ordinary differential equations.
-- It is a method of type Predictor-Corrector.
-- @arg df The differential equantion.
-- @arg initCond The initial condition that must be satisfied.
-- @arg a The value of 'a' in the interval [a,b[.
-- @arg b The value of 'b' of in the interval [a,b[.
-- @arg delta The step of the independent variable.
-- @usage f = function(x) return x^3 end
-- v = integrationHeun(f, 0, 0, 3, 0.1)
local function integrationHeun(df, initCond, a, b, delta)
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

-- Implements the Runge-Kutta Method (Fourth Order) to integrate ordinary differential equations.
-- @arg df The differential equantion.
-- @arg initCond The initial condition that must be satisfied.
-- @arg a The value of 'a' in the interval [a,b[.
-- @arg b The value of 'b' of in the interval [a,b[.
-- @arg delta The step of the independent variable.
-- @usage f = function(x) return x^3 end
-- v = integrationRungeKutta(f, 0, 0, 3, 0.1)
local function integrationRungeKutta(df, initCond, a, b, delta)
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
			y = y + delta * (y1 + 2 * y2 + 2 * y3 + y4) / 6
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
				values[i] = y[i] + delta * (y1 + 2 * y2 + 2 * y3 + y4) / 6
			end
			for i = 1, sizeDF do
				y[i] = values[i]
			end
		end
		return y

	end
end

-- Implements the Euler (Euler-Cauchy) Method to integrate ordinary differential equations.
-- @arg df The differential equantion.
-- @arg initCond The initial condition that must be satisfied.
-- @arg a The value of 'a' in the interval [a,b[.
-- @arg b The value of 'b' of in the interval [a,b[.
-- @arg delta The step of the independent variable.
-- @usage f = function(x) return x^3 end
-- v = integrationEuler(f, 0, 0, 3, 0.1)
local function integrationEuler(df, initCond, a, b, delta)
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
		local values = {} -- each equation must be computed from the same "past" value ==> o(n2),
						  -- where n is the number of equations
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

--- Parse a single CSV line. It returns a vector of strings with the i-th value in the position i.
-- This function was taken froom http://lua-users.org/wiki/LuaCsv.
-- @arg line A string from a CSV file.
-- @arg sep A string with the separator. The default value is ','.
-- @usage CSVparseLine(line, ",")
function CSVparseLine(line, sep)
	mandatoryArgument(1, "string", line)
	optionalArgument(2, "string", sep)

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
				local startp, endp = string.find(line, '^%b""', pos)
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
			verify(c == sep or c == "", "Invalid line: '"..line.."'.")
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

--- Read a CSV file. It returns a non-named table (indexed by the lines)
-- containing named-tables (indexed by the attribute names).
-- The first line of the file list the attribute names.
-- @arg filename A string with the location of the CSV file.
-- @arg sep A string with the separator. The default value is ','.
-- @usage -- Given file.csv:
-- -- attr1;attr2
-- -- 11;12
-- -- 21;22
--
-- mytable = CSVread("file.csv", ";")
--
-- print(mytable[1].attr1) -- 11
-- print(mytable[2].attr2) -- 22
function CSVread(filename, sep)
	mandatoryArgument(1, "string", filename)
	optionalArgument(2, "string", sep)

	local data = {}
	local file = io.open(filename)

	if not file then
		resourceNotFoundError(1, filename)
	end

	local fields = CSVparseLine(file:read(), sep)
	local line = file:read()
	while line do
		local element = {}
		local tuple = CSVparseLine(line, sep)
		if #tuple == #fields then
			for k, v in ipairs(fields) do
				element[v] = tonumber(tuple[k]) or tuple[k]
			end
			table.insert(data, element)
		else
			customError("Line '"..line.."' should contain "..#fields.." attributes but has "..#tuple..".")
		end
		line = file:read()
	end
	file:close()
	return data
end

--- Write a given table into a CSV file.
-- The first line of the file will list the attributes of each table.
-- @arg data A table to be saved. It must be a non-named table (indexed by the lines)
-- containing named-tables (indexed by the attribute names).
-- @arg filename A string with the location of the CSV file.
-- @arg sep A string with the separator. The default value is ','.
-- @usage mytable = {
--     {age = 1, wealth = 10, vision = 2},
--     {age = 3, wealth =  8, vision = 1},
--     {age = 3, wealth = 15, vision = 2}
-- }
--
-- CSVwrite(mytable, "file.csv", ";")
function CSVwrite(data, filename, sep)
	mandatoryArgument(1, "table", data)
	mandatoryArgument(2, "string", filename)
	optionalArgument(3, "string", sep)

	sep = sep or ","
	local file = io.open(filename, "w")
	local fields = {}

	if data[1] == nil then
		customError("#1 does not have position 1.")
	elseif #data ~= getn(data) then
		customError("#1 should have only numbers as indexes.")
	end

	for k in pairs(data[1]) do
		if type(k) ~= "string" then
			customError("All attributes should be string, got "..type(k)..".")
		end
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

--- Return whether a given value belong to a table.
-- @arg value A value.
-- @arg values A table with a set of values.
-- @usage belong(2, {1, 2, 3})
function belong(value, values)
	if type__(values) ~= "table" then
		incompatibleTypeError(2, "table", values)
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

--- Return a function that executes a given function of an object.
-- It is particularly useful as argument action for an Event.
-- @arg obj Any TerraME object.
-- @arg func A string with the function to be executed.
-- @usage a = Agent{exec = function(self, ev) print(ev:getTime()) end}
--
-- t = Timer{
--     Event{action = call(a, "exec")}
-- }
--
-- t:execute(10)
function call(obj, func)
	mandatoryArgument(2, "string", func)

	if type__(obj) ~= "table" then
		customError("Cannot access elements from an object of type '"..type(obj).."'.")
	elseif type(obj[func]) ~= "function" then
		customError("Function '"..func.."' does not exist.")
	end

	return function(ev) obj[func](obj, ev) end
end

--- Pause the simulation for a given time.
-- @arg delay_s A number indicating how long in seconds should the model pause.
-- The default value is 1.
-- @usage delay(2.5)
function delay(delay_s)
	optionalArgument(1, "number", delay_s)

	if not delay_s then
		delay_s = 1
	end

	local time_to = os.time() + delay_s
	while os.time() <= time_to do end
end

--- Convert the time in seconds to a more readable value. It returns a string in the format
-- "hours:minutes:seconds", or "days:hours:minutes:seconds" if the elapsed time is
-- more than one day.
-- @arg s A number.
-- @usage print(elapsedTime(100)) -- 00:01:40
function elapsedTime(s)
	mandatoryArgument(1, "number", s)

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

--- Second order function to traverse a Society, Group, or Cell, applying a function to each of
-- its Agents. It returns true if no call to the function taken as argument returns false,
-- otherwise it returns false.
-- @arg obj A Society, Group, or Cell. Cells need to have a placement in order to execute
-- this function.
-- @arg func A function that takes one single Agent as argument. If some call to it returns
-- false, forEachAgent() stops and does not process any other Agent. 
-- This function can optionally get a second argument with a positive number representing the
-- position of the Agent in the vector of Agents.
-- @usage forEachAgent(group, function(agent)
--     agent.age = agent.age + 1
-- end)
-- @see Environment:createPlacement
function forEachAgent(obj, func)
	local t = type(obj)
	if t ~= "Society" and t ~= "Cell" and t ~= "Group" then
		incompatibleTypeError(1, "Society, Group, or Cell", obj)
	elseif type(func) ~= "function" then
		incompatibleTypeError(2, "function", func)
	end

	local ags = obj.agents
	if ags == nil then 
		customError("Could not get agents from the "..type(obj)..".")
	end
	-- forEachAgent needs to be different from the other forEachs because the
	-- ageng can die along its own execution and it shifts back all the other
	-- agents in society.agents. If ipairs was used instead, forEach would
	-- skip the next agent of the vector after the removed agent.
	local k = 1
	for i = 1, #ags do
		local ag = ags[k]
		if ag and func(ag, i) == false then return false end
		if ag == ags[k] then k = k + 1 end
	end
	return true
end

--- Second order function to transverse a given CellularSpace, Trajectory, or Agent,
-- applying a given function to each of its Cells. If any of the function calls returns
-- false, forEachCell() stops and returns false, otherwise it returns true.
-- @arg cs A CellularSpace, Trajectory, or Agent. Agents need to have a placement
-- in order to execute this function.
-- @arg f A user-defined function that takes a Cell as argument.
-- It can optionally have a second argument with a positive number representing the position of
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
		incompatibleTypeError(1, "CellularSpace, Trajectory, or Agent", cs)
	elseif type(f) ~= "function" then
		incompatibleTypeError(2, "function", f)
	end

	for i, cell in ipairs(cs.cells) do
		if f(cell, i) == false then return false end
	end
	return true
end

--- Second order function to transverse two CellularSpaces with the same resolution and
-- size. It applies a function that gets two Cells as arguments, one from each
-- CellularSpace. Both cells share the same (x, y) location.
-- It returns true if no call to the function taken as argument returns false, otherwise
-- it returns false.
-- @arg cs1 A CellularSpace.
-- @arg cs2 Another CellularSpace.
-- @arg f A user-defined function that takes two Cells as arguments, one coming from the
-- first argument and the other from the second one.
-- If some call returns false, forEachCellPair() stops and does not
-- process any other pair of Cells.
-- @usage forEachCellPair(cs1, cs2, function(cell1, cell2)
--     cell1.water = cell1.water + cell2.water
--     cell2.water = 0
-- end)
function forEachCellPair(cs1, cs2, f)
	if type(cs1) ~= "CellularSpace" then
		incompatibleTypeError(1, "CellularSpace", cs1)
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError(2, "CellularSpace", cs2)
	elseif type(f) ~= "function" then
		incompatibleTypeError(3, "function", f)
	end

	verify(#cs1 == #cs2, "CellularSpaces should have the same size.")

	for i, cell1 in ipairs(cs1.cells) do
		local cell2 = cs2.cells[i]
		if f(cell1, cell2, i) == false then return false end
	end
	return true
end

--- Second order function to transverse the connections of a given Agent, applying a function to
-- each of them. It returns true if no call to the function taken as argument returns false,
-- otherwise it returns false.
-- There are two ways of using this function because the second argument is optional.
-- @arg agent An Agent.
-- @arg index (Optional) A string with the name of the SocialNetwork to be transversed. The default value is "1".
-- @arg f A function that takes three arguments: the Agent itself, its connection, and the
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
		incompatibleTypeError(1, "Agent", agent)
	elseif type(index) == "function" then
		f = index
		index = "1"
	elseif type(index) ~= "string" then
		incompatibleTypeError(2, "function or string", index)
	elseif type(f) ~= "function" then
		incompatibleTypeError(3, "function", f)
	end

	local socialnetwork = agent:getSocialNetwork(index)
	if not socialnetwork then
		customError("Agent does not have a SocialNetwork named '"..index.."'.")
	end
	for index, connection in pairs(socialnetwork.connections) do
		local weight = socialnetwork.weights[index]
		if f(agent, connection, weight) == false then return false end
	end
	return true
end

--- Second order function to transverse a given object, applying a function to each of its
-- elements. It can be used for instance to transverse all the elements of an Agent or an
-- Environment. According to the current Lua version, if one uses this function twice, Lua
-- does not guarantee that the objects will be transversed in the same order. If you need to
-- guarantee this, it is recommended to use Utils:forEachOrderedElement() instead.
-- This function returns true if no call to the function taken as argument returns false,
-- otherwise it returns false.
-- @arg obj A TerraME object or a table.
-- @arg func A user-defined function that takes three arguments: the index of the element,
-- the element itself, and the type of the element. If some call to this function returns
-- false then forEachElement() stops.
-- @usage forEachElement(cell, function(idx, element, etype)
--     print(element, etype)
-- end)
function forEachElement(obj, func)
	if obj == nil then
		mandatoryArgumentError(1)
	elseif func == nil then
		mandatoryArgumentError(2)
	elseif type(func) ~= "function" then
		incompatibleTypeError(2, "function", func)
	end

	for k, ud in pairs(obj) do
		local t = type(ud)
		if func(k, ud, t) == false then return false end
	end
	return true
end

--- Second order function to transverse a given folder,
-- applying a given function on each of its files. If any of the function calls returns
-- false, forEachFile() stops and returns false, otherwise it returns true.
-- @arg folder A string with the path to a folder, or a vector of files.
-- @arg f A user-defined function that takes a file name as argument. Note that
-- the name does not include the directory where the file is placed.
-- @usage forEachFile("C:", function(file)
--     print(file)
-- end)
-- @see FileSystem:dir
function forEachFile(folder, f)
	if type(folder) == "string" then
		folder = dir(folder)
	end

	mandatoryArgument(1, "table", folder)
	mandatoryArgument(2, "function", f)

	for i = 1, #folder do
		if f(folder[i]) == false then return false end
	end
	return true
end

--- Second order function to transverse a given Neighborhood of a Cell, applying a
-- function in each of its neighbors. It returns true if no call to the function taken as
-- argument returns false, otherwise it returns false.
-- There are two ways of using this function because the second argument is optional.
-- @arg cell A Cell.
-- @arg index (Optional) A string with the name of the Neighborhood to be transversed.
-- The default value is "1".
-- @arg f A user-defined function that takes three arguments: the Cell itself, the neighbor
-- Cell, and the connection weight. If some call to it returns false, forEachNeighbor() stops
-- and does not process any other neighbor. In the case where the second argument is missing,
-- this function becomes the second argument.
-- @usage forEachNeighbor(cell, function(cell, neighbor)
--     if neighbor.deforestation > 0.9 then
--         cell.deforestation = cell.deforestation * 1.01
--     end
-- end)
--
-- neigh_deforestation = 0
-- forEachNeighbor(cell, "roads", function(cell, neighbor, weight)
--     neigh_deforestation = neigh_deforestation + neighbor.deforestation * weight
-- end)
-- @see CellularSpace:createNeighborhood
-- @see CellularSpace:loadNeighborhood
function forEachNeighbor(cell, index, f)
	if type(cell) ~= "Cell" then
		incompatibleTypeError(1, "Cell", cell)
	elseif type(index) == "function" then
		f = index
		index = "1"
	elseif type(index) ~= "string" then
		incompatibleTypeError(2, "function or string", index)
	elseif type(f) ~= "function" then
		incompatibleTypeError(3, "function", f)
	end

	local neighborhood = cell:getNeighborhood(index)
	if neighborhood == nil then
		customError("Neighborhood '"..index.."' does not exist.")
	end
	neighborhood.cObj_:first()
	while not neighborhood.cObj_:isLast() do
		local neigh = neighborhood.cObj_:getNeighbor()
		local weight = neighborhood.cObj_:getWeight()
		if f(cell, neigh, weight) == false then return false end
		neighborhood.cObj_:next()
	end
	return true
end

--- Second order function to transverse all Neighborhoods of a Cell, applying a given function
-- on them. It returns true if no call to the function taken as argument returns false,
-- otherwise it returns false.
-- @arg cell A Cell.
-- @arg f A function that receives a Neighborhood as argument.
-- @usage forEachNeighborhood(cell, function(neighborhood)
--     print(neighborhood:getId())
-- end)
function forEachNeighborhood(cell, f)
	if type(cell) ~= "Cell" then
		incompatibleTypeError(1, "Cell", cell)
	elseif type(f) ~= "function" then
		incompatibleTypeError(2, "function", f)
	end

	cell.cObj_:first()
	while not cell.cObj_:isLast() do
		local nh = cell.cObj_:getCurrentNeighborhood()
		if f(nh) == false then return false end
		cell.cObj_:next()
	end
	return true
end

--- Second order function to transverse a given object, applying a function to each of its
-- elements according to their alphabetical order. It can be used for instance to transverse all
-- the elements of an Agent or an
-- Environment. This function executes first the numeric indexes and then the string ones, with
-- upper case characters having priority over lower case.
-- This function returns true if no call to the function taken as argument returns false,
-- otherwise it returns false.
-- @arg obj A TerraME object or a table.
-- @arg func A user-defined function that takes three arguments: the index of the element,
-- the element itself, and the type of the element. If some call to this function returns
-- false then forEachElement() stops.
-- @usage forEachOrderedElement(cell, function(idx, element, etype)
--     print(element, etype)
-- end)
function forEachOrderedElement(obj, func)
	if obj == nil then
		mandatoryArgumentError(1)
	elseif type(func) ~= "function" then
		incompatibleTypeError(2, "function", func)
	end

	local strk

	local sorder = {}
	local sreference = {}

	local norder = {}
	local nreference = {}

	for k, ud in pairs(obj) do
		if type(k) == "number" then
			norder[#norder + 1] = k
			nreference[k] = k
		else	
			strk = tostring(k)
			sorder[#sorder + 1] = strk
			sreference[strk] = k
		end
	end

	table.sort(norder)
	table.sort(sorder)

	for k = 1, #norder do
		local idx = nreference[norder[k]]
		if func(idx, obj[idx], type(obj[idx])) == false then return false end
	end

	for k = 1, #sorder do
		local idx = sreference[sorder[k]]
		if func(idx, obj[idx], type(obj[idx])) == false then return false end
	end
	return true
end

--- Return a table with the content of the file config.lua, stored in the directory where TerraME
-- was executed. All the global variables of the file are elements of the returned table. 
-- Some packages require specific variables in this file in order to be tested or executed.
-- TerraME execution options -imporDb and -exportDb also use this file.
-- @usage getConfig()
function getConfig()
	return include("config.lua")
end

--- Return the extension of a given file name. It returns the substring after the last dot.
-- If it does not have a dot, an empty string is returned.
-- @arg filename A string with the file name.
-- @usage getExtension("file.txt") -- ".txt"
function getExtension(filename)
	mandatoryArgument(1, "string", filename)

	for i = 1, filename:len() do
		if filename:sub(i, i) == "." then
			return filename:sub(i + 1, filename:len())
		end
	end
	return ""
end

--- Return the number of elements of a table, be them named or not.
-- It is a substitute for the old Lua function table.getn. It can
-- also be used to compute the number of elements of any TerraME
-- object, such as Agent or Environment.
-- @arg t A table.
-- @usage getn{name = "john", age = 20}
function getn(t)
	if type__(t) ~= "table" then
		incompatibleTypeError(1, "table", t)
	end

	local n = 0
	for k, v in pairs(t) do
		n = n + 1
	end
	return n
end

--- Return a function that compares two tables (which can be, for instance, Agents or Cells).
-- The function returns which one has a priority over the other, according to an attribute of the
-- objects and a given operator. If the function was not successfully built it returns nil.
-- @arg attribute A string with the name of the attribute.
-- @arg operator A string with the operator, which can be ">", "<", "<=", or ">=". The default value is "<".
-- @usage t = Trajectory{
--     target = cs,
--     sort = greaterByAttribute("cover")
-- }
-- @see Trajectory
-- @see Group
function greaterByAttribute(attribute, operator)
	if type(attribute) ~= "string" then
		incompatibleTypeError(1, "string", attribute)
	elseif operator == nil then
		operator = "<"
	elseif not belong(operator, {"<", ">", "<=", ">="}) then
		incompatibleValueError(2, "<, >, <=, or >=", operator)
	end

	local str = "return function(o1, o2) return o1."..attribute.." "..operator.." o2."..attribute.." end"
	return load(str)()
end

--- Return a function that compares two tables with x and y attributes (basically two regular
-- Cells). The function returns which one has a priority over the other, according to a given
-- operator.
-- @arg operator A string with the operator, which can be ">", "<", "<=", or ">=".
-- The default value is "<".
-- @usage t = Trajectory{
--     target = cs,
--     sort = greaterByCoord()
-- }
-- @see Trajectory
function greaterByCoord(operator)
	if operator == nil then
		operator = "<"
	elseif not belong(operator, {"<", ">", "<=", ">="}) then
		incompatibleValueError(1, "<, >, <=, or >=", operator)
	end

	local str = "return function(a, b)\n"
	str = str .. "if a.x"..operator.."b.x then return true end\n"
	str = str .. "if a.x == b.x and a.y"..operator.."b.y then return true end\n"
	str = str .. "return false end"	
	return load(str)()
end

--- A second order function to numerically solve ordinary differential equations with a given
-- initial value.
-- @arg attrs.method the name of a numeric algorithm to solve the ordinary differential
-- equations. See the options below.
-- @tabular method
-- Method & Description \
-- "euler" (default) & Euler integration method \
-- "heun" & Heun (Second Order Euler) \
-- "rungekutta" & Runge-Kutta Method (Fourth Order)
-- @arg attrs.equation A differential equation or a vector of differential equations. Each
-- equation is described as a function of one or two arguments that returns a value of its
-- derivative f(t, y), where t is the time instant, and y starts with the value of attribute
-- initial and changes according to the result of f() and the chosen method. The calls to f
-- will use the first argument (t) in the interval [a,b[, according to the argument step.
-- @arg attrs.initial The initial condition, or a vector of initial conditions, which must be
-- satisfied. Each initial condition represents the value of y when t (first argument of f)
-- is equal to the value of argument a.
-- @arg attrs.a A number with the beginning of the interval.
-- @arg attrs.b A number with the end of the interval.
-- @arg attrs.step A positive number with the step within the interval. It must
-- satisfy the condition that (b - a) is a multiple of step.
-- @arg attrs.event An Event that can be used to set arguments a and b with values
-- event:getTime() - event:getPeriodicity() and event:getTime(), respectively. The period of the
-- event must be a multiple of step. Note that the first execution of the event will compute the
-- equation relative to a time interval between event.time - event.period and event.time. Be
-- careful about that, as it can start before the initial Event of the simulation.
-- @usage v = integrate{
--     equation = function(t, y)
--         return t - 0.1 * y
--     end,
--     method = "euler",
--     initial = 0,
--     a = 0,
--     b = 100,
--     step = 0.1
-- }
function integrate(attrs)
	verifyNamedTable(attrs)

	if attrs.event ~= nil then
		mandatoryTableArgument(attrs, "event", "Event")
		verify(attrs.a == nil, "Argument 'a' should not be used together with argument 'event'.")
		verify(attrs.b == nil, "Argument 'b' should not be used together with argument 'event'.")
		attrs.a = attrs.event:getTime() - attrs.event:getPeriod() 
		attrs.b = attrs.event:getTime()
	end

	if type(attrs.equation) ~= "function" then
		mandatoryTableArgument(attrs, "equation", "table")

		forEachElement(attrs.equation, function(_, value)
			if type(value) ~= "function" then
				customError("Table 'equation' should contain only functions, got "..type(value)..".")
			end
		end)

		mandatoryTableArgument(attrs, "initial", "table")
	end

	if type(attrs.initial) ~= "number" then
		mandatoryTableArgument(attrs, "initial", "table")
		mandatoryTableArgument(attrs, "equation", "table")

		forEachElement(attrs.initial, function(_, value)
			if type(value) ~= "number" then
				customError("Table 'initial' should contain only numbers, got "..type(value)..".")
			end
		end)

		if #attrs.equation ~= #attrs.initial then
			customError("Tables equation and initial shoud have the same size.")
		end
	end

	mandatoryTableArgument(attrs, "step", "number")
	positiveTableArgument(attrs, "step")

	defaultTableValue(attrs, "method", "euler")

	verifyUnnecessaryArguments(attrs, {"a", "b", "event", "method", "initial", "equation", "step"})

	local result = switch(attrs, "method"):caseof {
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

--- Return the Levenshtein's distance between two strings.
-- See http://en.wikipedia.org/wiki/Levenshtein_distance for more details.
-- @arg s A string.
-- @arg t Another string.
-- @usage levenshtein("abc", "abb")
function levenshtein(s, t)
	mandatoryArgument(1, "string", s)
	mandatoryArgument(2, "string", t)

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

--- Round a number given a precision.
-- @arg num A number.
-- @arg idp The number of decimal places to be used. The default value is zero.
-- @usage round(2.34566, 3)
function round(num, idp)
	mandatoryArgument(1, "number", num)
	optionalArgument(2, "number", idp)

	if not idp then idp = 0 end

	local mult = 10 ^ idp
	return math.floor(num * mult + 0.5) / mult
end

--- Return information about the current execution. The result is a table
-- with the following values.
-- @tabular tab
-- Attribute & Description \
-- mode & A string with the current mode for warnings ("normal", "debug", or "quiet"). \
-- dbVersion & A string with the current TerraLib version for databases. \
-- separator & A string with the directory separator. \
-- path & A string with the location of TerraME in the computer.
-- @usage sessionInfo().version
function sessionInfo()
	return info_ -- this is a global variable created when TerraME is initialized
end

--- Return whether a string ends with a given substring (no case sensitive).
-- @arg str A string.
-- @arg send A substring describing the end of the first parameter.
-- @usage string.endswith("abcdef", "def")
function string.endswith(str, send)
	local send = send:lower().."$"
	return str:lower():match(send) ~= nil
end

--- Return the type of an object. It extends the original Lua type() to support TerraME objects,
-- whose type name (for instance "CellularSpace" or "Agent") is returned instead of "table".
-- @arg data Any object or value.
-- @usage c = Cell{value = 3}
-- print(type(c)) -- "Cell"
function type(data)
	local t = type__(data)
	if t == "table" or (t == "userdata" and getmetatable(data)) then
		if data.type_ ~= nil then
			return data.type_
		end
	end
	return t
end

-- This function is taken from https://gist.github.com/lunixbochs/5b0bb27861a396ab7a86
--- Function that returns a string describing the internal content of an object.
-- @arg o The object to be converted into a string.
-- @arg indent A string to be placed in the beginning of each line of the returning string.
-- @usage vardump{name = "john", age = 20}
function vardump(o, indent)
	if indent == nil then indent = '' end

	local indent2 = indent..'    '
	if type__(o) == 'table' then
		local s = indent..'{'..'\n'
		local first = true
		forEachOrderedElement(o, function(k, v)
			if first == false then s = s .. ', \n' end
			if type__(k) ~= 'number' then k = "'"..tostring(k).."'" end
			s = s..indent2..'['..k..'] = '..vardump(v, indent2)
			first = false
		end)
		return s..'\n'..indent..'}'
	else
		return "'"..tostring(o).."'"
	end
end

