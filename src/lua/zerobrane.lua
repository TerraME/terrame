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

local qtYes = 2 ^ 14
local qtNo = 2 ^ 16

local ide
local zbpreferencespath
local path

if info_.system == "mac" then
	ide = Directory(info_.path.."../ide/zerobrane")
	path = os.getenv("HOME")
	zbpreferencespath = os.getenv("HOME").."/Library/Preferences/ZeroBraneStudio Preferences"
elseif info_.system == "windows" then
	ide = Directory(info_.path.."/ide/zerobrane")
	path = os.getenv("appdata")
	zbpreferencespath = os.getenv("appdata").."/ZeroBraneStudio.ini"
else
	ide = Directory(info_.path.."/ide/zerobrane")
	path = os.getenv("HOME")
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
	local home = os.getenv("HOME")

	while line do
		local value = string.gsub(line, "PATH", home.."/terrame-examples")
		table.insert(output, value)
		line = file:readLine()
	end

	file:close()
	file = File(zbpreferencespath)

	file:writeLine(table.concat(output, "\n"))
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

	-- TODO: #2060 copy examples here
end

local function updateConfigurationDirectory()
	local zbpath = Directory(path.."/.zbstudio")

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

