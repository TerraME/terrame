-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Author: Rodrigo Avancini
-------------------------------------------------------------------------------------------

require("terralib_mod_binding_lua")

-- TODO: To document this

local binding = terralib_mod_binding_lua
local instance = nil
local initialized = false

-- TODO: Remove this after
local function printTable(sometable)
	print("\n\n------------------------------ Table")
	for key, value in pairs(sometable) do
		print(key, value)
	end
end

local function createConnInfo(nameOrPath, dsType)
	local connInfo = {}
		
	if dsType == "ADO" then
		connInfo.PROVIDER = "Microsoft.Jet.OLEDB.4.0"
		connInfo.DB_NAME = nameOrPath
		connInfo.CREATE_OGC_METADATA_TABLES = "TRUE"		
	elseif dsType == "POSTGIS" then
		connInfo.PG_HOST = "localhost" 
		connInfo.PG_PORT = "5432" 
		connInfo.PG_USER = "postgres"
		connInfo.PG_PASSWORD = "postgres"
		connInfo.PG_DB_NAME = nameOrPath
		connInfo.PG_CONNECT_TIMEOUT = "4" 
		connInfo.PG_CLIENT_ENCODING = "CP1252"     -- "LATIN1" --"WIN1252" 
		connInfo.CREATE_OGC_METADATA_TABLES = "TRUE"	
	elseif dsType == "OGR" then
		connInfo.URI = nameOrPath
	elseif dsType == "GDAL" then
		connInfo.URI = nameOrPath
	end
		
	return connInfo
end

local function addDataSourceInfo(dsId, type, title, connInfo)
	local dsInfo = binding.te.da.DataSourceInfo()

	dsInfo:setId(dsId)
	dsInfo:setType(type)
	dsInfo:setAccessDriver(type)
	dsInfo:setTitle(title)
	dsInfo:setConnInfo(connInfo)
	dsInfo:setDescription("Created on TerraME")
	binding.te.da.DataSourceInfoManager.getInstance():add(dsInfo)	
end

local function makeAndOpenDataSource(name, filePath, type)
	local ds = binding.te.da.DataSourceFactory.make(type)
	local connInfo = createConnInfo(filePath, type)
	local dsId = binding.GetRandomicId()

	ds:setId(dsId)
	ds:setConnectionInfo(connInfo) 
	ds:open()
	binding.te.da.DataSourceManager.getInstance():insert(ds)

	addDataSourceInfo(dsId, type, name, connInfo)

	return ds	
end

local function release(obj)
	obj = nil
	collectgarbage("collect")
end

local function createLayer(name, filePath, type)
	local ds = makeAndOpenDataSource(name, filePath, type)
	
	local dsetType = nil
	local dset = nil
	local dsetName = ""
	local env = nil
	local srid = 0
	
	if type == "OGR" then
		dsetName = getFileName(filePath)
		dsetType = ds:getDataSetType(dsetName)
		dset = ds:getDataSet(dsetName)
		local gp = binding.GetFirstGeomProperty(dsetType)
		env = binding.te.gm.Envelope(binding.GetExtent(dsetType:getName(), gp:getName(), ds:getId()))
		srid = gp:getSRID()
	elseif type == "GDAL" then
		dsetName = getFileNameWithExtension(filePath)
		dsetType = ds:getDataSetType(dsetName)
		dset = ds:getDataSet(dsetName)
		local rpos = binding.GetFirstPropertyPos(dset, binding.RASTER_TYPE)
		local raster = dset:getRaster(rpos)
		
		env = raster:getExtent()
		srid = raster:getSRID()
	end
	
	local id = binding.GetRandomicId()
	local layer = binding.te.map.DataSetLayer(id)
	
	layer:setDataSetName(dsetName)
	layer:setTitle(name)
	layer:setDataSourceId(ds:getId())
	layer:setExtent(env)
	layer:setVisibility(binding.VISIBLE)
	layer:setRendererType("ABSTRACT_LAYER_RENDERER")
	layer:setSRID(srid)
	
	binding.te.da.DataSourceManager.getInstance():detach(ds:getId())
	release(ds)
	
	return layer
end

local function isValidTviewExt(filePath)
	return getFileExtension(filePath) == "tview"
end

local function releaseProject(project)
	for title, layer in pairs(project.layers) do
		local id = layer:getDataSourceId()
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():get(id)
		binding.te.da.DataSourceInfoManager.getInstance():remove(id)
		release(dsInfo)
	end
end

