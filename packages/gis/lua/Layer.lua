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

local EncodingMapper = {
	utf8 = "UTF-8",
	cp1250 = "CP1250",
	cp1251 = "CP1251",
	cp1252 = "CP1252",
	cp1253 = "CP1253",
	cp1254 = "CP1254",
	cp1257 = "CP1257",
	latin1 = "LATIN1",  --Latin1 encoding (ISO8859-1)
}

local function isValidSource(source)
	return belong(source, {"tif", "shp", "postgis", "nc", "asc", "geojson", "wfs", "wms", "png"})
end

local function checkSourceExtension(ext)
	if not isValidSource(ext) then
		invalidFileExtensionError("file", ext)
	end
end

local function checkSourcePostgis(source)
	if source ~= "postgis" then
		customError("The only supported database is 'postgis'. Please, set source = \"postgis\".")
	end
end

local function checkEncodingExists(encoding)
	if not EncodingMapper[encoding] then
		customError("Encoding '"..encoding.."' is invalid.")
	end
end

local function isRasterSource(source)
	return belong(source, {"tif", "nc", "asc", "png", "wms"})
end

local function isValidName(name)
	if string.find(name, "%W") then
		local n = string.gsub(name, "-*_*", "")
		if string.find(n, "%W") or string.find(n, "%s") then
			return false
		end
	end

	return true
end

local function getLayerInfoAdapted(data)
	local info = TerraLib().getLayerInfo(data.project, data.name)
	info.type = nil

	forEachElement(info, function(idx, value)
		if idx == "url" then
			idx = "service"
			value = string.gsub(value, "^WFS:", "")
		elseif idx == "dataset" then
			if info.source == "wfs" then
				idx = "feature"
			elseif info.source == "wms" then
				idx = "map"
			end
		elseif idx == "srid" then
			idx = "epsg"
		elseif idx == "encoding" then
			value = string.lower(string.gsub(value, "-", ""))
		end
		data[idx] = value
	end)
end

local function checkName(name, arg)
	local errMsg = TerraLib().checkName(name)
	if errMsg ~= "" then
		customError(arg.." name '"..name.."' is not a valid name. "..errMsg..".")
	end
end

local function fixName(name)
	return string.gsub(name, "-", "_")
end

local function checkPostgisParams(data)
	mandatoryTableArgument(data, "password", "string")
	mandatoryTableArgument(data, "database", "string")
	optionalTableArgument(data, "table", "string")

	checkName(data.database, "Database")

	if data.table then
		data.table = string.lower(data.table)
	end

	if data.name then
		defaultTableValue(data, "table", string.lower(data.name))
	end

	data.table = fixName(data.table)
	checkName(data.table, "Table")

	defaultTableValue(data, "host", "localhost")
	defaultTableValue(data, "user", "postgres")
	defaultTableValue(data, "port", 5432)
	data.port = tostring(data.port)
end

local function addCellularLayer(self, data)
	verifyNamedTable(data)
	verifyUnnecessaryArguments(data, {"box", "input", "name", "resolution", "file", "project", "source",
	                                  "clean", "host", "port", "user", "password", "database", "table",
									  "index"})

	mandatoryTableArgument(data, "input", "string")
	positiveTableArgument(data, "resolution")

	if type(data.file) == "string" then
		data.file = File(data.file)
	end

	if data.source == nil then
		if data.file == nil then
			if data.database then
				data.source = "postgis"
			else
				customError("At least one of the following arguments must be used: 'file', 'source', or 'database'.")
			end
		else
			local source = data.file:extension()
			data.source = source
		end
	end

	mandatoryTableArgument(data, "source", "string")

	if belong(data.source, {"tif", "shp", "geojson"}) then
		mandatoryTableArgument(data, "file", "File")

		if data.source ~= data.file:extension() then
			customError("File '"..data.file.."' not match to source '"..data.source.."'.")
		end
	end

	if not isValidSource(data.source) then
		customError("Source '"..data.source.."' is invalid.")
	end

	if not self.layers[data.input] then
		customError("Input layer '"..data.input.."' was not found.")
	end

	if self.layers[data.name] then
		customError("Layer '"..data.name.."' already exists in the Project.")
	end

	local inputInfos = TerraLib().getLayerInfo(data.project, data.input)
	local repr = inputInfos.rep

	switch(data, "source"):caseof{
		shp = function()
			mandatoryTableArgument(data, "file", "File")
			defaultTableValue(data, "clean", false)
			defaultTableValue(data, "index", true)

			if repr == "raster" then
				verifyUnnecessaryArguments(data, {"clean", "input", "name", "project",
												"resolution", "file", "source", "index"})
				data.box = true
			else
				defaultTableValue(data, "box", false)
				verifyUnnecessaryArguments(data, {"clean", "box", "input", "name", "project",
												"resolution", "file", "source", "index"})
			end

			if data.file:exists() then
				if data.clean then
					data.file:delete()
				else
					customError("File '"..data.file.."' already exists. Please set clean = true or remove it manually.")
				end
			end

			TerraLib().addShpCellSpaceLayer(self, data.input, data.name, data.resolution,
											data.file, not data.box, data.index)
		end,
		geojson = function()
			mandatoryTableArgument(data, "file", "File")
			defaultTableValue(data, "clean", false)
			defaultTableValue(data, "index", true)

			if repr == "raster" then
				verifyUnnecessaryArguments(data, {"clean", "input", "name", "project",
												"resolution", "file", "source", "index"})
				data.box = true
			else
				defaultTableValue(data, "box", false)
				verifyUnnecessaryArguments(data, {"clean", "box", "input", "name", "project",
												"resolution", "file", "source", "index"})
			end

			if data.file:exists() then
				if data.clean then
					data.file:delete()
				else
					customError("File '"..data.file.."' already exists. Please set clean = true or remove it manually.")
				end
			end

			TerraLib().addGeoJSONCellSpaceLayer(self, data.input, data.name, data.resolution,
												data.file, not data.box, data.index)
		end,
		postgis = function()
			checkPostgisParams(data)

			defaultTableValue(data, "clean", false)

			if repr == "raster" then
				verifyUnnecessaryArguments(data, {"clean", "input", "name", "resolution", "source", -- SKIP
										"project", "host", "port", "user", "password", "database", "table"})
				data.box = true -- SKIP
			else
				defaultTableValue(data, "box", false)
				verifyUnnecessaryArguments(data, {"box", "clean", "input", "name", "resolution", "source",
										"project", "host", "port", "user", "password", "database", "table"})
			end

			if data.clean then
				data.encoding = inputInfos.encoding
				TerraLib().dropPgTable(data)
			end

			TerraLib().addPgCellSpaceLayer(self, data.input, data.name, data.resolution, data, not data.box)
		end
	}
