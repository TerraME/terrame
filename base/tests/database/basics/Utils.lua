-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
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
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	getConfig = function(unitTest)
		local cf = getConfig()
		unitTest:assert_nil(cf.qwertyuiop)
	end,
	CSVparseLine = function(unitTest)
		local line = CSVparseLine("2,5,aa", ",")
		unitTest:assert_equal(line[1], "2")
		unitTest:assert_equal(line[2], "5")
		unitTest:assert_equal(line[3], "aa")
	end,
	CSVread = function(unitTest)
		local mfile = file("agents.csv", "base")

		local csv = CSVread(mfile)

		unitTest:assert_equal(4, #csv)
		unitTest:assert_equal(20, csv[1].age)
	end,
	CSVwrite = function(unitTest)
		local example = {
			{age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 15, vision = 2, metabolism = 1, test = "Foo,text"},
			{age = 4, wealth = 12, vision = 2, metabolism = 2, test = "Foo@text"},
			{age = 2, wealth = 10, vision = 3, metabolism = 1, test = "Foo%text"},
			{age = 2, wealth =  9, vision = 2, metabolism = 1, test = "Foo)text"},
			{age = 1, wealth = 11, vision = 2, metabolism = 1, test = "Foo#text"},
			{age = 3, wealth = 15, vision = 1, metabolism = 2, test = "Foo=text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			{age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		local filename = unitTest:tmpFolder().."/csvwrite.csv"

		CSVwrite(example, filename)
		local data = CSVread(filename)
		unitTest:assert_not_nil(data)
		unitTest:assert_equal(#example, #data)

		for i = 1, #example do
			for k in pairs(example[i]) do
				unitTest:assert_equal(example[i][k], data[i][k])
			end
		end
	end
}

