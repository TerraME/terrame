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
		local file = File("amazonia.tview")

		local proj1 = Project{
			file = tostring(file),
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}

		unitTest:assertType(proj1, "Project")
		unitTest:assertEquals(proj1.file, file)

		local proj2 = Project{
			file = tostring(file)
		}

		unitTest:assertEquals(proj1.author, proj2.author)
		unitTest:assertEquals(proj1.title, proj2.title)
		unitTest:assertEquals(proj1.file, proj2.file)

		local proj3 = Project{
			file = file:name()
		}

		unitTest:assertEquals(proj1.author, proj3.author)
		unitTest:assertEquals(proj1.title, proj3.title)
		unitTest:assertEquals(proj3.file, File("amazonia.tview"))

		local proj3clean = Project{
			file = file:name(),
			clean = true
		}

		unitTest:assertEquals("No author", proj3clean.author)
		unitTest:assertEquals("No title", proj3clean.title)
		unitTest:assertEquals(proj3clean.file, File("amazonia.tview"))

		file:deleteIfExists()

		file = File("notitlenoauthor.tview")
		file:deleteIfExists()

		local proj4 = Project{
			file = file:name(true)
		}

		unitTest:assertEquals(proj4.title, "No title")
		unitTest:assertEquals(proj4.author, "No author")
		unitTest:assert(not proj4.clean)
		unitTest:assertType(proj4.layers, "table")
		unitTest:assertEquals(getn(proj4.layers), 0)

		file:deleteIfExists()

		file = File("emas.tview")

		local proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("emas-firebreak.shp", "gis"),
			cover = filePath("emas-accumulation.tif", "gis"),
			river = filePath("emas-river.shp", "gis"),
			limit = filePath("emas-limit.shp", "gis")
		}

		unitTest:assertType(proj5.firebreak, "Layer")
		unitTest:assertEquals(proj5.firebreak.rep, "line")
		unitTest:assertEquals(proj5.firebreak.source, "shp")

		unitTest:assertType(proj5.cover, "Layer")
		unitTest:assertEquals(proj5.cover.rep, "raster")
		unitTest:assertEquals(proj5.cover.source, "tif")

		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertEquals(proj5.river.rep, "line")
		unitTest:assertEquals(proj5.river.source, "shp")

		unitTest:assertType(proj5.limit, "Layer")
		unitTest:assertEquals(proj5.limit.rep, "polygon")
		unitTest:assertEquals(proj5.limit.source, "shp")

		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("emas-firebreak.shp", "gis"),
			cover = filePath("emas-accumulation.tif", "gis"),
			river = filePath("emas-river.shp", "gis"),
			limit = filePath("emas-limit.shp", "gis")
		}

		unitTest:assertType(proj5.firebreak, "Layer")
		unitTest:assertEquals(proj5.firebreak.rep, "line")
		unitTest:assertEquals(proj5.firebreak.source, "shp")

		unitTest:assertType(proj5.cover, "Layer")
		unitTest:assertEquals(proj5.cover.rep, "raster")
		unitTest:assertEquals(proj5.cover.source, "tif")

		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertEquals(proj5.river.rep, "line")
		unitTest:assertEquals(proj5.river.source, "shp")

		unitTest:assertType(proj5.limit, "Layer")
		unitTest:assertEquals(proj5.limit.rep, "polygon")
		unitTest:assertEquals(proj5.limit.source, "shp")
		unitTest:assertEquals(proj5.limit.epsg, 29192)

		local cl = Layer{
			project = proj5,
			file = "emas.shp",
			clean = true,
			input = "limit",
			name = "cells",
			resolution = 2e3,
			progress = false
		}

		unitTest:assertType(cl, "Layer")
		unitTest:assertEquals(cl.rep, "polygon")
		unitTest:assertEquals(cl.source, "shp")
		unitTest:assertEquals(cl.epsg, 29192)
		unitTest:assertEquals(proj5.cells, cl)

		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("emas-firebreak.shp", "gis"),
			river = filePath("emas-river.shp", "gis"),
			limit = filePath("emas-limit.shp", "gis"),
			cells = File("emas.shp")
		}

		local cover = Layer{
			project = proj5,
			name = "cover",
			file = filePath("emas-accumulation.tif", "gis"),
			epsg = 29192
		}

		unitTest:assertType(proj5.firebreak, "Layer")
		unitTest:assertEquals(proj5.firebreak.rep, "line")
		unitTest:assertEquals(proj5.firebreak.source, "shp")
		unitTest:assertEquals(proj5.cover, cover)

		unitTest:assertType(cover, "Layer")
		unitTest:assertEquals(cover.rep, "raster")
		unitTest:assertEquals(cover.source, "tif")
		unitTest:assertEquals(cover.epsg, proj5.cells.epsg)
		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertEquals(proj5.river.rep, "line")
		unitTest:assertEquals(proj5.river.source, "shp")

		unitTest:assertType(proj5.limit, "Layer")
		unitTest:assertEquals(proj5.limit.rep, "polygon")
		unitTest:assertEquals(proj5.limit.source, "shp")

		unitTest:assertType(proj5.cells, "Layer")
		unitTest:assertEquals(proj5.cells.rep, "polygon")
		unitTest:assertEquals(proj5.cells.source, "shp")

		cl:fill{
			operation = "maximum",
			attribute = "maxcover",
			layer = "cover",
			progress = false
		}

		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
			firebreak = filePath("emas-firebreak.shp", "gis"),
			river = filePath("emas-river.shp", "gis"),
			cells = File("emas.shp")
		}

		unitTest:assertType(proj5.firebreak, "Layer")
		unitTest:assertEquals(proj5.firebreak.rep, "line")
		unitTest:assertEquals(proj5.firebreak.source, "shp")

		unitTest:assertType(cover, "Layer")
		unitTest:assertEquals(cover.rep, "raster")
		unitTest:assertEquals(cover.source, "tif")

		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertEquals(proj5.river.rep, "line")
		unitTest:assertEquals(proj5.river.source, "shp")

		unitTest:assertType(proj5.cells, "Layer")
		unitTest:assertEquals(proj5.cells.rep, "polygon")
		unitTest:assertEquals(proj5.cells.source, "shp")

		local attrs = proj5.cells:attributes()
		unitTest:assertEquals(attrs[5].name, "maxcover")

		proj5 = Project{
			file = file:name(true),
			clean = true,
			author = "Almeida, R.",
			title = "Emas database",
		}

		unitTest:assertEquals(#proj5.layers, 0)

		file:delete()
		cl:delete()

		file = File("abc.tview")
		local proj = Project{
			file = file,
			clean = true,
			directory = packageInfo("gis").data.."test"
		}

		unitTest:assertEquals(getn(proj.layers), 21)
		file:deleteIfExists()

		local version = ""
		local readQGisProject = function()
			local qgisproj

			if _Gtme.sessionInfo().system == "windows" then
				qgisproj = Project {
					file = filePath("test/various"..version..".qgs", "gis")
				}
			else
				local ncWarn = function()
					qgisproj = Project {
						file = filePath("test/various"..version..".qgs", "gis")
					}
				end
				unitTest:assertWarning(ncWarn, "Layer QGIS ignored 'vegtype_2000'. Type 'nc' is not supported.") -- SKIP
			end

			local l1 = Layer{
				project = qgisproj,
				name = "sampa"
			}
			unitTest:assertEquals(l1.name, "sampa")
			unitTest:assertEquals(l1.rep, "polygon")
			unitTest:assertEquals(l1.epsg, 4019)
			unitTest:assertEquals(File(l1.file):name(), "sampa.geojson")
			unitTest:assertEquals(l1.source, "geojson")
			unitTest:assertEquals(l1.encoding, "latin1")

			local l2 = Layer{
				project = qgisproj,
				name = "biomassa-manaus"
			}
			unitTest:assertEquals(l2.name, "biomassa-manaus")
			unitTest:assertEquals(l2.rep, "raster")
			unitTest:assertEquals(l2.epsg, 4326)
			unitTest:assertEquals(File(l2.file):name(), "biomassa-manaus.asc")
			unitTest:assertEquals(l2.source, "asc")
			unitTest:assertEquals(l2.encoding, "latin1")

			if _Gtme.sessionInfo().system == "windows" then
				local l3 = Layer{
					project = qgisproj,
					name = "vegtype_2000"
				}
				unitTest:assertEquals(l3.name, "vegtype_2000") -- SKIP
				unitTest:assertEquals(l3.rep, "raster") -- SKIP
				unitTest:assertEquals(l3.epsg, 4326) -- SKIP
				unitTest:assertEquals(File(l3.file):name(), "vegtype_2000.nc") -- SKIP
				unitTest:assertEquals(l3.source, "nc") -- SKIP
				unitTest:assertEquals(l3.encoding, "latin1") -- SKIP
			end

			File("various"..version..".tview"):delete()
		end

		local insertNewLayerQgis = function()
			local qgsfile = filePath("test/sampa_v3.qgs", "gis")
			local spfile = filePath("test/sampa.shp", "gis")

			qgsfile:copy(currentDir())
			spfile:copy(currentDir())

			local qgp = Project {
				file = File("sampa_v3.qgs")
			}

			local l1 = Layer{
				project = qgp,
				name = "SP"
			}

			local cl1Name = "SPCells"

			local cl1 = Layer{
				project = qgp,
				source = "shp",
				clean = true,
				input = l1.name,
				name = cl1Name,
				resolution = 1,
				file = cl1Name..".shp",
				index = false,
				progress = false
			}

			local spgj = filePath("test/sampa.geojson", "gis")
			spgj:copy(currentDir())

			local l2 = Layer{
				project = qgp,
				name = "SPGJ",
				file = File("sampa.geojson")
			}

			local fileTif = filePath("emas-accumulation.tif", "gis")
			fileTif:copy(currentDir())

			Layer {
				project = qgp,
				name = "Tif",
				file = File("emas-accumulation.tif"),
				epsg = 4019
			}

			local qgp2 = Project {
				file = File("sampa_v3.qgs")
			}

			local l3 = Layer{
				project = qgp2,
				name = "SPCells"
			}

			unitTest:assertEquals(l3.name, "SPCells")
			unitTest:assertEquals(l3.rep, "polygon")
			unitTest:assertEquals(l3.epsg, 4019)
			unitTest:assertEquals(File(l3.file):name(), "SPCells.shp")
			unitTest:assertEquals(l3.source, "shp")
			unitTest:assertEquals(l3.encoding, "latin1")

			local l4 = Layer{
				project = qgp2,
				name = "SPGJ"
			}

			unitTest:assertEquals(l4.name, "SPGJ")
			unitTest:assertEquals(l4.rep, "polygon")
			unitTest:assertEquals(l4.epsg, 4019)
			unitTest:assertEquals(File(l4.file):name(), "sampa.geojson")
			unitTest:assertEquals(l4.source, "geojson")
			unitTest:assertEquals(l4.encoding, "latin1")

			local l5 = Layer{
				project = qgp2,
				name = "Tif"
			}

			unitTest:assertEquals(l5.name, "Tif")
			unitTest:assertEquals(l5.rep, "raster")
			unitTest:assertEquals(l5.epsg, 4019)
			unitTest:assertEquals(File(l5.file):name(), "emas-accumulation.tif")
			unitTest:assertEquals(l5.source, "tif")
			unitTest:assertEquals(l5.encoding, "latin1")

			qgp2.file:delete()
			File("sampa_v3.tview"):delete()
			cl1:delete()
			l1:delete()
			l2:delete()
			l5:delete()
		end

		local createQGisProject = function()
			local spfile = filePath("test/sampa.shp", "gis")
			spfile:copy(currentDir())

			local qgp = Project {
				file = File("create_func_v3.qgs")
			}

			local l1 = Layer{
				project = qgp,
				name = "SP",
				file = File("sampa.shp")
			}

			local cl1Name = "SPCells"
			local cl1 = Layer{
				project = qgp,
				source = "shp",
				clean = true,
				input = l1.name,
				name = cl1Name,
				resolution = 1,
				file = cl1Name..".shp",
				index = false,
				progress = false
			}

			local qgp2 = Project {
				file = qgp.file
			}

			local l2 = Layer{
				project = qgp2,
				name = cl1Name
			}

			unitTest:assertEquals(l2.name, cl1Name)
			unitTest:assertEquals(l2.rep, "polygon")
			unitTest:assertEquals(l2.epsg, 4019)
			unitTest:assertEquals(File(l2.file):name(), "SPCells.shp")
			unitTest:assertEquals(l2.source, "shp")
			unitTest:assertEquals(l2.encoding, "latin1")

			local l3 = Layer{
				project = qgp2,
				name = "SP"
			}

			unitTest:assertEquals(l3.name, "SP")
			unitTest:assertEquals(l3.rep, "polygon")
			unitTest:assertEquals(l3.epsg, 4019)
			unitTest:assertEquals(File(l3.file):name(), "sampa.shp")
			unitTest:assertEquals(l3.source, "shp")
			unitTest:assertEquals(l3.encoding, "latin1")

			qgp2.file:delete()
			File("create_func_v3.tview"):delete()
			cl1:delete()
			l1:delete()
		end

		unitTest:assert(readQGisProject)
		version = "_v3"
		unitTest:assert(readQGisProject)
		unitTest:assert(insertNewLayerQgis)
		unitTest:assert(createQGisProject)

		-- Temporal Layers
		local projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		    areas = packageInfo("gis").data.."conservationAreas*.shp",
		}

		unitTest:assertNil(projTemporal.areas)
		unitTest:assertEquals(projTemporal.areas_1961.name, "areas_1961")
		unitTest:assertType(projTemporal.areas_1961, "Layer")
		unitTest:assertEquals(projTemporal.areas_1961.source, "shp")
		unitTest:assertEquals(projTemporal.areas_1974.name, "areas_1974")
		unitTest:assertType(projTemporal.areas_1974, "Layer")
		unitTest:assertEquals(projTemporal.areas_1974.source, "shp")
		unitTest:assertEquals(projTemporal.areas_1979.name, "areas_1979")
		unitTest:assertType(projTemporal.areas_1979, "Layer")
		unitTest:assertEquals(projTemporal.areas_1979.source, "shp")

		projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		    layer = packageInfo("gis").data.."conservation*.shp",
		}

		unitTest:assertNil(projTemporal.layer)
		unitTest:assertEquals(projTemporal.layerAreas_1961.name, "layerAreas_1961")
		unitTest:assertType(projTemporal.layerAreas_1961, "Layer")
		unitTest:assertEquals(projTemporal.layerAreas_1961.source, "shp")
		unitTest:assertEquals(projTemporal.layerAreas_1974.name, "layerAreas_1974")
		unitTest:assertType(projTemporal.layerAreas_1974, "Layer")
		unitTest:assertEquals(projTemporal.layerAreas_1974.source, "shp")
		unitTest:assertEquals(projTemporal.layerAreas_1979.name, "layerAreas_1979")
		unitTest:assertType(projTemporal.layerAreas_1979, "Layer")
		unitTest:assertEquals(projTemporal.layerAreas_1979.source, "shp")

		projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		    hidro = packageInfo("gis").data.."hidroeletricPlants*.shp",
		    conservation = packageInfo("gis").data.."conservationAreas*.shp",
		}

		unitTest:assertNil(projTemporal.conservation)
		unitTest:assertNil(projTemporal.hidro)
		unitTest:assertEquals(projTemporal.conservation_1961.name, "conservation_1961")
		unitTest:assertType(projTemporal.conservation_1961, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1961.source, "shp")
		unitTest:assertEquals(projTemporal.conservation_1974.name, "conservation_1974")
		unitTest:assertType(projTemporal.conservation_1974, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1974.source, "shp")
		unitTest:assertEquals(projTemporal.conservation_1979.name, "conservation_1979")
		unitTest:assertType(projTemporal.conservation_1979, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1979.source, "shp")
		unitTest:assertEquals(projTemporal.hidro_1970.name, "hidro_1970")
		unitTest:assertType(projTemporal.hidro_1970, "Layer")
		unitTest:assertEquals(projTemporal.hidro_1970.source, "shp")
		unitTest:assertEquals(projTemporal.hidro_1975.name, "hidro_1975")
		unitTest:assertType(projTemporal.hidro_1975, "Layer")
		unitTest:assertEquals(projTemporal.hidro_1975.source, "shp")
		unitTest:assertEquals(projTemporal.hidro_1977.name, "hidro_1977")
		unitTest:assertType(projTemporal.hidro_1977, "Layer")
		unitTest:assertEquals(projTemporal.hidro_1977.source, "shp")

		File("temporal.tview"):deleteIfExists()
	end,
	__tostring = function(unitTest)
		local file = File("tostring.tview")
		local proj1 = Project{
			file = file:name(),
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}

		unitTest:assertEquals(tostring(proj1), [[author  string [Avancini]
clean   boolean [true]
file    File
layers  vector of size 0
title   string [The Amazonia]
]])

		file:delete()

		local defaultValueError = function()
			Project{file = "abc.tview", title = "No title"}
		end
		unitTest:assertWarning(defaultValueError, defaultValueMsg("title", "No title"))
		File("abc.tview"):delete()

		defaultValueError = function()
			Project{file = "abc.tview", author = "No author"}
		end
		unitTest:assertWarning(defaultValueError, defaultValueMsg("author", "No author"))
		File("abc.tview"):delete()

		local qgisproj = Project {
			file = filePath("test/amazonia.qgs", "gis")
		}

		unitTest:assertEquals(tostring(qgisproj), [[author  string [QGIS Project]
clean   boolean [false]
file    File
layers  named table of size 3
title   string [QGIS Project]
]])

		File("amazonia.tview"):delete()
	end
}
