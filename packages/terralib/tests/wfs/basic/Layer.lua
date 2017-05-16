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
		local projName = "layer_wfs_basic.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local layerName = "BAU"
		local service = "http://terrabrasilis.info/redd-pac/wfs"
		local feature = "reddpac:wfs_biomes"

		if TerraLib().isValidWfsUrl(service) then
			local layer = Layer {
				project = proj,
				source = "wfs",
				name = layerName,
				service = service,
				feature = feature
			}

			unitTest:assertEquals(layer.name, layerName) -- SKIP
			unitTest:assertEquals(layer.source, "wfs") -- SKIP
			unitTest:assertEquals(layer.service, service) -- SKIP
			unitTest:assertEquals(layer.feature, feature) -- SKIP
		else
			customError("WFS server '.."..service.."' is not responding, try again later.") -- SKIP
		end

		File(projName):delete()
	end,
	fill = function(unitTest)
		local projName = File("layer_wfs_fill.tview")

		local proj = Project {
				file = projName,
				clean = true
		}

		local biomesName = "biomes"
		local prodesName = "prodes"
		local service = "http://terrabrasilis.info/redd-pac/wfs"

		local prodes = Layer{
			project = proj,
			source = "wfs",
			name = prodesName,
			service = service,
			feature = "reddpac:wfs_simus_prodes"
		}

		local biomes = Layer{
			project = proj,
			source = "wfs",
			name = biomesName,
			service = service,
			feature = "reddpac:wfs_biomes"
		}

		local file = File("cells.shp")

		local cl1 = Layer{
			project = proj,
			clean = true,
			input = biomesName,
			name = "cells",
			resolution = 8,
			file = file,
			index = false
		}

		unitTest:assertEquals(#cl1, 20)
		local attributes = cl1:attributes()

		unitTest:assertEquals(#attributes, 4)
		unitTest:assertEquals(attributes[1].name, "FID")
		unitTest:assertEquals(attributes[2].type, "string")
		unitTest:assertEquals(cl1:projection(), "'WGS 84', with EPSG: 4326 (PROJ4: '+proj=longlat +datum=WGS84 +no_defs ')")
		unitTest:assertEquals(cl1:representation(), "polygon")

		cl1:fill{
			operation = "area",
			layer = biomes,
			attribute = "area"
		}

		cl1:fill{
			operation = "count",
			layer = biomes,
			attribute = "mcount"
		}

		cl1:fill{
			operation = "average", -- use average as well
			attribute = "defor",
			select = "desflorest",
			layer = prodes
		}

		local cs = CellularSpace{
			project = proj,
			layer = "cells"
		}

		local map = Map{
			target = cs,
			select = "area",
			slices = 8,
			color = "Blues"
		}

		unitTest:assertSnapshot(map, "map-wfs-area.png")

		map = Map{
			target = cs,
			select = "mcount",
			slices = 4,
			color = "Blues"
		}

		unitTest:assertSnapshot(map, "map-wfs-count.png")

		map = Map{
			target = cs,
			select = "defor",
			slices = 8,
			color = "RdYlGn",
			invert = true
		}

		unitTest:assertSnapshot(map, "map-wfs-average.png")

		projName:delete()
		file:delete()
	end
}

