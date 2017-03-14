-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

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

local function chartFromData(attrTab)
	local columns = attrTab.target:columns()
	local rows = attrTab.target:rows()

	forEachElement(attrTab.select, function(_, idx)
		if not columns[idx] then
			customError("Selected column '"..idx.."' does not exist in the DataFrame.")
		end
	end)

	if attrTab.xAxis and not columns[attrTab.xAxis] then
		customError("Selected column '"..attrTab.xAxis.."' for argument 'xAxis' does not exist in the DataFrame.")
	end

	local cell = Cell(clone(columns))
	local df = attrTab.target

	local function updateValues(time)
		local mrow = df[time]
		forEachElement(attrTab.select, function(_, value)
			cell[value] = mrow[value]
		end)

		if attrTab.xAxis then
			cell[attrTab.xAxis] = mrow[attrTab.xAxis]
		end
	end

	if attrTab.yLabel == "" then attrTab.yLabel = nil end
	if attrTab.title == "" then attrTab.title = nil end

	local begin = getNames(rows)[1]
	updateValues(begin)
	attrTab.target = cell
	local chart = Chart(attrTab)

	forEachOrderedElement(rows, function(idx)
		updateValues(idx)
		chart:update(idx)
	end)

	return chart
end

Chart_ = {
	type_ = "Chart",
	--- Return a DataFrame with the values got from all its updates.
	-- @usage cs = CellularSpace{
	--     xdim = 10,
	--     value1 = 5,
	--     value2 = 7
	-- }
	--
	-- chart = Chart{target = cs}
	--
	-- chart:update(1)
	-- chart:update(2)
	-- chart:update(3)
	--
	-- data = chart:getData()
	-- print(tostring(data))
	getData = function(self)
		return self.values
	end,
	--- Save a Chart into a file. Supported extensions are bmp, jpg, png, and tiff.
	-- @arg file A string with the file name.
	-- @usage cs = CellularSpace{
	--     xdim = 10,
	--     value1 = 5,
	--     value2 = 7
	-- }
	--
	-- chart = Chart{target = cs}
	--
	-- chart:update(1)
	-- chart:update(2)
	-- chart:update(3)
	-- chart:save("file.bmp")
	-- File("file.bmp"):delete()
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
	end,
	--- Update the Chart with the latest values of its target. It is usually recommended
    -- to use the Chart as action of an Event instead of calling this function explicitly.
	-- @arg modelTime A number with the current time or an Event.
	-- @usage cell = Cell{value = 1}
	-- chart = Chart{target = cell}
	--
	-- chart:update(0)
	-- chart:update(1)
	-- chart:update(2)
	update = function(self, modelTime)
		if type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		end

		local values = {}

		forEachElement(self.select, function(_, key)
			values[key] = self.target[key]
		end)

		self.values[modelTime] = values

		self.target:notify(modelTime)
	end,
	--- Clear the Chart.
	-- @usage -- DONTRUN
	-- cell = Cell{value = 1}
	-- chart = Chart{target = cell}
	-- chart:update(1)
	-- chart:update(2)
	-- chart:clear()
	clear = function(self)
		self.cObj_:clear()
	end,
	--- Restart the Chart keeping the old plots.
	-- @usage -- DONTRUN
	-- cell = Cell{value = 1}
	-- chart = Chart{target = cell}
	-- chart:update(1)
	-- chart:update(2)
	-- chart:restart()
	-- chart:update(2)
	-- chart:update(3)
	restart = function(self)
		self.cObj_:restart()
	end
}

metaTableChart_ = {__index = Chart_}

