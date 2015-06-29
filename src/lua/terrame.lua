-------------------------------------------------------------------------------------------
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
-- Authors:
--       Pedro R. Andrade (pedro.andrade@inpe.br)
--       Raian V. Maretto
-------------------------------------------------------------------------------------------

if os.setlocale(nil, "all") ~= "C" then os.setlocale("C", "numeric") end

local begin_red    = "\027[00;31m"
local begin_yellow = "\027[00;33m"
local begin_green  = "\027[00;32m"
local end_color    = "\027[00m"

_Gtme = {}
setmetatable(_Gtme, {__index = _G})

_Gtme.loadedPackages = {}
_Gtme.print = print
_Gtme.type = type

function _Gtme.printError(value)
	if sessionInfo().separator == "/" and sessionInfo().color then
		_Gtme.print(begin_red..value..end_color)
	else
		_Gtme.print(value)
	end
end

function _Gtme.printNote(value)
	if sessionInfo().separator == "/" and sessionInfo().color then
		_Gtme.print(begin_green..value..end_color)
	else
		_Gtme.print(value)
	end
end

function _Gtme.printWarning(value)
	if sessionInfo().separator == "/" and sessionInfo().color then
		_Gtme.print(begin_yellow..value..end_color)
	else
		_Gtme.print(value)
	end
end

-- from http://stackoverflow.com/questions/17673657/loading-a-file-and-returning-its-environment
function _Gtme.include(scriptfile, basetable)
	if basetable == nil then
		basetable = {}
	end

	local env = setmetatable(basetable, {__index = _G})
	if not isFile(scriptfile) then
		_Gtme.customError("File '"..scriptfile.."' does not exist.")
	end
	local lf = loadfile(scriptfile, "t", env)

	if lf == nil then
		_Gtme.printError("Could not load file "..scriptfile..".")
		dofile(scriptfile) -- this line will show the error when parsing the file
	end

	lf() 

	return setmetatable(env, nil)
end

-- from http://metalua.luaforge.net/src/lib/strict.lua.html
local function checkNilVariables()
	local mt = getmetatable(_G)
	if mt == nil then
		mt = {}
		setmetatable(_G, mt)
	end

	local __STRICT = true
	mt.__declared = {}

	mt.__newindex = function(t, n, v)
		if __STRICT and not mt.__declared[n] then
			local w = debug.getinfo(2, "S").what
			if w ~= "main" and w ~= "C" then
				_Gtme.strictWarning("Assign to undeclared variable '"..n.."'.")
			end
			mt.__declared[n] = true
		end
		rawset(t, n, v)
	end

	mt.__index = function(t, n)
		if not mt.__declared[n] and debug.getinfo(2, "S").what ~= "C" then
			_Gtme.strictWarning("Variable '"..n.."' is not declared.")
		end
		return rawget(t, n)
	end
end

local function countTable(mtable)
	local result = {}

	_Gtme.forEachElement(mtable, function(idx, value, mtype)
		if mtype == "function" or mtype == "Model" then
			result[idx] = 0
		elseif _Gtme.type(value) == "table" then
			_Gtme.forEachElement(value, function(midx, mvalue, mmtype)
				if mmtype == "function" or mmtype == "Model" then
					result[midx] = 0
				end
			end)
		end
	end)
	return result
end

-- builds a table with zero counts for each element of the table gotten as argument
function _Gtme.buildCountTable(package)
	local s = _Gtme.sessionInfo().separator
	local baseDir = _Gtme.packageInfo(package).path

	local load_file = baseDir..s.."load.lua"
	local load_sequence

	if _Gtme.isFile(load_file) then
		-- the 'include' below does not need to be inside a xpcall because 
		-- the package was already loaded with success
		load_sequence = _Gtme.include(load_file).files
	else
		load_sequence = {}
		_Gtme.forEachFile(baseDir..s.."lua", function(mfile)
			if string.endswith(mfile, ".lua") then
				table.insert(load_sequence, mfile)
			end
		end)
	end

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		-- the 'include' below does not need to be inside a xpcall because 
		-- the package was already loaded with success
		testfunctions[file] = countTable(_Gtme.include(baseDir..s.."lua"..s..file))
	end

	return testfunctions
end

