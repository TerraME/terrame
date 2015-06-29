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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--#########################################################################################

local colors = {
	black        = {  0,   0,   0},
	white        = {255, 255, 255},
	lightRed     = {255, 102, 102},
	red          = {255,   0,   0},
	darkRed      = {128,   0,   0},
	lightYellow  = {255, 255, 153},
	yellow       = {255, 255,   0},
	darkYellow   = {255, 215,   0},
	lightOrange  = {255, 180,   0},
	orange       = {238, 154,   0},
	darkOrange   = {205, 103,   0},
	lightBrown   = {128,  85,  85},
	brown        = {128,  64,  64},
	darkBrown    = {108,  53,  53},
	lightGreen   = {153, 255, 153},
	green        = {  0, 255,   0},
	darkGreen    = {  0, 128,   0},
	lightCyan    = {128, 255, 255},
	cyan         = {  0, 255, 255},
	darkCyan     = {  0, 128, 128},
	lightBlue    = {173, 216, 230},
	blue         = {  0,   0, 255},
	darkBlue     = {  0,   0, 128},
	lightGray    = {200, 200, 200},
	gray         = {160, 160, 160},
	darkGray     = {128, 128, 128},
	lightMagenta = {255, 128, 255},
	magenta      = {255,   0, 255},
	darkMagenta  = {139,   0, 139},
	lightPurple  = {155,  48, 255},
	purple       = {125,  38, 205},
	darkPurple   = { 85,  26, 139}
}

Chart_ = {
	type_ = "Chart",
	--- Save a Chart into a file. Supported extensions are bmp, jpg, png, and tiff.
	-- @arg file A string with the file name.
	-- @usage chart:save("file.bmp")
	save = function(self, file)
		local _, extension = string.match(file, "(.-)([^%.]+)$")

		local availableExtensions = {
			bmp = true,
			jpg = true,
			png = true,
			tiff = true
		}

		if not availableExtensions[extension] then
			invalidFileExtensionError(1, extension)
		end

		extension = string.upper(extension)

		self.cObj_:save(file, extension)
	end
}

metaTableChart_ = {__index = Chart_}

