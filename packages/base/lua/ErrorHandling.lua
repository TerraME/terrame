-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

-- @header Some basic and useful functions to handle errors and error messages.

--- Stop the simulation with an error.
-- @arg msg A string describing the error message.
-- @usage _, err = pcall(function() customError("error message") end)
-- print(err)
function customError(msg)
	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	end

	local level = _Gtme.getLevel()
	error("Error: "..msg, level)
end

--- Print a warning. If TerraME is executing in the debug mode, it stops the simulation with an error.
-- @arg msg A string describing the warning.
-- @usage customWarning("warning message")
function customWarning(msg)
	if sessionInfo().mode == "quiet" then return end

	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	end

	local level = _Gtme.getLevel()
	local info = debug.getinfo(level)
	local func = _Gtme.printWarning
	local arg = msg

	if info then
		arg = "Warning: "..msg.." In file "..info.short_src..", in line "..info.currentline.."."
	end

	if sessionInfo().mode == "debug" then
		func = customError
		arg = msg
	end

	func(arg)
end

--- Verify the default value of a given attribute of a named table. It adds the attribute
-- with the default value in the table if it does not exist, 
-- stops with an error (ErrorHandling:incompatibleTypeMsg()) if
-- the value has a different type, or shows a
-- warning (ErrorHandling:defaultValueWarning()) if it is equal to the default value.
-- @arg data A named table (which can be an argument for a function).
-- @arg idx A string with the name of an attribute (or argument) from #1.
-- @arg value The default value (any type).
-- @usage function integrate(attrs)
--     defaultTableValue(attrs, "method", "euler")
--     return attrs
-- end
--
-- t = integrate{}
-- print(t.method)
function defaultTableValue(data, idx, value)
	if data[idx] == nil then
		data[idx] = value
	elseif data[idx] == value then
		defaultValueWarning(idx, value)
	elseif type(data[idx]) ~= type(value) then
		incompatibleTypeError(idx, type(value), data[idx])
	end
end

--- Return a message indicating that the modeler is using the default value for a
-- given argument and therefore it could be removed.
-- @arg argument A string with the name of the argument.
-- @arg value A number or string or boolean value with the default value for the argument.
-- @usage str = defaultValueMsg("dbtype", "mysql")
-- print(str)
function defaultValueMsg(argument, value)
	if type(value) == "string" then
		return "Argument '"..argument.."' could be removed as it is the default value ('"..value.."')."
	else
		return "Argument '"..argument.."' could be removed as it is the default value ("..tostring(value)..")."
	end
end

--- Show a strict warning if the attribute of a table has the default value. If TerraME is running
-- in the debug mode, the simulation stops with an error. The warning message comes from
-- ErrorHandling:defaultValueMsg().
-- @arg argument A string with the name of the argument.
-- @arg value The default value.
-- @usage str = defaultValueWarning("size", 2)
-- print(str)
function defaultValueWarning(argument, value)
	mandatoryArgument(1, "string", argument)

	strictWarning(defaultValueMsg(argument, value))
end

--- Show an error indicating a deprecated function. The error
-- comes from ErrorHandling:deprecatedFunctionMsg().
-- @arg functionName A string with the name of the deprecated function.
-- @arg functionExpected A string indicating how to proceed to replace the
-- deprecated function call.
-- @usage deprecatedFunc = function()
--     deprecatedFunction("abc", "def")
-- end
--
-- _, err = pcall(function() deprecatedFunc() end)
-- print(err)
function deprecatedFunction(functionName, functionExpected)
	mandatoryArgument(1, "string", functionName)
	mandatoryArgument(2, "string", functionExpected)

	customError(deprecatedFunctionMsg(functionName, functionExpected))
end

--- Return a message indicating that a function is deprecated and must be replaced.
-- @arg functionName A string with the name of the deprecated function.
-- @arg functionExpected A string indicating how to proceed to replace the
-- deprecated function call.
-- @usage str = deprecatedFunctionMsg("abc", "def")
-- print(str)
function deprecatedFunctionMsg(functionName, functionExpected)
	return "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
end

