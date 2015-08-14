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

--@header Some basic and useful functions to handle errors and error messages.

--- Stop the simulation with an error.
-- @arg msg A string describing the error message.
-- @usage customError("error message")
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
		arg = info.short_src..":".. info.currentline ..": Warning: "..msg
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
-- @arg data A named table.
-- @arg idx A string with the name of the attribute.
-- @arg value The default value (any type).
-- @usage t = {x = 5}
-- defaultTableValue(t, "y", 8)
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
-- @usage defaultValueMsg("dbtype", "mysql")
function defaultValueMsg(argument, value)
	return "Argument '"..argument.."' could be removed as it is the default value ("..tostring(value)..")."
end

--- Show a strict warning if the attribute of a table has the default value. If TerraME is running
-- in the debug mode, the simulation stops with an error. The warning message comes from
-- ErrorHandling:defaultValueMsg().
-- @arg argument A string with the attribute name.
-- @arg value The default value.
-- @usage defaultValueWarning("size", 2)
function defaultValueWarning(argument, value)
	mandatoryArgument(1, "string", argument)

	strictWarning(defaultValueMsg(argument, value))
end

--- Show an error indicating a deprecated function. The error
-- comes from ErrorHandling:deprecatedFunctionMsg().
-- @arg functionName A string with the name of the deprecated function.
-- @arg functionExpected A string indicating hot to proceed to replace the
-- deprecated function.
-- @usage deprecatedFunction("abc", "def")
function deprecatedFunction(functionName, functionExpected)
	mandatoryArgument(1, "string", functionName)
	mandatoryArgument(2, "string", functionExpected)

	customError(deprecatedFunctionMsg(functionName, functionExpected))
end

--- Return a message indicating that a function is deprecated and must be replaced.
-- @arg functionName A string with the name of the deprecated function.
-- @arg functionExpected A string indicating hot to proceed to replace the
-- deprecated function.
-- @usage deprecatedFunctionMsg("abc", "def")
function deprecatedFunctionMsg(functionName, functionExpected)
	return "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
end

--- Stop the simulation with an error of a wrong type for an argument of a function.
-- The error message is the return value of ErrorHandling:incompatibleTypeMsg().
-- @arg attr A string with an attribute name, or a numeric position of the argument
-- in a function with non-named arguments.
-- @arg expectedTypesString A string with the possible type (or types).
-- @arg gottenValue The value passed as argument with wrong type.
-- @usage incompatibleTypeError("cell", "Cell", Agent{})
function incompatibleTypeError(attr, expectedTypesString, gottenValue)
	customError(incompatibleTypeMsg(attr, expectedTypesString, gottenValue))
end

--- Return an error message for incompatible types.
-- @arg attr A string with an attribute name, or a numeric position of the argument
-- in a function with non-named arguments.
-- @arg expectedTypesString A string with the possible type (or types).
-- @arg gottenValue The value passed as argument with wrong type.
-- @usage incompatibleTypeMsg("dbType", "string", 2)
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
-- @arg attr A string with an attribute name (for functions with named arguments),
-- or position (otherwise).
-- @arg expectedValues A string with the expected values for the argument.
-- @arg gottenValue The wrong value passed as argument.
-- @usage incompatibleValueError("position", "one of {1, 2, 3}", 4)
function incompatibleValueError(attr, expectedValues, gottenValue)
	customError(incompatibleValueMsg(attr, expectedValues, gottenValue))
end

--- Return an error message for incompatible values.
-- @arg attr A string with an attribute name (for functions with named arguments),
-- or position (otherwise).
-- @arg expectedValues A string with the expected values for the argument.
-- @arg gottenValue The wrong value passed as argument.
-- @usage incompatibleValueMsg("dbType", "one of {1, 3, 4}", 2)
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

--- Verify whether a given argument of a non-named function is integer.
-- The error message comes from ErrorHandling:integerArgumentMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg value The valued used as argument to the function call.
-- @usage integerArgument(1, 2.3)
function integerArgument(position, value)
	if type(value) ~= "number" then customError(type(value)) end
	if math.floor(value) ~= value then
		customError(integerArgumentMsg(position, value))
	end