local function sqlFiles(package)
	local s = _Gtme.sessionInfo().separator
	local files = {}
	data = function(mtable)
		if type(mtable.file) == "string" then mtable.file = {mtable.file} end

		_Gtme.forEachElement(mtable.file, function(_, mfile)
			if string.endswith(mfile, ".sql") then
				table.insert(files, mfile)
			end
		end)
	end

	xpcall(function() dofile(_Gtme.packageInfo(package).path..s.."data.lua") end, function(err)
		_Gtme.printError("Error loading "..package..s.."data.lua")
		_Gtme.printError(err)
		os.exit()
	end)

	data = _Gtme.data

	return files
end

function _Gtme.findModels(package)
	local s = _Gtme.sessionInfo().separator
	
	if not _Gtme.isLoaded("base") then
		_Gtme.import("base")
	end

	if not _Gtme.isLoaded(package) then
		_Gtme.import(package)
	end

	local models = {}
	local found = false
	local oldModel = Model
	Model = function()
		found = true
		return "___123"
	end

	local packagepath = _Gtme.packageInfo(package).path

	if _Gtme.attributes(packagepath, "mode") ~= "directory" then
		_Gtme.printError("Error: Package '"..package.."' is not installed.")
		os.exit()
	end

	local srcpath = packagepath..s.."lua"..s

	if _Gtme.attributes(srcpath, "mode") ~= "directory" then
		_Gtme.printError("Error: Folder 'lua' from package '"..package.."' does not exist.")
		os.exit()
	end

	_Gtme.forEachFile(srcpath, function(fname)
		found = false
		local a
		xpcall(function() a = _Gtme.include(srcpath..fname) end, function(err)
			_Gtme.printError("Error: Could not load "..fname..": "..err)
			os.exit()
		end)

		if found then
			_Gtme.forEachElement(a, function(idx, value)
				if value == "___123" then
					table.insert(models, idx)
				end
			end)
		end
	end)
	Model = oldModel
	return models
end

function _Gtme.findExamples(package)
	local s = _Gtme.sessionInfo().separator

	local examplespath

	xpcall(function() examplespath = _Gtme.packageInfo(package).path..s.."examples" end, function(err)
		_Gtme.printError(err)
		os.exit()
	end)

	if _Gtme.attributes(examplespath, "mode") ~= "directory" then
		return {}
	end

	local result = {}

	_Gtme.forEachFile(examplespath, function(fname)
		if string.endswith(fname, ".lua") then
			table.insert(result, string.sub(fname, 0, string.len(fname) - 4))
		elseif not string.endswith(fname, ".tme") and not string.endswith(fname, ".log") then
			_Gtme.printWarning("Test file '"..fname.."' does not have a valid extension")
		end
	end)
	return result
end

function _Gtme.showDoc(package)
	local s = _Gtme.sessionInfo().separator

	local docpath

	xpcall(function() docpath = _Gtme.packageInfo(package).path end, function(err)
		_Gtme.printError(err)
		os.exit()
	end)

	docpath = docpath..s.."doc"..s.."index.html"

	if s == "/" then
		if _Gtme.runCommand("uname")[1] == "Darwin" then
			_Gtme.runCommand("open "..docpath)
		else
			_Gtme.runCommand("xdg-open "..docpath)
		end
	else
		print("This functionality is still not implemented in Windows.")
	end
end

local function exportDatabase(package)
	local s = _Gtme.sessionInfo().separator

	local config = _Gtme.getConfig()

	local user = config.user
	local password = config.password
	local host = config.host
	local drop = config.drop

	local command = "mysqldump"

	if user then
		command = command.." -u"..user
	else
		command = command.." -u root"
	end

	if password and password ~= "" then
		command = command.." -p="..password
	end

	if host then
		command = command.." -h="..host
	end

	local folder = _Gtme.packageInfo(package).data
	local files = _Gtme.sqlFiles(package)

	_Gtme.forEachElement(files, function(_, mfile)
		local database = string.sub(mfile, 1, string.len(mfile) - 4)

		if _Gtme.isFile(folder..s..mfile) then
			_Gtme.printWarning("File "..mfile.." already exists and will not be replaced")
		else
			_Gtme.printNote("Exporting database "..database)
			local result = _Gtme.runCommand(command.." "..database.." > "..folder..mfile, 2)

			if result and result[1] then
				_Gtme.printError(result[1])
				os.execute("rm "..folder..mfile)
			else
				_Gtme.printNote("Database '"..database.."'successfully exported")
			end
		end
	end)
