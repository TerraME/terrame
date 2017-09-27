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

--@header Functions to work with packages in TerraME.

--- Return a File storing the full path of a file within a given package.
-- The file must be inside the directory data of package.
-- @arg filename A string with the name of the file.
-- @arg package A string with the name of the package. As default, it uses base package.
-- @usage cs = CellularSpace{file = filePath("simple.pgm")}
function filePath(filename, package)
	if package == nil then package = "base" end

	filename = _Gtme.makePathCompatibleToAllOS(filename)

	local data = packageInfo(package).data
	local file = File(data..filename)

	if file:exists() then
		return file
	else
		local msg = "File 'data/"..filename.."' does not exist in package '"..package.."'."

		if file:extension() ~= "" then
			local _, name = file:split()
			local luafile = File(packageInfo(package).data..name..".lua")

			if luafile:exists() then
				msg = msg.." Please run 'terrame -package "..package.." -project "..name.."' to create it."
				customError(msg)
			end
		end

		local dir = file:path()
		local suggest = suggestion(filename, Directory(dir):list())
		local suggestMsg = suggestionMsg(suggest)

		msg = msg..suggestMsg

		customError(msg)
	end
end

--- Return a table with the files of a package that have a given extension.
-- @arg package A string with the name of the package.
-- @arg extension A string with the extension.
-- @usage filesByExtension("base", "csv")
function filesByExtension(package, extension)
	mandatoryArgument(1, "string", package)
	mandatoryArgument(2, "string", extension)

	local result = {}

	forEachFile(packageInfo(package).data, function(file)
		if file:extension() == extension then
			table.insert(result, file)
		end
	end)

	return result
end

--- Load a given package. If the package is not installed, it verifies if the
-- package is available in the current directory. It shows a warning if
-- trying to load a package that was already loaded. In this case, the package
-- will not be loaded again. See #2 below for a different procedure.
-- @arg package A package name.
-- @arg reload A boolean value indicating whether TerraME should load the package
-- even if it was already loaded (default is false). In this case, it
-- also avoids a warning indicating that the package was already loaded.
-- @usage -- DONTRUN
-- import("calibration")
function import(package, reload)
	mandatoryArgument(1, "string", package)
	optionalArgument(2, "boolean", reload)

	if reload == nil then reload = false end

	if isLoaded(package) and not reload then
		strictWarning("Package '"..package.."' is already loaded.")
	else
		local s = sessionInfo().separator
		local package_path = packageInfo(package).path
		if not isDirectory(package_path..s.."lua") then return true end

		_Gtme.verifyDepends(package)
		_Gtme.loadModules(package_path)

		local load_file = package_path..s.."load.lua"
		local all_files = Directory(package_path..s.."lua"):list()
		local load_sequence

		if File(load_file):exists() then -- SKIP
			xpcall(function() load_sequence = getLuaFile(load_file) end, function(err)
				_Gtme.customError("Package '"..package.."' could not be loaded:"..err) -- SKIP
			end)

			verifyUnnecessaryArguments(load_sequence, {"files"})

			load_sequence = load_sequence.files -- SKIP
			if load_sequence == nil then -- SKIP
				_Gtme.printError("Package '"..package.."' could not be loaded.")
				_Gtme.printError("load.lua should declare table 'files', with the order of the files to be loaded.")
				os.exit(1) -- SKIP
			elseif type(load_sequence) ~= "table" then
				_Gtme.printError("Package '"..package.."' could not be loaded.")
				_Gtme.printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
				os.exit(1) -- SKIP
			end
		else
			load_sequence = all_files -- SKIP
		end

		local count_files = {}
		for _, file in ipairs(all_files) do
			count_files[file] = 0 -- SKIP
		end

		if load_sequence then -- SKIP
			forEachOrderedElement(load_sequence, function(_, file)
				if string.endswith(file, ".tme") then return end

				local mfile = package_path..s.."lua"..s..file
				if not File(mfile):exists() then -- SKIP
					customWarning("Cannot open "..mfile..". No such file. Please check "..package_path..s.."load.lua.") -- SKIP
				else
					local merror
					local mode = sessionInfo().mode

					sessionInfo().mode = "quiet"
					xpcall(function() dofile(mfile) end, function(err)
						merror = "Package '"..package.."' could not be loaded: "..err -- SKIP
					end)

					sessionInfo().mode = mode

					if merror then -- SKIP
						_Gtme.customError(merror) -- SKIP
					end

					count_files[file] = count_files[file] + 1 -- SKIP
				end
			end)
		end

		for mfile, count in pairs(count_files) do
			if count == 0 and isFile(package_path.."lua"..s..mfile) then -- SKIP
				if not string.endswith(mfile, ".tme") then -- SKIP
					customWarning("File lua"..s..mfile.." is ignored by load.lua.") -- SKIP
				end
			elseif count > 1 then
				customWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.") -- SKIP
			end
		end

		local files = _Gtme.fontFiles(package)
		forEachElement(files, function(_, file)
			if not _Gtme.loadedFonts[file] then -- SKIP
				cpp_loadfont(package_path..s.."font"..s..file) -- SKIP
				_Gtme.loadedFonts[file] = true -- SKIP
			end
		end)

		if package == "base" then -- SKIP
			cpp_setdefaultfont() -- SKIP
		end

		rawset(_G, "font", function(data)
			_Gtme.fonts[data.name] = data.symbol -- SKIP
		end)

		if File(package_path..s.."font.lua"):exists() then -- SKIP
			dofile(package_path..s.."font.lua")
		end

		font = nil -- SKIP

		_Gtme.loadedPackages[package] = true -- SKIP
	end
