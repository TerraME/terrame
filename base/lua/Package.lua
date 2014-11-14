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

--@header Some basic and useful functions to develop packages.

--- Return the description of a package. It reads all the attributes from file 
-- description.lua of the package and create an additional attribute data, with 
-- the path to folder data in the package.
-- @param package Name of the package. If nil, packageInfo will return
-- the description of TerraME.
-- @usage packageInfo().version
packageInfo = function(package)
	if package == nil then package = "base" end

	local s = sessionInfo().separator
	local pkgfile = sessionInfo().path..s.."packages"..s..package
	if not isfile(pkgfile) then
		customError("Package '"..package.."' is not installed.")
	end
	
	local file = pkgfile..s.."description.lua"
	local result = include(file)
	result.data = pkgfile..s.."data"..s
	return result
end

--- Return the path to a file of a given package. The file must be inside the data folder
-- of the package.
-- @param filename A string with the name of the file.
-- @param package A string with the name of the package.
-- @usage file("cs.csv") 
function file(filename, package)
	if package == nil then package = "base" end

	local s = sessionInfo().separator
	local file = sessionInfo().path..s.."packages"..s..package..s.."data"..s..filename
	if not isfile(file) then
		customError("File '"..file.."' does not exist in package '"..package.."'.")
	end
	return file
end

--- Implement a switch case function, where options are given and there are functions
-- associated to them.
-- @param data A table.
-- @param att The chosen attribute.
-- @usage switch(data, "protocol"):caseof{
--     tcp = function() print("tcp") end,
--     udp = function() print("udp") end
-- }
function switch(data, att)
	mandatoryArgument(1, "table", data)
	mandatoryArgument(2, "string", att)

	local swtbl = {
		casevar = data[att],
		caseof = function(self, code)
			local f
			if self.casevar then
				f = code[self.casevar] or code.default
			else
				f = code.missing or code.default
			end
			if f then
				if type(f) == "function" then
					return f(self.casevar,self)
				else
					customError("Case "..tostring(self.casevar).." should be a function.")
				end
			else
				local distance = string.len(self.casevar)
				local word
				forEachElement(code, function(a)
					local d = levenshtein(a, self.casevar) 
					if d < distance then
						distance = d
						word = a
					end
				end)
				if distance < string.len(self.casevar) * 0.6 then
					customError(switchInvalidParameterSuggestionMsg(self.casevar, att, word))
				else
					customError(switchInvalidParameterMsg(self.casevar, att, code))
				end
			end
		end
	}
	return swtbl
end

--- Return a message for a wrong parameter value showing the options.
-- @param casevar Value of the attribute.
-- @param att Name of the attribute.
-- @param options A table with the available options.
-- @usage local options = {
--     aaa = true,
--     bbb = true,
--     ccc = true
-- }
-- switchInvalidParameterMsg("ddd", "attr", options)
function switchInvalidParameterMsg(casevar, att, options)
	local word = "It must be a string from the set ["
	forEachOrderedElement(options, function(a)
		word = word.."'"..a.."', "
	end)
	word = string.sub(word, 0, string.len(word) - 2).."]."
	return "'"..casevar.."' is an invalid value for parameter '"..att.."'. "..word
end

--- Return a message for a wrong parameter value showing the most similar option.
-- @param casevar Value of the attribute.
-- @param att Name of the attribute.
-- @param suggestion A suggestion for to replace the wrong value.
-- @usage switchInvalidParameterSuggestionMsg("aab", "attr", "aaa")
function switchInvalidParameterSuggestionMsg(casevar, att, suggestion)
	return "'"..casevar.."' is an invalid value for parameter '"..att.."'. Do you mean '"..suggestion.."'?"
end

--- Load a given package.
-- @param package A package name.
-- @usage require("calibration")
function require(package)
	mandatoryArgument(1, "string", package)

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	if not isfile(package_path) then
		customError("Package '"..package.."' is not installed.")
	end

	local load_file = package_path..s.."load.lua"
	local load_sequence

	if isfile(load_file) then
		load_sequence = include(load_file).files
	end

	local all_files = dir(package_path..s.."lua")
	local count_files = {}
	for _, file in ipairs(all_files) do
		count_files[file] = 0
	end

	local i, file

	if load_sequence then
		for _, file in ipairs(load_sequence) do
			dofile(package_path..s.."lua"..s..file)
			count_files[file] = count_files[file] + 1
		end
	end

	for mfile, count in pairs(count_files) do
		local attr = attributes(package_path..s.."lua"..s..mfile)
		if count == 0 and attr.mode ~= "directory" then
			printWarning("File lua/"..mfile.." is ignored by load.lua.")
		elseif count > 1 then
			printWarning("File lua/"..mfile.." is loaded "..count.." times in load.lua.")
		end
	end
