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

metaTableFlow_ = {__tostring = _Gtme.tostring}

--- A Flow describes the behavior of an automaton or Agent in a given State.
-- @arg data.1st A function(ev, agent, cell), where the arguments are: an Event that 
-- activated the Flow, the Automaton or Agent that owns the Flow, and the Cell over which
-- the Flow will be evaluated.
-- @usage Flow{function(ev, agent, cell)
--     agent.value = agent.value + 2
-- end}
function Flow(data)
	local cObj = TeFlow()

	if data == nil then
		data = {}
	elseif type(data) ~= "table" then
		customError(tableArgumentMsg())
	end

	data.rule = cObj

	if type(data[1]) ~= "function" then
		customError("Flow constructor expected a function as argument.")
	end

	setmetatable(data, metaTableFlow_)
	cObj:setReference(data)

	return cObj
end

