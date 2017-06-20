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

-- Colors --------------------------------------------------------------------------

-- Based on color table at http://gucky.uni-muenster.de/cgi-bin/rgbtab-en
local TME_LEGEND_COLOR = {
	BLACK           = {  0,   0,   0},
	WHITE           = {255, 255, 255},
	LIGHTRED        = {255, 102, 102},
	RED             = {255,   0,   0},
	DARKRED         = {128,   0,   0},
	LIGHTYELLOW     = {255, 255, 153},
	YELLOW          = {255, 255,   0},
	DARKYELLOW      = {255, 215,   0},
	LIGHTORANGE     = {255, 180,   0},
	ORANGE          = {238, 154,   0},
	DARKORANGE      = {205, 103,   0},
	LIGHTBROWN      = {128,  85,  85},
	BROWN           = {128,  64,  64},
	DARKBROWN       = {108,  53,  53},
	LIGHTGREEN      = {153, 255, 153},
	GREEN           = {  0, 255,   0},
	DARKGREEN       = {  0, 128,   0},
	LIGHTCYAN       = {128, 255, 255},
	CYAN            = {  0, 255, 255},
	DARKCYAN        = {  0, 128, 128},
	LIGHTBLUE       = {173, 216, 230},
	BLUE            = {  0,   0, 255},
	DARKBLUE        = {  0,   0, 128},
	LIGHTGRAY       = {200, 200, 200},
	GRAY            = {160, 160, 160},
	DARKGRAY        = {128, 128, 128},
	LIGHTMAGENTA    = {255, 128, 255},
	MAGENTA         = {255,   0, 255},
	DARKMAGENTA     = {139,   0, 139},
	LIGHTPURPLE     = {155, 048, 255},
	PURPLE          = {125, 038, 205},
	DARKPURPLE      = {085, 026, 139}
}

local TME_LEGEND_COLOR_USER = {
	["black"]           = TME_LEGEND_COLOR.BLACK,
	["white"]           = TME_LEGEND_COLOR.WHITE,
	["lightRed"]        = TME_LEGEND_COLOR.LIGHTRED,
	["red"]             = TME_LEGEND_COLOR.RED,
	["darkRed"]         = TME_LEGEND_COLOR.DARKRED,
	["lightYellow"]     = TME_LEGEND_COLOR.LIGHTYELLOW,
	["yellow"]          = TME_LEGEND_COLOR.YELLOW,
	["darkyellow"]      = TME_LEGEND_COLOR.DARKYELLOW,
	["lightOrange"]     = TME_LEGEND_COLOR.LIGHTORANGE,
	["orange"]          = TME_LEGEND_COLOR.ORANGE,
	["darkOrange"]      = TME_LEGEND_COLOR.DARKORANGE,
	["lightBrown"]      = TME_LEGEND_COLOR.LIGHTBROWN,
	["brown"]           = TME_LEGEND_COLOR.BROWN,
	["darkBrown"]       = TME_LEGEND_COLOR.DARKBROWN,
	["lightGreen"]      = TME_LEGEND_COLOR.LIGHTGREEN,
	["green"]           = TME_LEGEND_COLOR.GREEN,
	["darkGreen"]       = TME_LEGEND_COLOR.DARKGREEN,
	["lightCyan"]       = TME_LEGEND_COLOR.LIGHTCYAN,
	["cyan"]            = TME_LEGEND_COLOR.CYAN,
	["darkCyan"]        = TME_LEGEND_COLOR.DARKCYAN,
	["lightBlue"]        = TME_LEGEND_COLOR.LIGHTBLUE,
	["blue"]            = TME_LEGEND_COLOR.BLUE,
	["darkBlue"]        = TME_LEGEND_COLOR.DARKBLUE,
	["lightGray"]       = TME_LEGEND_COLOR.LIGHTGRAY,
	["gray"]            = TME_LEGEND_COLOR.GRAY,
	["darkGray"]        = TME_LEGEND_COLOR.DARKGRAY,
	["lightMagenta"]    = TME_LEGEND_COLOR.LIGHTMAGENTA,
	["magenta"]         = TME_LEGEND_COLOR.MAGENTA,
	["darkMagenta"]     = TME_LEGEND_COLOR.DARKMAGENTA,
	["lightPurple"]     = TME_LEGEND_COLOR.LIGHTPURPLE,
	["purple"]          = TME_LEGEND_COLOR.PURPLE,
	["darkPurple"]      = TME_LEGEND_COLOR.DARKPURPLE
}

