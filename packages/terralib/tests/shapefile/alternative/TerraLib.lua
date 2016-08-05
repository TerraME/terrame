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
	attributeFill = function(unitTest)
		local tl = TerraLib{}
		local proj = {}
		proj.file = "myproject.tview"
		proj.title = "TerraLib Tests"
		proj.author = "Avancini Rodrigo"
		
		if isFile(proj.file) then
			rmFile(proj.file)
		end	
		
		tl:createProject(proj, {})

		local layerName1 = "Para"
		local layerFile1 = filePath("limitePA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName1, layerFile1)		
		
		local shp = {}

		local clName = "Para_Cells"
		shp[1] = clName..".shp"

		if isFile(shp[1]) then
			rmFile(shp[1])
		end
		
		-- CREATE THE CELLULAR SPACE
		local resolution = 60e3
		local mask = true
		tl:addShpCellSpaceLayer(proj, layerName1, clName, resolution, shp[1], mask)
		
		-- CREATE A LAYER WITH POLYGONS TO DO OPERATIONS
		local layerName2 = "Protection_Unit" 
		local layerFile2 = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		tl:addShpLayer(proj, layerName2, layerFile2)
		
		-- SHAPE OUTPUT
		-- FILL CELLULAR SPACE WITH PRESENCE OPERATION
		local presLayerName = clName.."_"..layerName2.."_Presence"		
		shp[2] = presLayerName..".shp"
		
		if isFile(shp[2]) then
			rmFile(shp[2])
		end

		local operation = "presence"
		local attribute = "presence_truncate"
		local select = "FID"
		local area = nil
		local default = nil
		
		local attributeTruncateWarning = function()
			tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		end
		unitTest:assertError(attributeTruncateWarning, "The 'attribute' lenght has more than 10 characters. It was truncated to 'presence_t'.")
		
		attribute = "FID"
		local attributeAlreadyExists = function()
			tl:attributeFill(proj, layerName2, clName, presLayerName, attribute, operation, select, area, default)
		end
		unitTest:assertError(attributeAlreadyExists, "The attribute 'FID' already exists in the Layer.")
		
		-- END
		for j = 1, #shp do
			if isFile(shp[j]) then
				rmFile(shp[j])
			end
		end	
		
		rmFile(proj.file)
	end
}