--- Stop the simulation with an error of a wrong type for an argument of a function.
-- The error message is the return value of ErrorHandling:incompatibleTypeMsg().
-- @arg attr A string with the name of the argument, or a number with its the position.
-- @arg expectedTypesString A string with the possible type (or types).
-- @arg gottenValue The value wrongly passed as argument.
-- @usage _, err = pcall(function() incompatibleTypeError("cell", "Cell", Agent{}) end)
-- print(err)
function incompatibleTypeError(attr, expectedTypesString, gottenValue)
	customError(incompatibleTypeMsg(attr, expectedTypesString, gottenValue))
end

--- Return an error message for incompatible types.
-- @arg attr A string with the name of the argument, or a number with its the position.
-- @arg expectedTypesString A string with the possible type (or types).
-- @arg gottenValue The value wrongly passed as argument.
-- @usage str = incompatibleTypeMsg("source", "string", 2)
-- print(str)
function incompatibleTypeMsg(attr, expectedTypesString, gottenValue)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	if expectedTypesString == nil then expectedTypesString = "nil" end

	return "Incompatible types. Argument '"..attr.."' expected "..
		expectedTypesString..", got "..type(gottenValue).."."
end

--- Stop the simulation with an error of a wrong value for an argument of a function.
-- The error message comes from ErrorHandling:incompatibleValueMsg().
-- @arg attr A string with the name of the argument or a number with its position.
-- @arg expectedValues A string with the expected value(s) for the argument.
-- @arg gottenValue The value wrongly passed as argument.
-- @usage _, err = pcall(function() incompatibleValueError("position", "one of {1, 2, 3}", 4) end)
-- print(err)
function incompatibleValueError(attr, expectedValues, gottenValue)
	customError(incompatibleValueMsg(attr, expectedValues, gottenValue))
end

--- Return an error message for incompatible values.
-- @arg attr A string with the name of the argument or a number with its position.
-- @arg expectedValues A string with the expected value(s) for the argument.
-- @arg gottenValue The value wrongly passed as argument.
-- @usage str = incompatibleValueMsg("source", "one of {1, 3, 4}", 2)
-- print(str)
function incompatibleValueMsg(attr, expectedValues, gottenValue)
	if expectedValues == nil then expectedValues = "nil" end

	if type(attr) == "number" then
		attr = "#"..attr
	end

	local msg = "Incompatible values. Argument '"..attr.."' expected ".. expectedValues ..", got "
	if type(gottenValue) == "string" then
		msg = msg.."'"..gottenValue.."'."
	elseif gottenValue == nil then
		msg = msg.."nil."
	else
		msg = msg..gottenValue.."."
	end
	return msg
end

--- Verify whether a given argument is integer. It is useful only for functions with
-- non-named arguments. The error message comes from ErrorHandling:integerArgumentMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg value The value used as argument to the function call.
-- @usage sum = function(a, b)
--     integerArgument(1, a)
--     integerArgument(2, b)
--     return a + b
-- end
--
-- _, err = pcall(function() sum(5) end)
-- print(err)
function integerArgument(position, value)
	if type(value) ~= "number" then customError(incompatibleTypeMsg(2, "number", value)) end
	if math.floor(value) ~= value then
		customError(integerArgumentMsg(position, value))
	end
end

--- Return a message indicating that a given argument of a function should be integer.
-- @arg attr A string with the name of the argument or a number with the position of the argument.
-- @arg value The value used as argument to the function call.
-- @usage str = integerArgumentMsg("target", 7.4)
-- print(str)
--
-- str = integerArgumentMsg(2, 5.1)
-- print(str)
function integerArgumentMsg(attr, value)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return incompatibleValueMsg(attr, "integer number", value)
end

--- Verify whether a given argument of a named function is integer.
-- The error message comes from ErrorHandling:integerArgumentMsg().
-- @arg table A named table.
-- @arg attr A string with the name of the argument.
-- @usage myFunction = function(mtable)
--     integerTableArgument(mtable, "value")
-- end
-- 
-- _, err = pcall(function() myFunction{value = false} end)
-- print(err)
function integerTableArgument(table, attr)
	if type(table[attr]) ~= "number" then
		incompatibleTypeError(attr, "number", table[attr])
	end

	if math.floor(table[attr]) ~= table[attr] then
		customError(integerArgumentMsg(attr, table[attr]))
	end
end

