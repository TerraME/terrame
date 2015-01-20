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
	checkUnnecessaryArguments = function(unitTest)
		local error_func = function(unitTest)
			checkUnnecessaryArguments({aaa = "aaa"}, {"abc", "acd", "aab"})
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("aaa"))

		local error_func = function(unitTest)
			checkUnnecessaryArguments({aaaa = "aaa"}, {"aabc", "aacd", "aaab"})
		end
		unitTest:assert_error(error_func, unnecessaryArgumentMsg("aaaa", "aaab"))

	end,
	unnecessaryArgumentMsg = function(unitTest)
		unitTest:assert_equal(unnecessaryArgumentMsg("aaa"), "Argument 'aaa' is unnecessary.")
	end,

	incompatibleTypeMsg = function(unitTest)
		unitTest:assert_equal(incompatibleTypeMsg("aaa", "string", 2), "Incompatible types. Argument 'aaa' expected string, got number.")
	end,
	defaultValueMsg = function(unitTest)
		unitTest:assert_equal(defaultValueMsg("aaa", 2), "Argument 'aaa' could be removed as it is the default value (2).")
	end,
	packageInfo = function(unitTest)
		local r = packageInfo()

		unitTest:assert_equal(r.version, "2.0")
		unitTest:assert_equal(r.date, "17 October 2014")
		unitTest:assert_equal(r.package, "base")
		unitTest:assert_equal(r.url, "http://www.terrame.org")
	end,
	resourceNotFoundMsg = function(unitTest)
		unitTest:assert_equal(resourceNotFoundMsg("aaa", "bbb"), "Resource 'bbb' not found for argument 'aaa'.")
	end,
	suggestion = function(unitTest)
		local t = {
			aaaaa = true,
			bbbbb = true,
			ccccc = true
		}

		unitTest:assert_equal(suggestion("aaaab", t), "aaaaa")
		unitTest:assert_nil(suggestion("ddddd", t))
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
		unitTest:assert_error(error_func, switchInvalidArgumentSuggestionMsg("aaaab", "arg", "aaaaa"))

		local error_func = function()
			switchInvalidArgument("arg", "ddddd", t)
		end
		unitTest:assert_error(error_func, switchInvalidArgumentMsg("ddddd", "arg", t))
	end,

	valueNotFoundMsg = function(unitTest)
		unitTest:assert_equal(valueNotFoundMsg("aaa", "bbb"), "Value 'bbb' not found for argument 'aaa'.")
	end,
	tableArgumentMsg = function(unitTest)
		unitTest:assert_equal(tableArgumentMsg(), "Argument must be a table.")
	end,
	mandatoryArgument = function(unitTest)
		local error_func = function()
			mandatoryArgument(1, "string")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))

		local error_func = function()
			mandatoryArgument(1, "string", 2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	mandatoryArgumentMsg = function(unitTest)
		unitTest:assert_equal(mandatoryArgumentMsg("aaa"), "Argument 'aaa' is mandatory.")
	end,
	namedArgumentsMsg = function(unitTest)
		unitTest:assert_equal(namedArgumentsMsg(), "Arguments must be named.")
	end,
	invalidFileExtensionMsg = function(unitTest)
		unitTest:assert_equal(invalidFileExtensionMsg("aaa", "bbb"), "Argument 'aaa' does not support extension 'bbb'.")
	end,
	customError = function(unitTest)
		local error_func = function()
			customError("test.")
		end
		unitTest:assert_error(error_func, "test.")
	end,
	customWarning = function(unitTest)
		local error_func = function()
			customWarning("test.")
		end
		unitTest:assert_error(error_func, "test.")
	end,
	defaultValueWarning = function(unitTest)
		local error_func = function()
			defaultValueWarning("size", 2)
		end
		unitTest:assert_error(error_func, defaultValueMsg("size", 2))
	end,
	defaultTableValue = function(unitTest)
		local t = {x = 5}
		defaultTableValue(t, "y", 8)

		unitTest:assert_equal(t.y, 8)
	end,
	deprecatedFunctionWarning = function(unitTest)
		local error_func = function()
			deprecatedFunctionWarning("abc", "def")
		end
		unitTest:assert_error(error_func, deprecatedFunctionMsg("abc", "def"))
	end,
	deprecatedFunctionMsg = function(unitTest)
		unitTest:assert_equal(deprecatedFunctionMsg("aaa", "bbb"), "Function 'aaa' is deprecated. Use 'bbb' instead.")
	end,
	file = function(unitTest)
		unitTest:assert_type(file("simple-cs.csv"), "string")
	end,
	invalidFileExtensionError = function(unitTest)
		local error_func = function()
			invalidFileExtensionError("file", ".txt")
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("file", ".txt"))
	end,
	incompatibleTypeError = function(unitTest)
		local error_func = function()
			incompatibleTypeError("cell", "Cell", Agent{})
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("cell", "Cell", Agent{}))
	end,
	incompatibleValueError = function(unitTest)
		local error_func = function()
			incompatibleValueError("position", "1, 2, or 3", "4")
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("position", "1, 2, or 3", "4"))
	end,
	incompatibleValueMsg = function(unitTest)
		local str = incompatibleValueMsg("attr", "positive", -2)
		unitTest:assert_equal(str, "Incompatible values. Argument 'attr' expected positive, got -2.")
	end,
	resourceNotFoundError = function(unitTest)
		local error_func = function()
			resourceNotFoundError("file", "/usr/local/file.txt")
		end
		unitTest:assert_error(error_func, resourceNotFoundMsg("file", "/usr/local/file.txt"))
	end,
	mandatoryArgumentError = function(unitTest)
		local error_func = function()
			mandatoryArgumentError("neighborhood")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("neighborhood"))
	end,
	mandatoryTableArgument = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			mandatoryTableArgument(mtable, "bbb", "string")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("bbb", "string", 3))

		error_func = function()
			mandatoryTableArgument(mtable, "ddd", "string")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("ddd", "string"))
	end,
	optionalArgument = function(unitTest)
		local error_func = function()
			optionalArgument(1, "string", 2)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "string", 2))
	end,
	optionalTableArgument = function(unitTest)
		local mtable = {bbb = 3, ccc = "aaa"}

		local error_func = function()
			optionalTableArgument(mtable, "bbb", "string")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("bbb", "string", 3))
	end,
	verifyNamedTable = function(unitTest)
		local error_func = function()
			verifyNamedTable()
		end
		unitTest:assert_error(error_func, tableArgumentMsg())

		local error_func = function()
			verifyNamedTable(123)
		end
		unitTest:assert_error(error_func, namedArgumentsMsg())

		local error_func = function()
			verifyNamedTable{x = 3, 3, 4}
		end
		unitTest:assert_error(error_func, "All elements of the argument must be named.")
	end,
	switch = function(unitTest)
		unitTest:assert(true)
	end,
	valueNotFoundError = function(unitTest)
		local error_func = function()
			valueNotFoundError("1", "neighborhood")
		end
		unitTest:assert_error(error_func, "Value 'neighborhood' not found for argument '1'.")
	end,
	verify = function(unitTest)
		local error_func = function(unitTest)
			verify(false, "error")
		end
		unitTest:assert_error(error_func, "error")
	end,
	switchInvalidArgumentMsg = function(unitTest)
		local options = {
			aaa = true,
			bbb = true,
			ccc = true
		}
		local str = switchInvalidArgumentMsg("ddd", "attr", options)
		unitTest:assert_equal(str, "'ddd' is an invalid value for argument 'attr'. It must be a string from the set ['aaa', 'bbb', 'ccc'].")

	end,
	switchInvalidArgumentSuggestionMsg = function(unitTest)
		local str = switchInvalidArgumentSuggestionMsg("aab", "attr", "aaa")
		unitTest:assert_equal(str, "'aab' is an invalid value for argument 'attr'. Do you mean 'aaa'?")
	end
}

