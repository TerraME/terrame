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
			-- file = filePath("PRODES_5KM.tif", "terralib")	
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
		
		-- SPATIAL INDEX TEST
		local projName = "layer_tif_alternative.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local prodes = "prodes"
		local indexUnnecessary = function()
			Layer{
				project = proj,
				name = prodes,
				file = filePath("PRODES_5KM.tif", "terralib"),
				index = true
			}
		end
		unitTest:assertError(indexUnnecessary, unnecessaryArgumentMsg("index"))
		
		File(proj.file):delete()
		-- // SPATIAL INDEX TEST
	end,
	fill = function(unitTest)
		local projName = "cellular_layer_fill_tiff_alternative.tview"

		local proj = Project{
			file = projName,
			clean = true
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end		
		
		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/limitePA_polyc_pol.shp", "terralib")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("test/prodes_polyc_10k.tif", "terralib")	
		}
		
		local clName1 = "cells"
		local shp1 = clName1..".shp"

		if File(shp1):exists() then
			File(shp1):delete()
		end

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

		if File(shp):exists() then
			File(shp):delete()
		end

		local invalidBand = function()
			cl:fill{
				operation = "mode",
				attribute = "prod_mode",
				layer = prodes,
				band = 5
			}
		end

		unitTest:assertError(invalidBand, "Band '5' does not exist. The available bands are from '0' to '4.0'.")
		
		Layer{
			project = proj,
			name = "altimetria",
			file = filePath("elevation.tif", "terralib")
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
		
		-- unitTest:assertFile(projName) -- SKIP #1301
		File(projName):delete() -- #1301

		if File(shp1):exists() then
			File(shp1):delete()
		end
		
		customWarning = customWarningBkp		
	end,
	dummy = function(unitTest)
		local projName = "layer_tif_dummy.tview"
		
		if File(projName):exists() then
			File(projName):delete()
		end
		
		local proj = Project{
			file = projName,
			clean = true
		}
		
		local customWarningBkp = customWarning
		customWarning = function(msg)
			return msg
		end				

		local prodes = "prodes"
		local bandNoExists = function()
			local l = Layer{
				project = proj,
				name = prodes,
				file = filePath("test/prodes_polyc_10k.tif", "terralib")	
			}
			
			l:dummy(4)
		end
		unitTest:assertError(bandNoExists, "The maximum band is '3.0'.")

		File(projName):delete()

		customWarning = customWarningBkp
	end
}