end

local function isWarningMessage(message)
	return string.match(string.upper(message), "WARNING")
end

local function importDatabase(package)
	local s = _Gtme.sessionInfo().separator

	local config = _Gtme.getConfig()

	local user = config.user
	local password = config.password
	local host = config.host
	local drop = config.drop

	local command = "mysql"

	if user then
		command = command.." -u"..user
	else
		command = command.." -u root"
	end

	if password and password ~= "" then
		command = command.." -p"..password
	end

	if host then
		command = command.." -h"..host
	end

	local folder = _Gtme.packageInfo(package).data
	local files = sqlFiles(package)

	_Gtme.forEachElement(files, function(_, value)
		local database = string.sub(value, 1, string.len(value) - 4)

		if drop then
			_Gtme.printNote("Deleting database '"..database.."'")
			local result = _Gtme.runCommand(command.." -e \"drop database "..database.."\"", 2)
		end

		_Gtme.printNote("Creating database '"..database.."'")
		local result = _Gtme.runCommand(command.." -e \"create database "..database.."\"", 2)
		if result and result[1] and not isWarningMessage(result[1]) then
			_Gtme.printError(result[1])
			_Gtme.printError("Add 'drop = true' to your config.lua to allow replacing databases if needed.")
		else
			_Gtme.printNote("Importing database '"..database.."'")
			os.execute(command .." "..database.." < "..folder..s..value)
			_Gtme.printNote("Database '"..database.."' successfully imported")
		end
	end)
end

function _Gtme.installPackage(file)
	if file == nil then
		_Gtme.printError("You need to choose the file to be installed.")
		return
	elseif not _Gtme.isFile(file) then
		_Gtme.printError("No such file: "..file)
		return
	end

	_Gtme.printNote("Installing "..file)

	local s = _Gtme.sessionInfo().separator
	local package
	local result = xpcall(function() package = string.sub(file, 1, string.find(file, "_") - 1) end, function(err)
		_Gtme.printError(file.." is not a valid file name for a TerraME package")
	end)

	if not result then return end

	local arg = _Gtme.sessionInfo().path..s.."packages"..s..package

	local currentDir = _Gtme.currentDir()
	local packageDir = _Gtme.sessionInfo().path..s.."packages"

	os.execute("cp "..file.." "..packageDir)
	_Gtme.chDir(packageDir)

	os.execute("unzip -q "..file)

	local lastSep = string.find(package, s, string.len(package) / 2)
	local name = package

	if lastSep then
		name = string.sub(package, lastSep + 1)
	end

	if not _Gtme.isLoaded("base") then
		_Gtme.import("base")
	end

	_Gtme.printNote("Trying to load package "..name)
	xpcall(function() import(name) end, function(err)
		_Gtme.printError("Package could not be loaded:")
		_Gtme.printError(err)

		os.execute("rm -rf "..package)
		os.exit()
	end)
	_Gtme.printNote("Package successfully installed")
	chDir(currentDir)

	os.execute("rm "..packageDir..s.."*.zip")
	return name
end

local function version()
	print("TerraME - Terra Modeling Environment")
	print("Version: ".._Gtme.sessionInfo().version)
	print("Location (TME_PATH): ".._Gtme.sessionInfo().path)

	local lua_release, qt_version, qwt_version, terralib_version, db_version = cpp_informations()

	print("Compiled with:")
	print("  "..lua_release)
	print("  Qt "..qt_version)
	print("  Qwt "..qwt_version)
	print("  TerraLib "..terralib_version.." (Database version: "..db_version..")")
end

local function usage()
	print("")
	print("Usage: TerraME [arguments] [file1.lua file2.lua ...]\n")
	print("Options: ")
	print(" -autoclose                  Automatically close the platform after simulation.")