end

--- Return a message indicating that a given argument of a function should be integer.
-- @arg attr The name of the argument. It can be a string or a number.
-- @arg value The valued used as argument to the function call.
-- @usage integerArgumentMsg("target", 7.4)
-- integerArgumentMsg(2, 5.1)
function integerArgumentMsg(attr, value)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return incompatibleValueMsg(attr, "integer number", value)
end

--- Verify whether a given argument of a named function is integer.
-- The error message comes from ErrorHandling:integerArgumentMsg().
-- @arg table A named table.
-- @arg attr A string with the attribute name.
-- @usage mtable = {bbb = 2.3}
-- integerTableArgument(table, "bbb")
function integerTableArgument(table, attr)
	if math.floor(table[attr]) ~= table[attr] then
		customError(integerArgumentMsg(attr, table[attr]))
	end
end

--- Stop the simulation with an error indicating that the function does not support
-- a given file extension.
-- The error message comes from ErrorHandling:invalidFileExtensionMsg().
-- @arg attr A string with an attribute name (for functions with named arguments), or position
-- (otherwise).
-- @arg ext A string with the incompatible file extension.
-- @usage invalidFileExtensionError("file", ".txt")
function invalidFileExtensionError(attr, ext)
	customError(invalidFileExtensionMsg(attr, ext))
end

--- Return a message indicating that a given file extension is incompatible.
-- @arg attr A string with an attribute name (for functions with named arguments), or position
-- (otherwise).
-- @arg ext A string with the incompatible file extension.
-- @usage invalidFileExtensionMsg("file", "csv")
function invalidFileExtensionMsg(attr, ext)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Argument '".. attr.."' does not support extension '"..ext.."'."
end

--- Verify whether a given argument of a function with non-named arguments belongs
--  to the correct type. The error message comes
-- from ErrorHandling:mandatoryArgumentMsg() and ErrorHandling:incompatibleTypeMsg().
-- @arg position A number wiht the position of the argument in the function.
-- @arg mtype A string with the required type for the argument.
-- @arg value The value used as argument to the function call.
-- @usage mandatoryArgument(1, "string", argument)
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
-- @arg attr The name of the argument (a string) or the position of the argument in the
-- function (a number).
-- @usage mandatoryArgumentError("target")
-- mandatoryArgumentError(2)
function mandatoryArgumentError(attr)
	customError(mandatoryArgumentMsg(attr))
end

--- Return a message indicating that a given argument of a function is mandatory.
-- @arg attr The name of the argument. It can be a string or a number.
-- @usage mandatoryArgumentMsg("target")
-- mandatoryArgumentMsg(2)
function mandatoryArgumentMsg(attr)
	if type(attr) == "number" then
		attr = "#"..attr
	end
	return "Argument '"..attr.."' is mandatory."
end

--- Verify whether a named table contains a mandatory argument. It stops with an error
-- if the value is nil or if it does not belong to the required type.
-- The error message comes from ErrorHandling:mandatoryArgumentMsg() or ErrorHandling:incompatibleTypeMsg().
-- @arg table A named table.
-- @arg attr A string with the attribute name.
-- @arg mtype A string with the required type for the attribute.
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- mandatoryTableArgument(mtable, "bbb", "string")
function mandatoryTableArgument(table, attr, mtype)
	if table[attr] == nil then
		mandatoryArgumentError(attr)
	elseif type(table[attr]) ~= mtype and mtype ~= nil then
		incompatibleTypeError(attr, mtype, table[attr])
	end
end

--- Return a message indicating that the arguments of a function must be named.
-- @usage namedArgumentsMsg()
function namedArgumentsMsg()
	return "Arguments must be named."
end

--- Verify whether an optional argument of a function with non-named arguments
-- belongs to the correct type.
-- The error message comes from ErrorHandling:incompatibleTypeMsg(), only if the argument is not nil.
-- @arg position A number with the position of the argument in the function.
-- @arg mtype A string with the required type for the argument.
-- @arg value The value used as argument to the function call.
-- @usage optionalArgument(1, "string", argument)
function optionalArgument(position, mtype, value)
	if value ~= nil and type(value) ~= mtype then
		incompatibleTypeError(position, mtype, value)
	end
