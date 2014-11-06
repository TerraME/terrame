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

Chart = function(data)
	mandatoryTableArgument(data, "subject")
	defaultTableValue(data, "yLabel", "")
	defaultTableValue(data, "xLabel", "")
	defaultTableValue(data, "title",  "")

	optionalTableArgument(data, "xAxis",  "string")

	if type(data.select) == "string" then data.select = {data.select} end
	if type(data.label)  == "string" then data.label  = {data.label} end

	optionalTableArgument(data, "select", "table")
	optionalTableArgument(data, "label",  "table")

	if data.select == nil then
		verify(data.label == nil, "As select is nil, it is not possible to use label.")

		data.select = {}

		if type(data.subject) == "Cell" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if mtype == "number" and idx ~= "x" and idx ~= "y" and string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "Agent" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if mtype == "number" and string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "CellularSpace" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if mtype == "number" and not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim"}) and string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "Society" then
			forEachElement(data.subject, function(idx, value, mtype)
				if mtype == "number" then
					data.select[#data.select + 1] = idx
				end
			end)
			data.select[#data.select + 1] = "#"
		else
			customError("Invalid type. Charts only work with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The subject does not have at least one valid numeric attribute to be used.")
	else
		if type(data.select) == "string" then
			data.select = {data.select}
		else
			optionalTableArgument(data, "select", "table")
		end

		forEachElement(data.select, function(_, value)
			if data.subject[value] == nil then
				if  value == "#" then
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

			elseif type(data.subject[value]) ~= "number" then
				incompatibleTypeError(value, "number or function", data.subject[value])
			end
		end)

		if data.subject.obsattrs then
			forEachElement(data.subject.obsattrs, function(idx)
				for i = 1, #data.select do
					if data.select[i] == idx then
						data.select[i] = idx.."_"
						local mvalue = data.subject[idx](data.subject)
						verify(type(mvalue) == "number", "Function "..idx.. "returns a non-number value.")
						data.subject[idx.."_"] = mvalue
					end
				end
			end)
		end
	end

	verify(#data.select > 0, "Charts must select at least one attribute.")

	if data.label == nil then
		data.label = {}
		for i = 1, #data.select do
			if data.select[i] == "#" then
				data.label[i] = "quantity"
			else
				data.label[i] = data.select[i]
			end
		end
	end

	for i = 1, #data.label do
		local size = string.len(data.label[i])

		if string.sub(data.label[i], size, size) == "_" then
			data.label[i] = string.sub(data.label[i], 1, size - 1)
		end
	end

	checkUnnecessaryParameters(data, {"subject", "select", "yLabel", "xLabel", "title", "label"})

	local observerType
	if data.xAxis == nil then
		observerType = TME_OBSERVERS.DYNAMICGRAPHIC
	else
		observerType = TME_OBSERVERS.GRAPHIC
		table.insert(data.select, data.xAxis)
	end

	local observerParams = {}
	local subject = data.subject
	if type(subject) == "Automaton" then
		local locatedInCell = data.location
		if type(locatedInCell) ~= "Cell" then
			customError("Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".")
		else
			table.insert(observerParams, locatedInCell)
		end
	end
	table.insert(observerParams, data.title)
	table.insert(observerParams, data.xLabel)
	table.insert(observerParams, data.yLabel)

    local label = ""

    if type(data.label) == "table" then
        local labelCount = #data.label
        local attrCount = #data.select

        if labelCount < attrCount then
            label = table.concat(data.label, ";")
            for i = labelCount + 1, attrCount do
                label = label..";"..tostring(i)..";"
            end
        else
            label = table.concat(data.label, ";")
        end
    end

	table.insert(observerParams, label)

	local id

	if subject.cObj_ then
		if type(subject) == "CellularSpace" then
			id = subject.cObj_:createObserver(observerType, {}, data.select, observerParams, subject.cells)
		else
			if type(subject) == "Society" then
				subject.observerId = 1 -- TODO: verify why this line is necessary
			end
			id = subject.cObj_:createObserver(observerType, data.select, observerParams)
		end
	else
		id = subject:createObserver(observerType, data.select, observerParams)
	end	
    table.insert(createdObservers, {subject = data.subject, id = id})
	return id
end