--	print(" -draw-all-higher <value>    Draw all subjects when percentage of changes was higher")
--	print("                             than <value>. Value must be between interval [0, 1].")
	print(" -gui                        Show the player for the application (it works only ")
	print("                             when an Environment and/or a Timer objects are used).")
	print(" -ide                        Configure TerraME for running from IDEs in Windows systems.")
	print(" -ft                         Show the full traceback in case of errors (including")
	print("                             internal lines from TerraME and loaded packages).")
	print(" -mode=normal (default)      Warnings enabled.")
	print(" -mode=debug                 Warnings treated as errors.")
	print(" -mode=strict                Execute additional verifications in the source code ")
	print("                             when it finds unnecessary arguments for functions.")
	print(" -mode=quiet                 Warnings disabled.")
	print(" -mode=silent                print() does not show any text on the screen. This")
	print("                             mode can be used with the other three modes independently.")
	print(" -version                    TerraME general information.")
	print(" -color                      Show colored output (only for Linux and Mac systems).")
	print(" -package <pkg>              Select a given package. If used alone and the model has a")
	print("                             single model than it runs the graphical interface")
	print("                             creating an instance of such model.")
	print(" -install <file>             Install a package stored in a given file.")
	print(" [-package <pkg>] -test      Execute unit tests.")
	print(" [-package <pkg>] -example   Run an example.")
	print(" [-package <pkg>] -doc       Build the documentation.")
	print(" [-package <pkg>] -showdoc   Show the documentation in the default browser.")
	print(" [-package <pkg>] -interface Configure and run a Model using a graphical interface.")
	print(" [-package <pkg>] -importDb  Import .sql files described in data.lua from folder data")
	print("                             within the package to MySQL.")
	print(" [-package <pkg>] -exportDb  Export .sql files described in data.lua from MySQL to")
	print("                             folder data within the package.")
--	print(" -workers <value>            Sets the number of threads used for spatial observers.")
	print("\nFor more information, please visit www.terrame.org\n")
end

function _Gtme.replaceSpecialChars(pattern)
	local specialChars = {"%^", "%$", "%(", "%)", "%.", "%[", "%]", "%*", "%+", "%-", "%?"}

	pattern = string.gsub(pattern, "%%", "%%%%")
	for _, spChar in ipairs(specialChars) do
		pattern = string.gsub(pattern, spChar, "%"..spChar)
	end
	return pattern
end

function _Gtme.getLevel()
	local level = 1

	if _Gtme.sessionInfo().fullTraceback then
		return 3
	end

	while true do
		local info = debug.getinfo(level)

		if info == nil then
			return level - 1
		end

		local si = _Gtme.sessionInfo()

		local s = si.separator
		local m1 = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."lua"))
		local m2 = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."packages"..s.."base"..s.."lua"))
		local m3 = string.match(info.short_src, "%[C%]")
		local m4 = string.sub(info.short_src, 1, 1) == "["

		local mpackage = false

		local p = si.package
		if p then
			mpackage = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."packages"..s..p..s.."lua"))
		end

		if m1 or m2 or m3 or m4 or mpackage then
			level = level + 1
		else
			return level - 1 -- minus one because of getLevel()
		end
	end
end

local function graphicalInterface(package, model)
	local s = _Gtme.sessionInfo().separator
	_Gtme.sessionInfo().interface = true
	dofile(_Gtme.sessionInfo().path..s.."lua"..s.."interface.lua")
	local attrTab
	local mModel = Model
	Model = function(attr) attrTab = attr end
	local data = _Gtme.include(_Gtme.packageInfo(package).path..s.."lua"..s..model..".lua")
	Model = mModel

	_Gtme.interface(attrTab, model, package)
end

