-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

-- TODO: create Common for this
local SourceTypeMapper = {
	OGR = "shp",
	GDAL = "tif",
	POSTGIS = "postgis",
	ADO = "access"
}

local function isEmpty(data)
	return (data == "") or (data == nil)
end

local function isValidSource(source)
	return source == "tif" or source == "shp" or source == "postgis" or source == "access"
end

local function isSourceConsistent(source, filePath)
	if filePath ~= nil then
		return source == getFileExtension(filePath)
	end
	
	return true
end

local function validateGeomAndRasterData(data, repr)
	if repr == "geometry" then
		verifyUnnecessaryArguments(data, {"area", "attribute", "default", "dummy", "name", "operation", "select", "output", "table"})
		defaultTableValue(data, "area", false)
		mandatoryTableArgument(data, "select", "string")
	else
		verifyUnnecessaryArguments(data, {"attribute", "default", "dummy", "name", "operation", "select", "output", "table"})
		mandatoryTableArgument(data, "select", "number")
		if data.select < 0 then
			customError("The attribute selected must be '>=' 0.")
		end
	end
	
	defaultTableValue(data, "default", 0)
	defaultTableValue(data, "dummy", math.huge)		
end

local function validateGeomData(data, repr)
	if repr == "geometry" then
		verifyUnnecessaryArguments(data, {"attribute", "name", "operation", "output", "table"})
		data.select = "FID"
	else
		customError("The operation '"..data.operation.."' is not available to raster layer.")
	end	
end

local function addCellularLayer(self, data)
	verifyNamedTable(data)
	verifyUnnecessaryArguments(data, {"box", "input", "name", "resolution", "file", "project", "source", 
										"host", "port", "user", "password", "database", "table"})

	defaultTableValue(data, "box", false) -- TODO: CHECK HOW USE THIS
	mandatoryTableArgument(data, "input", "string")
	positiveTableArgument(data, "resolution")
		
	if isEmpty(data.source) then		
		if isEmpty(data.file) then
			--if not isFile(data.file) then
				--customError("The layer file'"..data.file.."' not found.")
				mandatoryTableArgument(data, "source", "string")
			--end	
		else		
			local source = getFileExtension(data.file)
			data.source = source	
		end
	end
		
	-- if isEmpty(data.source) then
		-- mandatoryTableArgument(data, "file", "string")	
			
		-- local source = getFileExtension(data.file)
		-- data.source = source
	-- else
		-- mandatoryTableArgument(data, "source", "string")
			
		-- if not isSourceConsistent(data.source, data.file) then
			-- customError("File '"..data.file.."' not match to source '"..data.source.."'.")
		-- end
	-- end		

	mandatoryTableArgument(data, "source", "string")
		
	if (data.source == "tif") or (data.source == "shp") then
		if not isSourceConsistent(data.source, data.file) then
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

	switch(data, "source"):caseof{
		shp = function()
			mandatoryTableArgument(data, "file", "string")
				
			verifyUnnecessaryArguments(data, {"box", "input", "name", "project", "resolution", "file", "source"})
				
			if isFile(data.file) then
				customError("File '"..data.file.."' already exists.")
			end			

			self.terralib:addShpCellSpaceLayer(self, data.input, data.name, data.resolution, data.file)
		end,
		--tif = function()
		--	mandatoryTableArgument(data, "file", "string")
			
		--	verifyUnnecessaryArguments(data, {"box", "input", "name", "resolution", "project", "file", "source"})
				
		--	if isFile(data.file) then
		--		customError("File '"..data.file.."' already exists.")
		--	end	
			
			--self.terralib:addTifLayer(data.name, data.file)
		--end,
		postgis = function()
			mandatoryTableArgument(data, "user", "string")
			mandatoryTableArgument(data, "password", "string")
			mandatoryTableArgument(data, "database", "string")
				
			defaultTableValue(data, "table", string.lower(data.name))
			defaultTableValue(data, "host", "localhost")
			defaultTableValue(data, "port", 5432)
			defaultTableValue(data, "encoding", "CP1252")
				
			data.port = tostring(data.port)

			verifyUnnecessaryArguments(data, {"box", "input", "name", "resolution", "source", "encoding",
										"project", "host", "port", "user", "password", "database", "table", "project"})
			self.terralib:addPgCellSpaceLayer(self, data.input, data.name, data.resolution, data)
		end
	}
