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

if os.setlocale(nil, "all") ~= "C" then os.setlocale("C", "numeric") end

local begin_red    = "\027[1;31m"
local begin_yellow = "\027[1;33m"
local begin_green  = "\027[1;32m"
local end_color    = "\027[0m"

_Gtme = {}
setmetatable(_Gtme, {__index = _G})

_Gtme.loadedPackages = {}
_Gtme.loadedFonts = {}
_Gtme.createdObservers = {}
_Gtme.fonts = {}
_Gtme.print = print
_Gtme.iowrite = io.write
_Gtme.type = type

print = function(obj, ...)
	if type(obj) == "table" then
		obj = vardump(obj)
	end

	_Gtme.print(obj, ...)
end

function _Gtme.loadLibraryPath()
	local dyldpath = os.getenv("DYLD_LIBRARY_PATH")
	if dyldpath then
		package.cpath = package.cpath..";"..dyldpath.."/?.so;"
										..dyldpath.."/?.dylib"
		package.path = package.path..";"..dyldpath.."/?.lua;"
	end

	local ldpath = os.getenv("LD_LIBRARY_PATH")
	if ldpath then
		package.cpath = package.cpath..";"..ldpath.."/?.so"
		package.path = package.path..";"..ldpath.."/?.lua;"
	end
end

_Gtme.loadLibraryPath()

_Gtme.terralib_mod_binding_lua = nil

local function initializeTerraLib()
	if _Gtme.terralib_mod_binding_lua == nil then
		require("terralib_mod_binding_lua")
		local binding = terralib_mod_binding_lua
		binding.TeSingleton.getInstance():initialize()
		binding.InitializePluginSystem()
		binding.LoadAll()
		_Gtme.terralib_mod_binding_lua = terralib_mod_binding_lua
	end
end

local function finalizeTerraLib()
	if _Gtme.terralib_mod_binding_lua ~= nil then
		local binding = terralib_mod_binding_lua
		binding.FinalizePluginSystem()
		binding.TeSingleton.getInstance():finalize()
		_Gtme.terralib_mod_binding_lua = nil
	end
end

initializeTerraLib()

local function checkUnnecessaryArguments(arguments, argCount)
	if #arguments > argCount then
		if belong(arguments[argCount + 1], {">", "2>"}) then return end

		_Gtme.printError("It is not possible to have additional arguments after '"..arguments[argCount].."'.")
		os.exit(1)
	end
end

local function colorText(value, color)
	value = string.gsub(value, "\n", end_color.."\n"..color)
	return color..value..end_color
end

function _Gtme.printError(value)
	if sessionInfo().color then
		value = colorText(value, begin_red)
	end

	_Gtme.print(value)
end

function _Gtme.printNote(value)
	if sessionInfo().color then
		value = colorText(value, begin_green)
	end

	_Gtme.print(value)
end

function _Gtme.printWarning(value)
	if sessionInfo().color then
		value = colorText(value, begin_yellow)
	end

	_Gtme.print(value)
end

function _Gtme.fontFiles(package)
	local fontpath = Directory(packageInfo(package).path.."font")

	if not fontpath:exists() then
		return {}
	end

	local result = {}

	forEachFile(fontpath, function(file)
		if file:extension() == "ttf" then
			table.insert(result, file:name())
		end
	end)

	return result
end

function _Gtme.getVersion(str)
	local version = {}

	string.gsub(str, "(%d+)", function(v)
		table.insert(version, tonumber(v))
	end)

	return version
end

function _Gtme.downloadPackagesList()
	local version = sessionInfo().version
	local list = load(cpp_listpackages("http://www.terrame.org/packages/"..version.."/packages.lua"))

	if not list then return {} end

	local packages = list()
	return packages
end

function _Gtme.downloadPackage(pkg)
	local version = sessionInfo().version
	cpp_downloadpackage(pkg, "http://www.terrame.org/packages/"..version.."/")
end

-- from http://metalua.luaforge.net/src/lib/strict.lua.html
function _Gtme.checkNilVariables(mt)
	if mt == nil then
		mt = {}
		setmetatable(_G, mt)
	end

	mt.__declared = {}

	mt.__newindex = function(t, n, v)
		if not mt.__declared[n] then
			local w = debug.getinfo(2, "S").what
			if w ~= "main" and w ~= "C" then
				_Gtme.strictWarning("Assign to undeclared variable '"..n.."'. Please declare it as local.")
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

	return mt
end

-- builds a table with zero counts for each element of the table gotten as argument
function _Gtme.buildCountTable(package)
	local s = _Gtme.sessionInfo().separator
	local baseDir = _Gtme.packageInfo(package).path

	if not isDirectory(baseDir..s.."lua") then return {} end

	local load_file = baseDir.."load.lua"
	local load_sequence

	if _Gtme.File(load_file):exists() then
		-- the 'getLuaFile' below does not need to be inside a xpcall because
		-- the package was already loaded with success
		load_sequence = _Gtme.getLuaFile(load_file).files
	else
		load_sequence = {}
		_Gtme.forEachFile(baseDir.."lua", function(mfile)
			if mfile:extension() == "lua" then
				table.insert(load_sequence, mfile:name())
			end
		end)
	end

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	local currentFile
	local mt = getmetatable(_G)
	setmetatable(_G, {}) -- to avoid warnings: "Variable 'xxx' is not declared."

	local result = setmetatable({}, {__index = _G, __newindex = function(t, k, v)
		rawset(t, k, v)

		local mtype = _Gtme.type(v)
		if mtype == "function" or type(v) == "Model" then
			testfunctions[currentFile][k] = 0
		elseif mtype == "table" then
			_Gtme.forEachElement(v, function(midx, _, mmtype)
				if mmtype == "function" or mmtype == "Model" then
					testfunctions[currentFile][midx] = 0
				end
			end)
		end

	end})

	for _, file in ipairs(load_sequence) do
		testfunctions[file] = {}
		currentFile = file
		lf = loadfile(baseDir.."lua"..s..file, 't', result)

		if lf ~= nil then
			lf()
		end
	end

	setmetatable(_G, mt)
	return testfunctions
