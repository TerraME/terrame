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
local function dir(folder)
	local s = sessionInfo().separator
	local command
	if s == "\\" then
		command = "dir "..folder.." /b > "..folder..s.."aux.txt"
	elseif s == "/" then
		command = "ls -1 "..folder.." > "..folder..s.."aux.txt"
	end
	
	os.execute(command)
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

local begin_red    = "\027[00;31m"
local begin_yellow = "\027[00;33m"
local begin_green  = "\027[00;32m"
local begin_blue   = "\027[00;34m"
local end_color    = "\027[00m"

local print_blue = function(value)
	if sessionInfo().separator == "/" then
		print(begin_blue..value..end_color)
	else
		print(value)
	end
end

local function print_red(value)
	if sessionInfo().separator == "/" then
		print(begin_red..value..end_color)
	else
		print(value)
	end
end

local function print_green(value)
	if sessionInfo().separator == "/" then
		print(begin_green..value..end_color)
	else
		print(value)
	end
end

local function print_yellow(value)
	if sessionInfo().separator == "/" then
		print(begin_yellow..value..end_color)
	else
		print(value)
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
			incompatibleTypesErrorMsg("#1", "string", type(package), 3)
		end
	end

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	if os.rename(package_path, package_path) == nil then
		customErrorMsg("Package "..package.." not found.", 3)
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

