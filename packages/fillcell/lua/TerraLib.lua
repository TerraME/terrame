require("terralib_mod_binding_lua")

-- TODO: To document this

local binding = terralib_mod_binding_lua
local currentProject = nil
local initialized = false
local layersDsIds = {}

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

	return ds, layer
end

local function release(obj)
	obj = nil
	collectgarbage("collect")
end

local function saveProject(project, fileName)
	project:setProjectAsChanged(true)
	project:setFileName(fileName)
	
	binding.te.qt.af.XMLFormatter.format(project, true)
	binding.te.qt.af.XMLFormatter.formatDataSourceInfos(true)
	binding.Save(project, fileName)
	--binding.SaveDataSourcesFile()
	binding.te.qt.af.XMLFormatter.format(project, false)
	binding.te.qt.af.XMLFormatter.formatDataSourceInfos(false)	
	
	project:setProjectAsChanged(false)
	
	currentProject = project
end

local function openProject(filePath)		
	-- TODO: This project could not be found:
	-- TODO: add file extension if user didn't set
	local project = binding.ReadProject(filePath)
		
	binding.te.qt.af.XMLFormatter.format(project, false)
	binding.te.qt.af.XMLFormatter.formatDataSourceInfos(false)		
	
	release(currentProject)
	currentProject = project
		
	currentProject:setProjectAsChanged(false)	
end

local function releaseProject()
	for key, value in pairs(layersDsIds) do
		local ds = binding.te.da.DataSourceManager.getInstance():detach(value)
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():get(value)
		binding.te.da.DataSourceInfoManager.getInstance():remove(value)
		release(dsInfo)
		release(ds)
	end
	
	layersDsIds = {}
	release(currentProject)
end

local function addFileLayer(name, filePath, type)
	local ds, layer = createLayer(name, filePath, type)
	
	currentProject:add(layer)
	saveProject(currentProject, currentProject:getFileName())
	
	local dsId = ds:getId()
	if layersDsIds["dsId"] == nil then
		layersDsIds[name] = dsId
	end	
end

local function	addCellSpaceLayer(inputLayerTitle, name, resolultion, filePath, type) 
		local inputLayer = currentProject:getDataSetLayerByTitle(inputLayerTitle)
		
		-- if inputLayer == nil then
			-- customError("The input layer '"..inputLayerTitle.."' not found.")
		-- end

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
		terralib = nil
		pmger = nil
		
		currentProject = nil
		binding = nil
		initialized = false	
		
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
		releaseProject()
		--finalize()
	end,

	createProject = function(self, fileName, author, title)
		releaseProject()
	
		local project = binding.te.qt.af.Project()	

		project:setTitle(title)
		project:setAuthor(author)
		project:setFileName(fileName)
		
		saveProject(project, project:getFileName())
	end,

	openProject = function(self, filePath)
		-- TODO: This project could not be found:
		-- TODO: add file extension if user didn't set
		
		releaseProject()
		openProject(filePath)		

		-- TODO: Maybe here getLayersNames()
	end,

	getProjectInfo = function()
		local projInfo = {}
		projInfo.title = currentProject:getTitle()
		projInfo.author = currentProject:getAuthor()
		projInfo.file = currentProject:getFileName()

		return projInfo
	end,

	getLayerInfo = function(self, layerName)
		local layer = currentProject:getDataSetLayerByTitle(layerName)
		
		if layer == nil then
			return nil
		end
		
		local info = {}		
		info.name = layer:getTitle()

		return info
	end,

	getLayersNames = function()
		local layersNames = currentProject:getLayersTitles()
		
		if layersNames == nil then
			return {}
		end
		
		return layersNames
	end,

	addShpLayer = function(self, name, filePath)
		addFileLayer(name, filePath, "OGR")
	end,
	
	addTifLayer = function(self, name, filePath)
		addFileLayer(name, filePath, "GDAL")
	end,

	layerExists = function(self, name)
		return currentProject:layerExists(name)
	end,

	addShpCellSpaceLayer = function(self, inputLayerTitle, name, resolultion, filePath) 
		addCellSpaceLayer(inputLayerTitle, name, resolultion, filePath, "OGR")
		self:addShpLayer(name, filePath)
	end
}

metaTableTerraLib_ = {
	__index = TerraLib_
}

function TerraLib(data)
	setmetatable(data, metaTableTerraLib_)
	return data
end