end

function _Gtme.projectFiles(package)
	local files = {}
	local data_path = _Gtme.packageInfo(package).data

	if not data_path:exists() then return files end

	forEachFile(data_path, function(file)
		if file:extension() == "lua" then
			table.insert(files, file)
		end
	end)

	return files
end

function _Gtme.findModels(package)
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

	if not packagepath:exists() then
		_Gtme.customError("Package '"..package.."' is not installed.")
	end

	_Gtme.forEachFile(packagepath.."lua", function(file)
		found = false
		local a
		a = _Gtme.getLuaFile(file)

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
	local examplespath

	xpcall(function() examplespath = _Gtme.packageInfo(package).path.."examples" end, function(err)
		_Gtme.printError(err)
		os.exit(1)
	end)

	if _Gtme.Directory(examplespath):attributes("mode") ~= "directory" then
		return {}
	end

	local result = {}

	_Gtme.forEachFile(examplespath, function(file)
		if file:extension() == "lua" then
			local split = {file:split()}
			table.insert(result, split[2])
		elseif file:extension() ~= "tme"then
			_Gtme.printWarning("Test file '"..file:name().."' does not have a valid extension.")
		end
	end)
	return result
end

function _Gtme.showDoc(package)
	local s = _Gtme.sessionInfo().separator

	local docpath

	xpcall(function() docpath = _Gtme.packageInfo(package).path end, function(err)
		_Gtme.printError(err)
		os.exit(1)
	end)

	docpath = docpath.."doc"..s.."index.html"

	local exists
	ok, err = pcall(function() exists = File(docpath):exists() end)

	if not ok or not exists then
		_Gtme.printError("It was not possible to find the documentation of package '"..package.."'.")
		_Gtme.printError("Please run 'terrame -package "..package.." -doc' to build it.")
		os.exit(1)
	end

	_Gtme.openWebpage(docpath)
end

function _Gtme.installRecursive(pkgfile)
	local sep = string.find(pkgfile, "_")

	if not sep then
		_Gtme.printError("Argument '"..pkgfile.."' is not a valid file.")
		os.exit(1)
	end

	local package = string.sub(pkgfile, 1, sep - 1)
	local installed = {}

	local packages = _Gtme.downloadPackagesList()
	_Gtme.printNote("Downloading package '"..package.."'")
	_Gtme.downloadPackage(pkgfile)

	os.execute("unzip -oq \""..pkgfile.."\"")

	local pinfo = packageInfo(package)
	local depends = 0

	if pinfo.tdepends then
		_Gtme.print("Verifying dependencies")
		forEachElement(pinfo.tdepends, function(_, dtable)
			if dtable.package == "terrame" or dtable.package == "base" then return end

			_Gtme.print("Package depends on "..dtable.package)
			depends = depends + 1
			local isInstalled = pcall(function() packageInfo(dtable.package) end)

			if not isInstalled then
				if not _Gtme.installRecursive(dtable.package.."_"..packages[dtable.package].version..".zip") then
					return false
				end

				installed[dtable.package] = true
				return true
			end
		end)
	end

	if depends == 0 then
		_Gtme.print("Package has no dependencies")
	end

	local status, err = pcall(function() _Gtme.installPackage(pkgfile) end)

	File(pkgfile):deleteIfExists()

	if isDirectory(package) then
		Directory(package):delete()
	end

	if not status then
		customError("File "..pkgfile.." could not be installed:\n"..err)
		return false
	end

	return true, installed
end

function _Gtme.uninstall(package)
	local si = _Gtme.sessionInfo()
	local s = si.separator

	local arg = si.path..s.."packages"..s..package
	_Gtme.printNote("Uninstalling package \'"..package.."\'")

	if package == "base" or package == "gis" then
		_Gtme.printError("Package '"..package.."' cannot be removed")
		os.exit(0)
	end

	if Directory(arg):exists() then
		Directory(arg):delete()
		if Directory(arg):exists() then
			_Gtme.printError("Package \'"..package.."\' could not be uninstalled (wrong permission)")
		else
			_Gtme.printNote("Package \'"..package.."\' was successfully uninstalled")
		end
	else
		_Gtme.printWarning("Package \'"..package.."\' is not installed.")
	end
end

function _Gtme.verifyDepends(package)
	local pinfo = packageInfo(package)
	local result = true

	if not pinfo.tdepends then return end

	forEachElement(pinfo.tdepends, function(_, dtable)
		local currentInfo = packageInfo(dtable.package)

		if not isLoaded(dtable.package) then
			import(dtable.package)
		end

		local dstrversion = table.concat(dtable.version, ".")

		if not _Gtme.verifyVersionDependency(currentInfo.version, dtable.operator, dstrversion) then
			_Gtme.customError("Package '"..package.."' requires '"..dtable.package.."' version '"..
				dstrversion.."', got '"..currentInfo.version.."'.")
		end
	end)

	return result
end

function _Gtme.verifyVersionDependency(newVersion, operator, oldVersion)
	local newVersionT = _Gtme.getVersion(newVersion)
	local oldVersionT = _Gtme.getVersion(oldVersion)

	if operator == "==" then
		return newVersion == oldVersion
	else
		local i = 1

		while i <= #newVersionT and i <= #oldVersionT and newVersionT[i] == oldVersionT[i] do
			i = i + 1
		end

		if i > #newVersionT or i > #oldVersionT then
			i = i - 1
		end

		if operator == ">=" then
			if i == #newVersionT and i == #oldVersionT then
				return newVersionT[i] >= oldVersionT[i]
			elseif newVersionT[i] ~= oldVersionT[i] then
				return newVersionT[i] >= oldVersionT[i]
			else
				return #newVersionT >= #oldVersionT
			end
		elseif operator == "<=" then
			if i == #newVersionT and i == #oldVersionT then
				return newVersionT[i] <= oldVersionT[i]
			elseif newVersionT[i] ~= oldVersionT[i] then
				return newVersionT[i] <= oldVersionT[i]
			else
				return #newVersionT <= #oldVersionT
			end
		else
			_Gtme.customError("Wrong operator: '"..operator.."'.")
		end
	end
end

function _Gtme.installPackage(file)
	if file == nil then
		_Gtme.printError("You need to choose the file to be installed.")
		return
	elseif not _Gtme.File(file):exists() then
		_Gtme.printError("No such file: '"..file.."'.")
		return
	end

	file = _Gtme.makePathCompatibleToAllOS(file)

	local _, pfile = string.match(file, "(.-)([^/]-([^%.]+))$") -- remove path from the file
	local package

	xpcall(function() package = string.sub(pfile, 1, string.find(pfile, "_") - 1) end, function()
		_Gtme.printError(file.." is not a valid file name for a TerraME package.")
		os.exit(1)
	end)

	local cDir = _Gtme.currentDir()
	local packageDir = Directory(_Gtme.sessionInfo().path.."packages")

	if not _Gtme.isLoaded("base") then
		_Gtme.import("base")
	end

	if Directory(packageDir..package):exists() then
		_Gtme.print("Removing previous version of package")
		Directory(packageDir..package):delete()
	end

	_Gtme.print("Installing package '"..package.."'")
	os.execute("unzip -oq \""..file.."\" -d "..packageDir)

	_Gtme.print("Verifying dependencies")
	_Gtme.verifyDepends(package)

	_Gtme.print("Trying to load package '"..package.."'")
	local status, err = pcall(function() import(package) end)

	if not status then
		Directory(packageDir..package):delete()
		_Gtme.customError(err)
	end

	cDir:setCurrentDir()

	_Gtme.loadedPackages[package] = nil
	_Gtme.printNote("Package '"..package.."' was successfully installed")
	return package
end

local function version()
	local tmeVersion, lua_release, qt_version, qwt_version = cpp_informations()

	local str = "Version: "..tmeVersion
	str = str.."\nLocation (TME_PATH): ".._Gtme.sessionInfo().path

	str = str.."\nCompiled with:"
	str = str.."\n  "..lua_release
	str = str.."\n  Qt "..qt_version
	str = str.."\n  Qwt "..qwt_version

	local gis = _Gtme.getPackage("gis")
	str = str.."\n  TerraLib "..gis.TerraLib().getVersion()
	finalizeTerraLib()

	return str
end

local function usage()
	print("\nUsage: TerraME [mode] [options] [file1.lua file2.lua ...]")
	print("\nMode:")
	print("-debug                   Warnings treated as errors.")
	print("-normal (default)        Warnings enabled.")
	print("-quiet                   Warnings disabled.")
	print("-strict                  Execute additional verifications in the source code.")
	print("\nOptions: ")
	print("-autoclose               Automatically close TerraME after simulation.")
	print("-color                   Show colored output. In Windows, it requires ansicon")
	print("                         (https://github.com/adoxa/ansicon/releases).")
--	print("-draw-all-higher <value> Draw all subjects when percentage of changes was higher")
--	print("                         than <value>. Value must be between interval [0, 1].")
	print("-ft                      Show the full traceback in case of errors (including")
	print("                         internal lines from TerraME and loaded packages).")
	print("-gui                     Show the player for the application (it works only")
	print("                         when an Environment or a Timer object is used.")
	print("-ide                     Configure TerraME for running from IDEs in Windows.")
	print("-install <pkg>           Install a package stored in TerraME's repository.")
	print("                         It can also be a local .zip file.")
	print("-package <pkg>           Select a given package. If not package is selected,")
	print("                         TerraME uses base package. -package can be combined")
	print("                         with the following options:")
	print("  -build [<f>] [-clean]  Test (-test [<f>]), document (-doc) and then build an")
	print("                         installer for the package. -clean option can be used to")
	print("                         remove test files and logs.")
	print("  -check                 Analyse Lua source code.")
	print("  -configure <m>         Visually configure and run Model <m>.")
	print("  -doc                   Build the documentation of the package.")
	print("  -example <exp>         Run example <exp>.")
	print("  -examples              Run all examples.")
	print("  -project <prj> [<res>] Create project <prj> in the current directory. When")
    print("                         using <res>, it replaces the resolution of the script.")
	print("  -projects              Create the TerraView projects for the package.")
	print("  -showdoc               Show the documentation in the default browser.")
	print("  -sketch                Create test scripts for source code files missing")
	print("                         tests and initial documentation for undocumented files.")
	print("  -test [<f>]            Execute unit tests for the package. An optional Lua")
	print("                         file <f> can describe a subset of the tests to be")
	print("                         executed.")
	print("  -uninstall             Remove an installed package.")
	print("-silent                  print() does not show any text on the screen.")
	print("-version                 Show TerraME general information.")
	print("-zb <dir>                Configures ZeroBrane to run TerraME. It uses the")
	print("                         default installation directory or <dir>.")
--	print("-workers <value>         Sets the number of threads used for spatial observers.")
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

function _Gtme.makePathCompatibleToAllOS(path)
	path = path:gsub("\\\\","/")
	path = path:gsub("\\", "/")

	return path
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

		local s = "/" -- si.separator
		local infoSource = _Gtme.makePathCompatibleToAllOS(info.source)
		local m1 = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."lua")))
		local m2 = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."packages"..s.."base"..s.."lua")))
		local m3 = string.match(info.short_src, "%[C%]")
		local m4 = string.sub(info.short_src, 1, 1) == "["

		local mpackage = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(s.."lua"..s)))

		if m1 or m2 or m3 or m4 or mpackage then
			level = level + 1
		else
			return level - 1 -- minus one because of getLevel()
		end
	end