end

--- Return whether a given package is loaded.
-- @arg package A string with the name of the package.
-- @usage if isLoaded("base") then
--     print("is loaded")
-- end
function isLoaded(package)
	mandatoryArgument(1, "string", package)
	return _Gtme.loadedPackages[package] == true
end

--- Return a table with the content of a given package. If the package is not
-- installed, it verifies if the package is in the current directory.
-- @arg pname A package name.
-- @usage base = getPackage("base")
-- cs = base.CellularSpace{xdim = 10}
function getPackage(pname)
	mandatoryArgument(1, "string", pname)

	local s = sessionInfo().separator
	local pname_path = packageInfo(pname).path
	if not isDirectory(pname_path..s.."lua") then return {} end

	_Gtme.verifyDepends(pname)
	_Gtme.loadModules(pname_path)

	local load_file = pname_path..s.."load.lua"
	local all_files = Directory(pname_path..s.."lua"):list()
	local load_sequence

	if File(load_file):exists() then -- SKIP
		xpcall(function() load_sequence = getLuaFile(load_file) end, function(err)
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.print(err)
		end)

		verifyUnnecessaryArguments(load_sequence, {"files"})

		load_sequence = load_sequence.files -- SKIP
		if load_sequence == nil then -- SKIP
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.printError("load.lua should declare table 'files', with the order of the files to be loaded.")
			os.exit(1) -- SKIP
		elseif type(load_sequence) ~= "table" then
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
			os.exit(1) -- SKIP
		end
	else
		load_sequence = all_files -- SKIP
	end

	local count_files = {}
	for _, file in ipairs(all_files) do
		count_files[file] = 0 -- SKIP
	end

	local overwritten = {}

	local mt = getmetatable(_G)
	setmetatable(_G, {}) -- to avoid warnings: "Variable 'xxx' is not declared."

	local result = setmetatable({}, {__index = _G, __newindex = function(t, k, v)
		if _G[k] then
			overwritten[k] = true
		end
		rawset(t, k, v)
	end})

	if load_sequence then -- SKIP
		for _, file in ipairs(load_sequence) do
			local mfile = pname_path..s.."lua"..s..file
			if not File(mfile):exists() then -- SKIP
				_Gtme.printError("Cannot open "..mfile..". No such file.")
				_Gtme.printError("Please check "..pname_path..s.."load.lua")
				os.exit(1) -- SKIP
			end

			local lf = loadfile(mfile, 't', result)

			if lf == nil then
				collectgarbage() -- SKIP
				lf = loadfile(mfile, 't', result) -- SKIP

				if lf == nil then -- SKIP
					_Gtme.printError("Could not load file "..mfile..".")
					dofile(mfile) -- this line will show the error when parsing the file
				end
			end

			lf()

			count_files[file] = count_files[file] + 1 -- SKIP
		end
	end

	for mfile, count in pairs(count_files) do
		local file_name = pname_path.."lua"..s..mfile
		if count == 0 and isFile(file_name) and not string.endswith(file_name, ".tme") then -- SKIP
			_Gtme.printWarning("File lua"..s..mfile.." is ignored by load.lua.")
		elseif count > 1 then
			_Gtme.printWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.")
		end
	end

	setmetatable(_G, mt)
	return result, overwritten