-- Data Types --------------------------------------------------------------------------
local TME_LEGEND_TYPE = {
	BOOL     = 0,
	NUMBER   = 1,
	DATETIME = 2,
	TEXT     = 3
}

local TME_LEGEND_TYPE_USER = {
	["bool"]     = TME_LEGEND_TYPE.BOOL,
	["number"]   = TME_LEGEND_TYPE.NUMBER,
	["datetime"] = TME_LEGEND_TYPE.DATETIME,
	["string"]   = TME_LEGEND_TYPE.TEXT
}

-- Groupping Types --------------------------------------------------------------------
local TME_LEGEND_GROUPING = {
	EQUALSTEPS   = 0,
	QUANTIL      = 1,
	STDDEVIATION = 2,
	UNIQUEVALUE  = 3
}

local TME_LEGEND_GROUPING_USER = {
	["equalsteps"]   = TME_LEGEND_GROUPING.EQUALSTEPS,
	["quantil"]      = TME_LEGEND_GROUPING.QUANTIL,
	["stddeviation"] = TME_LEGEND_GROUPING.STDDEVIATION,
	["uniquevalue"]  = TME_LEGEND_GROUPING.UNIQUEVALUE
}

-- Standard Deviation Types -----------------------------------------------------------
local TME_LEGEND_STDDEVIATION = {
	NONE    = -1,
	FULL    =  0,
	HALF    =  1,
	QUARTER =  2
}

local TME_LEGEND_STDDEVIATION_USER = {
	["none"]    = TME_LEGEND_STDDEVIATION.NONE,
	["full"]    = TME_LEGEND_STDDEVIATION.FULL,
	["half"]    = TME_LEGEND_STDDEVIATION.HALF,
	["quarter"] = TME_LEGEND_STDDEVIATION.QUARTER
}

-- Curve legend position -----------------------------------------------------------
-- Based on Qwt library (see QwtPlot::LegendPosition)
-- TME_LEGEND_CURVE_LEGEND_POSITION = {
-- LEFT      = 0,
-- RIGHT     = 1,
-- BOTTOM    = 2,
-- TOP       = 3
-- }

-- TME_LEGEND_CURVE_LEGEND_POSITION_USER = {
-- ["top"]     = TME_LEGEND_CURVE_LEGEND_POSITION.LEFT,
-- ["right"]   = TME_LEGEND_CURVE_LEGEND_POSITION.RIGHT,
-- ["bottom"]  = TME_LEGEND_CURVE_LEGEND_POSITION.BOTTOM,
-- ["top"]     = TME_LEGEND_CURVE_LEGEND_POSITION.TOP
-- }

-- Curve style -----------------------------------------------------------
-- Based on Qwt library (see QwtPlotCurve::CurveStyle)
local TME_LEGEND_CURVE_STYLE = {
	NOCURVE = -1,
	LINES   = 0,
	STICKS  = 1,
	STEPS   = 2,
	DOTS    = 3
}

local TME_LEGEND_CURVE_STYLE_USER = {
	["none"]   = TME_LEGEND_CURVE_STYLE.NOCURVE,
	["lines"]  = TME_LEGEND_CURVE_STYLE.LINES,
	["sticks"] = TME_LEGEND_CURVE_STYLE.STICKS,
	["steps"]  = TME_LEGEND_CURVE_STYLE.STEPS,
	["dots"]   = TME_LEGEND_CURVE_STYLE.DOTS
}

