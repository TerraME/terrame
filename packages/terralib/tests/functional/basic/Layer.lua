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
	Layer = function(unitTest)
		local projName = "cellular_layer_basic.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "Sampa"

		Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}	
		
		local filePath1 = "setores_cells_basic.shp"
		
		if not isFile(filePath1) then
			local mf = io.open(filePath1, "w")
			mf:write("aaa")
			io.close(mf)
		end
		
		local clName1 = "Sampa_Cells"
		
		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			clean = true,
			resolution = 0.3,
			file = filePath1
		}	

		unitTest:assertEquals(projName, cl.project.file)
		unitTest:assertEquals(clName1, cl.name)
		
		local cl2 = Layer{
			project = projName,
			name = clName1
		}
		
		unitTest:assertEquals(cl2.source, "shp")
		unitTest:assertEquals(cl2.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/"..filePath1))			
	
		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
		
		if isFile(filePath1) then
			rmFile(filePath1)
		end

		projName = "setores_2000.tview"

		if isFile(projName) then
			rmFile(projName)
		end
		
		local proj1 = Project {
			file = projName
		}		
		
		local layerName1 = "Sampa"
		local layer1 = Layer{
			project = proj1,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}
		unitTest:assertEquals(layer1.name, layerName1)
					
		local proj2 = Project {
			file = projName
		}		

		local layerName2 = "MG"
		local layer2 = Layer{
			project = proj2,
			name = layerName2,
			file = filePath("MG_cities.shp", "terralib")
		}

		unitTest:assertEquals(layer1.name, layerName1)
		unitTest:assertEquals(layer2.name, layerName2)
		
		local layerName21 = "MG_2"
		local layer21 = Layer{
			project = proj2,
			name = layerName21,
			file = filePath("MG_cities.shp", "terralib")
		}

		unitTest:assert(layer21.name ~= layer2.name)
		unitTest:assertEquals(layer21.sid, layer2.sid)		
		
		local layerName3 = "CBERS1"
		local layer3 = Layer{
			project = proj2,
			name = layerName3,
			file = filePath("cbers_rgb342_crop1.tif", "terralib")		
		}		
		
		unitTest:assertEquals(layer3.name, layerName3)
		
		local layerName4 = "CBERS2"
		local layer4 = Layer{
			project = proj2,
			name = layerName4,
			file = filePath("cbers_rgb342_crop1.tif", "terralib")		
		}		

		unitTest:assert(layer4.name ~= layer3.name)
		unitTest:assertEquals(layer4.sid, layer3.sid)		
		
		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
		
		projName = "cells_setores_2000.tview"

		proj = Project{
			file = projName,
			clean = true
		}		

		layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}
		
		layerName2 = "MG"
		Layer{
			project = proj,
			name = layerName2,
			file = filePath("MG_cities.shp", "terralib")	
		}

		layerName3 = "CBERS"
		Layer{
			project = proj,
			name = layerName3,
			file = filePath("cbers_rgb342_crop1.tif", "terralib")		
		}		
		
		filePath1 = "sampa_cells.shp"

		if isFile(filePath1) then
			rmFile(filePath1)
		end

		clName1 = "Sampa_Cells"
		local l1 = Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			file = filePath1
		}
		
		unitTest:assertEquals(l1.name, clName1)
		
		local filePath2 = "mg_cells.shp"
		
		if isFile(filePath2) then
			rmFile(filePath2)
		end			
		
		local clName2 = "MG_Cells"
		local l2 = Layer{
			project = proj,
			input = layerName2,
			name = clName2,
			resolution = 1,
			file = filePath2		
		}
		
		unitTest:assertEquals(l2.name, clName2)
		
		local filePath3 = "another_sampa_cells.shp"
		
		if isFile(filePath3) then
			rmFile(filePath3)
		end
		
		local clName3 = "Another_Sampa_Cells"
		local l3 = Layer{
			project = proj,
			input = layerName2,
			name = clName3,
			resolution = 0.7,
			file = filePath3		
		}
		
		unitTest:assertEquals(l3.name, clName3)	
		
		-- BOX TEST
		local tl = TerraLib{}
		local clSet = tl:getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 68)
		
		clName1 = clName1.."_Box"
		local filePath4 = clName1..".shp"
		
		if isFile(filePath4) then
			rmFile(filePath4)
		end		
		
		Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			box = true,
			file = filePath4
		}
		
		clSet = tl:getDataSet(proj, clName1)
		unitTest:assertEquals(getn(clSet), 104)		
		
		-- END
		if isFile(projName) then
			rmFile(projName)
		end		

		if isFile(filePath1) then rmFile(filePath1) end
		if isFile(filePath2) then rmFile(filePath2) end
		if isFile(filePath3) then rmFile(filePath3) end
		if isFile(filePath4) then rmFile(filePath4) end
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_basic.tview"
		local layerName1 = "Setores_2000"
		local localidades = "Localidades"
		local rodovias = "Rodovias"

		local proj = Project {
			file = projName,
			clean = true,
			[layerName1] = filePath("Setores_Censitarios_2000_pol.shp", "terralib"),
			[localidades] = filePath("Localidades_pt.shp", "terralib"),
			[rodovias] = filePath("Rodovias_lin.shp", "terralib")
		}
		
		local clName1 = "Setores_Cells"
		local filePath1 = clName1..".shp"
		
		if isFile(filePath1) then
			rmFile(filePath1)
		end

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 30000,
			file = filePath1
		}
		

		cl:fill{
			operation = "presence",
			layer = localidades,
			attribute = "presence"
		}	
