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

local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote
local print        = _Gtme.print

local function verifyTest(package, report)
	printNote("Verifying test files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local testDir = baseDir.."tests"
	local internalDirectory = false
	local dir = Directory(testDir)

	if not Directory(baseDir.."lua"):exists() then
		_Gtme.print("Package '"..package.."' does not have source code")
		return
	end

	if not dir:exists() then
		printWarning("Creating directory 'tests'")
		dir:create()
	end

	forEachDirectory(testDir, function()
		internalDirectory = true
		return false
	end)

	if internalDirectory then
		_Gtme.printWarning("Ignoring tests because internal directories were found in the tests")
		return false
	end

	local pkgData = _G.getPackage(package)
	local testfunctions = _Gtme.buildCountTable(package)

	forEachOrderedElement(testfunctions, function(idx, value)
		if File(testDir..s..idx):exists() then
			print("File '"..idx.."' already exists in the tests")
			return
		end

		local sub = string.sub(idx, 1, -5)

		if type(pkgData[sub]) == "Model" then
			local mandatory = false
			forEachElement(pkgData[sub]:getParameters(), function(_, _, mtype)
				if mtype == "Mandatory" then
					mandatory = true
				end
			end)

			if mandatory then
				printNote("Ignoring Model '"..sub.."' as it has a Mandatory argument")
				return
			end
		end

		printWarning("Creating "..idx)
		report.created_files = report.created_files + 1

		str = "-- Test file for "..idx.."\n"
		str = str.."-- Author: "..packageInfo(package).authors
		str = str.."\n\nreturn{\n"

		forEachOrderedElement(value, function(func)
			str = str.."\t"..func.." = function(unitTest)\n"

			if type(pkgData[func]) == "Model" then
				local model = pkgData[func]{}

				str = str.."\t\tlocal model = "..func.."{}\n\n"

				local countMap = 1

				forEachOrderedElement(model, function(midx, _, mtype)
					if mtype == "Map" then
						str = str.."\t\tunitTest:assertSnapshot(model."..midx..", \""..func.."-map-"..countMap.."-begin.bmp\")\n"
						countMap = countMap + 1
					end
				end)

				if countMap > 1 then
					str = str.."\n"
				end

				str = str.."\t\tmodel:run()\n\n"

				local countChart = 1
				countMap = 1

				forEachOrderedElement(model, function(midx, _, mtype)
					if mtype == "Chart" then
						str = str.."\t\tunitTest:assertSnapshot(model."..midx..", \""..func.."-chart-"..countChart..".bmp\")\n"
						countChart = countChart + 1
					elseif mtype == "Map" then
						str = str.."\t\tunitTest:assertSnapshot(model."..midx..", \""..func.."-map-"..countMap.."-end.bmp\")\n"
						countMap = countMap + 1
					end
				end)

				clean()

			else
				str = str.."\t\t-- add a test here \n"
			end

			str = str.."\tend,\n"
		end)

		str = str.."}\n\n"

		local file = io.open(testDir..s..idx, "w")
		io.output(file)
		io.write(str)
		io.close(file)
	end)
end

local function verifyData(package, report)
	printNote("Verifying data files")

	local baseDir = packageInfo(package).path
	local dataDir = Directory(baseDir.."data")

	if not dataDir:exists() then
		_Gtme.print("Package '"..package.."' does not have a data directory")
		return
	end

	local datafiles = {}
	local datadotlua = baseDir.."data.lua"

	forEachFile(dataDir, function(file)
		datafiles[file:name()] = false
	end)

	if getn(datafiles) == 0 then
		_Gtme.print("Package '"..package.."' has no data")
		return
	end

	if File(datadotlua):exists() then
		local originaldata = data
		data = function(mdata)
			if type(mdata.file) == "string" then
				datafiles[mdata.file] = true
			elseif type(mdata.file) == "table" then
				forEachElement(mdata.file, function(_, mfile)
					datafiles[mfile] = true
				end)
			end
		end

		_Gtme.include(datadotlua)
		data = originaldata
	else
		_Gtme.print("Creating 'data.lua'")
	end

	local mfile = io.open(datadotlua, "a")

	local tl = getPackage("terralib")

	sessionInfo().mode = "quiet"

	myProject = tl.Project{
		file = "tmpproj.tview",
		clean = true
	}

	counter = 1

	forEachDirectory(dataDir, function(dir)
		_Gtme.print("Directory '"..dir:name().."' will be ignored")
	end)

	forEachOrderedElement(datafiles, function(idx, value)
		local file = filePath(idx, package)
		local _, name, extension = file:split()

		if value then
			_Gtme.print("File '"..idx.."' is already documented in 'data.lua'")
		elseif _Gtme.ignoredFile(idx) then
			_Gtme.print("File '"..idx.."' does not need to be documented")
		elseif extension == "tview" and File(dataDir..name..".lua"):exists() then
			_Gtme.print("Project file '"..idx.."' does not need to be documented (a Lua file creates it)")
		elseif extension == "shp" and File(dataDir..name..".lua"):exists() then
			_Gtme.print("File '"..idx.."' does not need to be documented (a Lua file creates it)")
		else
			_Gtme.printWarning("Adding sketch for data file '"..idx.."'")
			local str = "data{\n"
				.."\tfile = \""..idx.."\",\n"
				.."\tsummary = \"\",\n"
				.."\tsource = \"\",\n"
				.."\treference = \"\""

			if extension == "shp" or extension == "geojson" then
				layer = tl.Layer{
					project = myProject,
					file = filePath(idx, package),
					name = "layer"..counter
				}

				counter = counter + 1

				str = str..",\n\tattributes = {\n"

				local attributes = layer:attributes()

				forEachElement(attributes, function(_, mvalue)
					str = str.."\t\t"..mvalue.." = \"\",\n"
				end)

				str = str.."\t}"
			elseif extension == "tif" then
				layer = tl.Layer{
					project = myProject,
					file = filePath(idx, package),
					name = "layer"..counter
				}

				counter = counter + 1

				str = str..",\n\tattributes = {\n"

				local bands = layer:bands()
				for i = 0, bands - 1 do
					str = str.."\t\t[\""..i.."\"] = \"\",\n"
				end

				str = str.."\t}"
			end

			str = str.."\n}\n\n"
			mfile:write(str)

			report.created_data = report.created_data + 1
		end
	end)

	sessionInfo().mode = "strict"
	File("tmpproj.tview"):delete()
	mfile:close()
end

local function verifyFont(package, report)
	printNote("Verifying font files")

	local baseDir = packageInfo(package).path
	local fontDir = baseDir.."font"

	if not Directory(fontDir):exists() then
		_Gtme.print("Package '"..package.."' does not have a font directory")
		return
	end

	local fontfiles = {}
	local fontdotlua = baseDir.."font.lua"

	forEachFile(fontDir, function(file)
		fontfiles[file:name()] = false
	end)

	if getn(fontfiles) == 0 then
		_Gtme.print("Package '"..package.."' has no fonts")
		return
	end

	if File(fontdotlua):exists() then
		local originalfont = font
		font = function(mfont)
			if type(mfont.file) == "string" then
				fontfiles[mfont.file] = true
			end
		end

		_Gtme.include(fontdotlua)
		font = originalfont
	else
		_Gtme.print("Creating 'font.lua'")
	end

	local mfile = io.open(fontdotlua, "a")

	forEachOrderedElement(fontfiles, function(idx, value)
		if value then
			_Gtme.print("File '"..idx.."' is already documented in 'font.lua'")
		elseif string.endswith(idx, ".ttf") then
			_Gtme.printWarning("Adding sketch for font file '"..idx.."'")
			local str = "font{\n"
				.."\tfile = \""..idx.."\",\n"
				.."\tname = \"\",    -- optional\n"
				.."\tsummary = \"\",\n"
				.."\tsource = \"\",\n"
				.."\tsymbol = {}\n"
				.."}\n\n"
			mfile:write(str)

			report.created_font = report.created_font + 1
		else
			_Gtme.print("File '"..idx.."' will be ignored")
		end
	end)

	mfile:close()
end

function _Gtme.sketch(package)
	local report = {
		created_files = 0,
		created_data = 0,
		created_font = 0,
	}

	import("base")

	verifyTest(package, report)
	verifyData(package, report)
	verifyFont(package, report)

	print("\nSketch report for package '"..package.."':")

	if report.created_files == 0 then
		printNote("No new test file was necessary.")
	elseif report.created_files == 1 then
		printWarning("One sketch to test a file was created.")
	else
		printWarning(report.created_files.." sketches to test files were created.")
	end

	if report.created_data == 0 then
		printNote("All data is already documented.")
	elseif report.created_data == 1 then
		printWarning("One sketch for data file was created in 'data.lua'.")
	else
		printWarning(report.created_data.." sketches for data files were created in 'data.lua'.")
	end

	if report.created_font == 0 then
		printNote("All font files are already documented.")
	elseif report.created_font == 1 then
		printWarning("One sketch for font file was created in 'font.lua'.")
	else
		printWarning(report.created_font.." sketches for font files were created in 'font.lua'.")
	end

	local errors = 0

	forEachElement(report, function(_, value)
		errors = errors + value
	end)

	if errors == 0 then
		printNote("Summing up, no sketch was created.")
	elseif errors == 1 then
		printError("Summing up, one sketch was created. Please fill it.")
	else
		printError("Summing up, "..errors.." sketches were created. Please fill them.")
	end

	os.exit(errors)
end

