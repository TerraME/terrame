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
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Coord = function(unitTest)
		local coord = Coord{x = nil, y = 2}
		unitTest:assert_equal(0,coord:getX())

		unitTest:assert_error(function()
			local coord = Coord{x = {}, y = 2}
		end,"Error: Incompatible types. Parameter 'x' expected number, got table.")

		local coord = Coord{x = 2, y = nil}
		unitTest:assert_equal(0, coord:getY())

		unitTest:assert_error(function()
			local coord = Coord{x = 2, y = "terralab"}
		end,"Error: Incompatible types. Parameter 'y' expected number, got string.")

		local coord = Coord(nil)
		unitTest:assert_equal(0, coord:getX())
		unitTest:assert_equal(0, coord:getY())

		unitTest:assert_error(function()
			local coord = Coord("terralab")
		end,"Error: Parameters for 'Coord' must be named.")
		unitTest:assert_error(function()
			local coord = Coord(18)
		end,"Error: Parameters for 'Coord' must be named.")
	end,
	set = function(unitTest)
		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = nil, y = 2}
 		end,"Error: Incompatible types. Parameter 'x' expected positive integer number, got nil.")

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = "terralab", y = 2}
		end,"Error: Incompatible types. Parameter 'x' expected positive integer number, got string.")

		unitTest:assert_error(function()
			coord:set{x = -18, y = 2}
		end,"Error: Incompatible values. Parameter 'x' expected positive integer number, got -18.")

		unitTest:assert_equal(30,coord:getX())

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = 2, y = nil}
		end,"Error: Incompatible types. Parameter 'y' expected positive integer number, got nil.")

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = 2, y = {}}
		end,"Error: Incompatible types. Parameter 'y' expected positive integer number, got table.")
		unitTest:assert_equal(30,coord:getY())
		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = 2, y = "terralab"}
		end,"Error: Incompatible types. Parameter 'y' expected positive integer number, got string.")

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set{x = 2, y = -18}
		end,"Error: Incompatible values. Parameter 'y' expected positive integer number, got -18.")

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set(nil)
	 	end,"Error: Parameter '#1' is mandatory.")

		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set("terralab")
		end,"Error: Incompatible types. Parameter '#1' expected table, got string.")

		unitTest:assert_equal(30,coord:getY())
		local coord = Coord{x = 30, y = 30}
		unitTest:assert_error(function()
			coord:set(18)
		end, "Error: Incompatible types. Parameter '#1' expected table, got number.")
	end
}

