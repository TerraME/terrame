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
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = "setores_cells.shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
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
		
		proj = nil
		
		local cl2 = Layer{
			project = projName,
			name = clName1
		}
		
		local clProj = cl2.project
		
		unitTest:assertEquals(cl2.source, "shp")
		unitTest:assertEquals(cl2.file, filePath1)
	
		unitTest:assertFile(projName)
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end

		local projName = "setores_2000.tview"

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
		
		unitTest:assertFile(projName)
		
		local projName = "cells_setores_2000.tview"

		local proj = Project {
			file = projName,
			clean = true
		}		

		local layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("sampa.shp", "terralib")
		}
		
		local layerName2 = "MG"
		Layer{
			project = proj,
			name = layerName2,
			file = filePath("MG_cities.shp", "terralib")	
		}

		local layerName3 = "CBERS"
		Layer{
			project = proj,
			name = layerName3,
			file = filePath("cbers_rgb342_crop1.tif", "terralib")		
		}		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		local shp1 = "sampa_cells.shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		local clName1 = "Sampa_Cells"
		local l1 = Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			file = filePath1
		}
		
		unitTest:assertEquals(l1.name, clName1)
		
		local shp2 = "mg_cells.shp"
		local filePath2 = testDir.."/"..shp2	
		local fn2 = getFileName(filePath2)
		fn2 = testDir.."/"..fn2	
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				rmFile(f)
			end
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
		
		local shp3 = "another_sampa_cells.shp"
		local filePath3 = testDir.."/"..shp3	
		local fn3 = getFileName(filePath3)
		fn3 = testDir.."/"..fn3	
		
		for i = 1, #exts do
			local f = fn3..exts[i]
			if isFile(f) then
				rmFile(f)
			end
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
		
		for i = 1, #exts do
			local f1 = fn1..exts[i]
			local f2 = fn2..exts[i]
			local f3 = fn3..exts[i]
			if isFile(f1) then
				rmFile(f1)
			end
			if isFile(f2) then
				rmFile(f2)
			end
			if isFile(f3) then
				rmFile(f3)
			end				
		end
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}		

		local layerName1 = "Setores_2000"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
		}	
		
		local localidades = "Localidades"
		Layer{
			project = proj,
			name = localidades,
			file = filePath("Localidades_pt.shp", "terralib")	
		}

		local rodovias = "Rodovias"
		Layer{
			project = proj,
			name = rodovias,
			file = filePath("Rodovias_lin.shp", "terralib")	
		}		
		
		local testDir = _Gtme.makePathCompatibleToAllOS(currentDir())
		
		local clName1 = "Setores_Cells"
		local shp1 = clName1..".shp"
		local filePath1 = testDir.."/"..shp1	
		local fn1 = getFileName(filePath1)
		fn1 = testDir.."/"..fn1	

		local exts = {".dbf", ".prj", ".shp", ".shx"}
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
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

		local shp2 = presenceLayerName..".shp"
		local filePath2 = testDir.."/"..shp2	
		local fn2 = getFileName(filePath2)
		fn2 = testDir.."/"..fn2	
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end		

		cl:fill{
			operation = "presence",
			name = localidades,
			attribute = "presence",
			output = presenceLayerName
		}	

		local areaLayerName = clName1.."_Area"
		
		local shp3 = areaLayerName..".shp"
		local filePath3 = testDir.."/"..shp3	
		local fn3 = getFileName(filePath3)
		fn3 = testDir.."/"..fn3	
		
		for i = 1, #exts do
			local f = fn3..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end		
		
		cl:fill{
			operation = "area",
			name = localidades,
			attribute = "area",
			output = areaLayerName
		}


		local countLayerName = clName1.."_Count"
		
		local shp4 = countLayerName..".shp"
		local filePath4 = testDir.."/"..shp4	
		local fn4 = getFileName(filePath4)
		fn4 = testDir.."/"..fn4	
		
		for i = 1, #exts do
			local f = fn4..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end			
		
		cl:fill{
			operation = "count",
			name = localidades,
			attribute = "count",
			output = countLayerName
		}
		
		
		-- local distanceLayerName = clName1.."_Distance"
		
		-- local shp5 = distanceLayerName..".shp"
		-- local filePath5 = testDir.."/"..shp5	
		-- local fn5 = getFileName(filePath5)
		-- fn5 = testDir.."/"..fn5	
		
		-- for i = 1, #exts do
			-- local f = fn5..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "distance",
			-- name = localidades,
			-- attribute = "distance",
			-- output = distanceLayerName
		-- }
		
		local minValueLayerName = clName1.."_Minimum"
		
		local shp6 = minValueLayerName..".shp"
		local filePath6 = testDir.."/"..shp6	
		local fn6 = getFileName(filePath6)
		fn6 = testDir.."/"..fn6	
		
		for i = 1, #exts do
			local f = fn6..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end		
		
		cl:fill{
			operation = "minimum",
			name = localidades,
			attribute = "minimum",
			output = minValueLayerName,
			select = "UCS_FATURA"
		}
		
		local maxValueLayerName = clName1.."_Maximum"
		
		local shp7 = maxValueLayerName..".shp"
		local filePath7 = testDir.."/"..shp7	
		local fn7 = getFileName(filePath7)
		fn7 = testDir.."/"..fn7	
		
		for i = 1, #exts do
			local f = fn7..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "maximum",
			name = localidades,
			attribute = "maximum",
			output = maxValueLayerName,
			select = "UCS_FATURA"
		}
		
		local coverageLayerName = clName1.."_Percentage"
		
		local shp8 = coverageLayerName..".shp"
		local filePath8 = testDir.."/"..shp8	
		local fn8 = getFileName(filePath8)
		fn8 = testDir.."/"..fn8	
		
		for i = 1, #exts do
			local f = fn8..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		cl:fill{
			operation = "coverage",
			name = localidades,
			attribute = "coverage",
			output = coverageLayerName,
			select = "LOCALIDADE"
		}
		
		local stdevLayerName = clName1.."_Stdev"
		
		local shp9 = stdevLayerName..".shp"
		local filePath9 = testDir.."/"..shp9	
		local fn9 = getFileName(filePath9)
		fn9 = testDir.."/"..fn9	
		
		for i = 1, #exts do
			local f = fn9..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "stdev",
			name = localidades,
			attribute = "stdev",
			output = stdevLayerName,
			select = "UCS_FATURA"
		}
		
		local meanLayerName = clName1.."_Average_Mean"
		
		local shp10 = meanLayerName..".shp"
		local filePath10 = testDir.."/"..shp10	
		local fn10 = getFileName(filePath10)
		fn10 = testDir.."/"..fn10	
		
		for i = 1, #exts do
			local f = fn10..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "average",
			name = localidades,
			attribute = "mean",
			output = meanLayerName,
			select = "UCS_FATURA"
		}
		
		local weighLayerName = clName1.."_Average_Weighted"
		
		local shp11 = weighLayerName..".shp"
		local filePath11 = testDir.."/"..shp11	
		local fn11 = getFileName(filePath11)
		fn11 = testDir.."/"..fn11	
		
		for i = 1, #exts do
			local f = fn11..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "average",
			name = localidades,
			attribute = "weighted",
			output = weighLayerName,
			select = "UCS_FATURA",
			area = true
		}
		
		local intersecLayerName = clName1.."_Mojority_Intersection"
		
		local shp12 = intersecLayerName..".shp"
		local filePath12 = testDir.."/"..shp12	
		local fn12 = getFileName(filePath12)
		fn12 = testDir.."/"..fn12	
		
		for i = 1, #exts do
			local f = fn12..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "mode",
			name = localidades,
			attribute = "high_inter",
			output = intersecLayerName,
			select = "UCS_FATURA",
			area = true
		}
		
		local occurrenceLayerName = clName1.."_Mojority_Occurrence"
		
		local shp13 = occurrenceLayerName..".shp"
		local filePath13 = testDir.."/"..shp13	
		local fn13 = getFileName(filePath13)
		fn13 = testDir.."/"..fn13	
		
		for i = 1, #exts do
			local f = fn13..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "mode",
			name = localidades,
			attribute = "high_occur",
			output = occurrenceLayerName,
			select = "UCS_FATURA"
		}
		
		local sumLayerName = clName1.."_Sum"
		
		local shp14 = sumLayerName..".shp"
		local filePath14 = testDir.."/"..shp14	
		local fn14 = getFileName(filePath14)
		fn14 = testDir.."/"..fn14	
		
		for i = 1, #exts do
			local f = fn14..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end
		
		cl:fill{
			operation = "sum",
			name = localidades,
			attribute = "sum",
			output = sumLayerName,
			select = "UCS_FATURA"
		}
		
		local wsumLayerName = clName1.."_Weighted_Sum"
		
		local shp15 = wsumLayerName..".shp"
		local filePath15 = testDir.."/"..shp15	
		local fn15 = getFileName(filePath15)
		fn15 = testDir.."/"..fn15	
		
		for i = 1, #exts do
			local f = fn15..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		cl:fill{
			operation = "sum",
			name = localidades,
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
		
		-- local shp16 = rmeanLayerName..".shp"
		-- local filePath16 = testDir.."/"..shp16	
		-- local fn16 = getFileName(filePath16)
		-- fn16 = testDir.."/"..fn16	
		
		-- for i = 1, #exts do
			-- local f = fn16..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "average",
			-- name = desmatamento,
			-- attribute = "mean_0",
			-- output = rmeanLayerName,
			-- select = 0
		-- }		
		
		-- local rminLayerName = clName1.."_Minimum_Raster"
		
		-- local shp17 = rminLayerName..".shp"
		-- local filePath17 = testDir.."/"..shp17	
		-- local fn17 = getFileName(filePath17)
		-- fn17 = testDir.."/"..fn17	
		
		-- for i = 1, #exts do
			-- local f = fn17..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "minimum",
			-- name = desmatamento,
			-- attribute = "minimum_0",
			-- output = rminLayerName,
			-- select = 0
		-- }		

		-- local rmaxLayerName = clName1.."_Maximum_Raster"
		
		-- local shp18 = rmaxLayerName..".shp"
		-- local filePath18 = testDir.."/"..shp18	
		-- local fn18 = getFileName(filePath18)
		-- fn18 = testDir.."/"..fn18	
		
		-- for i = 1, #exts do
			-- local f = fn18..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "maximum",
			-- name = desmatamento,
			-- attribute = "maximum_0",
			-- output = rmaxLayerName,
			-- select = 0
		-- }		

		-- local rpercentLayerName = clName1.."_Percentage_Raster"
		
		-- local shp19 = rpercentLayerName..".shp"
		-- local filePath19 = testDir.."/"..shp19	
		-- local fn19 = getFileName(filePath19)
		-- fn19 = testDir.."/"..fn19	
		
		-- for i = 1, #exts do
			-- local f = fn19..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "coverage",
			-- name = desmatamento,
			-- attribute = "percent_0",
			-- output = rpercentLayerName,
			-- select = 0
		-- }		

		-- local rstdevLayerName = clName1.."_Stdev_Raster"
		
		-- local shp20 = rstdevLayerName..".shp"
		-- local filePath20 = testDir.."/"..shp20	
		-- local fn20 = getFileName(filePath20)
		-- fn20 = testDir.."/"..fn20	
		
		-- for i = 1, #exts do
			-- local f = fn20..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "stdev",
			-- name = desmatamento,
			-- attribute = "stdev_0",
			-- output = rstdevLayerName,
			-- select = 0
		-- }		

		-- local rsumLayerName = clName1.."_Sum_Raster"
		
		-- local shp21 = rstdevLayerName..".shp"
		-- local filePath21 = testDir.."/"..shp21	
		-- local fn21 = getFileName(filePath21)
		-- fn21 = testDir.."/"..fn21	
		
		-- for i = 1, #exts do
			-- local f = fn21..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
		-- end	
		
		-- cl:fill{
			-- operation = "sum",
			-- name = desmatamento,
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

		local shp22 = cellSpaceLayerName..".shp"
		local filePath22 = testDir.."/"..shp22	
		local fn22 = getFileName(filePath22)
		fn22 = testDir.."/"..fn22	
		
		for i = 1, #exts do
			local f = fn22..exts[i]
			if isFile(f) then
				rmFile(f)
			end
		end	
		
		cs:save(cellSpaceLayerName, "past_sum")
		
		local cellSpaceLayer = Layer{
			project = proj,
			name = cellSpaceLayerName
		}

		unitTest:assertEquals(cellSpaceLayer.source, "shp")
		unitTest:assertEquals(cellSpaceLayer.file, filePath22)			
		
		local tl = TerraLib{}
		tl:finalize()			
		
		if isFile(projName) then
			rmFile(projName)
		end
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				rmFile(f)
			end
			local f = fn2..exts[i]
			if isFile(f) then
				rmFile(f)
			end		
			local f = fn3..exts[i]
			if isFile(f) then
				rmFile(f)
			end		
			local f = fn4..exts[i]
			if isFile(f) then
				rmFile(f)
			end	
			-- local f = fn5..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end
			local f = fn6..exts[i]
			if isFile(f) then
				rmFile(f)
			end			
			local f = fn7..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn8..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn9..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn10..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn11..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn12..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn13..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			local f = fn14..exts[i]
			if isFile(f) then
				rmFile(f)
			end					
			local f = fn15..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
			-- local f = fn16..exts[i] -- issue #928
			-- if isFile(f) then
				-- rmFile(f)
			-- end		
			-- local f = fn17..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end				
			-- local f = fn18..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end				
			-- local f = fn19..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end				
			-- local f = fn20..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end				
			-- local f = fn21..exts[i]
			-- if isFile(f) then
				-- rmFile(f)
			-- end				
			local f = fn22..exts[i]
			if isFile(f) then
				rmFile(f)
			end				
		end			
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
]], 60)
		unitTest:assertFile(projName)
	end
}