end

local function addLayer(self, data)
	verifyNamedTable(data)
	mandatoryTableArgument(data, "name", "string")

	if type(data.file) == "string" then
		data.file = File(data.file)
	end

	verifyUnnecessaryArguments(data, {"name", "source", "project", "file", "index",
									"host", "port", "user", "password", "encoding", "database", "table",
									"service", "feature", "epsg", "map"})

	if data.source == nil then
		if data.file then
			if not data.file:exists() then
				customError("File '"..data.file.."' does not exist.")
			end

			data.source = data.file:extension()
		end
	end

	if type(data.service) == "string" then
		local lower = string.lower(data.service)
		if string.match(lower, "wms") then
			defaultTableValue(data, "source", "wms")
		elseif string.match(lower, "wfs") then
			defaultTableValue(data, "source", "wfs")
		end
	end

	mandatoryTableArgument(data, "source", "string")

	if not isValidSource(data.source) then
		customError("Source '"..data.source.."' is invalid.")
	end

	if belong(data.source, {"tif", "shp", "nc", "asc", "geojson"}) then
		mandatoryTableArgument(data, "file", "File")

		if data.source ~= data.file:extension() then
			customError("File '"..data.file.."' does not match to source '"..data.source.."'.")
		end
	end

	if not isValidName(data.name) then
		customError("'"..data.name.."' is not a valid Layer name. Please check special characters or spaces.")
	end

	if self.layers[data.name] then
		customError("Layer '"..data.name.."' already exists in the Project.")
	end

	if data.encoding then
		checkEncodingExists(data.encoding)
	end

	optionalTableArgument(data, "epsg", "number")

	switch(data, "source"):caseof{
		shp = function()
			mandatoryTableArgument(data, "file", "File")
			defaultTableValue(data, "index", true)
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "index", "epsg", "encoding"})
			defaultTableValue(data, "encoding", "latin1")

			TerraLib().addShpLayer(self, data.name, data.file, data.index, data.epsg, EncodingMapper[data.encoding])
		end,
		geojson = function()
			mandatoryTableArgument(data, "file", "File") -- SKIP
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "epsg", "encoding"})
			defaultTableValue(data, "encoding", "latin1")

			TerraLib().addGeoJSONLayer(self, data.name, data.file, data.epsg) -- SKIP
		end,
		tif = function()
			mandatoryTableArgument(data, "file", "File")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "epsg"})

			TerraLib().addGdalLayer(self, data.name, data.file, data.epsg)
		end,
		nc = function()
			mandatoryTableArgument(data, "file", "File") -- SKIP
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "epsg"}) -- SKIP

			TerraLib().addGdalLayer(self, data.name, data.file, data.epsg) -- SKIP
		end,
		asc = function()
			mandatoryTableArgument(data, "file", "File")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "epsg"})

			TerraLib().addGdalLayer(self, data.name, data.file, data.epsg)
		end,
		png = function()
			mandatoryTableArgument(data, "file", "File")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "epsg"})

			TerraLib().addGdalLayer(self, data.name, data.file, data.epsg)
		end,
		postgis = function()
			verifyUnnecessaryArguments(data, {"name", "source", "host", "port", "user", "password",
									"database", "table", "project", "epsg", "encoding"})
			checkPostgisParams(data)
			defaultTableValue(data, "encoding", "latin1")

			TerraLib().addPgLayer(self, data.name, data, data.epsg, EncodingMapper[data.encoding])
		end,
		wfs = function()
			mandatoryTableArgument(data, "service", "string")
			mandatoryTableArgument(data, "feature", "string")
			verifyUnnecessaryArguments(data, {"name", "source", "service", "feature", "project", "epsg", "encoding"})

			TerraLib().addWfsLayer(self, data.name, data.service, data.feature, data.epsg, EncodingMapper[data.encoding])
		end,
		wms = function()
			mandatoryTableArgument(data, "service", "string")
			mandatoryTableArgument(data, "map", "string")
			defaultTableValue(data, "format", "png")

			verifyUnnecessaryArguments(data, {"name", "source", "service", "map", "project", "format",
									"user", "password", "port", "epsg"})

			local connect = {
				url = data.service,
				directory = currentDir(),
				format = data.format,
				user = data.user,
				password = data.password,
				port = data.port
			}

			TerraLib().addWmsLayer(self, data.name, connect, data.map, data.epsg)
		end
	}
end

local function checkIfRasterBandExists(data)
	local band = data.layer:bands()

	if data.band >= band then
		if band > 1 then
			customError("Band '"..data.band.."' does not exist. The available bands are from '0' to '"..band.."'.")
		else
			customError("Band '"..data.band.."' does not exist. The only available band is '0'.")
		end
	end

	return true
end

local function checkRaster(data)
	verifyUnnecessaryArguments(data, {"attribute", "band", "dummy", "missing", "layer", "operation", "pixel"})

	defaultTableValue(data, "band", 0)
	positiveTableArgument(data, "band", true)
	data.select = data.band

	defaultTableValue(data, "pixel", "centroid")

	switch(data, "pixel"):caseof{
		overlap  = function() data.pixel = true  end,
		centroid = function() data.pixel = false end
	}

	checkIfRasterBandExists(data)

	defaultTableValue(data, "dummy", data.layer:dummy(data.band))
end

local function deleteData(data)
	if type(data.file) == "string" then
		data.file = File(data.file)
	end

	if type(data.file) == "File" then
		if data.file:exists() then
			data.file:delete()
		end
	elseif data.database then
		TerraLib().dropPgTable(data)
	else
		customError("TerraME does not know how to remove such data source.")
	end
