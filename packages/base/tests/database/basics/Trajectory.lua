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

return{
	save = function(unitTest)
		-- WITH LAYER
		local gis = getPackage("gis")
		local projName = "trajectory_save_basic.tview"
		local author = "Avancini"
		local title = "Trajectory"

		local proj = gis.Project{
			file = projName,
			clean = true,
			author = author,
			title = title
		}

		local layerName1 = "Sampa"
		local layer1 = gis.Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local cs = CellularSpace{
			project = proj,
			layer = layerName1
		}

		unitTest:assertEquals(#cs, 63)

		local t1 = Trajectory{
			target = cs,
			select = function(cell)
				return cell.ID % 2 == 0
			end
		}

		unitTest:assertEquals(#t1, 34)

		local file2 = File("odd.shp")
		file2:deleteIfExists()

		t1:save(file2)

		local cs2 = CellularSpace{
			file = file2,
		}

		unitTest:assertEquals(#t1, #cs2)

		local layer2 = gis.Layer{
			project = proj,
			name = "Odd",
			file = file2
		}

		local attrs2 = layer2:attributes()
		unitTest:assertEquals(#attrs2, 4)
		unitTest:assertEquals(attrs2[1].name, "FID")
		unitTest:assertEquals(attrs2[2].name, "ID")
		unitTest:assertEquals(attrs2[3].name, "NM_MICRO")
		unitTest:assertEquals(attrs2[4].name, "CD_GEOCODU")

		local t2 = Trajectory{
			target = cs,
			select = function(cell)
				return cell.ID % 2 == 1
			end
		}

		unitTest:assertEquals(#t2, 29)

		local file3 = File("even.shp")
		file3:deleteIfExists()

		t2:save(file3, {"ID", "NM_MICRO"})

		local cs3 = CellularSpace{
			file = file3
		}

		unitTest:assertEquals(#t2, #cs3)

		local layer3 = gis.Layer{
			project = proj,
			name = "Even",
			file = file3
		}

		local attrs3 = layer3:attributes()
		unitTest:assertEquals(#attrs3, 3)
		unitTest:assertEquals(attrs3[1].name, "FID")
		unitTest:assertEquals(attrs3[2].name, "ID")
		unitTest:assertEquals(attrs3[3].name, "NM_MICRO")

		local pgData = {
			source = "postgis",
			password = getConfig().password,
			database = "postgis_22_sample",
			overwrite = true
		}

		layer1:export(pgData, true)

		local layerName2 = "SampaDB"
		local layer4 = gis.Layer{
			project = proj,
			source = "postgis",
			name = layerName2,
			password = getConfig().password,
			database = "postgis_22_sample",
			table = "sampa"
		}

		local cs7 = CellularSpace{
			project = proj,
			layer = layerName2
		}

		local t5 = Trajectory{
			target = cs7
		}

		local file6 = File("all.shp")
		t5:save(file6, {"id", "nm_micro"})

		local cs8 = CellularSpace{
			file = file6
		}

		unitTest:assertEquals(#cs7, #t5)
		unitTest:assertEquals(#cs8, #t5)

		local layer5 = gis.Layer{
			project = proj,
			name = "All",
			file = file6
		}

		local attrs4 = layer5:attributes()
		unitTest:assertEquals(#attrs4, 3)
		unitTest:assertEquals(attrs4[1].name, "FID")
		unitTest:assertEquals(attrs4[2].name, "id")
		unitTest:assertEquals(attrs4[3].name, "nm_micro")

		file2:delete()
		file3:delete()
		file6:delete()
		layer4:delete()
		proj.file:delete()

		-- WITHOUT LAYER
		local cs4 = CellularSpace{
			file = filePath("test/sampa.shp", "gis")
		}

		local t3 = Trajectory{
			target = cs4,
			select = function(cell)
				return cell.ID % 2 == 0
			end
		}

		unitTest:assertEquals(#t3, 34)

		local file4 = File("odd.shp")
		file4:deleteIfExists()

		t3:save(file4)

		local cs5 = CellularSpace{
			file = file4,
		}

		unitTest:assertEquals(#t3, #cs5)
		unitTest:assertEquals(cs5.cells[1].FID, 0)
		unitTest:assertEquals(cs5.cells[1].ID, 2)
		unitTest:assertEquals(cs5.cells[1].NM_MICRO, "VOTUPORANGA")
		unitTest:assertEquals(cs5.cells[1].CD_GEOCODU, "35")

		local t4 = Trajectory{
			target = cs4,
			select = function(cell)
				return cell.ID % 2 == 1
			end
		}

		unitTest:assertEquals(#t4, 29)

		local file5 = File("even.shp")
		file5:deleteIfExists()

		t4:save(file5, "ID")

		local cs6 = CellularSpace{
			file = file5,
		}

		unitTest:assertEquals(#t4, #cs6)
		unitTest:assertEquals(cs6.cells[1].FID, 0)
		unitTest:assertEquals(cs6.cells[1].ID, 11)
		unitTest:assertNil(cs6.cells[1].NM_MICRO)
		unitTest:assertNil(cs6.cells[1].CD_GEOCODU)

		file4:delete()
		file5:delete()
	end
}

