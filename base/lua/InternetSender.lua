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

InternetSender_ = {
	type_ = "InternetSender",
}

metaTableInternetSender_ = {__index = InternetSender_}

--- An Internet connection to send attribute values of an object through a 
--- TCP or UDP protocol. Every call to notify (for example, Agent:notify()) in the target
-- activates the InternetSender.
-- @arg data.target An Agent, Cell, CellularSpace, or Society.
-- @arg data.port A number greater or equal to 50000 indicating the port of the host to transfer
-- the data. The default value is 456456.
-- @arg data.host A string with the host name to transfer the data. The default value is
-- "localhost".
-- @arg data.visible A boolean value indicating whether InternetSender will create
-- a window to display the transferred data. The default value is true.
-- @arg data.protocol A string with the protocol to be used. It can be "tcp" (default)
-- or "udp".
-- @arg data.compress Compress the data to be transfered? It might be interesting not to
-- compress when the connection is on the localhost, or when there is a very fast connection,
-- to make the simulation faster. The default value is true.
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is a single value then it can also be described as a string. As default, it selects
-- all the user-defined attributes of an object. When using a CellularSpace as subject,
-- the values in select are related to its Cells and this argument is mandatory.
-- In the case of Society, if it does not have any numeric attributes then it will use
-- the number of agents in the Society as attribute.
-- @usage InternetSender{
--     target = cs,
--     protocol = "tcp",
--     compress = false
-- }
function InternetSender(data)
	mandatoryTableArgument(data, "target")
	defaultTableValue(data, "host", "localhost")
	defaultTableValue(data, "port", 456456)
	defaultTableValue(data, "visible", true)
	defaultTableValue(data, "protocol", "udp")
	defaultTableValue(data, "compress", true)

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.target) == "Cell" then
			forEachElement(data.target, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"x", "y", "past"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx)
				end
			end)
		elseif type(data.target) == "Agent" then
			forEachElement(data.target, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if string.sub(idx, -1, -1) ~= "_" then -- SKIP
					table.insert(data.select, idx) -- SKIP
				end
			end)
		elseif type(data.target) == "CellularSpace" then
			mandatoryArgumentError("select")
		elseif type(data.target) == "Society" then
			forEachElement(data.target, function(idx, value, mtype)
				if not belong(mtype, {"number", "string", "boolean"}) then return end

				if not belong(idx, {"autoincrement", "quantity", "observerId"}) and string.sub(idx, -1, -1) ~= "_" then
					table.insert(data.select, idx) -- SKIP
				end
			end)

			if #data.select == 0 then -- SKIP
				data.select = {"#"}
			end
		else
			customError("Invalid type. InternetSender only works with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The target does not have at least one valid attribute to be used.")
	end

	mandatoryTableArgument(data, "select", "table")
	verify(#data.select > 0, "InternetSender must select at least one attribute.")

	if type(data.target) == "CellularSpace" then
		verify(#data.select == 1, "InternetSender with CellularSpace uses only one attribute.")

		local sample = data.target.cells[1][data.select[1]]

		verify(sample ~= nil, "Selected element '"..data.select[1].."' does not belong to the target.")
	else
		forEachElement(data.select, function(_, value)
			if data.target[value] == nil then
				if  value == "#" then
					if data.target.obsattrs == nil then -- SKIP
						data.target.obsattrs = {}
					end

					data.target.obsattrs["quantity_"] = true -- SKIP
					data.target.quantity_ = #data.target -- SKIP
				else
					customError("Selected element '"..value.."' does not belong to the target.")
				end
			elseif type(data.target[value]) == "function" then
				if data.target.obsattrs == nil then -- SKIP
					data.target.obsattrs = {}
				end

				data.target.obsattrs[value] = true -- SKIP
			end
		end)
	end

	if data.target.obsattrs then
		forEachElement(data.target.obsattrs, function(idx)
			for i = 1, #data.select do
				if data.select[i] == idx then -- SKIP
					data.select[i] = idx.."_" -- SKIP
					if type(data.target[idx]) == "function" then
						local mvalue = data.target[idx](data.target)
						data.target[idx.."_"] = mvalue -- SKIP
					end
				end
			end
		end)
	end

	verifyUnnecessaryArguments(data, {"target", "protocol", "select", "port", "host", "visible", "compress"})
  
	verify(data.port >= 50000, "Argument 'port' should be greater or equal to 50000, got "..data.port..".")
  
	for i = 1, #data.select do
		if data.select[i] == "#" then
			data.select[i] = "quantity_" -- SKIP
			data.target.quantity_ = #data.target -- SKIP
		end
	end

	local observerParams = {}

	observerParams.visible = data.visible
	observerParams.compress = data.compress

	table.insert(observerParams, data.port)
	table.insert(observerParams, data.host)

	local observerType

	switch(data, "protocol"):caseof{
		tcp = function() observerType = 13 end,
		udp = function() observerType = 7 end
	}

	local id
  local obs
	local target = data.target
	if type(target) == "CellularSpace" then -- SKIP
		observerParams = {observerParams}
		id, obs = target.cObj_:createObserver(observerType, {}, data.select, observerParams, target.cells)
	else
		if type(target) == "Society" then -- SKIP
			target.observerId = 1 -- TODO: verify why this line is necessary -- SKIP
		end
		id, obs = target.cObj_:createObserver(observerType, data.select, observerParams) -- SKIP
	end

	verify(id, "The observer could not be created.") -- SKIP
  
  local isender
  
  if observerType == 13 then  
    isender = TeTcpSender()
  else
    isender = TeUdpSender()
  end
  
	isender:setObserver(obs)

	data.cObj_ = logfile
	data.id = id
  
  setmetatable(data, metaTableInternetSender_)    

	table.insert(_Gtme.createdObservers, data)

	return data
end

