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

if os.setlocale(nil, "all") ~= "C" then os.setlocale("C", "numeric") end

-- To keep compatibilities with old versions of Lua
--if _VERSION ~= "Lua 5.2" then
--	load = loadstring
--end	

print__ = print
local begin_red    = "\027[00;31m"
local begin_yellow = "\027[00;33m"
local begin_green  = "\027[00;32m"
local end_color    = "\027[00m"

function printError(value)
	if sessionInfo().separator == "/" then
		print__(begin_red..value..end_color)
	else
		print__(value)
	end
end

function printNote(value)
	if sessionInfo().separator == "/" then
		print__(begin_green..value..end_color)
	else
		print__(value)
	end
end

function printWarning(value)
	if sessionInfo().separator == "/" then
		print__(begin_yellow..value..end_color)
	else
		print__(value)
	end
end

-- from http://stackoverflow.com/questions/17673657/loading-a-file-and-returning-its-environment
function include(scriptfile)
	local env = setmetatable({}, {__index = _G})
	if not isfile(scriptfile) then
		customError("File '"..scriptfile.."' does not exist.")
	end
	loadfile(scriptfile, 't', env)() 

	return setmetatable(env, nil)
end

type__ = type

local function sqlFiles(package)
	local s = sessionInfo().separator
	local files = {}
	data = function(mtable)
		if type(mtable.file) == "string" then mtable.file = {mtable.file} end

		forEachElement(mtable.file, function(_, mfile)
			if string.endswith(mfile, ".sql") then
				table.insert(files, mfile)
			end
		end)
	end

	xpcall(function() dofile(sessionInfo().path..s.."packages"..s..package..s.."data.lua") end, function(err)
		printError("Error loading "..package..s.."data.lua")
		printError(err)
		os.exit()
	end)

	return files
end

local function examples(package)
	local s = sessionInfo().separator
	local examplespath = sessionInfo().path..s.."packages"..s..package..s.."examples"

	if attributes(examplespath, "mode") ~= "directory" then
		printError("examples is not a directory")
		os.exit()
	end

	local files = dir(examplespath)
	local result = {}

	forEachElement(files, function(_, fname)
		if string.endswith(fname, ".lua") then
			table.insert(result, fname)
		elseif not string.endswith(fname, ".tme") and not string.endswith(fname, ".log") then
			printWarning("Test file '"..fname.."' does not have a valid extension")
		end
	end)
	return result
end

local function exportDatabase(package)
	local s = sessionInfo().separator

	local config = getConfig()

	local user = config.user
	local password = config.password
	local host = config.host
	local drop = config.drop

	local command = "mysqldump"

	if user then
		command = command.." -u"..user
	else
		command = command.." -u root"
	end

	if password and password ~= "" then
		command = command.." -p="..password
	end

	if host then
		command = command.." -h="..host
	end

	local folder = packageInfo(package).data
	local files = sqlFiles(package)

	forEachElement(files, function(_, mfile)
		local database = string.sub(mfile, 1, string.len(mfile) - 4)

		if isfile(sessionInfo().path..s.."packages"..s..package..s.."data"..s..mfile) then
			printWarning("File "..mfile.." already exists and will not be replaced")
		else
			printNote("Exporting database "..database)
			local result = runCommand(command.." "..database.." > "..folder..mfile, 2)

			if result and result[1] then
				printError(result[1])
				os.execute("rm "..folder..mfile)
			else
				printNote("Database '"..database.."'successfully exported")
			end
		end
	end)
end

local function importDatabase(package)
	local s = sessionInfo().separator

	local config = getConfig()

	local user = config.user
	local password = config.password
	local host = config.host
	local drop = config.drop

	local command = "mysql"

	if user then
		command = command.." -u"..user
	else
		command = command.." -u root"
	end

	if password and password ~= "" then
		command = command.." -p"..password
	end

	if host then
		command = command.." -h"..host
	end

	local folder = packageInfo(package).data
	local files = sqlFiles(package)

	forEachElement(files, function(_, value)
		local database = string.sub(value, 1, string.len(value) - 4)

		if drop then
			printNote("Deleting database '"..database.."'")
			local result = runCommand(command.." -e \"drop database "..database.."\"", 2)
		end

		printNote("Creating database '"..database.."'")
		local result = runCommand(command.." -e \"create database "..database.."\"", 2)
		if result and result[1] then
			printError(result[1])
			printError("Add 'drop = true' to your config.lua to allow replacing databases if needed.")
		else
			printNote("Importing database '"..database.."'")
			os.execute(command .." "..database.." < "..folder..value)
			printNote("Database '"..database.."' successfully imported")
		end
	end)
