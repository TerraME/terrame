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

--- Check the dependencies of a package, showing warnings when the required
-- version does not match with the current version.
-- @arg package A string with the package name.
-- @usage checkDepends("tube")
function checkDepends(package)
	local pinfo = packageInfo(package)

	local function getVersion(str)
		local version = {}

		local function igetVersion(str)
			if tonumber(str) and not string.match(str, "%.") then -- SKIP
				table.insert(version, str) -- SKIP
			else
				local result = string.gsub(str, "(%d).", function(v)
					table.insert(version, v) -- SKIP
					return ""
				end)
				igetVersion(result) -- SKIP
			end
		end

		igetVersion(str) -- SKIP
		return version
	end

	local result = true

	if not pinfo.tdepends then return end

	forEachElement(pinfo.tdepends, function(_, dtable)
		local currentInfo = packageInfo(dtable.package)
		
		if not isLoaded(dtable.package) then -- SKIP
			require(dtable.package) -- SKIP
		end

		local currentVersion = getVersion(currentInfo.version)

		local dstrversion = table.concat(dtable.version, ".")

		if dtable.operator == "==" then -- SKIP
			if dstrversion ~= currentInfo.version then -- SKIP
				customWarning("Package '"..package.."' requires '"..dtable.package.."' version '".. -- SKIP
					dstrversion.."', got '"..currentInfo.version.."'.") -- SKIP
				result = false -- SKIP
			end
		elseif dtable.operator == ">=" then
			local i = 1
			local lresult = true

			while i <= #dtable.version and i <= #currentVersion and dtable.version[i] == currentVersion[i] do
				i = i + 1 -- SKIP
			end

			if i == #dtable.version and i == #currentVersion then -- SKIP
				lresult = dtable.version[i] <= currentVersion[i] -- SKIP
			elseif #dtable.version < #currentVersion then
				lresult = false -- SKIP
			end

			if not lresult then -- SKIP
				result = false -- SKIP
				customWarning("Package '"..package.."' requires '"..dtable.package.."' version >= '".. -- SKIP
					dstrversion.."', got '"..currentInfo.version.."'.") -- SKIP
			end
		elseif dtable.operator == "<=" then
			local i = 1
			local lresult = true

			while i <= #dtable.version and i <= #currentVersion and dtable.version[i] == currentVersion[i] do
				i = i + 1 -- SKIP
			end

			if i == #dtable.version and i == #currentVersion then -- SKIP
				lresult = dtable.version[i] >= currentVersion[i] -- SKIP
			elseif #dtable.version > #currentVersion then
				lresult = false -- SKIP
			end

			if not lresult then -- SKIP
				result = false -- SKIP
				customWarning("Package '"..package.."' requires '"..dtable.package.."' version <= '".. -- SKIP
					dstrversion.."', got '"..currentInfo.version.."'.") -- SKIP
			end
		else
			customError("Wrong operator: "..dtable.operator) -- SKIP
		end
	end)

	return result
end