end

local function addLayer(self, data)	
	verifyNamedTable(data)
	mandatoryTableArgument(data, "name", "string")
		
	verifyUnnecessaryArguments(data, {"name", "source", "project", "file", "host", "port", "user", "password", "database", "table"})
		
	if isEmpty(data.source) then		
		if not isEmpty(data.file) then
			if not isFile(data.file) then
				--customError("The layer file'"..data.file.."' not found.")
				mandatoryTableArgument(data, "source", "string")
			end	
				
			data.source = getFileExtension(data.file)
		end
	end
		
	mandatoryTableArgument(data, "source", "string")
			
	if not isValidSource(data.source) then
		customError("Source '"..data.source.."' is invalid.")
	end				
		
	if data.source == "tif" or data.source == "shp" then
		if not isSourceConsistent(data.source, data.file) then
			customError("File '"..data.file.."' does not match to source '"..data.source.."'.")
		end
	end

	if self.layers[data.name] then
		customError("Layer '"..data.name.."' already exists in the Project.")
	end

	switch(data, "source"):caseof{
		shp = function()
			mandatoryTableArgument(data, "file", "string")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project"})
				
			self.terralib:addShpLayer(self, data.name, data.file)
		end,
		tif = function()	
			mandatoryTableArgument(data, "file", "string")
			verifyUnnecessaryArguments(data, {"name", "source", "file", "project"})
			
			self.terralib:addTifLayer(self, data.name, data.file)
		end,
		postgis = function()
			mandatoryTableArgument(data, "user", "string")
			mandatoryTableArgument(data, "password", "string")
			mandatoryTableArgument(data, "database", "string")
			mandatoryTableArgument(data, "table", "string")
			
			verifyUnnecessaryArguments(data, {"name", "source", "host", "port", "user", "password", "database", "table", "project"})
			
			defaultTableValue(data, "table", string.lower(data.name))
			defaultTableValue(data, "host", "localhost")
			defaultTableValue(data, "port", 5432)
			defaultTableValue(data, "encoding", "CP1252")
				
			data.port = tostring(data.port)

			self.terralib:addPgLayer(self, data.name, data)
		end
	}
	--TODO: implement all types (tif, access, etc)		
end