--[[
		local areaLayerName = clName1.."_Area"
		local filePath3 = areaLayerName..".shp"
		
		if isFile(filePath3) then
			rmFile(filePath3)
		end
		
		cl:fill{
			operation = "area",
			layer = layerName1,
			attribute = "area"
		}
--]]
		
		cl:fill{
			operation = "count",
			layer = localidades,
			attribute = "count"
		}
		
		-- local distanceLayerName = clName1.."_Distance"
		-- local filePath5 = distanceLayerName..".shp"
		
		-- if isFile(filePath5) then
			-- rmFile(filePath5)
		-- end	
		
		-- cl:fill{
			-- operation = "distance",
			-- layer = localidades,
			-- attribute = "distance"
		-- }
		
		cl:fill{
			operation = "minimum",
			layer = localidades,
			attribute = "minimum",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "maximum",
			layer = localidades,
			attribute = "maximum",
			select = "UCS_FATURA"
		}
		
	--[[	
		cl:fill{
			operation = "coverage",
			layer = localidades,
			attribute = "coverage",
			select = "LOCALIDADE"
		}
		--]]
		
		cl:fill{
			operation = "stdev",
			layer = localidades,
			attribute = "stdev",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "average",
			layer = localidades,
			attribute = "mean",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "average",
			layer = localidades,
			attribute = "weighted",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "mode",
			layer = localidades,
			attribute = "high_inter",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "mode",
			layer = localidades,
			attribute = "high_occur",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "sum",
			layer = localidades,
			attribute = "sum",
			select = "UCS_FATURA"
		}
		
		cl:fill{
			operation = "sum",
			layer = localidades,
			attribute = "wsum",
			select = "UCS_FATURA",
			area = true
		}
		
		-- RASTER TESTS ------------------------------------------	issue #928
		-- local desmatamento = "Desmatamento"
		-- Layer{
			-- name = desmatamento,
			-- file = filePath("Desmatamento_2000.tif", "terralib")		
		-- }	
		
		-- local rmeanLayerName = clName1.."_Mean_Raster"
		-- local filePath16 = shp16 = rmeanLayerName..".shp"

		-- if isFile(filePath16) then
			-- rmFile(filePath16)
		-- end	
		
		-- cl:fill{
			-- operation = "average",
			-- layer = desmatamento,
			-- attribute = "mean_0",
			-- select = 0
		-- }		
		
		-- local rminLayerName = clName1.."_Minimum_Raster"
		-- local filePath17 = rminLayerName..".shp"

		-- if isFile(filePath17) then
			-- rmFile(filePath17)
		-- end	
		
		-- cl:fill{
			-- operation = "minimum",
			-- layer = desmatamento,
			-- attribute = "minimum_0",
			-- select = 0
		-- }		

		-- local rmaxLayerName = clName1.."_Maximum_Raster"
		-- local filePath18 = rmaxLayerName..".shp"

		-- if isFile(filePath18) then
			-- rmFile(filePath18)
		-- end	
		
		-- cl:fill{
			-- operation = "maximum",
			-- layer = desmatamento,
			-- attribute = "maximum_0",
			-- select = 0
		-- }		

		-- local rpercentLayerName = clName1.."_Percentage_Raster"
		-- local filePath19 = rpercentLayerName..".shp"

		-- if isFile(filePath19) then
			-- rmFile(filePath19)
		-- end	
		
		-- cl:fill{
			-- operation = "coverage",
			-- layer = desmatamento,
			-- attribute = "percent_0",
			-- select = 0
		-- }		

		-- local rstdevLayerName = clName1.."_Stdev_Raster"
		-- local filePath20 = rstdevLayerName..".shp"

		-- if isFile(filePath20) then
			-- rmFile(filePath20)
		-- end	
		
		-- cl:fill{
			-- operation = "stdev",
			-- layer = desmatamento,
			-- attribute = "stdev_0",
			-- select = 0
		-- }		

		-- local rsumLayerName = clName1.."_Sum_Raster"
		-- local filePath21 = rstdevLayerName..".shp"

		-- if isFile(filePath21) then
			-- rmFile(filePath21)
		-- end
		
		-- cl:fill{
			-- operation = "sum",
			-- layer = desmatamento,
			-- attribute = "sum_0",
			-- select = 0
		-- }		

		local cs = CellularSpace{
			project = proj,
			layer = cl.name
		}
		
		forEachCell(cs, function(cell)
			cell.past_sum = cell.sum
			cell.sum = cell.sum + 10000
		end)		
		
		local cellSpaceLayerName = clName1.."_CellSpace_Sum"
		local filePath22 = cellSpaceLayerName..".shp"

		if isFile(filePath22) then
			rmFile(filePath22)
		end
		
		cs:save(cellSpaceLayerName, "past_sum")
		
		local cellSpaceLayer = Layer{
			project = proj,
			name = cellSpaceLayerName
		}

		unitTest:assertEquals(cellSpaceLayer.source, "shp")
		unitTest:assertEquals(cellSpaceLayer.file, _Gtme.makePathCompatibleToAllOS(currentDir().."/"..filePath22))					
		
		if isFile(projName) then
			rmFile(projName)
		end

		rmFile(filePath1)
