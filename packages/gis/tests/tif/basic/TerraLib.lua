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

return {
	addGdalLayer = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local layerInfo = TerraLib().getLayerInfo(proj, layerName)

		unitTest:assertEquals(layerInfo.name, layerName)
		unitTest:assertEquals(layerInfo.file, tostring(layerFile))
		unitTest:assertEquals(layerInfo.type, "GDAL")
		unitTest:assertEquals(layerInfo.rep, "raster")

		proj.file:delete()
	end,
	getDataSet = function(unitTest)
		local getTifDataSet = function()
			local file = filePath("test/prodes_polyc_10k.tif", "gis")
			local dSet = TerraLib().getDataSet{file = file}

			unitTest:assertEquals(getn(dSet), 20020)

			for i = 0, getn(dSet) - 1 do
				for k, v in pairs(dSet[i]) do
					unitTest:assert(belong(k, {"b0", "col", "row"}))
					unitTest:assertNotNil(v)
					unitTest:assertType(v, "number")
				end
			end
		end

		local getAscDataSet = function()
			local file = filePath("test/biomassa-manaus.asc", "gis")
			local dSet = TerraLib().getDataSet{file = file}

			unitTest:assertEquals(getn(dSet), 9964)

			for i = 0, getn(dSet) - 1 do
				for k, v in pairs(dSet[i]) do
					unitTest:assert(belong(k, {"b0", "col", "row"}))
					unitTest:assertNotNil(v)
					unitTest:assertType(v, "number")
				end
			end
		end

		local getNcDataSet = function()
			local file = filePath("test/vegtype_2000.nc", "gis")
			local dSet = TerraLib().getDataSet{file = file}

			unitTest:assertEquals(getn(dSet), 8904) -- SKIP

			for i = 0, getn(dSet) - 1 do
				for k, v in pairs(dSet[i]) do
					unitTest:assert(belong(k, {"b0", "col", "row"})) -- SKIP
					unitTest:assertNotNil(v) -- SKIP
					unitTest:assertType(v, "number") -- SKIP
				end
			end
		end

		unitTest:assert(getTifDataSet)
		unitTest:assert(getAscDataSet)
		if _Gtme.sessionInfo().system == "windows" then
			unitTest:assert(getNcDataSet) -- SKIP
		end
	end,
	getNumOfBands = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local numBands = TerraLib().getNumOfBands(proj, layerName)
		unitTest:assertEquals(numBands, 3)

		proj.file:delete()
	end,
	getProjection = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile, 100017)

		local prj = TerraLib().getProjection(proj.layers[layerName])

		unitTest:assertEquals(prj.SRID, 100017.0)
		unitTest:assertEquals(prj.NAME, "SAD69 / UTM zone 21S - old 29191")
		unitTest:assertEquals(prj.PROJ4, "+proj=utm +zone=21 +south +ellps=aust_SA +towgs84=-57,1,-41,0,0,0,0 +units=m +no_defs ")

		proj.file:delete()
	end,
	getPropertyNames = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local propNames = TerraLib().getPropertyNames(proj, layerName)

		unitTest:assertEquals(getn(propNames), 1)
		unitTest:assertEquals(propNames[0], "raster")

		proj.file:delete()
	end,
	getPropertyInfos = function(unitTest)
		local proj = {}
		proj.file = "tlib_pg_bas.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "Prodes"
		local layerFile = filePath("amazonia-prodes.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local propInfos = TerraLib().getPropertyInfos(proj, layerName)

		unitTest:assertEquals(getn(propInfos), 1)
		unitTest:assertEquals(propInfos[0].type, "raster")
		unitTest:assertEquals(propInfos[0].type, "raster")

		proj.file:delete()
	end,
	getDistance = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("amazonia-prodes.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = File(clName..".shp")

		shp1:deleteIfExists()

		local resolution = 2e5
		local mask = false
		TerraLib().addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)

		local dSet = TerraLib().getDataSet{project = proj, layer = clName}
		local dist = TerraLib().getDistance(dSet[0].OGR_GEOMETRY, dSet[getn(dSet) - 1].OGR_GEOMETRY)

		unitTest:assertEquals(dist, 3883297.5677895, 1.0e-7) -- SKIP

		shp1:delete()

		proj.file:delete()
	end,
	getDummyValue = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		File(proj.file):deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local dummy = TerraLib().getDummyValue(proj, layerName, 0)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		dummy = TerraLib().getDummyValue(proj, layerName, 1)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		dummy = TerraLib().getDummyValue(proj, layerName, 2)
		unitTest:assertEquals(tostring(dummy), tostring(1.7976931348623e+308))

		local layerName2 = "ShapeLayer"
		local layerFile2 = filePath("test/sampa.shp", "gis")
		TerraLib().addShpLayer(proj, layerName2, layerFile2)

		dummy = TerraLib().getDummyValue(proj, layerName2, 0)
		unitTest:assertNil(dummy)

		proj.file:delete()
	end,
	getLayerSize = function(unitTest)
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"

		local file = File(proj.file)
		file:deleteIfExists()

		TerraLib().createProject(proj, {})

		local layerName = "TifLayer"
		local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
		TerraLib().addGdalLayer(proj, layerName, layerFile)

		local size = TerraLib().getLayerSize(proj, layerName)

		unitTest:assertEquals(size, 882875.0)

		file:delete()
	end,
	getDataSetSize = function(unitTest)
		local tifFile = filePath("test/prodes_polyc_10k.tif", "gis")
		local dsetSize = TerraLib().getDataSetSize(tifFile)

		unitTest:assertEquals(dsetSize, 20020)
	end,
	saveDataAs = function(unitTest)
		local createProject = function()
			local proj = {
				file = "savedataas_tif_basic.tview",
				title = "TerraLib Tests",
				author = "Avancini Rodrigo"
			}
			File(proj.file):deleteIfExists()
			TerraLib().createProject(proj, {})
			return proj
		end

		local saveTifLayerAsTifAndReproject = function()
			local proj = createProject()
			local layerName = "TifLayer"
			local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName, layerFile)

			local overwrite = true
			local fromData = {project = proj, layer = layerName}
			local toData = {file = File("tif2tif.tif"), srid = 5880}

			TerraLib().saveDataAs(fromData, toData, overwrite)

			local tifSet = TerraLib().getDataSet{project = proj, layer = layerName}
			local outSet = TerraLib().getDataSet{file = toData.file}
			unitTest:assert(toData.file:exists())
			unitTest:assertEquals(getn(tifSet), getn(outSet))
			unitTest:assertEquals(getn(tifSet), 882875)
			unitTest:assertEquals(outSet[0].b0, 33)
			unitTest:assertEquals(outSet[882874].b0, 41)
			unitTest:assertEquals(outSet[0].b0, tifSet[0].b0)
			unitTest:assertEquals(outSet[882874].b0, tifSet[882874].b0)

			local outLayerName = "Saved"
			TerraLib().addGdalLayer(proj, outLayerName, toData.file)

			local tifInfo = TerraLib().getLayerInfo(proj, layerName)
			local outInfo = TerraLib().getLayerInfo(proj, outLayerName)
			unitTest:assert(tifInfo.srid ~= outInfo.srid)
			unitTest:assertEquals(outInfo.srid, 5880)

			proj.file:delete()
			toData.file:delete()
		end

		local saveTifLayerAsPng = function()
			local proj = createProject()
			local layerName = "TifLayer"
			local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName, layerFile)

			local overwrite = true
			local fromData = {project = proj, layer = layerName}
			local toData = {file = File("tif2png.png"), type = "png"}

			TerraLib().saveDataAs(fromData, toData, overwrite)

			local tifSet = TerraLib().getDataSet{project = proj, layer = layerName}
			local outSet = TerraLib().getDataSet{file = toData.file}
			unitTest:assert(toData.file:exists())
			unitTest:assertEquals(getn(tifSet), getn(outSet))
			unitTest:assertEquals(getn(tifSet), 882875)
			unitTest:assertEquals(outSet[0].b0, 33)
			unitTest:assertEquals(outSet[882874].b0, 41)
			unitTest:assertEquals(outSet[0].b0, tifSet[0].b0)
			unitTest:assertEquals(outSet[882874].b0, tifSet[882874].b0)

			proj.file:delete()
			toData.file:delete()
		end

		local saveTifLayerAsNc = function()
			local proj = createProject()
			local layerName = "TifLayer"
			local layerFile = filePath("test/prodes_polyc_10k.tif", "gis")
			TerraLib().addGdalLayer(proj, layerName, layerFile)

			local overwrite = true
			local fromData = {project = proj, layer = layerName}
			local toData = {file = File("tif2nc.nc"), type = "nc"}

			TerraLib().saveDataAs(fromData, toData, overwrite)

			local tifSet = TerraLib().getDataSet{project = proj, layer = layerName} -- SKIP
			local outSet = TerraLib().getDataSet{file = toData.file} -- SKIP
			unitTest:assert(toData.file:exists()) -- SKIP
			unitTest:assertEquals(getn(tifSet), getn(outSet)) -- SKIP
			unitTest:assertEquals(getn(tifSet), 20020) -- SKIP
			unitTest:assertEquals(outSet[0].b0, 255) -- SKIP
			unitTest:assertEquals(outSet[20019].b0, 255) -- SKIP
			unitTest:assertEquals(outSet[0].b0, tifSet[0].b0) -- SKIP
			unitTest:assertEquals(outSet[20019].b0, tifSet[20019].b0) -- SKIP

			proj.file:delete()
			toData.file:delete()
		end

		-- local saveTifLayerAsAsc = function()
			-- local proj = createProject()
			-- local layerName = "TifLayer"
			-- local layerFile = filePath("test/cbers_rgb342_crop1.tif", "gis")
			-- TerraLib().addGdalLayer(proj, layerName, layerFile)

			-- local overwrite = true
			-- local fromData = {project = proj, layer = layerName}
			-- local toData = {file = File("tif2nc.asc"), type = "asc"}

			-- TerraLib().saveDataAs(fromData, toData, overwrite)

			-- local tifSet = TerraLib().getDataSet{project = proj, layer = layerName} -- SKIP
			-- local outSet = TerraLib().getDataSet{file = toData.file} -- SKIP
			-- unitTest:assert(toData.file:exists()) -- SKIP
			-- unitTest:assertEquals(getn(tifSet), getn(outSet)) -- SKIP
			-- unitTest:assertEquals(getn(tifSet), 882875) -- SKIP
			-- unitTest:assertEquals(outSet[0].b0, 33) -- SKIP
			-- unitTest:assertEquals(outSet[882874].b0, 41) -- SKIP
			-- unitTest:assertEquals(outSet[0].b0, tifSet[0].b0) -- SKIP
			-- unitTest:assertEquals(outSet[882874].b0, tifSet[882874].b0) -- SKIP

			-- proj.file:delete()
			-- toData.file:delete()
		-- end

		local saveTifAsPngAndOverwrite = function()
			local fromData = {file = filePath("test/prodes_polyc_10k.tif", "gis")}
			local toData = {file = File("tif2png.png"), type = "png"}
			local overwrite = true

			TerraLib().saveDataAs(fromData, toData, overwrite)

			local tifSet = TerraLib().getDataSet{file = fromData.file}
			local outSet = TerraLib().getDataSet{file = toData.file}
			unitTest:assert(toData.file:exists())
			unitTest:assertEquals(getn(tifSet), getn(outSet))
			unitTest:assertEquals(getn(tifSet), 20020)
			unitTest:assertEquals(outSet[0].b0, 255)
			unitTest:assertEquals(outSet[20019].b0, 255)
			unitTest:assertEquals(outSet[0].b0, tifSet[0].b0)
			unitTest:assertEquals(outSet[20019].b0, tifSet[20019].b0)

			--<overwriting existing>--
			TerraLib().saveDataAs(fromData, toData, overwrite)
			outSet = TerraLib().getDataSet{file = toData.file}
			unitTest:assert(toData.file:exists())
			unitTest:assertEquals(getn(tifSet), getn(outSet))
			unitTest:assertEquals(getn(tifSet), 20020)
			unitTest:assertEquals(outSet[0].b0, 255)
			unitTest:assertEquals(outSet[20019].b0, 255)
			unitTest:assertEquals(outSet[0].b0, tifSet[0].b0)
			unitTest:assertEquals(outSet[20019].b0, tifSet[20019].b0)

			toData.file:delete()
		end

		unitTest:assert(saveTifLayerAsTifAndReproject)
		unitTest:assert(saveTifLayerAsPng)
		-- unitTest:assert(saveTifLayerAsAsc) -- SKIP -- TODO(): to .asc is not working
		if _Gtme.sessionInfo().system == "windows" then
			unitTest:assert(saveTifLayerAsNc) -- SKIP
		end
		unitTest:assert(saveTifAsPngAndOverwrite)
	end
}