--- Return the description of a package. It reads all the attributes from file 
-- description.lua of the package and create an additional attribute data, with 
-- the path to folder data in the package.
-- @arg package Name of the package. If nil, packageInfo will return
-- the description of TerraME.
-- @usage packageInfo().version
function packageInfo(package)
	if package == nil then package = "base" end

	if belong(package, {"terrame", "TerraME"}) then
		package = "base"
	end

	local s = sessionInfo().separator
	local pkgfile = sessionInfo().path..s.."packages"..s..package
	if not isFile(pkgfile) then
		customError("Package '"..package.."' is not installed.")
	end
	
	local file = pkgfile..s.."description.lua"
	
	local result 
	xpcall(function() result = include(file) end, function(err)
		printError("Package "..package.." has a corrupted description.lua")
		printError(err)
		os.exit() -- SKIP
	end)

	if result == nil then
		customError("Could not read description.lua") -- SKIP
	end

	result.data = pkgfile..s.."data"..s

	if result.depends then
		local s = string.gsub(result.depends, "([%w]+ %(%g%g %d[.%d]+%))", function(v)
			return ""
		end)

		if s ~= "" then
			s = string.gsub(s, "%, ", function(v)
				return ""
			end)
		end

		if s ~= "" then
			customError("Wrong description of 'depends' in description.lua of package '"..package.."'. Unrecognized '"..s.."'.")
		end

		local mversion

		local function getVersion(str)
			if tonumber(str) and not string.match(str, "%.") then -- SKIP
				table.insert(mversion, str) -- SKIP
			else
				local result = string.gsub(str, "(%d).", function(v)
					table.insert(mversion, v) -- SKIP
					return ""
				end)
				getVersion(result) -- SKIP
			end
		end

		local mdepends = {}
		s = string.gsub(result.depends, "([%w]+) %((%g%g) (%d[.%d]+)%)",
		function(value, v2, v3)
			mversion = {}
			getVersion(v3) -- SKIP
			table.insert(mdepends, {package = value, operator = v2, version = mversion})
		end)

		result.tdepends = mdepends
	end

	return result
end

--- Return the path to a file of a given package. The file must be inside the data folder
-- of the package.
-- @arg filename A string with the name of the file.
-- @arg package A string with the name of the package.
-- @usage file("cs.csv") 
function file(filename, package)
	if package == nil then package = "base" end

	local s = sessionInfo().separator
	local file = sessionInfo().path..s.."packages"..s..package..s.."data"..s..filename
	if not isFile(file) then
		customError("File '"..file.."' does not exist in package '"..package.."'.")
	end
	return file
end

--- Implement a switch case function, where options are given and there are functions
-- associated to them. It can have a field "missing" in the caseof that is used when
-- the first argument does not have an attribute whose name is the value of the second argument.
-- @arg data A table.
-- @arg att The chosen attribute.
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
				switchInvalidArgument(att, self.casevar, code)

			end
		end
	}
	return swtbl
end

--- Stops the simulation with an error because the used did not use a correct option.
-- This function supposes that there is a set of available options described as
-- string idexes of a table so it tries to find an approximate string to be shown as
-- a suggestion. Otherwise, it shows all the available options.
-- The error messages come from switchInvalidArgumentSuggestionMsg() and
-- switchInvalidArgumentMsg().
-- @arg att The attribute name (a string).
-- @arg value The wrong value passed as argument.
-- @arg suggestions A table with string indexes describing the available options.
-- @usage t = {
--     blue = true,
--     red = true,
--     green = true
-- }
--
-- switchInvalidArgument("attribute", "gren", t) 
function switchInvalidArgument(att, value, suggestions)
	local sugg = suggestion(value, suggestions)
	if sugg then
		customError(switchInvalidArgumentSuggestionMsg(value, att, sugg))
	else
		customError(switchInvalidArgumentMsg(value, att, suggestions))
	end
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
			customError("All the indexes in #2 should be string, got '"..type(a).."'.")
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

--- Return a message for a wrong argument value showing the options.
-- @arg casevar Value of the attribute.
-- @arg att Name of the attribute.
-- @arg options A table with the available options.
-- @usage local options = {
--     aaa = true,
--     bbb = true,
--     ccc = true
-- }
-- switchInvalidArgumentMsg("ddd", "attr", options)
function switchInvalidArgumentMsg(casevar, att, options)
	local word = "It must be a string from the set ["
	forEachOrderedElement(options, function(a)
		word = word.."'"..a.."', "
	end)
	word = string.sub(word, 0, string.len(word) - 2).."]."
	return "'"..casevar.."' is an invalid value for argument '"..att.."'. "..word
end

--- Return a message for a wrong argument value showing the most similar option.
-- @arg casevar Value of the attribute.
-- @arg att Name of the attribute.
-- @arg suggestion A suggestion for to replace the wrong value.
-- @usage switchInvalidArgumentSuggestionMsg("aab", "attr", "aaa")
function switchInvalidArgumentSuggestionMsg(casevar, att, suggestion)
	return "'"..casevar.."' is an invalid value for argument '"..att.."'. Do you mean '"..suggestion.."'?"
