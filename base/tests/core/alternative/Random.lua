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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	Random = function(unitTest)
		local error_func = function()
			local r = Random(12345)
		end
		unitTest:assert_error(error_func, namedArgumentsMsg())

		local error_func = function()
			local r = Random{x = 12345}
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("x"))

		local error_func = function()
			local r = Random{seed = 2.3}
		end
		unitTest:assert_error(error_func, integerArgumentMsg("seed", 2.3))
	end,
	integer = function(unitTest)
		local randomObj = Random{}

		local error_func = function()
			randomObj:integer("terralab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		local error_func = function()
			randomObj:integer(2, "terralab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "number", "terralab"))
	end,
	number = function(unitTest)
		local randomObj = Random{}

		local error_func = function()
			randomObj:number("terralab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		local error_func = function()
			randomObj:number(2.5, "terralab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "number", "terralab"))
	end,
	reSeed = function(unitTest)
		local randomObj = Random{}
		local error_func = function()
			randomObj:reSeed("terralab")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "number", "terralab"))

		error_func = function()
			randomObj:reSeed(2.3)
		end
		unitTest:assert_error(error_func, integerArgumentMsg(1, 2.3))
	end,
	sample = function(unitTest)
		local randomObj = Random{}
		local error_func = function()
			randomObj:sample(2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "table", 2))
	end
}