end

--- Verify whether a named table contains an optional argument. It stops with an
-- error if the value is not nil and it has a type different from the required type.
-- The error comes from ErrorHandling:incompatibleTypeError().
-- @arg table A named table.
-- @arg attr A string with the argument name.
-- @arg allowedType A string with the required type for the attribute.
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- optionalTableArgument(mtable, "bbb", "string")
function optionalTableArgument(table, attr, allowedType)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, value)
	end
end

--- Verify whether a given argument of a function with non-named arguments is positive.
-- The error message comes from ErrorHandling:positiveArgumentMsg().
-- @arg position A number with the position of the argument in the function.
-- @arg value The value used as argument to the function call.
-- @arg zero A boolean value indicating whether zero should be included
-- (the default value is false).
-- @usage positiveArgument(1, -2)
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
-- @usage positiveArgumentMsg("target", -5)
-- positiveArgumentMsg(2, -2, true)
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
-- @usage mtable = {bbb = -3}
-- positiveTableArgument(table, "bbb")
function positiveTableArgument(table, attr, zero)
	if not zero then
		if table[attr] <= 0 then customError(positiveArgumentMsg(attr, table[attr], false)) end
	else
		if table[attr] < 0 then customError(positiveArgumentMsg(attr, table[attr], true)) end
	end
end

--- Stop the simulation with an error indicating that a given resource was not found.
-- The error message comes from ErrorHandling:resourceNotFoundMsg().
-- @arg attr A string with the attribute name.
-- @arg path A string with the location of the resource.
-- @usage resourceNotFoundError("file", "/usr/local/file.txt")
function resourceNotFoundError(attr, path)
	customError(resourceNotFoundMsg(attr, path))
end

--- Return a message indicating that a given resource could not be found.
-- @arg attr A string with the attribute name.
-- @arg path A string with the location of the resource.
-- @usage resourceNotFoundMsg("file", "c:\\myfiles\\file.csv")
function resourceNotFoundMsg(attr, path)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Resource '"..path.."' not found for argument '"..attr.."'."
end

--- Print a strict warning. This warning is shown only in the strict mode.
-- If TerraME is executing in the debug mode, it stops the simulation with an error. 
-- @arg msg A string describing the warning.
-- @usage strictWarning("warning message")
function strictWarning(msg)
	if sessionInfo().mode == "normal" then return end

	customWarning(msg)
end