end

--- Return whether a given package is loaded.
-- @arg package Name of the package.
-- @usage isLoaded("base")
function isLoaded(package)
	mandatoryArgument(1, "string", package)
	return belong(package, loadedPackages__)
end

--- Load a given package. If the package is not installed, it tries to load from a folder in the
-- current directory.
-- @arg package A package name.
-- @usage require("calibration")
function require(package)
	mandatoryArgument(1, "string", package)

	if belong(package, {"terrame", "TerraME"}) then
		return
	end

	if isLoaded(package) and sessionInfo().package == nil then
		customWarning("Package '"..package.."' is already loaded.")
	else
		local s = sessionInfo().separator
		local package_path = sessionInfo().path..s.."packages"..s..package

		if not isFile(package_path) then
			if isFile(package) then
				printWarning("Loading package '"..package.."' from a folder in the current directory")
				package_path = package -- SKIP
			else
				customError("Package '"..package.."' is not installed.")
			end
		end

		checkDepends(package)

		local load_file = package_path..s.."load.lua"
		local all_files = dir(package_path..s.."lua")
		local load_sequence

		if isFile(load_file) then -- SKIP
			xpcall(function() load_sequence = include(load_file) end, function(err)
				printError("Package '"..package.."' could not be loaded.")
				print(err)
			end)

			checkUnnecessaryArguments(load_sequence, {"files"})

			load_sequence = load_sequence.files -- SKIP
			if load_sequence == nil then -- SKIP
				printError("Package '"..package.."' could not be loaded.")
				printError("load.lua should declare table 'files', with the order of the files to be loaded.")
				os.exit() -- SKIP
			elseif type(load_sequence) ~= "table" then
				printError("Package '"..package.."' could not be loaded.")
				printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
				os.exit() -- SKIP
			end
		else
			load_sequence = all_files -- SKIP
		end

		local count_files = {}
		for _, file in ipairs(all_files) do
			count_files[file] = 0 -- SKIP
		end

		local i, file

		if load_sequence then -- SKIP
			for _, file in ipairs(load_sequence) do
				local mfile = package_path..s.."lua"..s..file
				if not isFile(mfile) then -- SKIP
					printError("Cannot open "..mfile..". No such file.")
					printError("Please check "..package_path..s.."load.lua")
					os.exit() -- SKIP
				end
				xpcall(function() dofile(mfile) end, function(err)
					printError("Package '"..package.."' could not be loaded.")
					printError(err)
					os.exit() -- SKIP
				end)
				count_files[file] = count_files[file] + 1 -- SKIP
			end
		end

		for mfile, count in pairs(count_files) do
			local attr = attributes(package_path..s.."lua"..s..mfile)
			if count == 0 and attr.mode ~= "directory" then -- SKIP
				printWarning("File lua"..s..mfile.." is ignored by load.lua.")
			elseif count > 1 then
				printWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.")
			end
		end

		table.insert(loadedPackages__, package) -- SKIP
	end
end

--- Verify a given condition, otherwise stops the simulation with an error.
-- @arg condition A value of any type. If it is not true, the function generates an error.
-- @arg msg A string with the error to be displayed.
-- @usage verify(2 < 3, "wrong operator")
function verify(condition, msg)
	if not condition then
		customError(msg)
	end
end

--- Verify whether the table passed as argument is a named table. It generates errors if it is nil,
-- if it is not a table, or if it has numeric indexes. The error messages come from
-- Package:tableArgumentMsg() and Package:namedArgumentsMsg().
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

--- Return a message indicating that the argument of a function must be a table.
-- @usage tableArgumentMsg()
function tableArgumentMsg()
	return "Argument must be a table."
end

--- Return a message indicating that the arguments of a function must be named.
-- @usage namedArgumentsMsg()
function namedArgumentsMsg()
	return "Arguments must be named."
end

