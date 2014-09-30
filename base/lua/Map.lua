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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

-- Based on a color table available at http://gucky.uni-muenster.de/cgi-bin/rgbtab-en
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
	lightPurple  = {155, 048, 255},
	purple       = {125, 038, 205},
	darkPurple   = {085, 026, 139}
}

local ColorBrewer = {
	YellowsGreens    = {{255,255,229},{247,252,185},{217,240,163},{173,221,142},{120,198,121},{65,171,93},{35,132,67},{0,104,55},{0,69,41}},
	YellowsGreensBlues   = {{255,255,217},{237,248,177},{199,233,180},{127,205,187},{65,182,196},{29,145,192},{34,94,168},{37,52,148},{8,29,88}},
	GreensBlues      = {{247,252,240},{224,243,219},{204,235,197},{168,221,181},{123,204,196},{78,179,211},{43,140,190},{8,104,172},{8,64,129}},
	BluesGreens      = {{247,252,253},{229,245,249},{204,236,230},{153,216,201},{102,194,164},{65,174,118},{35,139,69},{0,109,44},{0,68,27}},
	PurplesBluesGreens   = {{255,247,251},{236,226,240},{208,209,230},{166,189,219},{103,169,207},{54,144,192},{2,129,138},{1,108,89},{1,70,54}},
	PurplesBlues     = {{255,247,251}, {236,231,242}, {208,209,230}, {166,189,219}, {116,169,207}, {54,144,192}, {5,112,176}, {4,90,141},{2,56,88}},
	BluesPurples     = {{247,252,253},{224,236,244},{191,211,230},{158,188,218},{140,150,198},{140,107,177},{136,65,157},{129,15,124},{77,0,75}},
	RedsPurples  = {{255,247,243},{253,224,221},{252,197,192},{250,159,181},{247,104,161},{221,52,151},{174,1,126},{122,1,119},{73,0,106}},
	PurplesReds  = {{247,244,249},{231,225,239},{212,185,218},{201,148,199},{223,101,176},{231,41,138},{206,18,86},{152,0,67},{103,0,31}},
	OrangesReds  = {{255,247,236},{254,232,200},{253,212,158},{253,187,132},{252,141,89},{239,101,72},{215,48,31},{179,0,0},{127,0,0}},
	YellowsOrangesReds   = {{255,255,204},{255,237,160},{254,217,118},{254,178,76},{253,141,60},{252,78,42},{227,26,28},{189,0,38},{128,0,38}},
	YellowsOrangesBrowns     = {{255,255,229},{255,247,188},{254,227,145},{254,196,79},{254,153,41},{236,112,20},{204,76,2},{153,52,4},{102,37,6}},
	Purples  = {{252,251,253},{239,237,245},{218,218,235},{188,189,220},{158,154,200},{128,125,186},{106,81,163},{84,39,143},{63,0,125}},
	Blues    = {{247,251,255},{222,235,247},{198,219,239},{158,202,225},{107,174,214},{66,146,198},{33,113,181},{8,81,156},{8,48,107}},
	Greens   = {{247,252,245},{229,245,224},{199,233,192},{161,217,155},{116,196,118},{65,171,93},{35,139,69},{0,109,44},{0,68,27}},
	Oranges  = {{255,245,235},{254,230,206},{253,208,162},{252,146,114},{251,106,74},{239,59,44},{203,24,29},{165,15,21},{103,0,13}},
	Reds     = {{255,245,240},{254,224,210},{252,187,161},{252,146,114},{251,106,74},{239,59,44},{203,24,29},{165,15,21},{103,0,13}},
	Greys    = {{255,255,255},{240,240,240},{217,217,217},{189,189,189},{150,150,150},{115,115,115},{82,82,82},{37,37,37},{0,0,0}},
	Paired = {{166,206,227},{31,120,180}, {178,223,138}, {51,160,44}, {251,154,153}, {227,26,28}, {253,191,111}, {255,127,0}, {202,178,214} },
	Pastel1 = { {242,242,242}, {251,180,174}, {179,205,227}, {204,235,197}, {222,203,228}, {254,217,166}, {255,255,204}, {229,216,189}, {253,218,236} },
	Pastel2 = { {242,242,242}, {179,226,205},{253,205,172},{203,213,232},{244,202,228},{230,245,201},{255,242,174},{241,226,204},{204,204,204}},
	Accent = { {242,242,242}, {127,201,127},{190,174,212},{253,192,134},{255,255,153},{56,108,176},{240,2,127},{191,91,23},{102,102,102}}
}

local uniqueValueColorBar = function (values, colornames)
	assert(values ~= nil, "Viewer: values for the color bar are empty")
	assert(brew[colornames]  ~= nil, "Viewer: color names must exist in Color Brewer")

	local colorBar = {}
	n = #values
	assert(n <= brew.MAX and n >= 1)
	for i = 1, n do
		table.insert (colorBar, {value = values[i], color = brew[colornames][i]})
	end
	return colorBar
end

local slicedColorBar = function (min, max, slices, colornames)
	assert (slices <= brew.MAX)
	local colorBar = {}
	table.insert (colorBar, {value = min, color = brew[colornames][1]})
	table.insert (colorBar, {value = max, color = brew[colornames][slices]})
	return colorBar
end

local optionalTableElement = function(table, attr, allowedType, level)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypesErrorMsg(attr, allowedType, mtype, level + 1)
	end
end

local compulsoryTableElement = function(table, attr, level)
	if table[attr] == nil then
		mandatoryArgumentErrorMsg(attr, level + 1)
	end
end

Map = function(data)
	compulsoryTableElement(data, "subject", 3)
	optionalTableElement(data, "subject", "CellularSpace", 3)
	compulsoryTableElement(data, "select",  3)

	optionalTableElement(data, "values", "table", 3)
	optionalTableElement(data, "labels", "table", 3)
	optionalTableElement(data, "colors", "string", 3)

	checkUnnecessaryParameters(data, {"subject", "select", "values", "labels", "colors"}, 3)

	if type(data.select) == "string" then data.select = {data.select} end

	optionalTableElement(data, "select", "table", 3)

	verify(#data.select > 0, "Maps must select at least one attribute.", 4)

	forEachElement(data.select, function(_, value)
		verify(data.subject.cells[1][value] ~= nil, "Selected element '"..value.."' does not belong to the subject.", 6)
	end)

	verify(#data.labels == 0 or #data.labels == #data.values, "There should exist labels for each value.", 4)
	verify(#data.colors == 0 or #data.colors == #data.values, "There should exist colors for each value.", 4)
end