local function saveProject(project, layers)
	local writer = binding.te.xml.AbstractWriterFactory.make()
	
	writer:setURI(project.file)

	-- TODO: THIS GET THE PATH WHERE WAS INSTALLED (PROBLEM)
	local schema = binding.FindInTerraLibPath("share/terralib/schemas/terralib/qt/af/project.xsd")
	schema = _Gtme.makePathCompatibleToAllOS(schema)

	writer:writeStartDocument("UTF-8", "no")

	writer:writeStartElement("Project")

	--boost::replace_all(schema_loc, " ", "%20") -- TODO: REVIEW	
	
	writer:writeAttribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema-instance")
	writer:writeAttribute("xmlns:te_da", "http://www.terralib.org/schemas/dataaccess")
	writer:writeAttribute("xmlns:te_map", "http://www.terralib.org/schemas/maptools")
	writer:writeAttribute("xmlns:te_qt_af", "http://www.terralib.org/schemas/common/af")

	writer:writeAttribute("xmlns:se", "http://www.opengis.net/se")
	writer:writeAttribute("xmlns:ogc", "http://www.opengis.net/ogc")
	writer:writeAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink")

	writer:writeAttribute("xmlns", "http://www.terralib.org/schemas/qt/af")
	writer:writeAttribute("xsd:schemaLocation", "http://www.terralib.org/schemas/qt/af "..schema)
	writer:writeAttribute("version", binding.te.common.Version.asString())

	writer:writeElement("Title", project.title)
	writer:writeElement("Author", project.author)
	
	-- TODO: VERIFY PASS LAYERS IDS TO C++
	writer:writeDataSourceList()
	
	writer:writeStartElement("ComponentList")
	writer:writeEndElement("ComponentList")

	writer:writeStartElement("te_map:LayerList")
	
	if layers then 
		local lserial = binding.te.map.serialize.Layer.getInstance()
		
		for title, layer in pairs(layers) do
			lserial:write(layer, writer)
		end
	end
	writer:writeEndElement("te_map:LayerList")

	writer:writeEndElement("Project")

	writer:writeToFile()
end

local function loadProject(project, filePath)		
	-- TODO: This project could not be found:
	if not isFile(filePath) then
		customError("Could not read project file: "..filePath..".")
	end
	
	local xmlReader = binding.te.xml.ReaderFactory.make()

	xmlReader:setValidationScheme(false)
	xmlReader:read(filePath)
	
	if not xmlReader:next() then
		customError("Could not read project information in the file: "..filePath..".")
	end
	
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("Error reading the document "..filePath..", the start element wasn't found.")
	end
	
	if xmlReader:getElementLocalName() ~= "Project" then
		customError("The first tag in the document "..filePath.." is not 'Project'.")
	end	
	
	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		-- TODO
	end
	if xmlReader:getElementLocalName() ~= "Title" then
		-- TODO
	end

	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.VALUE then
		
	end
	project.title = xmlReader:getElementValue()
	
	xmlReader:next() -- End element

	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		-- TODO
	end
	if xmlReader:getElementLocalName() == "Author" then
		-- TODO
	end

	xmlReader:next()

	if xmlReader:getNodeType() == binding.VALUE then
		project.author = xmlReader:getElementValue()
		xmlReader:next() -- End element
	end	

	-- read data source list from this project
	xmlReader:next()

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		-- TODO
	end
	if xmlReader:getElementLocalName() ~= "DataSourceList" then
		-- TODO
	end

	xmlReader:next()

	-- DataSourceList contract form
	if (xmlReader:getNodeType() == binding.END_ELEMENT) and 
		(xmlReader:getElementLocalName() == "DataSourceList") then
		xmlReader:next()
	end
	
	while (xmlReader:getNodeType() == binding.START_ELEMENT) and
			(xmlReader:getElementLocalName() == "DataSource") do
		local  ds = binding.ReadDataSourceInfo(xmlReader)
		binding.te.da.DataSourceInfoManager.getInstance():add(ds)
	end
	
	-- end read data source list

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		-- TODO
	end
	if xmlReader:getElementLocalName() ~= "ComponentList" then
		-- TODO
	end
	
	xmlReader:next() -- End element
	xmlReader:next() -- next after </ComponentList>

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
	
	end
	if xmlReader:getElementLocalName() ~= "LayerList" then
	
	end

	xmlReader:next()

	local lserial = binding.te.map.serialize.Layer.getInstance()
	
	-- Read the layers
	while (xmlReader:getNodeType() ~= binding.END_ELEMENT) and
			(xmlReader:getElementLocalName() ~= "LayerList") do
		local layer = lserial:read(xmlReader)

		if not layer then
			-- TODO
		end
		
		project.layers[layer:getTitle()] = layer
	end
	
	if xmlReader:getNodeType() ~= binding.END_ELEMENT then
	
	end
	if xmlReader:getElementLocalName() ~= "LayerList" then
		
	end

	xmlReader:next()
	if (xmlReader:getNodeType() ~= binding.END_ELEMENT) or
		(xmlReader:getNodeType() ~= binding.END_DOCUMENT) then
		--_Gtme.print("ERROR ########################1")
	end
	if xmlReader:getElementLocalName() ~= "Project" then
		--_Gtme.print("ERROR ########################2")
	end	
	
	-- TODO: THE ONLY WAY SO FAR TO RELEASE THE FILE AFTER READ
	-- WAS READ ANOTHER FILE (REVIEW)
	xmlReader:read(file("YgDbLUDrqQbvu7QxTYxX.xml", "fillcell"))
