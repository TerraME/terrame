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

local binding = _Gtme.terralib_mod_binding_lua
local instance = nil

local OperationMapper = {
	value = binding.VALUE_OPERATION,
	area = binding.PERCENT_TOTAL_AREA,
	presence = binding.PRESENCE,
	count = binding.COUNT,
	distance = binding.MIN_DISTANCE,
	minimum = binding.MIN_VALUE,
	maximum = binding.MAX_VALUE,
	mode = binding.MODE,
	coverage = binding.PERCENT_EACH_CLASS,
	stdev = binding.STANDARD_DEVIATION,
	mean = binding.MEAN,
	weighted = binding.WEIGHTED,
	intersection = binding.HIGHEST_INTERSECTION,
	occurrence = binding.MODE,
	sum = binding.SUM,
	wsum = binding.WEIGHTED_SUM
}

local VectorAttributeCreatedMapper = {
	presence = "presence",
	area = "percent_of_total_area",
	count = "total_values",
	distance = "min_distance",
	minimum = "min_val",
	maximum = "max_val",
	coverage = "percent_area_class",
	stdev = "stand_dev",
	mean = "mean",
	weighted = "weigh_area",
	intersection = "class_high_area",
	occurrence = "mode",
	sum = "sum_values",
	wsum = "weigh_sum_area" 
}

local RasterAttributeCreatedMapper = {
	mean = "_Mean",
	minimum = "_Min_Value",
	maximum = "_Max_Value",
	mode = "_Mode",
	coverage = "",
	stdev = "_Standard_Deviation",
	sum = "_Sum"
}

local SourceTypeMapper = {
	OGR = {"shp", "geojson"},
	GDAL = {"tif", "nc", "asc"},
	POSTGIS = "postgis",
	ADO = "access"
}

local function decodeUri(str)
	str = string.gsub(str, "+", " ")
	str = string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
	str = string.gsub(str, "\r\n", "\n")
	  
	return str	
end

local function encodeUri(str)
	if (str) then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w %-%_%.%~])", function (c)
			return string.format ("%%%02X", string.byte(c))
		end)

		str = string.gsub (str, " ", "+")
	end
	
	return str
end

local function checkConnectionParams(type, connInfo)
	local msg

	do
		local ds = binding.te.da.DataSourceFactory.make(type)
		ds:setConnectionInfo(connInfo)
		msg = binding.te.da.DataSource.Exists(ds)	
	
		ds:close()
	end

	collectgarbage("collect")
	
	return msg
end

local function createPgConnInfo(host, port, user, pass, database, encoding)
	local connInfo = {}
	
	connInfo.PG_HOST = host 
	connInfo.PG_PORT = port 
	connInfo.PG_USER = user
	connInfo.PG_PASSWORD = pass
	connInfo.PG_NEWDB_NAME = database
	connInfo.PG_CONNECT_TIMEOUT = "4" 
	connInfo.PG_CLIENT_ENCODING = encoding -- "UTF-8" --"CP1252" -- "LATIN1" --"WIN1252" 	
	connInfo.PG_CHECK_DB_EXISTENCE = database	

	local errorMsg = checkConnectionParams("POSTGIS", connInfo)	
	if errorMsg ~= "" then
		customError(errorMsg)
	end
	
	if not binding.te.da.DataSource.exists("POSTGIS", connInfo) then
		binding.te.da.DataSource.create("POSTGIS", connInfo)
	end
	
	connInfo.PG_NEWDB_NAME = nil
	connInfo.PG_DB_NAME = database			

	return connInfo
end

local function createFileConnInfo(filePath)
	local connInfo = {}
	connInfo.URI = filePath
	
	return connInfo
end

local function createAdoConnInfo(dbFilePath)
	local connInfo = {}
	--connInfo.PROVIDER = "Microsoft.Jet.OLEDB.4.0"
	connInfo.PROVIDER = "Microsoft.ACE.OLEDB.12.0" 
	connInfo.DB_NAME = dbFilePath
	connInfo.CREATE_OGC_METADATA_TABLES = "TRUE"	
	
	return connInfo
end

local function addDataSourceInfo(type, title, connInfo)
	local dsInfo = binding.te.da.DataSourceInfo()
	local dsId = binding.GetRandomicId()
		
	dsInfo:setId(dsId)
	dsInfo:setType(type)
	dsInfo:setAccessDriver(type)
	dsInfo:setTitle(title)
	dsInfo:setConnInfo(connInfo)
	dsInfo:setDescription("Created on TerraME")
	
	if not binding.te.da.DataSourceInfoManager.getInstance():add(dsInfo) then
		dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfoByConnInfo(dsInfo:getConnInfoAsString())
	end
	
	return dsInfo:getId()
end

local function makeAndOpenDataSource(connInfo, type)
	local ds = binding.te.da.DataSourceFactory.make(type)

	ds:setConnectionInfo(connInfo)
	ds:open()

	return ds
end

local function hasShapeFileSpatialIndex(shapeFile)
	local qixFile = string.gsub(shapeFile, ".shp", ".qix")
	if isFile(qixFile) then
		return true
	end
	
	local sbnFile = string.gsub(shapeFile, ".shp", ".sbn")
	if isFile(sbnFile) then
		return true
	end	
	
	return false
end

local function addSpatialIndex(ds, dSetName)
	ds:execute("CREATE SPATIAL INDEX ON "..dSetName)
end

local function createLayer(name, dSetName, connInfo, type)
	local layer

	do
		local dsId = addDataSourceInfo(type, name, connInfo)

		local ds = makeAndOpenDataSource(connInfo, type)
		ds:setId(dsId)

		binding.te.da.DataSourceManager.getInstance():insert(ds)

		local dSetType
		local dSet
		local env = nil
		local srid = 0

		if type == "OGR" then
			dSetType = ds:getDataSetType(dSetName)
			local gp = binding.GetFirstGeomProperty(dSetType)
			env = binding.te.gm.Envelope(binding.GetExtent(dSetType:getName(), gp:getName(), ds:getId()))
			srid = gp:getSRID()
			if not hasShapeFileSpatialIndex(connInfo.URI) and connInfo.SPATIAL_IDX then
				addSpatialIndex(ds, dSetName)
			end
		elseif type == "GDAL"then
			dSet = ds:getDataSet(dSetName)
			local rpos = binding.GetFirstPropertyPos(dSet, binding.RASTER_TYPE)
			local raster = dSet:getRaster(rpos)	
			env = raster:getExtent()
			srid = raster:getSRID()
		elseif type == "POSTGIS" then
			dSetType = ds:getDataSetType(dSetName)
			local gp = binding.GetFirstGeomProperty(dSetType)
			env = binding.te.gm.Envelope(binding.GetExtent(dSetType:getName(), gp:getName(), ds:getId()))
			srid = gp:getSRID()
		end

		local id = binding.GetRandomicId()
		layer = binding.te.map.DataSetLayer(id)
	
		layer:setDataSetName(dSetName)
		layer:setTitle(name)
		layer:setDataSourceId(ds:getId())
		layer:setExtent(env)
		layer:setVisibility(binding.VISIBLE)
		layer:setRendererType("ABSTRACT_LAYER_RENDERER")
		layer:setSRID(srid)

		binding.te.da.DataSourceManager.getInstance():detach(ds:getId())

		ds:close()
	end

	collectgarbage("collect")
	
	return layer
