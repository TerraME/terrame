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
--          Antonio Jose da Cunha Rodrigues
--          Raian Vargas Maretto
--#########################################################################################

-- @header Some basic and useful functions for modeling.

--- Create a Neighborhood for each Cell of the CellularSpace.
-- @arg data.inmemory If true (default), a Neighborhood will be built and stored for
-- each Cell of the CellularSpace. The Neighborhoods will change only if the
-- modeler add or remove neighbors explicitly. In this case, if any of the attributes 
-- the Neighborhood is based on changes then the resulting Neighborhood might be different.
-- Neighborhoods not in memory also help the simulation to run with larger datasets,
-- as they are not explicitly represented, but they consume more
-- time as they need to be built again and again along the simulation.
-- @arg data.strategy A string with the strategy to be used for creating the Neighborhood. 
-- See the table below.
-- @tabular strategy
-- Strategy & Description & Compulsory Arguments & Optional Arguments \
-- "3x3" & A 3x3 (Couclelis) Neighborhood (Deprecated. Use mxn instead).  & name, filter, weight, inmemory \
-- "coord" & A bidirected relation between two CellularSpaces connecting Cells with the same 
-- (x, y) coordinates. & target & name, inmemory\
-- "function" & A Neighborhood based on a function where any other Cell can be a neighbor. & 
-- filter & name, weight, inmemory \
-- "moore"(default) & A Moore (queen) Neighborhood, connecting each Cell to its (at most) 
-- eight touching Cells. & & name, self, inmemory \
-- "mxn" & A m (columns) by n (rows) Neighborhood within the CellularSpace or between two
-- CellularSpaces if target is used. & m & name, n, filter, weight, target, inmemory \
-- "vonneumann" & A von Neumann (rook) Neighborhood, connecting each Cell to its (at most)
-- four ortogonally surrounding Cells. & & name, self, inmemory
-- @arg data.filter A function(Cell, Cell)->bool, where the first argument is the Cell itself
-- and the other represent a possible neighbor. It returns true when the neighbor will be
-- included in the relation. In the case of two CellularSpaces, this function is called twice
-- for e ach pair of Cells, first filter(c1, c2) and then filter(c2, c1), where c1 belongs to
-- cs1 and c2 belongs to cs2. The default value is a function that returns true.
-- @arg data.m Number of columns. If m is even then it will be increased by one to keep the
-- Cell in the center of the Neighborhood. The default value is 3.
-- @arg data.n Number of rows. If n is even then it will be increased by one to keep the Cell
-- in the center of the Neighborhood. The default value is m.
-- @arg data.name A string with the name of the Neighborhood to be created. 
-- The default value is "1".
-- @arg data.self Add the Cell as neighbor of itself? The default value is false. Note that the 
-- functions that do not require this argument always depend on a filter function, which will
-- define whether the Cell can be neighbor of itself.
-- @arg data.target Another CellularSpace whose Cells will be used to create neighborhoods.
-- @arg data.weight A function (Cell, Cell)->number, where the first argument is the Cell
-- itself and the other represent its neighbor. It returns the weight of the relation. This
-- function will be called only if filter returns true.
-- @usage cs:createNeighborhood2() -- moore
-- DONTRUN
createNeighborhood2 = function(self, data)
end	

--- Round a number given a precision.
-- @arg num A number.
-- @arg idp The number of decimal places to be used. The default value is zero.
-- @tabular
-- a & b \
-- value1 & value2
-- @usage -- round2(2.34566, 3)
function round2(num, idp)
	mandatoryArgument(1, "number", num)
	optionalArgument(2, "number", idp)

	if not idp then idp = 0 end

	local mult = 10 ^ idp
	return math.floor(num * mult + 0.5) / mult
end

--- Return information about the current execution. The result is a table
-- with the following values.
-- @tabular tab
-- Attribute & Description \
-- dbVersion & A string with the current TerraLib version for databases. \
-- mode & A string with the current mode for warnings ("normal", "debug", or "quiet"). \
-- path & A string with the location of TerraME in the computer. \
-- separator & A string with the directory separator. \
-- silent & A boolean value indicating whether print() calls should not be shown in the
-- screen. This parameter is set true when TerraME is executed with mode "silent".
-- @usage sessionInfo2().version
-- DONTRUN
function sessionInfo2()
	return _Gtme.info_ -- this is a global variable created when TerraME is initialized
end

--- Return the type of an object. It extends the original Lua type() to support TerraME objects,
-- whose type name (for instance "CellularSpace" or "Agent") is returned instead of "table".
-- @arg data Any object or value.
-- @usage c = Cell{value = 3}
-- print(type2(c)) -- "Cell"
-- DONTRUN
function type2(data)
	local t = _Gtme.type(data)
	if t == "table" or (t == "userdata" and getmetatable(data)) then
		if data.type_ ~= nil then
			return data.type_
		end
	end
	return t
end

