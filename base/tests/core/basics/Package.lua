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
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	customError = function(unitTest)
		local error_func = function()
			customError("test.")
		end
		unitTest:assertError(error_func, "test.")
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning("test.")
		end
		unitTest:assertError(error_func, "test.")
	end,
	defaultTableValue = function(unitTest)
		local t = {x = 5}
		defaultTableValue(t, "y", 8)

		unitTest:assertEquals(t.y, 8)
	end,
	defaultValueMsg = function(unitTest)
		unitTest:assertEquals(defaultValueMsg("aaa", 2), "Argument 'aaa' could be removed as it is the default value (2).")
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning("size", 2)
		end
		unitTest:assertError(error_func, defaultValueMsg("size", 2))
	end,
	deprecatedFunction = function(unitTest)
		local error_func = function()
			deprecatedFunction("abc", "def")
		end
		unitTest:assertError(error_func, deprecatedFunctionMsg("abc", "def"))
	end,
	deprecatedFunctionMsg = function(unitTest)
		unitTest:assertEquals(deprecatedFunctionMsg("aaa", "bbb"), "Function 'aaa' is deprecated. Use 'bbb' instead.")
	end,
	file = function(unitTest)
		unitTest:assertType(file("simple-cs.csv"), "string")
	end,
	incompatibleTypeError = function(unitTest)
		local error_func = function()
			incompatibleTypeError("cell", "Cell", Agent{})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("cell", "Cell", Agent{}))
	end,
	incompatibleTypeMsg = function(unitTest)
		unitTest:assertEquals(incompatibleTypeMsg("aaa", "string", 2), "Incompatible types. Argument 'aaa' expected string, got number.")
	end,
	incompatibleValueError = function(unitTest)
		local error_func = function()
			incompatibleValueError("position", "1, 2, or 3", "4")
		end
		unitTest:assertError(error_func, incompatibleValueMsg("position", "1, 2, or 3", "4"))

		local error_func = function()
			incompatibleValueError(1, "1, 2, or 3", "4")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "1, 2, or 3", "4"))

		local error_func = function()
			incompatibleValueError(1, "1, 2, or 3")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "1, 2, or 3"))
	end,
	incompatibleValueMsg = function(unitTest)
		local str = incompatibleValueMsg("attr", "positive", -2)
		unitTest:assertEquals(str, "Incompatible values. Argument 'attr' expected positive, got -2.")
	end,
	integerArgument = function(unitTest)
		local error_func = function()
			integerArgument(1, 0.2)
		end
		unitTest:assertError(error_func, integerArgumentMsg(1, 0.2))
	end,
	integerArgumentMsg = function(unitTest)
		local m = integerArgumentMsg("a", 2.3)
		unitTest:assertEquals(m, "Incompatible values. Argument 'a' expected integer number, got 2.3.")
	end,
	integerTableArgument = function(unitTest)
		local t = {x = 2.5}
		local error_func = function()
			integerTableArgument(t, "x")
		end
		unitTest:assertError(error_func, integerArgumentMsg("x", 2.5))
	end,
	invalidFileExtensionError = function(unitTest)
		local error_func = function()
			invalidFileExtensionError("file", ".txt")
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("file", ".txt"))
	end,
	invalidFileExtensionMsg = function(unitTest)
		unitTest:assertEquals(invalidFileExtensionMsg("aaa", "bbb"), "Argument 'aaa' does not support extension 'bbb'.")
		unitTest:assertEquals(invalidFileExtensionMsg(1, "bbb"), "Argument '#1' does not support extension 'bbb'.")
	end,
	isLoaded = function(unitTest)
		unitTest:assert(isLoaded("base"))
	end,
	mandatoryArgument = function(unitTest)
		local error_func = function()
			mandatoryArgument(1, "string")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			mandatoryArgument(1, "string", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	mandatoryArgumentError = function(unitTest)
		local error_func = function()
			mandatoryArgumentError("neighborhood")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("neighborhood"))
	end,
	mandatoryArgumentMsg = function(unitTest)
		unitTest:assertEquals(mandatoryArgumentMsg("aaa"), "Argument 'aaa' is mandatory.")
	end,
	mandatoryTableArgument = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			mandatoryTableArgument(mtable, "bbb", "string")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bbb", "string", 3))

		error_func = function()
			mandatoryTableArgument(mtable, "ddd", "string")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("ddd", "string"))
	end,
	namedArgumentsMsg = function(unitTest)
		unitTest:assertEquals(namedArgumentsMsg(), "Arguments must be named.")
	end,
	optionalArgument = function(unitTest)
		local error_func = function()
			optionalArgument(1, "string", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	optionalTableArgument = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			optionalTableArgument(mtable, "bbb", "string")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bbb", "string", 3))
	end,
	packageInfo = function(unitTest)
		local r = packageInfo()

		unitTest:assertEquals(r.version, "2.0")
		unitTest:assertEquals(r.date, "17 October 2014")
		unitTest:assertEquals(r.package, "base")
		unitTest:assertEquals(r.url, "http://www.terrame.org")

		r = packageInfo("terrame")
		unitTest:assertEquals(r.package, "base")

		r = packageInfo("TerraME")
		unitTest:assertEquals(r.package, "base")
	end,
	positiveArgument = function(unitTest)
		local error_func = function()
			positiveArgument(1, 0)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, 0))

		local error_func = function()
			positiveArgument(1, -2)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -2))

		local error_func = function()
			positiveArgument(1, -2, true)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -2, true))
	end,
	positiveArgumentMsg = function(unitTest)
		local m = positiveArgumentMsg("a", -2)
		unitTest:assertEquals(m, "Incompatible values. Argument 'a' expected positive number (except zero), got -2.")

		m = positiveArgumentMsg(1, -2, true)
		unitTest:assertEquals(m, "Incompatible values. Argument '#1' expected positive number (including zero), got -2.")
	end,
	positiveTableArgument = function(unitTest)
		local t = {x = -2}
		local error_func = function()
			positiveTableArgument(t, "x")
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", -2))

		local t = {x = 0}
		local error_func = function()
			positiveTableArgument(t, "x")
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", 0))

		local t = {x = -1}
		local error_func = function()
			positiveTableArgument(t, "x", true)
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", -1, true))
	end,
	resourceNotFoundError = function(unitTest)
		local error_func = function()
			resourceNotFoundError("file", "/usr/local/file.txt")
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", "/usr/local/file.txt"))
	end,
	resourceNotFoundMsg = function(unitTest)
		unitTest:assertEquals(resourceNotFoundMsg("aaa", "bbb"), "Resource 'bbb' not found for argument 'aaa'.")
		unitTest:assertEquals(resourceNotFoundMsg(2, "bbb"), "Resource 'bbb' not found for argument '#2'.")
	end,
	suggestion = function(unitTest)
		local t = {
			aaaaa = true,
			bbbbb = true,
			ccccc = true
		}

		unitTest:assertEquals(suggestion("aaaab", t), "aaaaa")
		unitTest:assertNil(suggestion("ddddd", t))
	end,
	switch = function(unitTest)
		local count = 0

		local data = {att = "abc"}
		switch(data, "att"):caseof{
			abc = function() count = count + 1 end
		}

		local data = {}
		switch(data, "att"):caseof{
			missing = function() count = count + 1 end
		}

		unitTest:assertEquals(count, 2)
	end,
	switchInvalidArgument = function(unitTest)
		local t = {
			aaaaa = true,
			bbbbb = true,
			ccccc = true
		}

		local error_func = function()
			switchInvalidArgument("arg", "aaaab", t)
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("aaaab", "arg", "aaaaa"))

		local error_func = function()
			switchInvalidArgument("arg", "ddddd", t)
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("ddddd", "arg", t))
	end,
	switchInvalidArgumentMsg = function(unitTest)
		local options = {
			aaa = true,
			bbb = true,
			ccc = true
		}
		local str = switchInvalidArgumentMsg("ddd", "attr", options)
		unitTest:assertEquals(str, "'ddd' is an invalid value for argument 'attr'. It must be a string from the set ['aaa', 'bbb', 'ccc'].")

	end,
	switchInvalidArgumentSuggestionMsg = function(unitTest)
		local str = switchInvalidArgumentSuggestionMsg("aab", "attr", "aaa")
		unitTest:assertEquals(str, "'aab' is an invalid value for argument 'attr'. Do you mean 'aaa'?")
	end,
	tableArgumentMsg = function(unitTest)
		unitTest:assertEquals(tableArgumentMsg(), "Argument must be a table.")
	end,
	toLabel = function(unitTest)
		sessionInfo().interface = true
		unitTest:assertEquals(toLabel("maxValue"), "'Max Value'")
		unitTest:assertEquals(toLabel("maxValue", "tab"), "'Max Value' (in 'Tab')")

		sessionInfo().interface = nil
		unitTest:assertEquals(toLabel("maxValue"), "'maxValue'")
		unitTest:assertEquals(toLabel("maxValue", "tab"), "'tab.maxValue'")
	end,
	unnecessaryArgumentMsg = function(unitTest)
		unitTest:assertEquals(unnecessaryArgumentMsg("aaa"), "Argument 'aaa' is unnecessary.")
	end,
	valueNotFoundMsg = function(unitTest)
		unitTest:assertEquals(valueNotFoundMsg("aaa", "bbb"), "Value 'bbb' not found for argument 'aaa'.")
		unitTest:assertEquals(valueNotFoundMsg(2, "bbb"), "Value 'bbb' not found for argument '#2'.")
	end,
	verifyUnnecessaryArguments = function(unitTest)
		local error_func = function(unitTest)
			verifyUnnecessaryArguments({aaa = "aaa"}, {"abc", "acd", "aab"})
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("aaa"))

		local error_func = function(unitTest)
			verifyUnnecessaryArguments({aaaa = "aaa"}, {"aabc", "aacd", "aaab"})
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("aaaa", "aaab"))
	end,
	verifyNamedTable = function(unitTest)
		local error_func = function()
			verifyNamedTable()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		local error_func = function()
			verifyNamedTable(123)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		local error_func = function()
			verifyNamedTable{x = 3, 3, 4}
		end
		unitTest:assertError(error_func, "All elements of the argument must be named.")
	end,
	valueNotFoundError = function(unitTest)
		local error_func = function()
			valueNotFoundError("1", "neighborhood")
		end
		unitTest:assertError(error_func, "Value 'neighborhood' not found for argument '1'.")
	end,
	verify = function(unitTest)
		local error_func = function(unitTest)
			verify(false, "error")
		end
		unitTest:assertError(error_func, "error")
	end
}

