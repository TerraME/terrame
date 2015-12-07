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
	addLayer = function(unitTest)
		local proj = Project{
			file = file("amazonia.tview", "fillcell")
		}

		local error_func = function()
			proj:addLayer()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			proj:addLayer{
				layer = 123,
				file = "myfile.shp",
			}

		end
		unitTest:assertError(error_func, incompatibleTypeMsg("layer", "string", 123))

		-- TODO: check if a layer to be added already exists
		-- TODO: tests for shapefiles
		-- TODO: tests for postgis
		-- TODO: tests for tiff
	end,
	Project = function(unitTest)
		local error_func = function()
			local proj = Project()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			local proj = Project{file = "myproj.tview", create = false}
		end
		unitTest:assertError(error_func, defaultValueMsg("create", false))

		error_func = function()
			local proj = Project{file = "myproj.tview", create = 2}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("create", "boolean", 2))

		error_func = function()
			local proj = Project{file = 123, create = true}
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("file", "string", 123))

		error_func = function()
			local proj = Project{create = true}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("file"))

		error_func = function()
			local proj = Project{file = "myproj.tview", ceate = true}
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("ceate", "create"))

		-- TODO: open a project that does not exist
		local error_func = function()
			local proj = Project{
				file = "myproject123.tview"
			}
		end
		-- unitTest:assertError(error_func, "Project 'myproject123.tview' does not exist. Use 'create = true' to create a new Project.")

		-- TODO: create a project that already exists
		local name = file("amazonia.tview", "fillcell")
		local error_func = function()
			local proj = Project{
				file = name,
				create = true
			}
		end
		-- unitTest:assertError(error_func, "Project '"..name.."' already exists.")
	end
}