end

local function isValidTviewExt(filePath)
	return getFileExtension(filePath) == "tview"
end

local function releaseProject(project)
	local removed = {}
	for _, layer in pairs(project.layers) do
		local id = layer:getDataSourceId()

		if not removed[id] then
			binding.te.da.DataSourceInfoManager.getInstance():remove(id)
			removed[id] = id
		end

		collectgarbage("collect")
	end
    binding.te.da.DataSourceManager.getInstance():detachAll()
end

local function decodeDataSourceInfo(dsInfo)
	local connInfo = dsInfo:getConnInfo()
	
	dsInfo:setTitle(decodeUri(dsInfo:getTitle()))
	dsInfo:setDescription(decodeUri(dsInfo:getDescription()))

	if connInfo.URI then
		connInfo.URI = decodeUri(connInfo.URI)
		dsInfo:setConnInfo(connInfo)
	end
	if connInfo.SOURCE then
		connInfo.SOURCE = decodeUri(connInfo.SOURCE)
		dsInfo:setConnInfo(connInfo)
	end	
end

local function encodeDataSourceInfos(layers)
	local encoded = {}
	
	for _, layer in pairs(layers) do
		layer:setTitle(encodeUri(layer:getTitle()))
		
		local lid = layer:getDataSourceId()
		if not encoded[lid] then
			local dsInfo =  binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(lid)
			local connInfo = dsInfo:getConnInfo()
			
			dsInfo:setTitle(encodeUri(dsInfo:getTitle()))
			dsInfo:setDescription(encodeUri(dsInfo:getDescription()))

			if connInfo.URI then
				connInfo.URI = encodeUri(connInfo.URI)
				dsInfo:setConnInfo(connInfo)
			end
			if connInfo.SOURCE then
				connInfo.SOURCE = encodeUri(connInfo.SOURCE)
				dsInfo:setConnInfo(connInfo)
			end		
			binding.te.da.DataSourceInfoManager.getInstance():remove(lid)
			binding.te.da.DataSourceInfoManager.getInstance():add(dsInfo)
			encoded[lid] = lid
		end
	end
end

local function saveProject(project, layers)
	encodeDataSourceInfos(layers)

	local writer = binding.te.xml.AbstractWriterFactory.make()
	
	writer:setURI(project.file)

	-- TODO: THIS GET THE PATH WHERE WAS INSTALLED (PROBLEM)
	local schema = binding.FindInTerraLibPath("share/terralib/schemas/terralib/qt/af/project.xsd")
	schema = _Gtme.makePathCompatibleToAllOS(schema)

	writer:writeStartDocument("UTF-8", "no")

	writer:writeStartElement("Project")

	schema = string.gsub(schema, "%s", "%%20")
	
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
	
	writer:writeDataSourceList()
	
	writer:writeStartElement("ComponentList")
	writer:writeEndElement("ComponentList")

	writer:writeStartElement("te_map:LayerList")
	
	if layers then 
		local lserial = binding.te.map.serialize.Layer.getInstance()
		
		for _, layer in pairs(layers) do
			lserial:write(layer, writer)
		end
	end
	writer:writeEndElement("te_map:LayerList")

	writer:writeEndElement("Project")

	writer:writeToFile()
end

local function loadProject(project, file)		
	if not isFile(file) then
		customError("Could not read project file: "..file..".")
	end
	
	local xmlReader = binding.te.xml.ReaderFactory.make()

	xmlReader:setValidationScheme(false)
	xmlReader:read(file)
	
	if not xmlReader:next() then
		customError("Could not read project information in the file: "..file..".")
	end
	
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("Error reading the document "..file..", the start element wasn't found.")
	end
	
	if xmlReader:getElementLocalName() ~= "Project" then
		customError("The first tag in the document "..file.." is not 'Project'.")
	end	
	
	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "Title" then
		customError("PROJECT READ ERROR.")
	end

	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.VALUE then
		customError("PROJECT READ ERROR.")
	end
	project.title = xmlReader:getElementValue()
	
	xmlReader:next() -- End element

	xmlReader:next()
	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "Author" then
		customError("PROJECT READ ERROR.")
	end

	xmlReader:next()

	if xmlReader:getNodeType() == binding.VALUE then
		project.author = xmlReader:getElementValue()
		xmlReader:next() -- End element
	end	

	-- read data source list from this project
	xmlReader:next()

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "DataSourceList" then
		customError("PROJECT READ ERROR.")
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
		decodeDataSourceInfo(ds)
		binding.te.da.DataSourceInfoManager.getInstance():add(ds)
	end
	
	-- end read data source list

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "ComponentList" then
		customError("PROJECT READ ERROR.")
	end
	xmlReader:next() -- End element
	xmlReader:next() -- next after </ComponentList>

	if xmlReader:getNodeType() ~= binding.START_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "LayerList" then
		customError("PROJECT READ ERROR.")
	end

	xmlReader:next()

	local lserial = binding.te.map.serialize.Layer.getInstance()
	
	-- Read the layers
	while (xmlReader:getNodeType() ~= binding.END_ELEMENT) and
			(xmlReader:getElementLocalName() ~= "LayerList") do
		local layer = lserial:read(xmlReader)
		
		if not layer then
			customError("PROJECT READ ERROR.")
		end
		
		layer:setTitle(decodeUri(layer:getTitle()))
		project.layers[layer:getTitle()] = layer
	end
	
	if xmlReader:getNodeType() ~= binding.END_ELEMENT then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "LayerList" then
		customError("PROJECT READ ERROR.")
	end

	xmlReader:next()
	if not ((xmlReader:getNodeType() == binding.END_ELEMENT) or
		(xmlReader:getNodeType() == binding.END_DOCUMENT)) then
		customError("PROJECT READ ERROR.")
	end
	if xmlReader:getElementLocalName() ~= "Project" then
		customError("PROJECT READ ERROR.")
	end	
	
	-- TODO: THE ONLY WAY SO FAR TO RELEASE THE FILE AFTER READ
	-- WAS READ ANOTHER FILE (REVIEW)
	-- #880
	xmlReader:read(filePath("YgDbLUDrqQbvu7QxTYxX.xml", "terralib"))