end

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

local function executeDoc(package)
	local initialTime = os.clock()

	require("base")
	require("luadoc")

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	xpcall(function() require(package) end, function(err)
		printError("Package could "..package.." not be loaded.")
		printError(err)
		os.exit()
	end)

	local lua_files = dir(package_path..s.."lua")

	local example_files = examples(package)

	local doc_report = {
		parameters = 0,
		lua_files = 0,
		html_files = 0,
		global_functions = 0,
		functions = 0,
		variables = 0,
		links = 0,
		examples = 0,
		wrong_description = 0,
		undoc_param = 0,
		undefined_param = 0,
		unused_param = 0,
		undoc_files = 0,
		lack_usage = 0,
		block_name_conflict = 0,
		no_call_itself_usage = 0,
		non_doc_functions = 0,
		wrong_links = 0,
		invalid_tags = 0,
		problem_examples = 0, 
		undoc_examples = 0
	}

	luadocMain(package_path, lua_files, example_files, package, doc_report)

	local finalTime = os.clock()

	print("\nReport:")
	printNote("Documentation was built in "..round(finalTime - initialTime, 2).." seconds.")

	if doc_report.undoc_files == 0 then
		printNote(doc_report.html_files.." HTML files were created.")
	else
		printError(doc_report.undoc_files.." out of "..doc_report.lua_files.." files are not documented.")
	end

	if doc_report.wrong_description == 0 then
		printNote("All fields of 'description.lua' are correct.")
	else
		printError(doc_report.wrong_description.." problems were found in 'description.lua'")
	end

	if doc_report.non_doc_functions == 0 then
		printNote("All "..doc_report.functions.." functions of the package are documented.")
	else
		printError(doc_report.non_doc_functions.." out of "..doc_report.functions.." functions are not documented.")
	end

	if doc_report.block_name_conflict == 0 then
		printNote("No block name conflicts were found.")
	else
		printError(doc_report.block_name_conflict.." functions were documented with a different name.")
	end

	if doc_report.undoc_param == 0 then
		printNote("All "..doc_report.parameters.." parameters are documented.")
	else
		printError(doc_report.undoc_param.." parameters are not documented.")
	end

	if doc_report.undefined_param == 0 then
		printNote("No undefined parameters were found.")
	else
		printError(doc_report.undefined_param.." undefined parameters were found.")
	end

	if doc_report.unused_param == 0 then
		printNote("All "..doc_report.parameters.." parameters are used in the HTML tables.")
	else
		printError(doc_report.unused_param.." table parameters are not used in the HTML tables.")
	end

	if doc_report.lack_usage == 0 then
		printNote("All "..doc_report.functions.." have @usage field defined.")
	else
		printError(doc_report.lack_usage.." out of "..doc_report.functions.." functions do not have @usage.")
	end

	if doc_report.no_call_itself_usage == 0 then
		printNote("All "..doc_report.functions.." documented functions call themselves in their @usage.")
	else
		printError(doc_report.no_call_itself_usage.." out of "..doc_report.functions.." documented functions do not call themselves in their @usage.")
	end

	if doc_report.invalid_tags == 0 then
		printNote("No invalid tags were found.")
	else
		printError(doc_report.invalid_tags.." invalid tags were found.")
	end

	if doc_report.wrong_links == 0 then
		printNote("All "..doc_report.links.." links were correctly built.")
	else
		printError(doc_report.wrong_links.." out of "..doc_report.links.." links are invalid.")
	end

	if doc_report.undoc_examples == 0 then
		printNote("All "..doc_report.examples.." examples are documented.")
	else
		printError(doc_report.undoc_examples.." out of "..doc_report.examples.." examples are not documented.")
	end

	if doc_report.problem_examples == 0 then
		printNote("All "..(doc_report.examples - doc_report.undoc_examples).." documented examples were correct.")
	else
		printError(doc_report.problem_examples.." problems were found in the documentation of the examples.")
	end

	local errors = doc_report.undoc_param + doc_report.unused_param + doc_report.undoc_files +
				   doc_report.lack_usage + doc_report.no_call_itself_usage + doc_report.non_doc_functions +
				   doc_report.block_name_conflict + doc_report.undefined_param + doc_report.wrong_description + 
				   doc_report.wrong_links + doc_report.problem_examples + doc_report.undoc_examples

	if errors == 0 then
		printNote("Summing up, all the documentation was successfully built.")
	elseif errors == 1 then
		printError("Summing up, one problem was found in the documentation.")
	else
		printError("Summing up, "..errors.." problems were found in the documentation.")
	end
	return errors