function _Gtme.traceback()
	local level = 1

	local si = sessionInfo()
	local s = si.separator
	local str = "Stack traceback:\n"

	local last_function = ""
	local found_function = false

	local info = debug.getinfo(level)
	while info ~= nil do
		local m1 = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."lua"))
		local m2 = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."packages"))
		local mb = string.match(info.source, _Gtme.replaceSpecialChars(si.path..s.."packages"..s.."base"))
		local m3 = string.match(info.short_src, "%[C%]")

		if m1 or m2 or m3 then
			last_function = info.name

			if (si.fullTraceback or si.package) and last_function then
				if si.package then
					if not mb and not m1 and not m3 then
						str = str.. "\n    In "..last_function.."\n"
						str = str.."    File "..info.short_src..", line "..info.currentline
					end
				else
					str = str.. "\n    In "..last_function.."\n"
					str = str.."    File "..info.short_src..", line "..info.currentline
				end
			end
		else
			if not found_function then
				if     last_function == "__add"      then last_function = "operator + (addition)"
				elseif last_function == "__sub"      then last_function = "operator - (subtraction)"
				elseif last_function == "__mul"      then last_function = "operator * (multiplication)"
				elseif last_function == "__div"      then last_function = "operator / (division)"
				elseif last_function == "__mod"      then last_function = "operator % (modulo)"
				elseif last_function == "__pow"      then last_function = "operator ^ (exponentiation)"
				elseif last_function == "__unm"      then last_function = "operator - (minus)"
				elseif last_function == "__concat"   then last_function = "operator .. (concatenation)"
				elseif last_function == "__len"      then last_function = "operator # (size)"
				elseif last_function == "__eq"       then last_function = "operator == (equal)"
				elseif last_function == "__lt"       then last_function = "comparison operator"
				elseif last_function == "__le"       then last_function = "comparison operator"
				elseif last_function == "__index"    then last_function = "operator [] (index)"
				elseif last_function == "__newindex" then last_function = "operator [] (index)"
				elseif last_function == "__call"     then last_function = "call"
				elseif last_function ~= nil          then last_function = "function '"..last_function.."'"
				end

				if last_function then
					str = str.. "\n    In "..last_function
				end
				found_function = true
			end


			str = str.."\n    File "..info.short_src..", line "..info.currentline
			if info.name then
				str = str..", in function "..info.name
			else
				str = str..", in main chunk"
			end
		end
		level = level + 1
		info = debug.getinfo(level)
	end
	if str == "Stack traceback:\n" then
		return ""
	end
	return string.sub(str, 0, string.len(str) - 1)
end

