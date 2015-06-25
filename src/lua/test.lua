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

-- find the folders inside a package that contain
-- lua files, starting from package/tests
local function testfolders(folder, ut)
	local result = {}

	local s = sessionInfo().separator

	local lf 
	lf = function(mfolder)
		local found_file = false
		local found_folder = false
		forEachFile(folder..s..mfolder, function(value)
			if string.endswith(value, ".lua") then
				if not found_file then
					found_file = true
					table.insert(result, mfolder)
				end
			elseif attributes(folder..s..mfolder..s..value, "mode") == "directory" then
				lf(mfolder..s..value)
				found_folder = true
			else
				printError("'"..mfolder..s..value.."' is not a folder neither a .lua file and will be ignored.")
				ut.invalid_test_file = ut.invalid_test_file + 1
			end
		end)
		if not found_file and not found_folder then
			printError("Folder '"..mfolder.."' is empty.")
			ut.invalid_test_file = ut.invalid_test_file + 1
		end
	end

	lf("tests")

	return(result)
end

-- find the lines of the file that have the string ":assert"
-- it ignores when this standart is inside a -- comment
-- all these lines should be executed at least once
local function assertTable(filename)
	local count = 0
	local mtable = {}

	local file = io.open(filename, "r")

	local line = file:read()
	while line do
		count = count + 1

		if string.match(line, ":assert") and not string.match(line, "SKIP") then
			if string.match(line, ".*%-%-.*assert") == nil then
				mtable[count] = 0
			end
		end

		line = file:read()
	end

	io.close(file)
	return mtable
end

local function lineTable(filename)
	local count = 0
	local mtable = {}

	local file = io.open(filename, "r")

	local line = file:read()
	while line do
		count = count + 1

		local pos = 1

		local state = "code"

		while true do
			local c = string.sub(line, pos, pos)

			if string.match(line, "function") then break end
			if string.match(line, "else")     then break end
			if string.match(line, "end")      then break end
			if string.match(line, "repeat")   then break end
			if string.match(line, "break")    then break end
			if string.match(line, "}")        then break end
			if string.match(line, "local")    then break end
			if string.match(line, "return")   then break end
			if string.match(line, "do")       then break end
			if string.match(line, "print")    then break end
			if string.match(line, "io.close") then break end
			if string.match(line, "SKIP")     then break end

			if state == "code" then
				if c == "" then
					break
				elseif c == " " or c == "\t" then

				elseif c == "-" then
					state = "-"
				else
					mtable[count] = 0
					break
				end
			elseif state == "-" then
				if c == "-" then
					state = "code"
					break
				else
					mtable[count] = 0
					break
				end
			end
			pos = pos + 1
		end

		line = file:read()
	end

	io.close(file)
	return mtable
end

local function buildLineTable(package)
	local s = sessionInfo().separator
	local baseDir = packageInfo(package).path

	local load_file = baseDir..s.."load.lua"
	local load_sequence

	if isFile(load_file) then
		-- the 'include' below does not need to be inside a xpcall because
		-- the package was already loaded with success
		load_sequence = _Gtme.include(load_file).files
	else
		local dir = dir(baseDir..s.."lua")
		load_sequence = {}
		forEachElement(dir, function(_, mfile)
			if string.endswith(mfile, ".lua") then
				table.insert(load_sequence, mfile)
			end
		end)
	end

	local testlines = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		-- the 'include' below does not need to be inside a xpcall because
		-- the package was already loaded with success
		testlines[file] = lineTable(baseDir..s.."lua"..s..file)

		local function trace(event, line)
			testlines[file][line] = 1
		end

		debug.sethook(trace, "l")
		dofile(baseDir..s.."lua"..s..file)
		debug.sethook()
	end

	return testlines
end