end

local function graphicalInterface(package, modelName)
	local s = _Gtme.sessionInfo().separator
	_Gtme.sessionInfo().interface = true
	local data = _Gtme.getLuaFile(_Gtme.packageInfo(package).path..s.."lua"..s..modelName..".lua")
	local model

	forEachElement(data, function(_, value, mtype)
		if mtype == "Model" then
			model = value
		end
	end)

	_Gtme.configure(model, modelName, package)
end

function _Gtme.traceback(err)
	local level = 1

	local si = sessionInfo()

	if si.fullTraceback then
		return _Gtme.ft(err)
	end

	local s = "/" -- si.separator
	local str = "Stack traceback:"

	local last_function

	local info = debug.getinfo(level)
	while info ~= nil do
		local infoSource = _Gtme.makePathCompatibleToAllOS(info.source)
		local m1 = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."lua")))
		local m2 = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."packages")))
		local mb = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."packages"..s.."base")))
		local m3 = string.match(info.short_src, "%[C%]")
		local m4

		if si.package then
			m4 = string.match(infoSource, _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.package..s.."lua")))
		end

		local func = info.name
		local update = true

		if     func == "?"          then func = "main chunk"
		elseif func == "__add"      then func = "operator + (addition)"
		elseif func == "__sub"      then func = "operator - (subtraction)"
		elseif func == "__mul"      then func = "operator * (multiplication)"
		elseif func == "__div"      then func = "operator / (division)"
		elseif func == "__mod"      then func = "operator % (modulo)"
		elseif func == "__pow"      then func = "operator ^ (exponentiation)"
		elseif func == "__unm"      then func = "operator - (minus)"
		elseif func == "__concat"   then func = "operator .. (concatenation)"
		elseif func == "__len"      then func = "operator # (size)"
		elseif func == "__eq"       then func = "operator == (equal)"
		elseif func == "__lt"       then func = "comparison operator"
		elseif func == "__le"       then func = "comparison operator"
		elseif func == "__index"    then func = "operator [] (index)"
		elseif func == "__newindex" then func = "operator [] (index)"
		elseif func == "__call"     then func = "call"
		elseif func == "_sof_"      then
			func = "second order function"

			if last_function and string.match(last_function, "operator") then
				local lf = func
				func = func..", in "..last_function
				last_function = lf
				update = false
			end
		elseif func ~= nil then
			func = "function '"..func.."'"
			if last_function and string.match(last_function, "operator") then
				local lf = func
				func = func..", in "..last_function
				last_function = lf
				update = false
			end
		elseif not func then
			if last_function and string.sub(last_function, 1, 7) ~= "call to" and last_function ~= "main chunk" then
				func = "call to "..last_function
			else
				func = "main chunk"
			end
		end

		if update then
			last_function = func
		end

		if not m1 and not m3 then
			if (si.package and not mb) or (not (m2 or m4)) or (si.package == "base" and mb) then
				local short = _Gtme.makePathCompatibleToAllOS(info.short_src)
				local current = sessionInfo().currentFile
				local currentStr = tostring(current)
				local equals

				if string.sub(short, 1, 3) == "..." then
					local subShort = string.sub(short, 4)
					local cut = string.sub(currentStr, string.len(currentStr) - string.len(subShort) + 1)
					equals = cut == subShort
				else
					equals = currentStr == short
				end

				if equals then
					str = str.."\n    File '"..current:name().."'"
				else
					str = str.."\n    File '"..short.."'"
				end

				if info.currentline > 0 then
					str = str..", line "..info.currentline
				end
				str = str..", in "..func
			end
		end

		level = level + 1
		info = debug.getinfo(level)
	end

	clean()

	local line
	local file

	if err then
		local sub = string.sub(err, 2, 3)

		if sub == ":/" or sub == ":\\" then -- if string starts with a windows partition (such as C:/)
			sub = string.sub(err, 1, 2)
		else
			sub = ""
		end

		local pos = string.find(err, "Error:") -- TerraME error

		if pos then -- error in some package
			err = string.sub(err, pos)
		else -- lua errror in the user's script
			pos = string.find(err, ":") -- remove first ":"
			file = string.sub(err, 1, pos - 1)
			err = string.sub(err, pos + 1)
			pos = string.find(err, ":") -- remove second ":"

			if pos then

				line = string.sub(err, 1, pos - 1)

				if tostring(tonumber(line)) ~= line then
					pos = string.find(err, ":") -- remove first ":"
					file = string.sub(err, 1, pos - 1)
					err = string.sub(err, pos + 1)
					pos = string.find(err, ":") -- remove second ":"
					line = string.sub(err, 1, pos - 1)
				end

				if file and sub then -- if string starts with a windows partition (such as C:/)
					file = sub..file
				end

				err = "Error:"..string.sub(err, pos + 1)
			else
				err = "Error:"..err
			end
		end
	end

	if str == "Stack traceback:" then
		if file and line then
			str = err.."\n"..str
			str = str.."\n    File '"..file.."', line "..line
		else
			str = err
		end
	elseif str ~= "" then
		str = err.."\n"..str
	else
		str = err
	end

	return _Gtme.makePathCompatibleToAllOS(str)
