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

TextScreen_ = {
	type_ = "TextScreen",
	--- Save a TextScreen into a file. Supported extensions are bmp, jpg, png, and tiff.
	-- @arg file A string with the file name.
	-- @usage agent = Agent{
	--     size = 5,
	--     age = 1
	-- }
	--
	-- ts = TextScreen{
	--     target = agent,
	--     select = {"size" , "age"}
	-- }
	--
	-- ts:save("file.bmp")
	-- File("file.bmp"):delete()
	save = function(self, file)
		local _, extension = string.match(file, "(.-)([^%.]+)$")

		local availableExtensions = {bmp = true, jpg = true, png = true, tiff = true}

		if not availableExtensions[extension] then
			invalidFileExtensionError(1, extension)
		end

		extension = string.upper(extension)

		self.cObj_:save(file, extension)
	end,
	--- Update the TextScreen with the latest values of its target. It is usually recommended
	-- to use the TextScreen as action of an Event instead of calling this function explicitly.
	-- @arg modelTime An optional argument that can be a number with the current time or an Event.
	-- @usage agent = Agent{
	--     size = 5,
	--     age = 1
	-- }
	--
	-- ts = TextScreen{
	--     target = agent,
	--     select = {"size" , "age"}
	-- }
	--
	-- ts:update()
	update = function(self, modelTime)
		self.target:notify(modelTime)
	end
}

metaTableTextScreen_ = {__index = TextScreen_}

--- A window with a table to show the attributes of an object along the simulation.
-- Each call to notify() add one more line to the content of the window.
-- @arg data.target An Agent, Cell, CellularSpace, Society.
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is only a single value then it can also be described as a string.
-- As default, it selects all the user-defined attributes of an object.
-- In the case of Society, if it does not have any numeric attributes then it will use
-- the number of agents in the Society as attribute.
-- @usage agent = Agent{
--     size = 5,
--     age = 1
-- }
--
-- TextScreen{
--     target = agent,
--     select = {"size" , "age"}
-- }
function TextScreen(data)
	verifyNamedTable(data)
	verifyUnnecessaryArguments(data, {"target", "select"})
	mandatoryTableArgument(data, "target")

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.target) == "Cell" then
			forEachElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"x", "y", "past"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "Agent" then
			forEachElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "CellularSpace" then
			forEachElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim", "source"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "Society" then
			forEachElement(data.target, function(idx, _, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"autoincrement", "quantity", "observerId"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)

			if #data.select == 0 then
				data.select = {"#"}
			end
		else
			customError("Invalid type. TextScreen only works with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The target does not have at least one valid attribute to be used.")
	end

	mandatoryTableArgument(data, "select", "table")
	verify(#data.select > 0, "TextScreen must select at least one attribute.")
	forEachElement(data.select, function(_, value)
		if data.target[value] == nil then
			if  value == "#" then
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
					if type(data.target[idx]) == "function" then
						local mvalue = data.target[idx](data.target)
						data.target[idx.."_"] = mvalue
					end
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

	local observerType = 1
	local observerParams = {}
	local target = data.target
	local id
	local obs

	if type(target) == "CellularSpace" then
		id, obs = target.cObj_:createObserver(observerType, {}, data.select, observerParams, target.cells)
	else
		id, obs = target.cObj_:createObserver(observerType, data.select, observerParams)
	end

	local textScreen = TeTextScreen()
	textScreen:setObserver(obs)

	data.cObj_ = textScreen
	data.id = id

	setmetatable(data, metaTableTextScreen_)

	table.insert(_Gtme.createdObservers, data)

	return data
end

