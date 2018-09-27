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

local function makeWeakTable(table)
	setmetatable(table, {__mode = 'v'})
	return table
end

local binding = _Gtme.terralib_mod_binding_lua
local instance = nil
local dataCache = makeWeakTable{}

local function getCache(level1, level2, level3)
	-- level1 is compulsory. The other ones are optional.

	local dataCacheLevel1 = dataCache[level1] -- SKIP
	if not dataCacheLevel1 then return end -- SKIP

	if not level2 then return dataCacheLevel1 end -- SKIP

	local dataCacheLevel2 = dataCacheLevel1[level2] -- SKIP
	if not dataCacheLevel2 then return end -- SKIP

	if not level3 then return dataCacheLevel2 end -- SKIP

	return dataCacheLevel2[level3] -- SKIP
end

local function addCache(value, level1, level2, level3)
	-- Again: level1 is compulsory. The other ones are optional.

	if not level2 then -- SKIP
		dataCache[level1] = value -- SKIP
		return
	end

	local dataCacheLevel1 = dataCache[level1] -- SKIP
	if not dataCacheLevel1 then -- SKIP
		dataCacheLevel1 = makeWeakTable{} -- SKIP
		dataCache[level1] = dataCacheLevel1 -- SKIP
	end

	if not level3 then -- SKIP
		dataCacheLevel1[level2] = value -- SKIP
		return
	end

	local dataCacheLevel2 = dataCacheLevel1[level2] -- SKIP
	if not dataCacheLevel2 then -- SKIP
		dataCacheLevel2 = makeWeakTable{} -- SKIP
		dataCacheLevel1[level2] = dataCacheLevel2 -- SKIP
	end

	dataCacheLevel2[level3] = value -- SKIP
end

local OperationMapper = {
	value = binding.VALUE_OPERATION,
	area = binding.PERCENT_TOTAL_AREA,
	presence = binding.PRESENCE,
	count = binding.COUNT,
	distance = binding.MIN_DISTANCE_CENTROID,
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
	distance = "dis_cent",
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
	sum = "_Sum",
	count = "_Count"
}

local OperationAvailablePerDataTypeMapper = {
	value = 7,			-- 7 means that operation work with (Integer-Real-String)
	area = 6,			-- 6 means that operation work with (Integer-Real)
	presence = 7,		-- 5 means that operation work with (Integer-String)
	count = 7,
	distance = 7,
	minimum = 7,
	maximum = 7,
	mode = 7,
	coverage = 5,
	stdev = 6,
	average = 6,
	mean = 6,
	weighted = 6,
	intersection = 5,
	occurrence = 7,
	sum = 6,
	wsum = 6
}

local SourceTypeMapper = {
	shp = "OGR",
	geojson = "OGR",
	tif = "GDAL",
	nc = "GDAL",
	asc = "GDAL",
	png = "GDAL",
	jpeg = "GDAL",
	jpg = "GDAL",
	postgis = "POSTGIS",
	wfs = "WFS",
	wms = "WMS2"
}

local function createFileConnInfo(filePath)
	local connInfo = "file://"..filePath
	return connInfo
end

local function getPgErrorMessage(data, errorMsg)
	if string.find(errorMsg, "invalid SRID")then
		return "Layer '"..data.layer.."' has a invalid EPSG. "
					.. "Please, set a valid projection, if it still doesn't work, "
					.. "reproject the layer data."
	elseif string.find(errorMsg, "could not translate host name") then
		return "Host '"..data.host.."' was not found."
	elseif string.find(errorMsg, "connections on port "..data.port) then
		return "Port '"..data.port.."' is not available for host '"..data.host.."'."
	elseif string.find(errorMsg, "password authentication failed for user") then
		return "Connection failed due to invalid username or password."
	elseif string.find(errorMsg, "database \""..data.database.."\" does not exist") then
		return "Database '"..data.database.."' does not exist."
	end

	return errorMsg -- SKIP
end

local function checkPgConnectParams(data, connInfo)
	local msg

	do
		local ds = binding.te.da.DataSourceFactory.make("POSTGIS", connInfo)
		msg = binding.te.da.DataSource.Check(ds)

		ds:close()
	end

	collectgarbage("collect")

	if msg ~= "" then
		customError(getPgErrorMessage(data, msg)) -- SKIP
	end
end

local function createPgDbIfNotExists(data, encoding)
	local connInfo = "pgsql://"..data.user..":"..data.password.."@"
					..data.host..":"..data.port.."/?"
					.."&PG_NEWDB_NAME="..data.database
					.."&PG_NEWDB_OWNER="..data.user
					.."&PG_NEWDB_ENCODING="..encoding
					.."&PG_CONNECT_TIMEOUT=10"
					.."&PG_MAX_POOL_SIZE=4"
					.."&PG_MIN_POOL_SIZE=2"
					.."&PG_CHECK_DB_EXISTENCE="..data.database

	checkPgConnectParams(data, connInfo)

	if not binding.te.da.DataSource.exists("POSTGIS", connInfo) then
		binding.te.da.DataSource.create("POSTGIS", connInfo)
	end
end

local function createPgConnInfo(data, encoding)
	local connInfo = "pgsql://"..data.user..":"..data.password.."@"..data.host
				..":"..data.port.."/"..data.database.."?"
				.."&PG_CLIENT_ENCODING="..encoding
				.."&PG_CONNECT_TIMEOUT=10"
				.."&PG_MAX_POOL_SIZE=4"
				.."&PG_MIN_POOL_SIZE=2"
				.."&PG_HIDE_SPATIAL_METADATA_TABLES=FALSE"
				.."&PG_HIDE_RASTER_TABLES=FALSE"
				.."&PG_CHECK_DB_EXISTENCE="..data.database

	checkPgConnectParams(data, connInfo)

	return connInfo
end

local function createWmsConnInfo(url, user, password, port, query, fragment, directory, format)
	local connInfo = url

	if user and password then
		local uri = binding.te.core.URI(connInfo) -- SKIP
		connInfo = uri:schema().."://"..user..":"..password.."@"..uri:host() -- SKIP
	end

	if port then
		connInfo = connInfo..":"..port -- SKIP
	end

	if query then
		connInfo = connInfo.."?"..query -- SKIP
	end

	if fragment then
		connInfo = connInfo.."#"..fragment -- SKIP
	end

	local encodedUri = binding.URIEncode(connInfo)

	if format then
		encodedUri = encodedUri.."&FORMAT="..format
	end

	return "wms://".."?URI="..encodedUri.."&VERSION=1.3.0".."&USERDATADIR=".. directory
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
	local ds = binding.te.da.DataSourceFactory.make(type, connInfo)
	ds:open()

	return ds
end

-- local function hasShapeFileSpatialIndex(shapeFile) -- TODO(#1678)
	-- if string.find(tostring(shapeFile), "WFS:http://", 1, true) then
		-- return false
	-- end

	-- local qixFile = File(string.gsub(shapeFile, ".shp", ".qix"))
	-- if qixFile:exists() then
		-- return true
	-- end

	-- local sbnFile = File(string.gsub(shapeFile, ".shp", ".sbn"))
	-- if sbnFile:exists() then
		-- return true
	-- end

	-- return false
-- end

local function addSpatialIndex(ds, dSetName)
	ds:execute("CREATE SPATIAL INDEX ON "..dSetName)
end

local function toUtf8(str)
	if sessionInfo().system == "windows" then
		return binding.CharEncoding.toUTF8(str, binding.CharEncoding.getEncodingType("LATIN1"))
	end

	return binding.CharEncoding.toUTF8(str)
end

local function createLayer(name, dSetName, connInfo, type, addSpatialIdx, srid, encoding)
	local layer
	local sridReal = 0

	do
		local dsId = addDataSourceInfo(type, name, connInfo)
		local ds = binding.te.da.DataSourceManager.getInstance():search(dsId)

		if ds then
			ds:open()
		else
			ds = makeAndOpenDataSource(connInfo, type)
			ds:setId(dsId)
			binding.te.da.DataSourceManager.getInstance():insert(ds)
		end

		local env
		local id = binding.GetRandomicId()

		if type == "WMS2" then
			local uri = binding.te.core.URI(connInfo)
			local info = binding.Expand(uri:query())
			info.USERDATADIR = binding.URIDecode(info.USERDATADIR)
			local client = binding.te.ws.ogc.WMSClient(toUtf8(info.USERDATADIR), info.URI, info.VERSION)
			client:updateCapabilities()
			local capblts = client:getCapabilities()
			local rootLayer = capblts.m_capability.m_layer
			local wmsLayer = rootLayer:getLayerByDataSetName(dSetName)

			if wmsLayer.m_title == "" then
				binding.te.da.DataSourceManager.getInstance():detach(dsId)
				ds:close()
				customError("Map '"..dSetName.."' was not found in WMS server.")
			end

			local request = wmsLayer:createMapRequest()

			if info.FORMAT then
				request.m_format = "image/"..info.FORMAT
			end

			local bbox = request.m_boundingBox
			env = binding.te.gm.Envelope(bbox.m_minX, bbox.m_minY, bbox.m_maxX, bbox.m_maxY)
			local srs = binding.SplitString(request.m_srs, ":")
			sridReal = tonumber(srs[1])
			layer = binding.te.ws.ogc.wms.WMSLayer(id, name)
			layer:setGetMapRequest(request)
		else
			local dSetType
			local dSet

			if not ds:dataSetExists(dSetName) then
				binding.te.da.DataSourceManager.getInstance():detach(dsId)
				ds:close()
				customError("It was not possible to find data set '"..dSetName.."' of type '"..type.."'. Layer '"..name.."' was not created.")
			end

			if (type == "OGR") or (type == "WFS") or (type == "POSTGIS") then
				dSetType = ds:getDataSetType(dSetName)
				local gp = binding.GetFirstGeomProperty(dSetType)
				env = binding.te.gm.Envelope(binding.GetExtent(dSetType:getName(), gp:getName(), ds:getId()))
				sridReal = gp:getSRID()

				if addSpatialIdx then -- and not hasShapeFileSpatialIndex(connInfo.URI) then -- TODO: check if is OGR resolve it
					addSpatialIndex(ds, dSetName)
				end
			elseif type == "GDAL"then
				dSet = ds:getDataSet(dSetName)
				local rpos = binding.GetFirstPropertyPos(dSet, binding.RASTER_TYPE)
				local raster = dSet:getRaster(rpos)
				env = raster:getExtent()
				sridReal = raster:getSRID()
			end

			layer = binding.te.map.DataSetLayer(id)
			layer:setRendererType("ABSTRACT_LAYER_RENDERER")
		end

		layer:setDataSetName(dSetName)
		layer:setTitle(name)
		layer:setDataSourceId(ds:getId())
		layer:setExtent(env)
		layer:setVisibility(binding.NOT_VISIBLE)

		if not encoding then
			encoding = "LATIN1"
		end

		layer:setEncoding(binding.CharEncoding.getEncodingType(encoding))

		if srid then
			sridReal = srid
		end

		layer:setSRID(sridReal)

		binding.te.da.DataSourceManager.getInstance():detach(ds:getId())

		ds:close()
	end

	collectgarbage("collect")

	if sridReal == binding.TE_UNKNOWN_SRS then
		customWarning("It was not possible to find the projection of layer '"..name.."'. " -- SKIP(#470)
					.."It should be one of the projections available at www.terrame.org/projections.html")	-- SKIP(#470)
	end

	return layer
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

local function castLayer(layer)
	if layer:getType() == "DATASETLAYER" then
		layer = binding.te.map.DataSetLayer.toDataSetLayer(layer)
	elseif layer:getType() == "OGCWMSLAYER" then
		layer = binding.te.ws.ogc.wms.WMSLayer.toWmsLayer(layer)
	else
		customError("Layer '"..layer:getTitle().."'cannot be converted, its type '"..layer:getType().."'.") -- SKIP
	end

	return layer
end

local function saveProject(project, layers)
	local file = tostring(project.file)
	local _, fileName, ext = project.file:split()

	if ext == "qgs" then
		file = currentDir()..fileName..".tview"
	end

	local layersVector = {}
	local i = 1

	for _, v in pairs(layers) do
		layersVector[i] = castLayer(v)
		i = i + 1
	end

	binding.SaveProject(toUtf8(file), project.author, project.title, layersVector)
end

local function loadProject(project, file)
	if not file:exists() then
		customError("Could not read project file: "..file..".") -- SKIP
	end

	local _, fileName, ext = project.file:split()

	if ext == "qgs" then
		file = currentDir()..fileName..".tview"
	end

	local projMd = binding.LoadProject(toUtf8(tostring(file)))
	project.author = projMd.author
	project.title = projMd.title
	local layers = projMd:getLayers()

	for i = 0, getn(layers) - 1 do
		local layer = layers[i]
		project.layers[layer:getTitle()] = castLayer(layer)
	end
end

local function addFileLayer(project, name, file, type, addSpatialIdx, srid, encoding)
	local connInfo = createFileConnInfo(tostring(file))

	loadProject(project, project.file)

	local dSetName = ""

	if type == "OGR" then
		local _, fn = file:split()
		dSetName = fn
	elseif type == "GDAL" then
		dSetName = file:name()
	elseif type == "GeoJSON" then
		type = "OGR"
		dSetName = "OGRGeoJSON"
	end

	local layer = createLayer(name, dSetName, connInfo, type, addSpatialIdx, srid, encoding)

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

		if ds:dataSetExists(dSetName) then
			ds:dropDataSet(dSetName)
		end

		ds:close()
	end

	collectgarbage("collect")
end

local function createCellSpaceLayer(inputLayer, name, dSetName, resolution, connInfo, type, mask)
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
	local errorMsg

	if mask then
		if inputDsType:hasGeom() then
			errorMsg = cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolution, resolution,
										inputLayer:getExtent(), inputLayer:getSRID(), cLType, inputLayer)
		else
			customWarning("The 'mask' not work to Raster, it was ignored.")
			errorMsg = cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolution, resolution,
													inputLayer:getExtent(), inputLayer:getSRID(), cLType)
		end
	else
		errorMsg = cellSpaceOpts:createCellSpace(cellLayerInfo, cellName, resolution, resolution,
												inputLayer:getExtent(), inputLayer:getSRID(), cLType)
	end

	if errorMsg and errorMsg ~= "" then
		if type == "POSTGIS" then
			customError(getPgErrorMessage({layer = inputLayer:getTitle()}, errorMsg))
		end

		customError(errorMsg) -- SKIP
	end
end

local function fixNameTo10Characters(name, property)
	local dif = string.len(name) - 10
	local prop = string.sub(property, 1, string.len(property) - dif)
	return string.gsub(name, property.."_", prop.."_")
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
			else
				if (dsType == "OGR") and (string.len(select) == 10) then
					if not string.find(currentProp, "_") then
						newName = string.gsub(currentProp, select, property.."_0")
					end
				else
					newName = string.gsub(currentProp, select.."_", property.."_")
				end
			end

			if (string.len(newName) > 10) and (dsType ~= "POSTGIS")
					and (dSetName ~= "OGRGeoJSON") then
				newName = fixNameTo10Characters(newName, property)
			end

			if newName ~= currentProp then
				ds:renameProperty(dSetName, currentProp, newName)
			end

			propsRenamed[newName] = newName

		elseif (dsType == "OGR") and (string.len(select) == 10) then
			local idx = string.find(currentProp, "_")
			if idx then
				local propSub = string.sub(currentProp, 1, idx - 1)
				if string.match(select, propSub) then
					newName = string.gsub(currentProp, "(.*)_", property.."_")

					if (string.len(newName) > 10) and (dsType ~= "POSTGIS") then
						newName = fixNameTo10Characters(newName, property)
					end

					if newName ~= currentProp then
						ds:renameProperty(dSetName, currentProp, newName)
					end

					propsRenamed[newName] = newName
				end
			end

		end
	end

	return propsRenamed
end

-- local function getDataSetTypeByLayer(layer)
	-- local dst

	-- do
		-- local dSetName = layer:getDataSetName()
		-- local connInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
		-- local ds = makeAndOpenDataSource(connInfo:getConnInfo(), connInfo:getType())
		-- dst = ds:getDataSetType(dSetName)

		-- ds:close()
	-- end

	-- collectgarbage("collect")

	-- return dst
-- end

local function getNormalizedName(name)
	if string.len(name) <= 10 then
		return name
	end

	return string.sub(name, 1, 10)
end

local function vectorToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, outDSetName, area)
	local propCreatedName
	local err
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

		local toDSetName = toLayer:getDataSetName()
		local toConnInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(toLayer:getDataSourceId())
		local toDs = makeAndOpenDataSource(toConnInfo:getConnInfo(), toConnInfo:getType())
		local toDst = toDs:getDataSetType(toDSetName)

		v2v:setParams(select, OperationMapper[operation], toDst)

		err = v2v:pRun() -- TODO: OGR RELEASE SHAPE PROBLEM (REVIEW)

		if err == "" then
			propCreatedName = select.."_"..VectorAttributeCreatedMapper[operation]
			propCreatedName = string.lower(propCreatedName)
		end

		toDs:close()
		outDs:close()
	end

	collectgarbage("collect")

	if err ~= "" then
		binding.te.da.DataSourceManager.getInstance():detachAll()
		customError(err)
	end

	return propCreatedName