configureTests = function(fileName)
	--TODO: Colocar aqui o caminho para o pacote especificado. Por enquando esta direto para o base
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages/base"
	local srcDir = baseDir..s.."tests"

	-- Prints the names of the folders inside the "run" folder, for the user to choose from
	local firstFolders = dir(srcDir)
	local options = {}
	local optionparent = {}
	print (">> Choose option: ")
	options[#options + 1] = "ALL"
	optionparent[#optionparent + 1] = "ALL"
	print("("..#options..")".." ALL")

	for _, parentFolder in ipairs(firstFolders) do
		local childFolders = dir(srcDir..s..parentFolder)
		for index, childFolder in ipairs(childFolders) do
			if s == "\\" then		
				options[#options + 1] = parentFolder..s..s..childFolder
			else
				options[#options + 1] = parentFolder..s..childFolder
			end
			optionparent[#optionparent + 1] = parentFolder
			print("("..#options..")".." "..options[#options])
		end
	end
	
	local answer = io.read()
	local test = io.open(fileName, "w")
	
	-- There is a function for each of the questions that can be asked for the user
	
	-- Question to wait between tests
	local function waitQuestion()
		print("\n >> Wait between tests? \n(1) True \n(2) False")
		local wait = io.read()
		if wait == '1' then
			test:write("wait = true\n")
		elseif wait == '2' then
			test:write("wait = false\n")			
		end
	end
	
	-- Question about the choosen test
	local function returnTest(folder, file)
		local tests = dofile(srcDir..s..folder..s..file)
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
			test:write("database = 'mysql'\n")
			test:write("password = '".. password.."'\n")
		elseif dbtype == "2" then
			test:write("database = 'ado'\n")
		end
	end
	
	-- Question about the test file
	local function fileQuestion()	
		print("\n>> Choose option: \n")	
		local luaTests = {}
		luaTests[#luaTests + 1] = '""'
		print ("("..(#luaTests)..")".." ".."ALL")
		local luaTests2 = dir(srcDir..s..options[tonumber(answer)])
		for _, test in ipairs(luaTests2) do
			luaTests[#luaTests + 1] = test
		end
		
		for index, tests in ipairs(luaTests2) do
			print ("("..(index + 1)..")".." "..tests)
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

doc = function(package)
	-- gera a documentacao do arquivo em TME_FOLDER/packages/package/doc a partir da pasta packages/package/lua/*.lua
	-- no futuro, pegar tambem a pasta examples para gerar a documentacao
	-- luadoc *.lua -d doc
	-- colocar sempre o logo do TerraME, removendo o parametro logo = "img/terrame.png"
end

-- altissima prioridade
exectest = function(package, configFile)
	if package == nil then
		package = "base"
	else
		require("base")
	end

	require(package)

	-- executar todos os testes
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


-- RAIAN: FUncao do antonio que executa os testes. Devera ir para dentro da funcao test acima. Coloquei desta maneira 
-- para executar os testes sem alterar a chamada no lado C++ por enquanto. 
executeTests = function(fileName)
	--TODO: Colocar aqui o caminho para o pacote especificado. Por enquando esta direto para o base
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages"..s.."base"
	local srcDir = baseDir..s.."tests"

	load_file = baseDir..s.."load.lua"
	local load_sequence

	if os.rename(load_file, load_file) then
		load_sequence = include(load_file).files
	end

	local testfunctions = {} -- test functions store all the functions that need to be tested, extracted from the source code

	for i, file in ipairs(load_sequence) do
		testfunctions[file] = buildCountTable(include(baseDir..s.."lua"..s..file))
	end

	sessionInfo = function()
		result = {
			mode = "debug",
			version = VERSION,
			dbVersion = "1_3_1", -- TODO: remove this parameter?
			separator = package.config:sub(1, 1),
			path = os.getenv("TME_PATH")
		}
		return result
	end

	-- TODO: possibilitar executar esta funcao mesmo que o usuario nao passe
	-- um arquivo de teste, de forma que todos os testes serao executados.

	local data = include(fileName)

	local examples = data.file == nil and data.folder == nil and data.test == nil

	-- Check every selected folder
	if type(data.folder) == "string" then 
		data.folder = {data.folder}
	elseif data.folder == nil then
		data.folder = {}
		local parentFolders = dir(srcDir)
		for _, parentFolder in ipairs(parentFolders) do
			local secondFolders = dir(srcDir..s..parentFolder)
			for _, secondFolder in pairs(secondFolders) do
				data.folder[#data.folder + 1] = parentFolder..s..secondFolder
			end
		end
	elseif type(data.folder) ~= "table" then
		error("folder is not a string, table or nil")
	end

	local myTest
	local myFile

	local global_variables = {}
	local count_global = getn(_G)
	forEachElement(_G, function(idx)
		global_variables[idx] = true
	end)

	local ut = UnitTest{
		dbType = data.dbType,
		user = data.user,
		password = data.password,
		port = data.port,
		host = data.host
	}

	ut.package_functions = 0
	ut.functions_not_exist = 0
	ut.functions_not_tested = 0
	ut.executed_functions = 0
	ut.functions_with_global_variables = 0
	ut.functions_with_error = 0
	ut.functions_without_assert = 0
	ut.examples = 0
	ut.examples_error = 0

	-- For each test in each file in each folder, execute the test
	for _, eachFolder in ipairs(data.folder) do
		local dirFiles = dir(srcDir..s..eachFolder)
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
			-- TODO: o teste abaixo supoe que eachFile existe. Fazer este teste e ignorar caso nao exista.
			local tests = dofile(srcDir..s..eachFolder..s..eachFile)

			if type(data.test) == "string" then
				myTest = {data.test}
			elseif data.test == nil then
				myTest = {}	
				forEachOrderedElement(tests, function(index, value, mtype)
					myTest[#myTest + 1] = index 					
				end)
			elseif type(test) == "table" then
				myTest = test
			else
				error("test is not a string, table or nil")
			end

			for _, eachTest in ipairs(myTest) do
				print("Testing "..eachTest)

				if testfunctions[eachFile] and testfunctions[eachFile][eachTest] then
					testfunctions[eachFile][eachTest] = testfunctions[eachFile][eachTest] + 1
				elseif testfunctions[eachFile] then
					print_red("Function does not exist in the source code.")
					ut.functions_not_exist = ut.functions_not_exist + 1
				end

				local count_test = ut.test

				collectgarbage("collect")
				local ok_execution, err = pcall(function() tests[eachTest](ut) end)
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

	-- checking if all source code functions were tested
	if type(data.file) == "string" then
		print_green("Checking functions from lua"..s..data.file)
		forEachElement(testfunctions[data.file], function(idx, value)
			ut.package_functions = ut.package_functions + 1
			if value == 0 then
				print_red("Function '"..idx.."' is not tested.")
				ut.functions_not_tested = ut.functions_not_tested + 1
			end
		end)
	elseif type(data.file) == "table" then
		forEachElement(data.file, function(idx, value)
			print_green("Checking functions from lua"..s..value)
			forEachElement(testfunctions[value], function(midx, mvalue)
				ut.package_functions = ut.package_functions + 1
				if mvalue == 0 then
					print_red("Function '"..midx.."' is not tested.")
					ut.functions_not_tested = ut.functions_not_tested + 1
				end
			end)
		end)
	elseif data.file == nil then
		forEachElement(testfunctions, function(idx, value)
			print_green("Checking functions from lua"..s..idx)
			forEachElement(value, function(midx, mvalue)
				ut.package_functions = ut.package_functions + 1
				if mvalue == 0 then
					print_red("Function '"..midx.."' is not tested.")
					ut.functions_not_tested = ut.functions_not_tested + 1
				end
			end)
		end)
	end

	-- executing examples
	if examples then
		print_green("Testing examples")
		local dirFiles = dir(baseDir..s.."examples")
		forEachElement(dirFiles, function(idx, value)
			print("Testing "..value)
			io.flush()
			collectgarbage("collect")
			
			ut.examples = ut.examples + 1
			local ok_execution, err = pcall(function() include(baseDir..s.."examples"..s..value) end)
			
			if not ok_execution then
				ut.examples_error = ut.examples_error + 1
				print_red(err)
			end
		end)
	else
		print_yellow("Skipping examples")
	end

	print("\nReport:")
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

	if ut.functions_with_global_variables > 0 then
		print_red(ut.functions_with_global_variables.." out of "..ut.executed_functions.." tested functions create some global variable.")
	else
		print_green("No function creates any global variable.")
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

	if ut.functions_not_tested > 0 then
		print_red(ut.functions_not_tested.." out of "..ut.package_functions.." source code functions are not tested.")
	else
		print_green("All "..ut.package_functions.." functions of the package are tested.")
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
		print_green("No examples were executed.")
	end

	local errors = ut.fail + ut.functions_not_exist + ut.functions_not_tested + ut.examples_error +
	               ut.functions_with_global_variables + ut.functions_with_error + ut.functions_without_assert

	if errors == 0 then
		print_green("All tests were succesfully executed.")
	elseif errors == 1 then
		print_red("Summing up, one problem was found during the tests.")
	else
		print_red("Summing up, "..errors.." problems were found during the tests.")
	end
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

local VERSION = "1.3.1"

-- RAIAN implementar
execute = function(parameters) -- parameters is a string
	-- implementa o sessionInfo
	-- o execute vai chamar o build, test, etc.
end

packageInfo = function(package)
	local s = sessionInfo().separator
	local file = sessionInfo().path..s.."packages"..s..package..s.."description.lua"
	
	return include(file)

	--forEachOrderedElement(ns, function(idx, value)
	--	print(idx..": "..value)
	--end)
end

--TODO: Raian-Diretorio onde ficarao instalados os pacotes nao deveria ser um campo desta tabela? 
sessionInfo = function()
	result = {
		mode = "normal",
		version = VERSION,
		dbVersion = "1_3_1", -- TODO: remove this parameter?
		separator = package.config:sub(1, 1),
		path = os.getenv("TME_PATH")
	}
	return result
	-- atualizar todos os arquivos que usam as variaveis globais por uma chamada a esta funcao
	-- remover as variaveis globais TME_MODE, ...
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

require("base")