function _Gtme.executeTests(package, fileName)
	local initialTime = os.clock()

	local data

	if type(fileName) == "string" then
		printNote("Loading configuration file '"..fileName.."'")
	
		xpcall(function() data = _Gtme.include(fileName) end, function(err)
			printError(err)
			os.exit()
		end)

		if getn(data) == 0 then
			printError("File "..fileName.." is empty. Please use at least one variable from {'examples', 'folder', 'file', 'lines', 'sleep', 'test'}.")
			os.exit()
		end

		if type(data.folder) == "string" then
			data.folder = {data.folder}
		elseif data.folder ~= nil and type(data.folder) ~= "table" then
			customError("'folder' should be string, table, or nil, got "..type(data.folder)..".")
		end

		if type(data.file) == "string" then
			data.file = {data.file}
		elseif type(data.file) ~= "table" and data.file ~= nil then
			customError("'file' should be string, table, or nil, got "..type(data.file)..".")
		end

		if data.test ~= nil and type(data.test) ~= "string" and type(data.test) ~= "table" then
			customError("'test' should be string, table, or nil, got "..type(data.test)..".")
		end

		if data.sleep ~= nil and type(data.sleep) ~= "number"  then
			customError("'sleep' should be number or nil, got "..type(data.sleep)..".")
		end

		if data.examples ~= nil and type(data.examples) ~= "boolean" then
			customError("'examples' should be boolean or nil, got "..type(data.examples)..".")
		end

		if data.lines ~= nil then
			if type(data.lines) ~= "boolean" then
				customError("'lines' should be boolean or nil, got "..type(data.lines)..".")
			elseif data.test ~= nil or data.folder ~= nil then
				customError("'lines' cannot be used with 'test' or 'folder'.")
			end
		end

		verifyUnnecessaryArguments(data, {"folder", "file", "test", "sleep", "examples", "lines"})
	else
		data = {}
	end

	if data.sleep == nil then
		data.sleep = 0
	end

	local check_functions = data.folder == nil and data.test == nil
	local check_snapshots = data.folder == nil and data.test == nil and data.file == nil
	if data.examples == nil then
		data.examples = check_functions and data.file == nil
	end

	local ut = UnitTest{
		sleep = data.sleep,
		package = package,
		package_functions = 0,
		functions_not_exist = 0,
		functions_not_tested = 0,
		executed_functions = 0,
		functions_with_global_variables = 0,
		functions_with_error = 0,
		functions_without_assert = 0,
		examples = 0,
		examples_error = 0,
		print_calls = 0,
		log_files = 0,
		invalid_test_file = 0,
		print_when_loading = 0,
		snapshots = 0,
		snapshot_files = 0,
		lines_not_executed = 0,
		asserts_not_executed = 0,
		overwritten_variables = 0,
		unused_snapshot_files = 0
	}

	if not isLoaded("base") and sessionInfo().package ~= "base" then
		import("base")
	end

	printNote("Loading package "..package)
	print = function(arg)
		ut.print_when_loading = ut.print_when_loading + 1

		printError("Error: print() call detected with argument '"..tostring(arg).."'")
	end

	_, overwritten = _G.package(package)

	print = function() end

	printNote("Looking for overwritten variables")
	if package ~= "base" then
		forEachOrderedElement(overwritten, function(value)
			printError("Global variable '"..value.."' is overwritten.")
			ut.overwritten_variables = ut.overwritten_variables + 1
		end)
	end

	import(package)

	printNote("Looking for documented functions")

	if not isLoaded("luadoc") then
		import("luadoc")
	end

	local s = sessionInfo().separator
	local baseDir = packageInfo(package).path
	local srcDir = baseDir..s.."tests"

	doc_functions = luadocMain(baseDir, dir(baseDir..s.."lua"), {}, package, {}, {}, true)

	printNote("Looking for package functions")
	testfunctions = _Gtme.buildCountTable(package)
	
	local extra = 0
	forEachElement(doc_functions.files, function(idx, value)
		if type(idx) ~= "string" then return end
		if not string.endswith(idx, ".lua") then return end

		if testfunctions[idx] == nil then
			testfunctions[idx] = {}
		end
		forEachElement(value.functions, function(midx)
			if midx == "#" then midx = "__len" end

			if type(midx) ~= "string" then return end
			if testfunctions[idx][midx] == nil then
				testfunctions[idx][midx] = 0
				extra = extra + 1
			end
		end)
	end)

	if extra > 0 then
		printNote("Found "..extra.." extra functions in the documentation")
	end

	if not isFile(srcDir) then
		printError("Folder 'tests' does not exist in package '"..package.."'.")
		
		printWarning("Creating folder 'tests'")
		mkDir(srcDir)

		forEachOrderedElement(testfunctions, function(idx, value)
			printWarning("Creating "..idx)

			str = "-- Test file for "..idx.."\n"
			str = str.."-- Author: "..packageInfo(package).authors
			str = str.."\n\nreturn{\n"

			forEachOrderedElement(value, function(func)
				str = str.."\t"..func.." = function(unitTest)\n"
				str = str.."\t\t-- add a test here \n"
				str = str.."\tend,\n"
			end)

			str = str.."}\n\n"

			local file = io.open(srcDir..s..idx, "w")
			io.output(file)
			io.write(str)
			io.close(file)
		end)

		printWarning("Please fill the test files and run the tests again")
		os.exit()
	end

	local executionlines

	if data.lines then
		printNote("Looking for lines of source code")
		executionlines = buildLineTable(package)
	else
		printWarning("Skip looking for lines of source code")
	end

	print = _Gtme.print

	local tf = testfolders(baseDir, ut)

	-- Check every selected folder
	if data.folder == nil then
		data.folder = tf
	else -- table
		local mfolder = data.folder
		data.folder = {}

		local found = {}
		forEachElement(mfolder, function(_, value)
			found[value] = false
		end)

		forEachElement(tf, function(_, value)
			forEachElement(mfolder, function(_, mvalue)
				if string.match(value, mvalue) then
					table.insert(data.folder, value)
					found[mvalue] = true
					return false
				end
			end)
		end)

		forEachElement(mfolder, function(_, value)
			if not found[value] then
				printError("Could not find any folder for pattern '"..value.."'.")
				os.exit()
			end
		end)
	end

	if #data.folder == 0 then
		customError("Could not find any folder to be tested according to the value of 'folder'.")
		os.exit()
	end

	local global_variables = {}
	local global_values = {}
	forEachElement(_G, function(idx, value, mtype)
		global_variables[idx] = mtype
		global_values[idx] = value
	end)

	local myTests
	local myFiles

	-- For each test in each file in each folder, execute the test
	forEachElement(data.folder, function(_, eachFolder)
		local dirFiles = dir(baseDir..s..eachFolder)

		if dirFiles == nil then return end

		myFiles = {}
		if type(data.file) == "table" then
			forEachElement(dirFiles, function(_, value)
				forEachElement(data.file, function(_, mfile)
					if string.match(value, mfile) then
						myFiles[#myFiles + 1] = value
					end
				end)
			end)
		else -- nil
			forEachElement(dirFiles, function(_, value)
				if string.endswith(value, ".lua") then
					myFiles[#myFiles + 1] = value
				end
			end)
		end

		if #myFiles == 0 then
			printWarning("Skipping folder "..eachFolder)
		end

		for _, eachFile in ipairs(myFiles) do
			ut.current_file = eachFolder..s..eachFile
			local tests

			printNote("Testing "..eachFolder..s..eachFile)

			print = function(arg)
				ut.print_calls = ut.print_calls + 1
				printError("Error: print() call detected with argument '"..arg.."'")
			end

			xpcall(function() tests = dofile(baseDir..s..eachFolder..s..eachFile) end, function(err)
				printError("Could not load file "..err)
				os.exit()
			end)

			print = _Gtme.print

			local myAssertTable = assertTable(baseDir..s..eachFolder..s..eachFile)

			if type(tests) ~= "table" or getn(tests) == 0 then
				printError("The file does not implement any test.")
				os.exit()
			end

			myTests = {}
			if type(data.test) == "string" then
				if tests[data.test] then
					myTests = {data.test}
				end
			elseif data.test == nil then
				forEachOrderedElement(tests, function(index, value, mtype)
					myTests[#myTests + 1] = index
				end)
			else -- table
				forEachElement(data.test, function(_, value)
					if tests[value] then
						myTests[#myTests + 1] = value
					end
				end)
			end

			if #myTests == 0 then
				printWarning("Skipping "..eachFolder..s..eachFile)
			end

			local function trace(event, line)
				local s = debug.getinfo(2).short_src
				local short = string.match(s, "([^/]-)$")

				if short == eachFile and string.match(s, "tests") then
					if myAssertTable[line] then
						myAssertTable[line] = myAssertTable[line] + 1
					end
				end

				if data.lines and short == eachFile and not string.match(s, "tests") then
					if executionlines[eachFile] then	
						if not executionlines[eachFile][line] then
							--printNote(line)
						else
							executionlines[eachFile][line] = executionlines[eachFile][line] + 1
						end
					end
				end
			end

			for _, eachTest in ipairs(myTests) do
				print("Testing "..eachTest)
				Random{seed = 0}
				debug.sethook(trace, "l")
				if not doc_functions then io.flush() end -- theck why it is necessary to have the 'if'

				if testfunctions[eachFile] then
					if testfunctions[eachFile][eachTest] then
						testfunctions[eachFile][eachTest] = testfunctions[eachFile][eachTest] + 1
					else
						printError("This function does not exist in the respective file in the source code.")
						ut.functions_not_exist = ut.functions_not_exist + 1
					end
				end

				local count_test = ut.test

				collectgarbage("collect")

				print = function(arg)
					ut.print_calls = ut.print_calls + 1
					printError("Error: print() call detected with argument '"..arg.."'")
				end

				local found_error = false
				xpcall(function() tests[eachTest](ut) end, function(err)
					printError("Wrong execution, got error: '"..err.."'.")
					ut.functions_with_error = ut.functions_with_error + 1
					local tb = _Gtme.traceback()
					if tb ~= "" then
						printError(tb)
					end
					found_error = true
				end)

				print = _Gtme.print

				ut:clear()
				ut.executed_functions = ut.executed_functions + 1

				if count_test == ut.test and not found_error then
					printError("No asserts were found in the test.")
					ut.functions_without_assert = ut.functions_without_assert + 1
				end

				local pvariables = {}
				local rpvariables = {}

				forEachElement(_G, function(idx, _, mtype)
					if global_variables[idx] == nil then
						pvariables[idx] = mtype
					elseif global_variables[idx] ~= mtype then
						rpvariables[idx] = {was = global_variables[idx], is = mtype}
					end
				end)

				if getn(pvariables) > 0 then
					local variables = ""
				
					-- we need to delete the global variables created in order to ensure that a
					-- new error will be generated if this variable is found again. This need
					-- to be done here because we cannot change _G inside a forEachElement
					-- traversing _G
					forEachOrderedElement(pvariables, function(value, mtype)
						_G[value] = nil
						variables = variables.."'"..value.."' ("..mtype.."), "
					end)

					variables = variables:sub(1, variables:len() - 2).."."
					printError("Test creates global variable(s): "..variables)
				end

				if getn(rpvariables) > 0 then
					local rvariables = ""

					-- same reason as above
					forEachOrderedElement(rpvariables, function(value, t)
						_G[value] = global_values[value]
						rvariables = rvariables.."'"..value.."' (changed from "..t.was.." to "..t.is.."), "
					end)

					rvariables = rvariables:sub(1, rvariables:len() - 2).."."
					printError("Test updates global variable(s): "..rvariables)
				end

				if getn(pvariables) > 0 or getn(rpvariables) > 0 then
					ut.functions_with_global_variables = ut.functions_with_global_variables + 1
				end

				if ut.count_last > 0 then
					printError("[The error above occurs "..ut.count_last.." more times.]")
					ut.count_last = 0
					ut.last_error = ""
				end
			end

			debug.sethook()

			if data.test then
				printWarning("Skip checking asserts")
			else
				print("Checking if all asserts were executed")
				forEachOrderedElement(myAssertTable, function(line, count)
					if count == 0 then
						printError("Assert in line "..line.." was not executed.")
						ut.asserts_not_executed = ut.asserts_not_executed + 1
					end
				end)
			end
		end
	end) 

	if ut.test == 0 and not data.examples then
		printError("No test was executed. Aborting.")
		os.exit()
	end

	-- checking if all source code functions were tested
	if check_functions then
		printNote("Checking if functions from source code were tested")
		if type(data.file) == "table" then
			local found = {}
			forEachElement(data.file, function(_, value)
				found[value] = false
			end)

			forEachOrderedElement(data.file, function(idx, value)
				forEachOrderedElement(testfunctions, function(midx, mvalue)
					if not string.match(midx, value) then return end

					found[value] = true

					print("Checking "..midx)
					forEachOrderedElement(mvalue, function(mmidx, mmvalue)
						ut.package_functions = ut.package_functions + 1
						if mmvalue == 0 then
							printError("Function '"..mmidx.."' was not tested.")
							ut.functions_not_tested = ut.functions_not_tested + 1
						end
					end)
				end)
			end)

			forEachElement(data.file, function(_, value)
				if not found[value] then
					printError("Could not find any file for pattern '"..value.."'.")
				end
			end)
		else -- nil
			forEachOrderedElement(testfunctions, function(idx, value)
				print("Checking "..idx)
				forEachOrderedElement(value, function(midx, mvalue)
					ut.package_functions = ut.package_functions + 1
					if mvalue == 0 then
						printError("Function '"..midx.."' was not tested.")
						ut.functions_not_tested = ut.functions_not_tested + 1
					end
				end)
			end)
		end
	else
		printWarning("Skipping source code functions check")
	end

	if data.lines then
		printNote("Checking lines of source code")
		if type(data.file) == "table" then
			forEachOrderedElement(data.file, function(idx, value)
				forEachElement(executionlines, function(midx, mvalue)
					if not string.match(midx, value) then return end

					print("Checking "..midx)
					forEachOrderedElement(mvalue, function(mmidx, mmvalue)
						if mmvalue == 0 then
							printError("Line "..mmidx.." was not executed.")
							ut.lines_not_executed = ut.lines_not_executed + 1
						end
					end)
				end)
			end)
		else -- nil
			forEachOrderedElement(executionlines, function(idx, mvalue)
				print("Checking "..idx)
				forEachOrderedElement(mvalue, function(idx, value)
					if value == 0 then
						printError("Line "..idx.." was not executed.")
						ut.lines_not_executed = ut.lines_not_executed + 1
					end
				end)
			end)
		end
	else
		printWarning("Skipping lines of source code check")
	end

	if ut.snapshots > 0 and check_snapshots then
		printNote("Checking snapshots")
		local mdir = dir(packageInfo(package).path..s.."snapshots")

		forEachElement(mdir, function(_, value)
			if not ut.tsnapshots[value] then
				printError("File 'snapshot/"..value.."' was not used by any assertSnapshot().")
				ut.unused_snapshot_files = ut.unused_snapshot_files + 1
			end
		end)
	else
		printWarning("Skipping snapthots check")
	end

	-- executing examples
	if data.examples then
		printNote("Testing examples")
		local dirFiles = _Gtme.findExamples(package)
		if dirFiles ~= nil then
			forEachElement(dirFiles, function(idx, value)
				print("Testing "..value)
				if not doc_functions then io.flush() end -- theck why it is necessary to have the 'if'

				local logfile = nil
				local writing_log = false
				print = function(x)
					if not logfile then
						local lfilename = value..".log"

						logfile = io.open(baseDir..s.."examples"..s..lfilename, "r")
						if logfile == nil then
							printError("Creating log file "..lfilename)
							logfile = io.open(baseDir..s.."examples"..s..lfilename, "w")
							writing_log = true
							ut.log_files = ut.log_files + 1
						end
					end

					if writing_log then
						local str = logfile:write(x.."\n")
					else
						local str = logfile:read(string.len(x) + 1)
						if str ~= x.."\n" then
							ut.examples_error = ut.examples_error + 1
							printError("Error: Strings do not match:")
							if str == nil then
								printError("Log file: <empty>")
							else
								printError("Log file: '"..str.."'.")
							end
							printError("Simulation: '"..x.."'.")
						end
					end
				end

				collectgarbage("collect")
				
				ut.examples = ut.examples + 1

				local myfunc = function()
					local env = setmetatable({}, {__index = _G})
					-- loadfile is necessary to avoid any global variable from one
					-- example affect another example
					loadfile(baseDir..s.."examples"..s..value..".lua", 't', env)()
				end
				xpcall(myfunc, function(err)
					ut.examples_error = ut.examples_error + 1
					printError("Error in "..err)
					printError(_Gtme.traceback())
					writing_log = true -- to avoid showing errors in the log file
				end)

				if not writing_log and logfile then
					local str = logfile:read("*all")
					if str and str ~= "" then
						ut.examples_error = ut.examples_error + 1
						printError("Output file contains text not printed by the simulation: ")
						printError("'"..str.."'")
					end
				end	

				if logfile ~= nil then
					io.close(logfile)
				end

				print = _Gtme.print

				ut:clear()
			end)
		end
	else
		printWarning("Skipping examples")
	end

	local finalTime = os.clock()

	print("\nTest report:")

	local text = "Tests were executed in "..round(finalTime - initialTime, 2).." seconds"
	if ut.delayed_time > 0 then
		text = text.." ("..ut.delayed_time.. " seconds sleeping)."
	else
		text = text.."."
	end
	printNote(text)

	if ut.snapshots > 0 then
		printNote("Snapshots were saved in '"..ut:tmpFolder().."'.")
	end

	if ut.print_when_loading == 1 then
		printError("One print() call was found when loading the package.")
	elseif ut.print_when_loading > 1 then
		printError(ut.print_when_loading.." print() calls were found when loading the package.")
	else
		printNote("No print() calls were found when loading the package.")
	end

	if ut.overwritten_variables == 1 then
		printError("One variable is overwritten when loading the package.")
	elseif ut.overwritten_variables > 1 then
		printError(ut.overwritten_variables.." variables are overwritten when loading the package.")
	else
		printNote("No variable is overwritten when loading the package.")
	end

	if ut.invalid_test_file == 1 then
		printError("One invalid file or folder was found in folder 'test'.")
	elseif ut.invalid_test_file > 1 then
		printError(""..ut.invalid_test_file.." invalid files or folders were found in folder 'test'.")
	else
		printNote("There are no invalid files or folders in folder 'tests'.")
	end

	if data.test then -- asserts are not verified only when the user executes specific tests
		printWarning("Execution of all asserts was not verified.")
	elseif ut.asserts_not_executed == 1 then
		printError("One assert was not executed at least once.")
	elseif ut.asserts_not_executed > 1 then
		printError(ut.asserts_not_executed.." asserts were not executed at least once.")
	else
		printNote("All asserts were executed at least once.")
	end

	if ut.fail == 1 then
		printError("One out of "..ut.test.." asserts failed.")
	elseif ut.fail > 1 then
		printError(ut.fail.." out of "..ut.test.." asserts failed.")
	else
		printNote("All "..ut.test.." asserts were executed successfully.")
	end

	if ut.functions_with_error == 1 then
		printError("One out of "..ut.executed_functions.." tested functions stopped with an unexpected error.")
	elseif ut.functions_with_error > 1 then
		printError(ut.functions_with_error.." out of "..ut.executed_functions.." tested functions stopped with an unexpected error.")
	else
		printNote("All "..ut.executed_functions.." tested functions do not have any unexpected execution error.")
	end

	if ut.functions_without_assert == 1 then
		printError("One out of "..ut.executed_functions.." tested functions does not have at least one assert.")
	elseif ut.functions_without_assert > 1 then
		printError(ut.functions_without_assert.." out of "..ut.executed_functions.." tested functions do not have at least one assert.")
	else
		printNote("All "..ut.executed_functions.." tested functions have at least one assert.")
	end

	if ut.functions_not_exist == 1 then
		printError("One out of "..ut.executed_functions.." tested functions does not exist in the source code of the package.")
	elseif ut.functions_not_exist > 1 then
		printError(ut.functions_not_exist.." out of "..ut.executed_functions.." tested functions do not exist in the source code of the package.")
	else
		printNote("All "..ut.executed_functions.." tested functions exist in the source code of the package.")
	end

	if ut.functions_with_global_variables == 1 then
		printError("One out of "..ut.executed_functions.." tested functions creates or updates some global variable.")
	elseif ut.functions_with_global_variables > 1 then
		printError(ut.functions_with_global_variables.." out of "..ut.executed_functions.." tested functions create or update some global variable.")
	else
		printNote("No tested function creates or updates any global variable.")
	end

	if ut.print_calls == 1 then
		printError("One print call was found in the tests.")
	elseif ut.print_calls > 1 then
		printError(ut.print_calls.." print calls were found in the tests.")
	else
		printNote("No function prints any text on the screen.")
	end

	if ut.wrong_file == 1 then
		printError("One assertError() call has an error message pointing to an internal file (wrong level).")
	elseif ut.wrong_file > 1 then
		printError(ut.wrong_file.." assertError() calls have error messages pointing to an internal file (wrong level).")
	else
		printNote("No assertError() calls have error messages pointing to internal files.")
	end

	if check_functions then
		if ut.functions_not_tested == 1 then
			printError("One out of "..ut.package_functions.." source code functions was not tested.")
		elseif ut.functions_not_tested > 1 then
			printError(ut.functions_not_tested.." out of "..ut.package_functions.." source code functions were not tested.")
		else
			printNote("All "..ut.package_functions.." functions of the package were tested.")
		end
	else
		printWarning("No source code functions were verified.")
	end

	if data.lines then
		if ut.lines_not_executed == 1 then
			printError("One line from the source code was not executed at least once.")
		elseif ut.lines_not_executed > 1 then
			printError(ut.lines_not_executed.." lines from the source code were not executed at least once.")
		else
			printNote("All lines from the source code were executed.")
		end
	else
		printWarning("No lines from the source code were verified.")
	end

	if ut.snapshots > 0 then
		if ut.snapshot_files == 1 then
			printError("One snapshot file was created. Please run the tests again.")
		elseif ut.snapshot_files > 1 then
			printError(ut.snapshot_files.." snapshot files were created. Please run the tests again.")
		else
			printNote("No new snapshot file was created.")
		end

		if ut.unused_snapshot_files == 1 then
			printError("One file from folder 'snapshots' was not used.")
		elseif ut.unused_snapshot_files > 1 then
			printError(ut.unused_snapshot_files.." files from folder 'snapshots' were not used.")
		else
			printNote("All snapshot files were used in the tests.")
		end
	else
		printWarning("No snapshot test was executed.")
	end

	if data.examples then
		if ut.examples == 0 then
			printError("No examples were found.")
		elseif ut.examples_error == 0 then
			printNote("All "..ut.examples.." examples were successfully executed.")
		elseif ut.examples_error == 1 then
			printError("One error was found in the "..ut.examples.." examples.")
		else
			printError(ut.examples_error.." errors were found in the "..ut.examples.." examples.")
		end

		if ut.log_files == 1 then
			printError("One log file was created in the examples. Please run the tests again.")
		elseif ut.log_files > 1 then
			printError(ut.log_files.." log files were created in the examples. Please run the tests again.")
		else
			printNote("No new log file was created.")
		end
	else
		printWarning("No examples were executed.")
	end

	local errors = -ut.examples -ut.executed_functions -ut.test -ut.success
	               -ut.snapshots - ut.package_functions - ut.delayed_time -ut.sleep

	forEachElement(ut, function(_, value, mtype)
		if mtype == "number" then
			errors = errors + value
		end
	end)

	if errors == 0 then
		printNote("Summing up, all tests were successfully executed.")
	elseif errors == 1 then
		printError("Summing up, one problem was found during the tests.")
	else
		printError("Summing up, "..errors.." problems were found during the tests.")
	end

	return errors
end

