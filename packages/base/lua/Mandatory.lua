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

Mandatory_ = {
	type_ = "Mandatory"
}

metaTableMandatory_ = {__index = Mandatory_, __tostring = _Gtme.tostring}

--- Type to define a mandatory argument for a given Model.
-- @arg value A string with the type of the argument. It cannot be boolean, string, nor userdata.
-- Note that Mandatory does not get named arguments as the other TerraME types.
-- @output value The required type.
-- @usage Mandatory("number")
function Mandatory(value)
	local result = {}

	mandatoryArgument(1, "string", value)

	if belong(value, {"boolean", "string", "userdata"}) then
		customError("Value '"..value.."' cannot be a mandatory argument.")
	end
	result.value = value

	setmetatable(result, metaTableMandatory_)
	return result
end