--- Stop the simulation with an error indicating that the function does not support
-- a given file extension.
-- The error message comes from ErrorHandling:invalidFileExtensionMsg().
-- @arg attr A string with the name of the argument or a number with its position.
-- @arg ext A string with the incompatible file extension.
-- @usage _, err = pcall(function() invalidFileExtensionError("file", ".txt") end)
-- print(err)
function invalidFileExtensionError(attr, ext)
	customError(invalidFileExtensionMsg(attr, ext))
end

--- Return a message indicating that a given file extension is incompatible.
-- @arg attr A string with the name of the argument (for functions with named arguments),
-- or its position (for functions with non-named arguments).
-- @arg ext A string with the incompatible file extension.
-- @usage str = invalidFileExtensionMsg("file", "csv")
-- print(str)
function invalidFileExtensionMsg(attr, ext)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Argument '".. attr.."' does not support extension '"..ext.."'."
end

--- Verify whether a given argument of a function with non-named arguments belongs
-- to the correct type. The error message comes
-- from ErrorHandling:mandatoryArgumentMsg() and ErrorHandling:incompatibleTypeMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg mtype A string with the required type for the argument.
-- @arg value The value used as argument to the function call.
-- @usage myFunction = function(value)
--     mandatoryArgument(1, "string", value)
-- end
-- 
-- _, err = pcall(function() myFunction(2) end)
-- print(err)
function mandatoryArgument(position, mtype, value)
	if type(value) ~= mtype then
		if value == nil then
			mandatoryArgumentError(position)
		else
			incompatibleTypeError(position, mtype, value)
		end
	end
end

--- Stop the simulation with an error indicating that a given argument is mandatory.
-- The error message comes from ErrorHandling:mandatoryArgumentMsg().
-- @arg attr A string with name of the argument or a number with its position in the
-- function.
-- @usage _, err = pcall(function() mandatoryArgumentError(2) end)
-- print(err)
function mandatoryArgumentError(attr)
	customError(mandatoryArgumentMsg(attr))
end

--- Return a message indicating that a given argument of a function is mandatory.
-- @arg attr The name of the argument. It can be a string or a number.
-- @usage str = mandatoryArgumentMsg("target")
-- print(str)
--
-- str = mandatoryArgumentMsg(2)
-- print(str)
function mandatoryArgumentMsg(attr)
	if type(attr) == "number" then
		attr = "#"..attr
	end
	return "Argument '"..attr.."' is mandatory."
end

--- Verify whether a named table contains a mandatory argument. It stops with an error
-- if the value is nil or if it does not belong to the required type.
-- The error message comes from ErrorHandling:mandatoryArgumentMsg()
-- or ErrorHandling:incompatibleTypeMsg().
-- @arg table A named table.
-- @arg attr A string with the argument name.
-- @arg mtype A string with the required type for the argument.
-- This argument is optional. If not used, then this function
-- will check only if the argument is not nil.
-- @usage myFunction = function(mtable)
--     mandatoryTableArgument(mtable, "value", "string")
-- end
-- 
-- _, err = pcall(function() myFunction{value = 2} end)
-- print(err)
function mandatoryTableArgument(table, attr, mtype)
	if table[attr] == nil then
		mandatoryArgumentError(attr)
	elseif type(table[attr]) ~= mtype then
		if type(mtype) == "string" then
			incompatibleTypeError(attr, mtype, table[attr])
		elseif mtype ~= nil then
			customError(incompatibleTypeMsg(3, "string", mtype))
		end
	end
end

--- Return a message indicating that the arguments of a function must be named.
-- @usage str = namedArgumentsMsg()
-- print(str)
function namedArgumentsMsg()
	return "Arguments must be named."
end

--- Verify whether an optional argument of a function with non-named arguments
-- belongs to the correct type. If the argument is nil then no error is
-- created. The error message comes from ErrorHandling:incompatibleTypeMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg mtype A string with the required type for the argument.
-- @arg value The value used as argument to the function call.
-- @usage myFunction = function(value)
--     optionalArgument(1, "string", value)
-- end
-- 
-- _, err = pcall(function() myFunction(2) end)
-- print(err)
function optionalArgument(position, mtype, value)
	if value ~= nil and type(value) ~= mtype then
		incompatibleTypeError(position, mtype, value)
	end
