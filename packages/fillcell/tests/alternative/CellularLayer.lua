-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Author: Pedro R. Andrade
-------------------------------------------------------------------------------------------

 return{
 	CellularLayer = function(unitTest)
 		unitTest:assert(true)
-- 		local error_func = function()
-- 			local cl = CellularLayer()
-- 		end
-- 		unitTest:assertError(error_func, tableArgumentMsg())

-- 		error_func = function()
-- 			local cl = CellularLayer{project = 2, layer = "cells"}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("project", "string", 2))

-- 		error_func = function()
-- 			local cl = CellularLayer{project = "myproj.tview", layer = false}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("layer", "string", false))

-- 		error_func = function()
-- 			local cl = CellularLayer{project = "myproj.tview", lauer = "cells"}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("lauer", "layer"))

-- 		-- TODO: select a project that does not exist
-- 		-- TODO: open a cellularlayer that does not exist - with and without suggestion
-- 	end,
-- 	fillCells = function(unitTest)
-- 		local cl = CellularLayer{project = "amazonia.tview", layer = "cells"}

-- 		local error_func = function()
-- 			cl:fillCells{
-- 				attribute = "population",
-- 				layer = "population"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, mandatoryArgumentMsg("operation"))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "distRoads",
-- 				operation = 2,
-- 				layer = "roads"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("operation", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "population",
-- 				operation = "area"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, mandatoryArgumentMsg("layer"))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "distRoads",
-- 				operation = "area",
-- 				layer = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("layer", "string", 2))
	
-- 		error_func = function()
-- 			cl:fillCells{
-- 				layer = "cells",
-- 				operation = "area"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, mandatoryArgumentMsg("attribute"))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = 2,
-- 				operation = "area",
-- 				layer = "cells"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("attribute", "string", 2))

-- 		-- area
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "area",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select"))

-- 		-- average
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "average",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- count
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "count",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select"))

-- 		-- distance
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "distance",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select"))

-- 		-- length
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "length",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select"))

-- 		-- majority
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "majority",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- maximum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "maximum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- minimum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "minimum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- percentage
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "percentage",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- presence
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "presence",
-- 				layer = "cover",
-- 				select = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("select"))

-- 		-- stdev
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "stdev",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- sum
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				default = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("default", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				dummy = false
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("dummy", "number", false))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "sum",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				defaut = 3
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("defaut", "default"))

-- 		-- value
-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				select = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("select", "string", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				select = "cover2010",
-- 				area = 2
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, incompatibleTypeMsg("area", "boolean", 2))

-- 		error_func = function()
-- 			cl:fillCells{
-- 				attribute = "attr",
-- 				operation = "value",
-- 				layer = "cover",
-- 				selec = "cover2010"
-- 			}
-- 		end
-- 		unitTest:assertError(error_func, unnecessaryArgumentMsg("selec", "select"))

-- 		-- TODO: match geometries with the available strategies
-- 		-- (first table of the documentation)
-- 		-- check if terralib already does this (but the test must exist anyway)

-- 		-- TODO: try to create an attribute that already exists (I dont know if TerraLib
-- 		-- will stop with an error or it is up to us to check this.)
-- 		-- TODO: try to fillCells using a `layer` that does not exist.

 	end
}