--- Verify whether the user has passed only the allowed arguments for a function, printing
-- a warning otherwise. The warning comes from Package:unnecessaryArgumentMsg().
-- This function returns the number of unnecessary arguments found.
-- @arg data The list of arguments used in the function call.
-- @arg arguments The list of the allowed arguments.
-- @usage t = {value = 2}
-- checkUnnecessaryArguments(t, {"target", "select"})
function checkUnnecessaryArguments(data, arguments)
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
			customWarning(msg)
		end
	end)
	return count
end

--- Return a message indicating that a given argument is unnecessary.
-- @arg value A string or number or boolean value.
-- @arg suggestion A possible suggestion for the argument.
-- @usage unnecessaryArgumentMsg("file")
-- unnecessaryArgumentMsg("filf", "file")
function unnecessaryArgumentMsg(value, suggestion)
	local str = "Argument '"..tostring(value).."' is unnecessary."

	if suggestion then
		str = str .." Do you mean '"..suggestion.."'?"
	end
	return str
end

--- Stop the simulation with an error.
-- @arg msg A string describing the error.
-- @usage customError("error message")
function customError(msg)
	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	end

	local level = getLevel()
	error("Error: "..msg, level)
end

--- Print a warning. If TerraME is executing in the debug mode, it stops the simulation with an error.
-- @arg msg A string describing the warning.
-- @usage customWarning("warning message")
function customWarning(msg)
	if type(msg) ~= "string" then
		customError(incompatibleTypeMsg(1, "string", msg))
	end

	local level = getLevel()
	local info = debug.getinfo(level)
	local func = printWarning
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

--- Verifies the default value of a given element of a table. It puts the default value in the table if it does not
-- exist, stops with an error (Package:incompatibleTypeMsg()) if the value has a different type, or a 
-- warning (Package:defaultValueWarning()) if it is equal to the default value.
-- @arg data A table.
-- @arg idx The element of the table (a string).
-- @arg value The default value (any type).
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
-- @arg argument The element.
-- @arg value The default value.
-- @usage defaultValueWarning("size", 2)
function defaultValueWarning(argument, value)
	mandatoryArgument(1, "string", argument)

	customWarning(defaultValueMsg(argument, value))
end

--- Return a message indicating that the modeler is using the default value and therefore it could be removed.
-- @arg argument A string.
-- @arg value A number or string or boolean value.
-- @usage defaultValueMsg("dbtype", "mysql")
function defaultValueMsg(argument, value)
	return "Argument '"..argument.."' could be removed as it is the default value ("..tostring(value)..")."
end

--- Pring a warning indicating a deprecated function. If TerraME is running in the
-- debug mode, the simulation stops with an error. The warning as well as the error
-- comes from Package:deprecatedFunctionMsg().
-- @arg functionName Name of the deprecated function.
-- @arg functionExpected A string with the name of the function to be used instead of the deprecated function.
-- @usage deprecatedFunction("abc", "def")
function deprecatedFunction(functionName, functionExpected)
	mandatoryArgument(1, "string", functionName)
	mandatoryArgument(2, "string", functionExpected)

	customError(deprecatedFunctionMsg(functionName, functionExpected))
end

--- Return a message indicating that a function is deprecated and must be replaced.
-- @arg functionName A string with the deprecated function.
-- @arg functionExpected A string with a function or an object to replace the deprecated function.
-- @usage deprecatedFunctionMsg("abc", "def")
function deprecatedFunctionMsg(functionName, functionExpected)
	return "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
end

