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

-- find the folders inside a package that contain
-- lua files, starting from package/tests
local function testfolders(folder, ut)
	local result = {}

	local s = sessionInfo().separator

	local lf 
	lf = function(mfolder)
		local parentFolders = dir(folder..s..mfolder)
		local found_file = false	
		local found_folder = false	
		forEachElement(parentFolders, function(idx, value)
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

local function lineTable(filename)
	local count = 0
	local mtable = {}

	local file = io.open(filename)

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
	file:close()
	return mtable
end

local function buildLineTable(package)
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s..package

	local load_file = baseDir..s.."load.lua"
	local load_sequence

	if isFile(load_file) then
		-- the 'include' below does not need to be inside a xpcall because 
		-- the package was already loaded with success
		load_sequence = include(load_file).files
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

function executeTests(package, fileName, doc_functions)
	local initialTime = os.clock()

	local data

	if type(fileName) == "string" then
		printNote("Loading configuration file '"..fileName.."'")
	
		xpcall(function() data = include(fileName) end, function(err)
			printError(err)
			os.exit()
		end)

		if getn(data) == 0 then
			printError("File "..fileName.." is empty. Please use at least one variable from {'examples', 'folder', 'file', 'lines', 'sleep', 'test'}.")
			os.exit()
		end

		if data.folder ~= nil and type(data.folder) ~= "string" and type(data.folder) ~= "table" then
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

		checkUnnecessaryArguments(data, {"folder", "file", "test", "sleep", "examples", "lines"})
	else
		data = {}
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
		unused_snapshot_files = 0
	}

	printNote("Loading package "..package)
	print = function(...)
		ut.print_when_loading = ut.print_when_loading + 1
		printError(...)
	end

	require(package)

	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s..package
	local srcDir = baseDir..s.."tests"

	if not isFile(srcDir) then
		customError("Folder 'tests' does not exist in package '"..package.."'.")
	end

	local testfunctions = doc_functions

	if not testfunctions then
		printNote("Looking for package functions")
		testfunctions = buildCountTable(package)
	end

	local executionlines

	if data.lines then
		printNote("Looking for lines of source code")
		executionlines = buildLineTable(package)
	end

	print = print__

	local tf = testfolders(baseDir, ut)

	-- Check every selected folder
	if type(data.folder) == "string" then 
		local mfolder = data.folder
		data.folder = {}
		forEachElement(tf, function(_, value)
			if string.match(value, mfolder) then
				table.insert(data.folder, value)
			end
		end)
	elseif data.folder == nil then
		data.folder = tf
	else -- table
		local mfolder = data.folder
		data.folder = {}
		forEachElement(tf, function(_, value)
			forEachElement(mfolder, function(_, mvalue)
				if string.match(value, mvalue) and not found then
					table.insert(data.folder, value)
					return false
				end
			end)
		end)
	end

	if #data.folder == 0 then
		customError("Could not find any folder to be tested according to the value of 'folder'.")
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
				myFiles[#myFiles + 1] = value
			end)
		end

		if #myFiles == 0 then
			printWarning("Skipping folder "..eachFolder)
		end

		for _, eachFile in ipairs(myFiles) do
			ut.current_file = eachFolder..s..eachFile
			local tests
			xpcall(function() tests = dofile(baseDir..s..eachFolder..s..eachFile) end, function(err)
				printNote("Testing "..eachFolder..s..eachFile)
				printError("Could not load file "..err)
				os.exit()
			end)

			if type(tests) ~= "table" or getn(tests) == 0 then
				printNote("Testing "..eachFolder..s..eachFile)
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

			if #myTests > 0 then
				printNote("Testing "..eachFolder..s..eachFile)
			else
				printWarning("Skipping "..eachFolder..s..eachFile)
			end

			local function trace(event, line)
				local s = debug.getinfo(2).short_src
				local short = string.match(s, "([^/]-)$")

				if data.lines and short == eachFile and not string.match(s, "tests") then
					if not executionlines[eachFile][line] then
						--printNote(line)
					else
						executionlines[eachFile][line] = executionlines[eachFile][line] + 1
					end
				end
			end

			for _, eachTest in ipairs(myTests) do
				print("Testing "..eachTest)
				debug.sethook(trace, "l")
				if not doc_functions then io.flush() end -- theck why it is necessary to have the 'if'

				if testfunctions[eachFile] then
					if testfunctions[eachFile][eachTest] then
						testfunctions[eachFile][eachTest] = testfunctions[eachFile][eachTest] + 1
					else
						printError("Function does not exist in the respective file in the source code.")
						ut.functions_not_exist = ut.functions_not_exist + 1
					end
				end

				local count_test = ut.test

				collectgarbage("collect")

				print = function(...)
					ut.print_calls = ut.print_calls + 1
					printError(...)
				end

				local found_error = false
				xpcall(function() tests[eachTest](ut) end, function(err)
					printError("Wrong execution, got error: '"..err.."'.")
					ut.functions_with_error = ut.functions_with_error + 1
					local tb = traceback()
					if tb ~= "" then
						printError(tb)
					end
					found_error = true
				end)

				print = print__

				killAllObservers()
				ut.executed_functions = ut.executed_functions + 1

				if count_test == ut.test and not found_error then
					printError("No asserts were found in the test.")
					ut.functions_without_assert = ut.functions_without_assert + 1
				end

				local variables = ""
				local pvariables = {}
				local rvariables = ""
				local rpvariables = {}

				forEachElement(_G, function(idx, _, mtype)
					if global_variables[idx] == nil then
						variables = variables.."'"..idx.."' ("..mtype.."), "
						pvariables[#pvariables + 1] = idx
					elseif global_variables[idx] ~= mtype then
						rvariables = rvariables.."'"..idx.."' (changed from "..global_variables[idx].." to "..mtype.."), "
						rpvariables[#rpvariables + 1] = idx
					end
				end)

				if variables ~= "" then
					variables = variables:sub(1, variables:len() - 2).."."
					printError("Test creates global variable(s): "..variables)

					-- we need to delete the global variables created in order to ensure that a 
					-- new error will be generated if this variable is found again. This need
					-- to be done here because we cannot change _G inside a forEachElement
					-- traversing _G
					forEachElement(pvariables, function(_, value)
						_G[value] = nil
					end)
				end

				if rvariables ~= "" then
					rvariables = rvariables:sub(1, rvariables:len() - 2).."."
					printError("Test updates global variable(s): "..rvariables)

					-- same reason as above
					forEachElement(rpvariables, function(_, value)
						_G[value] = global_values[value]
					end)
				end

				if variables ~= "" or rvariables ~= "" then
					ut.functions_with_global_variables = ut.functions_with_global_variables + 1
				end

				if ut.count_last > 0 then
					printError("[The error above occurs "..ut.count_last.." more times.]")
					ut.count_last = 0
					ut.last_error = ""
				end
			end
			debug.sethook()
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
			forEachOrderedElement(data.file, function(idx, value)
				forEachElement(testfunctions, function(midx, mvalue)
					if not string.match(midx, value) then return end

					print("Checking "..midx)
					forEachElement(mvalue, function(mmidx, mmvalue)
						ut.package_functions = ut.package_functions + 1
						if mmvalue == 0 then
							printError("Function '"..mmidx.."' was not tested.")
							ut.functions_not_tested = ut.functions_not_tested + 1
						end
					end)
				end)
			end)
		else -- nil
			forEachOrderedElement(testfunctions, function(idx, value)
				print("Checking "..idx)
				forEachElement(value, function(midx, mvalue)
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
					forEachElement(mvalue, function(mmidx, mmvalue)
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
		local mdir = dir(sessionInfo().path..s.."packages"..s..package..s.."snapshots")

		forEachElement(mdir, function(_, value)
			if not ut.tsnapshots[value] then
				printError("File 'snapshot/"..value.."' was not used by any assert_snapshot().")
				ut.unused_snapshot_files = ut.unused_snapshot_files + 1
			end
		end)
	else
		printWarning("Skipping snapthots check")
	end

	-- executing examples
	if data.examples then
		printNote("Testing examples")
		local dirFiles = exampleFiles(package)
		if dirFiles ~= nil then
			forEachElement(dirFiles, function(idx, value)
				print("Testing "..value)
				if not doc_functions then io.flush() end -- theck why it is necessary to have the 'if'

				local logfile = nil
				local writing_log = false
				print = function(x)
					if not logfile then
						local lfilename = string.sub(value, 0, string.len(value) - 3).."log"

						logfile = io.open(baseDir..s.."examples"..s..lfilename, "r")
						if logfile == nil then
							printWarning("Creating log file "..lfilename)
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
							printError("Different strings:")
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
					loadfile(baseDir..s.."examples"..s..value, 't', env)()
				end
				xpcall(myfunc, function(err)
					ut.examples_error = ut.examples_error + 1
					printError(err)
					printError(traceback())
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

				print = print__

				killAllObservers()
			end)
		end
	else
		printWarning("Skipping examples")
	end

	local finalTime = os.clock()

	print("\nReport:")

	local text = "Tests were executed in "..round(finalTime - initialTime, 2).." seconds"
	if ut.delayed_time > 0 then
		text = text.." ("..ut.delayed_time.. " seconds sleeping)."
	else
		text = text.."."
	end
	printNote(text)

	if ut.print_when_loading > 0 then
		printError(ut.print_when_loading.." print calls were found when loading the package.")
	else
		printNote("No print calls were found when loading the package.")
	end

	if ut.invalid_test_file > 0 then
		printError("There are "..ut.invalid_test_file.." invalid files or folders in folder 'test'.")
	else
		printNote("There are no invalid files or folders in folder 'tests'.")
	end

	if ut.fail > 0 then
		printError(ut.fail.." out of "..ut.test.." asserts failed.")
	else
		printNote("All "..ut.test.." asserts were executed successfully.")
	end

	if ut.functions_with_error > 0 then
		printError(ut.functions_with_error.." out of "..ut.executed_functions.." tested functions stopped with an unexpected error.")
	else
		printNote("All "..ut.executed_functions.." tested functions do not have any unexpected execution error.")
	end

	if ut.functions_without_assert > 0 then
		printError(ut.functions_without_assert.." out of "..ut.executed_functions.." tested functions do not have at least one assert.")
	else
		printNote("All "..ut.executed_functions.." tested functions have at least one assert.")
	end

	if ut.functions_not_exist > 0 then
		printError(ut.functions_not_exist.." out of "..ut.executed_functions.." tested functions do not exist in the source code of the package.")
	else
		printNote("All "..ut.executed_functions.." tested functions exist in the source code of the package.")
	end

	if ut.functions_with_global_variables > 0 then
		printError(ut.functions_with_global_variables.." out of "..ut.executed_functions.." tested functions create or update some global variable.")
	else
		printNote("No tested function creates or updates any global variable.")
	end

	if ut.print_calls > 0 then
		printError(ut.print_calls.." print calls were found in the tests.")
	else
		printNote("No function prints any text on the screen.")
	end

	if ut.wrong_file > 0 then
		printError(ut.wrong_file.." assert_error calls found an error message pointing to an internal file (wrong level).")
	else
		printNote("No assert_error calls had error messages pointing to internal files.")
	end

	if check_functions then
		if ut.functions_not_tested > 0 then
			printError(ut.functions_not_tested.." out of "..ut.package_functions.." source code functions were not tested.")
		else
			printNote("All "..ut.package_functions.." functions of the package were tested.")
		end
	else
		printWarning("No source code functions were verified.")
	end

	if data.lines then
		if ut.lines_not_executed > 0 then
			printError(ut.lines_not_executed.." lines of source code were not executed at least once.")
		else
			printNote("All lines of the source code were executed.")
		end
	else
		printWarning("No lines of source code were verified.")
	end

	if ut.snapshots > 0 then
		printNote("Snapshots were saved in '"..ut:tmpFolder().."'.")
		if ut.snapshot_files > 0 then
			printError(ut.snapshot_files.." snapshots were created. Please run the tests again.")
		else
			printNote("No new snapshot was created.")
		end

		if ut.unused_snapshot_files > 0 then
			printError(ut.unused_snapshot_files.." files from snapshot folder were not used.")
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
		else
			printError(ut.examples_error.." errors were found in the "..ut.examples.." examples.")
		end

		if ut.log_files > 0 then
			printError(ut.log_files.." log files were created in the examples. Please run the tests again.")
		else
			printNote("No new log file was created.")
		end
	else
		printWarning("No examples were executed.")
	end

	local errors = ut.fail + ut.functions_not_exist + ut.functions_not_tested + ut.examples_error + 
	               ut.wrong_file + ut.print_calls + ut.functions_with_global_variables + 
	               ut.functions_with_error + ut.functions_without_assert + ut.snapshot_files +
				   ut.unused_snapshot_files + ut.lines_not_executed

	if errors == 0 then
		printNote("Summing up, all tests were successfully executed.")
	elseif errors == 1 then
		printError("Summing up, one problem was found during the tests.")
	else
		printError("Summing up, "..errors.." problems were found during the tests.")
	end

	return errors
end

