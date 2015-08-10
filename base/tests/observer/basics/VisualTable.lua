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
-- Authors: Pedro R. Andrade
-------------------------------------------------------------------------------------------

return{
	VisualTable = function(unitTest)
		local world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt1 = VisualTable{target = world}
    
    unitTest:assertType(vt1, "VisualTable")
    
    -- unitTest:assertSnapshot(vt1, "visualtable_cell.bmp") -- issue #626

		local world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt2 = VisualTable{target = world}
    
    -- unitTest:assertSnapshot(vt2, "visualtable_agent.bmp") -- issue #626

		local vt3 = VisualTable{
			target = world,
			select = {"mcount"}
		}
    
    -- unitTest:assertSnapshot(vt3, "visualtable_agent2.bmp") -- issue #626
    
		local soc = Society{
			instance = world,
			quantity = 3
		}
    
		local vt4 = VisualTable{target = soc}
		local vt5 = VisualTable{target = soc, select = "#"}
    
    -- unitTest:assertSnapshot(vt4, "visualtable_society.bmp") -- issue #626
    -- unitTest:assertSnapshot(vt5, "visualtable_society_select.bmp") -- issue #626

		local soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local vt6 = VisualTable{target = soc}
    
    -- unitTest:assertSnapshot(vt6, "visualtable_society_agent.bmp") -- issue #626

		local world = CellularSpace{
			xdim = 10,
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt7 = VisualTable{target = world}
		local vt8 = VisualTable{target = world, select = "mcount"}
    
    -- unitTest:assertSnapshot(vt7, "visualtable_cellularspace.bmp") -- issue #626
    -- unitTest:assertSnapshot(vt8, "visualtable_cellularspace_select.bmp") -- issue #626    

	end
}

