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

-- lincense to be removed
local licenseTextLines = 23 -- last line of license text
local licenseTextPart = "This code is part of the TerraME framework" -- some part of license text

--local qtYes = 2 ^ 14
--local qtNo = 2 ^ 16

local ide
local zbpreferencespath
local path
local home

if info_.system == "mac" then
	ide = Directory(info_.path.."../ide/zerobrane")
	home = os.getenv("HOME")
	path = home
	zbpreferencespath = os.getenv("HOME").."/Library/Preferences/ZeroBraneStudio Preferences"
elseif info_.system == "windows" then
	ide = Directory(info_.path.."/ide/zerobrane")
	home = os.getenv("HOMEDRIVE").."/"..os.getenv("HOMEPATH")
	path = os.getenv("appdata")
	zbpreferencespath = os.getenv("appdata").."/ZeroBraneStudio.ini"
else
	ide = Directory(info_.path.."/ide/zerobrane")
	home = os.getenv("HOME")
	path = home
	zbpreferencespath = os.getenv("HOME").."/.ZeroBraneStudio"
end

local function setZeroBranePreferences()
	_Gtme.printNote("Updating ZeroBrane preferences")

	local file = File(ide.."/ZBPreferences")

	if file:exists() then
		_Gtme.print("Overwriting ZeroBrane configuration file")
		-- TODO: ask to overwrite here
	end

	local line = file:readLine()
	local output = {}

	while line do
		local value = string.gsub(line, "PATH", path.."/terrame-examples")
		if info_.system == "windows" then
			value = string.gsub(value, "\\", "\\\\")
		end
		table.insert(output, value)
		line = file:readLine()
	end

	file:close()
	file = File(zbpreferencespath)

	file:writeLine(table.concat(output, "\n"))
	file:close()
end

local function setupPackageFile(fileName, previousFile, nextFile)
	local file = File(fileName)
	local line = file:readLine()
	local fileBegin = line
	local output = {}
	table.insert(output, string.format("--[[ [previous](%s) | [contents](00-contents.lua) | [next](%s) ]]\n", previousFile, nextFile))
	foundLicense = false
	for _ = 1, licenseTextLines do
		if not line then
			break
		end

		if string.find(line, licenseTextPart) then
			foundLicense = true
		end

		line = file:readLine()
	end

	if foundLicense then
		line = file:readLine() -- after license
	else
		line = fileBegin -- back to begin to read all file
	end

	while line do
		table.insert(output, line)
		line = file:readLine()
	end

	file:close()
	file = File(fileName)
	local contents = table.concat(output, "\n")
	file:writeLine(contents)
	file:close()
end

local function createPackageIndex(packageName, packageExamplesPath, luaFiles, title)
	local file = File(packageExamplesPath.."/00-contents.lua")
	file:writeLine("--[[ [previous](00-contents.lua) | [back to index](../welcome.lua) | [next]("..luaFiles[1].indexed..")")
	file:writeLine("\n# ".._Gtme.stringToLabel(title).." of ".._Gtme.stringToLabel(packageName).."\n")
	for i = 1, #luaFiles do
		file:writeLine(string.format("(%02d) [%s](%s)", i, string.gsub(luaFiles[i].fileName, ".lua", ""), luaFiles[i].indexed))
	end

	file:writeLine("]]")
	file:close()
end

local function copyPackage(packageName, examplesPath, subfolders)
	forEachElement(subfolders, function(_, subfolder)
		local packagePath = Directory(packageInfo(packageName).path.."/"..subfolder)
		local folder = subfolder
		if folder == "data" then
			folder = "projects"
		end

		local outputDir = Directory(examplesPath.."/"..packageName.."-"..folder)
		if not outputDir:exists() then
			outputDir:create()
		end

		os.execute("cp -r "..packagePath.."/*.{tme,lua} "..outputDir)
		local files = outputDir:list()
		local luaFiles = {}
		if #files > 0 then
			table.sort(files, function(f1, f2)
				return f1 < f2
			end)

			local index = 0
			forEachElement(files, function(_, fileName)
				if not File(packagePath..fileName):exists() then
					return
				end

				if string.endswith(fileName, ".lua") then
					index = index+1
				end

				local newFileName = string.format("%02d-%s", index, fileName)
				os.execute("mv "..outputDir.."/"..fileName.." "..outputDir.."/"..newFileName)
				if string.endswith(newFileName, ".lua") then
					table.insert(luaFiles, {indexed = newFileName, fileName = fileName})
				end
			end)
		else -- delete folder if its empty
			outputDir:delete()
			return
		end

		table.sort(luaFiles, function(f1, f2)
			return f1.indexed < f2.indexed
		end)

		luaFiles[0] = {indexed = "00-contents.lua"}
		for i = 1, #luaFiles do
			local fileName = luaFiles[i].indexed
			local prevFile = luaFiles[(i - 1)].indexed
			local nextFile = luaFiles[(i + 1) % (#luaFiles+1)].indexed
			setupPackageFile(outputDir.."/"..fileName, prevFile, nextFile)
		end

		createPackageIndex(packageName, outputDir, luaFiles, subfolder)
	end)
end

local function copyExamplesTutorials()
	examples = Directory(path.."/terrame-examples")

	if examples:exists() then
		msg = "Directory '"..examples.."' already exists. Do you want to replace it or choose a new directory?"
		-- TODO: give the option here
	else
		msg = "Files will be copied to directory '"..examples.."'. Do you want to select another directory to store them?"
		-- TODO: give the option here
	end

	os.execute("cp -r "..ide.."terrame-examples "..path)
	copyPackage("base", examples, {"examples"})
	copyPackage("gis", examples, {"examples", "data"})
end

local function updateConfigurationDirectory()
	local zbpath = Directory(home.."/.zbstudio")

	if zbpath:exists() then
		_Gtme.printNote("Directory '"..zbpath.."' already exists")
	else
		_Gtme.printNote("Creating directory '"..zbpath.."'")
		zbpath:create()
	end

	local ok, err = pcall(function()
		_Gtme.printNote("Copying user.lua")
		File(ide.."user.lua"):copy(zbpath)

		local packages = Directory(zbpath.."packages")

		if packages:exists() then
			_Gtme.printNote("Directory '"..packages.."' already exists")
		else
			_Gtme.printNote("Creating directory '"..packages.."'")
			packages:create()
		end

		_Gtme.printNote("Copying packages")
		forEachFile(ide.."packages", function(file)
			-- TODO: ask if plugins could be replaced when they exist
			file:copy(packages)
		end)
	end)

	return ok, err
end

_Gtme.configureZeroBrane = function()
	_Gtme.loadLibraryPath()

	require("qtluae")

	-- TODO: say that some files will be copied, and it is necessary to close zerobrane before
	-- executing it, otherwise zerobrane will overwrite such files

	copyExamplesTutorials()
	local ok, err = updateConfigurationDirectory()
	setZeroBranePreferences()

	if ok then
		msg = "ZeroBrane was successfully configured."
		qt.dialog.msg_information(msg)
	else
		msg = "ZeroBrane was not properly configured. The following error was found: "..err
		qt.dialog.msg_critical(msg)
	end
end

