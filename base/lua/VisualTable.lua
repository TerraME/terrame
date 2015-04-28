--#########################################################################################
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
--#########################################################################################

--- A window with a table to show the current attributes of an object along the simulation.
-- Each notify() overwrites the previous values shown in the table.
-- @arg data.subject An Agent, Cell, CellularSpace, Society.
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is only a single value then it can also be described as a string. 
-- As default, it selects all the user-defined attributes of an object.
-- @usage VisualTable{
--     subject = cell,
--     select = {"temperature", "humidity"}
-- }
VisualTable = function(data)
	mandatoryTableArgument(data, "subject")

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.subject) == "Cell" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if not belong(idx, {"x", "y", "past"}) and string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "Agent" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "CellularSpace" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim"}) and string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.subject) == "Society" then
			forEachElement(data.subject, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end
				local size = string.len(idx)
				if string.sub(idx, size, size) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		else
			customError("Invalid type. VisualTable only works with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The subject does not have at least one valid attribute to be used.")
	end

	mandatoryTableArgument(data, "select", "table")
	verify(#data.select > 0, "VisualTable must select at least one attribute.")
	forEachElement(data.select, function(_, value)
		if data.subject[value] == nil then
			if value == "#" then
				if data.subject.obsattrs == nil then
					data.subject.obsattrs = {}
				end
				data.subject.obsattrs["quantity_"] = true
				data.subject.quantity_ = #data.subject
			else
				customError("Selected element '"..value.."' does not belong to the subject.")
			end
		elseif type(data.subject[value]) == "function" then
			if data.subject.obsattrs == nil then
				data.subject.obsattrs = {}
			end

			data.subject.obsattrs[value] = true
		end
	end)

	if data.subject.obsattrs then
		forEachElement(data.subject.obsattrs, function(idx)
			for i = 1, #data.select do
				if data.select[i] == idx then
					data.select[i] = idx.."_"
					local mvalue = data.subject[idx](data.subject)
					data.subject[idx.."_"] = mvalue
				end
			end
		end)
	end

	verifyUnnecessaryArguments(data, {"subject", "select"})

	for i = 1, #data.select do
		if data.select[i] == "#" then
			data.select[i] = "quantity_"
			data.subject.quantity_ = #data.subject
		end
	end

	local observerType = 3
	local observerParams = {}
	local id
	local subject = data.subject

	table.insert(observerParams, "Attribute")
	table.insert(observerParams, "Value")

	if type(subject) == "CellularSpace" then
		id = subject.cObj_:createObserver(observerType, {}, data.select, observerParams, subject.cells)
	else
		id = subject.cObj_:createObserver(observerType, data.select, observerParams)
	end

	table.insert(createdObservers, {subject = data.subject, id = id})
	return id
end