end

--- Return the description of a package. This function tries to find the package in the TerraME
-- installation directory. If it does not exist then it checks wether the package is available in
-- the current directory. If the package does not exist then it stops with an error. Otherwise,
-- it reads file description.lua and returns the following string attributes.
-- @tabular NONE
-- Attribute & Description \
-- authors & Name of the author(s) of the package.\
-- contact & E-mail of one or more authors. \
-- content & A description of the package. \
-- data & A Directory with the path to the data directory of the package. This attribute is added
-- by this function as it does not exist in description.lua.\
-- date & Date of the current version.\
-- depends & A string containing a comma-separated list of package names which this package depends on.\
-- tdepends & A table describing the dependencies of the package using internal tables containing three
-- values: operator (a string), package (a string), and version (a vector of numbers). \
-- license & Name of the package's license. \
-- package & Name of the package.\
-- path & A Directory with the path where the package is stored in the computer.\
-- title & Optional title for the HTML documentation of the package.\
-- url & An optional value with the webpage of the package.\
-- version & Current version of the package, in the form <number>[.<number>]*.
-- For example: 1, 0.2, 2.5.2.
-- @arg package A string with the name of the package. If nil, packageInfo will return
-- the description of TerraME.
-- @usage str = packageInfo().version
-- print(str)
function packageInfo(package)
	if package == nil or package == "terrame" then
		package = "base"
	end

	mandatoryArgument(1, "string", package)

	local s = sessionInfo().separator
	local pkgdirectory = Directory(sessionInfo().path.."packages"..s..package)

	if not pkgdirectory:exists() then
		pkgdirectory = Directory(sessionInfo().initialDir..package)
		if not pkgdirectory:exists() then
			customError("Package '"..package.."' is not installed.")
		end
	end

	local file = File(pkgdirectory.."description.lua")

	if not file:exists() then -- SKIP
		customError("Could not load package '"..package.."'. File 'description.lua' does not exist.") -- SKIP
	end

	local result
	xpcall(function() result = getLuaFile(file) end, function(err)
		_Gtme.printError("Could not load package '"..package.."': "..err)
		os.exit(1) -- SKIP
	end)

	if result == nil then
		customError("Could not load package '"..package.."'. File 'description.lua' is empty.") -- SKIP
	end

	result.path = pkgdirectory
	result.data = Directory(pkgdirectory.."data")

	if result.depends then
		local ss = string.gsub(result.depends, "([%w]+ %(%g%g %d[.%d]+%))", function()
			return ""
		end)

		if ss ~= "" then -- SKIP
			ss = string.gsub(ss, "%, ", function()
				return ""
			end)
		end

		if ss ~= "" then -- SKIP
			customError("Wrong description of 'depends' in description.lua of package '"..package.."'. Unrecognized '"..ss.."'.")
		end

		local mdepends = {}
		string.gsub(result.depends, "([%w]+) %((%g%g) (%d[.%d]+)%)", function(value, v2, v3)
			local mversion = _Gtme.getVersion(v3) -- SKIP
			table.insert(mdepends, {package = value, operator = v2, version = mversion})
		end)

		result.tdepends = mdepends
	end

	return result
end

