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

-- find the directories inside a package that contain
-- lua files, starting from package/tests
local function testdirectories(directory, ut)
	local result = {}

	local lf 
	lf = function(mdirectory)
		local found_file = false
		local found_directory = false
		forEachFile(mdirectory, function(value)
			if value:extension() == "lua" then
				if not found_file then
					found_file = true
					table.insert(result, mdirectory)
				end
			else
				printError("'"..value.."' is not a directory neither a .lua file and will be ignored.")
				ut.invalid_test_file = ut.invalid_test_file + 1
			end
		end)

		forEachDirectory(mdirectory, function(value)
			lf(value)
			found_directory = true
		end)

		if not found_file and not found_directory then
			printError("Directory '"..mdirectory.."' is empty.")
			ut.invalid_test_file = ut.invalid_test_file + 1
		end
	end

	lf(Directory(directory.."tests"))

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
			mtable[count] = 0
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

			local c = string.sub(line, pos, pos)

			if state == "code" then
				if c == "" then
					break
				elseif c == "-" then
					state = "-"
				elseif c ~= " " and c ~= "\t" then
					mtable[count] = 0
					break
				end
			elseif state == "-" then
				if c == "-" then
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

	local load_file = baseDir.."load.lua"
	local load_sequence

	if File(load_file):exists() then
		-- the 'include' below does not need to be inside a xpcall because
		-- the package was already loaded with success
		load_sequence = _Gtme.include(load_file).files
	else
		load_sequence = {}
		forEachFile(baseDir.."lua", function(file)
			if file:extension() == "lua" then
				table.insert(load_sequence, file:name())
			end
		end)
	end

	local testlines = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for _, file in ipairs(load_sequence) do
		-- the 'include' below does not need to be inside a xpcall because
		-- the package was already loaded with success
		testlines[file] = lineTable(baseDir.."lua"..s..file)

		local function trace(_, line)
			testlines[file][line] = 1
		end

		debug.sethook(trace, "l")
		dofile(baseDir.."lua"..s..file)
		debug.sethook()
	end

	return testlines
end