--- Stop the simulation with an error from a wrong type for a argument of a function.
-- The error message is the return value of Package:incompatibleTypeMsg().
-- @arg attr A string with an attribute name, or position (such as #1).
-- @arg expectedTypesString A string with the possible type (or types).
-- @arg gottenValue The value passed as argument with wrong type.
-- @usage incompatibleTypeError("cell", "Cell", Agent{})
function incompatibleTypeError(attr, expectedTypesString, gottenValue)
	customError(incompatibleTypeMsg(attr, expectedTypesString, gottenValue))
end

--- Return an error message for incompatible types.
-- @arg attr Name of the attribute. It can be a number indicating the position of the argument in a non-named function.
-- @arg expectedTypesString The expected type.
-- @arg gottenValue The gotten value, that does not belong to the expected type.
-- @usage incompatibleTypeMsg("dbType", "string", 2)
function incompatibleTypeMsg(attr, expectedTypesString, gottenValue)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	if expectedTypesString == nil then expectedTypesString = "nil" end

	return "Incompatible types. Argument '"..attr.."' expected "..
		expectedTypesString..", got "..type(gottenValue).."."
end

--- Stop the simulation with an error from a wrong value for a argument of a function.
-- The error message comes from Package:incompatibleValueMsg().
-- @arg attr A string with an attribute name (for named-functions), or position (for non-named functions).
-- @arg expectedValues A string with the expected type values for the argument.
-- @arg gottenValue The value passed as argument with wrong value.
-- @usage incompatibleValueError("position", "1, 2, or 3", "4")
function incompatibleValueError(attr, expectedValues, gottenValue)
	customError(incompatibleValueMsg(attr, expectedValues, gottenValue))
end

--- Return an error message for incompatible values.
-- @arg attr Name of the attribute. It can be a number indicating the position of the argument in a non-named function.
-- @arg expectedValues The expected values.
-- @arg gottenValue The gotten value, that does not belong to the expected values.
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

--- Stop the simulation with an error indicating that the function does not support a given file extension.
-- The error message comes from Package:invalidFileExtensionMsg().
-- @arg attr A string with an attribute name (for named-functions), or position (for non-named functions).
-- @arg ext The file extension (a string).
-- @usage invalidFileExtensionError("file", ".txt")
function invalidFileExtensionError(attr, ext)
	customError(invalidFileExtensionMsg(attr, ext))
end

--- Return a message indicating that a given file extension is incompatible.
-- @arg attr A string or a number with the argument of the function.
-- @arg ext The incompatible file extension.
-- @usage invalidFileExtensionMsg("file", "csv")
function invalidFileExtensionMsg(attr, ext)
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Argument '".. attr.."' does not support extension '"..ext.."'."
end

--- Stop the simulation with an error indicating that a given resource was not found.
-- The error message comes from Package:resourceNotFoundMsg().
-- @arg attr The attribute name (a string).
-- @arg path The location of the resource, described as a string.
-- @usage resourceNotFoundError("file", "/usr/local/file.txt")
function resourceNotFoundError(attr, path)
	customError(resourceNotFoundMsg(attr, path))
end

--- Return a message indicating that a given resource could not be found.
-- @arg attr Name of the argument. It can be a string or a number.
-- @arg path The location of the resource in the computer.
-- @usage resourceNotFoundMsg("file", "c:\\myfiles\\file.csv")
function resourceNotFoundMsg(attr, path)
	if type(attr) == "number" then
		attr = "#"..attr
	end

    return "Resource '"..path.."' not found for argument '"..attr.."'."
end

--- Stop the simulation with an error due to a wrong value for a argument.
-- The error message comes from Package:valueNotFoundMsg().
-- @arg attr The argument name (a string).
-- @arg value The wrong value, which can belong to any type.
-- @usage valueNotFoundError("1", "neighborhood")
function valueNotFoundError(attr, value)
	customError(valueNotFoundMsg(attr, value))
end

--- Return a message indicating that a given argument of a function is mandatory.
-- @arg attr The name of the argument. It can be a string or a number.
-- @arg value The valued used as argument to the function.
-- @usage valueNotFoundMsg("1", "neighborhood")
function valueNotFoundMsg(attr, value)
	if type(value) == nil then value = "nil" end
	if type(attr) == "number" then
		attr = "#"..attr
	end

	return "Value '"..value.."' not found for argument '"..attr.."'."
end

--- Verify whether a given argument of a non-named function is integer.
-- The error message comes from Package:integerArgumentMsg().
-- @arg position The position of the argument in the function signature (a number).
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
-- The error message comes from Package:integerArgumentMsg().
-- @arg table A table.
-- @arg attr The attribute name (a string).
-- @usage mtable = {bbb = 2.3}
-- integerTableArgument(table, "bbb")
function integerTableArgument(table, attr)
	if math.floor(table[attr]) ~= table[attr] then
		customError(integerArgumentMsg(attr, table[attr]))
	end
end

--- Verify whether a given argument of a non-named function is positive.
-- The error message comes from Package:positiveArgumentMsg().
-- @arg position The position of the argument in the function signature (a number).
-- @arg value The valued used as argument to the function call.
-- @arg zero A boolean value indicating whether zero should be included (default is false).
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
-- @arg value The valued used as argument to the function call.
-- @arg zero A boolean value indicating whether zero should be included (default is false).
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

--- Verify whether a given argument of a named function is positive.
-- The error message comes from Package:positiveArgumentMsg().
-- @arg table A table.
-- @arg attr The attribute name (a string).
-- @arg zero A boolean value indicating whether zero should be included (default is false).
-- @usage mtable = {bbb = -3}
-- positiveTableArgument(table, "bbb")
function positiveTableArgument(table, attr, zero)
	if not zero then
		if table[attr] <= 0 then customError(positiveArgumentMsg(attr, table[attr], false)) end
	else
		if table[attr] < 0 then customError(positiveArgumentMsg(attr, table[attr], true)) end
	end
end

--- Verify whether a given argument of a non-named function belong to the correct type.
-- The error message comes from Package:mandatoryArgumentMsg() and Package:incompatibleTypeMsg().
-- @arg position The position of the argument in the function signature (a number).
-- @arg mtype The required type for the argument.
-- @arg value The valued used as argument to the function call.
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
-- The error message comes from Package:mandatoryArgumentMsg().
-- @arg attr The name of the argument (a string) or the position of the argument in the
-- function signature (a number).
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

--- Verify whether the table contains a mandatory argument. It produces an error if the value is nil or
-- The error message comes from Package:mandatoryArgumentMsg() or Package:incompatibleTypeMsg().
-- it has a type different from the required type.
-- @arg table A table.
-- @arg attr The attribute name (a string).
-- @arg mtype The required type for the attribute (a string).
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- mandatoryTableArgument(mtable, "bbb", "string")
function mandatoryTableArgument(table, attr, mtype)
	if table[attr] == nil then
		mandatoryArgumentError(attr)
	elseif type(table[attr]) ~= mtype and mtype ~= nil then
		incompatibleTypeError(attr, mtype, table[attr])
	end
end

--- Verify whether an optional argument of a non-named function belong to the correct type.
-- The error message comes from Package:incompatibleTypeMsg(), only if the argument is not nil.
-- @arg position The position of the argument in the function signature (a number).
-- @arg mtype The required type for the argument.
-- @arg value The valued used as argument to the function call.
-- @usage optionalArgument(1, "string", argument)
function optionalArgument(position, mtype, value)
	if value ~= nil and type(value) ~= mtype then
		incompatibleTypeError(position, mtype, value)
	end
end

--- Verify whether the table contains an optional argument. It produces an error if the value is not nil and
-- it has a type different from the required type. The error comes from Package:incompatibleTypeError().
-- @arg table A table.
-- @arg attr The attribute name (a string).
-- @arg allowedType The required type for the attribute (a string).
-- @usage mtable = {bbb = 3, ccc = "aaa"}
-- optionalTableArgument(mtable, "bbb", "string")
function optionalTableArgument(table, attr, allowedType)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, value)
	end
end

--- Return a string with a literal description of a parameter name. It is 
-- useful to work with Model::check() when the model will be available through a graphical interface.
-- When using graphical interfaces, it converts upper case characters into space and lower case
-- characters and convert the first character of the string to uppercase. 
-- Otherwise, it return the name of the parameter itself.
-- @arg mstring A parameter name.
-- @arg parent Used when the parameter belongs to a table parameter.
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

