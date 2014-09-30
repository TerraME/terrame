-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

local optionalTableElement = function(table, attr, allowedType, level)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, mtype, level + 1)
	end
end

local compulsoryTableElement = function(table, attr, level)
	if table[attr] == nil then
		mandatoryArgumentError(attr, level + 1)
	end
end

Clock = function(data)
	compulsoryTableElement(data, "subject", 3)
	optionalTableElement(data, "subject", "Timer", 3)

	checkUnnecessaryParameters(data, {"subject"}, 3)

	local observerAttrs = {}
	local observerParams = {"", ""}
	local observerType = TME_OBSERVERS.SCHEDULER

	local id
	if data.subject.cObj_ then
		id = data.subject.cObj_:createObserver(observerType, observerAttrs, observerParams)
	else
		id = data.subject:createObserver(observerType, observerAttrs, observerParams)
	end

    table.insert(createdObservers, {subject = data.subject, id = id})
	return id

end