end

local function addFileLayer(project, name, filePath, type, addSpatialIdx)
	local connInfo = createFileConnInfo(filePath)
	
	loadProject(project, project.file)
	
	local dSetName = ""
	
	if type == "OGR" then
		if addSpatialIdx then
			connInfo.SPATIAL_IDX = true
		end
		dSetName = getFileName(connInfo.URI)
	elseif type == "GDAL" then
		dSetName = getFileNameWithExtension(connInfo.URI)
	elseif type == "GeoJSON" then
		type = "OGR"
		dSetName = "OGRGeoJSON"
	end

	local layer = createLayer(name, dSetName, connInfo, type)

	project.layers[layer:getTitle()] = layer
	saveProject(project, project.layers)
	releaseProject(project)
end

local function dataSetExists(connInfo, dSetName, type)
	local exists

	do
		local ds = makeAndOpenDataSource(connInfo, type)	
		exists = ds:dataSetExists(dSetName)
	
		ds:close()
	end

	collectgarbage("collect")
	
	return exists
end

local function propertyExists(connInfo, dSetName, property, type)
	local exists

	do
		local ds = makeAndOpenDataSource(connInfo, type)

		if type == "GDAL" then
			local dSet = ds:getDataSet(dSetName)
			local rpos = binding.GetFirstPropertyPos(dSet, binding.RASTER_TYPE)
			local raster = dSet:getRaster(rpos)	
			local numBands = raster:getNumberOfBands()
			return (property >= 0) and (property < numBands)
		end
	
		exists = ds:propertyExists(dSetName, property)
	
		ds:close()
	end

	collectgarbage("collect")
	
	return exists
end

local function dropDataSet(connInfo, dSetName, type)
	do
		local ds = makeAndOpenDataSource(connInfo, type)

		local dsetExists = ds:dataSetExists(dSetName)

		if dsetExists then
			ds:dropDataSet(dSetName)
		end	
	
		ds:close()
	end

	collectgarbage("collect")
end

local function toDataSetLayer(layer)
	if layer:getType() == "DATASETLAYER" then
		layer = binding.te.map.DataSetLayer.toDataSetLayer(layer)	
	else
		customError("Unknown Layer type '"..layer:getTitle().."'.")
	end
	
	return layer
end

local function copyLayer(from, to)
	do
		local fromDsId = from:getDataSourceId()
		local fromDs = binding.GetDs(fromDsId, true)	
	
		from = toDataSetLayer(from)	
		local dSetName = from:getDataSetName()
	
		local toDs = nil
		
		if to.type == "POSTGIS" then
			to.table = dSetName
			local toConnInfo = createPgConnInfo(to.host, to.port, to.user, to.password, to.database, to.encoding)	
			local toTable = string.lower(to.table)	
			-- TODO: IT IS NOT POSSIBLE CREATE A DATABASE (REVIEW)
			--toConnInfo.PG_CHECK_DB_EXISTENCE = toDb		
			--print(binding.te.da.DataSource.exists("POSTGIS", toConnInfo))
			--local exists = binding.te.da.DataSource.exists("POSTGIS", toConnInfo)
			-- if exists then
				-- toConnInfo.PG_DB_TO_DROP = string.lower(to.dbName)	
				-- binding.te.da.DataSource.drop("POSTGIS", toConnInfo)	
			-- end		
			toDs = makeAndOpenDataSource(toConnInfo, "POSTGIS")
		
			local tableExists = toDs:dataSetExists(toTable)
			if tableExists then
				toDs:dropDataSet(toTable)
			end
		elseif to.type == "ADO" then
			local toConnInfo = createAdoConnInfo(to.file)
			-- TODO: ADO DON'T WORK (REVIEW)
			toDs = makeAndOpenDataSource(toConnInfo, "ADO") --binding.te.da.DataSource.create("ADO", toConnInfo)
			-- local tableExists = toDs:dataSetExists(toTable)
			-- if tableExists then
				-- toDs:dropDataSet(toTable)
			-- end		
			--fromDs:moveFirst()
		end
	
		local fromDSetType = fromDs:getDataSetType(dSetName)
		local fromDSet = fromDs:getDataSet(dSetName)
		
		binding.Create(toDs, fromDSetType, fromDSet)
			
		fromDs:close()
		toDs:close()
	end

	collectgarbage("collect")	
end

local function createCellSpaceLayer(inputLayer, name, dSetName, resolultion, connInfo, type, mask)
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
	local cellName = dSetName
	local inputDsType = inputLayer:getSchema()

	if mask then
		if inputDsType:hasGeom() then
			cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolultion, resolultion, 
										inputLayer:getExtent(), inputLayer:getSRID(), cLType, inputLayer)
			return
		else
			customWarning("The 'mask' not work to Raster, it was ignored.")
		end
	end
	
	cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolultion, resolultion, 
								inputLayer:getExtent(), inputLayer:getSRID(), cLType)
end

local function renameEachClass(ds, dSetName, dsType, select, property)
	local dSet = ds:getDataSet(dSetName)
	local numProps = dSet:getNumProperties()
	local propsRenamed = {}
	
	for i = 0, numProps - 1 do
		local currentProp = dSet:getPropertyName(i)
		local newName

		if string.match(currentProp, select) then
			if type(select) == "number" then
				if dsType == "POSTGIS" then
					newName = string.gsub(currentProp, "b"..select.."_", property.."_")
				else
					newName = string.gsub(currentProp, "B"..select.."_", property.."_")
				end
			elseif dsType == "POSTGIS" then
				newName = string.gsub(currentProp, select.."_", property.."_")
			else
				newName = currentProp -- TODO: REVIEW TO SHAPE
			end

			if newName ~= currentProp then
				ds:renameProperty(dSetName, currentProp, newName)
			end
			
			propsRenamed[newName] = newName
		end		
	end
	
	return propsRenamed
end

local function getDataSetTypeByLayer(layer)
	local dst

	do
		local dSetName = layer:getDataSetName()
		local connInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
		local ds = makeAndOpenDataSource(connInfo:getConnInfo(), connInfo:getType())
		dst = ds:getDataSetType(dSetName)
	
		ds:close()
	end

	collectgarbage("collect")
	
	return dst
end

local function getNormalizedName(name)
	if string.len(name) <= 10 then
		return name
	end
	
	return string.sub(name, 1, 10)
end