end

--- Verify whether a named table contains an optional argument. It stops with an
-- error if the value is not nil and it has a type different from the required type.
-- The error comes from ErrorHandling:incompatibleTypeError().
-- @arg table A named table.
-- @arg attr A string with the name of the argument.
-- @arg allowedType A string with the required type for the argument.
-- @usage myFunction = function(mtable)
--     optionalTableArgument(mtable, "value", "string")
-- end
-- 
-- _, err = pcall(function() myFunction{value = 2} end)
-- print(err)
function optionalTableArgument(table, attr, allowedType)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, value)
	end
end

--- Verify whether a given argument is positive. It is useful only for functions with
-- non-named arguments. The error message comes from ErrorHandling:positiveArgumentMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg value The value used as argument to the function call.
-- @arg zero A boolean value indicating whether zero should be included
-- (the default value is false).
-- @usage positiveSum = function(a, b)
--     positiveArgument(1, a)
--     positiveArgument(2, b)
--     return a + b
-- end
--
-- _, err = pcall(function() positiveSum(5, -2) end)
-- print(err)
function positiveArgument(position, value, zero)
	if not zero then
		if value <= 0 then customError(positiveArgumentMsg(position, value, false)) end
	else
		if value < 0 then customError(positiveArgumentMsg(position, value, true)) end
	end
end

--- Return a message indicating that a given argument of a function should be positive.
-- @arg attr The name of the argument. It can be a string or a number.
-- @arg value The value used as argument to the function call.
-- @arg zero A boolean value indicating whether zero should be included
-- (the default value is false).
-- @usage str = positiveArgumentMsg("target", -5)
-- print(str)
--
-- str = positiveArgumentMsg(2, -2, true)
-- print(str)
function positiveArgumentMsg(attr, value, zero)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	if zero then
		return incompatibleValueMsg(attr, "positive number (including zero)", value)
	else
		return incompatibleValueMsg(attr, "positive number (except zero)", value)
	end
end

--- Verify whether a given argument of a function with named arguments is positive.
-- The error message comes from ErrorHandling:positiveArgumentMsg().
-- @arg table A named table.
-- @arg attr A string with the name of the argument.
-- @arg zero A boolean value indicating whether zero should be included
-- (the default value is false).
-- @usage myFunction = function(mtable)
--     positiveTableArgument(mtable, "value")
-- end
-- 
-- _, err = pcall(function() myFunction{value = -2} end)
-- print(err)
function positiveTableArgument(table, attr, zero)
	if type(table[attr]) ~= "number" then
		incompatibleTypeError(attr, "number", table[attr])
	end

	if not zero then
		if table[attr] <= 0 then customError(positiveArgumentMsg(attr, table[attr], false)) end
	else
		if table[attr] < 0 then customError(positiveArgumentMsg(attr, table[attr], true)) end
	end
end

--- Stop the simulation with an error indicating that a given resource was not found.
-- The error message comes from ErrorHandling:resourceNotFoundMsg().
-- @arg attr A string with the name of the argument, or its position.
-- @arg path A string with the location of the resource.
-- @usage _, err = pcall(function() resourceNotFoundError("file", "file.txt") end)
-- print(err)
function resourceNotFoundError(attr, path)
	customError(resourceNotFoundMsg(attr, path))
end

--- Return a message indicating that a given resource could not be found.
-- @arg attr A string with the name of the argument, or its position.
-- @arg path A string with the location of the resource.
-- @usage str = resourceNotFoundMsg("file", "c:\\myfiles\\file.csv")
-- print(str)
function resourceNotFoundMsg(attr, path)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Resource '"..path.."' not found for argument '"..attr.."'."
end

--- Print a strict warning. This warning is shown only in the strict mode.
-- If TerraME is executing in the debug mode, it stops the simulation with an error. 
-- @arg msg A string describing the warning.
-- @usage -- DONTRUN
-- strictWarning("warning message")
function strictWarning(msg)
	if sessionInfo().mode == "normal" then return end

	customWarning(msg)
end

