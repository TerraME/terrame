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
		
		if isFile(filePath1) then
			rmFile(filePath1)
		end
		
		local clName1 = "Sampa_Cells"
		
		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
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
	
		unitTest:assertFile(projName)
		
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
		
		layerName1 = "Sampa"
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
		
		unitTest:assertFile(projName)
		
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

		if isFile(projName) then
			rmFile(projName)
		end		

		if isFile(filePath1) then rmFile(filePath1) end
		if isFile(filePath2) then rmFile(filePath2) end
		if isFile(filePath3) then rmFile(filePath3) end
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
		
		local presenceLayerName = clName1.."_Presence"
		local filePath2 = presenceLayerName..".shp"

		if isFile(filePath2) then
			rmFile(filePath2)
		end

		cl:fill{
			operation = "presence",
			layer = localidades,
			attribute = "presence",
			output = presenceLayerName
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
			attribute = "area",
			output = areaLayerName
		}
--]]
		local countLayerName = clName1.."_Count"
		local filePath4 = countLayerName..".shp"
		
		if isFile(filePath4) then
			rmFile(filePath4)
		end
		
		cl:fill{
			operation = "count",
			layer = localidades,
			attribute = "count",
			output = countLayerName
		}
		
		-- local distanceLayerName = clName1.."_Distance"
		-- local filePath5 = distanceLayerName..".shp"
		
		-- if isFile(filePath5) then
			-- rmFile(filePath5)
		-- end	
		
		-- cl:fill{
			-- operation = "distance",
			-- layer = localidades,
			-- attribute = "distance",
			-- output = distanceLayerName
		-- }
		
		local minValueLayerName = clName1.."_Minimum"		
		local filePath6 = minValueLayerName..".shp"
		
		if isFile(filePath6) then
			rmFile(filePath6)
		end
		
		cl:fill{
			operation = "minimum",
			layer = localidades,
			attribute = "minimum",
			output = minValueLayerName,
			select = "UCS_FATURA"
		}
		
		local maxValueLayerName = clName1.."_Maximum"
		local filePath7 = maxValueLayerName..".shp"
		
		if isFile(filePath7) then
			rmFile(filePath7)
		end
		
		cl:fill{
			operation = "maximum",
			layer = localidades,
			attribute = "maximum",
			output = maxValueLayerName,
			select = "UCS_FATURA"
		}
		
		local coverageLayerName = clName1.."_Percentage"
		local filePath8 = coverageLayerName..".shp"
		
		if isFile(filePath8) then
			rmFile(filePath8)
		end	
	--[[	
		cl:fill{
			operation = "coverage",
			layer = localidades,
			attribute = "coverage",
			output = coverageLayerName,
			select = "LOCALIDADE"
		}
		--]]
		local stdevLayerName = clName1.."_Stdev"
		local filePath9 = stdevLayerName..".shp"

		if isFile(filePath9) then
			rmFile(filePath9)
		end
		
		cl:fill{
			operation = "stdev",
			layer = localidades,
			attribute = "stdev",
			output = stdevLayerName,
			select = "UCS_FATURA"
		}
		
		local meanLayerName = clName1.."_Average_Mean"
		local filePath10 = meanLayerName..".shp"

		if isFile(filePath10) then
			rmFile(filePath10)
		end
		
		cl:fill{
			operation = "average",
			layer = localidades,
			attribute = "mean",
			output = meanLayerName,
			select = "UCS_FATURA"
		}
		
		local weighLayerName = clName1.."_Average_Weighted"
		local filePath11 = weighLayerName..".shp"

		if isFile(filePath11) then
			rmFile(filePath11)
		end
		
		cl:fill{
			operation = "average",
			layer = localidades,
			attribute = "weighted",
			output = weighLayerName,
			select = "UCS_FATURA"
		}
		
		local intersecLayerName = clName1.."_Mojority_Intersection"
		local filePath12 = intersecLayerName..".shp"

		if isFile(filePath12) then
			rmFile(filePath12)
		end

		cl:fill{
			operation = "mode",
			layer = localidades,
			attribute = "high_inter",
			output = intersecLayerName,
			select = "UCS_FATURA"
		}
		
		local occurrenceLayerName = clName1.."_Mojority_Occurrence"
		local filePath13 = occurrenceLayerName..".shp"

		if isFile(filePath13) then
			rmFile(filePath13)
		end

		cl:fill{
			operation = "mode",
			layer = localidades,
			attribute = "high_occur",
			output = occurrenceLayerName,
			select = "UCS_FATURA"
		}
		
		local sumLayerName = clName1.."_Sum"
		local filePath14 = sumLayerName..".shp"

		if isFile(filePath14) then
			rmFile(filePath14)
		end
		
		cl:fill{
			operation = "sum",
			layer = localidades,
			attribute = "sum",
			output = sumLayerName,
			select = "UCS_FATURA"
		}
		
		local wsumLayerName = clName1.."_Weighted_Sum"
		local filePath15 = wsumLayerName..".shp"

		if isFile(filePath15) then
			rmFile(filePath15)
		end	
		
		cl:fill{
			operation = "sum",
			layer = localidades,
			attribute = "wsum",
			output = wsumLayerName,
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
			-- output = rmeanLayerName,
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
			-- output = rminLayerName,
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
			-- output = rmaxLayerName,
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
			-- output = rpercentLayerName,
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
			-- output = rstdevLayerName,
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
			-- output = rsumLayerName,
			-- select = 0
		-- }		

		local cs = CellularSpace{
			project = proj,
			layer = sumLayerName
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

		if isFile(filePath1)  then rmFile(filePath1)  end
		if isFile(filePath2)  then rmFile(filePath2)  end
--		if isFile(filePath3)  then rmFile(filePath3)  end
		if isFile(filePath4)  then rmFile(filePath4)  end
		--if isFile(filePath5)  then rmFile(filePath5)  end
		if isFile(filePath6)  then rmFile(filePath6)  end
		if isFile(filePath7)  then rmFile(filePath7)  end
		if isFile(filePath8)  then rmFile(filePath8)  end
		if isFile(filePath9)  then rmFile(filePath9)  end
		if isFile(filePath10) then rmFile(filePath10) end
		if isFile(filePath11) then rmFile(filePath11) end
		if isFile(filePath12) then rmFile(filePath12) end
		if isFile(filePath13) then rmFile(filePath13) end
		if isFile(filePath14) then rmFile(filePath14) end
		if isFile(filePath15) then rmFile(filePath15) end
		--if isFile(filePath16) then rmFile(filePath16) end
		--if isFile(filePath17) then rmFile(filePath17) end
		--if isFile(filePath18) then rmFile(filePath18) end
		--if isFile(filePath19) then rmFile(filePath19) end
		--if isFile(filePath20) then rmFile(filePath20) end
		--if isFile(filePath21) then rmFile(filePath21) end
		if isFile(filePath22) then rmFile(filePath22) end
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
		
		unitTest:assertEquals(tostring(l), [[file     string [packages\terralib\data\Setores_Censitarios_2000
_pol.shp]
name     string [Setores_2000]
project  Project
rep      string [geometry]
sid      string [055e2e78-18d7-4246-9e03-dbe2277a7e77]
source   string [shp]
]], 80)
		unitTest:assertFile(projName)
	end
}

