-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright © 2001-2012 INPE and TerraLAB/UFOP -- www.terrame.org
--
--  Legend Objects for TerraME
--  Last change: April/2012
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
-- Authors:
--      Antonio Jose da Cunha Rodrigues
--      Rodrigo Reis Pereira
--      Henrique Cota Camello

-- Colors --------------------------------------------------------------------------

-- @DANIEL: Based on color table at http://gucky.uni-muenster.de/cgi-bin/rgbtab-en
TME_LEGEND_COLOR = {
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

TME_LEGEND_COLOR_USER = {
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
	["lighBlue"]        = TME_LEGEND_COLOR.LIGHTBLUE,
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
TME_LEGEND_TYPE = {
	BOOL     = 0,
	NUMBER   = 1,
	DATETIME = 2,
	TEXT     = 3
}

TME_LEGEND_TYPE_USER = {
	["bool"]     = TME_LEGEND_TYPE.BOOL,
	["number"]   = TME_LEGEND_TYPE.NUMBER,
	["datetime"] = TME_LEGEND_TYPE.DATETIME,
	["string"]   = TME_LEGEND_TYPE.TEXT
}

-- Groupping Types --------------------------------------------------------------------
TME_LEGEND_GROUPING = {
	EQUALSTEPS   = 0,
	QUANTIL      = 1,
	STDDEVIATION = 2,
	UNIQUEVALUE  = 3
}

TME_LEGEND_GROUPING_USER = {
	["equalsteps"]   = TME_LEGEND_GROUPING.EQUALSTEPS,
	["quantil"]      = TME_LEGEND_GROUPING.QUANTIL,
	["stddeviation"] = TME_LEGEND_GROUPING.STDDEVIATION,
	["uniquevalue"]  = TME_LEGEND_GROUPING.UNIQUEVALUE
}

-- Standard Deviation Types -----------------------------------------------------------
TME_LEGEND_STDDEVIATION = {
	NONE    = -1,
	FULL    =  0,
	HALF    =  1,
	QUARTER =  2
}

TME_LEGEND_STDDEVIATION_USER = {
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
TME_LEGEND_CURVE_STYLE = {
	NOCURVE 	= 0,
	LINES		= 1,
	STICKS		= 2,
	STEPS		= 3,
	DOTS		= 4
}

TME_LEGEND_CURVE_STYLE_USER = {
	["none"] 		= TME_LEGEND_CURVE_STYLE.NOCURVE,
	["lines"]		= TME_LEGEND_CURVE_STYLE.LINES,
	["sticks"]	= TME_LEGEND_CURVE_STYLE.STICKS,
	["steps"]		= TME_LEGEND_CURVE_STYLE.STEPS,
	["dots"]		= TME_LEGEND_CURVE_STYLE.DOTS
}

-- Curve symbol -----------------------------------------------------------
-- Based on Qwt library (see QwtSymbol::Style)
TME_LEGEND_CURVE_SYMBOL = {
	NOSYMBOL    = -1,
	ELLIPSE     =  0,
	RECT        =  1,
	DIAMOND     =  2,
	TRIANGLE    =  3,
	DTRIANGLE   =  4,
	UTRIANGLE   =  5,
	LTRIANGLE   =  6,
	RTRIANGLE   =  7,
	CROSS       =  8,
	XCROSS      =  9,
	HLINE       = 10,
	VLINE       = 11,
	ASTERISK    = 12,
	STAR2       = 13,
	HEXAGON     = 14 
}

TME_LEGEND_CURVE_SYMBOL_USER = {
	["none"] 		= TME_LEGEND_CURVE_SYMBOL.NOSYMBOL,
	["ellipse"]	= TME_LEGEND_CURVE_SYMBOL.ELLIPSE,
	["rect"]		= TME_LEGEND_CURVE_SYMBOL.RECT,
	["diamond"]	= TME_LEGEND_CURVE_SYMBOL.DIAMOND,
	["triangle"]	= TME_LEGEND_CURVE_SYMBOL.TRIANGLE,
	["dtriangle"]	= TME_LEGEND_CURVE_SYMBOL.DTRIANGLE,
	["utriangle"]	= TME_LEGEND_CURVE_SYMBOL.UTRIANGLE,
	["ltriangle"]	= TME_LEGEND_CURVE_SYMBOL.LTRIANGLE,
	["rtriangle"]	= TME_LEGEND_CURVE_SYMBOL.RTRIANGLE,
	["cross"]		= TME_LEGEND_CURVE_SYMBOL.CROSS,
	["xcross"]	= TME_LEGEND_CURVE_SYMBOL.XCROSS,
	["hline"]		= TME_LEGEND_CURVE_SYMBOL.HLINE,
	["vline"]		= TME_LEGEND_CURVE_SYMBOL.VLINE,
	["asterisk"]	= TME_LEGEND_CURVE_SYMBOL.ASTERISK,
	["star"]		= TME_LEGEND_CURVE_SYMBOL.STAR2,
	["hexagon"]   = TME_LEGEND_CURVE_SYMBOL.HEXAGON,  
}

----------------------------------------------------------------------------------------------
-- Legend keys
local LEG_KEYS = {
	type = "type" ,
	grouping = "grouping",
	slices = "slices",
	precision = "precision",
	stdDeviation = "stdDeviation",
	maximum = "maximum",
	minimum = "minimum",
	colorBar = "colorBar",
	stdColorBar = "stdColorBar",
	font = "font",
	fontSize = "fontSize",
	symbol = "symbol",
	width = "width",
	style = "style"
}

----------------------------------------------------------------------------------------------
-- LEGEND CREATION FUNCTIONS
local DEF_TYPE = TME_LEGEND_TYPE.NUMBER
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
local DEF_FONT_SYMBOL = "®" -- equivale a seta na fonte symbol
local DEF_WIDTH = 2 -- 5
local DEF_CURVE_STYLE = TME_LEGEND_CURVE_STYLE.LINES
local DEF_CURVE_SYMBOL = TME_LEGEND_CURVE_SYMBOL.NOSYMBOL

local function defaultBasicLegend()
	data = {}
	data.type = DEF_TYPE
	data.grouping = DEF_GROUP
	data.slices = DEF_SLICES
	data.precision = DEF_PRECISION
	data.stdDeviation = DEF_STD_DEV
	data.maximum = DEF_MAX
	data.minimum = DEF_MIN
	data.colorBar = DEF_COLOR
	data.stdColorBar = DEF_STD_COLOR
	data.font = DEF_FONT
	data.fontSize = DEF_FONT_SIZE
	data.symbol = DEF_FONT_SYMBOL
	data.width = DEF_WIDTH
	data.style = DEF_CURVE_STYLE
	return data
end

-- Convert the colorBar for a string
-- Output format:
--   colorBar = color table; value; label; distance;#color table; value; label; distance;
-- TODO
-- @param colorBar TODO
-- @return TODO
function colorBarToString(colorBar)
	local str = ""

	if type(colorBar) ~= "table" then
		str = DEF_COLOR
		return str
	end

	-- Constants for separating values
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
				customErrorMsg("Invalid color in 'colorBar'.", 3)
			end
		end

		-- value
		if item.value ~= nil then
			str = str .. tostring(item.value) .. ITEM_SEP
		else
			str = str .. ITEM_NULL .. ITEM_SEP
		end

		-- label
		if item.label ~= nil and type(item.label) == "string" then
			str = str .. item.label .. ITEM_SEP
		elseif item.value ~= nil then
			local val = ""
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

		-- distance
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
	"style"
}


Legend_ = {
	type_ = "Legend"
}

local metaTableLegend_ = {__index = Legend_, __tostring = tostringTerraME}
-- Creates a new Legend to be used with Observers
---Type that defines how to color an attribute to be observed. It is used only with a map Observer. The configuration of a legend can be changed visually by double clicking the graphical interface along the simulation.
-- @param data A table
-- @param data.grouping A string with the strategy to slice and color the data. See below.
-- @param data.type The type of the attribute to be observed. It has to be one of "bool", "number", "string", and "datetime" (an ordered string).
-- @param data.slices The number of colors to be used for plotting. It must be an integer number greater than one.
-- @param data.precision The number of decimal digits for slicing. It must be an integer number greater than zero. It indicates that differences less than 10^(-digits) will not be considered. It means that, for instance, if a slice is in the interval [1.0,2.0] and precision is 2 (0.01), a value 0.99 might belong to such slice.
-- @param data.stdDeviation When the grouping mode is stddeviation, it has to be one of "full", "half" "quarter", or "none".
-- @param data.maximum The maximum value of the attribute (used only for numbers).
-- @param data.minimum The minimum value of the attribute (used only for numbers).
-- @param data.width The width of the line to be drawn. Used for drawing Neighborhoods (default is 10).
-- @param data.symbol A symbol to draw Agents. It can be one of: "none", "ellipse", "rect", "diamond", "triangle", "dtriangle", "utriangle", "ltriangle", "rtriangle", "cross", "xcross", "hline", "vline", "asterisk", "star", "hexagon". Default is an arrow.
-- @param data.font A string with the font used to draw each Agent. Default is "Symbol".
-- @param data.fontSize An integer positive number indicating the font size. Default is 12.
-- @param data.colorBar A table where each position is a table with a 'color', a 'value', and a 'label' (optional). Colors can be described as string ("red", "green", "blue", "white", "black", "yellow", "brown", "cyan", "gray", "magenta", "orange", "purple", and their light and dark compositions, such as "lightGray" and "darkGray"), or as tables with three integer numbers representing RGB compositions. Labels are strings that will be shown in the graphical interface describing the colors.
-- @param data.stdColorBar A table just as colorBar. It is needed only when standard deviation is the chosen strategy.
--
-- @tab grouping
-- Grouping & Description & Compulsory parameters & Optional parameters\
-- "equalsteps" &The values are divided into a set of slices with the same range. Each slice is associated to a given color. Equalsteps require only two colors in the colorBar, one for the minimum and the other for the maximum value. The other colors are computed from a linear interpolation of the two colors. &colorBar, slices, maximum, minimum & precision, type, width, font, fontSize, symbol \
-- "quantil" & Aggregate the values into slices with approximately the same size. Values are ordered from lower to higher and then sliced. This strategy uses two colors in the same way of equalsteps. & colorBar, slices, maximum, minimum & precision, type, width \
-- "stdeviation" & Define slices according to the distribution of a given attribute. Values with similar positive or negative distances to the average will belong to the same slice. & colorBar, stdColorBar & stdDeviation, precision, type, width \
-- "uniquevalue" & Map each attribute value to a given color. Attributes with type string can only be sliced with this strategy. &colorBar & type, width
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
function Legend(data)
	if type(data) ~= "table" then
		if data == nil then
			tableParameterErrorMsg("Legend", 3)
		else
 			namedParametersErrorMsg("Legend", 3)
		end
	end

	setmetatable(data, metaTableLegend_)

	suggest(data, legendPossibleParams)

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

	--###############################################
	-- LEGEND PRE-SETUP
	if not data.colorBar or (type(data.colorBar) == "table" and #data.colorBar == 0) then
		data.colorBar = nil
	elseif type(data.colorBar) ~= "table" then
		incompatibleTypesErrorMsg("colorBar", "table", type(data.colorBar), 3)
	end

	if data.stdColorBar and type(data.stdColorBar) == "table" and #data.stdColorBar == 0 then
		data.stdColorBar = nil
	end

	--###############################################
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
		--print("NAO CONSIGO INFERIR 'colorBar'")
		end
	else
		local theType
		for i = 1, #data.colorBar do
			if type(data.colorBar[i].color) == "string" then
				local colorName = data.colorBar[i].color
				data.colorBar[i].color = TME_LEGEND_COLOR_USER[data.colorBar[i].color]

				if data.colorBar[i].color == nil then
					customErrorMsg("Color name '" .. colorName .. "' not found. Please, check the color name or set its value using a table with the RGB composition.", 3)
				end
			end

			local value = data.colorBar[i].value
			local vtype = type(value)
			if theType == nil then
				theType = vtype
			else
				if vtype ~= theType then
					customErrorMsg("Each 'value' within colorBar should have the same type.", 3)
				end
			end
		end
	end

	if type(data.colorBar) == "table" then
		if #data.colorBar <= 1 and (data.grouping == "equalsteps" or data.grouping == TME_LEGEND_GROUPING_USER.equalsteps or data.grouping == "stddeviation" or data.grouping == TME_LEGEND_GROUPING_USER.stddeviation) then
			customErrorMsg("Parameter 'colorBar' requires at least two colors.", 3)
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
			local theType = type(data.colorBar[1].value) -- it was already checked that values have the same type

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
			if theType == "date"    then data.type = TME_LEGEND_TYPE.DATETIME end -- TODO: 'date' is not a Lua type. The code will never enter here.
		end
	end

	-- stdDeviation setup
	if data.stdDeviation == nil then
		--print("NAO CONSIGO INFERIR 'stdDeviation'")
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
		end
		if data.slices == nil then
			data.slices = DEF_SLICES
		end
	--@RAIAN: Tratando o caso em que a quantidade de slices e menor que zero ou maior que a quantidade de cores disponiveis, numeros reais
	else
		--@RAIAN: Tratando tipos incompatíveis
		if type(data.slices) ~= "number" then
			incompatibleTypesErrorMsg("slices", "integer number between 1 and 255", type(data.slices), 3)
		end

		local intPart, fracPart = math.modf(data.slices)
		if data.slices > 255 then
			incompatibleValuesErrorMsg("slices", "integer number between 1 and 255", data.slices, 3)
		elseif data.slices < 1 then
			incompatibleValuesErrorMsg("slices", "integer number between 1 and 255", data.slices, 3)
		elseif fracPart ~= 0 then
			incompatibleValuesErrorMsg("slices", "integer number between 1 and 255", data.slices, 3)
		end
	end

	-- Verify if the number of slices is smaller than or equal the number of available colors
	if type(data.colorBar) == "table" then
		local diffR = 0
		local diffG = 0
		local diffB = 0
		for k = 1, #data.colorBar - 1, 1 do
			local color = data.colorBar[k].color
			local nextColor = data.colorBar[k + 1].color

			diffR = diffR + math.abs(nextColor[1]-color[1])
			diffG = diffG + math.abs(nextColor[2]-color[2])
			diffB = diffB + math.abs(nextColor[3]-color[3])
		end
		maxDiff = math.max(diffR, diffG, diffB)

		if data.slices > maxDiff then
			customErrorMsg("Number of slices is larger than the number of available colors. Using these colors, you can define a maximum of "..maxDiff.." slices.", 3)
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
					local beginI,endI = string.find(strValue, "%.")

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
			incompatibleTypesErrorMsg("precision", "integer number greater than or equal to 1 (one)", type(data.precision), 3)
		end

		local intPart, fracPart = math.modf(data.precision)
		if data.precision < 1 then
			incompatibleValuesErrorMsg("precision", "integer number greater than or equal to 1 (one)", data.precision, 3)
		elseif fracPart ~= 0 then
			incompatibleValuesErrorMsg("precision", "integer number greater than or equal to 1 (one)", data.precision, 3)
		end
	end

	if data.font     == nil then data.font     = DEF_FONT        end
	if data.fontSize == nil then data.fontSize = DEF_FONT_SIZE   end
	if data.symbol   == nil then data.symbol   = DEF_FONT_SYMBOL end
	if data.style    == nil then data.style    = DEF_CURVE_STYLE end
	if data.width    == nil then data.width    = DEF_WIDTH       end

	if data.width < 1 then
		customErrorMsg("width", "greater than or equal to one", data.width, 3)
	end

	--###############################################
	-- colorBar and stdColorBar setup complement
	if type(data.colorBar) == "table" then
		data.colorBar = colorBarToString(data.colorBar)
	else
		-- Verificar
		--customWarningMsg("Warning: Attribute 'colorBar' should be a table, got a ".. type(data.colorBar) .. ". Using default color bar.", 4)
		data.colorBar = colorBarToString(DEF_COLOR)
	end

	if data.stdColorBar then
		if type(data.stdColorBar) == "table" then
			if #data.stdColorBar > 2 then
				data.stdColorBar = colorBarToString(data.stdColorBar)
			else
				-- Verificar
				if not QUIET_MODE then
					customWarningMsg("Warning: Attribute 'stdColorBar' is incomplete.", 4)
				end
			end
		elseif type(data.stdColorBar) ~= "string" then
			incompatibleTypesErrorMsg("stdColorBar","table",type(data.stdColorBar), 4)
		end
		data.colorBar = data.colorBar .. COLORBAR_SEP .. data.stdColorBar
		-- it is not necessary to keep 'stdColorBar' as it is attached to 'colorBar'
		data.stdColorBar = nil
	end

	return data
end