--- Return a suggestion for a wrong string value. The suggestion must have a
-- Levenshtein's distance of less than 60% the size of the string, otherwise
-- it returns nil.
-- @arg value A string.
-- @arg options A named table with the possible suggestions.
-- It can also be a vector of strings.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- str = suggestion("gren", t)
-- print(str)
function suggestion(value, options)
	mandatoryArgument(1, "string", value)
	mandatoryArgument(2, "table", options)

	if #options > 0 then
		local moptions = {}

		forEachElement(options, function(_, mvalue)
			moptions[mvalue] = true
		end)

		options = moptions
	end

	local distance = string.len(value)
	local word
	forEachOrderedElement(options, function(a)
		if type(a) ~= "string" then
			customError("All the names of argument #2 should be string, got '"..type(a).."'.")
		end

		local d = levenshtein(a, value) 
		if d < distance then
			distance = d
			word = a
		end
	end)
	if distance < string.len(value) * 0.6 then
		return word
	end
end

--- Return the arguments of suggestion within a question " Do you mean '"..suggestion.."'?".
-- @arg suggestion A string.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- str = suggestionMsg(suggestion("gren", t))
-- print(str)
function suggestionMsg(suggestion)
	local suggestionMsg = ""
	if suggestion then 
		suggestionMsg = " Do you mean '"..suggestion.."'?"
	end

	return suggestionMsg
end

--- Stop the simulation with an error because the user did not choose a correct option.
-- This function supposes that there is a set of available options described as
-- string idexes of a table so it tries to find an approximate string to be shown as
-- a suggestion. Otherwise, it shows all the available options.
-- The error messages come from ErrorHandling:switchInvalidArgumentSuggestionMsg() and
-- ErrorHandling:switchInvalidArgumentMsg().
-- @arg att A string with the name of the argument.
-- @arg value A string with wrong value passed as argument.
-- @arg suggestions A named table describing the available options.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- _, err = pcall(function() switchInvalidArgument("attribute", "gren", t) end)
-- print(err)
function switchInvalidArgument(att, value, suggestions)
	mandatoryArgument(1, "string", att)
	mandatoryArgument(2, "string", value)
	mandatoryArgument(3, "table", suggestions)

	local sugg = suggestion(value, suggestions)
	if sugg then
		customError(switchInvalidArgumentSuggestionMsg(value, att, sugg))
	else
		customError(switchInvalidArgumentMsg(value, att, suggestions))
	end
end

--- Return a message for a wrong argument value showing the options.
-- @arg casevar A string with the value of the argument.
-- @arg att A string with the name of the argument.
-- @arg options A named table indicating the available options.
-- @usage local options = {
--     aaa = true,
--     bbb = true,
--     ccc = true
-- }
--
-- str = switchInvalidArgumentMsg("ddd", "attr", options)
-- print(str)
function switchInvalidArgumentMsg(casevar, att, options)
	mandatoryArgument(1, "string", casevar)
	mandatoryArgument(2, "string", att)
	mandatoryArgument(3, "table", options)

	local word = "It must be a string from the set ["
	forEachOrderedElement(options, function(a)
		word = word.."'"..a.."', "
	end)
	word = string.sub(word, 0, string.len(word) - 2).."]."
	return "'"..casevar.."' is an invalid value for argument '"..att.."'. "..word
end

--- Return a message for a wrong argument value showing the most similar option.
-- @arg casevar A string with the value of the argument.
-- @arg att A string with the name of the argument.
-- @arg suggestion A string with a suggestion to replace the wrong value.
-- @usage str = switchInvalidArgumentSuggestionMsg("aab", "attr", "aaa")
-- print(str)
function switchInvalidArgumentSuggestionMsg(casevar, att, suggestion)
	mandatoryArgument(1, "string", casevar)
	mandatoryArgument(2, "string", att)
	mandatoryArgument(3, "string", suggestion)

	return "'"..casevar.."' is an invalid value for argument '"..att.."'."..suggestionMsg(suggestion)
end

--- Return a message indicating that the argument of a function must be a table.
-- @usage str = tableArgumentMsg()
-- print(str)
function tableArgumentMsg()
	return "Argument must be a table."
end