end

function _Gtme.loadModules(pkg)
	pkg = Directory(pkg.."lib")

	if pkg:exists() then
		package.path = pkg.."/?.lua;"..package.path
		cpp_putenv(tostring(pkg))

		local system = sessionInfo().system

		if system == "windows" then
			package.cpath = pkg.."/?.dll;"..package.cpath
		elseif system == "linux" then
			package.cpath = pkg.."/?.so;"..package.cpath
		else -- system == "mac"
			package.cpath = pkg.."/?.dylib;"..package.cpath
		end
	end
end

local function findExample(example, packageName)
	local file = example
	local s = package.config:sub(1, 1)
	local errMsg = nil
	local exFullPath = ""

	if file then
		local info
		xpcall(function() info = packageInfo(packageName).path end, function(err)
			errMsg = err
		end)

		if errMsg then
			return false, errMsg
		end

		exFullPath = info..s.."examples"..s..file..".lua"

		if not File(exFullPath):exists() then
			errMsg = "Example '"..file.."' does not exist in package '"..packageName.."'."
			errMsg = errMsg.."\nPlease use one from the list below:"
		end
	elseif packageName == "base" then
		errMsg = "TerraME has the following examples:"
	elseif #_Gtme.findExamples(packageName) == 0 then
		errMsg = "Package '"..packageName.."' has no examples."
		return false, errMsg
	else
		errMsg = "Package '"..packageName.."' has the following examples:"
	end

	if file and File(exFullPath):exists() then
		-- it only changes the file to point to the package and let it run as it
		-- was a call such as "TerraME .../package/examples/example.lua"
		return true, exFullPath
	else
		files = _Gtme.findExamples(packageName)

		_Gtme.forEachElement(files, function(_, value)
			errMsg = errMsg.."\n - "..value
		end)
	end

	return false, errMsg
