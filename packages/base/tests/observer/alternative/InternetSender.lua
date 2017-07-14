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

return{
	InternetSender = function(unitTest)
		local c = Cell{value = 5}

		local error_func = function()
			InternetSender(2)
		end

		unitTest:assertError(error_func, namedArgumentsMsg())

		error_func = function()
			InternetSender{}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("target"))

		local e = Event{action = function() end}
		error_func = function()
			InternetSender{target = e}
		end

		unitTest:assertError(error_func, "Invalid type. InternetSender only works with Cell, CellularSpace, Agent, and Society.")

		error_func = function()
			InternetSender{target = c, select = 5}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("select", "table", 5))

		error_func = function()
			InternetSender{target = c, select = "mvalue"}
		end

		unitTest:assertError(error_func, "Selected element 'mvalue' does not belong to the target.")

		error_func = function()
			InternetSender{target = c, host = 5}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("host", "string", 5))

		-- TODO(#1911)
		local warning_func = function()
			InternetSender{target = c, host = "localhost"}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("host", "localhost"))

		error_func = function()
			InternetSender{target = c, port = "5"}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("port", "number", "5"))

		error_func = function()
			InternetSender{target = c, port = 49999}
		end

		unitTest:assertError(error_func, "Argument 'port' should be greater or equal to 50000, got 49999.")

		-- TODO(#1911)
		warning_func = function()
			InternetSender{target = c, port = 456456}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("port", 456456))

		error_func = function()
			InternetSender{target = c, protocol = 5}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("protocol", "string", 5))

		-- TODO(#1911)
		warning_func = function()
			InternetSender{target = c, protocol = "udp"}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("protocol", "udp"))

		error_func = function()
			InternetSender{target = c, protocol = "vdp"}
		end

		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("vdp", "protocol", "udp"))

		error_func = function()
			InternetSender{target = c, visible = 4}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("visible", "boolean", 4))

		-- TODO(#1911)
		warning_func = function()
			InternetSender{target = c, visible = true}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("visible", true))

		error_func = function()
			InternetSender{target = c, compress = 4}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("compress", "boolean", 4))

		-- TODO(#1911)
		warning_func = function()
			InternetSender{target = c, compress = true}
		end

		unitTest:assertWarning(warning_func, defaultValueMsg("compress", true))

		error_func = function()
			InternetSender{target = c, select = {}}
		end

		unitTest:assertError(error_func, "InternetSender must select at least one attribute.")

		local unit = Cell{}

		error_func = function()
			InternetSender{target = unit}
		end

		unitTest:assertError(error_func, "The target does not have at least one valid attribute to be used.")

		local world = CellularSpace{xdim = 10}

		error_func = function()
			InternetSender{target = world}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("select"))

		error_func = function()
			InternetSender{target = world, select = "value"}
		end

		unitTest:assertError(error_func, "Selected element 'value' does not belong to the target.")
	end
}