-- LEGEND CREATION FUNCTIONS
local DEF_GROUP = TME_LEGEND_GROUPING.EQUALSTEPS
local DEF_SLICES = 2
local DEF_PRECISION = 4
local DEF_STD_DEV = TME_LEGEND_STDDEVIATION.NONE
local DEF_MAX = 100
local DEF_MIN = 0
local DEF_COLOR = { {color = TME_LEGEND_COLOR.WHITE, value = DEF_MIN }, {color = TME_LEGEND_COLOR.BLACK, value = DEF_MAX }}
local DEF_STD_COLOR = { {color = TME_LEGEND_COLOR.BLACK, value = DEF_MIN }, {color = TME_LEGEND_COLOR.WHITE, value = DEF_MAX }}
local DEF_FONT = "Symbol"
local DEF_FONT_SIZE = 12
local DEF_FONT_SYMBOL = string.char(174) -- arrow in the font Symbol
local DEF_WIDTH = 2 -- 5
local DEF_CURVE_STYLE = TME_LEGEND_CURVE_STYLE.LINES

-- Convert the colorBar for a string
-- Output format:
--   colorBar = color table; value; label; distance;#color table; value; label; distance;
local function colorBarToString(colorBar)
	local str = ""

	if type(colorBar) ~= "table" then
		str = DEF_COLOR
		return str
	end

	local COMP_COLOR_SEP = ","
	local ITEM_SEP = ";"
	local ITEM_NULL = "?"
	local COLORS_SEP = "#"

	for _,item in pairs(colorBar) do
		if type(item.color) == "table" then
			if #item.color == 3 or #item.color == 4 then
				str = str .. item.color[1] .. COMP_COLOR_SEP
				.. item.color[2] .. COMP_COLOR_SEP
				.. item.color[3]

				if item.color[4] ~= nil then
					str = str .. COMP_COLOR_SEP .. item.color[4] .. COMP_COLOR_SEP
				end
				str = str .. ITEM_SEP
			else
				customError("Invalid color in 'colorBar'.", 3)
			end
		end

		if item.value ~= nil then
			str = str .. tostring(item.value) .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end

		if item.label ~= nil and type(item.label) == "string" then
			str = str .. item.label .. ITEM_SEP
		elseif item.value ~= nil then
			local val
			if type(item.value) == "boolean" then
				val = 0
				if item.value == true then val = 1 end
			else
				val = item.value
			end
			str = str .. val .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end

		if item.distance ~= nil and type(item.distance == "number") then
			str = str .. item.distance .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end
		str = str .. COLORS_SEP
	end
	return str
end

-- Separator for color bars
local COLORBAR_SEP = "|"

local legendPossibleParams = {
	"grouping",
	"type",
	"slices",
	"precision",
	"stdDeviation",
	"maximum",
	"minimum",
	"width",
	"colorBar",
	"stdColorBar",
	"font",
	"fontSize",
	"symbol",
	"style",
	"pen",
	"size"
}

Legend_ = {
	type_ = "Legend"
}