end

local function createFileFromInputData(input)
	local file = input
	if type(file) == "string" then
		file = File(input)
	elseif type(file) ~= "File" then
		customError("Type of 'file' argument must be either a File or string.")
	end
	return file
end

local function extractMultiplesPattern(text)
	return string.match(text, "(.*)%*(.*)")
end

local function findMultiples(base, pattern, list)
	-- escape any "magic" Lua character
	local prefix = string.gsub(base, "([%(%)%.%%%+%-%*%?%[%]%^%$)])", "%%%1")
	local sufix = string.gsub(pattern, "([%(%)%.%%%+%-%*%?%[%]%^%$)])", "%%%1")
	local regex = string.format("%s(.*)%s$", prefix, sufix)
	local elements = {}
	forEachOrderedElement(list, function(_, element)
		local elementPattern = string.match(element, regex)
		if elementPattern then
			table.insert(elements, {pattern = elementPattern, name = element})
		end
	end)

	if #elements == 0 then
		customError("No results have been found to match the pattern '"..base.."*"..pattern.."'.")
	elseif #elements == 1 then
		customWarning("Only one resut has been found to match the pattern '"..base.."*"..pattern.."'.")
	end

	return elements
end

Layer_ = {
	type_ = "Layer",
	--- Return a string with the representation of the layer. It can be "point", "polygon", "line", or "raster".
	-- @usage -- DONTRUN
	-- print(layer:representation())
	representation = function(self)
		return TerraLib().getLayerInfo(self.project, self.name).rep
	end,
	--- Delete the data source of the Layer. If it is a file or a set of files, remove them. If it is a
	-- database table, remove it.
	-- @usage -- DONTRUN
	-- layer:delete()
	delete = function(self)
		deleteData(self)
	end,
	--- Drop the database of the Layer.
	-- This function only works when the layer is stored in a PostGIS table.
	-- Note that it removes all tables within the database.
	-- @usage -- DONTRUN
	-- layer:drop()
	drop = function(self)
		if self.database then
			TerraLib().dropPgDatabase(self)
		else
			customError("Function 'drop' only works with PostGIS layer.")
		end
	end,
	--- Return the number of bands of a raster layer. If the layer does not have a raster representation
	-- then it will stop with an error. The bands of the raster layer are named from zero to the number of
	-- bands minus one.
	-- @usage -- DONTRUN
	-- print(layer:bands())
	bands = function(self)
		return TerraLib().getNumOfBands(self.project, self.name)
	end,
	--- Create a new attribute for each object of a Layer.
	-- This attribute can be stored as a new
	-- column of a table or a new file, according to where the Layer is stored.
	-- There are several strategies for filling cells according to the geometry of the
	-- input layer.
	-- @arg data.select Name of an attribute from the input data. It is only required when
	-- the selected operation needs a value associated to the geometry (average, sum, mode).
	-- When using a raster data as input, use argument band instead.
	-- @arg data.band An integer value representing the band of the raster to be used.
	-- The default value is one.
	-- @arg data.layer An input Layer belonging to the same Project. It can also be a
	-- string with the Layer's name. There are
	-- several strategies available, depending on the geometry of the Layer. See below:
	-- @tabular layer
	-- Geometry & Using only geometry & Using attribute of objects with some overlap &
	-- Using geometry and attribute \
	-- Points & "count", "distance", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" & (none) \
	-- Lines & "count", "distance", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" & (none) \
	-- Polygons & "area", "count", "distance", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "average", "mode", "coverage", "sum" \
	-- Raster & (none) &
	-- "average", "mode", "maximum", "minimum", "coverage", "stdev", "sum", "count" &
	-- (none) \
	-- @arg data.operation The way to compute the attribute of each cell. When using raster
	-- data, a pixel is considered within a given geometry if there is some intersection
	-- between the pixel and the geometry. This means that the same pixel might belong to
	-- two or more geometries of the layer. See the
	-- table below with the available operations:
	-- @tabular operation
	-- Operation & Description & Mandatory arguments & Optional arguments \
	-- "area" & Percentage of area with some overlay with a layer of polygons. The created values
	-- will range from zero (no intersection) to one (area fully covered by polygons).
	-- This algorithm supposes that there is no intersection area between each pair of polygons
	-- from the reference layer. It sums the intersection areas of the object with all the polygons
	-- of the reference layer. Because of that, if there is some overlay between the polygons of the
	-- reference layer, it might create attribute values greater than one.
	-- & attribute, layer & split \
	-- "average" & Average of quantitative values from the objects that have some intersection
	-- with the cell, without taking into account their geometric properties. When using argument
	-- area, it computes the average weighted by the proportions of the respective intersection areas.
	-- Useful to distribute atributes that represent averages, such as per capita income.
	-- & attribute, layer, select  & area, missing, band, dummy, pixel, split  \
	-- "count" & Number of objects that have some overlay with the cell.
	-- & attribute, layer & dummy, pixel, split \
	-- "coverage" & Percentage of each qualitative value covering the cell, using polygons or
	-- raster data. It creates one new attribute for each available value, in the form
	-- attribute.."_"..value, where attribute is the value passed as argument to fill and
	-- value represent the different values in the input data.
	-- The sum of the created attribute values for a given cell will range
	-- from zero to one, according to the area of the cell covered by pixels.
	-- Note that this operation does not use dummy value, therefore one attribute will also
	-- be created for the dummy values.
	-- When using shapefiles, keep in mind the total limit of ten characters, as
	-- it removes the characters after the tenth in the name. This function will stop with
	-- an error if two attribute names in the output are the same.
	-- & attribute, layer, select & missing, band, pixel, split \
	-- "distance" & Distance to the nearest object. The distance is computed from the
	-- centroid of the cell to the closest point, line, or border of a polygon.
	-- & attribute, layer & split \
	-- "maximum" & Maximum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & missing, band, dummy, pixel, split \
	-- "minimum" & Minimum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & missing, band, dummy, pixel, split \
	-- "mode" & More common qualitative value from the objects that have some intersection with
	-- the cell, without taking into account their geometric properties. This operation creates an
	-- attribute with string values. Whenever there are two or more values with the same count, the resulting
	-- value will contain all them separated by comma. When using argument area, it
	-- uses the value of the object that has larger coverage. & attribute, layer, select &
	-- missing, band, dummy, pixel, split \
	-- "presence" & Boolean value pointing out whether some object has an overlay with the cell.
	-- & attribute, layer & split \
	-- "stdev" & Standard deviation of quantitative values from objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & missing, band, dummy, pixel, split \
	-- "sum" & Sum of quantitative values from objects that have some intersection with the
	-- cell, without taking into account their geometric properties. When using argument area, it
	-- computes the sum based on the proportions of intersection area. Useful to preserve the total
	-- sum in both layers, such as population size.
	-- & attribute, layer, select & area, missing, band, dummy, pixel, split \
	-- @arg data.attribute The name of the new attribute to be created.
	-- @arg data.area Whether the calculation will be based on the intersection area (true),
	-- or the weights are equal for each object with some overlap (false, missing value).
	-- @arg data.missing A value that will be used to fill a cell whose attribute cannot be
	-- computed (for example, when there is no intersection area). Note that this argument is
	-- related to the output. Its default value is zero.
	-- @arg data.dummy A number related to the input raster data that represents no information in a pixel value.
	-- This value will be ignored by all operations as if it did not exist.
	-- For example, in averages, dummy values will not be used in the sum nor to count the number of pixels.
	-- Its default value is the result of Layer:dummy().
	-- @arg data.split A boolean to determine if the fill will split the temporal data into different layers
	-- with each new layer's name formed by the own Layer's name and the respective times as sufix.
	-- The default value is false and, in this case, the temporal data will be filled in the own Layer
	-- into different attributes though.
	-- @arg data.pixel A string value indicating when a pixel is within a polygon. See the table below.
	-- @tabular pixel Pixel & Description \
	-- "centroid" (default) & A pixel is within a polygon if its centroid is within the polygon. It is recommended to
	-- use this strategy when one wants to keep the sum of the amount of pixels in the created output, and when the
	-- resolution of the polygons is greater than the resolution of the pixels. If the resolution of polygons
	-- is smaller than the resolution of pixels, there might exist polygons that do not contain any pixel. For cellular
	-- representations, when the cells were created using the raster and the
	-- resolution of polygons is considerably smaller than the resolution of pixels, a pixel might belong to two
	-- polygons as its centroid might be located in the limit of both polygons. \
	-- "overlap" & A pixel is considered within a polygon if they have some overlap. This way, a pixel might belong to
	-- two or more polygons at the same time. This strategy is usually recommended when the resolution of the polygons
	-- is smaller than the resolution of the pixels. This strategy takes more time to run. \
	-- @usage -- DONTRUN
	-- import("gis")
	--
	-- cl = Layer{
	--     project = file("rondonia.tview"),
	--     layer = "cells"
	-- }
	--
	-- cl:fill{
	--     attribute = "distRoads",
	--     operation = "distance",
	--     layer = "roads"
	-- }
	--
	-- cl:fill{
	--     attribute = "population",
	--     layer = "population",
	--     operation = "sum",
	--     area = true
	-- }
	--
	-- cl:fill{
	--     attribute = "area2010_",
	--     operation = "coverage",
	--     layer = "cover",
	--     select = "cover2010"
	-- }
	--
	-- cl:fill{
	--     attribute = "area",
	--     operation = "coverage",
	--     layer = "cover*", -- temporal representation
	-- }
	fill = function(self, data)
		verifyNamedTable(data)

		mandatoryTableArgument(data, "operation", "string")
		mandatoryTableArgument(data, "attribute", "string")
		optionalTableArgument(data, "dummy", "number")

		checkName(data.attribute, "Attribute")

		local project = self.project

		if type(data.layer) == "string" then
			if string.find(data.layer, "%*") then
				local prefix, sufix = extractMultiplesPattern(data.layer)
				local layers = {}
				forEachOrderedElement(project.layers, function(layer)
					table.insert(layers, layer)
				end)

				layers = findMultiples(prefix, sufix, layers)
				optionalTableArgument(data, "split", "boolean")
				if data.split then
					forEachOrderedElement(layers, function(_, layer)
						local newLayerName = self.name..layer.pattern
						local newLayer = self.project[newLayerName]
						if not newLayer then
							local newLayerFile = newLayerName.."."..self.source
							if not File(newLayerFile):exists() then
								local fromData = {
									project = self.project,
									layer = self.name
								}

								local toData = {file = File(newLayerFile)}
								TerraLib().saveDataAs(fromData, toData)
							end

							newLayer = Layer{
								project = self.project,
								name = newLayerName,
								file = newLayerFile
							}
						end

						local newData = clone(data)
						newData.layer = layer.name
						newData.split = nil
						newLayer:fill(newData)
					end)
				else
					forEachOrderedElement(layers, function(_, layer)
						local attr = data.attribute..layer.pattern
						if #attr > 10 and self.source == "shp" then
							customError("The attribute '"..attr.."' to be created has more than 10 characters. Please shorten the attribute name.")
						end
					end)

					forEachOrderedElement(layers, function(_, layer)
						local newData = clone(data)
						newData.layer = layer.name
						newData.attribute = data.attribute..layer.pattern
						self:fill(newData)
					end)
				end

				return
			end

			data.layer = Layer{
				project = self.project.file,
				name = data.layer
			}
		else
			mandatoryTableArgument(data, "layer", "Layer")
		end

		local repr = data.layer:representation()

		switch(data, "operation"):caseof{
			area = function()
				if repr == "polygon" or repr == "surface" then
					verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			average = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					if repr == "polygon" or repr == "surface" then
						verifyUnnecessaryArguments(data, {"area", "attribute", "missing", "layer", "operation", "select"})
						defaultTableValue(data, "area", false)
					else
						verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					end

					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			count = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation", "missing"})
					data.select = "FID"
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			distance = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			-- length = function() -- TODO(#795)
				-- if repr == "line" then
					-- verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					-- data.select = "FID"
				-- else
					-- customError("Operation '"..data.operation.."' is not available for layers with "..repr.." data.")
				-- end
			-- end,
			mode = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					if repr == "polygon" or repr == "surface" then
						verifyUnnecessaryArguments(data, {"area", "attribute", "missing", "layer", "operation", "select"})
						defaultTableValue(data, "area", false)
					else
						verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					end

					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			maximum = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			minimum = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			coverage = function()
				if repr == "polygon" or repr == "surface" then
					verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "missing", "layer", "operation", "pixel"})
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			presence = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			stdev = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"attribute", "missing", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end,
			sum = function()
				if belong(repr, {"point", "line", "polygon", "surface"}) then
					verifyUnnecessaryArguments(data, {"area", "attribute", "missing", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
					defaultTableValue(data, "area", false)
				elseif repr == "raster" then
					checkRaster(data)
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "missing", 0)
			end
		}

		if type(data.select) == "string" then
			local attrs = data.layer:attributes()
			local attrNames = {}

			for i = 1, #attrs do
				attrNames[i] = attrs[i].name
			end

			if not belong(data.select, attrNames) then
				local msg = "Selected attribute '"..data.select.."' does not exist in Layer '"..data.layer.name.."'."
				local sugg = suggestion(data.select, attrNames)

				if sugg then
					msg = msg..suggestionMsg(sugg)
				else
					msg = msg.." The available attributes are: '"..table.concat(attrNames, "', '").."'."
				end

				customError(msg)
			end
		end

		TerraLib().attributeFill(project, data.layer.name, self.name, nil, data.attribute, data.operation, data.select, data.area, data.missing, repr, data.dummy, data.pixel)
	end,
	--- Return the Layer's projection. It contains the name of the projection, its Geodetic
	-- Identifier (EPSG), and
	-- its Proj4 description (www.proj4.org/parameters.html).
	-- @usage -- DONTRUN
	-- print(layer:projection())
	projection = function(self)
		local prj = TerraLib().getProjection(self.project.layers[self.name])

		if prj.NAME == "" then
			prj.NAME = "Undefined" -- SKIP TODO(avancinirodrigo): there is no data with undefined projection to test
		else
			prj.NAME = "'"..prj.NAME.."'"
		end

		if prj.PROJ4 == "" then
			prj.PROJ4 = "Undefined" -- SKIP TODO(avancinirodrigo): there is no data with undefined projection to test
		else
			prj.PROJ4 = "'"..prj.PROJ4.."'"
		end

		return prj.NAME..", with EPSG: "..self.epsg.." (PROJ4: "..prj.PROJ4..")"
	end,
	--- The attribute names of the Layer. It returns a vector of strings, whose size is
	-- the number of attributes.
	-- @usage -- DONTRUN
	-- import("gis")
	--
	-- print(vardump(layer:attributes()))
	attributes = function(self)
		local propInfos = TerraLib().getPropertyInfos(self.project, self.name)

		if propInfos[0].type == "raster" then
			return nil
		end

		local luaPropInfos = {}
		local count = 1
		for i = 0, getn(propInfos) - 1 do
			if not (propInfos[i].type == "geometry") then
				luaPropInfos[count] = propInfos[i]
				count = count + 1
			end
		end

		return luaPropInfos
	end,
	--- Returns the dummy value of a raster layer. If the layer does not have a raster representation
	-- then it returns nil . The bands of the raster layer are named from zero to the number of
	-- bands minus one. If the band is greater than that, it returns an error.
	-- @arg band The band number. The default value is zero.
	-- @usage -- DONTRUN
	-- print(layer:dummy())
	dummy = function(self, band)
		if band == nil then band = 0 end

		mandatoryArgument(1, "number", band)
		positiveArgument(1, band, true)

		return TerraLib().getDummyValue(self.project, self.name, band)
	end,
	--- Exports the data of a Layer to another data source.
	-- The data can be either a file data or postgis. The SRID and overwrite are common arguments.
	-- @arg data.epsg A number from the EPSG Geodetic Parameter Dataset describing a projection.
	-- It can be used to reproject the data.
	-- A list with the supported epsg numbers is available at http://www.terrame.org/projections.html .
	-- @arg data.overwrite Indicates if the exported data will be overwritten, the default is false.
	-- @arg data.select  A vector with the names of the attributes to be saved. When saving a
	-- single attribute, you can use a string "attribute" instead of a table {"attribute"}.
	-- @arg data.... Additional arguments related to where the output will be saved. These arguments
	-- are the same for describing the data source when one creates a layer from a file or database.
	-- @usage -- DONTRUN
	-- layer:export{file = "myfile.shp"}
	-- layer:export{file = "myfile.geojson"}
	-- layer:export{file = "myfile.geojson", epsg = 4326}
	-- layer:export{file = "myfile.geojson", epsg = 4326, select = {"uf", "population"}}
	export = function(self, data)
		verifyNamedTable(data)

		if data.epsg then
			positiveTableArgument(data, "epsg")
		end

		defaultTableValue(data, "overwrite", false)

		if type(data.file) == "string" then
			data.file = File(data.file)
		end

		if type(data.select) == "string" then
			data.select = {data.select}
		end

		optionalTableArgument(data, "select", "table")

		local fromData = {
			project = self.project,
			layer = self.name
		}

		local toData = {}

		if data.file then
			local file = createFileFromInputData(data.file)
			local ext = file:extension()
			checkSourceExtension(ext)

			if isRasterSource(self.source) then
				if isRasterSource(ext) then
					verifyUnnecessaryArguments(data, {"source", "file", "epsg", "overwrite"})
				else
					customError("Raster layer '"..self.name
								.."' cannot be exported as vector data. Please, use 'polygonize' function instead.")
				end
			elseif isRasterSource(ext) then
				customError("Vector layer '"..self.name.."' cannot be exported as raster data.")
			else
				verifyUnnecessaryArguments(data, {"source", "file", "epsg", "overwrite", "select"})
			end

			toData = {
				file = file,
				type = ext,
				srid = data.epsg,
				encoding = EncodingMapper[self.encoding]
			}
		elseif isRasterSource(self.source) then
			customError("Raster layer '"..self.name
						.."' cannot be exported as vector data. Please, use 'polygonize' function instead.")
		else --< to data is postgis
			mandatoryTableArgument(data, "source", "string")
			checkSourcePostgis(data.source)
			verifyUnnecessaryArguments(data, {"source", "user", "password", "database", "host", "port", "encoding",
											"table", "epsg", "overwrite", "select"})
			data.name = self.name
			checkPostgisParams(data)

			for k, v in pairs(data) do
				toData[k] = v
			end

			toData.type = "postgis"
			toData.srid = toData.epsg
			toData.encoding = EncodingMapper[self.encoding]
		end

		TerraLib().saveDataAs(fromData, toData, data.overwrite, data.select)
	end,
	--- Create a new data simplifying its geometry.
	-- The data will be created using the same data source layer.
	-- This function uses Douclas-Peucker algorithm and currently works only for line data.
	-- @arg data.output The data name that will be created.
	-- @arg data.tolerance The maximum distance between the original curve and the simplified curve.
	-- A given point is removed when the distances in a curve without it is less than the maximum distance.
	-- The tolerance uses the same unit of the input geometry's projection.
	-- @usage -- DONTRUN
	-- layer:simplify{output = "layer_simplified", tolerance = 500}
	simplify = function(self, data)
		verifyNamedTable(data)
		mandatoryTableArgument(data, "output")
		mandatoryTableArgument(data, "tolerance")
		positiveTableArgument(data, "tolerance")

		checkName(data.output, "Output")

		local repr = self:representation()
		if repr == "line" then
			TerraLib().douglasPeucker(self.project, self.name, data.output, data.tolerance)
		else
			customError("Layer representation '"..repr.."' cannot be simplified.")
		end
	end,
	--- Returns the bounding box as a table with the keys xMin, yMin, xMax and yMax.
	-- @usage -- DONTRUN
	-- bbox = alayer:box()
	-- print(bbox.xMin, bbox.yMin, bbox.xMax, bbox.yMax)
	box = function(self)
		return TerraLib().getBoundingBox(self.project.layers[self.name])
	end,
	--- Creates a vector data from a raster layer using polygons covering contiguous pixels that share the same value.
	-- The output data can be either a file data or postgis.
	-- @arg data.band The band number (0, default). The output data created will have an attribute
	-- named 'value' with the value of the pixel according to the band selected.
	-- @arg data.overwrite Optional argument that indicates if the output data will be overwritten, the default is false.
	-- @arg data.... Additional arguments related to where the output will be saved. These arguments
	-- are the same for describing the data source when one creates a layer from a file or database.
	-- @usage -- DONTRUN
	-- layer:polygonize{file = "polygonized.shp", overwrite = true}
	-- layer:polygonize{
	-- 	source = "postgis",
	-- 	password = "postgres",
	-- 	database = "postgis_22_sample",
	-- 	table = "polygonized",
	-- 	overwrite = true
	-- }
	polygonize = function(self, data)
		verifyNamedTable(data)
		defaultTableValue(data, "band", 0)
		positiveTableArgument(data, "band", true)
		optionalTableArgument(data, "overwrite", "boolean")

		if not isRasterSource(self.source) then
			customError("Function polygonize only works from a raster Layer.")
		end

		checkIfRasterBandExists{layer = self, band = data.band}

		local rasterInfo = {
			project = self.project,
			layer = self.name,
			band = data.band
		}

		local outInfo

		if data.file then
			verifyUnnecessaryArguments(data, {"source", "file", "band", "overwrite"})
			local file = createFileFromInputData(data.file)
			local ext = file:extension()
			checkSourceExtension(ext)

			outInfo = {
				type = ext,
				file = file
			}
		else
			mandatoryTableArgument(data, "source", "string")
			checkSourcePostgis(data.source)
			verifyUnnecessaryArguments(data, {"source", "user", "password", "database", "host",
											"port", "encoding", "table", "band", "overwrite"})
			if data.encoding then
				checkEncodingExists(data.encoding)
			end
			defaultTableValue(data, "encoding", "latin1")
			checkPostgisParams(data)

			outInfo = {
				type = data.source,
				host = data.host,
				port = data.port,
				user = data.user,
				password = data.password,
				database = data.database,
				table = data.table,
				encoding = EncodingMapper[data.encoding]
			}
		end

		if data.overwrite then
			deleteData(outInfo)
		end

		TerraLib().polygonize(rasterInfo, outInfo)
	end,
	--- Splits a temporal layer into multiple layers. It creates a 'layer_time' for each time available as attribute values 'attribute_time'.
	-- @usage -- DONTRUN
	-- layer:split()
	split = function(self)
		local temporalAttributes = {}
		local startTime = math.huge
		local nonTemporalAttributes = {}
		local dataAttributes = {}
		local isTemporal = false
		forEachElement(self:attributes(), function(_, attr)
			local prefix, sufix = string.match(attr.name, "(.+)_(%d+)")
			if prefix and sufix then
				isTemporal = true
				if not temporalAttributes[sufix] then
					temporalAttributes[sufix] = {}
				end

				startTime = math.min(startTime, tonumber(sufix))
				table.insert(temporalAttributes[sufix], {prefix = prefix, sufix = sufix, name = attr.name})
			elseif belong(attr.name, {"id", "col", "row", "FID", "OGR_GEOMETRY", "ogr_geometry"}) then
				table.insert(dataAttributes, attr.name)
			else
				table.insert(nonTemporalAttributes, attr.name)
			end
		end)

		if not isTemporal then
			customError("No temporal attribute has been found.")
		end

		forEachElement(nonTemporalAttributes, function(_, attr)
			table.insert(temporalAttributes[tostring(startTime)], {prefix = attr, sufix = "", name = attr})
		end)

		forEachElement(dataAttributes, function(_, attr)
			forEachElement(temporalAttributes, function(time)
				table.insert(temporalAttributes[time], {prefix = attr, sufix = "", name = attr})
			end)
		end)

		forEachElement(temporalAttributes, function(time, attributeList)
			local attrNames = {}
			local mapAttributes = {}
			forEachElement(attributeList, function(_, attr)
				table.insert(attrNames, attr.prefix)
				mapAttributes[attr.name] = attr.prefix
			end)

			local dset = TerraLib().getDataSet{project = self.project, layer = self.name}
			local toSet = {}
			for i = 0, #dset do
				toSet[i + 1] = {}
				for k, v in pairs(dset[i]) do
					toSet[i + 1][k] = nil
					if mapAttributes[k] then
						toSet[i+1][mapAttributes[k]] = v
					end
				end
			end

			local newLayerName = self.name.."_"..time
			local fileName = newLayerName.."."..self.source
			-- a temp layer is needed because currently one can't remove attributes from a layer thus this layer holds only the desired attributes
			local tempLayer = "_l_y_r_"
			TerraLib().saveDataSet(self.project, self.name, toSet, tempLayer, attrNames)
			local from = {project = self.project, layer = tempLayer}
			local to = {file = File(fileName), type = self.source}
			TerraLib().saveDataAs(from, to, true, attrNames)
			Layer{project = self.project, name = newLayerName, file = fileName}
			TerraLib().removeLayer(self.project, tempLayer)
		end)
	end,
	--- Merges every temporal layer from the layer's project into a single layer with all temporal attribute.
	-- Atributes from temporal layers are created with the attribute name followed by the time from its layer.
	-- Every temporal layer must have the same geometry.
	-- @usage -- DONTRUN
	-- layer:merge()
	merge = function(self)
		local newLayerName, time = string.match(self.name, "(.+)_(%d+)")
		if not newLayerName or not time then
			customError("Layer '"..self.name.."' is not a temporal layer.")
		end

		if self.project.layers[newLayerName] then
			customWarning("Layer '"..newLayerName.."' already exists.") -- SKIP
		end

		local temporalLayers = {}
		local attributes = {}
		forEachElement(self.project.layers, function(layerName)
			local prefix, sufix = string.match(layerName, "(.+)_(%d+)")
			if prefix and sufix and prefix == newLayerName then
				temporalLayers[layerName] = true
				local attribs = TerraLib().getPropertyNames(self.project, layerName)
				forEachElement(attribs, function(_, attribute)
					if not attributes[attribute] then
						attributes[attribute] = {}
					end

					table.insert(attributes[attribute], {layer = layerName, time = sufix})
				end)
			end
		end)

		local dSetSize = TerraLib().getLayerSize(self.project, self.name)
		forEachOrderedElement(temporalLayers, function(layer)
			if dSetSize ~= TerraLib().getLayerSize(self.project, layer) then
				customError("Layer '"..self.name.."' cannot be merged with '"..layer.."' because they have different numbers of objects.")
			end
		end)

		local mapAttributes = {}
		local nonTemporalAttributes = {}
		forEachElement(attributes, function(attribute, layers)
			if #layers == 1 or belong(attribute, {"id", "col", "row", "OGR_GEOMETRY","ogr_geometry", "FID"})  then
				local layer = self.name
				if not mapAttributes[layer] then -- SKIP
					mapAttributes[layer] = {}
				end

				table.insert(nonTemporalAttributes, attribute) -- SKIP
			else
				forEachElement(layers, function(_, layerData)
					local layer = layerData.layer
					if not mapAttributes[layer] then -- SKIP
						mapAttributes[layer] = {}
					end

					table.insert(mapAttributes[layer], {attributeName = attribute, newLayerAttributeName = attribute.."_"..layerData.time})
				end)
			end
		end)

		local from = {project = self.project, layer = self.name}
		-- a temp layer is needed because currently one can't remove attributes from a layer thus this layer holds only the desired attributes
		local tempLayer = "_l_y_r_"
		local tempFile = tempLayer.."."..self.source
		local to = {file = File(tempFile), type = self.source}
		TerraLib().saveDataAs(from, to, true, nonTemporalAttributes) -- SKIP
		Layer{project = self.project, file = tempFile, name = tempLayer}
		local toSet = {}
		local attrs = {}
		forEachElement(mapAttributes, function(layer, mapAttribute)
			local dset = TerraLib().getDataSet{project = self.project, layer = layer}
			for i = 0, #dset do
				if not toSet[i + 1] then -- SKIP
					toSet[i + 1] = {}
				end

				for _, attr in pairs(mapAttribute) do
					toSet[i + 1][attr.newLayerAttributeName] = dset[i][attr.attributeName] -- SKIP
					if not belong(attr.newLayerAttributeName, attrs) then -- SKIP
						table.insert(attrs, attr.newLayerAttributeName) -- SKIP
					end
				end
			end
		end)

		TerraLib().saveDataSet(self.project, tempLayer, toSet, newLayerName, attrs) -- SKIP
		TerraLib().removeLayer(self.project, tempLayer) -- SKIP
		return Layer{project = self.project, name = newLayerName}
	end
}

