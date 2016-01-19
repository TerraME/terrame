-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Avancini
-------------------------------------------------------------------------------------------

return {
	addLayer = function(unitTest)
		local projName = "sampa_basic.tview"

		if isFile(projName) then
			os.execute("rm -f "..projName)
		end
		
		-- ###################### 1 #############################
		local proj1 = Project {
			file = projName,
			create = true,
			author = "Avancini",
			title = "SAMPA"
		}		

		local layerName1 = "Sampa"
		proj1:addLayer {
			layer = layerName1,
			file = file("sampa.shp", "fillcell")
		}
		local layer1 = proj1:infoLayer(layerName1)
		unitTest:assertEquals(layer1.name, layerName1)	
		
		local host = "localhost"
		local port = "5432"
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding = "CP1252"
		local tableName = "sampa"
		
		local data = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tableName, -- USED ONLY TO DROP
			encoding = encoding
			
		}
		
		-- USED ONLY TO TESTS
		local tl = TerraLib{}
		tl:copyLayer(proj1, layerName1, data)
		
		local layerName2 = "SampaDB"	
		
		proj1:addLayer {
			source = "postgis",
			layer = layerName2,
			-- host = host,
			-- port = port,
			user = user,
			password = password,
			database = database,
			table = tableName			
		}	
		local layer2 = proj1:infoLayer(layerName2)
		unitTest:assertEquals(layer2.name, layerName2)	

		-- ###################### 2 #############################
		local layerName3 = "Another_SampaDB" 
		proj1:addLayer {
			source = "postgis",
			layer = layerName3,
			-- host = host,
			-- port = port,
			user = user,
			password = password,
			database = database,
			table = tableName			
		}		
		local layer3 = proj1:infoLayer(layerName3)
		unitTest:assert(layer3.name ~= layer2.name)
		unitTest:assertEquals(layer3.sid, layer2.sid)
		
		tl:dropPgTable(data)
		
		if isFile(projName) then
			os.execute("rm -f "..projName)
		end		
	end
}