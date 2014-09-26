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
		incompatibleTypesErrorMsg(attr, allowedType, mtype, level + 1)
	end
end

local compulsoryTableElement = function(table, attr, level)
	if table[attr] == nil then
		mandatoryArgumentErrorMsg(attr, level + 1)
	end
end

Chart = function(data)
	compulsoryTableElement(data, "subject", 3)
	optionalTableElement(data, "yLabel", "string", 3)
	optionalTableElement(data, "xLabel", "string", 3)
	optionalTableElement(data, "xAxis",  "string", 3)
	optionalTableElement(data, "title",  "string", 3)

	if data.yLabel == nil then data.yLabel = "" end
	if data.xLabel == nil then data.xLabel = "" end
	if data.title  == nil then data.title  = "" end

	if data.select == nil then
		data.select = {}

		if type(data.subject) == "Cell" then
			forEachElement(data.subject, function(idx, value, mtype)
				if mtype == "number" and idx ~= "x" and idx ~= "y" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "CellularSpace" then
			forEachElement(data.subject, function(idx, value, mtype)
				if mtype == "number" and not belong(idx, {"minCol","maxCol", "minRow", "maxRow", "ydim", "xdim"}) then
					data.select[#data.select + 1] = idx
				end
			end)
		else
			forEachElement(data.subject, function(idx, value, mtype)
				if mtype == "number" then
					data.select[#data.select + 1] = idx
				end
			end)
		end

		verify(#data.select > 0, "The subject does not have at least one valid numeric attribute to be used.", 4)
	else
		if type(data.select) == "string" then
			data.select = {data.select}
		else
			optionalTableElement(data, "select", "table", 3)
		end

		forEachElement(data.select, function(_, value)
			if data.subject[value] == nil then
				customErrorMsg("Selected element '"..value.."' does not belong to the subject.", 5)
			elseif type(data.subject[value]) ~= "number" then
				customErrorMsg("Selected element '"..value.."' should be a number, got "..type(data.subject[value])..".", 5)
			end
		end)
	end

	verify(#data.select > 0, "Charts must select at least one attribute.", 3)

	if data.labels == nil then data.labels = data.select end

	checkUnnecessaryParameters(data, {"subject", "select", "yLabel", "xLabel", "title", "labels"}, 3)

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
			customErrorMsg("Observing an Automaton requires parameter 'location' to be a Cell, got "..type(locatedInCell)..".", 4)
		else
			table.insert(observerParams, locatedInCell)
		end
	end
	table.insert(observerParams, data.title)
	table.insert(observerParams, data.xLabel)
	table.insert(observerParams, data.yLabel)

    local labels = ""

    if type(data.labels) == "table" then
        local labelsCount = #data.labels
        local attrCount = #data.select

        if labelsCount < attrCount then
            labels = table.concat(data.labels, ";")
            for i = labelsCount + 1, attrCount do
                labels = labels..";"..tostring(i)..";"
            end
        else
            labels = table.concat(data.labels, ";")
        end
    end

	table.insert(observerParams, labels)

	if subject.cObj_ then
		if type(subject) == "CellularSpace" then
			return subject.cObj_:createObserver(observerType, {}, data.select, observerParams, subject.cells)
		else
			return subject.cObj_:createObserver(observerType, data.select, observerParams)
		end
	else
		return subject:createObserver(observerType, data.select, observerParams)
	end	
end

