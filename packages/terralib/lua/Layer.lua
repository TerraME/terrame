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

local function isValidSource(source)
	return belong(source, {"tif", "shp", "postgis", "nc", "asc", "geojson", "wfs"})
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

local function adaptsTerraLibInfo(data)
	local layer = data.project.layers[data.name]
	local info = data.project.terralib:getLayerInfo(data.project, layer)
	info.type = nil

	forEachElement(info, function(idx, value)
		if idx == "url" then
			idx = "service"
			value = string.gsub(value, "^WFS:", "")
		elseif idx == "dataset" then
			idx = "feature"
		end
		data[idx] = value
	end)
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

	local repr = data.project.terralib:getLayerInfo(data.project, data.project.layers[data.input]).rep

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

			self.terralib:addShpCellSpaceLayer(self, data.input, data.name, data.resolution,
											data.file, not data.box, data.index)
		end,
		geojson = function()
			mandatoryTableArgument(data, "file", "File") -- SKIP

			if repr == "raster" then -- SKIP
				verifyUnnecessaryArguments(data, {"input", "name", "project", -- SKIP
					"resolution", "file", "source"})
				data.box = true -- SKIP
			else
				defaultTableValue(data, "box", false) -- SKIP
				verifyUnnecessaryArguments(data, {"box", "input", "name", "project", -- SKIP
					"resolution", "file", "source"})
			end

			self.terralib:addGeoJSONCellSpaceLayer(self, data.input, data.name, data.resolution, -- SKIP
												data.file, not data.box) -- SKIP
		end,
		postgis = function()
			mandatoryTableArgument(data, "user", "string")
			mandatoryTableArgument(data, "password", "string")
			mandatoryTableArgument(data, "database", "string")

			defaultTableValue(data, "table", string.lower(data.name))
			defaultTableValue(data, "host", "localhost")
			defaultTableValue(data, "port", 5432)
			defaultTableValue(data, "encoding", "CP1252")

			data.port = tostring(data.port)

			if repr == "raster" then
				verifyUnnecessaryArguments(data, {"input", "name", "resolution", "source", "encoding", -- SKIP
										"project", "host", "port", "user", "password", "database", "table", "project"})
				data.box = true -- SKIP
			else
				defaultTableValue(data, "box", false)
				verifyUnnecessaryArguments(data, {"box", "input", "name", "resolution", "source", "encoding",
										"project", "host", "port", "user", "password", "database", "table", "project"})
			end

			self.terralib:addPgCellSpaceLayer(self, data.input, data.name, data.resolution, data, not data.box)
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
									"host", "port", "user", "password", "database", "table",
									"service", "feature", "srid"})

	if data.source == nil then
		if data.file then
			if not data.file:exists() then
				customError("File '"..data.file.."' does not exist.")
			end

			data.source = data.file:extension()
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
		customError("Layer name '"..data.name.."' is not a valid name. Please, revise special characters or spaces from it.")
	end

	if self.layers[data.name] then
		customError("Layer '"..data.name.."' already exists in the Project.")
	end

	optionalTableArgument(data, "srid", "number")

	switch(data, "source"):caseof{
		shp = function()
			mandatoryTableArgument(data, "file", "File")
			defaultTableValue(data, "index", true)
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "index", "srid"})

			self.terralib:addShpLayer(self, data.name, data.file, data.index, data.srid)
		end,
		geojson = function()
			mandatoryTableArgument(data, "file", "File") -- SKIP
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "srid"})

			self.terralib:addGeoJSONLayer(self, data.name, data.file, data.srid) -- SKIP
		end,
		tif = function()
			mandatoryTableArgument(data, "file", "File")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "srid"})

			self.terralib:addGdalLayer(self, data.name, data.file, data.srid)
		end,
		nc = function()
			mandatoryTableArgument(data, "file", "File") -- SKIP
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "srid"}) -- SKIP

			self.terralib:addGdalLayer(self, data.name, data.file, data.srid) -- SKIP
		end,
		asc = function()
			mandatoryTableArgument(data, "file", "File")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project", "srid"})

			self.terralib:addGdalLayer(self, data.name, data.file, data.srid)
		end,
		postgis = function()
			mandatoryTableArgument(data, "user", "string")
			mandatoryTableArgument(data, "password", "string")
			mandatoryTableArgument(data, "database", "string")
			mandatoryTableArgument(data, "table", "string")

			verifyUnnecessaryArguments(data, {"name", "source", "host", "port", "user", "password", "database", "table", "project", "srid"})

			defaultTableValue(data, "table", string.lower(data.name))
			defaultTableValue(data, "host", "localhost")
			defaultTableValue(data, "port", 5432)
			defaultTableValue(data, "encoding", "CP1252")

			data.port = tostring(data.port)

			self.terralib:addPgLayer(self, data.name, data, data.srid)
		end,
		wfs = function()
			mandatoryTableArgument(data, "service", "string")
			mandatoryTableArgument(data, "feature", "string")

			verifyUnnecessaryArguments(data, {"name", "source", "service", "feature", "project"})

			self.terralib:addWfsLayer(self, data.name, data.service, data.feature)
		end
	}