--- Create a line chart showing the variation of one or more attributes (y axis) of an
-- object. X axis values come from the single argument of notify().
-- @arg data.target An Agent, Cell, CellularSpace, Society.
-- @arg data.select A vector of strings with the name of the attributes to be observed. If it is only a
-- single value then it can also be described as a string. 
-- As default, it selects all the user-defined number attributes of the target.
-- In the case of Society, if it does not have any numeric attributes then it will use
-- the number of agents in the Society as attribute.
-- @arg data.xLabel Name of the x-axis. It shows "Time" as default.
-- @arg data.yLabel Name of the y-axis. It does not show any label as default.
-- @arg data.label Vector of the same size of select that indicates the labels for each
-- line of the Chart. The default value is the name of the attributes.
-- @arg data.width The width of the lines to be drawn. It can be a number, indicating that all lines
-- will be drawn with the same width, or a vector describing each line. The default value is width one
-- for all lines.
-- @arg data.color An optional table where each position is a color for the respective attribute,
-- described as strings ("red", "green", "blue", "white", "black",
-- "yellow", "brown", "cyan", "gray", "magenta", "orange", "purple", and their light and dark
-- compositions, such as "lightGray" and "darkGray"), or as tables with three integer numbers
-- representing RGB compositions.
-- @arg data.title An overall title to the Chart.
-- @arg data.symbol The symbol to be used to draw the points of the Chart. It can be a string to
-- be used by all lines, or a vector of strings, describing the symbol for each line. The available
-- values are: "square", "diamond", "triangle", "ltriangle" (left), "dtriangle" (downwards triangle),
-- "rtriangle" (right), "cross", "vcross" (vertical cross), "hline", "vline", "asterisk",
-- "star", "hexagon", and "none" (default).
-- @arg data.size The size of the symbol, in pixels. It can be a number to be used by all lines.
-- or a vector of numbers, describing the size for each line. The default value is 7.
-- @arg data.pen The pen style for drawing lines. It can be one of "solid" (default), "dash",
-- "dot", "dashdot", or "dashdotdot". It can be a vector or a single value.
-- @arg data.style The style of each line to be drawn. It can be a string, indicating that all lines
-- will have the same style, or a vector of strings describing each line. The possible values are:
-- "lines", "dots", "none", "steps", and "sticks". The default value is "lines" for all lines.
-- @arg data.xAxis Name of the attribute to be used as x axis (instead of time). In this case,
-- notify() will not need its single argument for plotting Charts.
-- @usage Chart{target = cs}
--
-- Chart{
--     target = world,
--     width = 2,
--     select = {"susceptible", "infected", "recovered"},
--     style = {"dots", "steps", "sticks"},
--     color = {"red", "green", "blue"}
-- }
function Chart(data)
	local symbolTable = {
		square = 1,
		diamond = 2,
		triangle = 3,
		ltriangle = 4,
		-- triangle = 5,
		dtriangle = 6, -- downwards triangle
		rtriangle = 7,
		cross = 8,
		vcross = 9, -- vertical cross
		hline = 10,
		vline = 11,
		asterisk = 12,
		star = 13,
		hexagon = 14,
		none = 15
	}

	local styleTable = {
		lines = true,
		dots = true,
		none = true,
		steps = true,
		sticks = true
	}

	local penTable = {
		solid = 1,
		dash = 2,
		dot = 3,
		dashdot = 4,
		dashdotdot = 5
	}

	mandatoryTableArgument(data, "target")

	if not belong(type(data.target), {"Cell", "CellularSpace", "Agent", "Society", "table"}) then
		if not (data.target.parent and type(data.target.parent) == "Model") then
			customError("Invalid type. Charts only work with Cell, CellularSpace, Agent, Society, table, and instance of Model, got "..type(data.target)..".")
		end
	end

	defaultTableValue(data, "yLabel", "")
	defaultTableValue(data, "title",  "")

	optionalTableArgument(data, "xAxis", "string")

	if type(data.select) == "string" then data.select = {data.select} end
	if type(data.label)  == "string" then data.label  = {data.label} end

	optionalTableArgument(data, "select", "table")
	optionalTableArgument(data, "label",  "table")

	if data.select == nil then
		verify(data.label == nil, "As select is nil, it is not possible to use label.")

		data.select = {}

		if type(data.target) == "Cell" then
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" and idx ~= "x" and idx ~= "y" and string.sub(idx, -1, -1) ~= "_" then
					if not data.xAxis or idx ~= data.xAxis then
						data.select[#data.select + 1] = idx
					end
				end
			end)
		elseif type(data.target) == "Agent" then
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" and string.sub(idx, -1, -1) ~= "_" then
					if not data.xAxis or idx ~= data.xAxis then
						data.select[#data.select + 1] = idx
					end
				end
			end)
		elseif type(data.target) == "CellularSpace" then
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" and not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim"}) and string.sub(idx, -1, -1) ~= "_" then
					if not data.xAxis or idx ~= data.xAxis then
						data.select[#data.select + 1] = idx
					end
				end
			end)
		elseif type(data.target) == "Society" then
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" and not belong(idx, {"autoincrement", "observerId"}) and string.sub(idx, -1, -1) ~= "_"  then
					if not data.xAxis or idx ~= data.xAxis then
						data.select[#data.select + 1] = idx
					end
				end
			end)

			if #data.select == 0 then
				data.select = {"#"}
			end
		elseif type(data.target) == "table" then
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" then
					data.select[#data.select + 1] = idx
				end
			end)
		else -- instance of model
			forEachOrderedElement(data.target, function(idx, value, mtype)
				if mtype == "number" and not belong(idx, {"finalTime", "seed"}) and string.sub(idx, -1, -1) ~= "_" then
					if not data.xAxis or idx ~= data.xAxis then
						data.select[#data.select + 1] = idx
					end
				end
			end)
		end

		verify(#data.select > 0, "The target does not have at least one valid numeric attribute to be used.")
	elseif type(data.select) == "string" then
		data.select = {data.select}
	else
		optionalTableArgument(data, "select", "table")
	end

	forEachElement(data.select, function(_, value)
		if data.target[value] == nil then
			if  value == "#" then
				if data.target.obsattrs_ == nil then
					data.target.obsattrs_ = {}
				end

				data.target.obsattrs_["quantity_"] = true
				data.target.quantity_ = #data.target
			else
				customError("Selected element '"..value.."' does not belong to the target.")
			end
		elseif type(data.target[value]) == "function" then
			if data.target.obsattrs_ == nil then
				data.target.obsattrs_ = {}
			end

			data.target.obsattrs_[value] = true

		elseif type(data.target[value]) ~= "number" then
			incompatibleTypeError(value, "number or function", data.target[value])
		end
	end)

	if data.target.obsattrs_ then
		forEachElement(data.target.obsattrs_, function(idx)
			for i = 1, #data.select do
				if data.select[i] == idx then
					data.select[i] = idx.."_"
					local mvalue = data.target[idx](data.target)
					verify(type(mvalue) == "number", "Function '"..idx.. "' returns a non-number value.")
					data.target[idx.."_"] = mvalue
				end
			end
		end)
	end

	verify(#data.select > 0, "Charts must select at least one attribute.")

	for i = 1, #data.select do
		if data.select[i] == "#" then
			data.select[i] = "quantity_"
			data.target.quantity_ = #data.target
		end
	end

	if data.label == nil then
		data.label = {}
		for i = 1, #data.select do
			if data.select[i] == "quantity_" then
				data.label[i] = "quantity"
			else
				data.label[i] = data.select[i]
			end
		end
	end

	for i = 1, #data.label do
		local size = string.len(data.label[i])

		if string.sub(data.label[i], size, size) == "_" then
			data.label[i] = string.sub(data.label[i], 1, size - 1)
		end
	end

	verify(#data.select == #data.label, "Arguments 'select' and 'label' should have the same size, got "..#data.select.." and "..#data.label..".")

	if type(data.color) == "table" then
		verify(#data.select == #data.color, "Arguments 'select' and 'color' should have the same size, got "..#data.select.." and "..#data.color..".")

		forEachElement(data.color, function(idx, value)
			if type(value) == "string" then
				if not colors[value] then
					local s = suggestion(value, colors)
					if s then
						customError(switchInvalidArgumentSuggestionMsg(value, "color", s))
					else
						customError("Color '"..value.."' not found. Check the name or use a table with an RGB description.")
					end
				end
			elseif type(value) == "table" then
				verify(#value == 3, "RGB composition should have 3 values, got "..#value.." values in position "..idx..".")

				forEachElement(value, function(_, _, mtype)
					if mtype ~= "number" then
						customError("All the elements of an RGB composition should be numbers, got '"..mtype.."' in position "..idx..".")
					end
				end)
			end
		end)
	end

	verifyUnnecessaryArguments(data, {
		"target", "select", "yLabel", "xLabel",
		"title", "label", "pen", "color", "xAxis",
		"width", "symbol", "style", "size"
	})

	if data.xAxis then
		defaultTableValue(data, "xLabel", data.xAxis)
	else
		defaultTableValue(data, "xLabel", "Time")
	end

	local observerType
	if data.xAxis == nil then
		observerType = 5
	else
		observerType = 4
		table.insert(data.select, data.xAxis)
	end

	local observerParams = {}
	local target = data.target

	table.insert(observerParams, data.title)
	table.insert(observerParams, data.xLabel)
	table.insert(observerParams, data.yLabel)

	local label = table.concat(data.label, ";")

	table.insert(observerParams, label)

	if type(data.width) == "number" then
		local width = {}
		forEachElement(data.select, function()
			table.insert(width, data.width)
		end)
		data.width = width
	end

	local repeatAttribute = function(att, mtype)
		if type(data[att]) == mtype then
			local vatt = {}
			forEachElement(data.select, function()
				table.insert(vatt, data[att])
			end)
			data[att] = vatt
		end
	end

	repeatAttribute("style",  "string")
	repeatAttribute("symbol", "string")
	repeatAttribute("pen",    "string")
	repeatAttribute("size",   "number")
	repeatAttribute("color",  "string")

	optionalTableArgument(data, "width",  "table")
	optionalTableArgument(data, "style",  "table")
	optionalTableArgument(data, "symbol", "table")
	optionalTableArgument(data, "pen",    "table")
	optionalTableArgument(data, "size",   "table")
	optionalTableArgument(data, "color",  "table")

	if type(data.target) == "table" then
		if data.target.cobj_ == nil then
			data.target.cObj_ = TeCell()
			data.target.notify = Cell_.notify
		end
	end

	if data.size then
		forEachElement(data.size, function(idx, value)
			if value < 0 then
				customError(positiveArgumentMsg("size", value))
			end
		end)
	end

	if data.width then
		forEachElement(data.width, function(idx, value)
			if value <= 0 then
				incompatibleValueError("width", "greater than zero", value)
			end
		end)
	end

	if data.symbol then
		local symbol = {}
		forEachElement(data.symbol, function(idx, value)
			symbol[idx] = symbolTable[value]
			if not symbol[idx] then
				switchInvalidArgument("symbol", value, symbolTable)
			end
		end)
		data.symbol = symbol
	end

	if data.pen then
		local pen = {}
		forEachElement(data.pen, function(idx, value)
			pen[idx] = penTable[value]
			if not pen[idx] then
				switchInvalidArgument("pen", value, penTable)
			end
		end)
		data.pen = pen
	end

	if data.style then
		forEachElement(data.style, function(_, value)
			if not styleTable[value] then
				switchInvalidArgument("style", value, styleTable)
			end
		end)
	end

	-- Legend
	local defaultColors = {"red", "green", "blue", "yellow", "brown", "magenta", "orange", "purple", "cyan", "black"}

	if #data.select > 10 and not data.color then
		customError("Argument color is compulsory when using more than 10 attributes.")
	end

	local i = 1
	forEachElement(data.select, function()
		local width = 2
		if data.width then
			width = data.width[i]
		end

		local style = "lines"
		if data.style then
			style = data.style[i]
		end

		local symbol = symbolTable.none
		if data.symbol then
			symbol = data.symbol[i]
		end

		local pen = penTable.solid
		if data.pen then
			pen = data.pen[i]
		end

		local size = 7
		if data.size then
			size = data.size[i]
		end

		local color = defaultColors[i]
		if data.color then
			color = data.color[i]
		end

		local l = _Gtme.Legend{
			type = "number",
			width = width,
			style = style,
			size = size,
			slices = 1,
			symbol = symbol,
			pen = pen,
			colorBar = {{color = color, value = "-"}}
		}

		table.insert(observerParams, l)
		i = i + 1
	end)

	local id
	local obs

	if type(target) == "CellularSpace" then
		id, obs = target.cObj_:createObserver(observerType, {}, data.select, observerParams, target.cells)
	else
		if type(target) == "Society" then
			target.observerId = 1 -- TODO: verify why this line is necessary
		end
		id, obs = target.cObj_:createObserver(observerType, data.select, observerParams)
	end

	local chart = TeChart()
	chart:setObserver(obs)

	data.cObj_ = chart
	data.id = id
	
	setmetatable(data, metaTableChart_)
    table.insert(_Gtme.createdObservers, data)
	return data
end

