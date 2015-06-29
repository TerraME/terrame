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

--@header Functions to work with packages in TerraME.

local function verifyDepends(package)
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
			import(dtable.package) -- SKIP
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

--- Return the path to a file of a given package. The file must be inside the folder data
-- within the package.
-- @arg filename A string with the name of the file.
-- @arg package A string with the name of the package. As default, it uses paciage base.
-- @usage file("cs.csv") 
--
-- cs = CellularSpace{database = file("simple.map")}
function file(filename, package)
	if package == nil then package = "base" end

	local s = sessionInfo().separator
	local file = packageInfo(package).data..s..filename
	if not isFile(file) then
		customError("File '"..file.."' does not exist in package '"..package.."'.")
	end
	return file
end

--- Load a given package. If the package is not installed, it tries to load from
-- a folder in the current directory.
-- @arg package A package name.
-- @usage import("calibration")
function import(package)
	mandatoryArgument(1, "string", package)

	if belong(package, {"terrame", "TerraME"}) then
		return
	end

	if isLoaded(package) then
		customWarning("Package '"..package.."' is already loaded.")
	else
		local s = sessionInfo().separator
		local package_path = packageInfo(package).path

		verifyDepends(package)

		local load_file = package_path..s.."load.lua"
		local all_files = dir(package_path..s.."lua")
		local load_sequence

		if isFile(load_file) then -- SKIP
			xpcall(function() load_sequence = _Gtme.include(load_file) end, function(err)
				_Gtme.printError("Package '"..package.."' could not be loaded.")
				_Gtme.print(err)
			end)

			verifyUnnecessaryArguments(load_sequence, {"files"})

			load_sequence = load_sequence.files -- SKIP
			if load_sequence == nil then -- SKIP
				_Gtme.printError("Package '"..package.."' could not be loaded.")
				_Gtme.printError("load.lua should declare table 'files', with the order of the files to be loaded.")
				os.exit() -- SKIP
			elseif type(load_sequence) ~= "table" then
				_Gtme.printError("Package '"..package.."' could not be loaded.")
				_Gtme.printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
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
					_Gtme.printError("Cannot open "..mfile..". No such file.")
					_Gtme.printError("Please check "..package_path..s.."load.lua")
					os.exit() -- SKIP
				end
				xpcall(function() dofile(mfile) end, function(err)
					_Gtme.printError("Package '"..package.."' could not be loaded.")
					_Gtme.printError(err)
					os.exit() -- SKIP
				end)
				count_files[file] = count_files[file] + 1 -- SKIP
			end
		end

		for mfile, count in pairs(count_files) do
			local attr = attributes(package_path..s.."lua"..s..mfile, "mode")
			if count == 0 and attr ~= "directory" then -- SKIP
				_Gtme.printWarning("File lua"..s..mfile.." is ignored by load.lua.")
			elseif count > 1 then
				_Gtme.printWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.")
			end
		end

		table.insert(_Gtme.loadedPackages, package) -- SKIP
	end
end

--- Return whether a given package is loaded.
-- @arg package A string with the name of the package.
-- @usage isLoaded("base")
function isLoaded(package)
	mandatoryArgument(1, "string", package)
	return belong(package, _Gtme.loadedPackages)
end