end

local function checkBand(layer, data)
	defaultTableValue(data, "band", 0)
	positiveTableArgument(data, "band", true)

	local band = layer:bands()

	if data.band >= band then
		if band > 1 then
			customError("Band '"..data.band.."' does not exist. The available bands are from '0' to '"..band.."'.")
		else
			customError("Band '"..data.band.."' does not exist. The only available band is '0'.")
		end
	end
end

Layer_ = {
	type_ = "Layer",
	--- Return a string with the representation of the layer. It can be "point", "polygon", "line", or "raster".
	-- @usage -- DONTRUN
	-- print(layer:representation())
	representation = function(self)
		return self.project.terralib:getLayerInfo(self.project, self.project.layers[self.name]).rep
	end,
	--- Return the number of bands of a raster layer. If the layer does not have a raster representation
	-- then it will stop with an error. The bands of the raster layer are named from zero to the number of
	-- bands minus one.
	-- @usage -- DONTRUN
	-- print(layer:bands())
	bands = function(self)
		return self.project.terralib:getNumOfBands(self.project, self.name)
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
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "nearest" \
	-- Lines & "count", "distance", "length", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "nearest" \
	-- Polygons & "area", "count", "distance", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "average", "mode", "coverage", "nearest", "sum" \
	-- Raster & (none) &
	-- "average", "mode", "maximum", "minimum", "coverage", "stdev", "sum" &
	-- (none) \
	-- @arg data.operation The way to compute the attribute of each cell. See the
	-- table below:
	-- @tabular operation
	-- Operation & Description & Mandatory arguments & Optional arguments \
	-- "area" & Total overlay area between the cell and a layer of polygons. The created values
	-- will range from zero to one, indicating its area of coverage. & attribute, layer & \
	-- "average" & Average of quantitative values from the objects that have some intersection
	-- with the cell, without taking into account their geometric properties. When using argument
	-- area, it computes the average weighted by the proportions of the respective intersection areas.
	-- Useful to distribute atributes that represent averages, such as per capita income.
	-- & attribute, layer, select  & area, default, band  \
	-- "count" & Number of objects that have some overlay with the cell.
	-- & attribute, layer & \
	-- "distance" & Distance to the nearest object. The distance is computed from the
	-- centroid of the cell to the closest point, line, or border of a polygon.
	-- & attribute, layer & \
	-- "length" & Total length of overlay between the cell and a layer of lines. If there is
	-- more than one line, it sums all lengths.
	-- & attribute, layer & \
	-- "mode" & More common qualitative value from the objects that have some intersection with
	-- the cell, without taking into account their geometric properties. This operation converts the
	-- output to string. Whenever there are two or more values with the same count, the resulting
	-- value will contain all them separated by comma. When using argument area, it
	-- uses the value of the object that has larger coverage. & attribute, layer, select &
	-- default, band \
	-- "maximum" & Maximum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default, band \
	-- "minimum" & Minimum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default, band \
	-- "coverage" & Percentage of each qualitative value covering the cell, using polygons or
	-- raster data. It creates one new attribute for each available value, in the form
	-- attribute.."_"..value, where attribute is the value passed as argument to fill and
	-- value represent the different values in the input data.
	-- The sum of the created attribute values for a given cell will range
	-- from zero to one hundred, according to the coverage of the cell.
	-- When using shapefiles, keep in mind the total limit of ten characters, as
	-- it removes the characters after the tenth in the name. This function will stop with
	-- an error if two attribute names in the output are the same.
	-- & attribute, layer, select & default, band \
	-- "presence" & Boolean value pointing out whether some object has an overlay with the cell.
	-- & attribute, layer & \
	-- "stdev" & Standard deviation of quantitative values from objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default \
	-- "sum" & Sum of quantitative values from objects that have some intersection with the
	-- cell, without taking into account their geometric properties. When using argument area, it
	-- computes the sum based on the proportions of intersection area. Useful to preserve the total
	-- sum in both layers, such as population size.
	-- & attribute, layer, select & area, default \
	-- "nearest" & The value (quantitative or qualitative) of the nearest object. & attribute,
	-- layer, select & \
	-- @arg data.attribute The name of the new attribute to be created.
	-- @arg data.area Whether the calculation will be based on the intersection area (true),
	-- or the weights are equal for each object with some overlap (false, default value).
	-- @arg data.default A value that will be used to fill a cell whose attribute cannot be
	-- computed. For example, when there is no intersection area. Note that this argument is
	-- related to the output.
	-- @usage -- DONTRUN
	-- import("terralib")
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
	fill = function(self, data)
		verifyNamedTable(data)

		mandatoryTableArgument(data, "operation", "string")
		mandatoryTableArgument(data, "attribute", "string")

		if not isValidName(data.attribute) then
			customError("Attribute name '"..data.attribute.."' is not a valid name. Please, revise special characters or spaces from it.")
		end

		local tlib = TerraLib{}
		local project = self.project

		if type(data.layer) == "string" then
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
				if repr == "polygon" then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			average = function()
				if belong(repr, {"point", "line", "polygon"}) then
					if repr == "polygon" then
						verifyUnnecessaryArguments(data, {"area", "attribute", "default", "layer", "operation", "select"})
						defaultTableValue(data, "area", false)
					else
						verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					end

					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "default", "layer", "operation"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			count = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			distance = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			length = function()
				if repr == "line" then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("Operation '"..data.operation.."' is not available for layers with "..repr.." data.")
				end

				customError("Sorry, this operation was not implemented in TerraLib yet.")
			end,
			mode = function()
				if belong(repr, {"point", "line", "polygon"}) then
					if repr == "polygon" then
						verifyUnnecessaryArguments(data, {"area", "attribute", "default", "layer", "operation", "select"})
						defaultTableValue(data, "area", false)
					else
						verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					end

					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "default", "layer", "operation"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			maximum = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "default", "layer", "operation"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			minimum = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "default", "layer", "operation"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			coverage = function()
				if repr == "polygon" then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "band", "default", "layer", "operation"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			nearest = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation", "select"})

					mandatoryTableArgument(data, "select", "string")
					customError("Sorry, this operation was not implemented in TerraLib yet.")
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			presence = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "layer", "operation"})
					data.select = "FID"
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end
			end,
			stdev = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "band"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end,
			sum = function()
				if belong(repr, {"point", "line", "polygon"}) then
					verifyUnnecessaryArguments(data, {"area", "attribute", "default", "layer", "operation", "select"})
					mandatoryTableArgument(data, "select", "string")
					defaultTableValue(data, "area", false)
				elseif repr == "raster" then
					verifyUnnecessaryArguments(data, {"attribute", "default", "layer", "operation", "band"})
					checkBand(data.layer, data)

					data.select = data.band -- SKIP
				else
					customError("The operation '"..data.operation.."' is not available for layers with "..repr.." data.") -- SKIP
				end

				defaultTableValue(data, "default", 0)
			end
		}

		if type(data.select) == "string" then
			if not belong(data.select, data.layer:attributes()) then
				local msg = "Selected attribute '"..data.select.."' does not exist in layer '"..data.layer.name.."'."
				local sugg = suggestion(data.select, data.layer:attributes())

				msg = msg..suggestionMsg(sugg)
				customError(msg)
			end
		end

		tlib:attributeFill(project, data.layer.name, self.name, nil, data.attribute, data.operation, data.select, data.area, data.default, repr)
	end,
	--- Return the Layer's projection. It contains the name of the projection, its Spatial Reference
	-- Identifier (SRID), and
	-- its Proj4 description (www.proj4.org/parameters.html).
	-- @usage -- DONTRUN
	-- print(layer:projection())
	projection = function(self)
		local prj = self.project.terralib:getProjection(self.project.layers[self.name])

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

		return prj.NAME..", with SRID: "..prj.SRID.." (PROJ4: "..prj.PROJ4..")"
	end,
	--- The attribute names of the Layer. It returns a vector of strings, whose size is
	-- the number of attributes.
	-- @usage -- DONTRUN
	-- import("terralib")
	--
	-- print(vardump(layer:attributes()))
	attributes = function(self)
		local propNames = self.project.terralib:getPropertyNames(self.project, self.project.layers[self.name])

		if propNames[0] == "raster" then
			return nil
		end

		local luaPropNames = {}

		for i = 0, #propNames do
			luaPropNames[i + 1] = propNames[i]
		end

		return luaPropNames
	end,
	--- Returns the dummy value of a raster layer. If the layer does not have a raster representation
	-- then it returns a nil value. The bands of the raster layer are named from zero to the number of
	-- bands minus one, if the band is greater than that, it returns an error.
	-- @arg band The band number.
	-- @usage -- DONTRUN
	-- print(layer:dummy(0))
	dummy = function(self, band)
		return self.project.terralib:getDummyValue(self.project, self.name, band)
	end,
	--- Exports the data of a Layer to another data source.
	-- The data can be either a file data or postgis. The SRID and overwrite are common arguments.
	-- @arg data.srid A number from the EPSG Geodetic Parameter Dataset describing a projection.
	-- It can be used to reproject the data.
	-- @arg data.overwrite Indicates if the exported data will be overwritten, the default is false.
	-- @arg data.... Additional arguments related to where the output will be saved. These arguments
	-- are the same for describing the data source when one creates a layer from a file or database.
	-- @usage -- DONTRUN
	-- layer:export{file = "myfile.shp", overwrite = true}
	-- layer:export{file = "myfile.geojson"}
	-- layer:export{file = "myfile.geojson", srid = 4326}
	export = function(self, data)
		verifyNamedTable(data)

		if data.srid then
			positiveTableArgument(data, "srid")
		end

		defaultTableValue(data, "overwrite", false)

		if type(data.file) == "string" then
			data.file = File(data.file)
		end

		if type(data.file) == "File" then
			verifyUnnecessaryArguments(data, {"source", "file", "srid", "overwrite"})

			local source = data.file:extension()

			if isValidSource(source) then
				local toData = {
					file = tostring(data.file),
					type = source,
					srid = data.srid
				}

				self.project.terralib:saveLayerAs(self.project, self.name, toData, data.overwrite)
			else
				invalidFileExtensionError("data", source)
			end
		else
			mandatoryTableArgument(data, "source", "string")

			if data.source == "postgis" then
				verifyUnnecessaryArguments(data, {"source", "user", "password", "database", "host", "port", "encoding", "srid", "overwrite"})

				mandatoryTableArgument(data, "user", "string")
				mandatoryTableArgument(data, "password", "string")
				mandatoryTableArgument(data, "database", "string")
				defaultTableValue(data, "host", "localhost")
				defaultTableValue(data, "port", 5432)
				defaultTableValue(data, "encoding", "CP1252")
				local pgData = data
				pgData.type = "postgis"

				self.project.terralib:saveLayerAs(self.project, self.name, pgData, pgData.overwrite)
			else
				customError("It only supports postgis database, use source = \"postgis\".")
			end
		end
	end
}

