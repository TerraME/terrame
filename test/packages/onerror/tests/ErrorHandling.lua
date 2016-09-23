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
	customError2 = function(unitTest)
		local error_func = function()
			customError2("test.")
		end
		unitTest:assertError(error_func, "test.")
	end,
	customWarning2 = function(unitTest)
		local error_func = function()
			customWarning2("test.")
		end
		unitTest:assertError(error_func, "test.")
	end,
	defaultTableValue2 = function(unitTest)
		local t = {x = 5}
		defaultTableValue2(t, "y", 8)

		unitTest:assertEquals(t.y, 8)
	end,
	defaultValueMsg2 = function(unitTest)
		unitTest:assertEquals(defaultValueMsg2("aaa", 2), "Argument 'aaa' could be removed as it is the default value (2).")
	end,
	defaultValueWarning2 = function(unitTest)
		local error_func = function()
			defaultValueWarning2("size", 2)
		end
		unitTest:assertError(error_func, defaultValueMsg("size", 2))
	end,
	deprecatedFunction2 = function(unitTest)
		local error_func = function()
			deprecatedFunction2("abc", "def")
		end
		unitTest:assertError(error_func, deprecatedFunctionMsg("abc", "def"))
	end,
	deprecatedFunctionMsg2 = function(unitTest)
		unitTest:assertEquals(deprecatedFunctionMsg2("aaa", "bbb"), "Function 'aaa' is deprecated. Use 'bbb' instead.")
	end,
	incompatibleTypeError2 = function(unitTest)
		local error_func = function()
			incompatibleTypeError2("cell", "Cell", Agent{})
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("cell", "Cell", Agent{}))
	end,
	incompatibleTypeMsg2 = function(unitTest)
		unitTest:assertEquals(incompatibleTypeMsg2("aaa", "string", 2), "Incompatible types. Argument 'aaa' expected string, got number.")
	end,
	incompatibleValueError2 = function(unitTest)
		local error_func = function()
			incompatibleValueError2("position", "1, 2, or 3", "4")
		end
		unitTest:assertError(error_func, incompatibleValueMsg("position", "1, 2, or 3", "4"))

		local error_func = function()
			incompatibleValueError2(1, "1, 2, or 3", "4")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "1, 2, or 3", "4"))

		local error_func = function()
			incompatibleValueError2(1, "1, 2, or 3")
		end
		unitTest:assertError(error_func, incompatibleValueMsg(1, "1, 2, or 3"))
	end,
	incompatibleValueMsg2 = function(unitTest)
		local str = incompatibleValueMsg2("attr", "positive", -2)
		unitTest:assertEquals(str, "Incompatible values. Argument 'attr' expected positive, got -2.")

		local str = incompatibleValueMsg2("attr", "positive", "5")
		unitTest:assertEquals(str, "Incompatible values. Argument 'attr' expected positive, got '5'.")
	end,
	integerArgument2 = function(unitTest)
		local error_func = function()
			integerArgument2(1, 0.2)
		end
		unitTest:assertError(error_func, integerArgumentMsg(1, 0.2))
	end,
	integerArgumentMsg2 = function(unitTest)
		local m = integerArgumentMsg2("a", 2.3)
		unitTest:assertEquals(m, "Incompatible values. Argument 'a' expected integer number, got 2.3.")
	end,
	integerTableArgument2 = function(unitTest)
		local t = {x = 2.5}
		local error_func = function()
			integerTableArgument2(t, "x")
		end
		unitTest:assertError(error_func, integerArgumentMsg("x", 2.5))
	end,
	invalidFileExtensionError2 = function(unitTest)
		local error_func = function()
			invalidFileExtensionError2("file", ".txt")
		end
		unitTest:assertError(error_func, invalidFileExtensionMsg("file", ".txt"))
	end,
	invalidFileExtensionMsg2 = function(unitTest)
		unitTest:assertEquals(invalidFileExtensionMsg2("aaa", "bbb"), "Argument 'aaa' does not support extension 'bbb'.")
		unitTest:assertEquals(invalidFileExtensionMsg2(1, "bbb"), "Argument '#1' does not support extension 'bbb'.")
	end,
	mandatoryArgument2 = function(unitTest)
		local error_func = function()
			mandatoryArgument2(1, "string")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			mandatoryArgument2(1, "string", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	mandatoryArgumentError2 = function(unitTest)
		local error_func = function()
			mandatoryArgumentError2("neighborhood")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("neighborhood"))
	end,
	mandatoryArgumentMsg2 = function(unitTest)
		unitTest:assertEquals(mandatoryArgumentMsg2("aaa"), "Argument 'aaa' is mandatory.")
	end,
	mandatoryTableArgument2 = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			mandatoryTableArgument2(mtable, "bbb", "string")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bbb", "string", 3))

		error_func = function()
			mandatoryTableArgument2(mtable, "ddd", "string")
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("ddd", "string"))
	end,
	namedArgumentsMsg2 = function(unitTest)
		unitTest:assertEquals(namedArgumentsMsg2(), "Arguments must be named.")
	end,
	optionalArgument2 = function(unitTest)
		local error_func = function()
			optionalArgument2(1, "string", 2)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	optionalTableArgument2 = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			optionalTableArgument2(mtable, "bbb", "string")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg("bbb", "string", 3))
	end,
	positiveArgument2 = function(unitTest)
		local error_func = function()
			positiveArgument2(1, 0)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, 0))

		local error_func = function()
			positiveArgument2(1, -2)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -2))

		local error_func = function()
			positiveArgument2(1, -2, true)
		end
		unitTest:assertError(error_func, positiveArgumentMsg(1, -2, true))
	end,
	positiveArgumentMsg2 = function(unitTest)
		local m = positiveArgumentMsg2("a", -2)
		unitTest:assertEquals(m, "Incompatible values. Argument 'a' expected positive number (except zero), got -2.")

		m = positiveArgumentMsg2(1, -2, true)
		unitTest:assertEquals(m, "Incompatible values. Argument '#1' expected positive number (including zero), got -2.")
	end,
	positiveTableArgument2 = function(unitTest)
		local t = {x = -2}
		local error_func = function()
			positiveTableArgument2(t, "x")
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", -2))

		local t = {x = 0}
		local error_func = function()
			positiveTableArgument2(t, "x")
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", 0))

		local t = {x = -1}
		local error_func = function()
			positiveTableArgument2(t, "x", true)
		end
		unitTest:assertError(error_func, positiveArgumentMsg("x", -1, true))
	end,
	resourceNotFoundError2 = function(unitTest)
		local error_func = function()
			resourceNotFoundError2("file", "/usr/local/file.txt")
		end
		unitTest:assertError(error_func, resourceNotFoundMsg("file", "/usr/local/file.txt"))
	end,
	resourceNotFoundMsg2 = function(unitTest)
		unitTest:assertEquals(resourceNotFoundMsg2("aaa", "bbb"), "Resource 'bbb' not found for argument 'aaa'.")
		unitTest:assertEquals(resourceNotFoundMsg2(2, "bbb"), "Resource 'bbb' not found for argument '#2'.")
	end,
	strictWarning2 = function(unitTest)
		local error_func = function()
			strictWarning2("test.")
		end
		unitTest:assertError(error_func, "test.")
	end,
	suggestion2 = function(unitTest)
		local t = {
			aaaaa = true,
			bbbbb = true,
			ccccc = true
		}

		unitTest:assertEquals(suggestion2("aaaab", t), "aaaaa")
		unitTest:assertNil(suggestion2("ddddd", t))
	end,
	switchInvalidArgument2 = function(unitTest)
		local t = {
			aaaaa = true,
			bbbbb = true,
			ccccc = true
		}

		local error_func = function()
			switchInvalidArgument2("arg", "aaaab", t)
		end
		unitTest:assertError(error_func, switchInvalidArgumentSuggestionMsg("aaaab", "arg", "aaaaa"))

		local error_func = function()
			switchInvalidArgument2("arg", "ddddd", t)
		end
		unitTest:assertError(error_func, switchInvalidArgumentMsg("ddddd", "arg", t))
	end,
	switchInvalidArgumentMsg2 = function(unitTest)
		local options = {
			aaa = true,
			bbb = true,
			ccc = true
		}
		local str = switchInvalidArgumentMsg2("ddd", "attr", options)
		unitTest:assertEquals(str, "'ddd' is an invalid value for argument 'attr'. It must be a string from the set ['aaa', 'bbb', 'ccc'].")

	end,
	switchInvalidArgumentSuggestionMsg2 = function(unitTest)
		local str = switchInvalidArgumentSuggestionMsg2("aab", "attr", "aaa")
		unitTest:assertEquals(str, "'aab' is an invalid value for argument 'attr'. Do you mean 'aaa'?")
	end,
	tableArgumentMsg2 = function(unitTest)
		unitTest:assertEquals(tableArgumentMsg2(), "Argument must be a table.")
	end,
	toLabel2 = function(unitTest)
		sessionInfo().interface = true
		unitTest:assertEquals(toLabel2("maxValue"), "'Max Value'")
		unitTest:assertEquals(toLabel2("maxValue", "tab"), "'Max Value' (in 'Tab')")

		sessionInfo().interface = false
		unitTest:assertEquals(toLabel2("maxValue"), "'maxValue'")
		unitTest:assertEquals(toLabel2("maxValue", "tab"), "'tab.maxValue'")
	end,
	unnecessaryArgumentMsg2 = function(unitTest)
		unitTest:assertEquals(unnecessaryArgumentMsg2("aaa"), "Argument 'aaa' is unnecessary.")
	end,
	valueNotFoundMsg2 = function(unitTest)
		unitTest:assertEquals(valueNotFoundMsg2("aaa", "bbb"), "Value 'bbb' not found for argument 'aaa'.")
		unitTest:assertEquals(valueNotFoundMsg2(2, "bbb"), "Value 'bbb' not found for argument '#2'.")
	end,
	verifyUnnecessaryArguments2 = function(unitTest)
		local error_func = function(unitTest)
			verifyUnnecessaryArguments2({aaa = "aaa"}, {"abc", "acd", "aab"})
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("aaa"))

		local error_func = function(unitTest)
			verifyUnnecessaryArguments2({aaaa = "aaa"}, {"aabc", "aacd", "aaab"})
		end
		unitTest:assertError(error_func, unnecessaryArgumentMsg("aaaa", "aaab"))
	end,
	verifyNamedTable2 = function(unitTest)
		local error_func = function()
			verifyNamedTable2()
		end
		unitTest:assertError(error_func, tableArgumentMsg())

		local error_func = function()
			verifyNamedTable2(123)
		end
		unitTest:assertError(error_func, namedArgumentsMsg())

		local error_func = function()
			verifyNamedTable2{x = 3, 3, 4}
		end
		unitTest:assertError(error_func, "All elements of the argument must be named.")
	end,
	valueNotFoundError2 = function(unitTest)
		local error_func = function()
			valueNotFoundError2("1", "neighborhood")
		end
		unitTest:assertError(error_func, "Value 'neighborhood' not found for argument '1'.")
	end,
	verify2 = function(unitTest)
		local error_func = function(unitTest)
			verify2(false, "error")
		end
		unitTest:assertError(error_func, "error")
	end
}

