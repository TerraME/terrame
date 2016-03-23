return {
	CellularLayer = function(unitTest)
		local projName = "cellular_layer_basic.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local author = "Avancini"
		local title = "Cellular Layer"
	
		local proj = Project {
			file = projName,
			create = true,
			author = author,
			title = title
		}		

		local layerName1 = "Sampa"
		proj:addLayer {
			layer = layerName1,
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
				os.execute("rm -f "..f)
			end
		end			
		
		local clName1 = "Sampa_Cells"
		
		proj:addCellularLayer {
			source = "shp",
			input = layerName1,
			layer = clName1,
			resolution = 0.3,
			file = filePath1
		}	

		local cl = CellularLayer{
			project = proj,
			layer = clName1
		}		
		
		unitTest:assertEquals(projName, cl.project.file)
		unitTest:assertEquals(clName1, cl.layer)
		
		-- ###################### 2 #############################
		proj = nil
		local tl = TerraLib{}
		tl:finalize()
		
		local cl2 = CellularLayer{
			project = projName,
			layer = clName1
		}
		
		local clProj = cl2.project
		local clProjInfo = clProj:info()
		
		unitTest:assertEquals(clProjInfo.title, title)
		unitTest:assertEquals(clProjInfo.author, author)
		
		local clLayerInfo = clProj:infoLayer(clName1)
		unitTest:assertEquals(clLayerInfo.source, "shp")
		unitTest:assertEquals(clLayerInfo.file, filePath1)
	
		-- ###################### END #############################
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end		
		
		tl:finalize()		
	end,
	fillCells = function(unitTest)
		local projName = "cellular_layer_basic.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		local author = "Avancini"
		local title = "Cellular Layer"
	
		local proj = Project {
			file = projName,
			create = true,
			author = author,
			title = title
		}		

		local layerName1 = "Setores_2000"
		proj:addLayer {
			layer = layerName1,
			file = filePath("Setores_Censitarios_2000_pol.shp", "fillcell")
		}	
		
		local localidades = "Localidades"
		proj:addLayer {
			layer = localidades,
			file = filePath("Localidades_pt.shp", "fillcell")	
		}

		local rodovias = "Rodovias"
		proj:addLayer {
			layer = rodovias,
			file = filePath("Rodovias_lin.shp", "fillcell")	
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
				os.execute("rm -f "..f)
			end
		end			

		proj:addCellularLayer {
			source = "shp",
			input = layerName1,
			layer = clName1,
			resolution = 30000,
			file = filePath1
		}	
		
		local cellSpaceLayerInfo = proj:infoLayer(clName1)
		
		local cl = CellularLayer{
			project = proj,
			layer = clName1
		}		
		
		-- ###################### 1 #############################
		local presenceLayerName = clName1.."_Presence"

		local shp2 = presenceLayerName..".shp"
		local filePath2 = testDir.."/"..shp2	
		local fn2 = getFileName(filePath2)
		fn2 = testDir.."/"..fn2	
		
		for i = 1, #exts do
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end		

		cl:fillCells{
			operation = "presence",
			layer = localidades,
			attribute = "presence",
			output = presenceLayerName
		}	

		local presenceLayerInfo = proj:infoLayer(presenceLayerName)
		unitTest:assertEquals(presenceLayerInfo.source, "shp")
		unitTest:assertEquals(presenceLayerInfo.file, filePath2)			
		
		-- ###################### 2 #############################
		local areaLayerName = clName1.."_Area"
		
		local shp3 = areaLayerName..".shp"
		local filePath3 = testDir.."/"..shp3	
		local fn3 = getFileName(filePath3)
		fn3 = testDir.."/"..fn3	
		
		for i = 1, #exts do
			local f = fn3..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end		
		
		cl:fillCells{
			operation = "area",
			layer = localidades,
			attribute = "area",
			output = areaLayerName
		}

		local areaLayerInfo = proj:infoLayer(areaLayerName)
		unitTest:assertEquals(areaLayerInfo.source, "shp")
		unitTest:assertEquals(areaLayerInfo.file, filePath3)	

		-- ###################### 3 #############################	
		local countLayerName = clName1.."_Count"
		
		local shp4 = countLayerName..".shp"
		local filePath4 = testDir.."/"..shp4	
		local fn4 = getFileName(filePath4)
		fn4 = testDir.."/"..fn4	
		
		for i = 1, #exts do
			local f = fn4..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end			
		
		cl:fillCells{
			operation = "count",
			layer = localidades,
			attribute = "count",
			output = countLayerName
		}
		
		local countLayerInfo = proj:infoLayer(countLayerName)
		unitTest:assertEquals(countLayerInfo.source, "shp")
		unitTest:assertEquals(countLayerInfo.file, filePath4)	
		
		-- ###################### 4 #############################	
		-- local distanceLayerName = clName1.."_Distance"
		
		-- local shp5 = distanceLayerName..".shp"
		-- local filePath5 = testDir.."/"..shp5	
		-- local fn5 = getFileName(filePath5)
		-- fn5 = testDir.."/"..fn5	
		
		-- for i = 1, #exts do
			-- local f = fn5..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "distance",
			-- layer = localidades,
			-- attribute = "distance",
			-- output = distanceLayerName
		-- }
		
		-- local distanceLayerInfo = proj:infoLayer(distanceLayerName)
		-- unitTest:assertEquals(distanceLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(distanceLayerInfo.file, filePath5) -- SKIP

		-- ###################### 5 #############################	
		local minValueLayerName = clName1.."_Minimum"
		
		local shp6 = minValueLayerName..".shp"
		local filePath6 = testDir.."/"..shp6	
		local fn6 = getFileName(filePath6)
		fn6 = testDir.."/"..fn6	
		
		for i = 1, #exts do
			local f = fn6..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end		
		
		cl:fillCells{
			operation = "minimum",
			layer = localidades,
			attribute = "minimum",
			output = minValueLayerName,
			select = "UCS_FATURA"
		}
		
		local minValueLayerInfo = proj:infoLayer(minValueLayerName)	
		unitTest:assertEquals(minValueLayerInfo.source, "shp")
		unitTest:assertEquals(minValueLayerInfo.file, filePath6)

		-- ###################### 6 #############################	
		local maxValueLayerName = clName1.."_Maximum"
		
		local shp7 = maxValueLayerName..".shp"
		local filePath7 = testDir.."/"..shp7	
		local fn7 = getFileName(filePath7)
		fn7 = testDir.."/"..fn7	
		
		for i = 1, #exts do
			local f = fn7..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "maximum",
			layer = localidades,
			attribute = "maximum",
			output = maxValueLayerName,
			select = "UCS_FATURA"
		}
		
		local maxValueLayerInfo = proj:infoLayer(maxValueLayerName)	
		unitTest:assertEquals(maxValueLayerInfo.source, "shp")
		unitTest:assertEquals(maxValueLayerInfo.file, filePath7)	

		-- ###################### 7 #############################	
		local percentageLayerName = clName1.."_Percentage"
		
		local shp8 = percentageLayerName..".shp"
		local filePath8 = testDir.."/"..shp8	
		local fn8 = getFileName(filePath8)
		fn8 = testDir.."/"..fn8	
		
		for i = 1, #exts do
			local f = fn8..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end	
		
		cl:fillCells{
			operation = "percentage",
			layer = localidades,
			attribute = "percentage",
			output = percentageLayerName,
			select = "LOCALIDADE"
		}
		
		local percentageLayerInfo = proj:infoLayer(percentageLayerName)	
		unitTest:assertEquals(percentageLayerInfo.source, "shp")
		unitTest:assertEquals(percentageLayerInfo.file, filePath8)	

		-- ###################### 8 #############################	
		local stdevLayerName = clName1.."_Stdev"
		
		local shp9 = stdevLayerName..".shp"
		local filePath9 = testDir.."/"..shp9	
		local fn9 = getFileName(filePath9)
		fn9 = testDir.."/"..fn9	
		
		for i = 1, #exts do
			local f = fn9..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "stdev",
			layer = localidades,
			attribute = "stdev",
			output = stdevLayerName,
			select = "UCS_FATURA"
		}
		
		local stdevLayerInfo = proj:infoLayer(stdevLayerName)	
		unitTest:assertEquals(stdevLayerInfo.source, "shp")
		unitTest:assertEquals(stdevLayerInfo.file, filePath9)	

		-- ###################### 9 #############################	
		local meanLayerName = clName1.."_Average_Mean"
		
		local shp10 = meanLayerName..".shp"
		local filePath10 = testDir.."/"..shp10	
		local fn10 = getFileName(filePath10)
		fn10 = testDir.."/"..fn10	
		
		for i = 1, #exts do
			local f = fn10..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "average",
			layer = localidades,
			attribute = "mean",
			output = meanLayerName,
			select = "UCS_FATURA"
		}
		
		local meanLayerInfo = proj:infoLayer(meanLayerName)		
		unitTest:assertEquals(meanLayerInfo.source, "shp")
		unitTest:assertEquals(meanLayerInfo.file, filePath10)	
		
		-- ###################### 10 #############################	
		local weighLayerName = clName1.."_Average_Weighted"
		
		local shp11 = weighLayerName..".shp"
		local filePath11 = testDir.."/"..shp11	
		local fn11 = getFileName(filePath11)
		fn11 = testDir.."/"..fn11	
		
		for i = 1, #exts do
			local f = fn11..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "average",
			layer = localidades,
			attribute = "weighted",
			output = weighLayerName,
			select = "UCS_FATURA",
			area = true
		}
		
		local weighLayerInfo = proj:infoLayer(weighLayerName)	
		unitTest:assertEquals(weighLayerInfo.source, "shp")
		unitTest:assertEquals(weighLayerInfo.file, filePath11)	
		
		-- ###################### 11 #############################	
		local intersecLayerName = clName1.."_Mojority_Intersection"
		
		local shp12 = intersecLayerName..".shp"
		local filePath12 = testDir.."/"..shp12	
		local fn12 = getFileName(filePath12)
		fn12 = testDir.."/"..fn12	
		
		for i = 1, #exts do
			local f = fn12..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "majority",
			layer = localidades,
			attribute = "high_inter",
			output = intersecLayerName,
			select = "UCS_FATURA",
			area = true
		}
		
		local intersecLayerInfo = proj:infoLayer(intersecLayerName)	
		unitTest:assertEquals(intersecLayerInfo.source, "shp")
		unitTest:assertEquals(intersecLayerInfo.file, filePath12)		

		-- ###################### 12 #############################	
		local occurrenceLayerName = clName1.."_Mojority_Occurrence"
		
		local shp13 = occurrenceLayerName..".shp"
		local filePath13 = testDir.."/"..shp13	
		local fn13 = getFileName(filePath13)
		fn13 = testDir.."/"..fn13	
		
		for i = 1, #exts do
			local f = fn13..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "majority",
			layer = localidades,
			attribute = "high_occur",
			output = occurrenceLayerName,
			select = "UCS_FATURA"
		}
		
		local occurrenceLayerInfo = proj:infoLayer(occurrenceLayerName)	
		unitTest:assertEquals(occurrenceLayerInfo.source, "shp")
		unitTest:assertEquals(occurrenceLayerInfo.file, filePath13)		

		-- ###################### 13 #############################	
		local sumLayerName = clName1.."_Sum"
		
		local shp14 = sumLayerName..".shp"
		local filePath14 = testDir.."/"..shp14	
		local fn14 = getFileName(filePath14)
		fn14 = testDir.."/"..fn14	
		
		for i = 1, #exts do
			local f = fn14..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end
		
		cl:fillCells{
			operation = "sum",
			layer = localidades,
			attribute = "sum",
			output = sumLayerName,
			select = "UCS_FATURA"
		}
		
		local sumLayerInfo = proj:infoLayer(sumLayerName)
		unitTest:assertEquals(sumLayerInfo.source, "shp")
		unitTest:assertEquals(sumLayerInfo.file, filePath14)	

		-- ###################### 14 #############################	
		local wsumLayerName = clName1.."_Weighted_Sum"
		
		local shp15 = wsumLayerName..".shp"
		local filePath15 = testDir.."/"..shp15	
		local fn15 = getFileName(filePath15)
		fn15 = testDir.."/"..fn15	
		
		for i = 1, #exts do
			local f = fn15..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
		end	
		
		cl:fillCells{
			operation = "sum",
			layer = localidades,
			attribute = "wsum",
			output = wsumLayerName,
			select = "UCS_FATURA",
			area = true
		}
		
		local wsumLayerInfo = proj:infoLayer(wsumLayerName)	
		unitTest:assertEquals(wsumLayerInfo.source, "shp")
		unitTest:assertEquals(wsumLayerInfo.file, filePath15)	

		-- RASTER TESTS ------------------------------------------	issue #928
		-- local desmatamento = "Desmatamento"
		-- proj:addLayer {
			-- layer = desmatamento,
			-- file = filePath("Desmatamento_2000.tif", "fillcell")		
		-- }	
		
		-- -- ###################### 15 #############################
		-- local rmeanLayerName = clName1.."_Mean_Raster"
		
		-- local shp16 = rmeanLayerName..".shp"
		-- local filePath16 = testDir.."/"..shp16	
		-- local fn16 = getFileName(filePath16)
		-- fn16 = testDir.."/"..fn16	
		
		-- for i = 1, #exts do
			-- local f = fn16..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "average",
			-- layer = desmatamento,
			-- attribute = "mean_0",
			-- output = rmeanLayerName,
			-- select = 0
		-- }		
		
		-- local rmeanLayerInfo = proj:infoLayer(rmeanLayerName)
		-- unitTest:assertEquals(rmeanLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rmeanLayerInfo.file, filePath16) -- SKIP		

		-- -- ###################### 16 #############################
		-- local rminLayerName = clName1.."_Minimum_Raster"
		
		-- local shp17 = rminLayerName..".shp"
		-- local filePath17 = testDir.."/"..shp17	
		-- local fn17 = getFileName(filePath17)
		-- fn17 = testDir.."/"..fn17	
		
		-- for i = 1, #exts do
			-- local f = fn17..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "minimum",
			-- layer = desmatamento,
			-- attribute = "minimum_0",
			-- output = rminLayerName,
			-- select = 0
		-- }		

		-- local rminLayerInfo = proj:infoLayer(rminLayerName)		
		-- unitTest:assertEquals(rminLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rminLayerInfo.file, filePath17) -- SKIP	
		
		-- -- ###################### 17 #############################
		-- local rmaxLayerName = clName1.."_Maximum_Raster"
		
		-- local shp18 = rmaxLayerName..".shp"
		-- local filePath18 = testDir.."/"..shp18	
		-- local fn18 = getFileName(filePath18)
		-- fn18 = testDir.."/"..fn18	
		
		-- for i = 1, #exts do
			-- local f = fn18..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "maximum",
			-- layer = desmatamento,
			-- attribute = "maximum_0",
			-- output = rmaxLayerName,
			-- select = 0
		-- }		

		-- local rmaxLayerInfo = proj:infoLayer(rmaxLayerName)		
		-- unitTest:assertEquals(rmaxLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rmaxLayerInfo.file, filePath18) -- SKIP

		-- -- ###################### 18 #############################
		-- local rpercentLayerName = clName1.."_Percentage_Raster"
		
		-- local shp19 = rpercentLayerName..".shp"
		-- local filePath19 = testDir.."/"..shp19	
		-- local fn19 = getFileName(filePath19)
		-- fn19 = testDir.."/"..fn19	
		
		-- for i = 1, #exts do
			-- local f = fn19..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "percentage",
			-- layer = desmatamento,
			-- attribute = "percent_0",
			-- output = rpercentLayerName,
			-- select = 0
		-- }		

		-- local rpercentLayerInfo = proj:infoLayer(rpercentLayerName)	
		-- unitTest:assertEquals(rmaxLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rmaxLayerInfo.file, filePath19) -- SKIP

		-- -- ###################### 19 #############################
		-- local rstdevLayerName = clName1.."_Stdev_Raster"
		
		-- local shp20 = rstdevLayerName..".shp"
		-- local filePath20 = testDir.."/"..shp20	
		-- local fn20 = getFileName(filePath20)
		-- fn20 = testDir.."/"..fn20	
		
		-- for i = 1, #exts do
			-- local f = fn20..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "stdev",
			-- layer = desmatamento,
			-- attribute = "stdev_0",
			-- output = rstdevLayerName,
			-- select = 0
		-- }		

		-- local rstdevLayerInfo = proj:infoLayer(rstdevLayerName)
		-- unitTest:assertEquals(rmaxLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rmaxLayerInfo.file, filePath20) -- SKIP

		-- -- ###################### 20 #############################
		-- local rsumLayerName = clName1.."_Sum_Raster"
		
		-- local shp21 = rstdevLayerName..".shp"
		-- local filePath21 = testDir.."/"..shp21	
		-- local fn21 = getFileName(filePath21)
		-- fn21 = testDir.."/"..fn21	
		
		-- for i = 1, #exts do
			-- local f = fn21..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
		-- end	
		
		-- cl:fillCells{
			-- operation = "sum",
			-- layer = desmatamento,
			-- attribute = "sum_0",
			-- output = rsumLayerName,
			-- select = 0
		-- }		

		-- local rsumLayerInfo = proj:infoLayer(rsumLayerName)
		-- unitTest:assertEquals(rmaxLayerInfo.source, "shp") -- SKIP
		-- unitTest:assertEquals(rmaxLayerInfo.file, filePath21) -- SKIP	

		-- CELLULAR SPACE TESTS ---------------------------------------------------
		-- ###################### 21 #############################
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
				os.execute("rm -f "..f)
			end
		end	
		
		cs:save(cellSpaceLayerName, "past_sum")
		
		local cellSpaceLayerInfo = proj:infoLayer(cellSpaceLayerName)	
		unitTest:assertEquals(cellSpaceLayerInfo.source, "shp")
		unitTest:assertEquals(cellSpaceLayerInfo.file, filePath22)			
		
		-- ###################### END #############################
		local tl = TerraLib{}
		tl:finalize()			
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		for i = 1, #exts do
			local f = fn1..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end
			local f = fn2..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end		
			local f = fn3..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end		
			local f = fn4..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end	
			-- local f = fn5..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end
			local f = fn6..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end			
			local f = fn7..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn8..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn9..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn10..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn11..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn12..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn13..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			local f = fn14..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end					
			local f = fn15..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
			-- local f = fn16..exts[i] -- issue #928
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end		
			-- local f = fn17..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end				
			-- local f = fn18..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end				
			-- local f = fn19..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end				
			-- local f = fn20..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end				
			-- local f = fn21..exts[i]
			-- if isFile(f) then
				-- os.execute("rm -f "..f)
			-- end				
			local f = fn22..exts[i]
			if isFile(f) then
				os.execute("rm -f "..f)
			end				
		end			
	end
}