metaTableLayer_ = {
	__index = Layer_,
	__tostring = _Gtme.tostring,
	--- Return the number of objects (points, polygons, lines, or pixels) within the Layer.
	-- @usage -- DONTRUN
	-- print(#layer)
	__len = function(self)
		return self.project.terralib:getLayerSize(self.project, self.name)
	end
}

--- A Layer representing a geospatial dataset stored in a given data source.
-- Each Layer belongs to a Project.
-- It is possible to use data stored in different data sources to create
-- a Layer, or to create a cellular Layer from scratch. Cellular Layers
-- homogeneize the spatial representation of a given
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
-- @arg data.service A string with the description of a WFS location.
-- @arg data.feature A string with the name of the feature to be read from a WFS.
-- @tabular source
-- Source & Description & Mandatory & Optional \
-- "postgis" & PostGIS database. & password & host, port, srid, user\
-- "shp" & ESRI shapefile. & file & index, srid \
-- "wfs" & Web Feature Service (WFS). & feature, service & \
-- "tif" & Geotiff file. & file & srid \
-- "asc" & ASC format. & file & srid \
-- "nc" & NetCDF file. & file & srid \
-- "geojson" & GeoJSON file. & file & srid\
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
-- @arg data.srid A number from the EPSG Geodetic Parameter Dataset describing a projection.
-- It is a unique value used to unambiguously identify projected, unprojected, and local spatial
-- coordinate system definitions. When the projection of the data does not have this information,
-- it is necessary to set it manually to allow combining the Layer with other Layer to execute
-- any algorithm. If the prj file of a given data exists but there is no EPSG number, please
-- visit http://www.prj2epsg.org to search for it.
-- @arg data.clean A boolean value indicating whether the argument file should be cleaned
-- if it needs to create the file. The default value is false.
-- @arg data.index A boolean value indicating whether a spatial index file must be created for a
-- shapefile. The default value is true.
-- @output srid A number with its projection identifier.
-- @output sid A string with its unique identifier within the Project.
-- @usage -- DONTRUN
-- import("terralib")
--
-- proj = Project{
--     file = "myproject.tview"
-- }
--
-- -- Creating a layer from a shapefile.
-- Layer{
--     project = proj,
--     file = filePath("TI_AMZ.shp", "terralib"),
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
--     project = filePath("rondonia.tview", "terralib"),
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

	mandatoryTableArgument(data, "project", "Project")

	if getn(data) == 2 then
		if not data.project.layers[data.name] then
			local msg = "Layer '"..data.name.."' does not exist in Project '"..data.project.file.."'."
			local sug = suggestion(data.name, data.project.layers)
			msg = msg..suggestionMsg(sug)

			customError(msg)
		end

		setmetatable(data, metaTableLayer_)
		data.project.terralib:openProject(data.project, data.project.file)
		adaptsTerraLibInfo(data)

		return data
	elseif data.input or data.resolution or data.box then
		addCellularLayer(data.project, data)
		return Layer{project = data.project, name = data.name}
	else
		addLayer(data.project, data)
		return Layer{project = data.project, name = data.name}
	end
end

