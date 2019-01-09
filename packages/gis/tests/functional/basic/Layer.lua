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
	Layer = function(unitTest)
		local projName = File("cellular_layer_basic.tview")

		projName:deleteIfExists()
		local proj = Project{
			file = projName:name(),
			clean = true
		}

		local layerName1 = "Sampa"

		local layer0 = Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local filePath1 = "setores_cells_basic.shp"

		if not File(filePath1):exists() then
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
			file = filePath1,
			progress = false
		}

		unitTest:assertEquals(projName, cl.project.file)
		unitTest:assertEquals(clName1, cl.name)

		local cl2 = Layer{
			project = projName:name(true),
			name = clName1
		}

		unitTest:assertEquals(cl2.source, "shp")
		unitTest:assertEquals(cl2.file, currentDir()..filePath1)

		projName:deleteIfExists()
		File(filePath1):deleteIfExists()

		projName = File("setores_2000.tview")

		projName:deleteIfExists()

		local proj1 = Project {
			file = projName:name(true)
		}

		local layer1 = Layer{
			project = proj1,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis"),
			encoding = "utf8"
		}
		unitTest:assertEquals(layer1.name, layerName1)
		unitTest:assertEquals("utf8", layer1.encoding)
		unitTest:assertEquals("latin1", layer0.encoding)

		local proj2 = Project {
			file = projName:name(true)
		}

		local layerName2 = "MG"
		local layer2 = Layer{
			project = proj2,
			name = layerName2,
			file = filePath("test/MG_cities.shp", "gis")
		}

		unitTest:assertEquals(layer1.name, layerName1)
		unitTest:assertEquals(layer2.name, layerName2)

		local layerName21 = "MG_2"
		local layer21 = Layer{
			project = proj2,
			name = layerName21,
			file = filePath("test/MG_cities.shp", "gis")
		}

		unitTest:assert(layer21.name ~= layer2.name)
		unitTest:assertEquals(layer21.epsg, layer2.epsg)

		local layerName3 = "CBERS1"
		local layer3 = Layer{
			project = proj2,
			name = layerName3,
			file = filePath("test/cbers_rgb342_crop1.tif", "gis")
		}

		unitTest:assertEquals(layer3.name, layerName3)

		local layerName4 = "CBERS2"
		local layer4 = Layer{
			project = proj2,
			name = layerName4,
			file = filePath("test/cbers_rgb342_crop1.tif", "gis")
		}

		unitTest:assert(layer4.name ~= layer3.name)
		unitTest:assertEquals(layer4.epsg, layer3.epsg)

		projName:deleteIfExists()

		projName = File("cells_setores_2000.tview")
		proj = Project{
			file = projName:name(true),
			clean = true
		}

		layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		layerName2 = "MG"
		Layer{
			project = proj,
			name = layerName2,
			file = filePath("test/MG_cities.shp", "gis")
		}

		layerName3 = "CBERS"
		Layer{
			project = proj,
			name = layerName3,
			file = filePath("test/cbers_rgb342_crop1.tif", "gis")
		}

		filePath1 = "sampa_cells.shp"

		File(filePath1):deleteIfExists()

		clName1 = "Sampa_Cells"
		local l1 = Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			file = filePath1,
			progress = false
		}

		unitTest:assertEquals(l1.name, clName1)

		local filePath2 = "mg_cells.shp"
		local filePath3

		File(filePath2):deleteIfExists()

		local clName2 = "MG_Cells"
		local l2 = Layer{
			project = proj,
			input = layerName2,
			name = clName2,
			resolution = 1,
			file = filePath2,
			progress = false
		}

		unitTest:assertEquals(l2.name, clName2)

		filePath3 = "another_sampa_cells.shp"

		File(filePath3):deleteIfExists()

		local clName3 = "Another_Sampa_Cells"
		local l3 = Layer{
			project = proj,
			input = layerName2,
			name = clName3,
			resolution = 0.7,
			file = filePath3,
			progress = false
		}

		unitTest:assertEquals(l3.name, clName3)

		-- BOX TEST
		local clSetSize = TerraLib().getLayerSize(proj, clName1)
		unitTest:assertEquals(clSetSize, 68)

		clName1 = clName1.."_Box"
		local filePath4 = clName1..".shp"

		File(filePath4):deleteIfExists()

		Layer{
			project = proj,
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			box = true,
			file = filePath4,
			progress = false
		}

		clSetSize = TerraLib().getLayerSize(proj, clName1)
		unitTest:assertEquals(clSetSize, 104)

		local filePath6 = "sampabox.shp"
		File(filePath6):deleteIfExists()

		local boxDefaultError = function()
			Layer{
				project = proj,
				input = layerName1,
				name = "cells3",
				resolution = 0.7,
				box = false,
				file = filePath6,
				progress = false
			}
		end
		unitTest:assertWarning(boxDefaultError, defaultValueMsg("box", false))
		-- \\ BOX

		local filePath5 = "csSp.shp"
		local encodingUnnecessary = function()
			Layer{
				project = proj,
				source = "shp",
				input = layerName1,
				name = "SPCells",
				clean = true,
				resolution = 0.7,
				file = filePath5,
				encoding = "utf8",
				progress = false
			}
		end
		unitTest:assertWarning(encodingUnnecessary, unnecessaryArgumentMsg("encoding"))

		local filePath7 = "cells7.shp"
		local unnecessaryArgument = function()
			Layer{
				project = proj,
				input = layerName1,
				file = filePath7,
				name = "cells7",
				clean = true,
				resoltion = 200,
				resolution = 0.7,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("resoltion", "resolution"))

		local dir = Directory("a-b")
		dir:create()
		local filePath8 = tostring(dir).."/cells8.shp"

		local cl8 = Layer{
			project = proj,
			input = layerName1,
			file = filePath8,
			name = "cells8",
			clean = true,
			resolution = 0.7,
			progress = false
		}

		unitTest:assertEquals(filePath8, cl8.file)

		local dir2 = Directory("a--b_c")
		dir2:create()
		local filePath9 = tostring(dir2).."/cells9.shp"

		local cl9 = Layer{
			project = proj,
			input = layerName1,
			file = filePath9,
			name = "cells9",
			clean = true,
			resolution = 0.7,
			progress = false
		}

		unitTest:assertEquals(filePath9, cl9.file)

		projName:delete()
		File(filePath1):delete()
		File(filePath2):delete()
		File(filePath3):delete()
		File(filePath4):delete()
		File(filePath5):delete()
		File(filePath6):delete()
		File(filePath7):delete()
		File(filePath8):delete()
		File(filePath9):delete()
		dir:delete()
		dir2:delete()

		local projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."conservationAreas*.shp",
			name = "conservationAreas"
		}

		unitTest:assertEquals(projTemporal.conservationAreas_1961.name, "conservationAreas_1961")
		unitTest:assertType(projTemporal.conservationAreas_1961, "Layer")
		unitTest:assertEquals(projTemporal.conservationAreas_1961.source, "shp")
		unitTest:assertEquals(projTemporal.conservationAreas_1974.name, "conservationAreas_1974")
		unitTest:assertType(projTemporal.conservationAreas_1974, "Layer")
		unitTest:assertEquals(projTemporal.conservationAreas_1974.source, "shp")
		unitTest:assertEquals(projTemporal.conservationAreas_1979.name, "conservationAreas_1979")
		unitTest:assertType(projTemporal.conservationAreas_1979, "Layer")
		unitTest:assertEquals(projTemporal.conservationAreas_1979.source, "shp")

		projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."conservation*.shp",
			name = "layer"
		}

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
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."conservationAreas*.shp",
			name = "conservation"
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."hidroeletricPlants*.shp",
			name = "hidro"
		}

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

		projTemporal = Project{
		    file = "temporal.tview",
		    clean = true,
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."conservationAreas*.shp",
			name = "conservation",
			times = {1979, 1974}
		}

		Layer{
			project = projTemporal,
			file = packageInfo("gis").data.."hidroeletricPlants*.shp",
			name = "hidro",
			times = {1975, 1977}
		}

		unitTest:assertNil(projTemporal.conservation_1961)
		unitTest:assertEquals(projTemporal.conservation_1974.name, "conservation_1974")
		unitTest:assertType(projTemporal.conservation_1974, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1974.source, "shp")
		unitTest:assertEquals(projTemporal.conservation_1979.name, "conservation_1979")
		unitTest:assertType(projTemporal.conservation_1979, "Layer")
		unitTest:assertEquals(projTemporal.conservation_1979.source, "shp")
		unitTest:assertNil(projTemporal.hidro_1970)
		unitTest:assertEquals(projTemporal.hidro_1975.name, "hidro_1975")
		unitTest:assertType(projTemporal.hidro_1975, "Layer")
		unitTest:assertEquals(projTemporal.hidro_1975.source, "shp")
		unitTest:assertEquals(projTemporal.hidro_1977.name, "hidro_1977")
		unitTest:assertType(projTemporal.hidro_1977, "Layer")
		unitTest:assertEquals(projTemporal.hidro_1977.source, "shp")

		File("temporal.tview"):deleteIfExists()
	end,
	delete = function(unitTest)
		local projName = File("cellular_layer_del.tview")

		projName:deleteIfExists()
		local proj = Project{
			file = projName:name(),
			clean = true
		}

		local layerName1 = "Sampa"

		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local filePath1 = "setores_cells_basic.shp"

		local clName1 = "Sampa_Cells"

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			clean = true,
			resolution = 0.3,
			file = filePath1,
			progress = false
		}

		cl:delete()
		projName:delete()
		unitTest:assert(not File(filePath1):exists())
	end,
	fill = function(unitTest)
		local projName = File("gis_fill_func_basic.tview")
		local layerName1 = "Setores_2000"
		local localidades = "Localidades"
		local rodovias = "Rodovias"

		local proj = Project {
			file = projName,
			clean = true,
			[layerName1] = filePath("itaituba-census.shp", "gis"),
			[localidades] = filePath("test/Localidades_pt.shp", "gis"),
			[rodovias] = filePath("itaituba-roads.shp", "gis")
		}

		local clName1 = "Setores_Cells"
		local filePath1 = clName1..".shp"

		File(filePath1):deleteIfExists()

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 30000,
			file = filePath1,
			progress = false
		}

		local presenceSelectUnnecessary = function()
			cl:fill{
				operation = "presence",
				layer = localidades,
				attribute = "presence",
				select = "FID",
				progress = false
			}
		end
		unitTest:assertWarning(presenceSelectUnnecessary, unnecessaryArgumentMsg("select"))
		local attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "presence")

		local areaSelectUnnecessary = function()
			cl:fill{
				attribute = "areattr",
				operation = "area",
				layer = layerName1,
				select = "FID",
				progress = false
			}
		end
		unitTest:assertWarning(areaSelectUnnecessary, unnecessaryArgumentMsg("select"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "areattr")

		local countSelectUnnecessary = function()
			cl:fill{
				attribute = "counttr",
				operation = "count",
				layer = localidades,
				select = "FID",
				progress = false
			}
		end
		unitTest:assertWarning(countSelectUnnecessary, unnecessaryArgumentMsg("select"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "counttr")

		local distanceSelectUnnecessary = function()
			cl:fill{
				attribute = "disttr",
				operation = "distance",
				layer = layerName1,
				select = "FID",
				progress = false
			}
		end
		unitTest:assertWarning(distanceSelectUnnecessary, unnecessaryArgumentMsg("select"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "disttr")

		local unnecessaryArgument = function()
			cl:fill{
				attribute = "minttr",
				operation = "minimum",
				layer = localidades,
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "minttr")

		unnecessaryArgument = function()
			cl:fill{
				attribute = "maxattr",
				operation = "maximum",
				layer = localidades,
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "maxattr")

		unnecessaryArgument = function()
			cl:fill{
				attribute = "covttr",
				operation = "coverage",
				layer = layerName1,
				select = "FID",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "covttr_57")

		unnecessaryArgument = function()
			cl:fill{
				operation = "stdev",
				layer = localidades,
				attribute = "stdev",
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "stdev")

		unnecessaryArgument = function()
			cl:fill{
				operation = "average",
				layer = localidades,
				attribute = "mean",
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "mean")

		unnecessaryArgument = function()
			cl:fill{
				operation = "average",
				layer = localidades,
				attribute = "weighted",
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "weighted")


		unnecessaryArgument = function()
			cl:fill{
				operation = "mode",
				layer = localidades,
				attribute = "modttr",
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "modttr")

		unnecessaryArgument = function()
			cl:fill{
				operation = "sum",
				layer = localidades,
				attribute = "ucs_sum",
				select = "UCS_FATURA",
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "ucs_sum")

		unnecessaryArgument = function()
			cl:fill{
				operation = "sum",
				layer = localidades,
				attribute = "wsum",
				select = "UCS_FATURA",
				area = true,
				missin = 3,
				progress = false
			}
		end
		unitTest:assertWarning(unnecessaryArgument, unnecessaryArgumentMsg("missin", "missing"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "wsum")

		local normalizedNameWarning = function()
			cl:fill{
				attribute = "max10allowed",
				operation = "sum",
				layer = layerName1,
				select = "FID",
				progress = false
			}
		end
		unitTest:assertWarning(normalizedNameWarning, "The 'attribute' lenght has more than 10 characters. It was truncated to 'max10allow'.")
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "max10allow")

		-- RASTER TESTS
		local deforest = "Deforestation"
		Layer{
			project = proj,
			name = deforest,
			epsg = 29191,
			file = filePath("itaituba-deforestation.tif", "gis")
		}

		local areaUnnecessary = function()
			cl:fill{
				attribute = "argattr",
				operation = "average",
				layer = deforest,
				area = 2,
				progress = false
			}
		end
		unitTest:assertWarning(areaUnnecessary, unnecessaryArgumentMsg("area"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "argattr")

		areaUnnecessary = function()
			cl:fill{
				attribute = "mmittr",
				operation = "minimum",
				layer = deforest,
				area = 2,
				progress = false
			}
		end
		unitTest:assertWarning(areaUnnecessary, unnecessaryArgumentMsg("area"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "mmittr")

		areaUnnecessary = function()
			cl:fill{
				attribute = "mmaxttr",
				operation = "maximum",
				layer = deforest,
				area = 2,
				progress = false
			}
		end
		unitTest:assertWarning(areaUnnecessary, unnecessaryArgumentMsg("area"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "mmaxttr")

		cl:fill{
			attribute = "ccvattr",
			operation = "coverage",
			layer = deforest,
			progress = false
		}

		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "ccvatt_255")

		areaUnnecessary = function()
			cl:fill{
				attribute = "ssdvattr",
				operation = "stdev",
				layer = deforest,
				area = 2,
				progress = false
			}
		end
		unitTest:assertWarning(areaUnnecessary, unnecessaryArgumentMsg("area"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "ssdvattr")

		areaUnnecessary = function()
			cl:fill{
				attribute = "ssuattr",
				operation = "sum",
				layer = deforest,
				area = 2,
				progress = false
			}
		end
		unitTest:assertWarning(areaUnnecessary, unnecessaryArgumentMsg("area"))
		attrs = cl:attributes()
		unitTest:assertEquals(attrs[#attrs].name, "ssuattr")

		projName:delete()
		File(filePath1):delete()

		--TEMPORAL TESTS
		local projTemporal = Project{
			file = "temporal.tview",
			clean = true,
			conservation = packageInfo("gis").data.."conservationAreas*.shp",
			hidro = packageInfo("gis").data.."hidroeletricPlants*.shp",
		}

		cl = Layer{
			file = filePath1,
			project = projTemporal,
			source = "shp",
			input = "hidro_1970",
			name = "layer",
			resolution = 30000,
			progress = false
		}

		cl:fill{
			attribute = "conserv",
			operation = "area",
			layer = "conservation_19*",
			progress = false
		}

		local temporalAttributeWarn = function()
			cl:fill{
				attribute = "con",
				operation = "area",
				layer = "conservation*1961",
				progress = false
			}
		end

		unitTest:assertWarning(temporalAttributeWarn, "Only one result has been found to match the pattern 'conservation*1961'.")

		attrs = cl:attributes()
		local found = 0
		forEachElement(attrs, function(_, attr)
			if belong(attr.name, {"conserv61", "conserv74", "conserv79"}) then
				found = found + 1
			end
		end)

		unitTest:assertEquals(found, 3)
		cl = Layer{
			file = "layer_split.shp",
			project = projTemporal,
			source = "shp",
			input = "hidro_1970",
			name = "layer_split",
			clean = true,
			resolution = 30000,
			progress = false
		}

		unitTest:assertNil(projTemporal["layer_split_1961"])
		unitTest:assertNil(projTemporal["layer_split_1974"])
		unitTest:assertNil(projTemporal["layer_split_1979"])

		cl:fill{
			attribute = "attr",
			operation = "area",
			layer = "conservation*",
			split = true,
			progress = false
		}

		unitTest:assertNotNil(projTemporal["layer_split_1961"])
		unitTest:assertType(projTemporal["layer_split_1961"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assertNotNil(projTemporal["layer_split_1974"])
		unitTest:assertType(projTemporal["layer_split_1974"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assertNotNil(projTemporal["layer_split_1979"])
		unitTest:assertType(projTemporal["layer_split_1979"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(not belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split")))

		cl:fill{
			attribute = "attr2",
			operation = "area",
			layer = "conservation*",
			split = true,
			progress = false
		}

		unitTest:assertNotNil(projTemporal["layer_split_1961"])
		unitTest:assertType(projTemporal["layer_split_1961"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assertNotNil(projTemporal["layer_split_1974"])
		unitTest:assertType(projTemporal["layer_split_1974"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assertNotNil(projTemporal["layer_split_1979"])
		unitTest:assertType(projTemporal["layer_split_1979"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(not belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split")))
		unitTest:assert(not belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split")))

		File("temporal.tview"):delete()
		projTemporal = Project{
			file = "temporal.tview",
			clean = true,
			conservation = packageInfo("gis").data.."conservationAreas*.shp",
			layer_split = "layer_split.shp"
		}

		cl = projTemporal.layer_split
		cl:fill{
			attribute = "attr3",
			operation = "area",
			layer = "conservation*",
			split = true,
			progress = false
		}

		unitTest:assertNotNil(projTemporal["layer_split_1961"])
		unitTest:assertType(projTemporal["layer_split_1961"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assert(belong("attr3", TerraLib().getPropertyNames(projTemporal, "layer_split_1961")))
		unitTest:assertNotNil(projTemporal["layer_split_1974"])
		unitTest:assertType(projTemporal["layer_split_1974"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assert(belong("attr3", TerraLib().getPropertyNames(projTemporal, "layer_split_1974")))
		unitTest:assertNotNil(projTemporal["layer_split_1979"])
		unitTest:assertType(projTemporal["layer_split_1979"], "Layer")
		unitTest:assert(belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(belong("attr3", TerraLib().getPropertyNames(projTemporal, "layer_split_1979")))
		unitTest:assert(not belong("attr", TerraLib().getPropertyNames(projTemporal, "layer_split")))
		unitTest:assert(not belong("attr2", TerraLib().getPropertyNames(projTemporal, "layer_split")))
		unitTest:assert(not belong("attr3", TerraLib().getPropertyNames(projTemporal, "layer_split")))

		File(filePath1):delete()
		File("layer_split.shp"):delete()
		File("layer_split_1961.shp"):delete()
		File("layer_split_1974.shp"):delete()
		File("layer_split_1979.shp"):delete()
		File("temporal.tview"):delete()
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
			file = filePath("itaituba-census.shp", "gis")
		}

		unitTest:assertEquals(l:representation(), "polygon")

		local localidades = "Localidades"
		l = Layer{
			project = proj,
			name = localidades,
			file = filePath("itaituba-localities.shp", "gis")
		}

		unitTest:assertEquals(l:representation(), "point")

		local rodovias = "Rodovias"
		l = Layer{
			project = proj,
			name = rodovias,
			file = filePath("itaituba-roads.shp", "gis")
		}

		unitTest:assertEquals(l:representation(), "line")

		proj.file:delete()
	end,
	__tostring = function(unitTest)
		local projName = File("cellular_layer_print.tview")

		local proj = Project {
			file = projName:name(true),
			clean = true
		}

		local layerName1 = "Setores_2000"
		local l = Layer{
			project = proj,
			name = layerName1,
			file = filePath("itaituba-census.shp", "gis")
		}

		local expected = [[
encoding  string [latin1]
epsg      number [29191]
file      string [itaituba-census.shp]
name      string [Setores_2000]
project   Project
rep       string [polygon]
source    string [shp]
]]
		unitTest:assertEquals(tostring(l), expected, 0, true)
		projName:deleteIfExists()
	end,
	box = function(unitTest)
		local proj = Project {
			file = "box.tview",
			author = "Avancini, R.",
			clean = true
		}

		local layer = Layer{
			project = proj,
			name = "ES",
			file = filePath("test/limite_es_poly_wgs84.shp", "gis")
		}

		local bbox = layer:box()

		unitTest:assertEquals(bbox.xMin, 1260967.0129458, 1.0e-7)
		unitTest:assertEquals(bbox.yMin, -2412410.0831509, 1.0e-7)
		unitTest:assertEquals(bbox.xMax, 1513600.341338, 1.0e-6)
		unitTest:assertEquals(bbox.yMax, -2030571.5856793, 1.0e-7)

		proj.file:delete()
	end,
	split = function(unitTest)
		local proj = Project{
			file = "temporal.tview",
			conservation = packageInfo("gis").data.."conservationAreas*.shp",
			hidro = packageInfo("gis").data.."hidroeletricPlants*.shp",
			clean = true,
		}

		local layer = Layer{
			file = "test.shp",
			project = proj,
			source = "shp",
			input = "hidro_1970",
			name = "layer",
			resolution = 30000,
			clean = true,
			progress = false
		}

		layer:fill{
			attribute = "conserv_",
			operation = "area",
			layer = "conservation_19*",
			progress = false
		}

		layer:fill{
			attribute = "hidro_",
			operation = "distance",
			layer = "hidro_19*",
			progress = false
		}

		layer:fill{
			attribute = "hidro70",
			operation = "distance",
			layer = "hidro_1970",
			progress = false
		}

		layer:split()

		local attributes = TerraLib().getPropertyNames(proj, "layer_61")
		unitTest:assert(belong("conserv", attributes))
		unitTest:assert(belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		attributes = TerraLib().getPropertyNames(proj, "layer_70")
		unitTest:assert(belong("hidro", attributes))
		unitTest:assert(not belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		attributes = TerraLib().getPropertyNames(proj, "layer_74")
		unitTest:assert(belong("conserv", attributes))
		unitTest:assert(not belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		attributes = TerraLib().getPropertyNames(proj, "layer_75")
		unitTest:assert(belong("hidro", attributes))
		unitTest:assert(not belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		attributes = TerraLib().getPropertyNames(proj, "layer_77")
		unitTest:assert(belong("hidro", attributes))
		unitTest:assert(not belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		attributes = TerraLib().getPropertyNames(proj, "layer_79")
		unitTest:assert(belong("conserv", attributes))
		unitTest:assert(not belong("hidro70", attributes))
		unitTest:assert(belong("row", attributes))
		unitTest:assert(belong("col", attributes))
		unitTest:assert(belong("FID", attributes))
		unitTest:assert(belong("id", attributes))

		File("temporal.tview"):deleteIfExists()
		File("test.shp"):deleteIfExists()
		File("layer_61.shp"):deleteIfExists()
		File("layer_70.shp"):deleteIfExists()
		File("layer_74.shp"):deleteIfExists()
		File("layer_75.shp"):deleteIfExists()
		File("layer_77.shp"):deleteIfExists()
		File("layer_79.shp"):deleteIfExists()
	end,
	merge = function(unitTest)
		unitTest:assert(true)
		-- TODO(#2167)
		-- local proj = Project{
			-- file = "temporal.tview",
			-- conservation = packageInfo("gis").data.."conservationAreas*.shp",
			-- clean = true,
		-- }

		-- local layer = Layer{
			-- file = "test.shp",
			-- project = proj,
			-- source = "shp",
			-- input = "conservation_1961",
			-- name = "temporalLayer",
			-- resolution = 30000,
			-- clean = true,
		-- }

		-- layer:fill{
			-- attribute = "conserv_",
			-- operation = "area",
			-- layer = "conservation_19*",
		-- }

		-- layer:split()
		-- local areladyExistsLayer = function ()
			-- proj.temporalLayer_61:merge()
		-- end

		-- unitTest:assertWarning(areladyExistsLayer, "Layer 'temporalLayer' already exisists.") -- SKIP

		-- proj = Project{
			-- file = "temporal2.tview",
			-- temporalLayer_ = "temporalLayer_*.shp",
			-- clean = true
		-- }

		-- unitTest:assertNil(proj.layers["temporalLayer"]) -- SKIP
		-- local mergedLayer = proj.temporalLayer_61:merge()
		-- unitTest:assertNotNil(proj.layers["temporalLayer"]) -- SKIP
		-- unitTest:assertEquals(mergedLayer.name, "temporalLayer") -- SKIP
		-- local attributes = TerraLib().getPropertyNames(proj, mergedLayer.name)
		-- unitTest:assert(belong("FID", attributes)) -- SKIP
		-- unitTest:assert(belong("id", attributes)) -- SKIP
		-- unitTest:assert(belong("col", attributes)) -- SKIP
		-- unitTest:assert(belong("row", attributes)) -- SKIP
		-- unitTest:assert(belong("conserv_61", attributes)) -- SKIP
		-- unitTest:assert(belong("conserv_74", attributes)) -- SKIP
		-- unitTest:assert(belong("conserv_79", attributes)) -- SKIP
		-- unitTest:assert(not belong("conserv", attributes)) -- SKIP
		-- unitTest:assert(not belong("FID_61", attributes)) -- SKIP
		-- unitTest:assert(not belong("FID_74", attributes)) -- SKIP
		-- unitTest:assert(not belong("FID_79", attributes)) -- SKIP
		-- unitTest:assert(not belong("id_61", attributes)) -- SKIP
		-- unitTest:assert(not belong("id_74", attributes)) -- SKIP
		-- unitTest:assert(not belong("id_79", attributes)) -- SKIP
		-- unitTest:assert(not belong("col_61", attributes)) -- SKIP
		-- unitTest:assert(not belong("col_74", attributes)) -- SKIP
		-- unitTest:assert(not belong("col_79", attributes)) -- SKIP
		-- unitTest:assert(not belong("row_61", attributes)) -- SKIP
		-- unitTest:assert(not belong("row_74", attributes)) -- SKIP
		-- unitTest:assert(not belong("row_79", attributes)) -- SKIP

		-- local dSetRowMerged = TerraLib().getDataSet(proj, mergedLayer.name)[0]
		-- local dSetRow61 = TerraLib().getDataSet(proj, "temporalLayer_61")[0]
		-- local dSetRow74 = TerraLib().getDataSet(proj, "temporalLayer_74")[0]
		-- local dSetRow79 = TerraLib().getDataSet(proj, "temporalLayer_79")[0]
		-- unitTest:assertEquals(dSetRowMerged["conserv_61"], dSetRow61["conserv"]) -- SKIP
		-- unitTest:assertEquals(dSetRowMerged["conserv_74"], dSetRow74["conserv"]) -- SKIP
		-- unitTest:assertEquals(dSetRowMerged["conserv_79"], dSetRow79["conserv"]) -- SKIP

		-- File("temporal.tview"):deleteIfExists()
		-- File("temporal2.tview"):deleteIfExists()
		-- File("test.shp"):deleteIfExists()
		-- File("temporalLayer.shp"):deleteIfExists()
		-- File("temporalLayer_61.shp"):deleteIfExists()
		-- File("temporalLayer_74.shp"):deleteIfExists()
		-- File("temporalLayer_79.shp"):deleteIfExists()
	end
}

