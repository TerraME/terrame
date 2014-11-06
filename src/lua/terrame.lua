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

install = function(file)
	-- descompactar o pacote em TME_FOLDER/packages
	-- verificar se as dependencias estao instaladas (depends)
	-- verificar se a versao do terrame eh valida (built)
end

-- from http://stackoverflow.com/questions/17673657/loading-a-file-and-returning-its-environment
function include(scriptfile)
	local env = setmetatable({}, {__index = _G})
	if not isfile(scriptfile) then
		customError("File '"..scriptfile.."' does not exist.")
	end
	xpcall(function() loadfile(scriptfile, 't', env)() end, function(err)
		printError(err)
		printError(traceback())
	end)
	return setmetatable(env, nil) -- TODO: try to remove nil and see what happens. Perhaps this could be used in TerraME.
end

type__ = type

-- TODO: allow this to be executed directly from TerraME. Check if it is interesting to be executed
-- when the package is installed.
importDatabase = function()
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s.."base"

	-- before calling the commands below, we need to execute
	-- "create database cabeca;"
	
	local command = "mysql -u root -p -h localhost cabeca < "..baseDir..s.."data"..s.."cabecaDeBoi.sql"
	print(command)

	command = "mysql -u root -p -h localhost db_emas < "..baseDir..s.."data"..s.."db_emas.sql"
	print(command)
--	os.execute(command)
end

-- find the folders inside a package that contain
-- lua files, starting from package/tests
local testfolders = function(folder)
	local result = {}

	local lf 
	lf = function(mfolder)
		local parentFolders = dir(folder.."/"..mfolder)
		local found = false	
		forEachElement(parentFolders, function(idx, value)
			if string.endswith(value, ".lua") then
				if not found then
					found = true
					table.insert(result, mfolder)
				end
			else
				-- TODO: verify whether the value is really a folder here and show an error message
				if mfolder == "" then
					lf(value)
				else
					lf(mfolder.."/"..value)
				end
			end
		end)
	end

	lf("tests")

	return(result)
end

