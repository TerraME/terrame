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
			file = filePath("limitePA_polyc_pol.shp", "terralib")
		}

		local prodes = "prodes"
		Layer{
			project = proj,
			name = prodes,
			file = filePath("prodes_polyc_10k.tif", "terralib")	
		}
		
		local clName1 = "cells"
		local shp1 = clName1..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end

		local cl = Layer{
			project = proj,
			source = "shp",
			input = layerName1,
			name = clName1,
			resolution = 20000,
			file = clName1..".shp"
		}

		local shapes = {}

		local modeTifLayerName = clName1.."_"..prodes.."_mode"
		local shp = modeTifLayerName..".shp"

		table.insert(shapes, shp)
		
		if isFile(shp) then
			rmFile(shp)
		end

		local invalidBand = function()
			cl:fill{
				operation = "mode",
				attribute = "prod_mode",
				layer = prodes,
				output = modeTifLayerName,
				band = 5,
			}
		end

		unitTest:assertError(invalidBand, "Band '5' does not exist. The available bands are from '0' to '4'.")
		
		local altimetria = Layer{
			project = proj,
			name = "altimetria",
			file = filePath("elevation.tif", "terralib")
		}

		local invalidBand = function()
			cl:fill{
				operation = "mode",
				attribute = "prod_mode",
				layer = "altimetria",
				output = modeTifLayerName,
				band = 5,
			}
		end
		unitTest:assertError(invalidBand, "Band '5' does not exist. The only available band is '0'.")
	end
}

