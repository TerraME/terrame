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
		-- #1152
		-- local projName = "cellular_layer_fill_tiff_alternative.tview"

		-- local proj = Project{
			-- file = projName,
			-- clean = true
		-- }

		-- local prodes = "prodes"
		-- Layer{
			-- project = proj,
			-- name = prodes,
			-- file = filePath("amazonia-prodes.tif", "gis")
		-- }

		-- local clName1 = "cells"
		-- local shp1 = clName1..".shp"

		-- local boxUnnecessary = function()
			-- local cl = Layer{
				-- project = proj,
				-- source = "shp",
				-- input = prodes,
				-- name = clName1,
				-- resolution = 60e3,
				-- box = true,
				-- file = clName1..".shp"
			-- }
		-- end
		-- unitTest:assertError(boxUnnecessary, unnecessaryArgumentMsg("box")) -- SKIP

		-- File(projName):delete()

		unitTest:assert(true)
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_tiff_alternative.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/limitePA_polyc_pol.shp", "gis")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local clName1 = "cells"
		local shp1 = clName1..".shp"

		File(shp1):deleteIfExists()

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 20000,
			file = clName1..".shp"
		}

		local modeTifLayerName = clName1.."_"..prodes.."_mode"
		local shp = modeTifLayerName..".shp"

		File(shp):deleteIfExists()

		local invalidBand = function()
			cl:fill{
				operation = "mode",
				attribute = "prod_mode",
				layer = prodes,
				band = 5
			}
		end

		unitTest:assertError(invalidBand, "Band '5' does not exist. The only available band is '0'.")

		Layer{
			project = proj,
			name = "altimetria",
			epsg = 2311,
			file = filePath("cabecadeboi-elevation.tif", "gis")
		}

		Layer{
			project = proj,
			name = "box",
			file = filePath("cabecadeboi-box.shp", "gis"),
			epsg = 2311
		}

		invalidBand = function()
			cl:fill{
				operation = "mode",
				attribute = "prod_mode",
				layer = "altimetria",
				band = 5
			}
		end

		unitTest:assertError(invalidBand, "Band '5' does not exist. The only available band is '0'.")

		local invalidPixel = function()
			cl:fill{
				operation = "mode",
				attribute = "alt_mode",
				layer = "altimetria",
				pixel = "overlop"
			}
		end

		unitTest:assertError(invalidPixel, switchInvalidArgumentSuggestionMsg("overlop", "pixel", "overlap"))

		local dummyTypeError = function()
			cl:fill{
				operation = "average",
				attribute = "aver_nd",
				layer = "altimetria",
				dummy = true
			}
		end

		unitTest:assertError(dummyTypeError, incompatibleTypeMsg("dummy", "number", true))

		local diffSridError = function()
			cl:fill{
				operation = "average",
				attribute = "aver",
				layer = "altimetria"
			}
		end

		unitTest:assertError(diffSridError, "Layer projections are different: (altimetria, 2311) and (cells, 29101). Please, reproject your data to the right one.")

		File(projName):delete()
		File(shp1):delete()
	end,
	dummy = function(unitTest)
		local projName = "layer_tif_nodata.tview"
		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local l = Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local bandNoNumber = function()
			l:dummy("4")
		end
		unitTest:assertError(bandNoNumber, incompatibleTypeMsg(1, "number", "4"))

		local bandNegative = function()
			l:dummy(-1)
		end
		unitTest:assertError(bandNegative, positiveArgumentMsg(1, -1, true))

		local bandNoExists = function()
			l:dummy(4)
		end
		unitTest:assertError(bandNoExists, "The only available band is '0'.")

		File(projName):delete()
	end,
	export = function(unitTest)
		local proj = Project{
			file = "export_tif_alt.tview",
			author = "Avancini",
			clean = true
		}

		local layer = Layer{
			project = proj,
			name = "Prodes",
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local raster2VectorError = function()
			layer:export{file = "tif2shp.shp"}
		end

		unitTest:assertError(raster2VectorError, "Raster layer 'Prodes' cannot be exported as vector data. Please, use 'polygonize' function instead.")

		proj.file:delete()
	end
}