--- Return a message indicating that a given argument is unnecessary.
-- @arg value A string or number or boolean value.
-- @arg suggestion A possible suggestion for the argument.
-- This argument is optional.
-- @usage str = unnecessaryArgumentMsg("file")
-- print(str)
--
-- str = unnecessaryArgumentMsg("filf", "file")
-- print(str)
function unnecessaryArgumentMsg(value, suggestion)
	return "Argument '"..tostring(value).."' is unnecessary."..suggestionMsg(suggestion)
end

--- Stop the simulation with an error due to a wrong value for an argument.
-- The error message comes from ErrorHandling:valueNotFoundMsg().
-- @arg attr A string with the name of the argument or a number with its position.
-- @arg value The value used as argument to the function call.
-- @usage _, err = pcall(function() valueNotFoundError(1, "neighborhood") end)
-- print(err)
function valueNotFoundError(attr, value)
	customError(valueNotFoundMsg(attr, value))
end

--- Return a message indicating that a given argument of a function is mandatory.
-- @arg attr A string with the name of the argument or a number with its position.
-- @arg value The valued used as argument to the function call.
-- @usage str = valueNotFoundMsg(1, "neighborhood")
-- print(str)
function valueNotFoundMsg(attr, value)
	if type(value) == nil then value = "nil" end
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Value '"..value.."' not found for argument '"..attr.."'."
end

--- Verify a given condition, otherwise it stops the simulation with an error.
-- @arg condition A value of any type. If it is false or nil, the function generates an error.
-- @arg msg A string with the error to be displayed.
-- @usage greater = function(a, b)
--     verify(a > b, "#1 is not greater than #2.")
-- end
--
-- _, err = pcall(function() greater(5, 7) end)
-- print(err)
function verify(condition, msg)
	if not condition then
		customError(msg)
	end
end

--- Verify if a given object is a named table. It generates errors if it is nil,
-- if it is not a table, or if it has numeric names. The error messages come from
-- ErrorHandling:tableArgumentMsg() and ErrorHandling:namedArgumentsMsg().
-- @arg data A value of any type.
-- @usage myFunction = function(mtable)
--     verifyNamedTable(mtable)
-- end
-- 
-- _, err = pcall(function() myFunction{1, 2, 3} end)
-- print(err)
function verifyNamedTable(data)
	if type(data) ~= "table" then
		if data == nil then
			customError(tableArgumentMsg())
		else
			customError(namedArgumentsMsg())
		end
	elseif #data > 0 then
		customError("All elements of the argument must be named.")
	end
end

--- Verify whether the user has passed only the allowed arguments for a function, showing
-- a strict warning otherwise. The warning comes from ErrorHandling:unnecessaryArgumentMsg().
-- It is recommended that this function should be called as early as possible, in order
-- to show the warning before any error that might be related to it.
-- This function returns the number of unnecessary arguments found.
-- @arg data A named table with the arguments used in the function call.
-- The names of this table will be verified.
-- @arg arguments A vector with the allowed arguments.
-- @usage myFunction = function(mtable)
--     verifyUnnecessaryArguments(mtable, {"aaa", "bbb", "ccc"})
-- end
-- 
-- _, err = pcall(function() myFunction{aaa = 3, value = 2} end)
-- print(err)
function verifyUnnecessaryArguments(data, arguments)
	forEachElement(data, function(idx)
		if type(idx) ~= "string" then
			customError("Arguments should have only string names, got "..type(idx)..".")
		end
	end)

	local count = 0
	forEachElement(data, function(value)
		local notCorrectArguments = {}
		local correctedSuggestions = {}
		if not belong(value, arguments) then
			table.insert(notCorrectArguments, value)
			local moreSimilar = "" 
			local moreSimilarDistance = 1000000
			for j = 1, #arguments do
				local distance = levenshtein(value, arguments[j])
				if distance <= moreSimilarDistance then
					moreSimilarDistance = distance
					moreSimilar = arguments[j]
				end
			end
			table.insert(correctedSuggestions, moreSimilar)
		end

		for i = 1, #notCorrectArguments do
			local dst = levenshtein(notCorrectArguments[i], correctedSuggestions[i])
			local msg = unnecessaryArgumentMsg(value)
			if dst < math.floor(#notCorrectArguments[i] * 0.6) and data[i] == nil then
				msg = unnecessaryArgumentMsg(value, correctedSuggestions[i])
			end
			count = count + 1
			strictWarning(msg)
		end
	end)
	return count
end

