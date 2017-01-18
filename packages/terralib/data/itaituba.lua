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

-- @example Creates a project for the Itaituba region, in Para state, Brazil.

import("terralib")

proj = Project{
	file = "itaituba.tview",
	clean = true,
	localidades = filePath("Localidades_pt.shp", "terralib"),
	roads = filePath("Rodovias_lin.shp", "terralib"),
	setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
}

Layer{
	project = proj,
	name = "deforestation",
	file = filePath("Desmatamento_2000.tif", "terralib"),
	srid = 29191
}

Layer{
	project = proj,
	name = "altimetria",
	file = filePath("altimetria.tif", "terralib"),
	srid = 29191
}

cl = Layer{
	project = proj,
	name = "cells",
	clean = true,
	file = "itaituba.shp",
	input = "setores",
	resolution = 5000
}

cl:fill{
	operation = "average",
	layer = "altimetria",
	attribute = "altim"
}

cl:fill{
	operation = "coverage",
	layer = "deforestation",
	attribute = "defor"
}

if sessionInfo().system ~= "mac" then

cl:fill{
	operation = "sum",
	layer = "setores",
	attribute = "pop",
	select = "Populacao",
	area = true
}

cl:fill{
	operation = "distance",
	layer = "roads",
	attribute = "distr"
}

cl:fill{
	operation = "distance",
	layer = "localidades",
	attribute = "distl"
}

end

cs = CellularSpace{
	project = proj,
	layer = "cells"
}

m = Map{
	target = cs,
	select = "altim",
	slices = 10,
	color = "Blues"
}

if sessionInfo().system ~= "mac" then

m = Map{
	target = cs,
	select = "distl",
	slices = 10,
	color = "Reds"
}

end

m = Map{
	target = cs,
	select = "defor_167",
	slices = 10,
	color = "Greens"
}

m = Map{
	target = cs,
	select = "defor_87",
	slices = 10,
	color = "Greens"
}

if sessionInfo().system ~= "mac" then

m = Map{
	target = cs,
	select = "pop",
	slices = 10,
	color = "Purples"
}

m = Map{
	target = cs,
	select = "distr",
	slices = 10,
	color = "Reds"
}

end

