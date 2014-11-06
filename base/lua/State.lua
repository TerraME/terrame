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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Rodrigo Reis Pereira
--#########################################################################################

--[[
State_ = {
	type_ = "State",
	--#- Return a string with the id of the State.
	getId = function(self) 
		id = self.cObj_:getID()
		return id
	end,
	--#- Change the id of the State. It returns a boolean value indicating whether the operation was succesfully executed.
	-- @param idValue A string that will be set as the id of the State.
	setId = function(self, idValue)
		local idOld = self.cObj_:getID()

		if type(idValue) ~= "string" then
			incompatibleTypeError(1, "string", idValue)
		end	

		self.id = idValue
		self.cObj_:setid(idValue)
	end
}
--]]

--metaTableState_ = {__index = State_, __tostring = tostringTerraME}
metaTableState_ = {__tostring = tostringTerraME}
--- A container of Jumps and Flows. Every State also has an id to identify itself in the Jumps of
-- other States within the same Agent or Automaton.
-- @param data A table that contains the State attributes.
-- @param data.id A string with the unique identifier of the State.
-- @usage State {
--     id = "working",
--     Jump{...},
--     Flow{...}
-- }
function State(data)
	if type(data) ~= "table" then
		if data == nil then
			data = {}
		else
 			tableParameterError("State")
 		end
	end

	local cObj = TeState()

	if data.id == nil then
		data.id = "1"
	elseif type(data.id) ~= "string" then
		incompatibleTypeError("id", "string", data.id)
	end
	--data.__tostring = tostringTerraME
	cObj:config(data.id)

	for i, ud in pairs(data) do
		if type(ud) == "table" then cObj:add(ud.cObj_) end
		if type(ud) == "userdata" then cObj:add(ud) end
	end
--	setmetatable(data, metaTableState_)
  
	return cObj
end

