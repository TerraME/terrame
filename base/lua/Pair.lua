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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

Pair_ = {
	-- ESSE TYPE PRECISA REVISAO
	-- IMPLICA EM FALHA DO TIMER, EVENT  
	--type_ = "Pair", 
	notify = function(self, modelTime)
		if (modelTime == nil) or (type(modelTime) ~= 'number') then 
			modelTime = 0
		end
		if (type(self.cObj_[1]) == 'userdata') then
			self.cObj_[1]:notify(modelTime)
		end
	end,
	-- TODO: Verify if it can be moved to Event.lua
	config = function(self, time, period, priority)
		if time == nil then
			time = self.cObj_[1]:getTime()
		elseif type(time) ~= "number" then
			incompatibleTypeError("#1", "number", time)
		end

		if period == nil then
			period = self.cObj_[1]:getPeriod()
		elseif type(period) ~= "number" then
			incompatibleTypeError("#2", "number", period)
		elseif period <= 0 then
			incompatibleValueError("#2", "positive number", period)
		end

		if priority == nil then
			priority = self.cObj_[1]:getPriority()
		elseif type(priority) ~= "number" then
			incompatibleTypeError("#3", "number", priority)
		end

		self.cObj_[1]:config(time, period, priority)
	end
}

local metaTablePair_ = {__index = Pair_, __tostring = tostringTerraME}

function Pair(data)
	if data == nil then data = {} end

	if getn(data) ~= 2 then
		customError("A pair must have two attributes.")
	end

	setmetatable(data, metaTablePair_)
	data.cObj_ = data	

	return data
end

