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

function _Gtme.buildPackage(package)
	local initialTime = os.clock()

	local report = {
		doc_errors = 0,
		unnecessary_files = 0,
		test_errors = 0,
		license = 0,
		model_error = 0
	}

	printNote("Building package "..package)
	local s = sessionInfo().separator
	local docErrors = 0
	dofile(sessionInfo().path..s.."lua"..s.."doc.lua")
	xpcall(function() docErrors = _Gtme.executeDoc(package) end, function(err)
		printError(err)
		report.doc_errors = 1
	end)

	report.doc_errors = report.doc_errors + docErrors

	printNote("\nChecking unnecessary files")

	local root = {
		["description.lua"] = true,
		["license.lua"] = true,
		["load.lua"] = true,
		["data.lua"] = true,
		["license.txt"] = true,
		lua = true,
		tests = true,
		examples = true,
		data = true,
		doc = true
	}

	local pkgInfo = packageInfo(package)
	local pkgFolder = pkgInfo.path

	forEachFile(pkgFolder, function(file)
		if not root[file] then
			printError("File '"..pkgFolder..s..file.."' is unnecessary.")
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	forEachFile(pkgFolder..s.."examples", function(file)
		if not string.endswith(file, ".lua") and not string.endswith(file, ".tme") and not string.endswith(file, ".log") then
			printError("File '"..pkgFolder..s.."examples"..s..file.."' is unnecessary.")
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	forEachFile(pkgFolder..s.."lua", function(file)
		if not string.endswith(file, ".lua") and attributes(pkgFolder..s.."lua"..s..file, "mode") ~= "directory" then
			printWarning("File '"..pkgFolder..s.."lua"..s..file.."' is unnecessary.")
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	forEachFile(pkgFolder..s.."tests", function(file)
		if not string.endswith(file, ".lua") and attributes(pkgFolder..s.."tests"..s..file, "mode") ~= "directory" then
			printWarning("File '"..pkgFolder..s.."tests"..s..file.."' is unnecessary.")
			report.unnecessary_files = report.unnecessary_files + 1
		end
	end)

	printNote("\nTesting package "..package)

	info_.mode = "debug"
	local testErrors = 0
	dofile(sessionInfo().path..s.."lua"..s.."test.lua")
	xpcall(function() testErrors = _Gtme.executeTests(package) end, function(err)
		printError(err)
		report.test_errors = 1
	end)

	report.test_errors = report.test_errors + testErrors

	printNote("\nChecking Models")
	local mModel = Model
	local attrTab
	Model = function(attr)
		attrTab = attr
		return attr
	end
	local s = sessionInfo().separator

	local result = {}

	forEachFile(pkgInfo.path..s.."lua", function(fname)
		local data = _Gtme.include(pkgInfo.path..s.."lua"..s..fname)
		if attrTab ~= nil then
			forEachElement(data, function(idx, value)
				if value == attrTab then
					if idx..".lua" == fname then
						printNote("Model '"..idx.."' belongs to file '"..fname.."'")
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
	if not isFile(pkgFolder..s.."license.txt") then
		report.license = 1
		printError("The package does not contain file 'license.txt'")
	end

	printNote("Building package "..package)

	tmpfolder = runCommand("mktemp -d .terrame_"..package.."_XXXXX")[1]
	local currentdir = currentDir()

	chDir(tmpfolder)
	if pkgFolder == package then
		os.execute("cp -pr \""..currentdir..s..pkgFolder.."\" .")
	else
		os.execute("cp -pr \""..pkgFolder.."\" .")
	end

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

	md5sum = runCommand("md5 -q "..file)

	chDir(currentdir)

	local finalTime = os.clock()
	print("\nBuild report:")
	printNote("Package was built in "..round(finalTime - initialTime, 2).." seconds.")
	printNote("Build created file '"..file.."'.")
	printNote("Temporary files are saved in "..tmpfolder)

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