local function vectorToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, outDSetName, area)
	local propCreatedName
	do
		local v2v = binding.te.attributefill.VectorToVectorMemory()
		v2v:setInput(fromLayer, toLayer)			
			
		local outDs = v2v:createAndSetOutput(outDSetName, outType, outConnInfo)

		if operation == "average" then
			if area then
				operation = "weighted"
			else
				operation = "mean"
			end
		elseif operation == "mode" then
			if area then 
				operation = "intersection"
			else
				operation = "occurrence"
			end
		elseif operation == "sum" then
			if area then
				operation = "wsum"
			end
		end
	
		local toDst = getDataSetTypeByLayer(toLayer)

		v2v:setParams(select, OperationMapper[operation], toDst)

		local err = v2v:pRun() -- TODO: OGR RELEASE SHAPE PROBLEM (REVIEW)
		if err ~= "" then
			customError(err)
		end
	
		propCreatedName = select.."_"..VectorAttributeCreatedMapper[operation]
	
		if outType == "OGR" then
			propCreatedName = getNormalizedName(propCreatedName)
		end
	
		propCreatedName = string.lower(propCreatedName)	
	
		outDs:close()
	end

	collectgarbage("collect")
	
	return propCreatedName
end

local function rasterToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, outDSetName)
	local propCreatedName

	do
		local r2v = binding.te.attributefill.RasterToVector()
			
		fromLayer = toDataSetLayer(fromLayer)
		toLayer = toDataSetLayer(toLayer)
	
		local rDs = binding.GetDs(fromLayer:getDataSourceId(), true)
	    local rDSet = rDs:getDataSet(fromLayer:getDataSetName())
		local rpos = binding.GetFirstPropertyPos(rDSet, binding.RASTER_TYPE)
		local raster = rDSet:getRaster(rpos)
	
		local grid = raster:getGrid()
		grid:setSRID(fromLayer:getSRID())
			
		r2v:setInput(raster, toLayer)
			
		if operation == "average" then
			operation = "mean"
		end			
			
		r2v:setParams(select, OperationMapper[operation], false) -- TODO: TEXTURE PARAM (REVIEW)
			
		local outDs = r2v:createAndSetOutput(outDSetName, outType, outConnInfo)

		local err = r2v:pRun()
		if err ~= "" then
			customError(err)
		end
			
		propCreatedName = "B"..select..RasterAttributeCreatedMapper[operation]
	
		if outType == "POSTGIS" then
			propCreatedName = string.lower(propCreatedName)
		end	
	
		outDs:close()
	end

	collectgarbage("collect")
	
	return propCreatedName
end

local function isNumber(type)
	return	(type == binding.INT16_TYPE) or 
			(type == binding.INT32_TYPE) or 
			(type == binding.INT64_TYPE) or 
			(type == binding.UINT16_TYPE) or 
			(type == binding.UINT32_TYPE) or 
			(type == binding.UINT64_TYPE) or 
			(type == binding.FLOAT_TYPE) or 
			(type == binding.DOUBLE_TYPE) or 
			(type == binding.NUMERIC_TYPE)
end

local function getPropertiesTypes(dse)
	dse:moveFirst()
	local types = {}
	local numProps = dse:getNumProperties()
	
	for i = 0, numProps - 1 do
		types[dse:getPropertyName(i)] = dse:getPropertyDataType(i)
	end
	
	return types
end	

local function createDataSetAdapted(dSet)
	local count = 0
	local numProps = dSet:getNumProperties()
	local set = {}
	local precision = 15
		
	while dSet:moveNext() do
		local line = {}
		for i = 0, numProps - 1 do
			local type = dSet:getPropertyDataType(i)
			
			if isNumber(type) then
				line[dSet:getPropertyName(i)] = tonumber(dSet:getAsString(i, precision))
			elseif type == binding.BOOLEAN_TYPE then
				line[dSet:getPropertyName(i)] = dSet:getBool(i)
			elseif type == binding.GEOMETRY_TYPE then
				line[dSet:getPropertyName(i)] = dSet:getGeom(i)
			else
				line[dSet:getPropertyName(i)] = dSet:getAsString(i)
			end
		end
		set[count] = line
		count = count + 1
	end	
	
	return set
end

local function getGeometryTypeName(geomType)
	if 	geomType == binding.te.gm.GeometryType or 
		geomType == binding.te.gm.GeometryZType or
        geomType == binding.te.gm.GeometryMType or 
		geomType == binding.te.gm.GeometryZMType then
		return "geometry"
	elseif 	geomType == binding.te.gm.PointType or
			geomType == binding.te.gm.PointZType or
			geomType == binding.te.gm.PointMType or
			geomType == binding.te.gm.PointZMType or
			geomType == binding.te.gm.PointKdType or
			geomType == binding.te.gm.MultiPointType or
			geomType == binding.te.gm.MultiPointZType or
			geomType == binding.te.gm.MultiPointMType or
			geomType == binding.te.gm.MultiPointZMType then			
		return "point"
	elseif	geomType == binding.te.gm.LineStringType or
			geomType == binding.te.gm.LineStringZType or
			geomType == binding.te.gm.LineStringMType or
			geomType == binding.te.gm.LineStringZMType or
			geomType == binding.te.gm.MultiLineStringType or
			geomType == binding.te.gm.MultiLineStringZType or
			geomType == binding.te.gm.MultiLineStringMType or
			geomType == binding.te.gm.MultiLineStringZMType then			
		return "line"
	elseif 	geomType == binding.te.gm.CircularStringType or
			geomType == binding.te.gm.CircularStringZType or
			geomType == binding.te.gm.CircularStringMType or
			geomType == binding.te.gm.CircularStringZMType then
		return "circular"
	elseif 	geomType == binding.te.gm.CompoundCurveType or
			geomType == binding.te.gm.CompoundCurveZType or
			geomType == binding.te.gm.CompoundCurveMType or
			geomType == binding.te.gm.CompoundCurveZMType then
		return "compound"
	elseif 	geomType == binding.te.gm.PolygonType or
			geomType == binding.te.gm.PolygonZType or
			geomType == binding.te.gm.PolygonMType or
			geomType == binding.te.gm.PolygonZMType or
			geomType == binding.te.gm.CurvePolygonType or
			geomType == binding.te.gm.CurvePolygonZType or
			geomType == binding.te.gm.CurvePolygonMType or
			geomType == binding.te.gm.CurvePolygonZMType or
			geomType == binding.te.gm.MultiPolygonType or
			geomType == binding.te.gm.MultiPolygonZType or
			geomType == binding.te.gm.MultiPolygonMType or
			geomType == binding.te.gm.MultiPolygonZMType then			
		return "polygon"
	elseif 	geomType == binding.te.gm.GeometryCollectionType or
			geomType == binding.te.gm.GeometryCollectionZType or
			geomType == binding.te.gm.GeometryCollectionMType or
			geomType == binding.te.gm.GeometryCollectionZMType then
		return "collection"			  		
	elseif 	geomType == binding.te.gm.MultiSurfaceType or
			geomType == binding.te.gm.MultiSurfaceZType or
			geomType == binding.te.gm.MultiSurfaceMType or
			geomType == binding.te.gm.MultiSurfaceZMType then
		return "surface"
	elseif 	geomType == binding.te.gm.PolyhedralSurfaceType or
			geomType == binding.te.gm.PolyhedralSurfaceZType or
			geomType == binding.te.gm.PolyhedralSurfaceMType or
			geomType == binding.te.gm.PolyhedralSurfaceZMType then
		return "polyhedral"	
	elseif 	geomType == binding.te.gm.TINType or
			geomType == binding.te.gm.TINZType or
			geomType == binding.te.gm.TINMType or
			geomType == binding.te.gm.TINZMType or
			geomType == binding.te.gm.TriangleType or
			geomType == binding.te.gm.TriangleZType or
			geomType == binding.te.gm.TriangleMType or
			geomType == binding.te.gm.TriangleZMType then
		return "triangle"		
	end  
	
	return "unknown"
