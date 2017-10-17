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
			resolution = 2e3
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
if _Gtme.sessionInfo().system ~= "mac" then -- TODO(#1934)
		unitTest:assertEquals(cover.epsg, proj5.cells.epsg) -- SKIP
end
		unitTest:assertType(proj5.river, "Layer")
		unitTest:assertEquals(proj5.river.rep, "line")
		unitTest:assertEquals(proj5.river.source, "shp")

		unitTest:assertType(proj5.limit, "Layer")
		unitTest:assertEquals(proj5.limit.rep, "polygon")
		unitTest:assertEquals(proj5.limit.source, "shp")

		unitTest:assertType(proj5.cells, "Layer")
		unitTest:assertEquals(proj5.cells.rep, "polygon")
		unitTest:assertEquals(proj5.cells.source, "shp")

if _Gtme.sessionInfo().system ~= "mac" then -- TODO(#1934)
		cl:fill{
			operation = "maximum",
			attribute = "maxcover",
			layer = "cover"
		}
end

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
if _Gtme.sessionInfo().system ~= "mac" then	-- TODO(#1934)
		unitTest:assertEquals(attrs[5].name, "maxcover") -- SKIP
end
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

		unitTest:assertEquals(getn(proj.layers), 13)
		file:deleteIfExists()

		-- QGIS PROJECT
		local qgisproj

		if _Gtme.sessionInfo().system == "windows" then
			qgisproj = Project {
				file = filePath("test/various.qgs", "gis")
			}
		else
			local ncWarn = function()
				qgisproj = Project {
					file = filePath("test/various.qgs", "gis")
				}
			end
			unitTest:assertWarning(ncWarn, "Layer QGis ignored 'vegtype_2000'. Type 'nc' is not supported.") -- SKIP
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
		unitTest:assertNil(l2.encoding)

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
			unitTest:assertNil(l3.encoding) -- SKIP
		end

		File("various.tview"):delete()
		-- // QGIS PROJECT
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

		unitTest:assertEquals(tostring(qgisproj), [[author  string [QGis Project]
clean   boolean [false]
file    File
layers  named table of size 3
title   string [QGis Project]
]])

		File("amazonia.tview"):delete()
	end
}
