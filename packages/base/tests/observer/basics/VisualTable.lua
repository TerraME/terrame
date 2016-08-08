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

		unitTest:assertSnapshot(vt1, "visualtable_cell.bmp", 0.2)

		world = Agent{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt2 = VisualTable{target = world}

		unitTest:assertSnapshot(vt2, "visualtable_agent.bmp", 0.2)

		local vt3 = VisualTable{
			target = world,
			select = {"mcount"}
		}

		unitTest:assertSnapshot(vt3, "visualtable_agent2.bmp", 0.2)

		local soc = Society{
			instance = world,
			quantity = 3
		}

		local vt4 = VisualTable{target = soc}
		local vt5 = VisualTable{target = soc, select = "#"}

		unitTest:assertSnapshot(vt4, "visualtable_society.bmp", 0.2)
		unitTest:assertSnapshot(vt5, "visualtable_society_select.bmp", 0.2)

		soc = Society{
			instance = Agent{},
			quantity = 3,
			total = 10
		}

		local vt6 = VisualTable{target = soc}

		unitTest:assertSnapshot(vt6, "visualtable_society_agent.bmp", 0.2)

		world = CellularSpace{
			xdim = 10,
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt7 = VisualTable{target = world}
		local vt8 = VisualTable{target = world, select = "mcount"}

		unitTest:assertSnapshot(vt7, "visualtable_cellularspace.bmp", 0.25)
		unitTest:assertSnapshot(vt8, "visualtable_cellularspace_select.bmp", 0.2)
	end,
	update = function(unitTest)
		local world = Cell{
			count = 0,
			mcount = function(self)
				return self.count + 1
			end
		}

		local vt1 = VisualTable{target = world}

		vt1:update()

		unitTest:assertSnapshot(vt1, "visualtable_update.bmp", 0.15)
	end
}