end

local function rasterToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, outDSetName, nodata, pixel)
	local propCreatedName

	do
		local r2v = binding.te.attributefill.RasterToVector()

		fromLayer = castLayer(fromLayer)
		toLayer = castLayer(toLayer)

		local rDs = binding.GetDs(fromLayer:getDataSourceId(), true)
	    local rDSet = rDs:getDataSet(fromLayer:getDataSetName())
		local rpos = binding.GetFirstPropertyPos(rDSet, binding.RASTER_TYPE)
		local raster = rDSet:getRaster(rpos)

		if nodata then
			local bandObj = raster:getBand(select)
			local bandProperty = bandObj:getProperty()
			bandProperty.m_noDataValue = nodata
		end

		local grid = raster:getGrid()
		grid:setSRID(fromLayer:getSRID())

		r2v:setInput(raster, toLayer)

		if operation == "average" then
			operation = "mean"
		end

		r2v:setParams(select, OperationMapper[operation], pixel, false, true) -- TODO: ITERATOR BY BOX, TEXTURE, READALL PARAMS (REVIEW)

		local outDs = r2v:createAndSetOutput(outDSetName, outType, outConnInfo)

		local err = r2v:pRun()
		if err ~= "" then
			customError(err) -- SKIP
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

local function isDataTypeInteger(propType)
	return	propType == binding.INT16_TYPE or
			propType == binding.INT32_TYPE or
			propType == binding.INT64_TYPE or
			propType == binding.UINT16_TYPE or
			propType == binding.UINT32_TYPE or
			propType == binding.UINT64_TYPE or
			propType == binding.CINT32_TYPE
end

local function isDataTypeReal(propType)
	return	propType == binding.FLOAT_TYPE or
			propType == binding.DOUBLE_TYPE or
			propType == binding.NUMERIC_TYPE or
			propType == binding.CFLOAT_TYPE or
			propType == binding.CDOUBLE_TYPE
end

local function isDataTypeString(propType)
	return	propType == binding.STRING_TYPE or
			propType == binding.CHAR_TYPE or
			propType == binding.UCHAR_TYPE
end

local function isDataTypeNumber(propType)
	return isDataTypeInteger(propType) or isDataTypeReal(propType)
end

local function isDataTypeBoolean(propType)
	return propType == binding.BOOLEAN_TYPE
end

local function createDataSetAdapted(dSet, missing)
	local set
	local missValue = ""
	if missing then
		missValue = tostring(missing)
	end
	if dSet:getPropertyDataType(0) == binding.RASTER_TYPE  then
		set = binding.getRasterAsTable(dSet)
	else
		set = binding.getDataSetAsTable(dSet, missValue)
	end

	if not set then
		local numProps = dSet:getNumProperties()
		while dSet:moveNext() do
			for i = 0, numProps - 1 do
				if dSet:isNull(i) then
					if dSet:getPropertyDataType(i) == binding.GEOMETRY_TYPE then
						return nil, "Data cannot be loaded because it has a missing geometry. Please, fix your data."
					end

					if not missing then
						return nil, "Data has a missing value in attribute '"..dSet:getPropertyName(i).."'. Use argument 'missing' to set its value."
					end
				end
			end
		end
	end

	return set
end

local function getPropertyPosition(dse, propName)
	dse:moveFirst()
	local numProps = dse:getNumProperties()

	for i = 0, numProps - 1 do
		if dse:getPropertyName(i) == propName then
			return i
		end
	end

	return nil
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
			geomType == binding.te.gm.MultiPolygonZType or -- SKIP
			geomType == binding.te.gm.MultiPolygonMType or -- SKIP
			geomType == binding.te.gm.MultiPolygonZMType then -- SKIP
		return "polygon"
	elseif 	geomType == binding.te.gm.GeometryCollectionType or
			geomType == binding.te.gm.GeometryCollectionZType or -- SKIP
			geomType == binding.te.gm.GeometryCollectionMType or -- SKIP
			geomType == binding.te.gm.GeometryCollectionZMType then -- SKIP
		return "collection"
	elseif 	geomType == binding.te.gm.MultiSurfaceType or
			geomType == binding.te.gm.MultiSurfaceZType or -- SKIP
			geomType == binding.te.gm.MultiSurfaceMType or -- SKIP
			geomType == binding.te.gm.MultiSurfaceZMType then -- SKIP
		return "surface"
	elseif 	geomType == binding.te.gm.PolyhedralSurfaceType or
			geomType == binding.te.gm.PolyhedralSurfaceZType or -- SKIP
			geomType == binding.te.gm.PolyhedralSurfaceMType or -- SKIP
			geomType == binding.te.gm.PolyhedralSurfaceZMType then -- SKIP
		return "polyhedral"
	elseif 	geomType == binding.te.gm.TINType or
			geomType == binding.te.gm.TINZType or -- SKIP
			geomType == binding.te.gm.TINMType or -- SKIP
			geomType == binding.te.gm.TINZMType or -- SKIP
			geomType == binding.te.gm.TriangleType or -- SKIP
			geomType == binding.te.gm.TriangleZType or -- SKIP
			geomType == binding.te.gm.TriangleMType or -- SKIP
			geomType == binding.te.gm.TriangleZMType then -- SKIP
		return "triangle"
	end

	return "unknown"
end

