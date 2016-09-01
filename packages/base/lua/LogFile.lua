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

LogFile_ = {
	type_ = "LogFile",
	--- Update the LogFile with the latest values of its target. It is usually recommended
    -- to use the LogFile as action of an Event instead of calling this function explicitly.
	-- @usage agent = Agent{
	--     age = 3
	-- }
	--
	-- log = LogFile{
	--     target = agent,
	--     file = "agent.csv",
	--     separator = ";"
	-- }
	--
	-- log:update()
	--
	-- rmFile("agent.csv")
	update = function(self)
		self.target:notify()
	end
}

metaTableLogFile_ = {__index = LogFile_}

--- A log file to save attributes of an object. The saved file uses the csv
-- standard: The first line contains the attribute names and the following lines
-- contains values according to the calls to notify().
-- @arg data.target An Agent, Cell, CellularSpace, Society.
-- @arg data.file A string with the file name to be saved. The default value is "result.csv".
-- @arg data.separator A string with the separator. The default value is ",".
-- @arg data.overwrite A boolean value indicating whether the file should be overwritten. 
-- The default value is true.
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is only a single value then it can also be described as a string.
-- As default, it selects all the user-defined attributes of an object.
-- In the case of Society, if it does not have any numeric attributes then it will use
-- the number of agents in the Society as attribute.
-- @usage agent = Agent{
--     age = 3
-- }
--
-- LogFile{
--     target = agent,
--     file = "agent.csv",
--     separator = ";"
-- }
function LogFile(data)
	verifyNamedTable(data)
	verifyUnnecessaryArguments(data, {"target", "select", "file", "separator", "overwrite"})

	mandatoryTableArgument(data, "target")
	defaultTableValue(data, "separator", ",")
	defaultTableValue(data, "file", "result.csv")
	defaultTableValue(data, "overwrite", true)

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.target) == "Cell" then
			forEachOrderedElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"x", "y", "past"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "Agent" then
			forEachOrderedElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "CellularSpace" then
			forEachOrderedElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim", "source"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "Society" then
			forEachOrderedElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"autoincrement", "quantity", "observerId"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)

			if #data.select == 0 then
				data.select = {"#"}
			end
		else
			customError("Invalid type. LogFile only works with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The target does not have at least one valid attribute to be used.")
	end

	mandatoryTableArgument(data, "select", "table")
	verify(#data.select > 0, "LogFile must select at least one attribute.")
	forEachElement(data.select, function(_, value)
		if data.target[value] == nil then
			if value == "#" then
				if data.target.obsattrs == nil then
					data.target.obsattrs = {}
				end

				data.target.obsattrs["quantity_"] = true
				data.target.quantity_ = #data.target
			else
				customError("Selected element '"..value.."' does not belong to the target.")
			end
		elseif type(data.target[value]) == "function" then
			if data.target.obsattrs == nil then
				data.target.obsattrs = {}
			end

			data.target.obsattrs[value] = true
		end
	end)

	if data.target.obsattrs then
		forEachElement(data.target.obsattrs, function(idx)
			for i = 1, #data.select do
				if data.select[i] == idx then
					data.select[i] = idx.."_"
					local mvalue = data.target[idx](data.target)
					data.target[idx.."_"] = mvalue
				end
			end
		end)
	end

	for i = 1, #data.select do
		if data.select[i] == "#" then
			data.select[i] = "quantity_"
			data.target.quantity_ = #data.target
		end
	end

	if data.overwrite or not File(data.file):exists() then
		data.mode = "w"
	else
		data.mode = "w+"
	end
	
	local observerType = 2
	local observerParams = {}
	local target = data.target
	local id
	local obs

	table.insert(observerParams, data.file)
	table.insert(observerParams, data.separator)
	table.insert(observerParams, data.mode)

	if type(target) == "CellularSpace" then
		id, obs = target.cObj_:createObserver(observerType, {}, data.select, observerParams, target.cells)
	else
		id, obs = target.cObj_:createObserver(observerType, data.select, observerParams)
	end

	local logfile = TeLogFile()
	logfile:setObserver(obs)

	data.cObj_ = logfile
	data.id = id

	setmetatable(data, metaTableLogFile_)
	table.insert(_Gtme.createdObservers, data)
	return data
end