--- Return a table with the content of a given package. If the package is not
-- installed, it tries to load from a folder in the current directory.
-- @arg pname A package name.
-- @usage base = package("base")
-- cs = base.CellularSpace{xdim = 10}
function package(pname)
	mandatoryArgument(1, "string", pname)

	if belong(pname, {"terrame", "TerraME"}) then
		return
	end

	local s = sessionInfo().separator
	local pname_path = packageInfo(pname).path

	verifyDepends(pname)

	local load_file = pname_path..s.."load.lua"
	local all_files = dir(pname_path..s.."lua")
	local load_sequence

	if isFile(load_file) then -- SKIP
		xpcall(function() load_sequence = _Gtme.include(load_file) end, function(err)
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.print(err)
		end)

		verifyUnnecessaryArguments(load_sequence, {"files"})

		load_sequence = load_sequence.files -- SKIP
		if load_sequence == nil then -- SKIP
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.printError("load.lua should declare table 'files', with the order of the files to be loaded.")
			os.exit() -- SKIP
		elseif type(load_sequence) ~= "table" then
			_Gtme.printError("Package '"..pname.."' could not be loaded.")
			_Gtme.printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
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
			if not isFile(mfile) then -- SKIP
				_Gtme.printError("Cannot open "..mfile..". No such file.")
				_Gtme.printError("Please check "..pname_path.."load.lua")
				os.exit() -- SKIP
			end

			local lf = loadfile(mfile, 't', result)

 			if lf == nil then
				collectgarbage() -- SKIP
				lf = loadfile(mfile, 't', result) -- SKIP

				if lf == nil then -- SKIP
					_Gtme.printError("Could not load file "..scriptfile..".")
					dofile(scriptfile) -- this line will show the error when parsing the file
				end
			end

			lf()

			count_files[file] = count_files[file] + 1 -- SKIP
		end
	end

	for mfile, count in pairs(count_files) do
		local attr = attributes(pname_path.."lua"..s..mfile, "mode")
		if count == 0 and attr ~= "directory" then -- SKIP
			_Gtme.printWarning("File lua"..s..mfile.." is ignored by load.lua.")
		elseif count > 1 then
			_Gtme.printWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.")
		end
	end

	setmetatable(_G, mt)
	return result, overwritten
end

--- Return the description of a package. This function tries to find the package in the TerraME
-- installation folder. If it does not exist then it checks wether the package is available in the
-- current directory. If the package does not exist then it stops with an error. Otherwise, it reads
-- file description.lua and returns the following attributes.
-- @tabular arg
-- Attribute & Description \
-- authors & Name of the author(s) of the package.\
-- contact & E-mail of one or more authors. \
-- content & A description of the package. \
-- data & The path to folder data of the package. This attribute is added
-- by this function as it does not exist in description.lua.\
-- date & Date of the current version.\
-- depends & A comma-separated list of package names which this package depends on.\
-- license & Name of the package's license. \
-- package & Name of the package.\
-- path & Folder where the package is stored in the computer.\
-- title & Optional title for the HTML documentation of the package.\
-- url & An optional variable with a webpage of the package.\
-- version & Current version of the package, in the form <number>[.<number>]*.
-- For example: 1, 0.2, 2.5.2.
-- @arg package A string with the name of the package. If nil, packageInfo will return
-- the description of TerraME.
-- @usage packageInfo().version
function packageInfo(package)
	if package == nil or belong(package, {"terrame", "TerraME"}) then
		package = "base"
	end

	mandatoryArgument(1, "string", package)

	local s = sessionInfo().separator
	local pkgfile = sessionInfo().path..s.."packages"..s..package
	if not isFile(pkgfile) then
		if isFile(package) then
			pkgfile = package -- SKIP
		else
			customError("Package '"..package.."' is not installed.")
		end
	end
	
	local file = pkgfile..s.."description.lua"
	
	local result 
	xpcall(function() result = _Gtme.include(file) end, function(err)
		_Gtme.printError(err)
		os.exit() -- SKIP
	end)

	if result == nil then
		customError("Could not read description.lua") -- SKIP
	end

	result.path = pkgfile
	result.data = pkgfile..s.."data"

	if result.depends then
		local s = string.gsub(result.depends, "([%w]+ %(%g%g %d[.%d]+%))", function(v)
			return ""
		end)

		if s ~= "" then -- SKIP
			s = string.gsub(s, "%, ", function(v)
				return ""
			end)
		end

		if s ~= "" then -- SKIP
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
		s = string.gsub(result.depends, "([%w]+) %((%g%g) (%d[.%d]+)%)", function(value, v2, v3)
			mversion = {}
			getVersion(v3) -- SKIP
			table.insert(mdepends, {package = value, operator = v2, version = mversion})
		end)

		result.tdepends = mdepends
	end

	return result
end