metaTableLayer_ = {
	__index = Layer_,
	__tostring = _Gtme.tostring,
	--- Return the number of objects (points, polygons, lines, or pixels) within the Layer.
	-- @usage -- DONTRUN
	-- print(#layer)
	__len = function(self)
		return TerraLib().getLayerSize(self.project, self.name)
	end
}

--- A Layer representing a geospatial dataset stored in a given data source.
-- Each Layer belongs to a Project.
-- It is possible to use data stored in different data sources to create
-- a Layer, or to create a cellular Layer from scratch. Cellular Layers
-- homogenize the spatial representation of a given
-- model, making the model simpler and requiring less computational
-- resources. Layer gets different arguments, depending on the task one needs
-- to execute. See the table below.
-- @tabular NONE
-- Task & Mandatory Arguments & Optional arguments\
-- Open a Layer that already belongs to a Project. & name, project & \
-- Create a Layer using an existent file, database, or service. & name, project, [arguments related to the source] & [arguments related to the source] \
-- Create a cellular Layer from scratch. It has a set of squared polygons
-- that cover its input. It can be stored in "postgis" or "shp" sources.
-- & input, name, project, resolution, [arguments related to the source] & box, clean, [arguments related to the source] \
-- @arg data.project A file name with the TerraView project to be used, or a Project.
-- @arg data.name A string with the layer name to be used. If the layer already exists and no
-- additional argument is used besides project, then it opens such layer.
-- @arg data.source A string with the data source. See table below with the supported
-- data sources:
-- @arg data.input Name of the input layer whose coverage area will be used to create a
-- cellular layer.
-- @arg data.service A string with the description of a WFS or WMS location.
-- When the string contains wms or wfs in its content, the argument source can be avoided.
-- @arg data.feature A string with the name of the feature to be read from a WFS.
-- @arg data.map A string with the name of the map to be read from a WMS. The map will be
-- saved in the current directory within wms subdirectory automatically created.
-- @arg data.format A string with the image format available in a WMS ("png", default).
-- You can use another format if available in the WMS ("jpeg", "tiff", "geotiff", etc).
-- @tabular source
-- Source & Description & Mandatory & Optional \
-- "postgis" & PostGIS database. & password & host, port, epsg, user\
-- "shp" & ESRI shapefile. & file & index, epsg \
-- "wfs" & Web Feature Service (WFS). & feature, service & \
-- "wms" & Web Map Service (WMS). & map, service & format, user, password, port\
-- "tif" & Geotiff file. & file & epsg \
-- "asc" & ASC format. & file & epsg \
-- "nc" & NetCDF file. & file & epsg \
-- "geojson" & GeoJSON file. & file & epsg\
-- @arg data.host String with the host where the database is stored.
-- The default value is "localhost".
-- @arg data.port Number with the port of the connection. The default value is the standard port
-- of the DBMS. For example, MySQL uses 3306 as standard port.
-- @arg data.user String with the username. The default value is "".
-- @arg data.password A string with the password.
-- @arg data.file A string with the location of the file to be loaded or created, or a base::File.
-- @arg data.box A boolean value indicating whether the cellular Layer will fill the
-- box from the input layer (true) or only the minimal set of cells that cover all the
-- input data (false, default).
-- @arg data.resolution A number with the x and y resolution. It will need to be
-- measured in the same projection of the input layer.
-- @arg data.epsg A number from the EPSG Geodetic Parameter Dataset describing a projection.
-- It is a unique value used to unambiguously identify projected, unprojected, and local spatial
-- coordinate system definitions. When the projection of the data does not have this information,
-- it is necessary to set it manually to allow combining the Layer with other Layer to execute
-- any algorithm. If the prj file of a given data exists but there is no EPSG number, please
-- visit http://www.prj2epsg.org to search for it.
-- A list with the supported epsg numbers is available at http://www.terrame.org/projections.html .
-- @arg data.clean A boolean value indicating whether the argument file should be cleaned
-- if it needs to create the file. The default value is false.
-- @arg data.index A boolean value indicating whether a spatial index file must be created for a
-- shapefile. The default value is true.
-- @arg data.encoding A string value to set the character encoding.
-- Supported encodings are "utf8", "cp1250", "cp1251", "cp1252", "cp1253", "cp1254", "cp1257", and "latin1".
-- The default value is "latin1".
-- @output epsg A number with its projection identifier.
-- @usage -- DONTRUN
-- import("gis")
--
-- proj = Project{
--     file = "myproject.tview"
-- }
--
-- -- Creating a layer from a shapefile.
-- Layer{
--     project = proj,
--     file = filePath("TI_AMZ.shp", "gis"),
--     name = "ti"
-- }
--
-- -- Creating a layer from a PostGIS database.
-- Layer{
--     project = proj,
--     name = "roads",
--     user = "root",
--     password = "abc123",
--     table = "roads"
-- }
--
-- -- Opening a layer called "cells".
-- cl = Layer{
--     project = filePath("rondonia.tview", "gis"),
--     name = "cells"
-- }
--
-- -- Creating a cellular layer.
-- cl2 = Layer{
--     project = proj,
--     input = "amazonia-states",
--     name = "cells",
--     file = "cells.shp",
--     resolution = 5e4 -- 50x50km
-- }
--
-- -- Opening a WFS.
-- Layer{
--     project = proj,
--     name = "protected",
--     service = "http://terrabrasilis.info/redd-pac/wfs/wfs_biomes",
--     feature = "ProtectedAreas2000",
-- }
function Layer(data)
	verifyNamedTable(data)
	mandatoryTableArgument(data, "name", "string")
	if type(data.project) == "string" then
		data.project = File(data.project)
	end

	if type(data.project) == "File" then
		if not data.project:exists() then
			customError("Project file '"..data.project.."' does not exist.")
		end

		data.project = Project{
			file = data.project
		}
	end

	if data.file and type(data.file) == "string" then
		local base, pattern = extractMultiplesPattern(data.file)
		if base then
			optionalTableArgument(data, "times", "table")
			if data.times then
				if #data.times == 1 then
					customWarning("Only one resut has been found to match the pattern '"..base.."_"..data.times[1]..pattern.."'.")
				end

				forEachElement(data.times, function(_, time)
					local filePattern = "_"..time
					Layer{name = data.name..filePattern, file = File(base..filePattern..pattern), project = data.project}
				end)
			else
				local dir = Directory(File(base..pattern):path())
				local files = {}
				forEachElement(dir:list(), function(_, file)
					table.insert(files, dir..file)
				end)

				files = findMultiples(base, pattern, files)
				forEachElement(files, function(_, file)
					Layer{name = data.name..file.pattern, file = File(file.name), project = data.project}
				end)
			end

			return
		end
	end

	if getn(data) == 2 then
		if not data.project.layers[data.name] then
			local msg = "Layer '"..data.name.."' does not exist in Project '"..data.project.file.."'."
			local sug = suggestion(data.name, data.project.layers)
			msg = msg..suggestionMsg(sug)
			customError(msg)
		end

		setmetatable(data, metaTableLayer_)
		TerraLib().openProject(data.project, data.project.file)
		getLayerInfoAdapted(data)

		data.epsg = math.floor(data.epsg)
		data.project[data.name] = data

		return data
	elseif data.input or data.resolution or data.box then
		addCellularLayer(data.project, data)

		return Layer{project = data.project, name = data.name}
	else
		addLayer(data.project, data)
		return Layer{project = data.project, name = data.name}
	end
end