local doc = function(package)
	-- gera a documentacao do arquivo em TME_FOLDER/packages/package/doc a partir da pasta packages/package/lua/*.lua
	-- no futuro, pegar tambem a pasta examples para gerar a documentacao
	-- luadoc *.lua -d doc
	-- colocar sempre o logo do TerraME, removendo o parametro logo = "img/terrame.png"
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

	local files = dir(package_path..s.."lua")

	local doc_report = {
		parameters = 0,
		lua_files = 0,
		html_files = 0,
		global_functions = 0,
		functions = 0,
		variables = 0,
		links = 0,

		wrong_description = 0,
		undoc_param = 0,
		undefined_param = 0,
		unused_param = 0,
		undoc_files = 0,
		lack_usage = 0,
		block_name_conflict = 0,
		no_call_itself_usage = 0,
		non_doc_functions = 0,
		wrong_links = 0
	}

	luadocMain(package_path, files, package, doc_report)

	local finalTime = os.clock()

	print("\nReport: ")
	printNote("Documentation built in "..round(finalTime - initialTime, 2).." seconds.")

	if doc_report.undoc_param == 0 then
		printNote("All "..doc_report.parameters.." parameters were documented.")
	else
		printError(doc_report.undoc_param.." parameters were not documented.")
	end

	if doc_report.unused_param == 0 then
		printNote("All "..doc_report.parameters.." parameters were used in the HTML tables.")
	else
		printError(doc_report.unused_param.." table parameters were not used in the HTML tables.")
	end

	if doc_report.undoc_files == 0 then
		printNote(doc_report.html_files.." HTML files were built.")
	else
		printError(doc_report.undoc_files.." out of "..doc_report.lua_files.." files were not documented.")
	end

	if doc_report.lack_usage == 0 then
		printNote("All "..doc_report.functions.." have @usage field defined.")
	else
		printError(doc_report.lack_usage.." functions did not define @usage field.")
	end

	if doc_report.no_call_itself_usage == 0 then
		printNote("All "..doc_report.functions.." documented functions called themselves in their @usage.")
	else
		printError(doc_report.no_call_itself_usage.." documented functions do not call themselves in their @usage.")
	end

	if doc_report.non_doc_functions == 0 then
		printNote("All "..doc_report.functions.." functions of the package were documented.")
	else
		printError(doc_report.non_doc_functions.." functions were not documented.")
	end

	if doc_report.block_name_conflict == 0 then
		printNote("No block name conflicts were found.")
	else
		printError(doc_report.block_name_conflict.." functions were documented with a different name.")
	end

	if doc_report.undefined_param == 0 then
		printNote("No undefined parameter were found.")
	else
		printError(doc_report.undefined_param.." undefined parameters were found.")
	end

	if doc_report.wrong_description == 0 then
		printNote("All fields in file 'description.lua' are correct.")
	else
		printError(doc_report.wrong_description.." problems were found in file 'description.lua'")
	end

	if doc_report.wrong_links == 0 then
		printNote("All "..doc_report.links.." links were correctly generated.")
	else
		printError(doc_report.wrong_links.." of "..doc_report.links.." links to undefined functions of files were found")
	end

	local errors = doc_report.undoc_param + doc_report.unused_param + doc_report.undoc_files +
				   doc_report.lack_usage + doc_report.no_call_itself_usage + doc_report.non_doc_functions +
				   doc_report.block_name_conflict + doc_report.undefined_param + doc_report.wrong_description + 
				   doc_report.wrong_links

	if errors == 0 then
		printNote("Summing up, all tests were succesfully executed.")
	elseif errors == 1 then
		printError("Summing up, one problem was found during the tests.")
	else
		printError("Summing up, "..errors.." problems were found during the tests.")
	end
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

local executeTests = function(fileName, package)
	local initialTime = os.clock()

	if package ~= "base" then
		require("base")
	end

	local print_when_loading = 0

	printNote("Loading package "..package)
	print = function(...)
		-- FIXME: print_when_loading should be called ut.print_when_loading (see below the UnitTest)
		print_when_loading = print_when_loading + 1
		printError(...)
	end

    xpcall(function() require(package) end, function(err)
		printError("Package could not be loaded.")
        printError(err)
		os.exit()
    end)

	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s..package
	local srcDir = baseDir..s.."tests"

	if not isfile(srcDir) then
		customError("Folder 'tests' does not exist in package '"..package.."'.")
	end

	load_file = baseDir..s.."load.lua"
	local load_sequence

	print = function(...) end
	if isfile(load_file, load_file) then
		load_sequence = include(load_file).files
	end

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		testfunctions[file] = buildCountTable(include(baseDir..s.."lua"..s..file))
	end
	print = print__

	local data

	if type(fileName) == "string" then
		printNote("Loading configuration file "..fileName)
		data = include(fileName)
		if getn(data) == 0 then
			printError("File "..fileName.." is empty. Please use at least one variable from {'examples', 'folder', 'file', 'sleep', 'test'}.")
			os.exit()
		end
	else
		data = {}
	end

	local check_functions = data.folder == nil and data.file == nil and data.test == nil
	local examples = data.examples
	if examples == nil then
		examples = check_functions
	end

	local tf = testfolders(baseDir)
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
			local found = false
			forEachElement(mfolder, function(_, mvalue)
				if string.match(value, mvalue) and not found then
					table.insert(data.folder, value)
					found = true
				end
			end)
		end)
	else
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

	local parameters = {"sleep", "examples", "folder", "test", "file"}
	forEachElement(data, function(value)
		if not belong(value, parameters) then
			customWarning("Attribute '"..value.."' in file '"..fileName.."' is unnecessary.")
		end
	end)

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
		log_files = 0
	}

	local myTest
	local myFile

	-- For each test in each file in each folder, execute the test
	for _, eachFolder in ipairs(data.folder) do
		local dirFiles = dir(baseDir..s..eachFolder)
		if dirFiles ~= nil then 
			myFile = {}
			if type(data.file) == "string" then
				if belong(data.file, dirFiles) then
					myFile = {data.file}
				end
			elseif type(data.file) == "table" then
				forEachElement(dirFiles, function(_, value)
					if belong(value, data.file) then
						myFile[#myFile + 1] = value
					end
				end)
			elseif data.file == nil then
				forEachElement(dirFiles, function(_, value)
					myFile[#myFile + 1] = value
				end)
			else
				error("file is not a string, table or nil.")
			end

			if #myFile == 0 then
				printWarning("Skipping folder "..eachFolder)
			end

			for _, eachFile in ipairs(myFile) do
				ut.current_file = eachFolder..s..eachFile
				-- TODO: o teste abaixo supoe que eachFile existe. Fazer este teste e ignorar caso nao exista.
				local tests = dofile(baseDir..s..eachFolder..s..eachFile)

				if type(tests) ~= "table" or getn(tests) == 0 then
					customError("The file does not implement any test.")
				end

				myTest = {}
				if type(data.test) == "string" then
					if tests[data.test] then
						myTest = {data.test}
					end
				elseif data.test == nil then
					forEachOrderedElement(tests, function(index, value, mtype)
						myTest[#myTest + 1] = index 					
					end)
				elseif type(data.test) == "table" then
					forEachElement(data.test, function(_, value)
						if tests[value] then
							myTest[#myTest + 1] = value
						end
					end)
				else
					error("test is not a string, table or nil")
				end

				if #myTest > 0 then
					printNote("Testing "..eachFolder..s..eachFile)
				else
					printWarning("Skipping "..eachFolder..s..eachFile)
				end


				for _, eachTest in ipairs(myTest) do
					print("Testing "..eachTest)

					if testfunctions[eachFile] and testfunctions[eachFile][eachTest] then
						testfunctions[eachFile][eachTest] = testfunctions[eachFile][eachTest] + 1
					elseif testfunctions[eachFile] then
						printError("Function does not exist in the respective file in the source code.")
						ut.functions_not_exist = ut.functions_not_exist + 1
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
						ut.functions_without_assert = ut.functions_without_assert + 1
						printError("No asserts were found in the test.")
					end

					if getn(_G) > count_global then
						-- TODO: check if it is < or > (the code below works for >)
						local variables = ""
						local pvariables = {}
						forEachElement(_G, function(idx, _, mtype)
						-- TODO: trocar por forEachOrderedElement, mas esta dando pau
							if global_variables[idx] == nil then
								variables = variables.."'"..idx.."' ("..mtype.."), "
								pvariables[#pvariables + 1] = idx
							end
						end)
						variables = variables:sub(1, variables:len() - 2).."."
						printError("Test creates global variable(s): "..variables)
						ut.functions_with_global_variables = ut.functions_with_global_variables + 1

						-- we need to delete the global variables created in order
						-- to ensure that a new error will be generated if this
						-- variable is found again
						forEachElement(pvariables, function(_, value)
							_G[value] = nil
						end)
					else
						ut.success = ut.success + 1
					end

					if ut.count_last > 0 then
						printError("[The error above occurs more "..ut.count_last.." times.]")
						ut.count_last = 0
						ut.last_error = ""
					end
				end
			end
		end
	end 

	-- checking if all source code functions were tested
	if check_functions then
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
	if examples then
		printNote("Testing examples")
		local dirFiles = dir(baseDir..s.."examples")
		if dirFiles ~= nil then
			forEachElement(dirFiles, function(idx, value)
				if not string.endswith(value, ".lua") then
					if not string.endswith(value, ".log") then
						printWarning("Skipping "..value)
					end
					return true
				end

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
					loadfile(baseDir..s.."examples"..s..value, 't', env)()
					return setmetatable(env, nil)
				end
				xpcall(myfunc, function(err)
					ut.examples_error = ut.examples_error + 1
					printError(err)
					printError(traceback())
				end)

				if not writing_log and logfile then
					local str = logfile:read("*all")
					if str and str ~= "" then
						ut.examples_error = ut.examples_error + 1
						printError("Output file contains text not printed by the simulation: ")
						printError("'"..str.."'")
					end
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


	if print_when_loading > 0 then
		printError(print_when_loading.." print calls were found when loading the package.")
	else
		printNote("No print calls were found when loading the package.")
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

	if examples then
		if ut.examples == 0 then
			printError("No examples were found.")
		elseif ut.examples_error == 0 then
			printNote("All "..ut.examples.." examples were successfully executed.")
		else
			printError(ut.examples_error.." out of "..ut.examples.." examples had unexpected execution error.")
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
		printNote("Summing up, all tests were succesfully executed.")
	elseif errors == 1 then
		printError("Summing up, one problem was found during the tests.")
	else
		printError("Summing up, "..errors.." problems were found during the tests.")
	end
	os.exit() -- TODO: remove it. Up to now, if this line does not exist TerraME will not end.
end

build = function(folder, dev)
	if dev == nil then dev = false end
	-- TODO: pensar melhor:
	-- dev indica se o pacote gerado sera para desenvolvimento ou nao
	-- um pacote dev contem todos os testes e todos os dados

	-- verificar as tags do arquivo DESCRIPTION
	-- atualizar os campos 'data' e 'built' no DESCRIPTION
	-- doc() -- gerar documentacao das pastas lua e examples.
	-- test() -- executar todos os testes unitarios
	-- executar todos os examples (nao pode gerar erro)

	-- gerar o zip

	-- instalar o pacote
	-- carregar o pacote
end

local versions = function()
	print("\nTerraME - Terra Modeling Environment")
	print(" Version: ", sessionInfo().version)
	print(" Location (TME_PATH): "..sessionInfo().path)

	print(" Compiled with: ")
	-- TODO: Verify how to retrieve these informations.
	-- qWarning("    %s ", LUA_RELEASE);
	-- qWarning("    Qt %s ", qVersion());
	-- qWarning("    Qwt %s ", QWT_VERSION_STR);

	-- qWarning("    TerraLib %s (Database version: %s) ", 
	--     TERRALIB_VERSION,       // macro in the file "TeVersion.h"
	--     TeDBVERSION.c_str());   // macro in the file "TeDefines.h" linha 221

	print("\nFor more information, please visit: www.terrame.org\n")
end

local usage = function()
	print("")
	print("Usage: TerraME [[-gui] | [-mode=normal|debug|quiet]] file1.lua file2.lua ...")
	print("       or TerraME [-version]\n")
	print("Options: ")
	print(" -autoclose                 Automatically close the platform after simulation.")
	print(" -draw-all-higher <value>   Draw all subjects when percentage of changes was higher")
	print("                            than <value>. Value must be between interval [0, 1].")
	print(" -gui                       Show the player for the application (it works only ")
	print("                            when an Environment and/or a Timer objects are used).")
	print(" -ide                       Configure TerraME for running from IDEs in Windows systems.")
	print(" -mode=normal (default)     Warnings enabled.")
	print(" -mode=debug                Warnings treated as errors.")
	print(" -mode=quiet                Warnings disabled.")
	print(" -version                   TerraME general information.")
	print(" -test                      Execute tests.")
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

execute = function(parameters) -- parameters is a string
	if parameters == nil or #parameters < 1 then 
		print("\nYou should provide, at least, a model file as parameter.")
		usage()
		os.exit()
	end

	-- this variable is used by Utils:sessionInfo()
	info_ = {
		mode = "normal",
		dbVersion = "1_3_1", -- TODO: remove this parameter?
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

	local package = ""

	local paramCount = 1
	while paramCount <= #parameters do
		param = parameters[paramCount]
		if string.sub(param, 1, 1) == "-" then
			if param == "-version" then
				versions()
				usage()
				return
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
				if package == "" then
					package = "base"
				end

				local correct, errorMsg = xpcall(function() executeTests(parameters[paramCount], package) end, function(err)
					printError(err)
					--printError(traceback())
				end)
				return
			elseif param == "-help" then 
				usage()
				return
			elseif param == "-doc" then
				paramCount = paramCount + 1
				if package == "" then
					package = "base"
				end
				-- TODO: verify error handler
				local success, result = xpcall(function() doc(package) end, function(err)
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
				-- TODO
			elseif param == "-workers" then
				-- TODO
			elseif param == "-draw-all-higher" then
				-- TODO
			end
		else
			-- TODO: Verify this block
			if package ~= "" then
				if package ~= "base" then
					require("base")
				end
				require(package)
				local s = sessionInfo().separator
				param = sessionInfo().path..s.."packages"..s..package..s.."examples"..s..param
			else
				require("base")
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