function _Gtme.execute(arguments) -- 'arguments' is a vector of strings
	info_ = { -- this variable is used by Utils:sessionInfo()
		mode = "normal",
		dbVersion = "1_3_1",
		separator = package.config:sub(1, 1),
		silent = false,
		color = false,
		path = os.getenv("TME_PATH"), 
		fullTraceback = false,
		autoclose = false
	}

	if info_.path == nil or info_.path == "" then
		error("Error: TME_PATH environment variable should exist and point to TerraME installation folder.", 2)
	end

	-- Package.lua contains functions that terrame.lua needs, but should also be
	-- documented and availeble for the final users.
	local s = info_.separator
	local path = info_.path..s.."packages"..s.."base"..s.."lua"..s
	dofile(path.."ErrorHandling.lua", _Gtme)
	dofile(path.."Package.lua", _Gtme)
	dofile(path.."FileSystem.lua", _Gtme)
	dofile(path.."Utils.lua", _Gtme)
	dofile(info_.path..s.."lua"..s.."legend.lua")
	dofile(info_.path..s.."lua"..s.."observer.lua")

	info_.version = _Gtme.packageInfo().version

	if arguments == nil or #arguments < 1 then 
		dofile(info_.path..s.."lua"..s.."pmanager.lua")
		_Gtme.packageManager()
		return true
	end

	local package = "base"

	local argCount = 1
	while argCount <= #arguments do
		arg = arguments[argCount]
		if string.sub(arg, 1, 1) == "-" then
			if arg == "-version" then
				version()
				os.exit()
			elseif arg == "-ide" then
				local __cellEmpty = Cell{attrib = 1}
				local __obsEmpty = Chart{subject = __cellEmpty, select = "attrib"}
				_Gtme.killAllObservers()
			elseif arg == "-ft" then
				info_.fullTraceback = true
			elseif arg == "-color" then
				info_.color = true
			elseif arg == "-mode=normal" then
				info_.mode = "normal"
			elseif arg == "-mode=debug" then
				info_.mode = "debug"
			elseif arg == "-mode=quiet" then
				info_.mode = "quiet"
			elseif arg == "-mode=strict" then
				info_.mode = "strict"
			elseif arg == "-mode=silent" then
				info_.silent = true
				print = function() end
			elseif string.sub(arg, 1, 6) == "-mode=" then
				_Gtme.printError("Invalid mode '"..string.sub(arg, 7).."'.")
				os.exit()
			elseif arg == "-package" then
				argCount = argCount + 1
				package = arguments[argCount]
				info_.package = package
				if #arguments <= argCount then
					local models

					xpcall(function() models = _Gtme.findModels(package) end, function(err)
						_Gtme.printError(err)
						os.exit()
					end)

					if #models == 1 then
						xpcall(function() graphicalInterface(package, models[1]) end, function(err)
							_Gtme.printError(err)
							_Gtme.printError(traceback())
						end)
						os.exit()
					end

					local description = _Gtme.packageInfo(package).path..s.."description.lua"

					if not isFile(description) then
						_Gtme.printError("File '"..package..s.."description.lua' does not exist.")
						os.exit()
					end

					local data = _Gtme.include(_Gtme.packageInfo(package).path..s.."description.lua")
					print("Package '"..package.."'")
					print(data.title)
					print("Version "..data.version..", "..data.date)

					if #models > 0 then
						print("Model(s):")
						forEachElement(models, function(_, value)
							print(" - "..value)
						end)
					end
	
					files = _Gtme.findExamples(package)

					if #files > 0 then
						print("Example(s):")
						forEachElement(files, function(_, value)
							print(" - "..value)
						end)
					end
					os.exit()
				end
			elseif arg == "-interface" then
				argCount = argCount + 1
				model = arguments[argCount]

				import("base")

				xpcall(function() import(package) end, function(err)
					_Gtme.printError(err)
					os.exit()
				end)

				local models = _Gtme.findModels(package)

				if model == nil then
					_Gtme.printError("You should indicate a Model to be used.")
					print("Please use one from the list below:")

					_Gtme.forEachElement(models, function(_, value)
						print(" - "..value)
					end)
					os.exit()
				elseif belong(model, models) then
					graphicalInterface(package, model)
				else
					_Gtme.printError("Model '"..model.."' does not exist in package '"..package.."'.")
					print("Please use one from the list below:")

					_Gtme.forEachElement(models, function(_, value)
						print(" - "..value)
					end)
					os.exit()
				end
			elseif arg == "-test" then
				if info_.package == nil then
					info_.package = "base"
				end

				info_.mode = "debug"
				argCount = argCount + 1
				dofile(path.."UnitTest.lua")

				local s = sessionInfo().separator
				dofile(_Gtme.sessionInfo().path..s.."lua"..s.."test.lua")
				local correct, errorMsg = xpcall(function() _Gtme.executeTests(package, arguments[argCount]) end, function(err)
					_Gtme.printError(err)
					--_Gtme.printError(traceback())
				end)
				os.exit()
			elseif arg == "-help" then 
				usage()
				os.exit()
			elseif arg == "-showdoc" then
				_Gtme.showDoc(package)
				os.exit()
			elseif arg == "-doc" then
				info_.mode = "strict"
				local s = _Gtme.sessionInfo().separator
				dofile(_Gtme.sessionInfo().path..s.."lua"..s.."doc.lua")
				local success, result = _Gtme.myxpcall(function() _Gtme.executeDoc(package) end)

				if not success then
					_Gtme.printError(result)
				end
			elseif arg == "-autoclose" then
				argCount = argCount + 1
				info_.autoclose = true
			elseif arg == "-workers" then
				-- #80
			elseif arg == "-draw-all-higher" then
				-- #78
			elseif arg == "-build" then
				if package == "base" then
					_Gtme.printError("TerraME cannot be built using -build.")
				else
					dofile(sessionInfo().path..s.."lua"..s.."build.lua")
					_Gtme.buildPackage(package)
				end
				os.exit()
			elseif arg == "-install" then
				_Gtme.installPackage(arguments[argCount + 1])
				os.exit()
			elseif arg == "-importDb" then
				importDatabase(package)
				os.exit()
			elseif arg == "-exportDb" then
				exportDatabase(package)
				os.exit()
			elseif arg == "-example" then
				local file = arguments[argCount + 1]

				if file then
					local info
					xpcall(function() info = packageInfo(package).path end, function(err)
						_Gtme.printError(err)
						os.exit()
					end)

					arg = info..s.."examples"..s..file..".lua"

					if not isFile(arg) then
						_Gtme.printError("Example '"..file.."' does not exist in package '"..package.."'.")
						print("Please use one from the list below:")
					end
				elseif package == "base" then
					print("TerraME has the following examples:")
				else
					print("Package '"..package.."' has the following examples:")
				end

				if file and isFile(arg) then
					-- it only changes the file to point to the package and let it run as it
					-- was a call such as "TerraME .../package/examples/example.lua"
					arguments[argCount + 1] = arg
				else
					files = _Gtme.findExamples(package)

					_Gtme.forEachElement(files, function(_, value)
						print(" - "..value)
					end)
					os.exit()
				end
			elseif arg == "-gui" then
				-- this option was already recognized by the C++ level #79
			else
				_Gtme.printError("Option not recognized: "..arg)
				os.exit()
			end
		else
			if info_.mode ~= "quiet" then
				checkNilVariables()
			end

			if not _Gtme.isLoaded("base") then
				_Gtme.import("base")
			end

			local s = _Gtme.sessionInfo().separator

			local displayFile = string.sub(arg, 0, string.len(arg) - 3).."tme"

			local cObj = TeVisualArrangement()
			cObj:setFile(displayFile)

			if _Gtme.isFile(displayFile) then
				local display = dofile(displayFile)

				_Gtme.forEachElement(display, function(idx, data)
					cObj:addPosition(idx, data.x, data.y)
					cObj:addSize(idx, data.width, data.height)
				end)
			end

			local success, result = _Gtme.myxpcall(function() dofile(arg) end) 
			if not success then
				_Gtme.printError(result)
			end

		end
		argCount = argCount + 1
	end
	return true