end

TerraLib_ = {
	type_ = "TerraLib",
	
	--- Return the current TerraLib version.
	-- @usage import("terralib")
	-- tl = TerraLib{}
	-- print(tl:getVersion())
	getVersion = function()
		return binding.te.common.Version.asString()
	end,
	--- Create a new Project.
	-- @arg project The name of the project.
	-- @arg layers A table where the layers will be stored.
	-- @usage -- DONTRUN
	-- import("terralib")
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	createProject = function(_, project, layers)
		if not isValidTviewExt(project.file) then
			customError("Please, the file extension must be '.tview'.")
		end
		
		if not project.layers then
			project.layers = layers
		end
		
		saveProject(project, layers)
	end,
	--- Open a new project.
	-- @arg project The name of the project.
	-- @arg filePath The path for the project.
	-- @usage -- DONTRUN
	-- import("terralib")
	-- tl = TerraLib{}
	-- proj = {}
	-- tl:openProject(proj2, "myproject.tview")
	openProject = function(_, project, filePath)
		if not isValidTviewExt(filePath) then
			customError("Please, the file extension must be '.tview'.")
		end		
		
		if not project.file then
			project.file = filePath
		end
		
		loadProject(project, filePath)		
	end,
	--- Return the information of a given layer.
	-- @arg project The name of the project.
	-- @arg layer The name of the layer.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- tl:addPgLayer(proj, "SampaPg", pgData)
	-- 	
	-- layerInfo = tl:getLayerInfo(proj, proj.layers[layerName2])		
	getLayerInfo = function(_, project, layer)
		local info = {}		
		info.name = layer:getTitle()	
		info.sid = layer:getDataSourceId()
		local dseName = layer:getDataSetName()

		loadProject(project, project.file)
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(info.sid)

		local type = dsInfo:getType()
		info.type = type
		local connInfo = dsInfo:getConnInfo()

		if type == "POSTGIS" then
			info.host = connInfo.PG_HOST
			info.port = connInfo.PG_PORT
			info.user = connInfo.PG_USER
			info.password = connInfo.PG_PASSWORD
			info.database = connInfo.PG_DB_NAME
			info.table = dseName
			info.source = SourceTypeMapper.POSTGIS
		elseif type == "OGR" then
			info.file = connInfo.URI
			info.source = getFileExtension(info.file)
		elseif type == "GDAL" then
			info.file = connInfo.URI
			info.source = getFileExtension(info.file)
		elseif type == "ADO" then
			info.source = SourceTypeMapper.ADO
		end

		do
			local ds = makeAndOpenDataSource(connInfo, type)
			local dst = ds:getDataSetType(dseName)
		
			if dst:hasGeom() then
				local gp = binding.GetFirstGeomProperty(dst)
				local gpt = gp:getGeometryType()
				info.rep = getGeometryTypeName(gpt)
			elseif dst:hasRaster() then
				info.rep = "raster"
			else
				info.rep = "unknown"
			end
	
			ds:close()
		end

		collectgarbage("collect")
		
		releaseProject(project)
		
		return info
	end,
	--- Add a shapefile layer to a given project.
	-- @arg project The name of the project.
	-- @arg name The name of the layer.
	-- @arg filePath The path for the project.
	-- @usage -- DONTRUN
	-- tl = TerraLib()
	-- tl:createProject("project.tview", {})
	-- tl:addShpLayer(proj, "ShapeLayer", filePath("sampa.shp", "terralib"))
	addShpLayer = function(_, project, name, filePath, addSpatialIdx)
		addFileLayer(project, name, filePath, "OGR", addSpatialIdx)
	end,
	--- Add a new GDAL layer to a given project.
	-- @arg filePath The path for the project.
	-- @arg name The name of the layer.
	-- @arg project The name of the project.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--	
	-- tl:createProject(proj, {})
	--	
	-- layerName = "TifLayer"
	-- layerFile = filePath("cbers_rgb342_crop1.tif", "terralib")
	-- tl:addGdalLayer(proj, layerName, layerFile)
	addGdalLayer = function(_, project, name, filePath)
		addFileLayer(project, name, filePath, "GDAL")
	end,
	--- Add a GeoJSON layer to a given project.
	-- @arg project The name of the project.
	-- @arg name The name of the layer.
	-- @arg filePath The path for the project.
	-- @usage -- DONTRUN
	-- tl = TerraLib()
	-- tl:createProject("project.tview", {})
	-- tl:addGeoJSONLayer(proj, "GeoJSONLayer", filePath("Setores_Censitarios_2000_pol.geojson", "terralib"))
	addGeoJSONLayer = function(_, project, name, filePath, addSpatialIdx)
		addFileLayer(project, name, filePath, "GeoJSON", addSpatialIdx)
	end,
	--- Add a new PostgreSQL layer to a given project.
	-- @arg project The name of the project.
	-- @arg name The name of the layer.
	-- @arg data.host Name of the host.
	-- @arg data.port Port number.
	-- @arg data.user The user name.
	-- @arg data.password The password.
	-- @arg data.database The database name.
	-- @arg data.encoding The encoding of the table.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- tl:addPgLayer(proj, "SampaPg", pgData)
	addPgLayer = function(_, project, name, data)				
		local connInfo = createPgConnInfo(data.host, data.port, data.user, data.password, data.database, data.encoding)
		
		loadProject(project, project.file)
		
		local layer = nil
		
		if dataSetExists(connInfo, data.table, "POSTGIS") then
			connInfo.PG_NEWDB_NAME = data.table
			layer = createLayer(name, data.table, connInfo, "POSTGIS")
		else
			releaseProject(project)
			customError("Is not possible add the Layer. The table '"..data.table.."' does not exist.")
		end
		
		project.layers[layer:getTitle()] = layer		
		saveProject(project, project.layers)		
		releaseProject(project)		
	end,
	--- Create a new cellular layer into a shapefile.
	-- @arg project The name of the project.
	-- @arg filePath The path for the project.
	-- @arg name The name of the layer.
	-- @arg resolution The size of a cell.
	-- @arg inputLayerTitle The name of the layer.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- layerName1 = "SampaShp"
	-- layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--
	--	tl:addShpCellSpaceLayer(proj, layerName1, "Sampa_Cells", 0.7, currentDir())
	addShpCellSpaceLayer = function(self, project, inputLayerTitle, name, resolution, filePath, mask, addSpatialIdx) 
		loadProject(project, project.file)
		
		if not string.find(filePath, "/") then
			filePath = _Gtme.makePathCompatibleToAllOS(currentDir().."/")..filePath
		end

		local inputLayer = project.layers[inputLayerTitle]
		local connInfo = createFileConnInfo(filePath)
		local dSetName = getFileName(connInfo.URI)
		
		createCellSpaceLayer(inputLayer, name, dSetName, resolution, connInfo, "OGR", mask)
		
		self:addShpLayer(project, name, filePath, addSpatialIdx)
	end,
	--- Add a new cellular layer to a PostgreSQL connection.
	-- @arg project The name of the project.
	-- @arg inputLayerTitle Name of the input layer.
	-- @arg data The connection data, such as host, port, and user.
	-- @arg name The name of the layer.
	-- @arg resolution The size of a cell.
	-- @usage --DONTRUN
	-- local proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- local pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- local clName1 = "SampaPgCells"	
	-- local resolution = 0.7
	-- tl:addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData)
	addPgCellSpaceLayer = function(self, project, inputLayerTitle, name, resolution, data, mask) 
		loadProject(project, project.file)

		local inputLayer = project.layers[inputLayerTitle]
		local connInfo = createPgConnInfo(data.host, data.port, data.user, data.password, data.database, data.encoding)

		if not dataSetExists(connInfo, data.table, "POSTGIS") then
			createCellSpaceLayer(inputLayer, name, data.table, resolution, connInfo, "POSTGIS", mask)
		else
			releaseProject(project)
			customError("The table '"..data.table.."' already exists.")
		end
		
		self:addPgLayer(project, name, data)	
	end,
	--- Remove a PostreSQL table.
	-- @arg data.host Name of the host.
	-- @arg data.port Port number.
	-- @arg data.user The user name.
	-- @arg data.password The password.
	-- @arg data.database The database name.
	-- @arg data.encoding The encoding of the table.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- tl:addPgLayer(proj, "SampaPg", pgData)
	-- 	
	-- tl:dropPgTable(pgData)
	dropPgTable = function(_, data)
		local connInfo = createPgConnInfo(data.host, data.port, data.user, data.password, data.database, data.encoding)		
		dropDataSet(connInfo, string.lower(data.table), "POSTGIS")
	end,
	--- Remove a PostreSQL database.
	-- @arg data.host Name of the host.
	-- @arg data.port Port number.
	-- @arg data.user The user name.
	-- @arg data.password The password.
	-- @arg data.database The database name.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- tl:addPgLayer(proj, "SampaPg", pgData)
	-- 	
	-- tl:dropPgDatabase(pgData)
	dropPgDatabase = function(_, data)
		local connInfo = {}
		connInfo.PG_DB_TO_DROP = data.database
		connInfo.PG_HOST = data.host 
		connInfo.PG_PORT = data.port 
		connInfo.PG_USER = data.user
		connInfo.PG_PASSWORD = data.password
		connInfo.PG_CHECK_DB_EXISTENCE = data.database
		
		if binding.te.da.DataSource.exists("POSTGIS", connInfo) then
			binding.te.da.DataSource.drop("POSTGIS", connInfo)
		end
	end,
	--- Copy a given layer to another.
	-- @arg project The name of the project.
	-- @arg from The name input layer.
	-- @arg to The name of the output layer.
	-- 	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- tl:createProject(proj, {})
	--	
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	--     encoding = "CP1252"	
	-- }	
	--	
	-- tl:addPgLayer(proj, "SampaPg", pgData)
	-- 	
	-- tl:copyLayer(proj, layerName1, pgData)	
	copyLayer = function(_, project, from, to)
		loadProject(project, project.file)
		
		local fromLayer = project.layers[from]	
		copyLayer(fromLayer, to)
		
		releaseProject(project)	
	end,
	--- Fill a given attribute in a layer.
	-- @arg project The name of the project.
	-- @arg operation Name of the operation.
	-- @arg select The attribute to be used in the operation.
	-- @arg from Name of the input layer with the data where the operations will take place.
	-- @arg to Name of the reference layer with the elements to be copied to the output. 
	-- @arg out Name of the layer to be created with the output.
	-- @arg area A boolean value indicating whether the area should be considered.
	-- @arg property Name of the attribute to be created.
	-- @arg default The default value.
	-- @arg repr A string with the spatial representation of data ("raster", "polygon", "point", or "line").
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	--	
	-- tl:createProject(proj, {})
	--
	-- layerName1 = "Para"
	-- layerFile1 = filePath("limitePA_polyc_pol.shp", "terralib")
	-- tl:addShpLayer(proj, layerName1, layerFile1)		
	--	
	-- resolution = 60e3
	-- tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, filePath1)
	--	
	-- clSet = tl:getDataSet(proj, clName)
	--	
	-- layerName2 = "Protection_Unit" 
	-- layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
	-- tl:addShpLayer(proj, layerName2, layerFile2)
	--	
	-- tl:attributeFill(proj, layerName2, clName, presLayerName, "presence", "presence", "FID")
	attributeFill = function(_, project, from, to, out, property, operation, select, area, default, repr)
		do
			loadProject(project, project.file)

			local fromLayer = project.layers[from]
			local fromDsInfo =  binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
			local toLayer = project.layers[to]
			local toDsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(toLayer:getDataSourceId())
			local outDsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(toLayer:getDataSourceId())
		
			local outType = outDsInfo:getType()
		
			if outType == "OGR" then
				if string.len(property) > 10 then
					property = getNormalizedName(property)
					customWarning("The 'attribute' lenght is more than 10 characters, it was changed to '"..property.."'.")
				end
			end
		
			if propertyExists(toDsInfo:getConnInfo(), toLayer:getDataSetName(), property, toDsInfo:getType()) then
				customError("The attribute '"..property.."' already exists in the Layer.")
			end		

			if not propertyExists(fromDsInfo:getConnInfo(), fromLayer:getDataSetName(), select, fromDsInfo:getType()) then
				if repr == "raster" then
					customError("Selected band '"..select.."' does not exist in layer '"..from.."'.")
				else
					customError("Selected attribute '"..select.."' does not exist in layer '"..from.."'.")
				end
			end
		
			local outDs
			local outConnInfo = outDsInfo:getConnInfo()
			local outDSetName = out
			local propCreatedName
		
			if outType == "POSTGIS" then
				outDSetName = string.lower(outDSetName)
				outConnInfo.PG_NEWDB_NAME = outDSetName
			elseif outType == "OGR" then
				local outDir = _Gtme.makePathCompatibleToAllOS(getFileDir(outConnInfo.URI))
				outConnInfo.URI = outDir..out..".shp"
				outConnInfo.DRIVER = "ESRI Shapefile"
				outConnInfo.SPATIAL_IDX = true
			end				
		
			local dseType = fromLayer:getSchema()
		
			if dseType:hasRaster() then
				propCreatedName = rasterToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, out)
			else
				propCreatedName = vectorToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, out, area)
			end
		
			if outType == "OGR" then
				propCreatedName = getNormalizedName(propCreatedName)
			end
		
			if (outType == "POSTGIS") and (type(select) == "string")  then
				select = string.lower(select)
			end
		
			outDs = makeAndOpenDataSource(outConnInfo, outType)
			local attrsRenamed = {}
		
			if operation == "coverage" then
				attrsRenamed = renameEachClass(outDs, outDSetName, outType, select, property)
			else
				outDs:renameProperty(outDSetName, propCreatedName, property)
				attrsRenamed[property] = property
			end
		
			if default then
				for _, prop in pairs(attrsRenamed) do
					outDs:updateNullValues(outDSetName, prop, tostring(default))
				end			
			end
		
			-- TODO: RENAME INSTEAD OUTPUT
			-- #875
			-- outDs:renameDataSet(outDSetName, "rename_test")		
			
			local outLayer = createLayer(out, outDSetName, outConnInfo, outType)
			project.layers[out] = outLayer
		
			loadProject(project, project.file) -- TODO: IT NEED RELOAD (REVIEW)
			saveProject(project, project.layers)
			releaseProject(project)
		
			outDs:close()
		end

		collectgarbage("collect")		
	end,
	--- Returns a given dataset from a layer.
	-- @arg project The name of the project.
	-- @arg layerName Name of the layer to be read.
	-- @usage -- DONTRUN
	-- ds = terralib:getDataSet("myproject.tview", "mylayer")
	getDataSet = function(_, project, layerName)
		local set

		do
			loadProject(project, project.file)
		
			local layer = project.layers[layerName]
			layer = binding.te.map.DataSetLayer.toDataSetLayer(layer)	
			local dseName = layer:getDataSetName()
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			local dse = ds:getDataSet(dseName)
		
			set = createDataSetAdapted(dse)
		
			releaseProject(project)
			ds:close()
		end

		collectgarbage("collect")
		
		return set
	end,
	--- Save a given dataset.
	-- @arg project The name of the project.
	-- @arg fromLayerName The input layer name.
	-- @arg toName The output layer name.
	-- @arg toSet A table mapping the names of the attributes from the input to the output.
	-- @arg attrs A table with the attributes to be saved.
	-- @usage -- DONTRUN
	-- saveDataSet(self, project, fromLayerName, toSet, toName, attrs)
	saveDataSet = function(_, project, fromLayerName, toSet, toName, attrs)
		do
			loadProject(project, project.file)

			local fromLayer = project.layers[fromLayerName]
			fromLayer = toDataSetLayer(fromLayer)	
			local dseName = fromLayer:getDataSetName()
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			local dse = ds:getDataSet(dseName)
			local dst = ds:getDataSetType(dseName)
			local pk = dst:getPrimaryKey()
			local pkName = pk:getPropertyName(0)
			local numProps
			local newDst = binding.te.da.DataSetType(toName)
			local geom = binding.GetFirstGeomProperty(dst)
			local srid = geom:getSRID()	
		
			local attrsToIn = {}
			if attrs then
				for i = 1, #attrs do
					attrsToIn[attrs[i]] = true
				end
			end
		
			local types = getPropertiesTypes(dse)
			local outType = dsInfo:getType()

			-- Config the properties of the new DataSet 
			for k, v in pairs(toSet[1]) do		
				local isPk = (k == pkName)
			
				if types[k] ~= nil then
					if types[k] == binding.GEOMETRY_TYPE then
						newDst:add(k, srid, geom:getGeometryType(), true)
					else
						newDst:add(k, isPk, types[k], true)
					end
				elseif attrsToIn[k] then
					if type(v) == "number" then
						newDst:add(k, isPk, binding.DOUBLE_TYPE, true)
					elseif type(v) == "string" then
						newDst:add(k, isPk, binding.STRING_TYPE, true)
					elseif type(v) == "boolean" then
						if outType == "OGR" then
							newDst:add(k, isPk, binding.STRING_TYPE, true)
						else
							newDst:add(k, isPk, binding.BOOLEAN_TYPE, true)
						end
					end
				end
			end

			-- Create the new DataSet
			local newDse = binding.te.mem.DataSet(newDst)
			numProps = newDse:getNumProperties()
		
			for i = 1, #toSet do
				local item = binding.te.mem.DataSetItem.create(newDse)

				for j = 0, numProps - 1 do
					local propName = newDse:getPropertyName(j)

					for k, v in pairs(toSet[i]) do				
						if propName == k then 
							local type = newDse:getPropertyDataType(j)
						
							if type == binding.INT16_TYPE then
								item:setInt16(j, v)
							elseif type == binding.INT32_TYPE then
								item:setInt32(j, v)
							elseif type == binding.INT64_TYPE then
								item:setInt64(j, v)
							elseif type == binding.FLOAT_TYPE then
								item:setFloat(j, v)
							elseif type == binding.DOUBLE_TYPE then
								item:setDouble(j, v)
							elseif type == binding.NUMERIC_TYPE then
								item:setNumeric(j, tostring(v))
							elseif type == binding.BOOLEAN_TYPE then
								item:setBool(j, v)
							elseif type == binding.GEOMETRY_TYPE then
								item:setGeom(j, v)
							else
								item:setString(j, tostring(v))
							end

							break
						end
					end
				end
				newDse:add(item)
			end
		
			local newDstName = newDst:getName()

			-- Remove the DataSet if it already exists
			local outConnInfo = dsInfo:getConnInfo()
			local outDs = nil
			if outType == "POSTGIS" then
				newDstName = string.lower(newDstName)
				outConnInfo.PG_NEWDB_NAME = string.lower(newDstName)
				outDs = makeAndOpenDataSource(outConnInfo, outType)
			elseif outType == "OGR" then
				local outDir = _Gtme.makePathCompatibleToAllOS(getFileDir(outConnInfo.URI))
				outConnInfo.URI = outDir..newDstName..".shp"		

				if fromLayerName == toName then
					outDs = ds
				else	
					outDs = makeAndOpenDataSource(outConnInfo, outType)
				end
			end
			
			if outDs:dataSetExists(newDstName) then
				outDs:dropDataSet(newDstName)
			end

			-- Save the new DataSet into the from DataSource
			outDs:createDataSet(newDst)
			newDse:moveBeforeFirst()
			outDs:add(newDstName, newDse)
		
			-- Create the new Layer
			local outLayer = createLayer(toName, newDstName, outConnInfo, outType)
			project.layers[toName] = outLayer
		
			saveProject(project, project.layers)
			releaseProject(project)
		
			ds:close()
			dst:clear()
			newDst:clear()
			newDse:clear()		
			outDs:close()
		end

		collectgarbage("collect")		
	end,
	--- Return the content of a shapefile.
	-- @arg filePath The path for the file to be loaded.
	-- @usage -- DONTRUN
	-- tl = TerraLib{}
	-- local shpPath = filePath("sampa.shp", "terralib")
	-- dSet = tl:getShpByFilePath(shpPath)
	getShpByFilePath = function(_, filePath)
		local set

		do
			local connInfo = createFileConnInfo(filePath)
			local ds = makeAndOpenDataSource(connInfo, "OGR")
			local dSetName = getFileName(filePath)
			local dSet = ds:getDataSet(dSetName)
			set = createDataSetAdapted(dSet)
		
			ds:close()
		end

		collectgarbage("collect")
		
		return set	
	end,
	--- Returns the number of bands of some Raster.
	-- @arg project The name of the project.
	-- @arg layerName The input layer name.
	-- @usage -- DONTRUN
	-- tl:addGdalLayer(proj, layerName, layerFile)	
	-- local numBands = tl:getNumOfBands(proj, layerName)	
	getNumOfBands = function(_, project, layerName)
		loadProject(project, project.file)
		local layer = project.layers[layerName]
		layer = toDataSetLayer(layer)
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
		local connInfo = dsInfo:getConnInfo()
		local dsType = dsInfo:getType()

		if dsType == "GDAL" then
			local numBands
			do
				local ds = makeAndOpenDataSource(connInfo, dsType)
				local dSetName = layer:getDataSetName()
				local dSet = ds:getDataSet(dSetName)
				local rpos = binding.GetFirstPropertyPos(dSet, binding.RASTER_TYPE)
				local raster = dSet:getRaster(rpos)	
				numBands = raster:getNumberOfBands()
			
				ds:close()
			end

			collectgarbage("collect")
			
			releaseProject(project)
			return numBands
		end		
		
		releaseProject(project)
		
		customError("The layer '"..layerName.."' is not a Raster.")
	end,
	--- Returns the area of this envelope as measured in the spatial reference system of it.
	-- @arg geom The geometry of the project.
	-- @usage -- DONTRUN
	-- local dSet = tl:getDataSet(proj, clName1)
	-- local area = tl:getArea(dSet[0].OGR_GEOMETRY)
	getArea = function(_, geom)
		local geomType = geom:getGeometryType()

		if (geomType == "MultiPolygon") or (geomType == "CurvePolygon") or
			(geomType == "Polygon") then
			local env = geom:getMBR()
			return env:getArea()
		else
			customWarning("Geometry should be a polygon to get the area.")
		end	
		
		return 0
	end,
	--- Returns a coordinate system name given an identification.
	-- @arg layer The layer.
	-- @usage -- DONTRUN
	-- local prj = tl:getLayerProjection(proj.layers[layerName])
	-- print(prj.NAME..". SRID: "..prj.SRID..". PROJ4: "..prj.PROJ4)
	getProjection = function(_, layer)
		local srid = layer:getSRID()
		local proj4 = binding.te.srs.SpatialReferenceSystemManager.getInstance():getP4Txt(srid)
		local name = binding.te.srs.SpatialReferenceSystemManager.getInstance():getName(srid)
		local prj = {}
		prj.SRID = srid
		prj.NAME = name
		prj.PROJ4 = proj4
		return prj
	end,
	--- Returns the property names of the dataset.
	-- @arg layer The project.
	-- @arg layer The layer.
	-- @usage -- DONTRUN	
	-- local propNames = tl:getPropertyNames(proj, proj.layers[layerName])
	-- for i = 0, #propNames do
	--		unitTest:assert((propNames[i] == "FID") or (propNames[i] == "ID") or 
	--						(propNames[i] == "NM_MICRO") or (propNames[i] == "CD_GEOCODU"))
	-- end	
	getPropertyNames = function(_, project, layer)
		loadProject(project, project.file)
		
		local dSetLayer = toDataSetLayer(layer)
		local dSetName = dSetLayer:getDataSetName()
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(dSetLayer:getDataSourceId())
		local names

		do
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			names = ds:getPropertyNames(dSetName)
			ds:close()		
		end
		
		releaseProject(project)
		
		return names
	end,
	--- Returns the shortest distance between any two points in the two geometries.
	-- @arg fromGeom The geometry.
	-- @arg toGeom The other geometry.
	-- @usage -- DONTRUN
	-- local dSet = tl:getDataSet(proj, clName)
	-- local dist = tl:getDistance(dSet[0].OGR_GEOMETRY, dSet[getn(dSet) - 1].OGR_GEOMETRY)	
	getDistance = function(_, fromGeom, toGeom)
		return fromGeom:distance(toGeom)
	end
}

metaTableTerraLib_ = {
	__index = TerraLib_,
}

--- Type to access TerraLib. It contains very basic and low level functions that
-- are used by the other types of the package. If needed, these functions should
-- be used with care. Such functions mught stop with very strange errors because
-- they do not check any errors in their arguments.
-- @usage -- DONTRUN
-- TerraLib()
function TerraLib()
	if instance then
		return instance
	else
		local data = {}
		setmetatable(data, metaTableTerraLib_)
		instance = data
		return data
	end
end