Layer_ = {
	type_ = "Layer",	
	--- Create a new attribute for each cell of a Layer.
	-- This attribute can be stored as a new
	-- column of a table or a new file, according to where the Layer is stored.
	-- There are several strategies for filling cells according to the geometry of the
	-- input layer.
	-- @arg data.select Name of an attribute from the input data. It is only required when
	-- the selected operation needs a value associated to the geometry (average, sum, mode).
	-- It can also be an integer value representing the band of the raster to be used.
	-- If the raster has only one band then this value is optional.
	-- @arg data.layer Name of an input layer belonging to the same Project. There are
	-- several strategies available, depending on the geometry of the layer. See below:
	-- @tabular layer
	-- Geometry & Using only geometry & Using attribute of objects with some overlap &
	-- Using geometry and attribute \
	-- Points & "count", "distance", "presence" & 
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "value" \
	-- Lines & "count", "distance", "length", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "mode", "value" \
	-- Polygons & "area", "count", "distance", "presence" &
	-- "average", "mode", "maximum", "minimum", "stdev", "sum" &
	-- "average", "mode", "coverage", "value", "sum" \
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
	-- & attribute, layer, select & area, default, dummy \
	-- "count" & Number of objects that have some overlay with the cell.
	-- & attribute, layer & \
	-- "distance" & Distance to the nearest object. The distance is computed from the
	-- centroid of the cell to the closest point, line, or border of a polygon.
	-- & attribute, layer & \
	-- "length" & Total length of overlay between the cell and a layer of lines. If there is
	-- more than one line, it sums all lengths.
	-- & attribute, layer & \
	-- "mode" & More common qualitative value from the objects that have some intersection with
	-- the cell, without taking into account their geometric properties. When using argument area, it
	-- uses the value of the object that has larger coverage. & attribute, layer, select & 
	-- default, dummy \
	-- "maximum" & Maximum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default, dummy \
	-- "minimum" & Minimum quantitative value among the objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default, dummy \
	-- "coverage" & Percentages of each qualitative value covering the cell, using polygons or
	-- raster data. It creates one new attribute for each available value, appending the value to
	-- the attribute name. The sum of the created attribute values for a given cell will range
	-- from zero to one, according to the coverage of coverage.
	-- & attribute, layer, select & default, dummy \
	-- "presence" & Boolean value pointing out whether some object has an overlay with the cell.
	-- & attribute, layer & \
	-- "stdev" & Standard deviation of quantitative values from objects that have some
	-- intersection with the cell, without taking into account their geometric properties. &
	-- attribute, layer, select & default, dummy \
	-- "sum" & Sum of quantitative values from objects that have some intersection with the
	-- cell, without taking into account their geometric properties. When using argument area, it
	-- computes the sum based on the proportions of intersection area. Useful to preserve the total
	-- sum in both layers, such as population size.
	-- & attribute, layer, select & area, default, dummy \
	-- "value" & The value (quantitative or qualitative) of the closest object. If using
	-- area, it uses the value of the object with greater intersection area. & attribute,
	-- layer, select & area \
	-- @arg data.attribute The name of the new attribute to be created.
	-- @arg data.area Whether the calculation will be based on the intersection area (true), 
	-- or the weights are equal for each object with some overlap (false, default value).
	-- @arg data.dummy A value that will ignored when computing the operation, used only for
	-- raster strategies. Note that this argument is related to the input.
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
		mandatoryTableArgument(data, "name", "string")
		mandatoryTableArgument(data, "attribute", "string")
		mandatoryTableArgument(data, "output", "string")
		
		local tlib = TerraLib{}
		local project = self.project
		
		if not project.layers[data.name] then
			customError("The layer '"..data.name.."' does not exist.")
		end
	
		if not data.table then
			data.table = data.name
		end
	
		if isFile(data.output..".shp") then
			customError("File '"..data.output..".shp' already exists and should be removed manually.") -- SKIP This should be removed by #902.
		end

		local layer = project.layers[data.name]
		local info = project.terralib:getLayerInfo(project, layer)
		local repr = info.rep
		
		switch(data, "operation"):caseof{
			area = function()	
				validateGeomData(data, repr)
			end,
			average = function()		
				validateGeomAndRasterData(data, repr)
			end,
			count = function()
				validateGeomData(data, repr)
			end,
			distance = function()
				validateGeomData(data, repr)
			end,
			length = function()
				verifyUnnecessaryArguments(data, {"attribute", "name", "operation", "output", "table"})
				customError("Sorry, this operation was not implemented in TerraLib yet.")
			end,
			mode = function()
				if repr == "geometry" then
					verifyUnnecessaryArguments(data, {"area", "attribute", "default", "dummy", "name", "operation", "select", "output", "table"})
					defaultTableValue(data, "area", false)
					mandatoryTableArgument(data, "select", "string")
				else
					--verifyUnnecessaryArguments(data, {"attribute", "default", "dummy", "name", "operation", "select", "output", "table"})
					--mandatoryTableArgument(data, "select", "number")
					customError("The operation '"..data.operation.."' is not available to raster layer.")
				end

				defaultTableValue(data, "default", 0)
				defaultTableValue(data, "dummy", math.huge)
			end,
			maximum = function()
				validateGeomAndRasterData(data, repr)
			end,
			minimum = function()
				validateGeomAndRasterData(data, repr)
			end,
			coverage = function()
				validateGeomAndRasterData(data, repr)
			end,
			presence = function()
				validateGeomData(data, repr)
			end,
			stdev = function()
				validateGeomAndRasterData(data, repr)
			end,
			sum = function()
				validateGeomAndRasterData(data, repr)
			end
			-- value = function()
				-- verifyUnnecessaryArguments(data, {"area", "attribute", "name", "operation", "select"})

				-- mandatoryTableArgument(data, "select", "string")
				-- defaultTableValue(data, "area", false)
			-- end
		}
		
		tlib:attributeFill(project, data.name, self.name, data.output, data.attribute, data.operation, data.select, data.area, data.default)
		
		self.name = data.output
	end
}

