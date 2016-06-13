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

return {
	addShpCellSpaceLayer = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		local layerName1 = "AmazoniaTif"
		local layerFile1 = filePath("PRODES_5KM.tif", "terralib")
		tl:addTifLayer(proj, layerName1, layerFile1)

		local clName = "Amazonia_Cells"
		local shp1 = clName..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end	
		
		local resolution = 60e3
		local mask = true
		
		local maskNotWork = function()
			tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp1, mask)
		end
		unitTest:assertError(maskNotWork, "The 'mask' not work to Raster, it was ignored.")
		
		rmFile(proj.file)
	end,	
	--addPgCellSpaceLayer = function(unitTest)
		-- #1152
	--end,
	getNumOfBands = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})
		
		local layerName = "SampaShp"
		local layerFile = filePath("sampa.shp", "terralib")
		tl:addShpLayer(proj, layerName, layerFile)	
		
		local noRasterLayer = function()
			local numBands = tl:getNumOfBands(proj, layerName)
		end
		unitTest:assertError(noRasterLayer, "The layer '"..layerName.."' is not a Raster.")		
		
		rmFile(proj.file)
	end
}