local metaTableLegend_ = {__index = Legend_, __tostring = tostringTerraME}
--- Type that defines how to color an attribute to be observed. It is used only with a map
-- Observer. The configuration of a legend can be changed visually by double clicking the
-- graphical interface along the simulation.
-- @arg data A table
-- @arg data.grouping A string with the strategy to slice and color the data. See below.
-- @arg data.type The type of the attribute to be observed. It has to be one of "bool",
-- "number", "string", and "datetime" (an ordered string).
-- @arg data.slices The number of colors to be used for plotting. It must be an integer
-- number greater than one.
-- @arg data.precision The number of decimal digits for slicing. It must be an integer
-- number greater than zero. It indicates that differences less than 10^(-digits) will
-- not be considered. It means that, for instance, if a slice is in the interval [1.0, 2.0]
-- and precision is 2 (0.01), a value 0.99 might belong to such slice.
-- @arg data.stdDeviation When the grouping mode is stddeviation, it has to be one of "full",
-- "half" "quarter", or "none".
-- @arg data.maximum The maximum value of the attribute (used only for numbers).
-- @arg data.minimum The minimum value of the attribute (used only for numbers).
-- @arg data.width The width of the line to be drawn. Used for drawing Neighborhoods (default is 10).
-- @arg data.symbol A symbol to draw Agents. It can be one of: "none", "ellipse", "rect",
-- "diamond", "triangle", "dtriangle", "utriangle", "ltriangle", "rtriangle", "cross", "xcross",
-- "hline", "vline", "asterisk", "star", "hexagon". Default is an arrow.
-- @arg data.font A string with the font used to draw each Agent. Default is "Symbol".
-- @arg data.fontSize An integer positive number indicating the font size. Default is 12.
-- @arg data.colorBar A table where each position is a table with a 'color', a 'value', and a
-- 'label' (optional). Colors can be described as string ("red", "green", "blue", "white", "black",
-- "yellow", "brown", "cyan", "gray", "magenta", "orange", "purple", and their light and dark
-- compositions, such as "lightGray" and "darkGray"), or as tables with three integer numbers
-- representing RGB compositions. Labels are strings that will be shown in the graphical
-- interface describing the colors.
-- @arg data.stdColorBar A table just as colorBar. It is needed only when standard deviation is
-- the chosen strategy.
-- @tabular grouping
-- Grouping & Description & Compulsory arguments & Optional arguments\
-- "equalsteps" &The values are divided into a set of slices with the same range. Each slice is
-- associated to a given color. Equalsteps require only two colors in the colorBar, one for the
-- minimum and the other for the maximum value. The other colors are computed from a linear
-- interpolation of the two colors. &colorBar, slices, maximum, minimum & precision, type, width,
-- font, fontSize, symbol \
-- "quantil" & Aggregate the values into slices with approximately the same size. Values are
-- ordered from lower to higher and then sliced. This strategy uses two colors in the same way
-- of equalsteps. & colorBar, slices, maximum, minimum & precision, type, width \
-- "stdeviation" & Define slices according to the distribution of a given attribute. Values with
-- similar positive or negative distances to the average will belong to the same slice. &
-- colorBar, stdColorBar & stdDeviation, precision, type, width \
-- "uniquevalue" & Associate each attribute value to a given color. Attributes with type string can
-- only be sliced with this strategy. &colorBar & type, width
--
-- @usage coverLeg = Legend {
--     grouping = "uniquevalue",
--     colorBar = {
--         {value = 0, color = "white"},
--         {value = 1, color = "red"},
--         {value = 2, color = "green"}
--     }
-- }
--
-- deforLeg = Legend {
--     grouping = "equalsteps",
--     slices = 10,
--     colorBar = {
--         {value = 0, color = "green"},
--         {value = 1, color = "red"}
--     }
-- }
function _Gtme.Legend(data)
	if type(data) ~= "table" then
		if data == nil then
			tableArgumentError("Legend", 3)
		else
			namedArgumentsError("Legend", 3)
		end
	end

	setmetatable(data, metaTableLegend_)

	verifyUnnecessaryArguments(data, legendPossibleParams)

	-- conversion of string values from user layer
	if type(data.type) == "string" then
		data.type = TME_LEGEND_TYPE_USER[data.type]
	end

	if type(data.grouping) == "string" then
		data.grouping = TME_LEGEND_GROUPING_USER[data.grouping]
	end

	if type(data.stdDeviation) == "string" then
		data.stdDeviation = TME_LEGEND_STDDEVIATION_USER[data.stdDeviation]
	end

	if type(data.style) == "string" then
		data.style = TME_LEGEND_CURVE_STYLE_USER[data.style]
	end

	if not data.colorBar or (type(data.colorBar) == "table" and #data.colorBar == 0) then
		data.colorBar = nil
	elseif type(data.colorBar) ~= "table" then
		incompatibleTypeError("colorBar", "table", data.colorBar, 3)
	end

	if data.stdColorBar and type(data.stdColorBar) == "table" and #data.stdColorBar == 0 then
		data.stdColorBar = nil
	end

	-- LEGEND PARAMETERS SETUP
	-- colorBar setup
	if data.colorBar == nil then
		if data.type ~= nil then
			if data.type == TME_LEGEND_TYPE.NUMBER then
				local max, min = nil
				if data.maximum ~= nil then max = data.maximum end
				if data.minimum ~= nil then min = data.minimum end
				if max == nil then max = DEF_MAX end
				if min == nil then min = DEF_MIN end
				data.colorBar = {
					{color = TME_LEGEND_COLOR.RED, value = min},
					{color = TME_LEGEND_COLOR.BLACK, value = max}
				}
			end

			if data.type == TME_LEGEND_TYPE.BOOL then
				data.colorBar = {
					{color = TME_LEGEND_COLOR.BLACK, value = false},
					{color = TME_LEGEND_COLOR.WHITE, value = true}
				}
				data.maximum = 1
				data.minimum = 0
				data.grouping = TME_LEGEND_GROUPING.UNIQUEVALUE
			end

			if data.type == TME_LEGEND_TYPE.TEXT then
				data.colorBar = {
					{color = TME_LEGEND_COLOR.BLACK, value = "BLACK"},
					{color = TME_LEGEND_COLOR.WHITE, value = "WHITE"}
				}
			end

			if data.type == TME_LEGEND_TYPE.DATETIME then
				data.colorBar = {
					{color = TME_LEGEND_COLOR.BLACK, value = "2012-01-01 00:00:00"},
					{color = TME_LEGEND_COLOR.WHITE, value = "2012-01-31 00:00:00"}
				}
			end
		else
			customError("Could not infer colorBar.")
		end
	else
		local theType
		for i = 1, #data.colorBar do
			if type(data.colorBar[i].color) == "string" then
				local colorName = data.colorBar[i].color
				data.colorBar[i].color = TME_LEGEND_COLOR_USER[data.colorBar[i].color]

				if data.colorBar[i].color == nil then
					customError("Color '" .. colorName .. "' was not found. Please, check the color name or set its value using a table with the RGB composition.", 3)
				end
			end

			local value = data.colorBar[i].value
			local vtype = type(value)
			if theType == nil then
				theType = vtype
			else
				if vtype ~= theType then
					customError("Each 'value' within colorBar should have the same type.", 3)
				end
			end
		end
	end

	if type(data.colorBar) == "table" then
		if #data.colorBar <= 1 and (data.grouping == "equalsteps" or data.grouping == TME_LEGEND_GROUPING_USER.equalsteps or data.grouping == "stddeviation" or data.grouping == TME_LEGEND_GROUPING_USER.stddeviation) then
			customError("Argument 'colorBar' requires at least two colors.", 3)
		end
	end

	-- stdColorBar setup
	if data.stdColorBar == nil then
		if data.grouping == TME_LEGEND_GROUPING.STDDEVIATION then
			data.stdColorBar = DEF_STD_COLOR
		end
	else
		for i = 1, #data.stdColorBar do
			if type(data.stdColorBar[i].color) == "string" then
				data.stdColorBar[i].color = TME_LEGEND_COLOR_USER[data.stdColorBar[i].color]
			end
		end
	end

	if data.maximum == nil then
		if data.colorBar ~= nil then
			local colorBarValues = {}
			local t = type(data.colorBar[1].value)
			if t == "number" then
				for i = 1, #data.colorBar do
					table.insert(colorBarValues, data.colorBar[i].value)
				end

				if #colorBarValues > 0 and type(colorBarValues[1]) == "number" then
					-- returns 'too many results to unpack' when colorBarValues is a big set
					-- data.maximum = math.max(unpack(colorBarValues))
					local auxMax = -9999999999999
					for i = 1, #colorBarValues do
						if colorBarValues[i] > auxMax then
							auxMax = colorBarValues[i]
						end
					end
					data.maximum = auxMax
				else
					data.maximum = #data.colorBar
				end
			else
				data.maximum = #data.colorBar
			end
		else
			data.maximum = DEF_MAX
		end
	end

	if data.minimum == nil then
		if data.colorBar ~= nil then
			local colorBarValues = {}
			for i = 1, #data.colorBar do
				table.insert(colorBarValues, data.colorBar[i].value)
			end

			if #colorBarValues > 0 and type(colorBarValues[1]) == "number" then
				-- returns 'too many results to unpack' when colorBarValues is a big set
				-- .minimum = math.min(unpack(colorBarValues))
				local auxMin = 9999999999999
				for i = 1, #colorBarValues do
					if colorBarValues[i] < auxMin then
						auxMin = colorBarValues[i]
					end
				end
				data.minimum = auxMin
			else
				data.minimum = 1
			end
		else
			data.minimum = DEF_MIN
		end
	end

	if data.type == nil then
		if data.colorBar ~= nil then
			local theType = type(data.colorBar[1].value) -- it was already checked that values have the same type

			if theType == "number"  then data.type = TME_LEGEND_TYPE.NUMBER end
			if theType == "string"  then data.type = TME_LEGEND_TYPE.TEXT end
			if theType == "boolean" then data.type = TME_LEGEND_TYPE.BOOL end
			if theType == "date"    then data.type = TME_LEGEND_TYPE.DATETIME end -- FIXME: 'date' is not a Lua type. The code will never enter here.
		end
	end

	-- stdDeviation setup
	if data.stdDeviation == nil then
		data.stdDeviation = DEF_STD_DEV
	end

	-- grouping setup
	if data.grouping == nil then
		if (data.colorBar ~= nil and #data.colorBar > 2) or
		(data.type ~= nil and data.type == TME_LEGEND_TYPE.TEXT) then
			data.grouping = TME_LEGEND_GROUPING.UNIQUEVALUE
		end

		if data.stdColorBar ~= nil then
			data.grouping = TME_LEGEND_GROUPING.STDDEVIATION
		end

		if data.grouping == nil then data.grouping = DEF_GROUP end
	end

	-- slices setup
	if data.slices == nil then
		if data.grouping == TME_LEGEND_GROUPING.UNIQUEVALUE then
			if data.colorBar ~= nil then data.slices = #data.colorBar end
		else
			data.slices = DEF_SLICES
		end
	else
		if type(data.slices) ~= "number" then
			incompatibleTypeError("slices", "integer number between 1 and 255", data.slices, 3)
		end

		local _, fracPart = math.modf(data.slices)
		if data.slices > 255 then
			incompatibleValueError("slices", "integer number between 1 and 255", data.slices, 3)
		elseif data.slices < 1 then
			incompatibleValueError("slices", "integer number between 1 and 255", data.slices, 3)
		elseif fracPart ~= 0 then
			incompatibleValueError("slices", "integer number between 1 and 255", data.slices, 3)
		end
	end

	-- Verify if the number of slices is smaller than or equal the number of available colors
	if type(data.colorBar) == "table" and data.slices > 1 then
		local diffR = 0
		local diffG = 0
		local diffB = 0
		for k = 1, #data.colorBar - 1, 1 do
			local color = data.colorBar[k].color
			local nextColor = data.colorBar[k + 1].color

			diffR = diffR + math.abs(nextColor[1] - color[1])
			diffG = diffG + math.abs(nextColor[2] - color[2])
			diffB = diffB + math.abs(nextColor[3] - color[3])
		end

		local maxDiff = math.max(diffR, diffG, diffB)

		if data.slices > maxDiff then
			customError("Number of slices ("..data.slices..") is larger than the number of available colors. Using these colors, you can define a maximum of "..maxDiff.." slices.", 3)
		end
	end
	-- precision setup
	if data.precision == nil then
		if data.colorBar ~= nil then
			local colorBarValues = {}
			local t = type(data.colorBar[1].value)
			if t == "number" then
				for i = 1, #data.colorBar do
					table.insert(colorBarValues, data.colorBar[i].value)
				end

				-- find max precision using colorBar values
				local precisions = {}
				for i = 1, #colorBarValues do
					local strValue = "".. colorBarValues[i]
					local beginI = string.find(strValue, "%.")

					if beginI ~= nil then
						local subStrValue = string.sub(strValue,beginI+1)
						table.insert(precisions,#subStrValue)
					end
				end
				if #precisions > 0 then
					--.precision = math.max(unpack(precisions))
					data.precision = math.max(table.unpack(precisions))
				else
					data.precision = DEF_PRECISION
				end
			else
				data.precision = DEF_PRECISION
			end
		else
			data.precision = DEF_PRECISION
		end
	else
		if type(data.precision) ~= "number" then
			incompatibleTypeError("precision", "integer number greater than or equal to 1 (one)", data.precision, 3)
		end

		local _, fracPart = math.modf(data.precision)
		if data.precision < 1 then
			incompatibleValueError("precision", "integer number greater than or equal to 1 (one)", data.precision, 3)
		elseif fracPart ~= 0 then
			incompatibleValueError("precision", "integer number greater than or equal to 1 (one)", data.precision, 3)
		end
	end

	if data.font     == nil then data.font     = DEF_FONT        end
	if data.fontSize == nil then data.fontSize = DEF_FONT_SIZE   end
	if data.symbol   == nil then data.symbol   = DEF_FONT_SYMBOL end
	if data.style    == nil then data.style    = DEF_CURVE_STYLE end
	if data.width    == nil then data.width    = DEF_WIDTH       end

	if data.width < 1 then
		customError("width", "greater than or equal to one", data.width, 3)
	end

	-- colorBar and stdColorBar setup complement
	if type(data.colorBar) == "table" then
		data.colorBar = colorBarToString(data.colorBar)
	else
		--customWarning("Warning: Attribute 'colorBar' should be a table, got a ".. type(data.colorBar) .. ". Using default color bar.", 4)
		data.colorBar = colorBarToString(DEF_COLOR)
	end

	if data.stdColorBar then
		if type(data.stdColorBar) == "table" then
			if #data.stdColorBar > 2 then
				data.stdColorBar = colorBarToString(data.stdColorBar)
			else
				customWarning("Warning: Attribute 'stdColorBar' is incomplete.", 4)
			end
		elseif type(data.stdColorBar) ~= "string" then
			incompatibleTypeError("stdColorBar","table", data.stdColorBar, 4)
		end
		data.colorBar = data.colorBar .. COLORBAR_SEP .. data.stdColorBar
		-- it is not necessary to keep 'stdColorBar' as it is attached to 'colorBar'
		data.stdColorBar = nil
	end

	return data
end

-- Convert a given string to a readable text. It converts the first character
-- of the string to uppercase. If the string contains underscores, it
-- replaces them by spaces and convert the next characters to uppercase.
-- Otherwise, it adds a space before each uppercase characters.
-- @arg mstring A string.
-- @arg parent A string with the table name where the string is stored. If used,
-- the return value will be appended by this value between parenthesis.
function _Gtme.stringToLabel(mstring, parent)
	if type(mstring) == "number" then
		return tostring(mstring)
	end

	mandatoryArgument(1, "string", mstring)
	optionalArgument(2, "string", parent)

	local result = string.upper(string.sub(mstring, 1, 1))
	local size = string.len(mstring)

	if string.sub(mstring, size, size) == "_" then
		mstring = string.sub(mstring, 1, size - 1)
	end

	local find = string.find(mstring, "_")

	if find then
		local i = 2
		while i <= mstring:len() do
			local char = string.sub(mstring, i, i)
			local nextchar = string.sub(mstring, i + 1, i + 1)

			if char == "_" then
				nextchar = string.upper(nextchar)
				result = result.." "..nextchar
				i = i + 1
			else
				result = result..char
			end

			i = i + 1
		end
	else
		mstring = string.sub(mstring, 2)
		local nextu = string.match(mstring, "%u")
		local nextd = string.match(mstring, "%d")

		local prevu = false
		local prevd = false

		if tostring(tonumber(result)) == result then
			prevd = true
		end

		for i = 1, mstring:len() do
			local nextchar = string.sub(mstring, i, i)

			if nextchar == nextu then
				if not prevu then
					result = result.." "
				end

				result = result..nextu

				nextu = string.match(string.sub(mstring, i + 1, mstring:len()), "%u")
				prevd = false
				prevu = true
			elseif nextchar == nextd then
				if not prevd then
					result = result.." "
				end

				result = result..nextd
				nextd = string.match(string.sub(mstring, i + 1, mstring:len()), "%d")
				prevu = false
				prevd = true
			else
				result = result..nextchar
				prevu = false
				prevd = false
			end
		end
	end

	if parent then
		return result.." (in ".._Gtme.stringToLabel(parent)..")"
	else
		return result
	end
end

function _Gtme.cleanErrorMessage(err)
	local match = string.find(err, ":")
	local str = string.sub(err, match + 1)
	match = string.find(str, ":")
	str = string.sub(str, match + 2)

	return str
end

_Gtme.internalCellVariables = {
	agents = true,
	cObj_ = true,
	geom = true,
	neighborhoods = true,
	parent = true,
	past = true,
	placement = true,
	x = true,
	y = true
}

_Gtme.internalAgentVariables = {
	cell = true,
	cells = true,
	cObj_ = true,
	geometry = true,
	id = true,
	parent = true,
	placement = true,
	socialnetworks = true,
	state_ = true
}

