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
--          Rodrigo Avancini
--#########################################################################################

-- TODO: create Common for this
local dataSourceTypeMapper = {
	shp = "OGR",
	tif = "GDAL",
	postgis = "POSTGIS",
	access = "ADO"
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

Project_ = {
	type_ = "Project",
	--- Add a new layer to the project. This layer can be stored in a database, 
	-- a file, or even a web service.
	-- @arg data.source A string with the data source. See table below:
	-- @tabular source
	-- Source & Description & Mandatory arguments & Optional arguments \
	-- "postgis" & A connection to a PostGIS database. & password, layer & user, port, host \
	-- "shapefile" & A shapefile according to ESRI definition. & file, layer & \
	-- "webservice" & A web service & host, layer & \
	-- @arg data.layer Name of the layer to be created.
	-- @arg data.host String with the host where the database is stored.
	-- The default value is "localhost".
	-- @arg data.port Number with the port of the connection. The default value is the standard port
	-- of the DBMS. For example, MySQL uses 3306 as standard port.
	-- @arg data.user String with the username. The default value is "".
	-- @arg data.password A string with the password.
	-- @arg data.file A string with the location of the file to be loaded.
	-- @usage -- DONTRUN
	-- import("fillcell")
	--
	-- proj = Project{
	--     file = "myproject.tview"
	-- }
	--
	-- proj:addLayer{
	--     layer = "roads",
	--     user = "root",
	--     password = "abc123",
	--     table = "roads"
	-- }
	addLayer = function(self, data)	
		verifyNamedTable(data)
		mandatoryTableArgument(data, "layer", "string")
		
		verifyUnnecessaryArguments(data, {"layer", "source", "file", "host", "port", "user", "password", "database", "table"})
		
		if isEmpty(data.source) then
			-- mandatoryTableArgument(data, "file", "string")
		
			if not isEmpty(data.file) then
				if not isFile(data.file) then
					--customError("The layer file'"..data.file.."' not found.")
					mandatoryTableArgument(data, "source", "string")
				end	
				
				local source = getFileExtension(data.file)
				data.source = source	
			end
		end
		
		mandatoryTableArgument(data, "source", "string")
			
		if not isValidSource(data.source) then
			customError("The source'"..data.source.."' is invalid.")
		end				
		
		if (data.source == "tif") or (data.source == "shp") then
			if not isSourceConsistent(data.source, data.file) then
				customError("File '"..data.file.."' not match to source '"..data.source.."'.")
			end
		end

		if self.layers[data.layer] == nil then
			if data.source == "shp" then	
				mandatoryTableArgument(data, "file", "string")
				verifyUnnecessaryArguments(data, {"layer", "source", "file"})
				
				self.terralib:addShpLayer(self, data.layer, data.file)
			elseif data.source == "tif" then	
				mandatoryTableArgument(data, "file", "string")
				verifyUnnecessaryArguments(data, {"layer", "source", "file"})
				
				self.terralib:addTifLayer(self, data.layer, data.file)
			elseif data.source == "postgis" then
				mandatoryTableArgument(data, "user", "string")
				mandatoryTableArgument(data, "password", "string")
				mandatoryTableArgument(data, "database", "string")
				mandatoryTableArgument(data, "table", "string")
				
				optionalTableArgument(data, "host", "string")
				optionalTableArgument(data, "port", "string")
				
				verifyUnnecessaryArguments(data, {"layer", "source", "host", "port", "user", "password", "database", "table"})
				
				if isEmpty(data.host) then
					data.host = "localhost"
				end
				
				if isEmpty(data.port) then
					data.port = "5432"
				end
				
				if isEmpty(data.encoding) then -- TODO: REVIEW THIS
					data.encoding = "CP1252"
				end
				
				self.terralib:addPgLayer(self, data.layer, data)
			end
		else
			customError("Layer '"..data.layer.."' already exists in the Project.")
		end

		--TODO: implement all types (tif, access, etc)		
	end,
	--- Add a new CellularLayer to the project. It has a raster-like
	-- representation of space with several attributes created from
	-- different spatial representations.
	-- CellularLayers homogeneize the spatial representation of a given
	-- model, making the model simpler and requiring less computational
	-- resources.
	-- @arg data.layer Name of the layer to be created.
	-- @arg data.input A layer whose spatial coverage will be used to create the CellularLayer.
	-- @arg data.box A boolean value indicating whether the CellularLayer will fill the
	-- box from the input layer (true) or only the minimal set of cells that cover all the
	-- input data (false, default).
	-- @arg data.resolution A number with the x and y resolution. It will need to be
	-- measured in the same projection of the input layer.
	-- @usage -- DONTRUN
	-- proj:addCellularLayer{
	--     input = "amazonia-states",
	--     layer = "cells",
	--     resolution = 5e4 -- 50x50km
	-- }
	addCellularLayer = function(self, data)
		verifyNamedTable(data)

		verifyUnnecessaryArguments(data, {"box", "input", "layer", "resolution", "file", "source"})

		defaultTableValue(data, "box", false) -- TODO: CHECK HOW USE THIS
		mandatoryTableArgument(data, "layer", "string")
		mandatoryTableArgument(data, "input", "string")
		positiveTableArgument(data, "resolution")
		
		if isEmpty(data.source) then
			mandatoryTableArgument(data, "file", "string")	
			
			local source = getFileExtension(data.file)
			data.source = source
		else
			mandatoryTableArgument(data, "source", "string")
			
			if not isSourceConsistent(data.source, data.file) then
				customError("File '"..data.file.."' not match to source '"..data.source.."'.")
			end
		end
		
		if not isValidSource(data.source) then
			customError("The source'"..data.source.."' is invalid.")
		end		
		
		if not self.layers[data.input] then
			customError("The input layer '"..data.input.."' not found.")
		end		

		if isFile(data.file) then
			customError("File '"..data.file.."' already exists.")
		end		
		
		if self.layers[data.layer] == nil then
			if data.source == "shp" then	
				mandatoryTableArgument(data, "file", "string")
				self.terralib:addShpCellSpaceLayer(self, data.input, data.layer, data.resolution, data.file)
			elseif data.source == "tif" then	
				mandatoryTableArgument(data, "file", "string")
				--self.terralib:addTifLayer(data.layer, data.file)
			end
		else
			customError("Layer '"..data.layer.."' already exists in the Project.")
		end
	end,

	info = function(self)
		local info = {}
		info.title = self.title
		info.author = self.author
		info.file = self.file
		
		return info
	end,
	
	infoLayer = function(self, name)
		-- TODO: CHECK WHICH INFORMATIONS ARE NECESSARY
		
		local layer = self.layers[name]
		
		if layer == nil then
			customError("Layer '"..name.."' not exists.")
		end
		
		local info = {}		
		info.name = layer:getTitle()	
		info.sid = layer:getDataSourceId()
			
		return info
	end,
}

metaTableProject_ = {
	__index = Project_
}

--- Project is a concept to describe all the data to be used by a given model.
-- Data can be stored in different sources, with different formats and access.
-- A project organises the data into a set of layers, storing all the information
-- related to each data source internally. After that, the user can refer to the
-- data sets only using the respective layer name. 
-- TerraME allows the modeler to create a Project from scratch or load one already
-- created in another software of TerraLib family.
-- @arg data.file A string with the file name to be used. If the
-- file does not exist then it will be created.
-- @arg data.create A boolean value indicating whether the project should be created.
-- The default value is false.
-- @usage -- DONTRUN
-- import("fillcell")
--
-- proj = Project{
--     file = "myproject.tview"
-- }
function Project(data)
	verifyNamedTable(data)
    
	mandatoryTableArgument(data, "file", "string")
	
	local fileName = getFileName(data.file)
	if isEmpty(fileName) then
		data.file = data.file..".tview"
	end

	optionalTableArgument(data, "create", "boolean")
	optionalTableArgument(data, "title", "string")
	optionalTableArgument(data, "author", "string")

	verifyUnnecessaryArguments(data, {"create", "file", "author", "title"})

	if isEmpty(data.author) then
		data.author = "<no author>"
	end

	if isEmpty(data.title) then
		data.title = "<no title>" 
	end 

	if isEmpty(data.create) then
		data.create = false
	end

	local terralib = TerraLib{}
	
	terralib:init()

	--TODO: auto finalize terralib and all objects, how? 

	data.terralib = terralib
	data.layers = {}

	if data.create then
		if isFile(data.file) then
			customError("Project '"..data.file.."' already exists.")
		else
			terralib:createProject(data, data.layers)
		end
	else
		if isFile(data.file) then
			terralib:openProject(data, data.file)
		else
			customError("Project '"..data.file.."' does not exist. Use 'create = true' to create a new Project.")
		end
	end

	setmetatable(data, metaTableProject_)

	return data
end
