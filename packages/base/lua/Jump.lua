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

--- Control a discrete transition between States. If the method in the first argument returns
-- true, the target becomes the new active State.
-- @arg data.1st a function that returns a boolean value and takes as arguments an Event,
-- an Agent or Automaton, and a Cell, respectively.
-- @arg data.target a string with another State id.
-- @usage Jump{
--     function(ev, agent, c)
--         return c.water > c.capInf
--     end,
--     target = "wet"
-- }
function Jump(data)
	if type(data) ~= "table" then
		customError(tableArgumentMsg())
	end

	local cObj = TeJump()
	data.rule = cObj

	if type(data[1]) ~= "function" then
		customError("Jump constructor expected a function as first argument.")
	end

	if type(data.target) ~= "string" then
		data.target = "st1"
	end
	cObj:setTargetControlModeName(data.target)
	cObj:setReference(data)
	return cObj
end