end

local function executeExamples(package)
	if not isLoaded("base") then
		import("base")
	end

	_Gtme.printNote("Running all examples of package '"..package.."'")

	local errors = 0

	local s = _Gtme.sessionInfo().separator
	local examplespath

	xpcall(function() examplespath = _Gtme.packageInfo(package).path..s.."examples" end, function(err)
		_Gtme.printError(err)
		os.exit(1)
	end)

	_Gtme.forEachFile(examplespath, function(file)
		if file:extension() == "lua" then
			print("Running example '"..file:name().."'")

			xpcall(function() dofile(tostring(file)) end, function(err)
				_Gtme.printError(err)
				errors = errors + 1
			end)

			clean()
		end
	end)

	return errors
end

function _Gtme.loadTmeFile(luafile)
	local displayFile = string.sub(luafile, 0, string.len(luafile) - 3).."tme"
	displayFile = _Gtme.makePathCompatibleToAllOS(displayFile)

	local cObj = TeVisualArrangement()

	cObj:setFile(displayFile)
	cpp_restartobservercounter()

	if _Gtme.File(displayFile):exists() then
		local display = dofile(displayFile)

		_Gtme.forEachElement(display, function(idx, data)
			cObj:addPosition(idx, data.x, data.y)
			cObj:addSize(idx, data.width, data.height)
		end)
	end
end

local function runScript(script)
	if info_.mode ~= "quiet" then
		local mt = getmetatable(_G)
		_Gtme.checkNilVariables(mt)
	end

	if not _Gtme.isLoaded("base") then
		_Gtme.import("base")
	end

	_Gtme.loadTmeFile(script)

	if isDirectory(script) then
		_Gtme.printError("Argument '"..script.."' is a directory, and not a Lua file.")
		os.exit(1)
	end

	script = File(script)

	if not script:exists() then
		_Gtme.printError("File '"..script.."' does not exist.")
		os.exit(1)
	elseif script:extension() ~= "lua" then
		_Gtme.printError("Argument '"..script.."' does not have '.lua' extension.")
		os.exit(1)
	end

	info_.currentFile = script

	dofile(sessionInfo().path.."lua"..sessionInfo().separator.."check.lua")

	if info_.mode == "strict" then
		_Gtme.checkFile(tostring(script), "Warning")
	elseif info_.mode == "debug" then
		local numIssues = _Gtme.checkFile(tostring(script), "Error")
		if numIssues > 0 then
			os.exit(numIssues)
		end
	end

	local success, result = _Gtme.myxpcall(function() dofile(tostring(script)) end)
	if not success then
		_Gtme.printError(result)
		os.exit(1)
	end
end

function _Gtme.execExample(example, packageName)
	local ok, res = findExample(example, packageName)

	if not ok then
		return false, res
	end

	example = res

	local mdialog
	local description
	local okButton

	local oldPrint = print
	print = function(value)
		if not mdialog then
			mdialog = qt.new_qobject(qt.meta.QDialog)
			local _, file = File(example):split()
			mdialog.windowTitle = "Output of example "..file

			local externalLayout = qt.new_qobject(qt.meta.QVBoxLayout)
			local internalLayout = qt.new_qobject(qt.meta.QHBoxLayout)
			description = qt.new_qobject(qt.meta.QLabel)
			description.text = ""

			okButton = qt.new_qobject(qt.meta.QPushButton)
			okButton.minimumSize = {150, 28}
			okButton.maximumSize = {160, 28}
			okButton.text = "Close"
			okButton.enabled = false

			qt.ui.layout_add(internalLayout, okButton)
			qt.ui.layout_add(externalLayout, description)
			qt.ui.layout_add(externalLayout, internalLayout)
			qt.ui.layout_add(mdialog, externalLayout)

			qt.connect(okButton, "clicked()", function()
				mdialog:done(0)
			end)

			mdialog:show()
		end

		_Gtme.print(value)
		description.text = description.text.."\n"..value
	end

	local success, result = pcall(function() runScript(example) end)
	if not success then
		print = oldPrint
		return false, result
	end

	if mdialog then
		okButton.enabled = true
		mdialog:exec()
	end

	print = oldPrint
	return success
end

function _Gtme.execConfigure(model, packageName)
	local errMsg = nil

	if packageName ~= "base" then
		import("base")
	end

	xpcall(function() import(packageName) end, function(err)
		return false, err
	end)

	local models

	xpcall(function() models = _Gtme.findModels(packageName) end, function(err)
		return false, err
	end)

	if #models == 0 then
		errMsg = "Package \""..packageName.."\" does not have any Model."
		return false, errMsg
	end

	if model == nil then
		errMsg = "You should indicate a Model to be used."
		errMsg = errMsg.."\nPlease use one from the list below:"

		_Gtme.forEachElement(models, function(_, value)
			errMsg = errMsg.."\n - "..value
		end)
		return false, errMsg
	elseif belong(model, models) then
		graphicalInterface(packageName, model)
		return true, _
	else
		errMsg = "Model '"..model.."' does not exist in package '"..packageName.."'."
		errMsg = errMsg.."\nPlease use one from the list below:"
		_Gtme.forEachElement(models, function(_, value)
			errMsg = errMsg.."\n - "..value
		end)
		return false, errMsg
	end
