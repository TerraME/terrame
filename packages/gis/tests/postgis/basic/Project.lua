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
	Project = function(unitTest)
		local version = ""
		local readQGisProject = function()
			local proj = Project{
				file = "project_pg_basic.tview",
				clean = true
			}

			local layerName = "Sampa"

			local l1 = Layer{
				project = proj,
				name = layerName,
				file = filePath("test/sampa.shp", "gis")
			}

			local password = "postgres"
			local database = "postgis_22_sample"

			local pgData = {
				source = "postgis",
				password = password,
				database = database,
				overwrite = true,
				progress = false
			}

			l1:export(pgData)

			local qgisproj
			if version == "_v3" then
				qgisproj = Project {
					file = filePath("test/sampapg"..version..".qgs", "gis"),
					user = "postgres",
					password = "postgres"
				}
			else
				qgisproj = Project {
					file = filePath("test/sampapg"..version..".qgs", "gis")
				}
			end

			local l2 = Layer{
				project = qgisproj,
				name = "SP"
			}

			unitTest:assertEquals(l2.source, "postgis")
			unitTest:assertEquals(l2.host, "localhost")
			unitTest:assertEquals(l2.port, "5432")
			unitTest:assertEquals(l2.user, "postgres")
			unitTest:assertEquals(l2.password, "postgres")
			unitTest:assertEquals(l2.database, "postgis_22_sample")
			unitTest:assertEquals(l2.table, "sampa")

			File("sampapg"..version..".tview"):delete()
			l2:delete()
			proj.file:delete()
		end

		local insertNewLayerQgis = function()
			local proj = Project{
				file = "project_pg_basic.tview",
				clean = true
			}

			local layerName = "Sampa"

			local l1 = Layer{
				project = proj,
				name = layerName,
				file = filePath("test/sampa.shp", "gis")
			}

			local password = "postgres"
			local database = "postgis_22_sample"

			local pgData = {
				source = "postgis",
				password = password,
				database = database,
				overwrite = true,
				progress = false
			}

			l1:export(pgData)

			local qgpfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")
			qgpfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = Project {
				file = "sampa_v3.qgs",
				user = "postgres",
				password = "postgres"
			}

			local l2 = Layer{
				project = qgp,
				source = "postgis",
				name = "LayerPG",
				password = "postgres",
				database = "postgis_22_sample",
				table = "sampa"
			}

			local qgp2 =  Project{
				file = "sampa_v3.qgs"
			}

			local l3 = Layer{
				project = qgp2,
				name = l2.name
			}

			unitTest:assertEquals(l3.source, "postgis")
			unitTest:assertEquals(l3.host, "localhost")
			unitTest:assertEquals(l3.port, "5432")
			unitTest:assertEquals(l3.user, "postgres")
			unitTest:assertEquals(l3.password, "postgres")
			unitTest:assertEquals(l3.database, "postgis_22_sample")
			unitTest:assertEquals(l3.table, "sampa")

			qgp.file:delete()
			l3:delete()
			File("sampa_v3.tview"):delete()
			File("sampa.shp"):delete()
			proj.file:delete()
		end

		unitTest:assert(readQGisProject)
		version = "_v3"
		unitTest:assert(readQGisProject)
		unitTest:assert(insertNewLayerQgis)
	end
}