metaTableLayer_ = {
	__index = Layer_, __tostring = _Gtme.tostring
}
	
--- A Layer of cells that belongs to a Project. It has operations to create new attributes from other Layers.
-- The data of the Layer can be stored in several different sources, such as a database, 
-- a file, or even a web service.
-- @arg data.project A file name with the TerraView project to be used, or a Project.
-- @arg data.name A string with the layer name to be used.
-- @arg data.source A string with the data source. See table below:
-- @arg data.input TODO: verify.
-- @tabular source
-- Source & Description & Mandatory arguments & Optional arguments \
-- "none" & Tries to open a Layer already stored in the Project & project, name & \
-- "postgis" & Create a Layer to connect to a PostGIS database. & password, name & user, port, host \
-- "shp" & Create a Layer to work with an ESRI shapefile. & file, name & \
-- "webservice" & Create a Layer to connect to a web service. & host, name & \
-- "cell" & Create a cellular Layer. It has a raster-like
-- representation of space with several attributes created from
-- different spatial representations.
-- Cellular Layers homogeneize the spatial representation of a given
-- model, making the model simpler and requiring less computational
-- resources. It can be stored in "postgis" or "shp". 
-- & input, resolution & box, name, user, port, host, file \
-- @arg data.host String with the host where the database is stored.
-- The default value is "localhost".
-- @arg data.port Number with the port of the connection. The default value is the standard port
-- of the DBMS. For example, MySQL uses 3306 as standard port.
-- @arg data.user String with the username. The default value is "".
-- @arg data.password A string with the password.
-- @arg data.file A string with the location of the file to be loaded.
-- @arg data.box A boolean value indicating whether the cellular Layer will fill the
-- box from the input layer (true) or only the minimal set of cells that cover all the
-- input data (false, default).
-- @arg data.resolution A number with the x and y resolution. It will need to be
-- measured in the same projection of the input layer.
-- @usage -- DONTRUN
-- import("terralib")
--
-- proj = Project{
--     file = "myproject.tview"
-- }
--
-- Layer{
--     project = proj,
--     layer = "roads",
--     user = "root",
--     password = "abc123",
--     table = "roads"
-- }
--
-- cl = Layer{
--     project = filePath("rondonia.tview", "terralib"),
--     name = "cells"
-- }
--
-- cl2 = Layer{
--     project = proj,
--     input = "amazonia-states",
--     layer = "cells",
--     resolution = 5e4 -- 50x50km
-- }
function Layer(data)
	verifyNamedTable(data)

	mandatoryTableArgument(data, "name", "string")

	if type(data.project) == "string" then
		if not isFile(data.project) then
			customError("Project file '"..data.project.."' does not exist.")
		end

		data.project = Project{
			file = data.project
		}
	end

	mandatoryTableArgument(data, "project", "Project")

	if getn(data) == 2 then
		if not data.project.layers[data.name] then
			customError("Layer '"..data.name.."' does not exist in the Project '"..data.project.file.."'.")
		end

		setmetatable(data, metaTableLayer_)
		data.project.terralib:openProject(data.project, data.project.file)

		local layer = data.project.layers[data.name]

		local info = data.project.terralib:getLayerInfo(data.project, layer)
		info.source = SourceTypeMapper[info.type]
		info.type = nil

		forEachElement(info, function(idx, value)
			data[idx] = value
		end)

		return data
	elseif data.input or data.resolution or data.box then
		addCellularLayer(data.project, data)
		return Layer{project = data.project, name = data.name}
	else
		addLayer(data.project, data)
		return Layer{project = data.project, name = data.name}
	end
end

