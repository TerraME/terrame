-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

local function rm(file)
	if isDirectory(file) then
		Directory(file):delete()
	else
		File(file):delete()
	end
end

function _Gtme.buildPackage(package, config, clean)
	local initialTime = os.clock()

	printNote("Building package '"..package.."'")

	if not isLoaded("base") then
		import("base")
	end

	xpcall(function() _G.getPackage(package) end, function(err)
		printError(err)
		os.exit(1)
	end)

	info_.mode = "debug"

	if config then
		printNote("Parsing configuration file '"..config.."'")
		local data
		xpcall(function() data = _Gtme.include(config) end, function(err)
			printError(err)
			os.exit(1)
		end)

		local err, msg = pcall(function() verifyUnnecessaryArguments(data, {"lines"}) end)

		if not err then
			printError(msg)
			os.exit(1)
		end
	end

	local report = {
		doc_errors = 0,
		unnecessary_files = 0,
		test_errors = 0,
		license = 0,
		model_error = 0
	}

	local s = sessionInfo().separator
	local currentdir = currentDir()

	printNote("\nTesting package '"..package.."'")
	local testErrors = 0
	dofile(sessionInfo().path.."lua"..s.."test.lua")
	xpcall(function() testErrors = _Gtme.executeTests(package, config) end, function(err)
		printError(err)
		report.test_errors = 1
	end)

	report.test_errors = report.test_errors + testErrors

	printNote("Creating documentation of package '"..package.."'")
	local docErrors = 0
	dofile(sessionInfo().path.."lua"..s.."doc.lua")
	xpcall(function() docErrors = _Gtme.executeDoc(package) end, function(err)
		printError(err)
		report.doc_errors = 1
	end)

	report.doc_errors = report.doc_errors + docErrors

	tmpdirectory = Directory{
		name = ".terrame_"..package.."_XXXXX",
		tmp = true
	}

	local pkgInfo = packageInfo(package)
	local pkgDirectory = pkgInfo.path

	tmpdirectory:setCurrentDir()

	local dirWithoutSlash = tostring(pkgDirectory) -- needed to copy the directory using cp
	os.execute("cp -pr \""..dirWithoutSlash.."\" .")

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
		log = true,
		doc = true
	}

	print("Checking basic files and directories")
	forEachDirectory(pkgDirectory, function(dir)
		if not root[dir:name()] then
			printError("Directory '"..package..s..dir:name().."' is unnecessary and will be ignored.")
			dir:delete()
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	forEachFile(pkgDirectory, function(file)
		if not root[file:name()] then
			printError("File '"..package..s..file:name().."' is unnecessary and will be ignored.")
			file:delete()
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	if Directory(pkgDirectory.."examples"):exists() then
		print("Checking examples")
		forEachFile(pkgDirectory.."examples", function(file)
			if not belong(file:extension(), {"lua", ".tme"}) then
				printError("File '"..package..s.."examples"..s..file:name().."' is unnecessary and will be ignored.")
				file:delete()
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	else
		print("Skipping examples")
	end

	print("Checking source code")
	forEachFile(pkgDirectory..s.."lua", function(file)
		if file:extension() ~= "lua" then
			printError("File '"..package..s.."lua"..s..file:name().."' is unnecessary and will be ignored.")
			file:delete()
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	local function removeRecursiveLua(dir)
		forEachDirectory(dir, function(mdir)
			removeRecursiveLua(mdir)
		end)

		forEachFile(dir, function(file)
			if file:extension() ~= "lua" then
				printError("File '"..file.."' is unnecessary and will be ignored.")
				file:delete()
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	end

	removeRecursiveLua(pkgDirectory..s.."tests")

	print("Checking fonts")
	if Directory(package..s.."font"):exists() then
		local fontFiles = {}
		local df = _Gtme.fontFiles(package)
		forEachElement(df, function(_, mvalue)
			fontFiles[mvalue] = true
			local license = string.sub(mvalue, 0, -5)..".txt"
			fontFiles[license] = true
		end)

		forEachFile(package..s.."font", function(file)
			if not fontFiles[file:name()] then
				local mfile = package..s.."font"..s..file:name()
				printError("File '"..mfile.."' is unnecessary and will be ignored.")
				file:delete()
				report.unnecessary_files = report.unnecessary_files + 1
			end
		end)
	end

	print("Looking for hidden files")
	local hidden
	if _Gtme.sessionInfo().system == "windows" then
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

		local dlogs = Directory(package..s.."log")

		if dlogs:exists() then
			print("Removing 'log' directory")
			dlogs:delete()
		end

		local dtest = package..s.."test"

		if Directory(dtest):exists() then
			print("Removing 'test' directory")
			Directory(package..s.."test"):delete()
		end
	end

	printNote("Checking Models")
	local mModel = Model
	local attrTab
	Model = function(attr)
		attrTab = attr
		return attr
	end

	forEachFile(pkgInfo.path.."lua", function(fname)
		local mdata = _Gtme.include(pkgInfo.path.."lua"..s..fname:name())
		if attrTab ~= nil then
			forEachElement(mdata, function(idx, value)
				if value == attrTab then
					if idx..".lua" == fname:name() then
						print("Model '"..idx.."' belongs to file '"..fname:name().."'")
					else
						report.model_error = report.model_error + 1
						printError("Model '"..idx.."' is wrongly put in file '"..fname:name().."'. It should be in file '"..idx..".lua'")
					end
				end
			end)
			attrTab = nil
		end
	end)

	Model = mModel

	printNote("Checking license")
	if not File(pkgDirectory..s.."license.txt"):exists() then
		report.license = 1
		printError("The package does not contain file 'license.txt'")
	end

	printNote("Building package "..package)

	local file = package.."_"..pkgInfo.version..".zip"
	printNote("Creating file '"..file.."'")
	os.execute("zip -qr \""..file.."\" "..package)
	if File(file):exists() then
		printNote("Package '"..package.."' successfully zipped")
	else
		printError("Could not zip package '"..package.."'. Aborting.")
		os.exit(1)
	end

	os.execute("cp \""..file.."\" \""..currentdir.."\"")
	
	if _Gtme.sessionInfo().system == "windows" then
		md5sum = runCommand("md5sum "..file) 
	elseif runCommand("which md5")[1] then
		md5sum = runCommand("md5 -q "..file) 
	elseif runCommand("which md5sum")[1] then
		md5sum = runCommand("md5sum "..file)
	else
		printWarning("Could not find an MD5 sum software installed.")
	end

	currentdir:setCurrentDir()

	local finalTime = os.clock()
	print("\nBuild report for package '"..package.."':")
	printNote("Package was built in "..round(finalTime - initialTime, 2).." seconds.")
	printNote("Build created file '"..file.."'.")
	printNote("Temporary files are saved in "..tostring(tmpdirectory))

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

	return errors
end

