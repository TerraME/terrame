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

local dofileNamespace = function(file)
	local local_env = {}

	local oldmetatable = getmetatable(_G)
	setmetatable(_G, {__newindex = local_env, __index = local_env})
	dofile(file)
	setmetatable(_G, oldmetatable)

	return local_env
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

	if os.rename(package_path..s.."load.lua", package_path..s.."load.lua") then
		load_sequence = dofileNamespace(load_file)
		load_sequence = load_sequence.files
	else
		load_sequence = dir(package_path..s.."lua")
	end

	if load_sequence then
		for i, file in ipairs(load_sequence) do
			dofile(package_path..s.."lua"..s..file)
		end
	end

	-- executar a funcao onLoad() do pacote (esta funcao pode configurar algumas coisas e imprimir informacao
	-- de que o pacote foi carregado com sucesso).
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
	local function returnTest(folder,file)
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

-- RAIAN: FUncao do antonio que executa os testes. Devera ir para dentro da funcao test acima. Coloquei desta maneira 
-- para executar os testes sem alterar a chamada no lado C++ por enquanto. 
executeTests = function(fileName)
	--TODO: Colocar aqui o caminho para o pacote especificado. Por enquando esta direto para o base
	local s = sessionInfo().separator
	local baseDir = sessionInfo().path..s.."packages/base"
	local srcDir = baseDir..s.."tests"

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

	local data = dofileNamespace(fileName)

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

	-- For each test in each file in each folder, execute the test
	for _, eachFolder in ipairs(data.folder) do
		if type(data.file) == "string" then
			myFile = {data.file}
		elseif type(data.file) == "table" then
			myFile = data.file
		elseif data.file == nil then
			myFile = {}	
			local myFile2 = dir(srcDir..s..eachFolder)
			for _, eachFile in ipairs(myFile2) do
				myFile[#myFile + 1] = eachFile
			end
			
		else
			error("file is not a string, table or nil.")
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

				local my_function = function()
					tests[eachTest](ut)
				end

				ut.test = ut.test + 2
				local count_test = ut.test

				collectgarbage("collect")
				local ok_execution, err = pcall(my_function)

				if not ok_execution then
					print_red("Wrong execution, got error: '"..err.."'.")
					ut.fail = ut.fail + 1
				elseif count_test == ut.test then
					ut.fail = ut.fail + 1
					print_red("No asserts were found in the test.")
				else
					ut.success = ut.success + 1
				end

				if getn(_G) > count_global then
					ut.fail = ut.fail + 1
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

	print("\nReport:")
	if ut.fail > 0 then
		print_red("Tests: "..ut.test)
		print_red("Success: "..ut.success.." ("..round(ut.success/ut.test*100, 3).."%)")
		print_red("Fail: "..ut.fail.." ("..round(ut.fail/ut.test*100, 3).."%)")
	else
		print_green("Tests: "..ut.test)
		print_green("Success: "..ut.success.." (100%)")
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
	
	return dofileNamespace(file)

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

require("base")