--- Create a line chart showing the variation of one or more attributes (y axis) of an
-- object. As default, x axis values come from the single argument of Chart:update().
-- A Chart behaves according to its target's type. See the table below.
-- @tabular NONE
-- Type of the target & Behavior & Compulsory & Unnecessary \
-- "Agent", "Cell", instance of a Model & Plots how attributes change over time. & target & value \
-- "CellularSpace" & If the selected attributes belong to the CellularSpace, it plots how attributes change over time. If only one attribute is selected and it belongs to the Cells, then it plots the sum of the attribute values in the whole CellularSpace. & select, target &  \
-- "Map" & Works as a Chart created from a CellularSpace, copying the values of arguments target, select, value, color, and label from the Map to itself. It only works if the Map was created using grouping "uniquevalue". If some of the colors is white, the respective attribute value will be ignored by the Chart. & target & color, label, select, value \
-- "Environment" & Plot how a given attribute from different Models. & select, target & value \
-- "Society" & Plot how attributes change over time. If no attribute is selected, it will plot the amount of Agents along the simulation. & target &  \
-- "DataFrame" & Plot a set of values at once, without needing to call Chart:update(). & target & value \
-- @arg attrTab.select A vector of strings with the name of the attributes to be observed. If it is only a
-- single value then it can also be described as a string.
-- As default, it selects all the user-defined number attributes of the target.
-- In the case of Society, if it does not have any numeric attributes then it will use
-- the number of agents in the Society as attribute.
-- The positions of the vector define the plot order. It draws starting from the first
-- until the last position.
-- When using an Environment as target, it is possible to use only one attribute name. The selected
-- attribute must belong to the Model instances it contains. Chart will then create one line for
-- each Model instance. In this case, the selected attribute will be the default title for the Chart and the
-- default labels will be the names of the Model instances in the Environment (if they are named) or else their Model:title() values.
-- @arg attrTab.target The object to be observed.
-- @arg attrTab.value A vector of strings with the values to be observed. It is necessary when observing
-- automatic functions from CellularSpace or Society that are created from string attributes. In this case,
-- Chart will plot the quantity of each value described in this argument.
-- @arg attrTab.xLabel Name of the x-axis. It shows "Time" as default.
-- @arg attrTab.yLabel Name of the y-axis. It does not show any label as default.
-- @arg attrTab.label Vector of the same size of select that indicates the labels for each
-- line of the Chart. The default value is the name of the attributes using Utils:toLabel().
-- @arg attrTab.width The width of the lines to be drawn. It can be a number, indicating that all lines
-- will be drawn with the same width, or a vector describing each line. The default value is width one
-- for all lines.
-- @arg attrTab.color An optional table where each position is a color for the respective attribute,
-- described as strings ("red", "green", "blue", "white", "black",
-- "yellow", "brown", "cyan", "gray", "magenta", "orange", "purple", and their light and dark
-- compositions, such as "lightGray" and "darkGray"), or as tables with three integer numbers
-- representing RGB compositions.
-- @arg attrTab.data A table with a complete description of the data to be drawn in the Chart.
-- It must be a valid Utils:isTable() with a set of vectors, each one with a name. The names of these vectors can be
-- used in arguments select and xAxis. If not using xAxis, it will draw the time according to the
-- positions of the values. When using data, argument target becomes unnecessary. This argument
-- will automatically be converted to a Cell, in order to allow using Cell:notify().
-- @arg attrTab.title An overall title to the Chart. The default value is "". In the case of
-- instances of Models, the default is Model:title().
-- @arg attrTab.symbol The symbol to be used to draw the points of the Chart. It can be a string to
-- be used by all lines, or a vector of strings, describing the symbol for each line. The available
-- values are: "square", "diamond", "triangle", "ltriangle" (left), "dtriangle" (downwards triangle),
-- "rtriangle" (right), "cross", "vcross" (vertical cross), "hline", "vline", "asterisk",
-- "star", "hexagon", and "none" (default).
-- @arg attrTab.size The size of the symbol, in pixels. It can be a number to be used by all lines.
-- or a vector of numbers, describing the size for each line. The default value is 7.
-- @arg attrTab.pen The pen style for drawing lines. It can be one of "solid" (default), "dash",
-- "dot", "dashdot", or "dashdotdot". It can be a vector or a single value.
-- @arg attrTab.style The style of each line to be drawn. It can be a string, indicating that all lines
-- will have the same style, or a vector of strings describing each line. The possible values are:
-- "lines", "dots", "none", "steps", and "sticks". The default value is "lines" for all lines.
-- @arg attrTab.xAxis Name of the attribute to be used as x axis (instead of time). In this case,
-- notify() will not need its single argument for plotting Charts.
-- @usage cs = CellularSpace{
--     xdim = 10,
--     value1 = 5,
--     value2 = 7
-- }
--
-- chart = Chart{target = cs}
--
-- print(type(chart))
--
-- world = Cell{
--     susceptible = 498,
--     recovered = 0,
--     infected = 2
-- }
--
-- Chart{
--     target = world,
--     width = 2,
--     select = {"susceptible", "infected", "recovered"},
--     style = {"dots", "steps", "sticks"},
--     color = {"red", "green", "blue"}
-- }
--
-- data = DataFrame{
--     first = 2000,
--     step = 10,
--     demand = {7, 8, 9, 10},
--     limit = {0.1, 0.04, 0.3, 0.07}
-- }
--
-- Chart{
--     target = data,
--     select = "limit",
--     color = "blue"
-- }
function Chart(attrTab)
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

	verifyNamedTable(attrTab)

	verifyUnnecessaryArguments(attrTab, {
		"target", "select", "yLabel", "xLabel",
		"title", "label", "pen", "color", "xAxis", "value",
		"width", "symbol", "style", "size"
	})

	if type(attrTab.target) == "Map" then
		local value = {}
		local color = {}
		local label = {}

		if type(attrTab.target.value) ~= "table" or type(attrTab.target.color) ~= "table" then
			customError("Charts can only be created from Maps that use grouping 'uniquevalue'.")
		end

		forEachElement(attrTab.target.color, function(idx, mcolor)
			if mcolor[1] == 255 and mcolor[2] == 255 and mcolor[3] == 255 then return end

			table.insert(value, attrTab.target.value[idx])
			table.insert(label, attrTab.target.label[idx])
			table.insert(color, mcolor)
		end)

		attrTab.select = attrTab.target.select
		attrTab.target = attrTab.target.target
		attrTab.label = attrTab.target.label
		attrTab.value = value
		attrTab.color = color

		return Chart(attrTab)
	end

	if attrTab.value then
		if not belong(type(attrTab.target), {"CellularSpace", "Society"}) then
			customError("Argument 'value' can only be used with CellularSpace or Society, got "..type(attrTab.target)..".")
		end
	end

	defaultTableValue(attrTab, "yLabel", "")

	if isModel(attrTab.target) then
		defaultTableValue(attrTab, "title", attrTab.target:title())
	else
		defaultTableValue(attrTab, "title", "")
	end

	optionalTableArgument(attrTab, "xAxis", "string")

	if type(attrTab.select) == "string" then attrTab.select = {attrTab.select} end
	if type(attrTab.label)  == "string" then attrTab.label  = {attrTab.label} end

	optionalTableArgument(attrTab, "select", "table")
	optionalTableArgument(attrTab, "label", "table")

	if type(attrTab.target) == "Environment" then
		local c = Cell{}
		local select = {}

		mandatoryTableArgument(attrTab, "select", "table")

		verify(#attrTab.select == 1, "It is not possible to select more than one attribute when creating a Chart from an Environment.")

		local mselect = attrTab.select[1]
		local labels = {}

		forEachModel(attrTab.target, function(value, idx)
			local midx = tostring(idx)
			c[midx] = function() return value[mselect] end
			table.insert(select, midx)

			if type(idx) ~= "string" then
				table.insert(labels, value:title())
			end
		end)

		if #select == 0 then
			customError("There is no Model instance within the Environment.")
		end

		if attrTab.label == nil and #select == #labels then
			attrTab.label = labels
		end

		attrTab.target = c
		attrTab.select = select

		if attrTab.title  == "" then attrTab.title  = nil end

		defaultTableValue(attrTab, "title", _Gtme.stringToLabel(mselect))

		if attrTab.yLabel == "" then attrTab.yLabel = nil end

		return Chart(attrTab)
	else
		mandatoryTableArgument(attrTab, "target")

		if not belong(type(attrTab.target), {"Cell", "CellularSpace", "Agent", "Society", "DataFrame"}) and not isModel(attrTab.target) then
			customError("Invalid type. Charts only work with Cell, CellularSpace, Agent, Society, table, and instance of Model, got "..type(attrTab.target)..".")
		end
	end

	if attrTab.select == nil then
		verify(attrTab.label == nil, "As select is nil, it is not possible to use label.")

		attrTab.select = {}

		if type(attrTab.target) == "Cell" then
			forEachOrderedElement(attrTab.target, function(idx, _, mtype)
				if mtype == "number" and idx ~= "x" and idx ~= "y" and string.sub(idx, -1, -1) ~= "_" then
					if not attrTab.xAxis or idx ~= attrTab.xAxis then
						table.insert(attrTab.select, idx)
					end
				end
			end)
		elseif type(attrTab.target) == "Agent" then
			forEachOrderedElement(attrTab.target, function(idx, _, mtype)
				if mtype == "number" and string.sub(idx, -1, -1) ~= "_" then
					if not attrTab.xAxis or idx ~= attrTab.xAxis then
						table.insert(attrTab.select, idx)
					end
				end
			end)
		elseif type(attrTab.target) == "CellularSpace" then
			forEachOrderedElement(attrTab.target, function(idx, _, mtype)
				if mtype == "number" and not belong(idx, {"xMin", "xMax", "yMin", "yMax", "ydim", "xdim"}) and string.sub(idx, -1, -1) ~= "_" then
					if not attrTab.xAxis or idx ~= attrTab.xAxis then
						table.insert(attrTab.select, idx)
					end
				end
			end)
		elseif type(attrTab.target) == "Society" then
			forEachOrderedElement(attrTab.target, function(idx, _, mtype)
				if mtype == "number" and not belong(idx, {"autoincrement", "observerId"}) and string.sub(idx, -1, -1) ~= "_"  then
					if not attrTab.xAxis or idx ~= attrTab.xAxis then
						table.insert(attrTab.select, idx)
					end
				end
			end)

			if #attrTab.select == 0 then
				attrTab.select = {"#"}
			end
		elseif type(attrTab.target) == "DataFrame" then
			local columns = attrTab.target:columns()
			local row = getNames(attrTab.target:rows())[1]

			forEachOrderedElement(columns, function(idx)
				if type(attrTab.target[idx][row]) == "number" then
					table.insert(attrTab.select, idx)
				end
			end)
		elseif isModel(attrTab.target) then
			forEachOrderedElement(attrTab.target, function(idx, _, mtype)
				if mtype == "number" and not belong(idx, {"finalTime", "seed"}) and string.sub(idx, -1, -1) ~= "_" then
					if not attrTab.xAxis or idx ~= attrTab.xAxis then
						table.insert(attrTab.select, idx)
					end
				end
			end)
		end

		verify(#attrTab.select > 0, "The target does not have at least one valid numeric attribute to be used.")
	elseif type(attrTab.select) == "string" then
		attrTab.select = {attrTab.select}
	else
		optionalTableArgument(attrTab, "select", "table")
	end

	if type(attrTab.target) == "DataFrame" then
		return chartFromData(attrTab)
	end

	forEachElement(attrTab.select, function(_, value)
		if attrTab.target[value] == nil then
			if value == "#" then
				if attrTab.target.obsattrs_ == nil then
					attrTab.target.obsattrs_ = {}
				end

				attrTab.target.obsattrs_["quantity_"] = true
				attrTab.target.quantity_ = #attrTab.target
			else
				local suggestions = {}

				forEachElement(attrTab.target, function(idx, _, mtype)
					if mtype == "number" then
						suggestions[idx] = true
					end
				end)

				local sug = suggestion(value, suggestions)

				local err = "Selected element '"..value.."' does not belong to the target."

				if sug then
					err = err.." Do you mean '"..sug.."'?"
				end

				customError(err)
			end
		elseif type(attrTab.target[value]) == "function" then
			if attrTab.target.obsattrs_ == nil then
				attrTab.target.obsattrs_ = {}
			end

			local output = attrTab.target[value](attrTab.target)

			if type(output) == "table" then
				if not belong(type(attrTab.target), {"CellularSpace", "Society"}) then
					customError("It is only possible to observe functions that return tables using CellularSpace or Society, got "..type(attrTab.target)..".")
				end

				local set

				if type(attrTab.target) == "CellularSpace" then
					set = attrTab.target.cells
				else
					set = attrTab.target.agents
				end

				if not attrTab.value then
					customError("Argument 'value' is mandatory when observing a function that returns a table.")
				end

				mandatoryTableArgument(attrTab, "value", "table")

				forEachElement(attrTab.value, function(_, mvalue)
					if type(mvalue) ~= "string" then
						customError("Argument 'value' should contain only strings, got "..type(mvalue)..".")
					end

					attrTab.target[mvalue] = function()
						local count = 0
						forEachElement(set, function(_, element)
							if element[value] == mvalue then
								count = count + 1
							end
						end)

						return count
					end

					attrTab.target.obsattrs_[mvalue] = true
				end)

				if type(attrTab.color) == "table" then
					verify(#attrTab.value == #attrTab.color, "Arguments 'value' and 'color' should have the same size, got "..#attrTab.value.." and "..#attrTab.color..".")
				end

				attrTab.select = attrTab.value
			else
				attrTab.target.obsattrs_[value] = true
			end
		elseif type(attrTab.target[value]) ~= "number" then
			incompatibleTypeError(value, "number or function", attrTab.target[value])
		end
	end)

	if attrTab.target.obsattrs_ then
		forEachElement(attrTab.target.obsattrs_, function(idx)
			for i = 1, #attrTab.select do
				if attrTab.select[i] == idx then
					attrTab.select[i] = idx.."_"
					local mvalue = attrTab.target[idx](attrTab.target)
					verify(type(mvalue) == "number", "Function '"..idx.. "' returns a non-number value.")
					attrTab.target[idx.."_"] = mvalue
				end
			end
		end)
	end

	verify(#attrTab.select > 0, "Charts must select at least one attribute.")

	for i = 1, #attrTab.select do
		if attrTab.select[i] == "#" then
			attrTab.select[i] = "quantity_"
			attrTab.target.quantity_ = #attrTab.target
		end
	end

	if attrTab.label == nil then
		attrTab.label = {}
		for i = 1, #attrTab.select do
			attrTab.label[i] = _Gtme.stringToLabel(attrTab.select[i])
		end
	end

	verify(#attrTab.select == #attrTab.label, "Arguments 'select' and 'label' should have the same size, got "..#attrTab.select.." and "..#attrTab.label..".")

	if type(attrTab.color) == "table" then
		verify(#attrTab.select == #attrTab.color, "Arguments 'select' and 'color' should have the same size, got "..#attrTab.select.." and "..#attrTab.color..".")

		forEachElement(attrTab.color, function(idx, value)
			if type(value) == "string" then
				if not colors[value] then
					local s = suggestion(value, colors)
					if s then
						customError(switchInvalidArgumentSuggestionMsg(value, "color", s))
					else
						customError("Color '"..value.."' was not found. Check the name or use a table with an RGB description.")
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

	if attrTab.xAxis then
		defaultTableValue(attrTab, "xLabel", _Gtme.stringToLabel(attrTab.xAxis))

		if belong(attrTab.xAxis, attrTab.select) then
			customError("Attribute '"..attrTab.xAxis.."' cannot belong to argument 'select' as it was already selected as 'xAxis'.")
		end

		if type(attrTab.target[attrTab.xAxis]) == "function" then
			if attrTab.target.obsattrs_ == nil then
				attrTab.target.obsattrs_ = {}
			end

			attrTab.target.obsattrs_[attrTab.xAxis] = true
			attrTab.xAxis = attrTab.xAxis.."_"
		end
	else
		defaultTableValue(attrTab, "xLabel", "Time")
	end

	local observerType
	if attrTab.xAxis == nil then
		observerType = 5
	else
		observerType = 4
		table.insert(attrTab.select, attrTab.xAxis)
	end

	local observerParams = {}
	local target = attrTab.target

	local attributes = {}

	forEachElement(attrTab.select, function(_, value)
		attributes[value] = {}
	end)

	attrTab.values = DataFrame(attributes)

	table.insert(observerParams, attrTab.title)
	table.insert(observerParams, attrTab.xLabel)
	table.insert(observerParams, attrTab.yLabel)

	local label = table.concat(attrTab.label, ";")

	table.insert(observerParams, label)

	if type(attrTab.width) == "number" then
		local width = {}
		forEachElement(attrTab.select, function()
			table.insert(width, attrTab.width)
		end)
		attrTab.width = width
	end

	local repeatAttribute = function(att, mtype)
		if type(attrTab[att]) == mtype then
			local vatt = {}
			forEachElement(attrTab.select, function()
				table.insert(vatt, attrTab[att])
			end)
			attrTab[att] = vatt
		end
	end

	repeatAttribute("style",  "string")
	repeatAttribute("symbol", "string")
	repeatAttribute("pen",    "string")
	repeatAttribute("size",   "number")
	repeatAttribute("color",  "string")

	optionalTableArgument(attrTab, "width",  "table")
	optionalTableArgument(attrTab, "style",  "table")
	optionalTableArgument(attrTab, "symbol", "table")
	optionalTableArgument(attrTab, "pen",    "table")
	optionalTableArgument(attrTab, "size",   "table")
	optionalTableArgument(attrTab, "color",  "table")

	if attrTab.size then
		forEachElement(attrTab.size, function(_, value)
			if value < 0 then
				customError(positiveArgumentMsg("size", value))
			end
		end)
	end

	if attrTab.width then
		forEachElement(attrTab.width, function(_, value)
			if value <= 0 then
				incompatibleValueError("width", "greater than zero", value)
			end
		end)
	end

	if attrTab.symbol then
		local symbol = {}
		forEachElement(attrTab.symbol, function(idx, value)
			symbol[idx] = symbolTable[value]
			if not symbol[idx] then
				switchInvalidArgument("symbol", value, symbolTable)
			end
		end)
		attrTab.symbol = symbol
	end

	if attrTab.pen then
		local pen = {}
		forEachElement(attrTab.pen, function(idx, value)
			pen[idx] = penTable[value]
			if not pen[idx] then
				switchInvalidArgument("pen", value, penTable)
			end
		end)
		attrTab.pen = pen
	end

	if attrTab.style then
		forEachElement(attrTab.style, function(_, value)
			if not styleTable[value] then
				switchInvalidArgument("style", value, styleTable)
			end
		end)
	end

	-- Legend
	local defaultColors = {"red", "green", "blue", "yellow", "brown", "magenta", "orange", "purple", "cyan", "black"}

	if #attrTab.select > 10 and not attrTab.color then
		customError("Argument color is compulsory when using more than 10 attributes.")
	end

	local i = 1
	forEachElement(attrTab.select, function()
		local width = 2
		if attrTab.width then
			width = attrTab.width[i]
		end

		local style = "lines"
		if attrTab.style then
			style = attrTab.style[i]
		end

		local symbol = symbolTable.none
		if attrTab.symbol then
			symbol = attrTab.symbol[i]
		end

		local pen = penTable.solid
		if attrTab.pen then
			pen = attrTab.pen[i]
		end

		local size = 7
		if attrTab.size then
			size = attrTab.size[i]
		end

		local color = defaultColors[i]
		if attrTab.color then
			color = attrTab.color[i]
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
		id, obs = target.cObj_:createObserver(observerType, {}, attrTab.select, observerParams, target.cells)
	else
		if type(target) == "Society" then
			target.observerId = 1 -- TODO: verify why this line is necessary
		end
		id, obs = target.cObj_:createObserver(observerType, attrTab.select, observerParams)
	end

	local chart = TeChart()
	chart:setObserver(obs)

	attrTab.cObj_ = chart
	attrTab.id = id

	setmetatable(attrTab, metaTableChart_)
    table.insert(_Gtme.createdObservers, attrTab)
	return attrTab
end