end

-- builds a table with zero counts for each element of the table gotten as argument
local buildCountTable = function(mtable)
	result = {}

	forEachElement(mtable, function(idx, value, mtype)
		if type__(value) == "table" then
			forEachElement(value, function(midx, mvalue, mmtype)
				if mmtype == "function" then
					result[midx] = 0
				end
			end)
		elseif mtype == "function" then
			result[idx] = 0
		end
	end)
	return result
end

local executeTests = function(package, fileName)
	local initialTime = os.clock()

	require("base")

	local data

	if type(fileName) == "string" then
		printNote("Loading configuration file '"..fileName.."'")
	
		xpcall(function() data = include(fileName) end, function(err)
			printError(err)
			os.exit()
		end)

		if getn(data) == 0 then
			printError("File "..fileName.." is empty. Please use at least one variable from {'examples', 'folder', 'file', 'sleep', 'test'}.")
			os.exit()
		end

		if data.folder ~= nil and type(data.folder) ~= "string" and type(data.folder) ~= "table" then
			customError("'folder' should be string, table, or nil, got "..type(data.folder)..".")
		end

		if data.file ~= nil and type(data.file) ~= "string" and type(data.file) ~= "table" then
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

		checkUnnecessaryParameters(data, {"folder", "file", "test", "sleep", "examples"})
	else
		data = {}
	end

	local check_functions = data.folder == nil and data.file == nil and data.test == nil
	if data.examples == nil then
		data.examples = check_functions
	end

	local ut = UnitTest{
		sleep = data.sleep,
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
		print_when_loading = 0
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

	if not isfile(srcDir) then
		customError("Folder 'tests' does not exist in package '"..package.."'.")
	end

	load_file = baseDir..s.."load.lua"
	local load_sequence

	if isfile(load_file) then
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

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		-- the 'include' below does not need to be inside a xpcall because 
		-- the package was already loaded with success
		testfunctions[file] = buildCountTable(include(baseDir..s.."lua"..s..file))
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
	elseif type(data.folder) == "table" then
		local mfolder = data.folder
		data.folder = {}
		forEachElement(tf, function(_, value)
			-- TODO: instead of using found, why not use "return false" in forEachElement?
			local found = false
			forEachElement(mfolder, function(_, mvalue)
				if string.match(value, mvalue) and not found then
					table.insert(data.folder, value)
					found = true
				end
			end)
		end)
	else
		-- TODO: I think this error will never occur because when this function reads
		-- the file it already checks this.
		customError("Parameter 'folder' is not a string, table or nil.")
	end

	if #data.folder == 0 then
		customError("Could not find any folder to be tested according to the value of 'folder'.")
	end

	local global_variables = {}
	local count_global = getn(_G)
	forEachElement(_G, function(idx)
		global_variables[idx] = true
	end)

	-- TODO: I think this warning will never occur because when this function reads
	-- the file it already checks this.
	local parameters = {"sleep", "examples", "folder", "test", "file"}
	forEachElement(data, function(value)
		if not belong(value, parameters) then
			customWarning("Attribute '"..value.."' in file '"..fileName.."' is unnecessary.")
		end
	end)

	local myTests
	local myFiles

	-- For each test in each file in each folder, execute the test
	-- TODO: change this to forEachElement...
	for _, eachFolder in ipairs(data.folder) do
		local dirFiles = dir(baseDir..s..eachFolder)
		-- TODO: ... and this to "if dirfiles == nil then return end" to avoid a scope
		-- maybe this check could be done previously, instead of here.
		if dirFiles ~= nil then 
			myFiles = {}
			if type(data.file) == "string" then
				if belong(data.file, dirFiles) then
					myFiles = {data.file}
				end
			elseif type(data.file) == "table" then
				forEachElement(dirFiles, function(_, value)
					if belong(value, data.file) then
						myFiles[#myFiles + 1] = value
					end
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

				for _, eachTest in ipairs(myTests) do
					print("Testing "..eachTest)
					io.flush()

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
						printError(traceback())
						found_error = true
					end)

					print = print__

					killAllObservers()
					ut.executed_functions = ut.executed_functions + 1

					if count_test == ut.test and not found_error then
						printError("No asserts were found in the test.")
						ut.functions_without_assert = ut.functions_without_assert + 1
					end

					if getn(_G) > count_global then
						local variables = ""
						local pvariables = {}
						forEachElement(_G, function(idx, _, mtype)
							if global_variables[idx] == nil then
								variables = variables.."'"..idx.."' ("..mtype.."), "
								pvariables[#pvariables + 1] = idx
							end
						end)
						variables = variables:sub(1, variables:len() - 2).."."
						printError("Test creates global variable(s): "..variables)
						ut.functions_with_global_variables = ut.functions_with_global_variables + 1

						-- we need to delete the global variables created in order to ensure that a 
						-- new error will be generated if this variable is found again. This need
						-- to be done here because we cannot change _G inside a forEachElement
						-- traversing _G
						forEachElement(pvariables, function(_, value)
							_G[value] = nil
						end)
					else
						ut.success = ut.success + 1
					end

					if ut.count_last > 0 then
						printError("[The error above occurs "..ut.count_last.." more times.]")
						ut.count_last = 0
						ut.last_error = ""
					end
				end
			end
		end
	end 

	-- checking if all source code functions were tested
	if check_functions then
		-- TODO: check_functions is true only when data.file == nil!!
		printNote("Checking if functions from source code were tested")
		if type(data.file) == "string" then
			print("Checking "..data.file)
			forEachElement(testfunctions[data.file], function(idx, value)
				ut.package_functions = ut.package_functions + 1
				if value == 0 then
					printError("Function '"..idx.."' was not tested.")
					ut.functions_not_tested = ut.functions_not_tested + 1
				end
			end)
		elseif type(data.file) == "table" then
			forEachOrderedElement(data.file, function(idx, value)
				print("Checking "..value)
				forEachElement(testfunctions[value], function(midx, mvalue)
					ut.package_functions = ut.package_functions + 1
					if mvalue == 0 then
						printError("Function '"..midx.."' was not tested.")
						ut.functions_not_tested = ut.functions_not_tested + 1
					end
				end)
			end)
		elseif data.file == nil then
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

	-- executing examples
	if data.examples then
		printNote("Testing examples")
		local dirFiles = examples(package)
		if dirFiles ~= nil then
			forEachElement(dirFiles, function(idx, value)
				print("Testing "..value)
				io.flush()

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
		printError(ut.functions_with_global_variables.." out of "..ut.executed_functions.." tested functions create some global variable.")
	else
		printNote("No tested function creates any global variable.")
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
	               ut.functions_with_error + ut.functions_without_assert

	if errors == 0 then
		printNote("Summing up, all tests were successfully executed.")
	elseif errors == 1 then
		printError("Summing up, one problem was found during the tests.")
	else
		printError("Summing up, "..errors.." problems were found during the tests.")
	end

	return errors
end

buildPackage = function(package)
	printNote("Testing package "..package)
	local s = sessionInfo().separator
	local testErrors
	xpcall(function() testErrors = executeTests(package) end, function(err)
		printError(err)
	end)
	if testErrors > 0 then
		printError("Build aborted due to the errors in the tests.")
		return
	end

	printNote("Building documentation for "..package)
	local docErrors
	xpcall(function() docErrors = executeDoc(package) end, function(err)
		printError(err)
	end)

	if docErrors > 0 then
		printError("Build aborted due to the errors in the documentation.")
		return
	end

	printNote("Building package "..package)
	local info = packageInfo(package)
	local file = package.."_"..info.version..".zip"
	printNote("Creating file "..file)
	local currentDir = currentdir()
	local packageDir = sessionInfo().path..s.."packages"
	chdir(packageDir)
	os.execute("zip -qr "..file.." "..package)
	if isfile(file) then
		printNote("Package "..package.." successfully built")
	end
	chdir(currentDir)
	os.execute("mv "..packageDir..s..file.." .")
end

local function installPackage(file)
	if file == nil then
		printError("You need to choose the file to be installed.")
		return
	elseif not isfile(file) then
		printError("No such file: "..file)
		return
	end

	printNote("Installing "..file)

	local s = sessionInfo().separator
	local package
	xpcall(function() package = string.sub(file, 1, string.find(file, "_") - 1) end, function(err)
		printError(file.." is not a valid file name for a TerraME package")
		os.exit()
	end)

	local param = sessionInfo().path..s.."packages"..s..package

	local currentDir = currentdir()
	local packageDir = sessionInfo().path..s.."packages"

	os.execute("cp "..file.." "..packageDir)
	chdir(packageDir)

	os.execute("unzip -q "..file)

	printNote("Trying to load package "..package)
	xpcall(function() require(package) end, function(err)
		printError("Package could not be loaded:")
		printError(err)

		os.execute("rm -rf "..package)
		os.exit()
	end)
	printNote("Package successfully installed")
	chdir(currentDir)
	os.execute("rm "..packageDir..s..file)
end


local versions = function()
	print("\nTerraME - Terra Modeling Environment")
	print(" Version: ", sessionInfo().version)
	print(" Location (TME_PATH): "..sessionInfo().path)

	-- #203

	print("\nFor more information, please visit www.terrame.org\n")
end

local usage = function()
	print("")
	print("Usage: TerraME [[-gui] | [-mode=normal|debug|quiet]] file1.lua file2.lua ...")
	print("       or TerraME [-version]\n")
	print("Options: ")
	print(" -autoclose                 Automatically close the platform after simulation.")
	print(" -draw-all-higher <value>   Draw all subjects when percentage of changes was higher")
	print("                            than <value>. Value must be between interval [0, 1].")
	print(" [-package pkg] -exportDb   Exports .sql files described in data.lua from MySQL to folder data.")
	print(" -gui                       Show the player for the application (it works only ")
	print("                            when an Environment and/or a Timer objects are used).")
	print(" -ide                       Configure TerraME for running from IDEs in Windows systems.")
	print(" [-package pkg] -importDb   Imports .sql files described in data.lua from folder data to MySQL.")
	print(" -mode=normal (default)     Warnings enabled.")
	print(" -mode=debug                Warnings treated as errors.")
	print(" -mode=quiet                Warnings disabled.")
	print(" -version                   TerraME general information.")
	print(" [-package pkg] -test       Execute tests.")
	print(" [-package pkg] -example    Run an example.")
	print(" [-package pkg] -doc        Build the documentation.")
	print(" -workers <value>           Sets the number of threads used for spatial observers.")
end

replaceSpecialChars = function(pattern)
	local specialChars = {"%^", "%$", "%(", "%)", "%.", "%[", "%]", "%*", "%+", "%-", "%?"}

	pattern = string.gsub(pattern, "%%", "%%%%")
	for _, spChar in ipairs(specialChars) do
		pattern = string.gsub(pattern, spChar, "%"..spChar)
	end
	return pattern
end

function getLevel()
	local level = 1

	while true do
		local info = debug.getinfo(level)

		if info == nil then
			return level - 1
		end

		local s = sessionInfo().separator
		local m1 = string.match(info.source, replaceSpecialChars(sessionInfo().path..s.."lua"))

		local packages = dir(sessionInfo().path..s.."packages")

		local m2

		forEachElement(packages, function(_, value)
			if not m2 then
				m2 = string.match(info.source, replaceSpecialChars(sessionInfo().path..s.."packages"..s..value..s.."lua"))
			end
		end)

		local m3 = string.match(info.short_src, "%[C%]")
		if m1 or m2 or m3 then
			level = level + 1
		else
			return level - 1 -- minus one because of getLevel()
		end
	end
end

function traceback()
	local level = 1

	local str = ""
	str = str.."Stack traceback:\n"

	local last_function = ""
	local found_function = false

	local info = debug.getinfo(level)
	while info ~= nil do
		local m1 = string.match(info.source, replaceSpecialChars(sessionInfo().path.."/lua"))
		local m2 = string.match(info.source, replaceSpecialChars(sessionInfo().path.."/packages/base/lua"))
		local m3 = string.match(info.short_src, "%[C%]")
		if m1 or m2 or m3 then
			last_function = info.name

			-- add the lines below if you want to see all the traceback
			--[[
			if last_function then
				str = str.. "\n    In "..last_function.."\n"
				str = str.."    File "..info.short_src..", line "..info.currentline
			end
			--]]
		else
			if not found_function then
				if     last_function == "__add"      then last_function = "operator + (addition)"
				elseif last_function == "__sub"      then last_function = "operator - (subtraction)"
				elseif last_function == "__mul"      then last_function = "operator * (multiplication)"
				elseif last_function == "__div"      then last_function = "operator / (division)"
				elseif last_function == "__mod"      then last_function = "operator % (modulo)"
				elseif last_function == "__pow"      then last_function = "operator ^ (exponentiation)"
				elseif last_function == "__unm"      then last_function = "operator - (minus)"
				elseif last_function == "__concat"   then last_function = "operator .. (concatenation)"
				elseif last_function == "__len"      then last_function = "operator # (size)"
				elseif last_function == "__eq"       then last_function = "operator == (equal)"
				elseif last_function == "__lt"       then last_function = "comparison operator"
				elseif last_function == "__le"       then last_function = "comparison operator"
				elseif last_function == "__index"    then last_function = "operator [] (index)"
				elseif last_function == "__newindex" then last_function = "operator [] (index)"
				elseif last_function == "__call"     then last_function = "call"
				elseif last_function ~= nil          then last_function = "function '"..last_function.."'"
				end

				if last_function then
					str = str.. "    In "..last_function.."\n"
				end
				found_function = true
			end

			str = str.."    File "..info.short_src..", line "..info.currentline
			if info.name then
				str = str..", in function "..info.name
			else
				str = str..", in main chunk"
			end
			str = str.."\n"
		end
		level = level + 1
		info = debug.getinfo(level)
	end
	return string.sub(str, 0, string.len(str) - 1)
end

execute = function(parameters) -- parameters is a vector of strings
	if parameters == nil or #parameters < 1 then 
		print("\nYou should provide, at least, a file as parameter.")
		usage()
		os.exit()
	end

	info_ = { -- this variable is used by Utils:sessionInfo()
		mode = "normal",
		dbVersion = "1_3_1",
		separator = package.config:sub(1, 1),
		path = os.getenv("TME_PATH")
	}

	if info_.path == nil or info_.path == "" then
		error("Error: TME_PATH environment variable should exist and point to TerraME installation folder.", 2)
	end

	-- Package.lua contains functions that terrame.lua needs, but should also be
	-- documented and availeble for the final users.
	local s = info_.separator
	local path = info_.path..s.."packages"..s.."base"..s.."lua"..s
	dofile(path.."Package.lua")
	dofile(path.."FileSystem.lua")
	dofile(path.."Utils.lua")

	info_.version = packageInfo().version

	local package = "base"

	local paramCount = 1
	while paramCount <= #parameters do
		param = parameters[paramCount]
		if string.sub(param, 1, 1) == "-" then
			if param == "-version" then
				versions()
				usage()
				os.exit()
			elseif param == "-ide" then
				local __cellEmpty = Cell{attrib = 1}
				local __obsEmpty = Observer{subject = __cellEmpty, type = "chart", attributes = {"attrib"}}
				__obsEmpty:kill()
			elseif param == "-mode=normal" then
				info_.mode = "normal"
			elseif param == "-mode=debug" then
				info_.mode = "debug"
			elseif param == "-mode=quiet" then
				info_.mode = "quiet"
			elseif param == "-package" then
				paramCount = paramCount + 1
				package = parameters[paramCount]
			elseif param == "-test" then
				info_.mode = "debug"
				paramCount = paramCount + 1

				local correct, errorMsg = xpcall(function() executeTests(package, parameters[paramCount]) end, function(err)
					printError(err)
					--printError(traceback())
				end)
				os.exit() -- #76
			elseif param == "-help" then 
				usage()
				os.exit()
			elseif param == "-doc" then
				local success, result = xpcall(function() executeDoc(package) end, function(err)
					local s = sessionInfo().separator
					local luaFolder = replaceSpecialChars(sessionInfo().path..s.."lua")
					local baseLuaFolder = replaceSpecialChars(sessionInfo().path..s.."packages"..s.."base"..s.."lua")
					local luadocLuaFolder = replaceSpecialChars(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua")
					
					local m1 = string.match(err, string.sub(luaFolder, string.len(luaFolder) - 25, string.len(luaFolder)))
					local m2 = string.match(err, string.sub(baseLuaFolder, string.len(baseLuaFolder) - 25, string.len(baseLuaFolder)))
					local m3 = string.match(err, string.sub(luadocLuaFolder, string.len(luadocLuaFolder) - 25, string.len(luadocLuaFolder)))
					local m4 = string.match(err, "%[C%]")

					if m1 or m2 or m3 or m4 then
						local str = 
								"*************************************************************\n"..
								"UNEXPECTED TERRAME INTERNAL ERROR. PLEASE GIVE US A FEEDBACK.\n"..
								"WRITE AN EMAIL TO pedro.andrade@inpe.br REPORTING THIS ERROR.\n"..
								"*************************************************************\n"..
								err.."\nStack traceback:\n"

						local level = 1
						local info = debug.getinfo(level)
						while info ~= nil do
							local m1 = string.match(info.source, luaFolder)
							local m2 = string.match(info.source, baseLuaFolder)
							local m3 = string.match(info.source, luadocLuaFolder)
							local m4 = string.match(info.short_src, "%[C%]")

							if info.short_src == "[C]" then
								str = str.."    Internal C file"
							else
								str = str.."    File "..info.short_src
							end

							if info.currentline > 0 then
								str = str..", line "..info.currentline
							end

							if info.name then
								str = str..", in function "..info.name
							else
								str = str..", in main chunk"
							end
							str = str.."\n"
							level = level + 1
							info = debug.getinfo(level)
						end
						return string.sub(str, 0, string.len(str) - 1)

					else
						return err.."\n"..getLevel()
					end
				end)
				if not success then
					printError(result)
				end
			elseif param == "-autoclose" then
				-- #77
			elseif param == "-workers" then
				-- #80
			elseif param == "-draw-all-higher" then
				-- #78
			elseif param == "-build" then
				if package == "base" then
					printError("TerraME cannot be built using -build.")
				else
					buildPackage(package)
				end
				os.exit()
			elseif param == "-install" then
				installPackage(parameters[paramCount + 1])
				os.exit()
			elseif param == "-importDb" then
				importDatabase(package)
				os.exit()
			elseif param == "-exportDb" then
				exportDatabase(package)
				os.exit()
			elseif param == "-example" then
				local file = parameters[paramCount + 1]

				if file then
					param = sessionInfo().path..s.."packages"..s..package..s.."examples"..s..file
					if not isfile(param) then
						printError("Example '"..file.."' does not exist in package '"..package.."'.")
						print("Please use one from the list below:")
					end
				elseif package == "base" then
					print("TerraME has the following examples:")
				else
					print("Package '"..package.."' has the following examples:")
				end

				if file and isfile(param) then
					-- it only changes the file to point to the package and let it run as it
					-- was a call such as "TerraME .../package/examples/example.lua"
					parameters[paramCount + 1] = param
				else
					files = examples(package)

					forEachElement(files, function(_, value)
						print(" - "..value)
					end)
					os.exit()
				end
			end
		else
			if package ~= "base" then
				require("base")
			end
			require(package)
			local s = sessionInfo().separator

			local displayFile = string.sub(param, 0, string.len(param) - 3).."tme"

			local cObj = TeVisualArrangement()
			cObj:setFile(displayFile)

			if isfile(displayFile) then
				local display = dofile(displayFile)

				forEachElement(display, function(idx, data)
					cObj:addPosition(idx, data.x, data.y)
					cObj:addSize(idx, data.width, data.height)
				end)
			end

			local success, result = xpcall(function() dofile(param) end, function(err)
				local luaFolder = replaceSpecialChars(sessionInfo().path.."/lua")
				local baseLuaFolder = replaceSpecialChars(sessionInfo().path.."/packages/base/lua")
				
				local m1 = string.match(err, string.sub(luaFolder, string.len(luaFolder) - 25, string.len(luaFolder)))
				local m2 = string.match(err, string.sub(baseLuaFolder, string.len(baseLuaFolder) - 25, string.len(baseLuaFolder)))
				local m3 = string.match(err, "%[C%]")

				if m1 or m2 or m3 then
					local str = 
							"*************************************************************\n"..
							"UNEXPECTED TERRAME INTERNAL ERROR. PLEASE GIVE US A FEEDBACK.\n"..
							"WRITE AN EMAIL TO pedro.andrade@inpe.br REPORTING THIS ERROR.\n"..
							"*************************************************************\n"..
							err.."\nStack traceback:\n"

					local level = 1
					local info = debug.getinfo(level)
					while info ~= nil do
						local m1 = string.match(info.source, replaceSpecialChars(sessionInfo().path.."/lua"))
						local m2 = string.match(info.source, replaceSpecialChars(sessionInfo().path.."/packages/base/lua"))
						local m3 = string.match(info.short_src, "%[C%]")

						if info.short_src == "[C]" then
							str = str.."    Internal C file"
						else
							str = str.."    File "..info.short_src
						end

						if info.currentline > 0 then
							str = str..", line "..info.currentline
						end

						if info.name then
							str = str..", in function "..info.name
						else
							str = str..", in main chunk"
						end
						str = str.."\n"
						level = level + 1
						info = debug.getinfo(level)
					end
					return string.sub(str, 0, string.len(str) - 1)

				else
					return err.."\n"..traceback()
				end
			end)

			if not success then
				printError(result)
			end

			return
		end
		paramCount = paramCount + 1
	end
end

--- Return a string describing a TerraME object. This function allows one to use the method print() directly from any TerraME object.
-- @name tostring
-- @param data Any TerraME object.
-- @usage c = Cell{cover = "forest", distRoad = 0.3}
-- description = tostring(c)
-- print(description)
-- print(c) -- same result of line above
tostringTerraME = function(self)
	local rs = {}
	local maxlen = 0

	forEachElement(self, function(index)
		if type(index) ~= "string" then index = tostring(index) end

		if index:len() > maxlen then
			maxlen = index:len()
		end
	end)

	local result = ""
	forEachOrderedElement(self, function(index, value, mtype)
		if type(index) ~= "string" then index = tostring(index) end

		result = result..index.." "

		local size = maxlen - index:len()
		local i
		for i = 0, size do
			result = result.." "
		end

		if mtype == "number" then
			result = result..mtype.." ["..value.."]"
		elseif mtype == "boolean" then
			if value then
				result = result.."boolean [true]"
			else
				result = result.."boolean [false]"
			end
		elseif mtype == "string" then
			result = result.."string [".. value.."]"
		elseif mtype == "table" then
			result = result.."table of size "..#value..""
		else
			result = result..mtype
		end

		result = result.."\n"
	end)

	return result
end

