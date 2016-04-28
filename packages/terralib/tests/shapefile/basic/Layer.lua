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
		local projName = "cellular_layer_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName1 = "limitepa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("limitePA_polyc_pol.shp", "terralib")
		}

		local protecao = "protecao"
		Layer{
			project = proj,
			name = protecao,
			file = filePath("BCIM_Unidade_Protecao_IntegralPolygon_PA_polyc_pol.shp", "terralib")
		}

		local rodovias = "Rodovias"
		Layer{
			project = proj,
			name = rodovias,
			file = filePath("BCIM_Trecho_RodoviarioLine_PA_polyc_lin.shp", "terralib")	
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
			resolution = 50000,
			file = clName1..".shp"
		}

		local areaLayerName = clName1.."_area"
		local shp1 = areaLayerName..".shp"

		if isFile(shp1) then
			rmFile(shp1)
		end

		cl:fill{
			operation = "area",
			name = protecao,
			attribute = "marea",
			output = areaLayerName
		}

		local cs = CellularSpace{
			project = proj,
			layer = areaLayerName
		}

		local map = Map{
			target = cs,
			select = "marea",
			min = 0,
			max = 1,
			slices = 8,
			color = {"red", "green"}
		}

		unitTest:assertSnapshot(map, "polygons-area.png")

		local lengthLayerName = clName1.."_length"
		local shp2 = areaLayerName..".shp"

		if isFile(shp2) then
			rmFile(shp2)
		end

		local error_func = function()
			cl:fill{
				operation = "length",
				name = rodovias,
				attribute = "mlength",
				output = lengthLayerName
			}
		end
		unitTest:assertError(error_func, "Sorry, this operation was not implemented in TerraLib yet.")
	end
}