end

--- Verify a given condition, otherwise stops the simulation with an error.
-- @param condition A value of any type. If it is not true, the function generates an error.
-- @param msg A string with the error to be displayed.
-- @usage verify(2 < 3, "wrong operator")
function verify(condition, msg)
	if not condition then
		customError(msg)
	end
end

--- Verify whether the table passed as argument is a named table. It generates errors if it is nil,
-- if it is not a table, or if it has numeric indexes. The error messages come from
-- Package:tableParameterMsg() and Package:namedParametersMsg().
-- @param data A value of any type.
-- @usage t = {value = 2}
-- verifyNamedTable(t)
function verifyNamedTable(data)
	if type(data) ~= "table" then
		if data == nil then
			customError(tableParameterMsg())
		else
			customError(namedParametersMsg())
		end
	elseif #data > 0 then
		customError("All elements of the argument must be named.")
	end
end

--- Return a message indicating that the parameter of a function must be a table.
-- @usage tableParameterMsg()
function tableParameterMsg()
	return "Parameter must be a table."
end

--- Return a message indicating that the parameters of a function must be named.
-- @usage namedParametersMsg()
function namedParametersMsg()
	return "Parameters must be named."
end

--- Verify whether the used has used only the allowed parameters for a functoin, generating
-- a warning otherwise. The warning comes from Package:unnecessaryParameterMsg().
-- @param data The list of parameters used in the function call.
-- @param parameters The list of the allowed parameters.
-- @usage t = {value = 2}
-- checkUnnecessaryParameters(t, {"target", "select"})
function checkUnnecessaryParameters(data, parameters)
	forEachElement(data, function(value)
		local notCorrectParameters = {}
		local correctedSuggestions = {}
		if not belong(value, parameters) then
			table.insert(notCorrectParameters, value)
			local moreSimilar = "" 
			local moreSimilarDistance = 1000000
			for j = 1, #parameters do
				local distance = levenshtein(value, parameters[j])
				if distance <= moreSimilarDistance then
					moreSimilarDistance = distance
					moreSimilar = parameters[j]
				end
			end
			table.insert(correctedSuggestions, moreSimilar)
		end

		for i = 1, #notCorrectParameters do
			local dst = levenshtein(notCorrectParameters[i], correctedSuggestions[i])
			local msg = unnecessaryParameterMsg(value)
			if dst < math.floor(#notCorrectParameters[i] * 0.6) and data[i] == nil then
				msg = unnecessaryParameterMsg(value, correctedSuggestions[i])
			end
			customWarning(msg)
		end
	end)
end

--- Return a message indicating that a given parameter is unnecessary.
-- @param value A string or number or boolean value.
-- @param suggestion A possible suggestion for the parameter.
-- @usage unnecessaryParameterMsg("file")
-- unnecessaryParameterMsg("filf", "file")
function unnecessaryParameterMsg(value, suggestion)
	local str = "Parameter '"..tostring(value).."' is unnecessary."

	if suggestion then
		str = str .." Do you mean '"..suggestion.."'?"
	end
	return str
end

--- Stop the simulation with an error.
-- @param msg A string describing the error.
-- @usage customError("error message")
function customError(msg)
	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	end

	local level = getLevel()
	error("Error: "..msg, level)
end

--- Print a warning. If TerraME is executing in the debug mode, it stops the simulation with an error.
-- @param msg A string describing the warning.
-- @usage customWarning("warning message")
function customWarning(msg)
	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	elseif sessionInfo().mode == "normal" then
		local level = getLevel()
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		printWarning(str..":".. info.currentline ..": Warning: "..msg)
	elseif sessionInfo().mode == "debug" then
		customError(msg)
	end
	io.flush()
end

--- Verifies the default value of a given element of a table. It puts the default value in the table if it does not
-- exist, stops with an error (Package:incompatibleTypeMsg()) if the value has a different type, or a 
-- warning (Package:defaultValueWarning()) if it is equal to the default value.
-- @param data A table.
-- @param idx The element of the table (a string).
-- @param value The default value (any type).
-- @usage t = {x = 5}
-- defaultTableValue(t, "y", 8)
function defaultTableValue(data, idx, value)
	if data[idx] == nil then
		data[idx] = value
	elseif type(data[idx]) ~= type(value) then
		incompatibleTypeError(idx, type(value), data[idx])
	elseif data[idx] == value then
		defaultValueWarning(idx, value)
	end
end

--- Print a warning if the element of a table is the default value. If TerraME is running in the
-- debug mode, the simulation stops with an error. The warning message comes from Package:defaultValueMsg().
-- @param parameter The element.
-- @param value The default value.
-- @usage defaultValueWarning("size", 2)
function defaultValueWarning(parameter, value)
	mandatoryArgument(1, "string", parameter)

	customWarning(defaultValueMsg(parameter, value))
end

--- Return a message indicating that the modeler is using the default value and therefore it could be removed.
-- @param parameter A string.
-- @param value A number or string or boolean value.
-- @usage defaultValueMsg("dbtype", "mysql")
function defaultValueMsg(parameter, value)
	return "Parameter '"..parameter.."' could be removed as it is the default value ("..tostring(value)..")."
end

--- Pring a warning indicating a deprecated function. If TerraME is running in the
-- debug mode, the simulation stops with an error. The warning as well as the error
-- comes from Package:deprecatedFunctionMsg().
-- @param functionName Name of the deprecated function.
-- @param functionExpected A string with the name of the function to be used instead of the deprecated function.
-- @usage deprecatedFunctionWarning("abc", "def")
function deprecatedFunctionWarning(functionName, functionExpected)
	mandatoryArgument(1, "string", functionName)
	mandatoryArgument(2, "string", functionExpected)

	customWarning(deprecatedFunctionMsg(functionName, functionExpected))
end

--- Return a message indicating that a function is deprecated and must be replaced.
-- @param functionName A string with the deprecated function.
-- @param functionExpected A string with a function or an object to replace the deprecated function.
-- @usage deprecatedFunctionMsg("abc", "def")
function deprecatedFunctionMsg(functionName, functionExpected)
	return "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
end

--- Stop the simulation with an error from a wrong type for a parameter of a function.
-- The error message is the return value of Package:incompatibleTypeMsg().
-- @param attr A string with an attribute name, or position (such as #1).
-- @param expectedTypesString A string with the possible type (or types).
-- @param gottenValue The value passed as argument with wrong type.
-- @usage incompatibleTypeError("cell", "Cell", Agent{})
function incompatibleTypeError(attr, expectedTypesString, gottenValue)
	customError(incompatibleTypeMsg(attr, expectedTypesString, gottenValue))
end

--- Return an error message for incompatible types.
-- @param attr Name of the attribute. It can be a number indicating the position of the argument in a non-named function.
-- @param expectedTypesString The expected type.
-- @param gottenValue The gotten value, that does not belong to the expected type.
-- @usage incompatibleTypeMsg("dbType", "string", 2)
function incompatibleTypeMsg(attr, expectedTypesString, gottenValue)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	if expectedTypesString == nil then expectedTypesString = "nil" end

	return "Incompatible types. Parameter '"..attr.."' expected "..
		expectedTypesString..", got "..type(gottenValue).."."
end

--- Stop the simulation with an error from a wrong value for a parameter of a function.
-- The error message comes from Package:incompatibleValueMsg().
-- @param attr A string with an attribute name (for named-functions), or position (for non-named functions).
-- @param expectedValues A string with the expected type values for the parameter.
-- @param gottenValue The value passed as argument with wrong value.
-- @usage incompatibleValueError("position", "1, 2, or 3", "4")
function incompatibleValueError(attr, expectedValues, gottenValue)
	customError(incompatibleValueMsg(attr, expectedValues, gottenValue))
end

--- Return an error message for incompatible values.
-- @param attr Name of the attribute. It can be a number indicating the position of the argument in a non-named function.
-- @param expectedValues The expected values.
-- @param gottenValue The gotten value, that does not belong to the expected values.
-- @usage incompatibleValueMsg("dbType", "one of {1, 3, 4}", 2)
function incompatibleValueMsg(attr, expectedValues, gottenValue)
	if expectedValues == nil then expectedValues = "nil" end

	if type(attr) == "number" then
		attr = "#"..attr
	end

	local msg = "Incompatible values. Parameter '"..attr.."' expected ".. expectedValues ..", got "
	if type(gottenValue) == "string" then
		msg = msg.."'"..gottenValue.."'."
	elseif gottenValue == nil then
		msg = msg.."nil."
	else
		msg = msg..gottenValue.."."
	end
	return msg
end

--- Stop the simulation with an error indicating that the function does not support a given file extension.
-- The error message comes from Package:invalidFileExtensionMsg().
-- @param attr The attribute name (a string).
-- @param ext The file extension (a string).
-- @usage invalidFileExtensionError("file", ".txt")
function invalidFileExtensionError(attr, ext)
	customError(invalidFileExtensionMsg(attr, ext))
end

--- Return a message indicating that a given file extension is incompatible.
-- @param attr A string or a number with the argument of the function.
-- @param ext The incompatible file extension.
-- @usage invalidFileExtensionMsg("file", "csv")
function invalidFileExtensionMsg(attr, ext)
	return "Parameter '".. attr.."' does not support extension '"..ext.."'."
end

--- Stop the simulation with an error indicating that a given resource was not found.
-- The error message comes from Package:resourceNotFoundMsg().
-- @param attr The attribute name (a string).
-- @param path The location of the resource, described as a string.
-- @usage resourceNotFoundError("file", "/usr/local/file.txt")
function resourceNotFoundError(attr, path)
	customError(resourceNotFoundMsg(attr, path))
end

--- Return a message indicating that a given resource could not be found.
-- @param attr Name of the parameter. It can be a string or a number.
-- @param path The location of the resource in the computer.
-- @usage resourceNotFoundMsg("file", "c:\\myfiles\\file.csv")
function resourceNotFoundMsg(attr, path)
	if type(attr) == "number" then
		attr = "#"..attr
	end

    return "Resource '"..path.."' not found for parameter '"..attr.."'."
end

--- Stop the simulation with an error due to a wrong value for a parameter.
-- The error message comes from Package:valueNotFoundMsg().
-- @param attr The parameter name (a string).
-- @param value The wrong value, which can belong to any type.
-- @usage valueNotFoundError("1", "neighborhood")
function valueNotFoundError(attr, value)
	customError(valueNotFoundMsg(attr, value))
end

--- Return a message indicating that a given parameter of a function is mandatory.
-- @param attr The name of the parameter. It can be a string or a number.
-- @param value The valued used as argument to the function.
-- @usage valueNotFoundMsg("1", "neighborhood")
function valueNotFoundMsg(attr, value)
	if type(value) == nil then value = "nil" end
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Value '"..value.."' not found for parameter '"..attr.."'."
end

--- Verify whether a given parameter of a non-named function belong to the correct type.
-- The error message comes from Package:mandatoryArgumentMsg() and Package:incompatibleTypeMsg().
-- @param position The position of the parameter in the function signature (a number).
-- @param mtype The required type for the parameter.
-- @param value The valued used as argument to the function call.
-- @usage mandatoryArgument(1, "string", parameter)
function mandatoryArgument(position, mtype, value)
	if type(value) ~= mtype then
		if value == nil then
			mandatoryArgumentError(position)
		else
			incompatibleTypeError(position, mtype, value)
		end
	end
end

--- Stop the simulation with an error indicating that a given parameter is mandatory.
-- The error message comes from Package:mandatoryArgumentMsg().
-- @param attr The name of the parameter (a string).
-- @usage mandatoryArgumentError("target")
function mandatoryArgumentError(attr)
	customError(mandatoryArgumentMsg(attr))
end

--- Return a message indicating that a given parameter of a function is mandatory.
-- @param attr The name of the parameter. It can be a string or a number.
-- @usage mandatoryArgumentMsg(2)
-- mandatoryArgumentMsg("target")
function mandatoryArgumentMsg(attr)
	if type(attr) == "number" then
		attr = "#"..attr
	end
	return "Parameter '"..attr.."' is mandatory."
end

--- Verify whether the table contains a mandatory argument. It produces an error if the value is nil or
-- The error message comes from Package:mandatoryArgumentMsg() or Package:incompatibleTypeMsg().
-- it has a type different from the required type.
-- @param table A table.
-- @param attr The attribute name (a string).
-- @param mtype The required type for the attribute (a string).
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- mandatoryTableArgument(mtable, "bbb", "string")
function mandatoryTableArgument(table, attr, mtype)
	if table[attr] == nil then
		customError(mandatoryArgumentMsg(attr))
	elseif type(table[attr]) ~= mtype and mtype ~= nil then
		incompatibleTypeError(attr, mtype, table[attr])
	end
end

--- Verify whether the table contains an optional argument. It produces an error if the value is not nil and
-- it has a type different from the required type. The error comes from Package:incompatibleTypeError().
-- @param table A table.
-- @param attr The attribute name (a string).
-- @param allowedType The required type for the attribute (a string).
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- optionalTableArgument(mtable, "bbb", "string")
function optionalTableArgument(table, attr, allowedType)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, value)
	end
end