function _Gtme.executeTests(package, fileName)
	local initialTime = os.clock()
	local s = sessionInfo().separator

	local data

	if type(fileName) == "string" then
		printNote("Loading configuration file '".._Gtme.makePathCompatibleToAllOS(fileName).."'")

		xpcall(function() data = _Gtme.include(fileName) end, function(err)
			printError(err)
			os.exit(1)
		end)

		if getn(data) == 0 then
			printError("File "..fileName.." is empty. Please use at least one variable from {'examples', 'directory', 'file', 'lines', 'notest', 'time', 'test'}.")
			os.exit(1)
		end

		if type(data.directory) == "string" then
			data.directory = {data.directory}
		elseif data.directory ~= nil and type(data.directory) ~= "table" then
			customError("'directory' should be string, table, or nil, got "..type(data.directory)..".")
		end

		if type(data.file) == "string" then
			data.file = {data.file}
		elseif type(data.file) ~= "table" and data.file ~= nil then
			customError("'file' should be string, table, or nil, got "..type(data.file)..".")
		end

		if data.test and data.notest then
			customError("It is not possible to use 'test' and 'notest' at the same time.")
		end

		if type(data.test) == "string" then
			data.test = {data.test}
		elseif type(data.test) ~= "table" and data.test ~= nil then
			customError("'test' should be string, table, or nil, got "..type(data.test)..".")
		end

		if type(data.notest) == "string" then
			data.notest = {[data.notest] = true}
		elseif type(data.notest) ~= "table" and data.notest ~= nil then
			customError("'notest' should be string, table, or nil, got "..type(data.notest)..".")
		elseif type(data.notest) == "table" then
			local notest = {}

			forEachElement(data.notest, function(_, value)
				notest[value] = true
			end)

			data.notest = notest
		else -- nil
			data.notest = {}
		end

		if data.examples ~= nil and type(data.examples) ~= "boolean" then
			customError("'examples' should be boolean or nil, got "..type(data.examples)..".")
		end

		if data.time ~= nil then
			if type(data.time) ~= "boolean" then
				customError("'time' should be boolean or nil, got "..type(data.time)..".")
			end
		end

		if data.lines ~= nil then
			if type(data.lines) ~= "boolean" then
				customError("'lines' should be boolean or nil, got "..type(data.lines)..".")
			elseif data.test ~= nil or data.directory ~= nil then
				customError("'lines' cannot be used with 'test' or 'directory'.")
			end
		end

		verifyUnnecessaryArguments(data, {"directory", "file", "test", "notest", "examples", "lines", 'time'})
	else
		data = {notest = {}}
	end

	data.log = Directory(packageInfo(package).path.."log"..s..sessionInfo().system)

	if data.log:exists() then
		printNote("Using log directory '"..data.log.."'")
	else
		data.log = Directory(packageInfo(package).path..s.."log")

		if data.log:exists() then
			printNote("Using log directory '"..data.log.."'")
		else
			printNote("Creating log directory in '"..data.log.."'")
			data.log:create()
		end
	end

	local check_functions = data.directory == nil and data.test == nil and getn(data.notest) == 0
	local check_logs = data.directory == nil and data.test == nil and data.file == nil and 
	                   getn(data.notest) == 0 and data.examples ~= false

	if data.examples == nil then
		data.examples = check_functions and data.file == nil
	end

	local ut = UnitTest{
		log = data.log,
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
		invalid_test_file = 0,
		print_when_loading = 0,
		logs = 0,
		created_logs = 0,
		lines_not_executed = 0,
		asserts_not_executed = 0,
		overwritten_variables = 0,
		unused_log_files = 0,
		files_created = 0
	}

	if not isLoaded("base") and package ~= "base" then
		import("base")
	end

	printNote("Loading package '"..package.."'")
	print = function(arg)
		ut.print_when_loading = ut.print_when_loading + 1

		printError("Error: print() call detected with argument '"..tostring(arg).."'")
	end

	local overwritten

	xpcall(function() _, overwritten = _G.getPackage(package) end, function(err)
		printError("Package '"..package.."' could not be loaded.")
		printError(_Gtme.traceback(err))
		os.exit(1)
	end)

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

	local baseDir = packageInfo(package).path

	doc_functions = luadocMain(baseDir, Directory(baseDir.."lua"):list(), {}, package, {}, {}, {}, true)

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
			if midx == "#"  then midx = "__len"    end
			if midx == ".." then midx = "__concat" end

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

	if not Directory(baseDir.."tests"):exists() then
		printError("Directory 'tests' does not exist in package '"..package.."'")
		printError("Please run 'terrame -package "..package.." -sketch' to create test files.")
		os.exit(1)
	end

	local executionlines

	if data.lines then
		printNote("Looking for lines of source code")
		executionlines = buildLineTable(package)
	else
		printWarning("Skip looking for lines of source code")
	end

	print = _Gtme.print

	local tf = testdirectories(baseDir, ut)

	-- Check every selected directory
	if data.directory == nil then
		data.directory = tf
	else -- table
		local mdirectory = data.directory
		data.directory = {}

		local found = {}
		forEachElement(mdirectory, function(_, value)
			found[value] = false
		end)

		forEachElement(tf, function(_, value)
			forEachElement(mdirectory, function(_, mvalue)
				local cvalue  = tostring(value)
				local cmvalue = _Gtme.makePathCompatibleToAllOS(mvalue)

				if string.match(cvalue, cmvalue) and not belong(value, data.directory) then
					table.insert(data.directory, value)
					found[mvalue] = true
					return false
				end
			end)
		end)

		forEachElement(mdirectory, function(_, value)
			if not found[value] then
				printError("Could not find any directory for pattern '"..value.."'.")
				os.exit(1)
			end
		end)
	end

	if #data.directory == 0 then
		customError("Could not find any directory to be tested according to the value of 'directory'.")
		os.exit(1)
	end

	local global_variables = {}
	local global_values = {}
	forEachElement(_G, function(idx, value, mtype)
		global_variables[idx] = mtype
		global_values[idx] = value
	end)

	local myTests
	local myFiles

	local filesDir = {}

	forEachFile(".", function(file)
		filesDir[file:name()] = true
	end)

	-- For each test in each file in each directory, execute the test
	forEachElement(data.directory, function(_, eachDirectory)
		local dirFiles = eachDirectory:list()

		if dirFiles == nil then return end

		myFiles = {}
		if type(data.file) == "table" then
			forEachElement(dirFiles, function(_, value)
				forEachElement(data.file, function(_, mfile)
					if string.match(value, mfile) and not myFiles[value] then
						myFiles[value] = true
					end
				end)
			end)
		else -- nil
			forEachElement(dirFiles, function(_, value)
				if string.endswith(value, ".lua") then
					myFiles[value] = true
				end
			end)
		end

		forEachOrderedElement(myFiles, function(eachFile)
			ut.current_file = eachDirectory:relativePath(baseDir).."/"..eachFile
			local tests

			local printTesting = false

			print = function(arg)
				ut.print_calls = ut.print_calls + 1

				if not printTesting then
					printNote("Testing "..ut.current_file)
					printTesting = true
				end

				printError("Error: print() call detected with argument '"..tostring(arg).."'")
			end

			xpcall(function() tests = dofile(eachDirectory.."/"..eachFile) end, function(err)
				if not printTesting then
					printNote("Testing "..ut.current_file)
					printTesting = true
				end

				printError("Could not load file "..err)
				os.exit(1)
			end)

			print = _Gtme.print

			local myAssertTable = assertTable(eachDirectory..s..eachFile)

			if type(tests) ~= "table" or getn(tests) == 0 then
				if not printTesting then
					printNote("Testing "..ut.current_file)
					printTesting = true
				end

				printError("The file does not implement any test.")
				os.exit(1)
			end

			myTests = {}
			if data.test == nil then
				forEachOrderedElement(tests, function(index)
					if not data.notest[index] then
						table.insert(myTests, index)
					end
				end)
			else -- table
				forEachElement(data.test, function(_, value)
					if tests[value] then
						table.insert(myTests, value)
					end
				end)
			end

			if #myTests > 0 and not printTesting then
				printNote("Testing "..ut.current_file)
			end

			local shortSrcs = {}

			local function trace(_, line)
				local ss = debug.getinfo(2).short_src

				local currentShortSrc = shortSrcs[ss]

				if not currentShortSrc then
					local mss = _Gtme.makePathCompatibleToAllOS(ss)

					currentShortSrc = {
						short = string.match(mss, "([^/]-)$"),
						matchTests = string.match(mss, "tests")
					}

					shortSrcs[ss] = currentShortSrc
				end

				if currentShortSrc.short == eachFile and currentShortSrc.matchTests then
					if myAssertTable[line] then
						myAssertTable[line] = myAssertTable[line] + 1
					end
				end

				if data.lines and currentShortSrc.short == eachFile and not currentShortSrc.matchTests then
					if executionlines[eachFile] then
						if executionlines[eachFile][line] then
							executionlines[eachFile][line] = executionlines[eachFile][line] + 1
						end
					end
				end
			end

			for _, eachTest in ipairs(myTests) do
				print("Testing "..eachTest)
				Random{seed = 987654321}
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
					printError("Error: print() call detected with argument '"..tostring(arg).."'")
				end

				local found_error = false

				local testInitialTime = os.clock()

				xpcall(function() tests[eachTest](ut) end, function(err)
					ut.functions_with_error = ut.functions_with_error + 1
					printError("Wrong execution, got:\n".._Gtme.traceback(err))
					found_error = true
				end)

				if data.time then
					local testFinalTime = os.clock()
					local difference = testFinalTime - testInitialTime

					local text = "Test executed in "..round(difference, 1).." seconds"

					if difference > 30 then
						_Gtme.print("\027[00;37;41m"..text.."\027[00m")
					elseif difference > 10 then
						_Gtme.print("\027[00;37;43m"..text.."\027[00m")
					elseif difference > 1 then
						_Gtme.print("\027[00;37;42m"..text.."\027[00m")
					end
				end

				print = _Gtme.print

				forEachFile(".", function(file)
					if filesDir[file:name()] == nil then
						printError("File '"..file.."' was created along the test.")
						filesDir[file:name()] = true
						ut.files_created = ut.files_created + 1
					end
				end)

				clean()
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

			if #myTests > 0 then
				if data.test or getn(data.notest) > 0 then
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
	end) 

	if ut.test == 0 and not data.examples then
		printError("No test was executed. Aborting.")
		os.exit(1)
	end

	-- checking if all source code functions were tested
	if check_functions then
		printNote("Checking if functions from source code were tested")
		if type(data.file) == "table" then
			local found = {}
			forEachElement(data.file, function(_, value)
				found[value] = false
			end)

			forEachOrderedElement(data.file, function(_, value)
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
			forEachOrderedElement(data.file, function(_, value)
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
				forEachOrderedElement(mvalue, function(midx, value)
					if value == 0 then
						printError("Line "..midx.." was not executed.")
						ut.lines_not_executed = ut.lines_not_executed + 1
					end
				end)
			end)
		end
	else
		printWarning("Skipping lines of source code check")
	end

	-- executing examples
	if data.examples then
		printNote("Testing examples")
		local dirFiles = _Gtme.findExamples(package)
		if #dirFiles > 0 then
			forEachElement(dirFiles, function(_, value)
				print("Testing "..value)
				if not doc_functions then io.flush() end -- theck why it is necessary to have the 'if'
				Random{seed = 987654321}

				local logfile
				print = function(x)
					if not logfile then
						local lfilename = value..".log"

						logfile = io.open(lfilename, "w")
					end

					logfile:write(x.."\n")
				end

				collectgarbage("collect")
				
				ut.examples = ut.examples + 1

				_Gtme.loadedPackages[package] = nil

				local myfunc = function()
					local env = setmetatable({}, {__index = _G})
					-- loadfile is necessary to avoid any global variable from one
					-- example affect another example
					local result, err = loadfile(baseDir.."examples"..s..value..".lua", 't', env)

					if not result then
						printError(err)
						ut.examples_error = ut.examples_error + 1
					else
						return result()
					end
				end

				xpcall(myfunc, function(err)
					ut.examples_error = ut.examples_error + 1
					printError("Error in example: ".._Gtme.traceback(err))
				end)

				print = _Gtme.print

				if logfile ~= nil then
					io.close(logfile)

					local test = ut.test
					local success = ut.success
					local fail = ut.fail 

					if File(value..".log"):exists() then
						ut:assertFile(value..".log")
					else
						printError("Error: Could not find log file "..value..".log. Possibly the example is handling temporary folders in a wrong way.")
						test = test + 1
						fail = fail + 1
					end

					ut.test = test
					ut.success = success
					ut.fail = fail
				end

				clean()
			end)
		else
			printWarning("The package has no examples")
		end
	else
		printWarning("Skipping examples")
	end

	if ut.logs > 0 and check_logs then
		printNote("Checking logs")
		local mdir = data.log:list()

		local path = "log/"
		if string.endswith(tostring(data.log), sessionInfo().system) then
			path = path..sessionInfo().system.."/"
		end

		forEachElement(mdir, function(_, value)
			if not ut.tlogs[value] then
				printError("File '"..path..value.."' was not used by any assert.")
				ut.unused_log_files = ut.unused_log_files + 1
			end
		end)
	else
		printWarning("Skipping logs check")
	end

	local finalTime = os.clock()

	print("\nFunctional test report for package '"..package.."':")

	local text = "Tests were executed in "..round(finalTime - initialTime, 2).." seconds."
	printNote(text)

	if ut.logs > 0 then
		printNote("Logs were saved in '"..ut.tmpdir.."'.")
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
		printError("One invalid file or directory was found in directory 'test'.")
	elseif ut.invalid_test_file > 1 then
		printError(""..ut.invalid_test_file.." invalid files or directories were found in directory 'test'.")
	else
		printNote("There are no invalid files or directories in directory 'tests'.")
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

	if ut.files_created == 1 then
		printError("One file was created along the tests.")
	elseif ut.files_created > 1 then
		printError(ut.files_created.." files were created along the tests.")
	else
		printNote("No file was created along the tests.")
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

	if data.examples then
		if ut.examples == 0 then
			printWarning("The package has no examples.")
		elseif ut.examples_error == 0 then
			printNote("All "..ut.examples.." examples were successfully executed.")
		elseif ut.examples_error == 1 then
			printError("One error was found in the "..ut.examples.." examples.")
		else
			printError(ut.examples_error.." errors were found in the "..ut.examples.." examples.")
		end
	else
		printWarning("No examples were executed.")
	end

	if ut.logs > 0 then
		if ut.created_logs == 1 then
			printError("One log file was created. Please run the tests again.")
		elseif ut.created_logs > 1 then
			printError(ut.created_logs.." log files were created. Please run the tests again.")
		else
			printNote("No new log file was created.")
		end

		if ut.unused_log_files == 1 then
			printError("One file from directory 'log/"..sessionInfo().system.."' was not used.")
		elseif ut.unused_log_files > 1 then
			printError(ut.unused_log_files.." files from directory 'log/"..sessionInfo().system.."' were not used.")
		else
			printNote("All log files were used in the tests.")
		end
	else
		printWarning("No log test was executed.")
	end

	local errors = -ut.examples -ut.executed_functions -ut.test -ut.success
	               -ut.logs - ut.package_functions

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

	if errors > 255 then errors = 255 end

	return errors
end

