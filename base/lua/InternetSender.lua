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

--- Creates an Internet connection to send observed attributes of an object through a 
--- TCP or UDP port of a given IP. 
-- @arg data.subject An Agent, Cell, CellularSpace, Society.
-- @arg data.port A string or a vector of strings with ports for the respective host 
-- names to be used by udpsenders.
-- @arg data.host A string or a vector of strings with host names for udpsenders.
-- @arg data.visible A boolean value indicating whether the InternetSender will create
-- a window to display its data.
-- @arg data.protocol A string with the protocol to be used. It can be "tcp" (default)
-- or "udp".
-- @arg data.compress Compress the data to be transfered? It might be interesting not to 
-- compress when the connection is on the localhost, or when there is a very fast connection,
-- to make the simulation faster.
-- @arg data.select A vector of strings with the name of the attributes to be observed.
-- If it is only a single value then it can also be described as a string. 
-- @usage InternetSender{subject = cs}
InternetSender = function(data)
	mandatoryTableArgument(data, "subject")
	defaultTableValue(data, "host", "localhost")
	defaultTableValue(data, "port", 456456)
	defaultTableValue(data, "visible", true)
	defaultTableValue(data, "protocol", "tcp")
	defaultTableValue(data, "compress", true)

	if type(data.select) == "string" then data.select = {data.select} end

	if data.select == nil then
		data.select = {}
		if type(data.subject) == "Cell" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if idx ~= "x" and idx ~= "y" and idx ~= "past" and string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "Agent" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "CellularSpace" then
			forEachElement(data.subject, function(idx, value, mtype)
				local size = string.len(idx)
				if not belong(idx, {"minCol", "maxCol", "minRow", "maxRow", "ydim", "xdim"}) and string.sub(idx, size, size) ~= "_" then
					data.select[#data.select + 1] = idx
				end
			end)
		elseif type(data.subject) == "Society" then
			forEachElement(data.subject, function(idx, value, mtype)
				data.select[#data.select + 1] = idx
			end)
			data.select[#data.select + 1] = "#"
		else
			customError("Invalid type. InternetSender only work with Cell, CellularSpace, Agent, and Society.")
		end

		verify(#data.select > 0, "The subject does not have at least one valid attribute to be used.")
	else
		mandatoryTableArgument(data, "select", "table")
		verify(#data.select > 0, "InternetSender must select at least one attribute.")
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
	end

	checkUnnecessaryArguments(data, {"subject", "protocol", "select", "port", "host", "visible", "compress"})

	local observerType

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
	local subject = data.subject
	if subject.cObj_ then
		if type(subject) == "CellularSpace" then
			observerParams = {observerParams}
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