end

function _Gtme.myxpcall(func)
	return xpcall(func, function(err)
		local si = _Gtme.sessionInfo()
		local s = si.separator
		local luaFolder = _Gtme.replaceSpecialChars(si.path..s.."lua")
		local baseLuaFolder = _Gtme.replaceSpecialChars(si.path..s.."packages"..s.."base"..s.."lua")
		local luadocLuaFolder = _Gtme.replaceSpecialChars(si.path..s.."packages"..s.."luadoc")
				
		local m1 = string.match(err, string.sub(luaFolder, string.len(luaFolder) - 25, string.len(luaFolder)))
		local m2 = string.match(err, string.sub(baseLuaFolder, string.len(baseLuaFolder) - 25, string.len(baseLuaFolder)))
		local m3 = string.match(err, string.sub(luadocLuaFolder, string.len(luadocLuaFolder) - 25, string.len(luadocLuaFolder)))
		local m4 = string.match(err, "%[C%]")

		if m1 or m2 or m3 or m4 then
			local str = 
				"*************************************************************\n"..
				"UNEXPECTED TERRAME INTERNAL ERROR. PLEASE GIVE US A FEEDBACK.\n"..
				"WRITE AN EMAIL TO pedro.andrade@inpe.br REPORTING THIS ERROR.\n"..
				"*************************************************************\n"..
				err.."\nStack traceback:\n"

			local level = 1
			local info = debug.getinfo(level)
			while info ~= nil do
				if info.short_src == "[C]" then
					str = str.."    Internal C file"
				else
					str = str.."    File "..info.short_src
				end

				if info.currentline > 0 then
					str = str..", line "..info.currentline
				end

				if info.name then
					str = str..", in function "..info.name
				else
					str = str..", in main chunk"
				end
				str = str.."\n"
				level = level + 1
				info = debug.getinfo(level)
			end
			return string.sub(str, 0, string.len(str) - 1)
		else
			local msg = _Gtme.traceback()

			if msg ~= "" then
				msg = err.."\n"..msg
			else
				msg = err
			end

			return msg
		end
	end)
end

function _Gtme.tostring(self)
	local rs = {}
	local maxlen = 0

	_Gtme.forEachElement(self, function(index)
		if type(index) ~= "string" then index = tostring(index) end

		if index:len() > maxlen then
			maxlen = index:len()
		end
	end)

	local result = ""
	_Gtme.forEachOrderedElement(self, function(index, value, mtype)
		if type(index) ~= "string" then index = tostring(index) end

		result = result..index.." "

		local size = maxlen - index:len()
		local i
		for i = 0, size do
			result = result.." "
		end

		if mtype == "number" then
			result = result..mtype.." ["..value.."]"
		elseif mtype == "boolean" then
			if value then
				result = result.."boolean [true]"
			else
				result = result.."boolean [false]"
			end
		elseif mtype == "string" then
			result = result.."string [".. value.."]"
		elseif mtype == "table" then
			result = result.."table of size "..#value..""
		else
			result = result..mtype
		end

		result = result.."\n"
	end)

	return result
end