--		rmFile(filePath3)
--		rmFile(filePath5)
		--rmFile(filePath16)
		--rmFile(filePath17)
		--rmFile(filePath18)
		--rmFile(filePath19)
		--rmFile(filePath20)
		--rmFile(filePath21)
		rmFile(filePath22)
	end,
	representation = function(unitTest)
		local projName = "cellular_layer_representation.tview"

		local proj = Project {
			file = projName,
			clean = true
		}		

		local layerName1 = "Setores_2000"
		local l = Layer{
			project = proj,
			name = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}	
		
		unitTest:assertEquals(l:representation(), "polygon")

		local localidades = "Localidades"
		l = Layer{
			project = proj,
			name = localidades,
			file = filePath("Localidades_pt.shp", "terralib")	
		}

		unitTest:assertEquals(l:representation(), "point")

		local rodovias = "Rodovias"
		l = Layer{
			project = proj,
			name = rodovias,
			file = filePath("Rodovias_lin.shp", "terralib")	
		}

		unitTest:assertEquals(l:representation(), "line")
		
		rmFile(proj.file)
	end,
	__tostring = function(unitTest)
		local projName = "cellular_layer_print.tview"

		local proj = Project {
			file = projName,
			clean = true
		}		

		local layerName1 = "Setores_2000"
		local l = Layer{
			project = proj,
			name = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}

		local expected = [[file     string [Setores_Censitarios_2000_pol.shp]
name     string [Setores_2000]
project  Project
rep      string [polygon]
sid      string [055e2e78-18d7-4246-9e03-dbe2277a7e77]
source   string [shp]
]]
		unitTest:assertEquals(tostring(l), expected, 36, true)
		-- unitTest:assertFile(projName) -- SKIP #1301
		rmFile(projName) -- #1301
	end
}