end

function _Gtme.execute(arguments) -- 'arguments' is a vector of strings
	local osName = cpp_getOsName()
	if osName == "windows" then
		local locale = cpp_getLocale()
		os.setlocale(locale, "collate")
		os.setlocale(locale, "ctype")
	end

	info_ = { -- this variable is used by Utils:sessionInfo()
		mode = "normal",
		dbVersion = "1_3_1",
		separator = package.config:sub(1, 1),
		silent = false,
		color = false,
		interface = false,
		graphics = true,
		path = os.getenv("TME_PATH"),
		fullTraceback = false,
		autoclose = false,
		time = os.clock(),
		system = osName,
		round = 1e-5
	}

	if info_.path == nil or info_.path == "" then
		error("Error: TME_PATH environment variable should exist and point to TerraME installation directory.", 2)
	end

	-- Package.lua contains functions that terrame.lua needs, but should also be
	-- documented and availeble for the final users.
	local s = info_.separator
	local path = info_.path..s.."packages"..s.."base"..s.."lua"..s
	dofile(path.."ErrorHandling.lua", _Gtme)
	dofile(path.."File.lua", _Gtme)
	dofile(path.."Directory.lua", _Gtme)
	dofile(path.."Package.lua", _Gtme)
	dofile(path.."OS.lua", _Gtme)
	dofile(path.."Utils.lua", _Gtme)
	dofile(info_.path..s.."lua"..s.."utils.lua")
	dofile(info_.path..s.."lua"..s.."configure.lua")
	dofile(path.."Profiler.lua", _Gtme)

	local infopath = _Gtme.Directory(info_.path)
	if tostring(infopath) == tostring(_Gtme.currentDir()) then
		_Gtme.printError("It is not possible to execute TerraME within its directory. Please, run it from another place.")
		os.exit(1)
	end

	info_.path       = _Gtme.Directory(info_.path)
	info_.initialDir = _Gtme.Directory(tostring(_Gtme.currentDir()))
	info_.version    = _Gtme.packageInfo().version

	if arguments == nil or #arguments < 1 or (#arguments == 1 and arguments[1] == "-ide") then
		if not _Gtme.Directory(info_.path.."/packages/base/doc"):exists() then
			_Gtme.printError("TerraME does not have documentation. Please run 'terrame -doc' first.")
			os.exit(1)
		end

		if arguments and arguments[1] == "-ide" then
			if not _Gtme.isLoaded("base") then
				_Gtme.import("base")
			end

			local __cellEmpty = Cell{attrib = 1}
			Chart{target = __cellEmpty}
			clean()
		end

		dofile(info_.path..s.."lua"..s.."pmanager.lua")
		dofile(info_.path..s.."lua"..s.."project.lua")
		_Gtme.packageManager()
		return true
	end

	local package = "base"

	local argCount = 1
	while argCount <= #arguments do
		arg = arguments[argCount]
		if string.sub(arg, 1, 1) == "-" then
			if arg == "-version" then
				checkUnnecessaryArguments(arguments, argCount)
				print("TerraME - Terra Modeling Environment")
				print(version())
				os.exit(0)
			elseif arg == "-ide" then
				if not _Gtme.isLoaded("base") then
					_Gtme.import("base")
				end

				local __cellEmpty = Cell{attrib = 1}
				Chart{target = __cellEmpty}
				clean()
			elseif arg == "-ft" then
				info_.fullTraceback = true
			elseif arg == "-color" then
				info_.color = true
			elseif arg == "-normal" then
				info_.mode = "normal"
			elseif arg == "-debug" then
				info_.mode = "debug"
			elseif arg == "-quiet" then
				info_.mode = "quiet"
			elseif arg == "-strict" then
				info_.mode = "strict"
			elseif arg == "-silent" then
				info_.silent = true
				print = function() end
			elseif arg == "-zb" then
				checkUnnecessaryArguments(arguments, argCount)
				dofile(info_.path..s.."lua"..s.."zerobrane.lua")
				_Gtme.configureZeroBrane()
				os.exit(0)
			elseif string.sub(arg, 1, 6) == "-mode=" then
				_Gtme.printError("Invalid mode '"..string.sub(arg, 7).."'.")
				os.exit(1)
			elseif arg == "-package" then
				argCount = argCount + 1
				package = arguments[argCount]

				if package == nil then
					_Gtme.printError("A package should be specified after -package.")
					os.exit(1)
				end

				package = Directory(package):name()

				info_.package = package
				if #arguments <= argCount then
					local models

					xpcall(function() models = _Gtme.findModels(package) end, function(err)
						_Gtme.printError(err)
						os.exit(1)
					end)

					if #models == 1 then
						xpcall(function() graphicalInterface(package, models[1]) end, function(err)
							_Gtme.printError(_Gtme.traceback(err))
						end)
						os.exit(1)
					end

					local description = _Gtme.packageInfo(package).path..s.."description.lua"

					if not File(description):exists() then
						_Gtme.printError("File '"..package..s.."description.lua' does not exist.")
						os.exit(1)
					end

					local data = _Gtme.getLuaFile(_Gtme.packageInfo(package).path..s.."description.lua")
					local date = data.date
					if not date then date = "(undefined date)" end

					print("Package '"..package.."'")
					print(data.title)
					print("Version "..data.version..", "..date)

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
					os.exit(0)
				end
			elseif arg == "-configure" then
				argCount = argCount + 1
				model = arguments[argCount]

				checkUnnecessaryArguments(arguments, argCount)

				if package ~= "base" then
					import("base")
				end

				xpcall(function() import(package) end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				local models

				xpcall(function() models = _Gtme.findModels(package) end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				if #models == 0 then
					_Gtme.printError("Package \""..package.."\" does not have any Model.")
					os.exit(0)
				end

				if model == nil then
					_Gtme.printError("You should indicate a Model to be used.")
					print("Please use one from the list below:")

					_Gtme.forEachElement(models, function(_, value)
						print(" - "..value)
					end)
					os.exit(0)
				elseif belong(model, models) then
					graphicalInterface(package, model)
				else
					_Gtme.printError("Model '"..model.."' does not exist in package '"..package.."'.")
					print("Please use one from the list below:")

					_Gtme.forEachElement(models, function(_, value)
						print(" - "..value)
					end)
					os.exit(0)
				end
			elseif arg == "-test" then
				if info_.package == nil then
					info_.package = "base"
				end

				info_.mode = "debug"

				local file
				if arguments[argCount + 1] then
					argCount = argCount + 1
					file = arguments[argCount]
				end

				checkUnnecessaryArguments(arguments, argCount)

				dofile(path.."UnitTest.lua")

				dofile(_Gtme.sessionInfo().path.."lua"..s.."test.lua")
				local errors = 0
				xpcall(function() errors = _Gtme.executeTests(package, file) end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				finalizeTerraLib()

				os.exit(errors)
			elseif arg == "-sketch" then
				info_.mode = "debug"
				checkUnnecessaryArguments(arguments, argCount)

				dofile(_Gtme.sessionInfo().path.."lua"..s.."test.lua")
				dofile(_Gtme.sessionInfo().path.."lua"..s.."doc.lua")
				dofile(_Gtme.sessionInfo().path.."lua"..s.."sketch.lua")
				xpcall(function() _Gtme.sketch(package) end, function(err)
					_Gtme.printError(_Gtme.traceback(err))
					os.exit(1)
				end)

				os.exit(0)
			elseif arg == "-help" then
				checkUnnecessaryArguments(arguments, argCount)
				usage()
				os.exit(0)
			elseif arg == "-showdoc" then
				checkUnnecessaryArguments(arguments, argCount)
				_Gtme.showDoc(package)
				os.exit(0)
			elseif arg == "-doc" then
				checkUnnecessaryArguments(arguments, argCount)

				info_.mode = "debug"
				dofile(_Gtme.sessionInfo().path.."lua"..s.."doc.lua")
				local errors = 0
				local success, result = _Gtme.myxpcall(function() errors = _Gtme.executeDoc(package) end)

				if not success then
					_Gtme.printError(result)
					os.exit(1)
				end

				os.exit(errors)
			elseif arg == "-examples" then
				checkUnnecessaryArguments(arguments, argCount)
				local errors
				_Gtme.myxpcall(function() errors = executeExamples(package) end)
				errors = errors or 0
				os.exit(errors)
			elseif arg == "-projects" then
				checkUnnecessaryArguments(arguments, argCount)
				dofile(_Gtme.sessionInfo().path.."lua"..s.."project.lua")
				local errors

				xpcall(function() packageInfo(package) end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				import("base")
				import("gis")

				_Gtme.myxpcall(function() errors = _Gtme.executeProjects(package) end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				os.exit(errors)
			elseif arg == "-autoclose" then
				info_.autoclose = true
			elseif arg == "-build" then
				if package == "base" then
					_Gtme.printError("TerraME cannot be built using -build.")
					os.exit(0)
				end

				import("gis")

				dofile(sessionInfo().path.."lua"..s.."build.lua")
				dofile(sessionInfo().path.."lua"..s.."project.lua")

				local config

				if arguments[argCount + 1] and arguments[argCount + 1] ~= "-clean" then
					argCount = argCount + 1
					config = arguments[argCount]
				end

				local clean

				if arguments[argCount + 1] == "-clean" then
					clean = true
					argCount = argCount + 1
				end

				checkUnnecessaryArguments(arguments, argCount)

				local errors = _Gtme.buildPackage(package, config, clean)
				os.exit(errors)
			elseif arg == "-install" then
				argCount = argCount + 1
				checkUnnecessaryArguments(arguments, argCount)

				if package ~= "base" then
					_Gtme.printError("It is not possible to use -package with -install. Run the following command instead:")
					_Gtme.printError("terrame -install "..package)
					os.exit(1)
				elseif not arguments[argCount] then
					_Gtme.printError("Please use one extra argument with the package name or file to be installed.")
					os.exit(1)
				end

				local file = File(arguments[argCount])

				if file:extension() == "zip" then
					xpcall(function() _Gtme.installPackage(arguments[argCount]) end, function(err)
						_Gtme.printError(err)
						os.exit(1)
					end)
				else
					local packages = _Gtme.downloadPackagesList()
					local pkg = arguments[argCount]

					if not packages[pkg] then
						_Gtme.printError("Package '"..pkg.."' does not exist in TerraME repository.")
						os.exit(1)
					end

					_Gtme.installRecursive(pkg.."_"..packages[pkg].version..".zip")
				end

				os.exit(0)
			elseif arg == "-uninstall" then
				checkUnnecessaryArguments(arguments, argCount)
				_Gtme.uninstall(package)
				os.exit(0)
			elseif arg == "-example" then
				info_.fullTraceback = true
				argCount = argCount + 1
				local file = arguments[argCount]
				checkUnnecessaryArguments(arguments, argCount)

				if file then
					local info
					xpcall(function() info = packageInfo(package).path end, function(err)
						_Gtme.printError(err)
						os.exit(1)
					end)

					arg = info..s.."examples"..s..file..".lua"

					if File(arg):exists() then
						runScript(arg)
					else
						_Gtme.printError("Example '"..file.."' does not exist in package '"..package.."'.")
						print("Please use one from the list below:")
						file = nil
					end
				elseif package == "base" then
					print("TerraME has the following examples:")
				elseif #_Gtme.findExamples(package) == 0 then
					_Gtme.printError("Package '"..package.."' has no examples.")
					os.exit(0)
				else
					print("Package '"..package.."' has the following examples:")
				end

				if not file then
					files = _Gtme.findExamples(package)

					_Gtme.forEachElement(files, function(_, value)
						print(" - "..value)
					end)
					os.exit(0)
				end
			elseif arg == "-project" then
				argCount = argCount + 1
				local project = arguments[argCount]

				argCount = argCount + 1
				local resolution = arguments[argCount]

				if resolution then
					if tostring(tonumber(resolution)) ~= resolution then
						_Gtme.printError("Resolution ("..resolution..") is not a number.")
						os.exit(0)
					end

					resolution = tonumber(resolution)
				end

				checkUnnecessaryArguments(arguments, argCount)

				local info
				xpcall(function() info = packageInfo(package).path end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				if project then
					arg = info..s.."data"..s..project..".lua"

					if not File(arg):exists() then
						_Gtme.printError("Project '"..project.."' does not exist in package '"..package.."'.")
						print("Please use one from the list below:")
					end
				elseif #_Gtme.projectFiles(package) == 0 then
					_Gtme.printError("Package '"..package.."' has no projects.")
					os.exit(1)
				else
					print("Package '"..package.."' has the following projects:")
				end

				if project and File(arg):exists() then
					dofile(_Gtme.sessionInfo().path.."lua"..s.."project.lua")
					import("gis")
					import("base")

					_Gtme.executeProject(package, project, resolution)

				else
					files = _Gtme.projectFiles(package)

					_Gtme.forEachElement(files, function(_, value)
						value = value:name()
						print(" - "..value:sub(0, string.len(value) - 4))
					end)

					os.exit(0)
				end
			elseif arg == "-check" then
				checkUnnecessaryArguments(arguments, argCount)
				dofile(sessionInfo().path.."lua"..s.."check.lua")

				if info_.package == nil then
					info_.package = "base"
				end

				local pkgPath
				xpcall(function() pkgPath = packageInfo(package).path end, function(err)
					_Gtme.printError(err)
					os.exit(1)
				end)

				local numIssues = _Gtme.checkPackage(package, pkgPath)

				os.exit(numIssues)
			else
				_Gtme.printError("Option not recognized: '"..arg.."'.")
				os.exit(1)
			end
		else
			checkUnnecessaryArguments(arguments, argCount)
			runScript(arg)
		end

		argCount = argCount + 1
	end

	if rawget(_Gtme, "tmpdirectory__") then
		forEachElement(_Gtme.tmpdirectory__, function(_, dir)
			if dir:exists() then dir:delete() end
		end)
	end

	finalizeTerraLib()

	return true
end

function _Gtme.myxpcall(func)
	return xpcall(func, function(err)
		local si = _Gtme.sessionInfo()
		local s = si.separator
		local luaDirectory = _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."lua"))
		local baseLuaDirectory = _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."packages"..s.."base"..s.."lua"))
		local luadocLuaDirectory = _Gtme.makePathCompatibleToAllOS(_Gtme.replaceSpecialChars(si.path.."packages"..s.."luadoc"))

		local m1 = string.match(err, string.sub(luaDirectory, string.len(luaDirectory) - 25, string.len(luaDirectory)))
		local m2 = string.match(err, string.sub(baseLuaDirectory, string.len(baseLuaDirectory) - 25, string.len(baseLuaDirectory)))
		local m3 = string.match(err, string.sub(luadocLuaDirectory, string.len(luadocLuaDirectory) - 25, string.len(luadocLuaDirectory)))
		local m4 = string.match(err, "%[C%]")
		local m5 = string.match(err, "attempt to index a nil value %(local 'self'%)")

		if m5 then
			-- whenever this error uccurs, it is because terrame is trying to use the argument
			-- self of a function of a type, but it is nil. TerraME never checks if this
			-- argument exists, and therefore this kind of error must be captured here.
			err = string.sub(err, 1, -44)
			err = err.."Trying to index a nil value. Did you forget to use ':' instead of '.'?"
			return _Gtme.traceback(err)
		elseif m1 or m2 or m3 or m4 then
			local str =
				"*************************************************************\n"..
				"UNEXPECTED TERRAME INTERNAL ERROR. PLEASE GIVE US A FEEDBACK.\n"..
				"REPORT THE ERROR AT github.com/TerraME/terrame/issues/new\n"..
				"PLEASE ADD THE INFORMATION BELOW AND SEND US ANY SCRIPTS AND\n"..
				"DATA THAT COULD HELP US TO REPRODUCE THE ERROR.\n"..
				"*************************************************************\n"

			if _Gtme.sessionInfo().fullTraceback then
				str = ""
			end

			str = str.._Gtme.ft(err)

			if not _Gtme.sessionInfo().fullTraceback then
				str = str.."\n\nTerraME installation:\n"..version()
			end

			return str
		else
			return _Gtme.traceback(err)
		end
	end)
end

function _Gtme.ft(err)
	local level = 1
	local str = err.."\nStack traceback:"
	local info = debug.getinfo(level)

	clean()

	while info ~= nil do
		if info.short_src == "[C]" then
			str = str.."\n    Internal C file"
		else
			str = str.."\n    File '"..info.short_src.."'"
		end

		if info.currentline > 0 then
			str = str..", line "..info.currentline
		end

		if info.name then
			str = str..", in function "..info.name
		else
			str = str..", in main chunk"
		end

		level = level + 1
		info = debug.getinfo(level)
	end

	return _Gtme.makePathCompatibleToAllOS(str)
end

function _Gtme.tostring(self)
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
		for _ = 0, size do
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
			if _Gtme.getn(value) == #value then
				result = result.."vector of size ".._Gtme.getn(value)..""
			else
				result = result.."named table of size ".._Gtme.getn(value)..""
			end
		else
			result = result..mtype
		end

		result = result.."\n"
	end)

	return result
end
