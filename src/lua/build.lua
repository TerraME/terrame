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

local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote

local function rm(file)
	if isFile(file) then
		rmFile(file)
	else
		rmDir(file)
	end
end

function _Gtme.buildPackage(package, clean)
	local initialTime = os.clock()

	printNote("Building package '"..package.."'")

	if not isLoaded("base") then
		import("base")
	end

	xpcall(function() _G.getPackage(package) end, function(err)
		printError(err)
		os.exit()
	end)

	local report = {
		doc_errors = 0,
		unnecessary_files = 0,
		test_errors = 0,
		license = 0,
		model_error = 0
	}

	local s = sessionInfo().separator

	printNote("\nTesting package '"..package.."'")
	info_.mode = "debug"
	local testErrors = 0
	dofile(sessionInfo().path..s.."lua"..s.."test.lua")
	xpcall(function() testErrors = _Gtme.executeTests(package) end, function(err)
		printError(err)
		report.test_errors = 1
	end)

	report.test_errors = report.test_errors + testErrors

	printNote("Creating documentation of package '"..package.."'")
	local docErrors = 0
	dofile(sessionInfo().path..s.."lua"..s.."doc.lua")
	xpcall(function() docErrors = _Gtme.executeDoc(package) end, function(err)
		printError(err)
		report.doc_errors = 1
	end)

	report.doc_errors = report.doc_errors + docErrors

	tmpdirectory = tmpDir(".terrame_"..package.."_XXXXX")
	local currentdir = currentDir()

	local pkgInfo = packageInfo(package)
	local pkgDirectory = pkgInfo.path

	chDir(tmpdirectory)

	if pkgDirectory == package then
		os.execute("cp -pr \""..currentdir..s..pkgDirectory.."\" .")
	else
		os.execute("cp -pr \""..pkgDirectory.."\" .")
	end

	printNote("")

	local data
	pcall(function() data = _Gtme.include(package..s.."description.lua") end)

	if data then
		if not data.date then
			printNote("Adding date to description.lua")
			local date = "\ndate = \""..os.date("%d %B %Y").."\" -- automatically added by build"
			local file = io.open(package..s.."description.lua", "a")
			io.output(file)
			io.write(date)
			io.close(file)
		end
	end

	printNote("Checking unnecessary files")

	local root = {
		["description.lua"] = true,
		["license.lua"] = true,
		["load.lua"] = true,
		["data.lua"] = true,
		["font.lua"] = true,
		["license.txt"] = true,
		lua = true,
		tests = true,
		examples = true,
		data = true,
		images = true,
		font = true,
		snapshots = true,
		doc = true
	}

	print("Checking basic files and directories")
	forEachFile(package, function(file)
		if not root[file] then
			printError("File '"..package..s..file.."' is unnecessary and will be ignored.")
			rm(package..s..file)
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	if isDir(package..s.."examples") then
		print("Checking examples")
		forEachFile(package..s.."examples", function(file)
			if not string.endswith(file, ".lua") and not string.endswith(file, ".tme") and not string.endswith(file, ".log") then
				printError("File '"..package..s.."examples"..s..file.."' is unnecessary and will be ignored.")
				rm(package..s.."examples"..s..file)
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	else
		print("Skipping examples")
	end

	print("Checking source code")
	forEachFile(package..s.."lua", function(file)
		if not string.endswith(file, ".lua") and not isDir(package..s.."lua"..s..file) then
			printError("File '"..package..s.."lua"..s..file.."' is unnecessary and will be ignored.")
			rm(package..s.."lua"..s..file)
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	local function removeRecursiveLua(currentDir)
		forEachFile(currentDir, function(file)
			if isDir(currentDir..s..file) then
				removeRecursiveLua(currentDir..s..file)
			elseif not string.endswith(currentDir..s..file, ".lua") then
				printError("File '"..currentDir..s..file.."' is unnecessary and will be ignored.")
				rm(currentDir..s..file)
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	end

	removeRecursiveLua(package..s.."tests")

	print("Checking fonts")
	if isDir(package..s.."font") then
		local fontFiles = {}
		local df = _Gtme.fontFiles(package)
		forEachElement(df, function(_, mvalue)
			fontFiles[mvalue] = true
			local license = string.sub(mvalue, 0, -5)..".txt"
			fontFiles[license] = true
		end)

		forEachFile(package..s.."font", function(file)
			if not fontFiles[file] then
				local mfile = package..s.."font"..s..file
				printError("File '"..mfile.."' is unnecessary and will be ignored.")
				rm(mfile)
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	end

	print("Looking for hidden files")
	local hidden
	if _Gtme.isWindowsOS() then
		hidden = runCommand("find-msys '"..package.."' -name '.*'")
	else
		hidden = runCommand("find \""..package.."\" -name \".*\"")
	end

	forEachElement(hidden, function(_, file)
		if belong(file, {package..s..".git", package..s..".gitignore"}) then
			printWarning("File '"..file.."' is unnecessary and will be ignored.")
		else
			printError("File '"..file.."' is unnecessary and will be ignored.")
			report.unnecessary_files = report.unnecessary_files + 1
		end

		rm(file)
	end)

	if clean then
		printNote("Cleaning package")

		local dsnapshots = package..s.."snapshots"

		if isDir(dsnapshots) then
			print("Removing 'snapshots' directory")
			rmDir(package..s.."snapshots")
		end

		local dtest = package..s.."test"

		if isDir(dtest) then
			print("Removing 'test' directory")
			rmDir(package..s.."test")
		end

		local logs 
		if _Gtme.isWindowsOS() then
			logs = runCommand("find-msys \""..package.."\" -name \"*.log\"")
		else
			logs = runCommand("find \""..package.."\" -name \"*.log\"")
		end
  
		forEachElement(logs, function(_, file)
			print("Removing "..file)
			rmFile(file)
		end)
	end

	printNote("Checking Models")
	local mModel = Model
	local attrTab
	Model = function(attr)
		attrTab = attr
		return attr
	end

	local result = {}

	forEachFile(pkgInfo.path..s.."lua", function(fname)
		local data = _Gtme.include(pkgInfo.path..s.."lua"..s..fname)
		if attrTab ~= nil then
			forEachElement(data, function(idx, value)
				if value == attrTab then
					if idx..".lua" == fname then
						print("Model '"..idx.."' belongs to file '"..fname.."'")
					else
						report.model_error = report.model_error + 1
						printError("Model '"..idx.."' is wrongly put in file '"..fname.."'. It should be in file '"..idx..".lua'")
					end
				end
			end)
			attrTab = nil
		end
	end)

	Model = mModel

	printNote("Checking license")
	if not isFile(pkgDirectory..s.."license.txt") then
		report.license = 1
		printError("The package does not contain file 'license.txt'")
	end

	printNote("Building package "..package)

	local info = packageInfo(package)
	local file = package.."_"..info.version..".zip"
	printNote("Creating file '"..file.."'")
	os.execute("zip -qr \""..file.."\" "..package)
	if isFile(file) then
		printNote("Package '"..package.."' successfully zipped")
	else
		printError("Could not zip package '"..package.."'. Aborting.")
		os.exit()
	end

	os.execute("cp \""..file.."\" \""..currentdir.."\"")
	
	if _Gtme.isWindowsOS() then 
		md5sum = runCommand("md5sum "..file) 
	else 
		md5sum = runCommand("md5 -q "..file) 
	end

	chDir(currentdir)

	local finalTime = os.clock()
	print("\nBuild report:")
	printNote("Package was built in "..round(finalTime - initialTime, 2).." seconds.")
	printNote("Build created file '"..file.."'.")
	printNote("Temporary files are saved in "..tmpdirectory)

	if type(md5sum) == "table" then
		printNote("MD5 sum for the package is "..md5sum[1])
	end

	if report.license == 0 then
		printNote("The package has a license file.")
	else
		printError("The package does not have a license file.")
	end

	if report.doc_errors == 0 then
		printNote("Documentation was successfully built.")
	elseif report.doc_errors == 1 then
		printError("One error was found in the documentation.")
	else
		printError(report.doc_errors.." errors were found in the documentation.")
	end

	if report.unnecessary_files == 0 then
		printNote("There are no unnecessary files in the package.")
	elseif report.unnecessary_files == 1 then
		printError("One file is unnecessary.")
	else
		printError(report.unnecessary_files.." files are unnecessary.")
	end

	if report.test_errors == 0 then
		printNote("No errors were found while testing the package.")
	elseif report.test_errors == 1 then
		printError("One error was found in the tests.")
	else
		printError(report.test_errors.." errors were found in the tests.")
	end

	if report.model_error == 0 then
		printNote("All Models are placed in the right files.")
	elseif report.model_error == 1 then
		printError("One Model is placed in the wrong file.")
	else
		printError(report.model_error.." Models are placed in the wrong files.")
	end

	local errors = 0

	forEachElement(report, function(_, value)
		errors = errors + value
	end)

	if errors == 0 then
		printNote("Summing up, the package was successfully built.")
	elseif errors == 1 then
		printError("Summing up, one problem was found along the build.")
	else
		printError("Summing up, "..errors.." problems were found along the build.")
	end
end

