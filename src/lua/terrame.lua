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

-- Creates a text file with the names of the files inside a given folder
-- RAIAN: I changed this function from local to global, in order to use it in luadoc
function dir(folder)
	local s = sessionInfo().separator
	local command
	if s == "\\" then
		command = "dir "..folder.." /b > "..folder..s.."aux.txt"
	elseif s == "/" then
		command = "ls -1 "..folder.." 2> /dev/null".." > "..folder..s.."aux.txt"
	end
	
	if os.execute(command) ~= nil then 
		local file = io.open(folder..s.."aux.txt", "r")
		local fileTable = {}
		for line in file:lines() do
			if line ~= "README.txt" and line ~= ".svn" and line ~= ".aux.txt.swp" and line ~= "aux.txt" then 
				fileTable[#fileTable + 1] = line
			end
		end

		file:close()
		os.execute("rm "..folder..s.."aux.txt")
		return fileTable
	end
end	

local begin_red    = "\027[00;31m"
local begin_yellow = "\027[00;33m"
local begin_green  = "\027[00;32m"
local begin_blue   = "\027[00;34m"
local end_color    = "\027[00m"

print__ = print

local print_blue = function(value)
	if sessionInfo().separator == "/" then
		print__(begin_blue..value..end_color)
	else
		print__(value)
	end
end

local function print_red(value)
	if sessionInfo().separator == "/" then
		print__(begin_red..value..end_color)
	else
		print__(value)
	end
end

local function print_green(value)
	if sessionInfo().separator == "/" then
		print__(begin_green..value..end_color)
	else
		print__(value)
	end
end

local function print_yellow(value)
	if sessionInfo().separator == "/" then
		print__(begin_yellow..value..end_color)
	else
		print__(value)
	end
end

-- baixa prioridade
install = function(file)
	-- descompactar o pacote em TME_FOLDER/packages
	-- verificar se as dependencias estao instaladas (depends)
	-- verificar se a versao do terrame eh valida (built)
end

-- from http://stackoverflow.com/questions/17673657/loading-a-file-and-returning-its-environment
function include(scriptfile)
	local env = setmetatable({}, {__index = _G})
	loadfile(scriptfile, 't', env)()
	return setmetatable(env, nil) -- TODO: try to remove nil and see what happens. Perhaps this could be used in TerraME.
end

-- altissima prioridade (somente com o primeiro argumento)
-- TODO: This function shouldn't have named parameters? It has two optional parameters. 
require = function(package, recursive, asnamespace)
	-- asnamespaca significa que os objetos do pacote estarao todos dentro de um namespace
	-- com o nome do proprio pacote. Por exemplo, se o pacote core for carregado como
	-- namespace entao o forEachCell deveria ser acessado como core.forEachCell.
	if asnamespace == nil then asnamespace = false end

	-- recursive indica se deve carregar tambem os pacotes que este depende
	if recursive == nil then recursive = true end

	-- verificar se a pasta TME_FOLDER/packages/package existe
	if type(package) ~= "string" then
		if package == nil then
			mandatoryArgumentErrorMsg("#1", 3)
		else
			incompatibleTypeError("#1", "string", type(package), 3)
		end
	end

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	if not isfile(package_path) then
		customError("Package "..package.." not found.", 3)
	end

	local load_file = package_path..s.."load.lua"
	local load_sequence

	if os.rename(load_file, load_file) then
		load_sequence = include(load_file).files
	end

	local i, file

	if load_sequence then
		for _, file in ipairs(load_sequence) do
			dofile(package_path..s.."lua"..s..file)
		end
	end

	-- executar a funcao onLoad() do pacote (esta funcao pode configurar algumas coisas e imprimir informacao
	-- de que o pacote foi carregado com sucesso).
end

type__ = type

--- Return the type of an object. It extends the original Lua type() to support TerraME objects, 
-- whose type name (for instance "CellularSpace" or "Agent") is returned instead of "table".
-- @param data Any object or value.
-- @usage c = Cell{value = 3}
-- print(type(c)) -- "Cell"
type = function(data)
	local t = type__(data)
	if t == "table" or t == "userdata" and getmetatable(data) then
		if data.type_ ~= nil then
			return data.type_
		end
	end
	return t
end

-- TODO: allow this to be executed directly from TerraME. Check if it is interesting to be executed
-- when the package is installed.
importDatabase = function()
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages/base"

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
	require("base")

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

local configureTests = function(fileName, package)
	if package == "" then
		package = "base"
	end

	--TODO: Colocar aqui o caminho para o pacote especificado. Por enquando esta direto para o base
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s..package
	local srcDir = baseDir..s.."tests"

	local tf = testfolders(baseDir)
	local options = {}
	local optionparent = {}
	print (">> Choose option: ")
	options[#options + 1] = "ALL"
	optionparent[#optionparent + 1] = "ALL"
	print("("..#options..")".." ALL")

	forEachElement(tf, function(_, folder)
		options[#options + 1] = folder
		print("("..#options..")".." "..options[#options])
	end)

	local answer = io.read()
	local test = io.open(fileName, "w")
	
	-- There is a function for each of the questions that can be asked for the user
	
	-- Question to wait between tests
	local function waitQuestion()
		print("\n >> Wait between tests? \n(1) True \n(2) False")
		local wait = io.read()
		if wait == '1' then
			test:write("sleep = 2\n")
		end
	end
	
	-- Question about the choosen test
	local function returnTest(folder, file)
		local tests = dofile(baseDir..s..folder..s..file)
		local testsList = {}
		print ("\n>> Choose Test: ")
		testsList[#testsList + 1] = "ALL"
		print("("..#testsList..") ALL")
		forEachOrderedElement(tests, function(index, value, mtype)		
			testsList[#testsList + 1] = index
			print("("..#testsList..") "..index)
		end)
		return testsList
	end
	
	-- Question about the database and password if necessary
	local function databaseQuestion()
		print("\n>> Choose database type: \n(1) MySQL\n(2) MSAccess")
		local dbtype = io.read()
		if dbtype == '1' then
			print(">> Input Password: ")
			local password = io.read()	
			test:write("dbType = 'mysql'\n")
			test:write("password = '".. password.."'\n")
		elseif dbtype == "2" then
			test:write("dbType = 'ado'\n")
		end
	end
	
	-- Question about the test file
	local function fileQuestion()	
		print("\n>> Choose option: \n")	
		local luaTests = {}
		luaTests[#luaTests + 1] = '""'
		print("("..(#luaTests)..")".." ".."ALL")
		local luaTests2 = dir(baseDir..s..options[tonumber(answer)])
		for _, test in ipairs(luaTests2) do
			luaTests[#luaTests + 1] = test
		end
		
		for index, tests in ipairs(luaTests2) do
			print("("..(index + 1)..")".." "..tests)
		end
	
		usertest = io.read()
		if tonumber(usertest) ~= 1 then
			test:write("file = ".."'"..luaTests[tonumber(usertest)].."'".."\n")
			local results = returnTest(options[tonumber(answer)], luaTests[tonumber(usertest)])
			local answerTest = io.read()
			if tonumber(answerTest) ~= 1 then
				test:write("test = ".."'"..results[tonumber(answerTest)].."'")
			end
		end
		
		return luaTests[tonumber(usertest)]
	end
	
	-- If the user chooses something else than ALL, it writes the choosen folder
	if tonumber(answer) ~= 1 then
		test:write("folder = ".."'"..options[tonumber(answer)].."'".."\n")
	end
	
	-- Check which of the folders the user has choosen to test, and asks the appropriate questions
	if optionparent[tonumber(answer)] == "observer" then
		waitQuestion()
		local luaTests = fileQuestion()
	elseif optionparent[tonumber(answer)] == "database" then
		databaseQuestion()
		local luaTests = fileQuestion()
	elseif optionparent[tonumber(answer)] == "core" then	
		local luaTests = fileQuestion()
	elseif tonumber(answer) == 1 then
		waitQuestion()
		databaseQuestion()	
	else 
		waitQuestion()
		databaseQuestion()
		local luaTests = fileQuestion()	
	end

	test:close()
end

local doc = function(package)
	-- gera a documentacao do arquivo em TME_FOLDER/packages/package/doc a partir da pasta packages/package/lua/*.lua
	-- no futuro, pegar tambem a pasta examples para gerar a documentacao
	-- luadoc *.lua -d doc
	-- colocar sempre o logo do TerraME, removendo o parametro logo = "img/terrame.png"

	require("luadoc")
	require("base")

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	local files = dir(package_path..s.."lua")

	luadocMain(package, files)
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

isfile = function(file)
	return os.rename(file, file)
end

-- RAIAN: FUncao do antonio que executa os testes. Devera ir para dentro da funcao test acima. Coloquei desta maneira 
-- para executar os testes sem alterar a chamada no lado C++ por enquanto. 
local executeTests = function(fileName, package)
	if package == nil then
		package = "base"
	else
		require("base")
	end

	require(package)

	local initialTime = os.clock()

	--TODO: Colocar aqui o caminho para o pacote especificado. Por enquando esta direto para o base
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s..package
	local srcDir = baseDir..s.."tests"

	if not isfile(srcDir) then
		customError("Folder 'tests' does not exist in package '"..package.."'.")
	end

	load_file = baseDir..s.."load.lua"
	local load_sequence

	if os.rename(load_file, load_file) then
		load_sequence = include(load_file).files
	end

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		testfunctions[file] = buildCountTable(include(baseDir..s.."lua"..s..file))
	end

	local data

	if type(fileName) == "string" then
		data = include(fileName)
	else
		data = {}
	end

	local check_functions = data.folder == nil and data.file == nil and data.test == nil
	local examples = check_functions or data.examples

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

	local myTest
	local myFile

	local global_variables = {}
	local count_global = getn(_G)
	forEachElement(_G, function(idx)
		global_variables[idx] = true
	end)

	checkUnnecessaryParameters(data, {"dbType", "host", "port", "password", "user", "sleep", "examples", "folder", "test", "file"}, 3)

	local ut = UnitTest{
		dbType = data.dbType,
		user = data.user,
		password = data.password,
		port = data.port,
		host = data.host,
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
	}
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
				print_yellow("Skipping folder "..eachFolder)
			end

			for _, eachFile in ipairs(myFile) do
				print_green("Testing "..eachFolder..s..eachFile)
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

				if #myTest == 0 then
					print_yellow("Skipping file "..eachFile)
				end


				for _, eachTest in ipairs(myTest) do
					print("Testing "..eachTest)

					if testfunctions[eachFile] and testfunctions[eachFile][eachTest] then
						testfunctions[eachFile][eachTest] = testfunctions[eachFile][eachTest] + 1
					elseif testfunctions[eachFile] then
						print_red("Function does not exist in the respective file in the source code.")
						ut.functions_not_exist = ut.functions_not_exist + 1
					end

					local count_test = ut.test

					collectgarbage("collect")

					print = function(...)
						ut.print_calls = ut.print_calls + 1
						print_red(...)
					end

					local ok_execution, err = pcall(function() tests[eachTest](ut) end)

					print = print__

					killAllObservers()
					ut.executed_functions = ut.executed_functions + 1

					if not ok_execution then
						print_red("Wrong execution, got error: '"..err.."'.")
						ut.functions_with_error = ut.functions_with_error + 1
					elseif count_test == ut.test then
						ut.functions_without_assert = ut.functions_without_assert + 1
						print_red("No asserts were found in the test.")
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
						print_red("Test creates global variable(s): "..variables)
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
						print_red("[The error above occurs more "..ut.count_last.." times.]")
						ut.count_last = 0
						ut.last_error = ""
					end
				end
			end
		end
	end 

	-- checking if all source code functions were tested
	if check_functions then
		print_green("Checking if functions from source code were tested")
		if type(data.file) == "string" then
			print("Checking "..data.file)
			forEachElement(testfunctions[data.file], function(idx, value)
				ut.package_functions = ut.package_functions + 1
				if value == 0 then
					print_red("Function '"..idx.."' was not tested.")
					ut.functions_not_tested = ut.functions_not_tested + 1
				end
			end)
		elseif type(data.file) == "table" then
			forEachOrderedElement(data.file, function(idx, value)
				print("Checking "..value)
				forEachElement(testfunctions[value], function(midx, mvalue)
					ut.package_functions = ut.package_functions + 1
					if mvalue == 0 then
						print_red("Function '"..midx.."' was not tested.")
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
						print_red("Function '"..midx.."' was not tested.")
						ut.functions_not_tested = ut.functions_not_tested + 1
					end
				end)
			end)
		end
	else
		print_yellow("Skipping source code functions check")
	end

	-- executing examples
	if examples then
		print_green("Testing examples")
		local dirFiles = dir(baseDir..s.."examples")
		if dirFiles ~= nil then
			forEachElement(dirFiles, function(idx, value)
				print("Testing "..value)
				io.flush()
				collectgarbage("collect")
				
				ut.examples = ut.examples + 1

				collectgarbage("collect")

				print = function(...)
					ut.print_calls = ut.print_calls + 1
					print_red(...)
				end

				local ok_execution, err = pcall(function() include(baseDir..s.."examples"..s..value) end)

				print = print__

				killAllObservers()
		
				if not ok_execution then
					ut.examples_error = ut.examples_error + 1
					print_red(err)
				end
			end)
		end
	else
		print_yellow("Skipping examples")
	end

	local finalTime = os.clock()

	print("\nReport:")

	local text = "Tests were executed in "..round(finalTime - initialTime, 2).." seconds"
	if ut.delayed_time > 0 then
		text = text.." ("..ut.delayed_time.. " seconds sleeping)."
	else
		text = text.."."
	end

	print_green(text)

	if ut.fail > 0 then
		print_red(ut.fail.." out of "..ut.test.." asserts failed.")
	else
		print_green("All "..ut.test.." asserts were executed successfully.")
	end

	if ut.functions_with_error > 0 then
		print_red(ut.functions_with_error.." out of "..ut.executed_functions.." tested functions stopped with an unexpected error.")
	else
		print_green("All "..ut.executed_functions.." tested functions do not have any unexpected execution error.")
	end

	if ut.functions_without_assert > 0 then
		print_red(ut.functions_without_assert.." out of "..ut.executed_functions.." tested functions do not have at least one assert.")
	else
		print_green("All "..ut.executed_functions.." tested functions have at least one assert.")
	end

	if ut.functions_not_exist > 0 then
		print_red(ut.functions_not_exist.." out of "..ut.executed_functions.." tested functions do not exist in the source code of the package.")
	else
		print_green("All "..ut.executed_functions.." tested functions exist in the source code of the package.")
	end

	if ut.functions_with_global_variables > 0 then
		print_red(ut.functions_with_global_variables.." out of "..ut.executed_functions.." tested functions create some global variable.")
	else
		print_green("No function creates any global variable.")
	end

	if ut.print_calls > 0 then
		print_red(ut.print_calls.." print calls were found in the tests.")
	else
		print_green("No function prints any text on the screen.")
	end

	if ut.wrong_file > 0 then
		print_red(ut.wrong_file.." assert_error calls found an error message pointing to an internal file (wrong level).")
	else
		print_green("No assert_error has error messages pointing to internal files.")
	end

	if check_functions then
		if ut.functions_not_tested > 0 then
			print_red(ut.functions_not_tested.." out of "..ut.package_functions.." source code functions are not tested.")
		else
			print_green("All "..ut.package_functions.." functions of the package are tested.")
		end
	else
		print_yellow("No source code functions were verified.")
	end

	if examples then
		if ut.examples == 0 then
			print_red("No examples were found.")
		elseif ut.examples_error == 0 then
			print_green("All "..ut.examples.." examples were successfully executed.")
		else
			print_red(ut.examples_error.." out of "..ut.examples.." examples have unexpected execution error.")
		end
	else
		print_yellow("No examples were executed.")
	end

	local errors = ut.fail + ut.functions_not_exist + ut.functions_not_tested + ut.examples_error + 
	               ut.wrong_file + ut.print_calls + ut.functions_with_global_variables + 
	               ut.functions_with_error + ut.functions_without_assert

	if errors == 0 then
		print_green("Summing up, all tests were succesfully executed.")
	elseif errors == 1 then
		print_red("Summing up, one problem was found during the tests.")
	else
		print_red("Summing up, "..errors.." problems were found during the tests.")
	end
	os.exit() -- TODO: remove it. Up to now, if this line does not exist TerraME will not end.
end

build = function(folder, dev)
	if dev == nil then dev = false end
	-- pensar melhor:
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

file = function(file, package)
	local s = sessionInfo().separator
	local file = sessionInfo().path..s.."packages"..s..package..s.."data"..s..file
	return file
	-- verificar se o arquivo existe senao retorna um erro
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
	print(" -config-tests <file_name>  Generate a file used to configure the execution of the tests.")
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
	--print("WRONG LEVEL: "..level) end

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

-- RAIAN implementar
execute = function(parameters) -- parameters is a string
	-- implementa o sessionInfo
	-- o execute vai chamar o build, test, etc.

	if parameters == nil or #parameters < 1 then 
		print("\nYou should provide, at least, a model file as parameter.")
		usage()
		return
	end

	local executionMode = "normal"

	local info = {
		mode = executionMode,
		version = "2.0",
		dbVersion = "1_3_1", -- TODO: remove this parameter?
		separator = package.config:sub(1, 1),
		path = os.getenv("TME_PATH")
	}

	sessionInfo = function()
		return info
		-- atualizar todos os arquivos que usam as variaveis globais por uma chamada a esta funcao
		-- remover as variaveis globais TME_MODE, ...
	end

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
				info.mode = "normal"
			elseif param == "-mode=debug" then
				info.mode = "debug"
			elseif param == "-mode=quiet" then
				info.mode = "quiet"
			elseif param == "-config-tests" then
				paramCount = paramCount + 1
				local correct, errorMsg = pcall(configureTests, parameters[paramCount], package)
				if not correct then 
					print(errorMsg)
				end
				return
			elseif param == "-package" then
				paramCount = paramCount + 1
				package = parameters[paramCount]
				
			elseif param == "-test" then
				info.mode = "debug"
				paramCount = paramCount + 1
				if package == "" then
					package = "base"
				end

				local correct, errorMsg = pcall(executeTests, parameters[paramCount], package)
				if not correct then
					print(errorMsg)
				end
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
					print_red(result)
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
			local function getLevel()
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
							else   last_function = "function "..last_function
							end

							str = str.. "    In "..last_function.."\n"
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
					return err.."\n"..getLevel()
				end
			end)

			if not success then
				print_red(result)
			end

			return
		end
		paramCount = paramCount + 1
	end
end

packageInfo = function(package)
	local s = sessionInfo().separator
	local file = sessionInfo().path..s.."packages"..s..package..s.."description.lua"
	
	return include(file)

	--forEachOrderedElement(ns, function(idx, value)
	--	print(idx..": "..value)
	--end)
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