local function removeDataSource(project, dsId)
	local count = 0
	for _, v in pairs(project.layers) do
		if v:getDataSourceId() == dsId then -- SKIP(#470)
			count = count + 1 -- SKIP -- TODO(avancinirodrigo): TerraLib is mapping one by one datasource after update to release-5.2, review.
		end
	end

	if count == 1 then
		binding.te.da.DataSourceInfoManager.getInstance():remove(dsId) -- SKIP -- TODO(avancinirodrigo): TerraLib is mapping one by one datasource after update to release-5.2, review.
	end
end

local function fixSpaceInPath(path)
	return string.gsub(path, "%%20", " ")
end

local function getFileByUri(uri)
	local path = binding.URIDecode(uri:path())
	return File(fixSpaceInPath(uri:host()..path))
end

local function removeLayer(project, layerName)
	do
		loadProject(project, project.file)
		local layer = project.layers[layerName]
		if not layer then
			customError("Layer '"..layerName.."' not found.")
		end

		local id = layer:getDataSourceId()
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(id)
		local dsetName = layer:getDataSetName()
		local connInfo = dsInfo:getConnInfo()
		local dsType = dsInfo:getType()

		if (dsType == "OGR") or (dsType == "GDAL") then
			local file = getFileByUri(connInfo)
			connInfo = createFileConnInfo(tostring(file))
			connInfo = toUtf8(connInfo)
		end

		local ds = makeAndOpenDataSource(connInfo, dsType)

		ds:dropDataSet(dsetName)
		removeDataSource(project, id)
		project.layers[layerName] = nil
		project[layerName] = nil

		saveProject(project, project.layers)
		releaseProject(project)

		ds:close()
	end

	collectgarbage("collect")
end

local function overwriteLayer(project, fromName, toName, toSetName, default)
	local fromDset = instance.getDataSet{project = project, layer = fromName, missing = default}

	local luaTable = {}
	for i = 0, #fromDset do
		table.insert(luaTable, fromDset[i])
	end

	instance.saveDataSet(project, fromName, luaTable, toName, {}, toSetName)
end

local function castGeometry(geom)
	local geomType = binding.te.gm.Geometry.getGeomTypeId(string.upper(geom:getGeometryType()))

	if 	geomType == binding.te.gm.GeometryType then
		return geom
	elseif geomType == binding.te.gm.PointType then
		return binding.te.gm.Geometry.toPoint(geom)
	elseif geomType == binding.te.gm.MultiPointType then
		return binding.te.gm.Geometry.toMultiPoint(geom)
	elseif geomType == binding.te.gm.LineStringType then
		return binding.te.gm.Geometry.toLineString(geom)
	elseif geomType == binding.te.gm.MultiLineStringType then
		return binding.te.gm.Geometry.toMultiLineString(geom)
	elseif geomType == binding.te.gm.CircularStringType then
		return binding.te.gm.Geometry.toCircularString(geom)
	elseif geomType == binding.te.gm.CompoundCurveType then
		return binding.te.gm.Geometry.toCompoundCurve(geom)
	elseif geomType == binding.te.gm.PolygonType then
		return binding.te.gm.Geometry.toPolygon(geom)
	elseif geomType == binding.te.gm.CurvePolygonType then
		return binding.te.gm.Geometry.toCurvePolygon(geom)
	elseif geomType == binding.te.gm.MultiPolygonType then
		return binding.te.gm.Geometry.toMultiPolygon(geom)
	elseif geomType == binding.te.gm.GeometryCollectionType then
		return binding.te.gm.Geometry.toGeometryCollection(geom)
	elseif geomType == binding.te.gm.MultiSurfaceType then
		return binding.te.gm.Geometry.toMultiSurface(geom)
	elseif geomType == binding.te.gm.PolyhedralSurfaceType then
		return binding.te.gm.Geometry.toPolyhedralSurface(geom)
	elseif geomType == binding.te.gm.TINType then
		return binding.te.gm.Geometry.toTIN(geom)
	elseif geomType == binding.te.gm.TriangleType then
		return binding.te.gm.Geometry.toTriangle(geom)
	end

	customError("Unknown geometry type '"..geomType.."'.") -- SKIP
end

local function getRasterFromLayer(project, layer)
	loadProject(project, project.file)

	layer = castLayer(layer)
	local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
	local connInfo = dsInfo:getConnInfo()
	local dsType = dsInfo:getType()
	local raster = nil

	if dsType == "GDAL" then
		do
			local ds = makeAndOpenDataSource(connInfo, dsType)
			local dSetName = layer:getDataSetName()
			local dSet = ds:getDataSet(dSetName)
			local rpos = binding.GetFirstPropertyPos(dSet, binding.RASTER_TYPE)
			raster = dSet:getRaster(rpos)

			ds:close()
		end

		collectgarbage("collect")
	end

	releaseProject(project)

	return raster
end

local function isValidDataSourceUri(uri, type)
	local ds = binding.te.da.DataSourceFactory.make(type, uri)
	return ds:isValid()
end

local function toWfsUrl(url)
	local wfsPrefix = "WFS:"
	if string.find(url, "^"..wfsPrefix) then
		return url
	end

	return wfsPrefix..url
end

local function getLayerByDataSetName(layers, dsetName, type)
	for _, l in pairs(layers) do
		if l:getDataSetName() == dsetName then
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(l:getDataSourceId())
			if dsInfo:getType() == type then
				return l
			end
		end
	end

	return nil
end

local function swapFileConnInfo(connInfo, fileName)
	local file = getFileByUri(connInfo)
	local outFile = file:path()..fileName.."."..file:extension()
	return createFileConnInfo(outFile)
end

local function createConnInfoToSave(connInfo, toSetName, toType)
	local toConnInfo

	if toType == "POSTGIS" then
		toConnInfo = connInfo
	elseif toType == "OGR" then
		toConnInfo = swapFileConnInfo(connInfo, toSetName)
	end

	return toConnInfo
end

local function isGeometryProperty(propName)
	return (propName == "OGR_GEOMETRY") or
		   (propName == "ogr_geometry") or
		   (propName == "geom")
end

local function createInvalidNamesErrorMsg(invalidNames)
	local errorMsg

	if #invalidNames == 1 then
		errorMsg = "Invalid attribute name '"..invalidNames[1].."'."
	else
		local ins = ""
		for i = 1, #invalidNames do
			ins = ins.."'"..invalidNames[i].."'"
			if (i ~= #invalidNames - 1) and not (i == #invalidNames) then
				ins = ins..", "
			elseif i == #invalidNames - 1 then
				ins = ins.." and "
			end
		end

		errorMsg = "Invalid attribute names "..ins.."."
	end

	return errorMsg
end

local function createAttributesInfo(dataset, attrNames)
	local attrInfos = {}

	if attrNames then
		for i = 1, #attrNames do
			attrInfos[i] = {name = attrNames[i], pos = nil, type = nil}
		end
	end

	local numProps = dataset:getNumProperties()
	for i = 0, numProps - 1 do
		local pn = dataset:getPropertyName(i)
		for j = 1, #attrInfos do
			if pn == attrInfos[j].name then
				attrInfos[j].pos = i
				attrInfos[j].type = dataset:getPropertyDataType(i)
			end
		end
	end

	return attrInfos
end

local function updateAttributeNumberByType(dataset, type, pos, value)
	if type == binding.DOUBLE_TYPE then
		dataset:setDouble(pos, value)
	elseif type == binding.INT64_TYPE then
		dataset:setInt64(pos, value)
	elseif type == binding.INT32_TYPE then
		dataset:setInt32(pos, value) -- SKIP TODO(avancinirodrigo): there is no that type to test
	elseif type == binding.INT16_TYPE then
		dataset:setInt16(pos, value)  -- SKIP
	else
		dataset:setDouble(pos, value) -- SKIP
	end
end

local function fillDataSetWithUpdatedData(dseToUp, dseType, newDataSet, attrsToUp)
	local index = 1
	dseToUp:moveBeforeFirst()
	while dseToUp:moveNext() do
		for i = 1, #attrsToUp do
			local attr = attrsToUp[i].name
			local v = newDataSet[index][attr]
			local t = type(v)

			if (t == "number") and isDataTypeNumber(attrsToUp[i].type) then
				updateAttributeNumberByType(dseToUp, attrsToUp[i].type, attrsToUp[i].pos, v)
			elseif (t == "string") and isDataTypeString(attrsToUp[i].type) then
				dseToUp:setString(attr, v)
			elseif (t == "boolean") and (dseType == "OGR") then
					dseToUp:setString(attr, tostring(v))
			elseif (t == "boolean") and isDataTypeBoolean(attrsToUp[i].type) then
					dseToUp:setBool(attr, v)
			elseif isGeometryProperty(attr) then
					dseToUp:setGeometry(attr, v)
			else
				return "Attempt to set '"..attr.."' with type '"..t.."'. Please, set the correct type."
			end
		end

		index = index + 1
	end
end

local function createDataSetFromLayer(fromLayer, toSetName, toSet, attrs)
	local errorMsg
	do
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
		local connInfo = dsInfo:getConnInfo()
		local fromType = dsInfo:getType()
		local ds = makeAndOpenDataSource(connInfo, fromType)
		local dsetName = fromLayer:getDataSetName()
		local dse = ds:getDataSet(dsetName)

		-- Check new attributes
		local attrsToIn = {}
		local attrsToUp = {}
		local invalidNames = {}
		if attrs then
			for i = 1, #attrs do
				local propName = attrs[i]

				if not ds:isPropertyNameValid(propName) then
					table.insert(invalidNames, propName)
				elseif ds:propertyExists(dsetName, propName) or isGeometryProperty(propName) then
					table.insert(attrsToUp, propName)
				else
					table.insert(attrsToIn, propName)
				end
			end
		end

		if #invalidNames > 0 then
			errorMsg = createInvalidNamesErrorMsg(invalidNames)
		else
			-- Copy from dataset to new
			local dst = ds:getDataSetType(dsetName)
			local newDst = ds:cloneDataSetType(dsetName)
			newDst:setName(toSetName)
			local newDse = binding.te.mem.DataSet(dse)

			-- TODO(avancinirodrigo): why POSTGIS does not work like OGR?
			-- Fix the primary key for postgis only
			if fromType == "POSTGIS" then
				local pk = newDst:getPrimaryKey()
				local rand = string.gsub(binding.GetRandomicId(), "-", "")
				rand = string.sub(rand, 1, 8)

				if pk then
					newDst:removeIndex(pk:getName())
					local newPk = binding.te.da.PrimaryKey(newDst)
					newPk:setName("pk"..rand)
					pk = dst:getPrimaryKey()
					local pkPos = getPropertyPosition(dse, pk:getPropertyName(0))
					newPk:add(pk:getProperty(pkPos))

					--local pkIdx = pk:getAssociatedIndex() -- TODO(#1678)
					-- if pkIdx then
						-- pkIdx:setName("idx"..rand)
						--newDst:remove(pkIdx)
						-- pk:setAssociatedIndex(pkIdx)
					-- end
				end
			end

			if #attrs > 0 then
				-- Add the new attributes to new dataset
				local isPk = false
				for i = 1, #attrsToIn do
					local attr = attrsToIn[i]
					local v = toSet[1][attr]

					if type(v) == "number" then
						newDst:add(attr, isPk, binding.DOUBLE_TYPE, false)
						newDse:add(attr, binding.DOUBLE_TYPE)
					elseif type(v) == "string" then
						newDst:add(attr, isPk, binding.STRING_TYPE, false)
						newDse:add(attr, binding.STRING_TYPE)
					elseif type(v) == "boolean" then
						if fromType == "OGR" then
							newDst:add(attr, isPk, binding.STRING_TYPE, false)
							newDse:add(attr, binding.STRING_TYPE)
						else
							newDst:add(attr, isPk, binding.BOOLEAN_TYPE, false)
							newDse:add(attr, binding.BOOLEAN_TYPE)
						end
					end
				end

				-- Set the values of the new dataset from the data
				local index = 1
				newDse:moveBeforeFirst()
				while newDse:moveNext() do
					for i = 1, #attrsToIn do
						local attr = attrsToIn[i]
						local v = toSet[index][attr]

						if type(v) == "number" then
							newDse:setDouble(attr, v)
						elseif type(v) == "string" then
							newDse:setString(attr, v)
						elseif type(v) == "boolean" then
							if fromType == "OGR" then
								newDse:setString(attr, tostring(v))
							else
								newDse:setBool(attr, v)
							end
						end
					end

					index = index + 1
				end

				if #attrsToUp > 0 then
					attrsToUp = createAttributesInfo(dse, attrsToUp)
					errorMsg = fillDataSetWithUpdatedData(newDse, fromType, toSet, attrsToUp)
				end
			end

			if not errorMsg then
				local toConnInfo = createConnInfoToSave(connInfo, toSetName, fromType)
				if type(toConnInfo) == "string" then
					toConnInfo = toUtf8(toConnInfo)
				end
				local toDs = makeAndOpenDataSource(toConnInfo, fromType)

				-- Drop if exists
				if toDs:dataSetExists(toSetName) then
					toDs:dropDataSet(toSetName)
				end

				-- Create new dataset in database
				toDs:createDataSet(newDst)
				newDse:moveBeforeFirst()
				toDs:add(toSetName, newDse)
			end
		end
	end

	collectgarbage("collect")

	if errorMsg then
		customError(errorMsg)
	end
end

local function updateDataSet(fromLayer, toSet, attrs)
	local errorMsg
	do
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
		local connInfo = dsInfo:getConnInfoAsString()
		connInfo = binding.URIDecode(connInfo)
		local fromType = dsInfo:getType()
		local ds = makeAndOpenDataSource(toUtf8(connInfo), fromType)
		local dsetName = fromLayer:getDataSetName()
		local dse = ds:getDataSet(dsetName)

		local attrsToUp = createAttributesInfo(dse, attrs)
		local dseUp = binding.te.mem.DataSet(dse)
		errorMsg = fillDataSetWithUpdatedData(dseUp, fromType, toSet, attrsToUp)

		if not errorMsg then
			local attrsNameToUpVector = {}
			for i = 1, #attrsToUp do
				attrsNameToUpVector[i] = attrsToUp[i].name
			end

			binding.UpdateDs(ds, dsetName, dseUp, attrsNameToUpVector)
		end
	end

	collectgarbage("collect")

	if errorMsg then
		customError(errorMsg)
	end
end

local function hasNewAttributeOnLayer(fromLayer, attrs)
	local result = false

	do
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
		local connInfo = dsInfo:getConnInfo()
		local fromType = dsInfo:getType()
		local ds = makeAndOpenDataSource(connInfo, fromType)
		local dseName = fromLayer:getDataSetName()

		for i = 1, #attrs do
			if not ds:propertyExists(dseName, attrs[i]) then
				result = true
			end
		end
	end

	collectgarbage("collect")

	return result
end

local function getPropertyDataType(connInfo, dstype, dsetName, propName)
	local propType

	do
		local ds = makeAndOpenDataSource(connInfo, dstype)
		local dse = ds:getDataSet(dsetName)
		local numProps = dse:getNumProperties()

		dse:moveFirst()

		for i = 0, numProps - 1 do
			local pn = dse:getPropertyName(i)
			if (pn == propName) or (pn == "raster") then
				propType = dse:getPropertyDataType(i)
			end
		end
	end

	collectgarbage("collect")

	return propType
end

local function isOperationAvailableToPropertyDataType(operation, propType)
	if not propType then
		return false
	elseif propType == binding.RASTER_TYPE then
		return true
	else
		local opa = OperationAvailablePerDataTypeMapper[operation]

		if isDataTypeInteger(propType) or (opa == 7) then
			return true
		elseif isDataTypeReal(propType) and (opa == 6) then
			return true
		elseif isDataTypeString(propType) and (opa == 5) then
			return true
		end
	end

	return false
end

local function createFromDataInfoToSaveAsByLayer(layer)
	local info = {}
	local fromDsId = layer:getDataSourceId()
	local fromDsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromDsId)
	info.datasource = binding.GetDs(fromDsId, true)
	info.datasource:setEncoding(layer:getEncoding())
	layer = castLayer(layer)
	info.dataset = layer:getDataSetName()
	info.type = fromDsInfo:getType()
	info.name = layer:getTitle()
	info.srid = layer:getSRID()

	return info
end

local function getRasterByDataSet(dataset)
	local rpos = binding.GetFirstPropertyPos(dataset, binding.RASTER_TYPE)
	return dataset:getRaster(rpos)
end

local function createFromDataInfoToSaveAsByFile(file)
	local info = {}
	local connInfo = createFileConnInfo(tostring(file))
	local fileExt = file:extension()
	info.type = SourceTypeMapper[fileExt]

	if fileExt == "shp" then
		local _, fileName = file:split()
		info.dataset = fileName
	elseif fileExt == "geojson" then
		info.dataset = "OGRGeoJSON"
	else
		info.dataset = file:name()
	end

	info.datasource = makeAndOpenDataSource(connInfo, info.type)

	if info.type == "OGR" then
		local dst = info.datasource:getDataSetType(info.dataset)
		local gp = binding.GetFirstGeomProperty(dst)
		info.srid = gp:getSRID()
		info.name = info.dataset.."."..fileExt
	else
		info.name = info.dataset
		local dset = info.datasource:getDataSet(info.dataset)
		local raster = getRasterByDataSet(dset)
		info.srid = raster:getSRID()
	end

	collectgarbage("collect")

	return info
end

local function createToDataInfoToSaveAs(toData, fromData, overwrite)
	local info = {}
	local toDs
	local toDSetName
	local fromDSetName = fromData.dataset
	local fromType = fromData.type
	local errorMsg

	local toType
	if toData.type then
		toType = SourceTypeMapper[toData.type]
	else --< must be file
		local fileExt = toData.file:extension()
		toType = SourceTypeMapper[fileExt]
	end

	if fromType == "GDAL" then
		if toType == "GDAL" then
			toDSetName = toData.file:name()

			if toData.file:exists() then
				if overwrite then
					toData.file:delete() -- TODO(avancinirodrigo): it can be optimized by dropDataSet(), but now it doesn't work.
				else
					errorMsg = "File '"..toData.file:name().."' already exists."
				end
			end

			if not errorMsg then
				local connInfo = createFileConnInfo(tostring(toData.file))
				toDs = makeAndOpenDataSource(connInfo, "GDAL")
				info.file = toData.file
			end
		else
			errorMsg = "Raster data '"..fromData.name.."' cannot be saved as vector."
		end
	else --< vectorial data
		if toType == "GDAL" then
			errorMsg = "Vector data '"..fromData.name.."' cannot be saved as raster."
		elseif toType == "POSTGIS" then
			if not toData.table then
				toData.table = fromDSetName
			end

			toData.table = string.lower(toData.table)
			toDSetName = toData.table
			createPgDbIfNotExists(toData, toData.encoding)
			local connInfo = createPgConnInfo(toData, toData.encoding)
			toDs = makeAndOpenDataSource(connInfo, "POSTGIS")

			if toDs:dataSetExists(toDSetName) then
				if overwrite then
					toDs:dropDataSet(toDSetName)
				else
					errorMsg = "Table '"..toData.table.."' already exists in postgis database '"..toData.database.."'."
				end
			end
		elseif toType == "OGR" then
			local _, fn = toData.file:split()
			toDSetName = fn

			if toData.file:exists() then
				if overwrite then
					toData.file:delete()
				else
					errorMsg = "File '"..toData.file:name().."' already exists."
				end
			end

			if not errorMsg then
				local connInfo = createFileConnInfo(tostring(toData.file))
				toDs = makeAndOpenDataSource(connInfo, "OGR")
			end
		end
	end

	if errorMsg then
		if toDs then
			toDs:close()
		end

		fromData.datasource:close()
		customError(errorMsg)
	end

	info.dataset = toDSetName
	info.datasource = toDs
	info.type = toType

	if toData.encoding then
		toDs:setEncoding(binding.CharEncoding.getEncodingType(toData.encoding))
	else
		toDs:setEncoding(fromData.datasource:getEncoding())
	end

	if toData.srid then
			info.srid = toData.srid
	else
		info.srid = fromData.srid
	end

	return info
end

local function hasValuesSamePrimaryKey(values, pkName)
	return values[1][pkName] ~= nil
end

local function saveVectorDataAs(fromData, toData, attrs, values)
	do
		local fromDs = fromData.datasource

		local attrsToIn = {}
		local attrsNoExist = {}
		local errorMsg

		if attrs then
			for i = 1, #attrs do
				local propName = attrs[i]
				if fromDs:propertyExists(fromData.dataset, propName) then
					attrsToIn[propName] = true
				else
					table.insert(attrsNoExist, propName)
				end
			end
		end

		if #attrsNoExist > 0 then
			if #attrsNoExist == 1 then
				errorMsg = "There is no attribute '"..attrsNoExist[1].."' in '"..fromData.name.."'."
			else
				local ins = ""
				for i = 1, #attrsNoExist do
					ins = ins.."'"..attrsNoExist[i].."'"
					if (i ~= #attrsNoExist - 1) and not (i == #attrsNoExist) then
						ins = ins..", "
					elseif i == #attrsNoExist - 1 then
						ins = ins.." and "
					end
				end

				errorMsg = "There are no attributes "..ins.." in '"..fromData.name.."'."
			end
		end

		local toDs = toData.datasource
		local toDSetName = toData.dataset

		if errorMsg then
			if toDs then
				toDs:close()
			end

			fromDs:close()
			customError(errorMsg)
		end

		local fromDSetType = fromDs:getDataSetType(fromData.dataset)
		local fromDSet = fromDs:getDataSet(fromData.dataset)
		local converter = binding.te.da.DataSetTypeConverter(fromDSetType, fromDs:getCapabilities(), toDs:getEncoding())

		local pkName = ""
		local pk = fromDSetType:getPrimaryKey()
		if pk then
			if fromData.type == "POSTGIS" then
				pkName = pk:getPropertyName(0)
			else
				pkName = pk:getName()
			end
		end

		-- If there are attrs, keep only them, primary key and geometries
		local attrsFilter = {}
		if attrs then
			local numProps = fromDSet:getNumProperties()
			fromDSet:moveFirst()
			for i = 0, numProps - 1 do
				local propName = fromDSet:getPropertyName(i)
				if not (pkName == propName) and not attrsToIn[propName] and
					not (fromDSet:getPropertyDataType(i) == binding.GEOMETRY_TYPE) then
					converter:remove(propName)
				else
					table.insert(attrsFilter, propName)
				end
			end
		elseif values then -- if there is a subset without attrs, it will save all properties from the subset
			local numProps = fromDSet:getNumProperties()
			fromDSet:moveFirst()
			for i = 0, numProps - 1 do
				local propName = fromDSet:getPropertyName(i)
				table.insert(attrsFilter, propName)
			end
		end

		binding.AssociateDataSetTypeConverterSRID(converter, toData.srid)
		local dstResult = converter:getResult()
		dstResult:setName(toDSetName)

		-- TODO(avancinirodrigo): why POSTGIS does not work like OGR?
		-- Fix the primary key for postgis only
		if toData.type == "POSTGIS" then
			local pkToFix = dstResult:getPrimaryKey()
			if pkToFix then
				local rand = string.gsub(binding.GetRandomicId(), "-", "")
				rand = string.sub(rand, 1, 8)
				pkToFix:setName("pk"..rand)

				-- local pkIdx = pkToFix:getAssociatedIndex() TODO(#1678)
				-- if pkIdx then
					-- pkIdx:setName("idx"..rand)
				-- else
					-- local gp = binding.GetFirstGeomProperty(dstResult)
					-- if gp then
						-- local idx = binding.te.da.Index(dstResult)
						-- idx:setName("idx"..rand)
						-- idx:setIndexType(binding.R_TREE_TYPE)
						-- idx:add(gp:clone())
						-- pkToFix:setAssociatedIndex(idx)
					-- end
				-- end
			end
		end

		local dsetAdapted

		-- It can create a new data with only some values
		if values then
			if not hasValuesSamePrimaryKey(values, pkName) then
				if toDs then
					toDs:close()
				end
				fromDs:close()
				customError("Primary key not found ("..fromData.name..", "..pkName.."). Please, check your subset.")
			end

			local newDst = converter:getConvertee()
			local newDse = binding.te.mem.DataSet(newDst)
			attrsToIn = createAttributesInfo(fromDSet, attrsFilter)
			local pkPos = getPropertyPosition(fromDSet, pkName)

			fromDSet:moveBeforeFirst()
			for i = 1, #values do
				local next = true
				while next do
					if fromDSet:moveNext() then
						if fromDSet:getInt(pkPos) == values[i][pkName] then
							local item = binding.te.mem.DataSetItem.create(newDse)
							for j = 1, #attrsToIn do
								item:setValue(attrsToIn[j].pos, fromDSet:getValue(attrsToIn[j].pos):clone())
							end
							newDse:add(item)
							next = false
						end
					else
						next = false -- SKIP
					end
				end
			end

			dsetAdapted = binding.CreateAdapter(newDse, converter)
		else
			dsetAdapted = binding.CreateAdapter(fromDSet, converter)
		end

		local transactor = toDs:getTransactor()
		transactor:begin()
		transactor:createDataSet(dstResult, {})
		local toDstName = dstResult:getName()
		dsetAdapted:moveBeforeFirst()
		transactor:add(toDstName, dsetAdapted)
		transactor:commit()

		if toData.type == "OGR" then -- TODO(#1678)
			addSpatialIndex(toDs, toDstName)
		end
	end

	collectgarbage("collect")

	return true
end

local function saveRasterDataAs(fromData, toData)
	do
		local fromDSet = fromData.datasource:getDataSet(fromData.dataset)
		local raster = getRasterByDataSet(fromDSet)
		binding.SaveRasterOnFile(raster, tostring(toData.file), toData.srid)
	end

	collectgarbage("collect")
end

-- debug function
-- local function showUri(uri)
	-- _Gtme.print("uri()", uri:uri())
	-- _Gtme.print("scheme()", uri:scheme())
	-- _Gtme.print("user()", uri:user())
	-- _Gtme.print("password()", uri:password())
	-- _Gtme.print("host()", uri:host())
	-- _Gtme.print("port()", uri:port())
	-- _Gtme.print("path()", uri:path())
	-- _Gtme.print("query()", uri:query())
	-- _Gtme.print("fragment()", uri:fragment())
-- end

local function splitString(str, delimiter)
	local tokens = {}
	for token in string.gmatch(str, "([^"..delimiter.."]+)") do
		table.insert(tokens, token)
	end
	return tokens
end

local function createProjectFromQgis(project)
	local qgisProjInfo = binding.QgisProject.load(tostring(project.file))
	local layers = qgisProjInfo:getLayers()

	project.title = qgisProjInfo:getTitle()

	if project.title == "" then
		project.title = "QGis Project"
	end

	project.author = project.title
	project.layers = {}

	saveProject(project, project.layers)

	for i = 0, getn(layers) - 1 do
		local qgisLayer = layers[i]
		local uri = qgisLayer:getUri()

		if uri:scheme() == "file" then
			local file = File(fixSpaceInPath(uri:host()..uri:path()))
			local ext = file:extension()
			if ext == "shp" then
				instance.addShpLayer(project, qgisLayer:getName(), file, true, qgisLayer:getSrid())
			elseif ext == "tif" then
				instance.addGdalLayer(project, qgisLayer:getName(), file, qgisLayer:getSrid())
			elseif ext == "geojson" then
				instance.addGeoJSONLayer(project, qgisLayer:getName(), file, qgisLayer:getSrid())
			elseif (ext == "nc") and (_Gtme.sessionInfo().system == "windows") then -- TODO(#1302)
				instance.addGdalLayer(project, qgisLayer:getName(), file, qgisLayer:getSrid()) -- SKIP
			elseif ext == "asc" then
				instance.addGdalLayer(project, qgisLayer:getName(), file, qgisLayer:getSrid())
			else -- TODO(#avancinirodrigo): there is no data to test this else in windows
				customWarning("Layer QGis ignored '"..qgisLayer:getName().."'. Type '"..ext.."' is not supported.") -- SKIP
			end
		elseif uri:scheme() == "pgsql" then
			local conn = {
				host = uri:host(),
				port = uri:port(),
				user = uri:user(),
				password = uri:password(),
				database = string.gsub(uri:path(), "/", ""),
				table = uri:query(),
				encoding = "LATIN1"
			}

			instance.addPgLayer(project,  qgisLayer:getName(), conn, qgisLayer:getSrid(), conn.encoding)
		elseif uri:scheme() == "wfs" then
			instance.addWfsLayer(project, qgisLayer:getName(), uri:path(), uri:query(), qgisLayer:getSrid())
		elseif uri:scheme() == "wms" then
			local values = splitString(uri:query(), "&")
			local format = splitString(values[1], "=")[2]
			local layer = splitString(values[2], "=")[2]

			local conn = {
				url = uri:path(),
				format = format,
				directory = currentDir()
			}

			instance.addWmsLayer(project, qgisLayer:getName(), conn, layer, qgisLayer:getSrid())
		else -- TODO(avancinirodrigo): there is no data to test this else
			customWarning("Layer QGis ignored '"..qgisLayer:getName().."'. Unsupported type.") -- SKIP
		end
	end
end

local function getLayerDataSourceInfo(project, layer)
	loadProject(project, project.file)
	local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
	releaseProject(project)
	return dsInfo
end

-- local function getDataSetFromLayer(project, layerName)
	-- local dset
	-- do
		-- loadProject(project, project.file)
		-- local layer = project.layers[layerName]
		-- layer = castLayer(layer)
		-- local dseName = layer:getDataSetName()
		-- local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
		-- local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
		-- dset = ds:getDataSet(dseName)
		-- releaseProject(project)
	-- end

	-- return dset
-- end

local function getDataSetFromFile(file)
	local dset
	do
		local fileExt = string.lower(file:extension())
		local dsType = SourceTypeMapper[fileExt]
		local connInfo = createFileConnInfo(tostring(file))
		local ds = makeAndOpenDataSource(connInfo, dsType)
		local dSetName

		if dsType == "OGR" then
			if fileExt == "geojson" then
				dSetName = "OGRGeoJSON"
			else
				local _, name = file:split()
				dSetName = name
			end
		else --< GDAL
			dSetName = file:name(true)
		end

		dset = ds:getDataSet(dSetName)

		ds:close()
	end

	collectgarbage("collect")

	return dset
end

local function getRasterSize(raster)
	return raster:getNumberOfRows() * raster:getNumberOfColumns()
end

TerraLib_ = {
	type_ = "TerraLib",

	--- Return the current TerraLib version.
	-- @usage import("gis")
	-- print(TerraLib().getVersion())
	getVersion = function()
		return binding.te.common.Version.asString()
	end,
	--- Create a new Project.
	-- @arg project The name of the project.
	-- @arg layers A table where the layers will be stored.
	-- @usage -- DONTRUN
	-- import("gis")
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	createProject = function(project, layers)
		if type(project.file) == "string" then
			project.file = File(project.file)
		end

		if not ((project.file:extension() == "tview") or (project.file:extension() == "qgs")) then
			customError("Please, the file extension must be '.tview' or '.qgs'.")
		end

		if project.file:extension() == "qgs" then
			createProjectFromQgis(project)
		else
			if not project.layers then
				project.layers = layers
			end

			saveProject(project, layers)
		end
	end,
	--- Open a new project.
	-- @arg project The name of the project.
	-- @arg filePath The path for the project.
	-- @usage -- DONTRUN
	-- import("gis")
	-- proj = {}
	-- TerraLib().openProject(proj2, "myproject.tview")
	openProject = function(project, filePath)
		if type(filePath) == "string" then
			filePath = File(filePath)
		end

		if not ((filePath:extension() == "tview") or  (filePath:extension() == "qgs")) then
			customError("Please, the file extension must be '.tview' or '.qgs'.")
		end

		if not project.file then
			project.file = filePath
		end

		loadProject(project, filePath)
	end,
	--- Return the information of a given layer.
	-- @arg project The name of the project.
	-- @arg layerName The name of a layer.
	-- @usage -- DONTRUN
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
	--
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells"
	-- }
	--
	-- TerraLib().addPgLayer(proj, "SampaPg", pgData)
	--
	-- layerInfo = TerraLib().getLayerInfo(proj, "SampaPg")
	getLayerInfo = function(project, layerName)
		local layer = project.layers[layerName]

		if not layer then
			customError("Layer '"..layerName.."' doesn't exist.")
		end

		local info = {}
		info.name = layer:getTitle()
		info.srid = layer:getSRID()
		info.encoding = binding.CharEncoding.getEncodingName(layer:getEncoding())
		local dseName = layer:getDataSetName()

		loadProject(project, project.file)
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())

		local type = dsInfo:getType()
		info.type = type
		local connInfo = dsInfo:getConnInfo()

		if type == "POSTGIS" then
			info.host = connInfo:host()
			info.port = connInfo:port()
			info.user = connInfo:user()
			info.password = connInfo:password()
			info.database = string.gsub(connInfo:path(), "/", "")
			info.table = dseName
			info.source = "postgis"
		elseif (type == "OGR") or (type == "GDAL") then
			local file = getFileByUri(connInfo)
			info.file = tostring(file)
			info.source = file:extension()
		elseif type == "WFS" then
			info.url = connInfo:path()
			info.source = "wfs"
			info.dataset = dseName
		elseif type == "WMS2" then
			local infos = binding.Expand(connInfo:query())
			info.url = infos.URI
			info.source = "wms"
			info.dataset = dseName
			info.rep = "raster"
			collectgarbage("collect")
			releaseProject(project)
			return info
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
				info.rep = "unknown" -- SKIP
			end

			ds:close()
		end

		collectgarbage("collect")
		releaseProject(project)

		return info
	end,
	--- Add a shapefile layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg file The file to the layer.
	-- @arg addSpatialIdx A boolean value indicating whether a spatial index file should be created.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @arg encoding A string value used to set the character encoding.
	-- @usage -- DONTRUN
	-- tl = TerraLib()
	-- proj = TerraLib().createProject("project.tview", {})
	-- TerraLib().addShpLayer(proj, "ShapeLayer", filePath("sampa.shp", "gis"))
	addShpLayer = function(project, name, file, addSpatialIdx, srid, encoding)
		addFileLayer(project, name, file, "OGR", addSpatialIdx, srid, encoding)
	end,
	--- Add a new GDAL layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg file The file to the layer.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @usage -- DONTRUN
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- layerName = "TifLayer"
	-- layerFile = filePath("cbers_rgb342_crop1.tif", "gis")
	-- TerraLib().addGdalLayer(proj, layerName, layerFile)
	addGdalLayer = function(project, name, file, srid)
		addFileLayer(project, name, file, "GDAL", nil, srid)
	end,
	--- Add a GeoJSON layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg file The file to the layer.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @arg encoding A string value used to set the character encoding.
	-- @usage -- DONTRUN
	-- tl = TerraLib()
	-- TerraLib().createProject("project.tview", {})
	-- TerraLib().addGeoJSONLayer(proj, "GeoJSONLayer", filePath("Setores_Censitarios_2000_pol.geojson", "gis"))
	addGeoJSONLayer = function(project, name, file, srid, encoding)
		addFileLayer(project, name, file, "GeoJSON", nil, srid, encoding)
	end,
	--- Validates if the URL is a valid WFS server.
	-- @arg url The URL of the WFS server.
	-- @usage -- DONTRUN
	-- local layerName = "WFS-Layer"
	-- local url = "http://terrabrasilis.info/redd-pac/wfs/wfs_biomes"
	-- local dataset = "reddpac:BAU"
	-- TerraLib().isValidWfsUrl(url)
	isValidWfsUrl = function(url)
		return isValidDataSourceUri(toWfsUrl(url), "WFS")
	end,
	--- Add a WFS layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg url The URL of the WFS server.
	-- @arg dataset The data set in WFS server.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @arg encoding A string value used to set the character encoding.
	-- @usage -- DONTRUN
	-- local layerName = "WFS-Layer"
	-- local url = "http://terrabrasilis.info/redd-pac/wfs/wfs_biomes"
	-- local dataset = "reddpac:BAU"
	-- TerraLib().addWfsLayer(project, name, url, dataset)
	addWfsLayer = function(project, name, url, dataset, srid, encoding)
		local wfsUrl = toWfsUrl(url)
		if instance.isValidWfsUrl(wfsUrl) then
			loadProject(project, project.file)

			local layer = createLayer(name, dataset, wfsUrl, "WFS", nil, srid, encoding)

			project.layers[layer:getTitle()] = layer
			saveProject(project, project.layers)
			releaseProject(project)
		else
			customError("The URL '"..url.."' is invalid.")
		end
	end,
	--- Add a WMS layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg connect A table with the WMS connection parameters.
	-- @arg dataset The data set in WMS server.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @usage -- DONTRUN
	-- local layerName = "WMS-Layer"
	-- local url = "http://terrabrasilis.info/terraamazon/ows"
	-- local dataset = "IMG_02082016_321077D"
	-- local directory = currentDir()
	-- local conn = {
		-- url = url,
		-- directory = directory,
		-- format = "jpeg"
	-- }
	-- TerraLib().addWmsLayer(project, layerName, conn, dataset)
	addWmsLayer = function(project, name, connect, dataset, srid)
		local connInfo = createWmsConnInfo(connect.url, connect.user, connect.password, connect.port,
										connect.query, connect.fragment, connect.directory, connect.format)

		if not isValidDataSourceUri(connInfo, "WMS2") then
			local wmsDir = Directory("wms")

			if wmsDir:exists() then
				wmsDir:delete()
			end

			customError("The URL '"..connect.url.."' is invalid.")
		end

		loadProject(project, project.file)
		local layer = createLayer(name, dataset, connInfo, "WMS2", nil, srid)
		project.layers[layer:getTitle()] = layer
		saveProject(project, project.layers)
		releaseProject(project)
	end,
	--- Create a new cellular layer into a shapefile.
	-- @arg project A table that represents a project.
	-- @arg file The file to the cellular layer.
	-- @arg name The name of the layer.
	-- @arg resolution The size of a cell.
	-- @arg inputLayerTitle The name of the layer.
	-- @arg mask A boolean value indicating whether the cells should cover only the input data (true) or its bounding box (false).
	-- @usage -- DONTRUN
	-- proj = {
	--     file = "mygeojsonproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Carneiro Heitor"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- layerName1 = "Setores_Layer"
	-- layerFile1 = filePath("Setores_Censitarios_2000_pol.geojson", "gis")
	-- TerraLib().addGeoJSONLayer(proj, layerName1, layerFile1)
	--
	-- TerraLib().addGeoJSONCellSpaceLayer(proj, layerName1, "Setores_Cells", 10000, currentDir())
	addGeoJSONCellSpaceLayer = function(project, inputLayerTitle, name, resolution, file, mask)
		loadProject(project, project.file)

		local inputLayer = project.layers[inputLayerTitle]
		local connInfo = createFileConnInfo(tostring(file))
		local _, dSetName = file:split()
		local srid = inputLayer:getSRID()

		createCellSpaceLayer(inputLayer, name, dSetName, resolution, connInfo, "OGR", mask)

		local encoding = binding.CharEncoding.getEncodingName(inputLayer:getEncoding())
		instance.addGeoJSONLayer(project, name, file, srid, encoding)
	end,
	--- Add a new PostgreSQL layer to a given project.
	-- @arg project A table that represents a project.
	-- @arg name The name of the layer.
	-- @arg conn.host Name of the host.
	-- @arg conn.port Port number.
	-- @arg conn.user The user name.
	-- @arg conn.password The password.
	-- @arg conn.database The database name.
	-- @arg encoding A string value used to set the character encoding.
	-- @arg srid A number value that represents the Spatial Reference System Identifier.
	-- @usage -- DONTRUN
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
	--
	-- pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells",
	-- }
	--
	-- TerraLib().addPgLayer(proj, "SampaPg", pgData)
	addPgLayer = function(project, name, conn, srid, encoding)
		local connInfo = createPgConnInfo(conn, encoding)

		loadProject(project, project.file)

		local layer

		if dataSetExists(connInfo, conn.table, "POSTGIS") then
			layer = createLayer(name, conn.table, connInfo, "POSTGIS", nil, srid, encoding)
		else
			releaseProject(project) -- SKIP
			customError("Is not possible add the Layer. Table '"..conn.table.."' does not exist.")
		end

		project.layers[layer:getTitle()] = layer
		saveProject(project, project.layers)
		releaseProject(project)
	end,
	--- Create a new cellular layer into a shapefile.
	-- @arg project A table that represents a project.
	-- @arg inputLayerTitle The name of the layer.
	-- @arg name The name of the layer.
	-- @arg resolution The size of a cell.
	-- @arg file The file to the layer.
	-- @arg mask A boolean value indicating whether the cells should cover only the input data (true) or its bounding box (false).
	-- @arg addSpatialIdx A boolean value indicating whether a spatial index file should be created.
	-- @usage -- DONTRUN
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- layerName1 = "SampaShp"
	-- layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
	--
	--	TerraLib().addShpCellSpaceLayer(proj, layerName1, "Sampa_Cells", 0.7, currentDir())

	addShpCellSpaceLayer = function(project, inputLayerTitle, name, resolution, file, mask, addSpatialIdx)
		loadProject(project, project.file)

		local inputLayer = project.layers[inputLayerTitle]
		local connInfo = createFileConnInfo(tostring(file))
		local _, dSetName = file:split()
		local srid = inputLayer:getSRID()

		createCellSpaceLayer(inputLayer, name, dSetName, resolution, connInfo, "OGR", mask)

		local encoding = binding.CharEncoding.getEncodingName(inputLayer:getEncoding())

		instance.addShpLayer(project, name, file, addSpatialIdx, srid, encoding)
	end,
	--- Add a new cellular layer to a PostgreSQL connection.
	-- @arg project The name of the project.
	-- @arg inputLayerTitle Name of the input layer.
	-- @arg data The connection data, such as host, port, and user.
	-- @arg name The name of the layer.
	-- @arg resolution The size of a cell.
	-- @arg mask A boolean value indicating whether the cells should cover only the input data (true) or its bounding box (false).
	-- @usage --DONTRUN
	-- local proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
	--
	-- local pgData = {
	--     type = "POSTGIS",
	--     host = "localhost",
	--     port = "5432",
	--     user = "postgres",
	--     password = "postgres",
	--     database = "terralib_save_test",
	--     table = "sampa_cells"
	-- }
	--
	-- local clName1 = "SampaPgCells"
	-- local resolution = 0.7
	-- TerraLib().addPgCellSpaceLayer(proj, layerName1, clName1, resolution, pgData)
	addPgCellSpaceLayer = function(project, inputLayerTitle, name, resolution, data, mask)
		loadProject(project, project.file)

		local inputLayer = project.layers[inputLayerTitle]
		local encoding = binding.CharEncoding.getEncodingName(inputLayer:getEncoding())
		createPgDbIfNotExists(data, encoding)
		local connInfo = createPgConnInfo(data, encoding)
		local srid = inputLayer:getSRID()

		if not dataSetExists(connInfo, data.table, "POSTGIS") then
			createCellSpaceLayer(inputLayer, name, data.table, resolution, connInfo, "POSTGIS", mask)
		else
			releaseProject(project) -- SKIP
			customError("Table '"..data.table.."' already exists.") -- SKIP
		end

		instance.addPgLayer(project, name, data, srid, encoding)
	end,
	--- Remove a PostreSQL table.
	-- @arg data.host Name of the host.
	-- @arg data.port Port number.
	-- @arg data.user The user name.
	-- @arg data.password The password.
	-- @arg data.database The database name.
	-- @arg data.encoding The encoding of the table.
	-- @usage -- DONTRUN
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
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
	-- TerraLib().addPgLayer(proj, "SampaPg", pgData)
	--
	-- TerraLib().dropPgTable(pgData)
	dropPgTable = function(data)
		local connInfo = "pgsql://"..data.user..":"..data.password.."@"..data.host..":"..data.port.."/?"
						.."&PG_CONNECT_TIMEOUT=10"
						.."&PG_MAX_POOL_SIZE=4"
						.."&PG_MIN_POOL_SIZE=2"
						.."&PG_CHECK_DB_EXISTENCE="..data.database

		if binding.te.da.DataSource.exists("POSTGIS", connInfo) then
			connInfo = createPgConnInfo(data, data.encoding)
			dropDataSet(connInfo, string.lower(data.table), "POSTGIS")
		end
	end,
	--- Remove a PostreSQL database.
	-- @arg data.host Name of the host.
	-- @arg data.port Port number.
	-- @arg data.user The user name.
	-- @arg data.password The password.
	-- @arg data.database The database name.
	-- @usage -- DONTRUN
	--
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	-- TerraLib().createProject(proj, {})
	--
	-- local layerName1 = "SampaShp"
	-- local layerFile1 = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
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
	-- TerraLib().addPgLayer(proj, "SampaPg", pgData)
	--
	-- TerraLib().dropPgDatabase(pgData)
	dropPgDatabase = function(data)
		local connInfo = "pgsql://"..data.user..":"..data.password.."@"..data.host..":"..data.port.."/?"
					.."&PG_CONNECT_TIMEOUT=10"
					.."&PG_MAX_POOL_SIZE=4"
					.."&PG_MIN_POOL_SIZE=2"
					.."&PG_DB_TO_DROP="..data.database
					.."&PG_CHECK_DB_EXISTENCE="..data.database

		if binding.te.da.DataSource.exists("POSTGIS", connInfo) then
			binding.te.da.DataSource.drop("POSTGIS", connInfo)
		end
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
	-- @arg nodata A number used in raster data that represents no information in a pixel value.
	-- @arg pixel A boolean value. If true, a pixel is considered within a polygon if they have some overlap.
	-- If false, a pixel is within a polygon if its centroid is within the polygon.
	-- @usage -- DONTRUN
	-- proj = {
	--     file = "myproject.tview",
	--     title = "TerraLib Tests",
	--     author = "Avancini Rodrigo"
	-- }
	--
	--
	-- TerraLib().createProject(proj, {})
	--
	-- layerName1 = "Para"
	-- layerFile1 = filePath("limitePA_polyc_pol.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName1, layerFile1)
	--
	-- resolution = 60e3
	-- TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, filePath1)
	--
	-- clSet = TerraLib().getDataSet{project = proj, layer = clName}
	--
	-- layerName2 = "Protection_Unit"
	-- layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName2, layerFile2)
	--
	-- TerraLib().attributeFill(proj, layerName2, clName, presLayerName, "presence", "presence", "FID")
	attributeFill = function(project, from, to, out, property, operation, select, area, default, repr, nodata, pixel)
		do
			loadProject(project, project.file)

			local fromLayer = project.layers[from]
			local toLayer = project.layers[to]
			local toSrid = toLayer:getSRID()
			if fromLayer:getSRID() ~= toSrid then
				local fromSrid = fromLayer:getSRID()
				customError("Layer projections are different: ("..from..", "..string.format("%.0f", fromSrid)..") and ("
								..to..", "..string.format("%.0f", toSrid).."). Please, reproject your data to the right one.")
			end

            local fromDsInfo =  binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
			local toDsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(toLayer:getDataSourceId())
			local outDsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(toLayer:getDataSourceId())
			local outType = outDsInfo:getType()
			local outConnInfo = outDsInfo:getConnInfo()
			local outFileExt

			if outType == "OGR" then
				outFileExt = string.lower(getFileByUri(outConnInfo):extension())

				if (string.len(property) > 10) and (outFileExt == "shp")  then
					property = getNormalizedName(property)
					customWarning("The 'attribute' lenght has more than 10 characters. It was truncated to '"..property.."'.")
				end
			end

			local toDSetName = toLayer:getDataSetName()

			if propertyExists(toDsInfo:getConnInfo(), toDSetName, property, toDsInfo:getType()) then
				customError("The attribute '"..property.."' already exists in the Layer.")
			end

			local fromConnInfo = fromDsInfo:getConnInfo()
			local fromType = fromDsInfo:getType()
			local fromDSetName = fromLayer:getDataSetName()

			if not propertyExists(fromConnInfo, fromDSetName, select, fromType) then
				if repr == "raster" then
					customError("Selected band '"..select.."' does not exist in Layer '"..from.."'.")
				else
					customError("Selected attribute '"..select.."' does not exist in Layer '"..from.."'.")
				end
			end

			local propType = getPropertyDataType(fromConnInfo, fromType, fromDSetName, select)

			if not isOperationAvailableToPropertyDataType(operation, propType) then
				local pt = "unknown"
				if isDataTypeReal(propType) then
					pt = "real"
				elseif isDataTypeString(propType) then
					pt = "string"
				end

				customError("Operation '"..operation.."' cannot be executed with an attribute of type "..pt.. " ('"..select.."').")
			end

			local outOverwrite = false
			if out == nil then
				outOverwrite = true
				local rand = string.gsub(binding.GetRandomicId(), "-", "")
				rand = string.sub(rand, 1, 5)
				out = to.."_"..rand
			end

			local outDSetName
			if outFileExt == "geojson" then
				outDSetName = "OGRGeoJSON"
			else
				outDSetName = out
			end

			local outDs
			local propCreatedName
			local outSpatialIdx

			if outType == "POSTGIS" then
				outDSetName = string.lower(outDSetName)
				outSpatialIdx = false -- TODO(#1678)
			elseif outType == "OGR" then
				local file = getFileByUri(outConnInfo)
				local outDir = _Gtme.makePathCompatibleToAllOS(file:path())
				local outFileUri = createFileConnInfo(outDir..out.."."..file:extension())
				outFileUri = toUtf8(outFileUri)
				outConnInfo = binding.te.core.URI(outFileUri)
				outSpatialIdx = true
			end

			dropDataSet(outConnInfo, outDSetName, outType)

			local dseType = fromLayer:getSchema()

			if dseType:hasRaster() then
				if pixel == nil then pixel = true end

				propCreatedName = rasterToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, out, nodata, pixel)
			else
				propCreatedName = vectorToVector(fromLayer, toLayer, operation, select, outConnInfo, outType, out, area)
			end

			if outType == "OGR" then
				if outFileExt == "shp" then
					propCreatedName = getNormalizedName(propCreatedName)
				end
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

			if outType == "POSTGIS" and outOverwrite then
				dropDataSet(outConnInfo, toDSetName, outType)
				outDs:renameDataSet(outDSetName, toDSetName)

				loadProject(project, project.file) -- TODO: WHY IS IT NEEDING RELOAD? (REVIEW)
				releaseProject(project)
				outDs:close()
			else -- TODO(#875): RENAME INSTEAD OUTPUT
				local outLayer = createLayer(out, outDSetName, outConnInfo, outType, outSpatialIdx, toSrid)
				project.layers[out] = outLayer

				loadProject(project, project.file) -- TODO: WHY IS IT NEEDING RELOAD? (REVIEW)
				saveProject(project, project.layers)
				releaseProject(project)

				if outOverwrite then
					local toConnInfo = toDsInfo:getConnInfo()
					local toType = toDsInfo:getType()
					local toSetName = nil

					if toType == "OGR" then
						local _, name = getFileByUri(toConnInfo):split()
						toSetName = name
					end

					outDs:close()

					if outFileExt == "geojson" then -- TODO(#2224)
						local toFile = getFileByUri(toConnInfo):deleteIfExists()
						local outFile = getFileByUri(outConnInfo)
						os.execute("mv "..outFile.." "..toFile) -- SKIP
					else
						overwriteLayer(project, out, to, toSetName, default)
					end

					removeLayer(project, out)
				end
			end
		end

		collectgarbage("collect")
	end,
	--- Returns a given dataset from a layer.
	-- @arg data.project A project.
	-- @arg data.layer A layer name.
	-- @arg data.file A file path.
	-- @arg data.missing A value to replace null values.
	-- @usage -- DONTRUN
	-- dset = TerraLib().getDataSet{project = "myproject.tview", layer = "mylayer"}
	getDataSet = function(data)
		local set, err

		if data.project then
			local project = data.project
			local layerName = data.layer
			local missing = data.missing

			local cache = getCache(project, layerName, missing)
			if cache then return cache end

			do
				loadProject(project, project.file)

				local layer = project.layers[layerName]
				local dseName = layer:getDataSetName()
				local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
				local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
				local dse = ds:getDataSet(dseName)
				set, err = createDataSetAdapted(dse, missing)

				addCache(set, project, layerName, missing)
				releaseProject(project)
			end
		else
			local cache = getCache(filePath, data.missing)
			if cache then return cache end

			local dset = getDataSetFromFile(data.file)
			set, err = createDataSetAdapted(dset, data.missing)

			addCache(set, data.file, data.missing)
		end

		collectgarbage("collect")

		if not set then
			customError(err)
		end

		return set
	end,
	--- Save a given dataset.
	-- @arg project The name of the project.
	-- @arg fromLayerName The input layer name.
	-- @arg toLayerName The output layer name.
	-- @arg toSet A table mapping the names of the attributes from the input to the output.
	-- @arg attrs A table with the attributes to be saved.
	-- @arg toSetName The name of the output data set.
	-- @usage -- DONTRUN
	-- saveDataSet(project, fromLayerName, toSet, toName, attrs)
	saveDataSet = function(project, fromLayerName, toSet, toLayerName, attrs, toSetName)
		do
			loadProject(project, project.file)

			local fromLayer = project.layers[fromLayerName]
			fromLayer = castLayer(fromLayer)
			local dseName = fromLayer:getDataSetName()
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(fromLayer:getDataSourceId())
			local connInfo = dsInfo:getConnInfo()
			local fromType = dsInfo:getType()

			if fromLayerName == toLayerName then
				toSetName = dseName
			elseif not toSetName then
				toSetName = toLayerName
			end

			local addSpatialIdx = true

			if fromType == "POSTGIS" then
				toSetName = string.lower(toSetName)
				addSpatialIdx = false
			elseif not (fromType == "OGR") then
				customError("Save '"..toSetName.."' does not support '"..toType.."' type.")
			end

			if not attrs then
				attrs = {}
			end

			if dseName == toSetName then
				if #attrs > 0 then
					if hasNewAttributeOnLayer(fromLayer, attrs) then
						createDataSetFromLayer(fromLayer, toSetName, toSet, attrs)
					else
						updateDataSet(fromLayer, toSet, attrs)
					end
				end
			else
				createDataSetFromLayer(fromLayer, toSetName, toSet, attrs)
				local toConnInfo = createConnInfoToSave(connInfo, toSetName, fromType)
				local toLayer
				if dseName == "OGRGeoJSON" then
					toLayer = createLayer(toLayerName, dseName, toConnInfo, fromType, addSpatialIdx, fromLayer:getSRID())
				else
					toLayer = createLayer(toLayerName, toSetName, toConnInfo, fromType, addSpatialIdx, fromLayer:getSRID())
				end
				project.layers[toLayerName] = toLayer
				saveProject(project, project.layers)
			end

			releaseProject(project)
		end

		collectgarbage("collect")
	end,
	--- Returns the number of bands of some Raster.
	-- @arg project The project.
	-- @arg layerName The input layer name.
	-- @usage -- DONTRUN
	-- TerraLib().addGdalLayer(proj, layerName, layerFile)
	-- local numBands = TerraLib().getNumOfBands(proj, layerName)
	getNumOfBands = function(project, layerName)
		local layer = project.layers[layerName]
		local raster = getRasterFromLayer(project, layer)

		if raster then
			return raster:getNumberOfBands()
		end

		customError("The layer '"..layerName.."' is not a Raster.")
	end,
	--- Returns the area of this envelope as measured in the spatial reference system of it.
	-- @arg geom The geometry of the project.
	-- @usage -- DONTRUN
	-- local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
	-- local area = TerraLib().getArea(dSet[0].OGR_GEOMETRY)
	getArea = function(geom)
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
	-- @arg layer A layer.
	-- @usage -- DONTRUN
	-- local prj = TerraLib().getProjection(proj.layers[layerName])
	-- print(prj.NAME..". SRID: "..prj.SRID..". PROJ4: "..prj.PROJ4)
	getProjection = function(layer)
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
	-- @arg project A Project.
	-- @arg layerName A Layer name.
	-- @usage -- DONTRUN
	-- local propNames = TerraLib().getPropertyNames(proj, proj.layers[layerName])
	-- for i = 0, #propNames do
	--		unitTest:assert((propNames[i] == "FID") or (propNames[i] == "ID") or
	--						(propNames[i] == "NM_MICRO") or (propNames[i] == "CD_GEOCODU"))
	-- end
	getPropertyNames = function(project, layerName)
		loadProject(project, project.file)

		local layer = project.layers[layerName]
		local dSetLayer = castLayer(layer)
		local dSetName = dSetLayer:getDataSetName()
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(dSetLayer:getDataSourceId())
		local names

		do
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			names = ds:getPropertyNames(dSetName)
			ds:close()
		end

		releaseProject(project)
		collectgarbage("collect")

		return names
	end,
	--- Returns the property informations of a layer.
	-- @arg project A Project.
	-- @arg layerName A Layer name.
	-- @usage -- DONTRUN
	-- local propInfos = TerraLib().getPropertyInfos(proj, "layerName")
	-- unitTest:assertEquals(propInfos[1].name, "ID")
	-- unitTest:assertEquals(propInfos[1].type, "integer 64")
	-- unitTest:assertEquals(propInfos[2].name, "NM_MICRO")
	-- unitTest:assertEquals(propInfos[2].type, "string")
	getPropertyInfos = function(project, layerName)
		loadProject(project, project.file)

		local layer = project.layers[layerName]
		local dSetLayer = castLayer(layer)
		local dSetName = dSetLayer:getDataSetName()
		local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(dSetLayer:getDataSourceId())
		local infos	= {}

		do
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			local dset = ds:getDataSet(dSetName)
			local numProps = dset:getNumProperties()

			dset:moveFirst()
			for i = 0, numProps - 1 do
				local info = {}
				info.name = dset:getPropertyName(i)
				info.type = string.lower(binding.ConvertDataTypeToString(dset:getPropertyDataType(i)))
				infos[i] = info
			end
		end

		releaseProject(project)
		collectgarbage("collect")

		return infos
	end,
	--- Returns the shortest distance between any two points in the two geometries.
	-- @arg fromGeom The geometry.
	-- @arg toGeom The other geometry.
	-- @usage -- DONTRUN
	-- local dSet = TerraLib().getDataSet{project = proj, layer = clName1}
	-- local dist = TerraLib().getDistance(dSet[0].OGR_GEOMETRY, dSet[getn(dSet) - 1].OGR_GEOMETRY)
	getDistance = function(fromGeom, toGeom)
		return fromGeom:distance(toGeom)
	end,
	--- Returns a subtype of Geometry object.
	-- @arg geom A Geometry object.
	-- @usage -- DONTRUN
	-- shpPath = filePath("RODOVIAS_AMZ_lin.shp", "gis")
	-- dSet = TerraLib().getDataSet{file = shpPath}
	-- geom = dSet[1].OGR_GEOMETRY
	-- geom = TerraLib().castGeomToSubtype(geom)
	castGeomToSubtype = function(geom)
		return castGeometry(geom)
	end,
	--- Returns the dummy value of a raster data.
	-- @arg project The project.
	-- @arg layerName The layer name which is in the project.
	-- @arg band The band number.
	-- @usage -- DONTRUN
	-- local layerName = "TifLayer"
	-- local layerFile = filePath("cbers_rgb342_crop1.tif", "gis")
	-- TerraLib().addGdalLayer(proj, layerName, layerFile)
	-- local dummy = TerraLib().getDummyValue(proj, layerName, 0)
	getDummyValue = function(project, layerName, band)
		local layer = project.layers[layerName]
		local raster = getRasterFromLayer(project, layer)
		local value = nil

		if raster then
			local numBands = raster:getNumberOfBands()
			if numBands > band then
				local bandObj = raster:getBand(band)
				local bandProperty = bandObj:getProperty()
				value = bandProperty.m_noDataValue
			else
				if (numBands - 1) > 0 then
					customError("The maximum band is '"..string.format("%.0f", numBands - 1).."'.")
				else
					customError("The only available band is '"..string.format("%.0f", numBands - 1).."'.")
				end
			end
		end

		return value
	end,
	--- Save some data of a layer to another data type.
	-- @arg fromData The reference information data.
	-- @arg toData The data that will be saved.
	-- @arg overwrite Indicates if the saved data will be overwritten.
	-- @arg attrs The attribute(s) that will be saved.
	-- @arg values A table with a data's subset of the Layer.
	-- If this parameter is set with a subset of from data, the saved data will have only its values.
	-- And, if values is set and attrs is nil, all attributes will be saved.
	-- @usage -- DONTRUN
	-- local fromData = {
	--     project = aProject,
	--     layer = "aLayerName"
	-- }
	-- local toData = {
	--     file = "shp2geojson.geojson",
	--     type = "geojson",
	--     srid = 4326
	-- }
	-- TerraLib().saveDataAs(fromData, toData, true, {"population", "ages"})
	saveDataAs = function(fromData, toData, overwrite, attrs, values)
		if fromData.project then
			local project = fromData.project
			loadProject(project, project.file)
			local layer = project.layers[fromData.layer]
			local fromDataToSave = createFromDataInfoToSaveAsByLayer(layer)
			local toDataToSave = createToDataInfoToSaveAs(toData, fromDataToSave, overwrite)

			if fromDataToSave.type == "GDAL" then
				saveRasterDataAs(fromDataToSave, toDataToSave)
			else
				saveVectorDataAs(fromDataToSave, toDataToSave, attrs, values)
			end

			-- If the data already belongs a layer, it will be updated in the project
			local toLayer = getLayerByDataSetName(project.layers, toDataToSave.dataset, toDataToSave.type)
			if toLayer then
				if toLayer:getSRID() ~= toDataToSave.srid then
					toLayer:setSRID(toDataToSave.srid)
					saveProject(project, project.layers)
				end
			end

			releaseProject(project)
		elseif fromData.file then
			local fromDataToSave = createFromDataInfoToSaveAsByFile(fromData.file)
			local toDataToSave = createToDataInfoToSaveAs(toData, fromDataToSave, overwrite)

			if fromDataToSave.type == "GDAL" then
				saveRasterDataAs(fromDataToSave, toDataToSave)
			else
				saveVectorDataAs(fromDataToSave, toDataToSave, attrs, values)
			end
		end

		collectgarbage("collect")

		return true
	end,
	--- Returns the size of a layer.
	-- When it stores vector data, it returns the number of elements. If it stores raster data, return the number of pixels.
	-- @arg project The project.
	-- @arg layerName The layer name which is in the project.
	-- @usage -- DONTRUN
	-- local layerName = "SampaShp"
	-- local layerFile = filePath("sampa.shp", "gis")
	-- TerraLib().addShpLayer(proj, layerName, layerFile)
	-- local size = TerraLib().getLayerSize(proj, layerName)
	getLayerSize = function(project, layerName)
		local size

		do
			loadProject(project, project.file)

			local layer = project.layers[layerName]
			local datasetName = layer:getDataSetName()
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), dsInfo:getType())
			local dataset = ds:getDataSet(datasetName)
			local dst = ds:getDataSetType(datasetName)

			if dst:hasGeom() then
				size = dataset:size()
			else
				local raster = getRasterByDataSet(dataset)
				size = getRasterSize(raster)
			end

			releaseProject(project)
		end

		collectgarbage("collect")

		return size
	end,
	--- Create a new dataset applying Douglas Peucker algorithm.
	-- @arg project The project.
	-- @arg fromLayerName The layer name used as reference to create a new dataset.
	-- @arg toDSetName The new dataset name.
	-- @arg tolerance The tolerance is a distance that defines the threshold for vertices to be
	-- considered "insignificant" for the general structure of the geometry.
	-- The tolerance must be expressed in the same units as the projection of the input geometry.
	-- @usage -- DONTRUN
	-- lnName = "ES_Rails"
	-- lnFile = filePath("test/rails.shp", "gis")
	-- TerraLib().addShpLayer(proj, lnName, lnFile)
	-- TerraLib().douglasPeucker(proj, lnName, "spl"..lnName, 500)
	douglasPeucker = function(project, fromLayerName, toDSetName, tolerance)
		local errorMsg

		do
			loadProject(project, project.file)

			local layer = project.layers[fromLayerName]
			layer = castLayer(layer)
			local datasetName = layer:getDataSetName()
			local dsInfo = binding.te.da.DataSourceInfoManager.getInstance():getDsInfo(layer:getDataSourceId())
			local fromType = dsInfo:getType()
			local ds = makeAndOpenDataSource(dsInfo:getConnInfo(), fromType)
			local dataset = ds:getDataSet(datasetName)
			local dst = ds:getDataSetType(datasetName)

			if dst:hasGeom() then
				local gp = binding.GetFirstGeomProperty(dst)
				local gpt = gp:getGeometryType()

				if (gpt == binding.te.gm.LineStringType) or (gpt == binding.te.gm.MultiLineStringType) then
					local toSet = {}
					local count = 1
					local gname = gp:getName()
					local gpos = getPropertyPosition(dataset, gname)
					dataset:moveBeforeFirst()

					if gpt == binding.te.gm.MultiLineStringType then
						if fromType == "POSTGIS" then
							while dataset:moveNext() do
								local to = {}
								local ml = castGeometry(dataset:getGeom(gpos))
								ml = ml:clone()
								local line = castGeometry(ml:getGeometryN(0))
								local dp = binding.GEOS_DouglasPeucker(line, tolerance, 0)
								local np = dp:size()
								local l = binding.te.gm.LineString(np, binding.te.gm.LineStringType, line:getSRID())
								l = l:clone()

								for i = 0, np - 1 do
									l:setPoint(i, dp:getX(i), dp:getY(i))
								end

								ml:setGeometryN(0, l)
								to[gname] = ml
								toSet[count] = to
								count = count + 1
							end
						else
							while dataset:moveNext() do
								local to = {}
								local ml = castGeometry(dataset:getGeom(gpos))
								ml = ml:clone()
								local line = castGeometry(ml:getGeometryN(0))
								local dp = binding.GEOS_DouglasPeucker(line, tolerance, 0)

								ml:setGeometryN(0, dp)
								to[gname] = ml
								toSet[count] = to
								count = count + 1
							end
						end

						toDSetName = string.lower(toDSetName)
					else
						while dataset:moveNext() do -- TODO(avancinirodrigo): there is no data with line to test.
							local to = {}
							local line = castGeometry(dataset:getGeom(gpos))
							local dp = binding.GEOS_DouglasPeucker(line, tolerance, 0)

							to[gname] = dp -- SKIP
							toSet[count] = to -- SKIP
							count = count + 1 -- SKIP
						end
					end

					createDataSetFromLayer(layer,  toDSetName, toSet, {gname})
				else
					errorMsg = "This function works only with line and multi-line geometry."
				end
			else
				errorMsg = "This function works only with line geometry."
			end

			releaseProject(project)
		end

		if errorMsg then
			customError(errorMsg)
		end
	end,
	--- Check if a name is valid.
	-- Return a error message if the name is invalid, otherwise it returns a empty string.
	-- @arg name A string name.
	-- @usage -- DONTRUN
	-- TerraLib().checkName("aname")
	checkName = function(name)
		return string.gsub(string.gsub(binding.CheckName(name), "\n", ""), "^%l", string.upper)
	end,
	--- Return the bounding box of a Layer.
	-- @arg layer A Layer.
	-- @usage -- DONTRUN
	-- TerraLib().getBoundingBox(proj.layers["layerName"])
	getBoundingBox = function(layer)
		local ext = layer:getExtent()
		local box = {
			xMin = ext:getLowerLeftX(),
			xMax = ext:getUpperRightX(),
			yMin = ext:getLowerLeftY(),
			yMax = ext:getUpperRightY()
		}

		return box
	end,
	--- Return pseudo-random number generations exported from Boost.
	-- @usage -- DONTRUN
	-- mt = TerraLib().random().MersenneTwister(1)
	-- nd = TerraLib().random().NormalDistribution(mt, 1, 6)
	-- print(nd())
	random = function()
		return binding.te.random
	end,
	--- Return a handle to TerraLib Geometry Objects.
	-- @usage -- DONTRUN
	-- TerraLib().geometry().Point(0, 0)
	geometry = function()
		return binding.te.gm
	end,
	--- Creates a polygonized data using GDALPolygonize().
	-- @arg rasterInfo A table with input Raster layer information.
	-- @arg rasterInfo.project The project which contains the layer.
	-- @arg rasterInfo.layer The layer name.
	-- @arg rasterInfo.band The band which will be created the values.
	-- @arg outInfo A table with output information according to data source with
	-- the same arguments when creates a layer from a file or database.
	-- @usage -- DONTRUN
	-- local rasterInfo = {
	-- 	project = aProject,
	-- 	layer = aLayerName,
	-- 	band = 0,
	-- }
	--
	-- local outInfo = {
	-- 	source = "postgis",
	-- 	host = "localhost",
	-- 	port = "5432",
	-- 	user = "postgres",
	-- 	password = "postgres",
	-- 	database = "postgis_22_sample",
	-- 	table = "aTableName",
	-- 	encoding = "LATIN1"
	-- }
	--
	-- TerraLib().polygonize(rasterInfo, outInfo)
	polygonize = function(rasterInfo, outInfo)
		local project = rasterInfo.project
		local layer = project.layers[rasterInfo.layer]
		local inInfo = getLayerDataSourceInfo(project, layer)

		if inInfo:getType() ~= "GDAL" then
			customError("Input layer must be a Raster.")
		end

		local raster = getRasterFromLayer(project, layer)
		local type = SourceTypeMapper[outInfo.type]
		local dsInfo = binding.te.da.DataSourceInfo()
		local connInfo
		local dseName

		if type == "OGR" then
			connInfo = createFileConnInfo(tostring(outInfo.file))
			local _, fileName = outInfo.file:split()
			dseName = fileName
		elseif type == "POSTGIS" then
			createPgDbIfNotExists(outInfo, outInfo.encoding)
			connInfo = createPgConnInfo(outInfo, outInfo.encoding)
			dseName = outInfo.table
		else
			customError("Output type '"..outInfo.type.."' is not supported.")
		end

		dsInfo:setType(type)
		dsInfo:setAccessDriver(type)
		dsInfo:setTitle(dseName)
		dsInfo:setConnInfo(connInfo)

		raster:polygonize(rasterInfo.band, dsInfo, layer:getSRID())
	end,
	--- Remove a given layer from a given project.
	-- @arg project The name of the project.
	-- @arg layerName The name of the layer to be removed.
	-- @usage -- DONTRUN
	-- removeLayer(project, layerName)
	removeLayer = function(project, layerName)
		removeLayer(project, layerName)
	end,
	--- Return the size of a dataset.
	-- @arg file A file.
	-- @usage -- DONTRUN
	-- tifFile = filePath("prodes_polyc_10k.tif", "gis")
	-- tifSize = TerraLib().getDataSetSize(tifFile)
	getDataSetSize = function(file)
		local size
		local dset = getDataSetFromFile(file)

		local fileExt = string.lower(file:extension())
		local dsType = SourceTypeMapper[fileExt]
		if dsType == "GDAL" then
			local raster = getRasterByDataSet(dset)
			size = getRasterSize(raster)
		else
			size = dset:size()
		end

		collectgarbage("collect")

		return size
	end,
	--- Return the information of a raster.
	-- @arg file A raster file.
	-- @usage -- DONTRUN
	-- tifFile = filePath("prodes_polyc_10k.tif", "gis")
	-- tifInfo = info = gis.TerraLib().getRasterInfo(file)
	getRasterInfo = function(file)
		local fileExt = string.lower(file:extension())
		local dsType = SourceTypeMapper[fileExt]
		local info = {}
		if dsType == "GDAL" then
			local dset = getDataSetFromFile(file)
			local raster = getRasterByDataSet(dset)
			info.bands = raster:getNumberOfBands()
			info.columns = raster:getNumberOfColumns()
			info.rows = raster:getNumberOfRows()
			info.resolutionX = raster:getResolutionX()
			info.resolutionY = raster:getResolutionY()
			info.srid = raster:getSRID()
		else
			customError("File '"..file:name().."' is not a raster.")
		end

		collectgarbage("collect")

		return info
	end,
	--- Save a raster on file.
	-- @arg rasterTable A table built from raster dataset.
	-- @arg rasterFileRef The raster file that was used for build the raster table.
	-- @arg outFile A file to save the raster.
	-- @arg attribute A attribute from the table that its values will be saved on raster band 0.
	-- @usage -- DONTRUN
	-- tifFile = filePath("prodes_polyc_10k.tif", "gis")
	-- local outFile = File("newraster.tif"):deleteIfExists()
	-- TerraLib().saveRasterFromTable(cs.cells, tifFile, outFile, "b0")
	saveRasterFromTable = function(rasterTable, rasterFileRef, outFile, attribute)
		do
			local dset = getDataSetFromFile(rasterFileRef)
			local rasterRef = getRasterByDataSet(dset)
			local rasterHandler = binding.te.rp.RasterHandler()
			binding.CreateRasterOnFile(rasterRef, tostring(outFile), rasterHandler)
			local rasterOut = rasterHandler:getRasterPtr()

			for i = 1, #rasterTable do
				local data = rasterTable[i]
				rasterOut:getBand(0):setValue(data.col, data.row, data[attribute])
			end
		end

		collectgarbage("collect")
	end
}

metaTableTerraLib_ = {
	__index = TerraLib_,
}

--- Type to access TerraLib. It contains very basic and low level functions that
-- are used by the other types of the package. If needed, these functions should
-- be used with care. Such functions mught stop with very strange errors because
-- they do not check any errors in their arguments.
-- All functions must be called by '.'.
-- @usage -- DONTRUN
-- TerraLib().getVersion()
function TerraLib()
	if instance then
		return instance
	else
		local data = {}
		setmetatable(data, metaTableTerraLib_) -- SKIP
		instance = data -- SKIP
		return data
	end
end