--- Return a suggestion for a wrong string value. The suggestion must have a
-- Levenshtein's distance of less than 60% the size of the string, otherwise
-- it returns nil.
-- @arg value A string.
-- @arg options A table with string indexes with the possible suggestions.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- suggestion("gren", t) -- "green"
function suggestion(value, options)
	mandatoryArgument(1, "string", value)
	mandatoryArgument(2, "table", options)

	local distance = string.len(value)
	local word
	forEachOrderedElement(options, function(a)
		if type(a) ~= "string" then
			customError("All the indexes of second parameter should be string, got '"..type(a).."'.")
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

--- Stop the simulation with an error because the user did not choose a correct option.
-- This function supposes that there is a set of available options described as
-- string idexes of a table so it tries to find an approximate string to be shown as
-- a suggestion. Otherwise, it shows all the available options.
-- The error messages come from ErrorHandling:switchInvalidArgumentSuggestionMsg() and
-- ErrorHandling:switchInvalidArgumentMsg().
-- @arg att A string with the attribute name.
-- @arg value A string with wrong value passed as argument.
-- @arg suggestions A table with string indexes describing the available options.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- switchInvalidArgument("attribute", "gren", t) 
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
-- @arg casevar A string with the value of the attribute.
-- @arg att A string with the name of the attribute.
-- @arg options A table whose indexes indicate the available options.
-- @usage local options = {
--     aaa = true,
--     bbb = true,
--     ccc = true
-- }
-- switchInvalidArgumentMsg("ddd", "attr", options)
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
-- @arg casevar A string with the value of the attribute.
-- @arg att A string with the name of the attribute.
-- @arg suggestion A string with a suggestion to replace the wrong value.
-- @usage switchInvalidArgumentSuggestionMsg("aab", "attr", "aaa")
function switchInvalidArgumentSuggestionMsg(casevar, att, suggestion)
	mandatoryArgument(1, "string", casevar)
	mandatoryArgument(2, "string", att)
	mandatoryArgument(3, "string", suggestion)

	return "'"..casevar.."' is an invalid value for argument '"..att.."'. Do you mean '"..suggestion.."'?"
end

--- Return a message indicating that the argument of a function must be a table.
-- @usage tableArgumentMsg()
function tableArgumentMsg()
	return "Argument must be a table."
end

--- Return a string with a literal description of a parameter name. It is useful to work
-- with Model:init() when the model will be available through a graphical interface.
-- When using graphical interfaces, it converts upper case characters into space and lower case
-- characters and convert the first character of the string to uppercase.
-- Otherwise, it returns the name of the parameter itself.
-- @arg mstring A string with the parameter name.
-- @arg parent A string with the name of the table the parameter belongs to.
-- This parameter is optional.
-- @usage toLabel("maxValue") --  'Max Value' (with graphical interface) or 'maxValue' (without)
function toLabel(mstring, parent)
	if type(mstring) == "number" then
		return tostring(mstring)
	end

	if sessionInfo().interface then
		local result = string.upper(string.sub(mstring, 1, 1))

		local nextsub = string.match(mstring, "%u")
		for i = 2, mstring:len() do
			local nextchar = string.sub(mstring, i, i)
			if nextchar == nextsub then
				result = result.." "..nextsub
				nextsub = string.match(string.sub(mstring, i + 1, mstring:len()), "%u")
			else
				result = result..nextchar
			end
		end

		if parent then
			return "'"..result.."' (in "..toLabel(parent)..")"
		else
			return "'"..result.."'"
		end
	elseif parent then
		return "'"..parent.."."..mstring.."'"
	else
		return "'"..mstring.."'"
	end
end

--- Return a message indicating that a given argument is unnecessary.
-- @arg value A string or number or boolean value.
-- @arg suggestion A possible suggestion for the argument.
-- This parameter is optional.
-- @usage unnecessaryArgumentMsg("file")
-- unnecessaryArgumentMsg("filf", "file")
function unnecessaryArgumentMsg(value, suggestion)
	local str = "Argument '"..tostring(value).."' is unnecessary."

	if suggestion then
		str = str .." Do you mean '"..suggestion.."'?"
	end
	return str
end

--- Stop the simulation with an error due to a wrong value for an argument.
-- The error message comes from ErrorHandling:valueNotFoundMsg().
-- @arg attr A string with an attribute name (for functions with named arguments), or position
-- (otherwise).
-- @arg value The valued used as argument to the function call.
-- @usage valueNotFoundError(1, "neighborhood")
function valueNotFoundError(attr, value)
	customError(valueNotFoundMsg(attr, value))
end

--- Return a message indicating that a given argument of a function is mandatory.
-- @arg attr A string with an attribute name (for functions with named arguments), or position
-- (otherwise).
-- @arg value The valued used as argument to the function call.
-- @usage valueNotFoundMsg(1, "neighborhood")
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
-- @usage verify(2 < 3, "wrong operator")
function verify(condition, msg)
	if not condition then
		customError(msg)
	end
end

--- Verify if a given object is a named table. It generates errors if it is nil,
-- if it is not a table, or if it has numeric indexes. The error messages come from
-- ErrorHandling:tableArgumentMsg() and ErrorHandling:namedArgumentsMsg().
-- @arg data A value of any type.
-- @usage t = {value = 2}
-- verifyNamedTable(t)
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
-- This function returns the number of unnecessary arguments found.
-- @arg data A named table with the arguments used in the function call.
-- The indexes of this table will be verified.
-- @arg arguments A non-named table with the allowed arguments.
-- @usage t = {value = 2}
-- verifyUnnecessaryArguments(t, {"target", "select"})
function verifyUnnecessaryArguments(data, arguments)
	forEachElement(data, function(idx)
		if type(idx) ~= "string" then
			customError("Arguments should have only string indexes, got "..type(idx)..".")
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