end

local function addFileLayer(project, name, filePath, type)
	local layer = createLayer(name, filePath, type)
	
	project.layers[layer:getTitle()] = layer
	
	loadProject(project, project.file)
	saveProject(project, project.layers)
	releaseProject(project)
end

local function addCellSpaceLayer(inputLayer, name, resolultion, filePath, type) 
		local connInfo = {}
		
		if type == "OGR" then
			connInfo = createConnInfo(filePath, "OGR")
		end

		local cLId = binding.GetRandomicId()
		local cellLayerInfo = binding.te.da.DataSourceInfo()
		
		cellLayerInfo:setConnInfo(connInfo)
		cellLayerInfo:setType(type)
		cellLayerInfo:setAccessDriver(type)
		cellLayerInfo:setId(cLId)
		cellLayerInfo:setTitle(name)
		cellLayerInfo:setDescription("Created on TerraME")
		
		local cellSpaceOpts = binding.te.cellspace.CellularSpacesOperations()
		local cLType = binding.te.cellspace.CellularSpacesOperations.CELLSPACE_POLYGONS
		local cellName = getFileName(filePath)

		cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolultion, resolultion, inputLayer:getExtent(), inputLayer:getSRID(), cLType, inputLayer)
	end

local function finalize()
	if initialized then
		local terralib = binding.TeSingleton.getInstance()
		local pmger = binding.te.plugin.PluginManager.getInstance()
		
		pmger:shutdownAll()
		pmger:unloadAll()
		pmger:clear()
		terralib:finalize()	
		release(terralib)
		release(pmger)
		
		release(binding)
		initialized = false	
		release(instance)
		
		collectgarbage("collect")
	end
end

TerraLib_ = {
	type_ = "TerraLib",

	init = function()		
		if not initialized then
			binding = terralib_mod_binding_lua
			local terralib = binding.TeSingleton.getInstance()
			terralib:initialize()

			local pmger = binding.te.plugin.PluginManager.getInstance()
			pmger:loadAll()
			initialized = true
		end
	end,

	finalize = function()
		finalize()
	end,

	createProject = function(self, project, layers)
		if not isValidTviewExt(project.file) then
			customError("Please, the file extension must be '.tview'.")
		end
		
		saveProject(project, layers)
	end,

	openProject = function(self, project, filePath)
		-- TODO: This project could not be found:
		-- TODO: add file extension if user didn't set
		if not isValidTviewExt(project.file) then
			customError("Please, the file extension must be '.tview'.")
		end		
	
		loadProject(project, filePath)		

		-- TODO: Maybe here getLayersNames()
	end,

	-- getProjectInfo = function()
		-- local projInfo = {}
		-- projInfo.title = currentProject:getTitle()
		-- projInfo.author = currentProject:getAuthor()
		-- projInfo.file = currentProject:getFileName()

		-- return projInfo
	-- end,

	-- getLayerInfo = function(self, layerName)
		-- local layer = currentProject:getDataSetLayerByTitle(layerName)
		
		-- if layer == nil then
			-- return nil
		-- end
		
		-- local info = {}		
		-- info.name = layer:getTitle()

		-- return info
	-- end,

	-- getLayersNames = function()
		-- local layersNames = currentProject:getLayersTitles()
		
		-- if layersNames == nil then
			-- return {}
		-- end
		
		-- return layersNames
	-- end,

	addShpLayer = function(self, project, name, filePath)
		addFileLayer(project, name, filePath, "OGR")
	end,
	
	addTifLayer = function(self, project, name, filePath)
		addFileLayer(project, name, filePath, "GDAL")
	end,

	layerExists = function(self, name)
		return currentProject:layerExists(name)
	end,

	addShpCellSpaceLayer = function(self, project, inputLayerTitle, name, resolultion, filePath) 
		loadProject(project, project.file)
		
		local inputLayer = project.layers[inputLayerTitle]
		addCellSpaceLayer(inputLayer, name, resolultion, filePath, "OGR")
		
		self:addShpLayer(project, name, filePath)
	end
}

metaTableTerraLib_ = {
	__index = TerraLib_
}

function TerraLib(data)
	if instance then
		return instance
	else	
		setmetatable(data, metaTableTerraLib_)
		instance = data
		return data
	end
end