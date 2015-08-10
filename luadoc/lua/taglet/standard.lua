-------------------------------------------------------------------------------
-- @release $Id: standard.lua,v 1.39 2007/12/21 17:50:48 tomas Exp $
-------------------------------------------------------------------------------

local assert, tostring, type = assert, tostring, type
local collectgarbage = collectgarbage
local pcall = pcall
local exit = os.exit
local io, table, string = io, table, string
local ipairs, pairs, lfsdir = ipairs, pairs, lfsdir
local printNote, printError, printWarning = _Gtme.printNote, _Gtme.printError, _Gtme.printWarning
local print, attributes = print, attributes
local sessionInfo, belong = sessionInfo, belong
local include = _Gtme.include
local getn = getn
local forEachElement = forEachElement
local belong = belong
local traceback = _Gtme.traceback
local forEachFile = forEachFile
local makepath = _Gtme.makePathCompatibleToAllOS

local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."util.lua")
local tags = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."taglet"..s.."standard"..s.."tags.lua")

-------------------------------------------------------------------------------
-- Creates an iterator for an array base on a class type.
-- @arg t array to iterate over
-- @arg class name of the class to iterate over
function class_iterator(t, class)
	return function ()
		local i = 1
		return function ()
			while t[i] and t[i].class ~= class do
				i = i + 1
			end
			local v = t[i]
			i = i + 1
			return v
		end
	end
end

-- Patterns for function recognition
local identifiers_list_pattern = "%s*(.-)%s*"
local identifier_pattern = "[^%(%s]+"
local function_patterns = {
	"^()%s*function%s*("..identifier_pattern..")%s*%("..identifiers_list_pattern.."%)",
	"^%s*(local%s)%s*function%s*("..identifier_pattern..")%s*%("..identifiers_list_pattern.."%)",
	"^()%s*("..identifier_pattern..")%s*%=%s*function%s*%("..identifiers_list_pattern.."%)",
}

-- Patterns for Model recognition
local model_patterns = {
	"^()%s*("..identifier_pattern..")%s*%=%s*%a*Model%s*%{"
}

-------------------------------------------------------------------------------
-- Checks if the line contains a function definition
-- @arg line string with line text
-- @return function information or nil if no function definition found
local function check_function(line)
	line = util.trim(line)

	local info
	for _, pattern in ipairs(function_patterns) do
		local r, _, l, id, arg = string.find(line, pattern)
		if r ~= nil then
			-- remove self
			--~ table.foreachi(util.split("%s*,%s*", arg), print)
			arg = arg:gsub("(self%s*,?%s*)", "")
			info = {
				name = id,
				private = (l == "local"),
				arg = util.split("%s*,%s*", arg),
			}

			local replaceNameFunctions = {
				__add = "+",
				__sub = "-",
				__mul = "*",
				__div = "/",
				__mod = "%",
				__pow = "^",
				__unm = "-",
				__concat = "..",
				__len = "#",
				__eq = "==",
				-- __lt = "comparison operator",
				-- __le = "comparison operator",
				-- __index = "operator [] (index)"
				-- __newindex = "operator [] (index)"
				--__call = "call"
			}

			if replaceNameFunctions[info.name] ~= nil then
				info.name = replaceNameFunctions[info.name]
			end

			break
		end
	end

	-- TODO: remove these assert's?
	if info ~= nil then
		assert(info.name, "function name undefined")
		assert(info.arg, string.format("undefined argument list for function '%s'", info.name))
	end

	return info
end

-------------------------------------------------------------------------------
-- Checks if the line contains a Model definition
-- @arg line string with line text
-- @return function information or nil if no function definition found
local function check_model(line)
	line = util.trim(line)

	local info
	for _, pattern in ipairs(model_patterns) do
		local r, _, l, id, arg = string.find(line, pattern)
		if r ~= nil then
			info = {
				name = id,
				private = (l == "local"),
				arg = ""
			}

			break
		end
	end

	if info ~= nil then
		assert(info.name, "function name undefined")
		assert(info.arg, string.format("undefined argument list for function '%s'", info.name))
	end

	return info
end

-------------------------------------------------------------------------------
-- Checks if the line contains a module definition.
-- @arg line string with line text
-- @arg currentmodule module already found, if any
-- @return the name of the defined module, or nil if there is no module 
-- definition
local function check_module(line, currentmodule)
	line = util.trim(line)
	
	-- module"x.y"
	-- module'x.y'
	-- module[[x.y]]
	-- module("x.y")
	-- module('x.y')
	-- module([[x.y]])
	-- module(...)

	local r, _, modulename = string.find(line, "^module%s*[%s\"'(%[]+([^,\"')%]]+)")
	if r then
		-- found module definition
		printNote(string.format("found module '%s'", modulename))
		return modulename
	end
	return currentmodule
end

-------------------------------------------------------------------------------
-- Extracts summary information from a description. The first sentence of each 
-- doc comment should be a summary sentence, containing a concise but complete 
-- description of the item. It is important to write crisp and informative 
-- initial sentences that can stand on their own
-- @arg description text with item description
-- @return summary string or nil if description is nil

local function parse_summary (description)
	-- summary is never nil...
	description = description or ""
	
	-- append an " " at the end to make the pattern work in all cases
	description = description.." "

	-- read until the first period followed by a space or tab	
	local summary = string.match(description, "(.-%.)[%s\t]")
	
	-- if pattern did not find the first sentence, summary is the whole description
	summary = summary or description
	
	return summary
end

-------------------------------------------------------------------------------
-- @arg f file handle
-- @arg line current line being parsed
-- @arg modulename module already found, if any
-- @return current line
-- @return code block
-- @return modulename if found
local function parse_code(f, line, modulename)
	local code = {}
	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-%-") then
			-- reached another luadoc block, end this parsing
			return line, code, modulename
		else
			-- look for a module definition
			modulename = check_module(line, modulename)

			table.insert(code, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, code, modulename
end

-------------------------------------------------------------------------------
-- Parses the information inside a block comment
-- @arg block block with comment field
-- @return block argument
local function parse_comment(block, first_line, doc_report, silent)
	-- get the first non-empty line of code
	local code 
	for _, line in ipairs(block.code) do
		if not util.line_empty(line) then
			-- 'local' declarations are ignored in two cases:
			-- when the 'nolocals' option is turned on; and
			-- when the first block of a file is parsed (this is
			--	necessary to avoid confusion between the top
			--	local declarations and the 'module' definition.
			if (options.nolocals or first_line) and line:find("^%s*local") then
				return 
			end
			code = line
			break
		end
	end
	
	-- parse first line of code
	if code ~= nil then
		local func_info = check_function(code)
		local module_name = check_module(code)
		local model_info = check_model(code)
		if func_info then
			block.class = "function"
			block.name = func_info.name
			block.arg = func_info.arg
			block.private = func_info.private
		elseif module_name then
			block.class = "module"
			block.name = module_name
			block.arg = {}
		elseif model_info then
			block.class = "model"
			block.name = model_info.name
		else
			block.arg = {}
			return
		end
	else
		-- TODO: comment without any code. Does this means we are dealing
		-- with a file comment?
	end

	-- parse @ tags
	local currenttag = "description"
	local currenttext
	
	for _, line in ipairs(block.comment) do
		-- armazena linha completa
		local example_code = line:gsub("^%s*%-+%s?", "")
		line = util.trim_comment(line)
		
		local r, _, tag, text = string.find(line, "@([_%w%.]+)%s*(.*)")
		if r ~= nil then
			-- found new tag, add previous one, and start a new one
			-- TODO: what to do with invalid tags? issue an error? or log a warning?
			tags.handle(currenttag, block, currenttext, doc_report, silent)
			
			currenttag = tag
			currenttext = text
		else
			-- keep code indentation
			if currenttag == "usage" then
				example_code = string.gsub(example_code, "\n", "")
				currenttext = currenttext .. "\n" .. example_code
			else
				currenttext = util.concat(currenttext, line)
			end
			assert(string.sub(currenttext, 1, 1) ~= " ", string.format("'%s', '%s'", currenttext, line))
		end
	end
	tags.handle(currenttag, block, currenttext, doc_report, silent)
  
	-- extracts summary information from the description
	block.summary = parse_summary(block.description)
	assert(string.sub(block.description, 1, 1) ~= " ", string.format("'%s'", block.description))
	
	-- sort 
	if block.see	then table.sort(block.see)	end	
	if block.arg	and block.arg.named then
		table.sort(block.arg, function(a, b) 
			if a:match("^%W") then return false end
			if b:match("^%W") then return true end
			return a < b
		end)
	end
	if block.output	then table.sort(block.output)	end

	return block
end

-------------------------------------------------------------------------------
-- Parses a block of comment, started with ---. Read until the next block of
-- comment.
-- @arg f file handle
-- @arg line being parsed
-- @arg modulename module already found, if any
-- @return line
-- @return block parsed
-- @return modulename if found
local function parse_block(f, line, modulename, first, doc_report, silent)
	local block = {
		comment = {},
		code = {},
	}

	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-") == nil then
			-- reached end of comment, read the code below it
			-- TODO: allow empty lines
			line, block.code, modulename = parse_code(f, line, modulename)

			-- parse information in block comment
			block = parse_comment(block, first, doc_report, silent)

			return line, block, modulename
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	
	-- parse information in block comment
	block = parse_comment(block, first, doc_report, silent)
	
	return line, block, modulename, header
end

-------------------------------------------------------------------------------
-- Parses a file documented following luadoc format.
-- @arg filepath full path of file to parse
-- @arg doc table with documentation
-- @return table with documentation
function parse_file(luapath, fileName, doc, doc_report, short_lua_path, silent)
	local blocks = {}
	local modulename = nil
	fullpath = luapath..fileName
	
	-- read each line
	local f = io.open(fullpath, "r")
	if not f then
		printError("Could not load "..fullpath)
		exit()
	end
	local i = 1
	local line = f:read()
	local first = true
	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-%-") then
			-- reached a luadoc block
			local block
			local mline = line
			line, block, modulename = parse_block(f, line, modulename, first, doc_report, silent)
			table.insert(blocks, block)

			if block and block.name then
				if block.description:sub(block.description:len(), block.description:len()) ~= "." and not silent then
					printError("Description of '"..block.name.."' does not end with '.'")
					doc_report.wrong_descriptions = doc_report.wrong_descriptions + 1
				end

				if block.arg then
					forEachElement(block.arg, function(idx, value, mtype)
						if mtype == "string" and idx ~= "named" and type(idx) ~= "number" then
							if not belong(value:sub(value:len(), value:len()), {".", "?", ":"}) and not silent then
								printError("Description of argument '"..idx.."' in '"..block.name.."()' does end with '.', '?', nor ':'.")
								doc_report.wrong_descriptions = doc_report.wrong_descriptions + 1
							end
						end
					end)
				end
			elseif not string.find(mline, "^[\t ]*%-%-%-%-") and not silent then
				printError("Invalid documentation line: "..mline)
				doc_report.wrong_line = doc_report.wrong_line + 1
			end
		else
			-- look for a module definition
			modulename = check_module(line, modulename)
			
			-- TODO: keep beginning of file somewhere
			line = f:read()
		end
		first = false
		i = i + 1
	end
	io.close(f)
	-- store blocks in file hierarchy
	assert(doc.files[fileName] == nil, string.format("doc for file '%s' already defined", fileName))
	table.insert(doc.files, fileName)
	doc.files[fileName] = {
		type = "file",
		path = luapath,
		short_path = short_lua_path,
		name = fileName,
		doc = blocks,
--		functions = class_iterator(blocks, "function"),
--		tables = class_iterator(blocks, "table"),
	}
--
	local first = doc.files[fileName].doc[1]
	if first and modulename then
		doc.files[fileName].author = first.author
		doc.files[fileName].copyright = first.copyright
		doc.files[fileName].description = first.description
		doc.files[fileName].release = first.release
		doc.files[fileName].summary = first.summary
	end

	-- if module definition is found, store in module hierarchy
	if modulename ~= nil then
		if modulename == "..." then
				modulename = string.gsub (fileName, "%.lua$", "")
				modulename = string.gsub (modulename, "/", ".")
		end
		if doc.modules[modulename] ~= nil then
			-- module is already defined, just add the blocks
			for _, v in ipairs(blocks) do
				table.insert(doc.modules[modulename].doc, v)
			end
		else
			-- TODO: put this in a different module
			table.insert(doc.modules, modulename)
			doc.modules[modulename] = {
				type = "module",
				name = modulename,
				doc = blocks,
--				functions = class_iterator(blocks, "function"),
--				tables = class_iterator(blocks, "table"),
				author = first and first.author,
				copyright = first and first.copyright,
				description = "",
				release = first and first.release,
				summary = "",
			}
			
			-- find module description
			for m in class_iterator(blocks, "module")() do
				doc.modules[modulename].description = util.concat(
					doc.modules[modulename].description, 
					m.description)
				doc.modules[modulename].summary = util.concat(
					doc.modules[modulename].summary, 
					m.summary)
				if m.author then
					doc.modules[modulename].author = m.author
				end
				if m.copyright then
					doc.modules[modulename].copyright = m.copyright
				end
				if m.release then
					doc.modules[modulename].release = m.release
				end
				if m.name then
					doc.modules[modulename].name = m.name
				end
			end
			doc.modules[modulename].description = doc.modules[modulename].description or (first and first.description) or ""
			doc.modules[modulename].summary = doc.modules[modulename].summary or (first and first.summary) or ""
		end
		
		-- make functions table
		doc.modules[modulename].functions = {}
		for f in class_iterator(blocks, "function")() do
			table.insert(doc.modules[modulename].functions, f.name)

			if doc.modules[modulename].functions[f.name] and not silent then
				printError("Function "..f.name.." was already declared.")
				doc_report.duplicated_functions = doc_report.duplicated_functions + 1
			end
			doc.modules[modulename].functions[f.name] = f
		end
		
		-- make tables table
		doc.modules[modulename].tables = {}
		for t in class_iterator(blocks, "table")() do
			table.insert(doc.modules[modulename].tables, t.name)
			doc.modules[modulename].tables[t.name] = t
		end
	end
	
	-- make functions table
	doc.files[fileName].functions = {}
	for f in class_iterator(blocks, "function")() do
		if not silent then
			doc_report.functions = doc_report.functions + 1
		end
		table.insert(doc.files[fileName].functions, f.name)

		if doc.files[fileName].functions[f.name] and not silent then
			printError("Function "..f.name.." was already declared.")
			doc_report.duplicated_functions = doc_report.duplicated_functions + 1
		end
		doc.files[fileName].functions[f.name] = f
	end

	-- make models table
	doc.files[fileName].models = {}
	for f in class_iterator(blocks, "model")() do
		if not silent then
			doc_report.models = doc_report.models + 1
		end

		local a 

		pcall(function() a = include(fullpath) end)

		if type(a) == "table" then
			local quant = getn(a) - 1
			if quant > 0 and not silent then
				printError(fileName.." should contain only a Model, got "..quant.." additional object(s).")
				doc_report.model_error = doc_report.model_error + quant
			end
		end
		table.insert(doc.files[fileName].models, f.name)
		doc.files[fileName].models[f.name] = f
		doc.files[fileName].type = "model"
	end
	
	-- make tables variables
	doc.files[fileName].variables = {}
	for t in class_iterator(blocks, "variable")() do
		if not silent then
			doc_report.variables = doc_report.variables + 1
		end

		table.insert(doc.files[fileName].variables, t.name)
		doc.files[fileName].variables[t.name] = t
	end
	-- -- make tables table
	-- doc.files[filepath].tables = {}
	for t in class_iterator(blocks, "table")() do
		table.insert(doc.files[fileName].variables, t.name)
		doc.files[fileName].variables[t.name] = t
	end

	-- -- make tables table
	-- doc.files[filepath].tables = {}
	-- for t in class_iterator(blocks, "table")() do
	-- 	table.insert(doc.files[filepath].tables, t.name)
	-- 	doc.files[filepath].tables[t.name] = t
	-- end

	return doc
end

-------------------------------------------------------------------------------
-- Checks if the file is terminated by ".lua" or ".luadoc" and calls the 
-- function that does the actual parsing
-- @arg filepath full path of the file to parse
-- @arg doc table with documentation
-- @return table with documentation
-- @see parse_file
function file(lua_path, fileName, doc, short_lua_path, doc_report, silent)
	local patterns = { "%.lua$", "%.luadoc$" }
	local valid = false
	for _, pattern in ipairs(patterns) do
		if string.find(lua_path..fileName, pattern) ~= nil then
			valid = true
		end
		break
	end
	
	if valid then
		if not silent then
			print(string.format("Parsing %s", makepath(short_lua_path..fileName)))
			doc_report.lua_files = doc_report.lua_files + 1
		end

		doc = parse_file(lua_path, fileName, doc, doc_report, short_lua_path, silent)

		if string.find(short_lua_path, "examples") == nil then
			for _, file_ in ipairs(doc.files) do
				local description = check_header(doc.files[file_].path..file_)
				doc.files[file_].description = description
				doc.files[file_].summary = parse_summary(description)
			end
		else
			local description, argnames, argdescr = check_example(doc.files[fileName].path..fileName, doc, fileName, doc_report, silent)
			doc.files[fileName].description = description
			doc.files[fileName].argnames = argnames
			doc.files[fileName].argdescription = argdescr
			doc.files[fileName].summary = parse_summary(description)
			doc.files[fileName].type = "example"

			if not silent then
				doc_report.examples = doc_report.examples + 1
			end
		end
	elseif not valid and belong(fileName, doc.examples) then
		for i, j in ipairs(doc.examples) do
			if j == fileName then
				doc.examples[i] = "invalid"
			end
		end
	end
	return doc
end

-------------------------------------------------------------------------------
-- Recursively iterates through a directory, parsing each file
-- @arg path directory to search
-- @arg doc table with documentation
-- @return table with documentation
function directory(lua_path, file_, doc, short_lua_path, silent)
	forEachFile(lua_path, function(f)
		local fullpath = lua_path..f
		local attr = attributes(fullpath)
		assert(attr, string.format("error stating file '%s'", fullpath))
		
		if attr.mode == "file" then
			doc = file(lua_path, f, doc, short_lua_path, silent)
		elseif attr.mode == "directory" and f ~= "." and f ~= ".." then
			fullpath = fullpath..s
			doc = directory(fullpath, f, doc, short_lua_path, silent)
		end
	end)
	return doc
end

-- Sorts the documentation table
local function sort_doc(files)
	table.sort(files)
	-- sort list of functions by name alphabetically
	for f, doc in pairs(files) do
		if doc.functions then
			table.sort(doc.functions, function(a, b) 
				if a:match("^%W") then return false end
				if b:match("^%W") then return true end
				return a < b
			end)
		end
		if doc.tables then
			table.sort(doc.tables)
		end
		if doc.variables then
			table.sort(doc.variables)
		end
	end
end

-- Stores reserved words for parsing
local function reserved_words(tab)
	tab.funcnames = tab.funcnames or {}
		for i = 1, #tab do
			local doc = tab[tab[i]]
			if doc.functions and #doc.functions > 0 then
				for j = 1, #doc.functions do
				local name = doc.functions[j]
				tab.funcnames[name] = name
			end
		end
	end
end

local function exclude_undoc(tab, doc_report, doc)
	printNote("Checking undocumented files")
	for i = #tab, 1, -1 do
		local example = 0
		if tab[tab[i]].type == "example" and tab[tab[i]].description ~= "" then
			example = 1
		end

		local doc_blocs = #tab[tab[i]].functions + #tab[tab[i]].variables + example + #tab[tab[i]].models
		if doc_blocs == 0 then
			if tab[tab[i]].type == "example" then
				printError("Example "..tab[tab[i]].name.." is not documented.")
				doc_report.undoc_examples = doc_report.undoc_examples + 1
				for k, v in ipairs(doc.examples) do
					if v == tab[i] then
						table.remove(doc.examples, k)
					end
				end
			else
				printError("File "..tab[tab[i]].name.." is not documented.")
				doc_report.undoc_files = doc_report.undoc_files + 1
			end

			tab[tab[i]] = nil
			table.remove(tab, i)
		end
	end
end

-- report functions with no usage definition
local function check_usage(files, doc_report)
	local no_usage = {}
	printNote("Checking @usage definition")
	for i = 1, #files do
		local file_name = files[i]
		if files[file_name].type ~= "example" then
			print("Checking "..makepath(files[file_name].short_path..file_name))
			local functions = files[file_name].functions
			for j = 1, #functions do
				local function_name = functions[j]
				if not functions[function_name].usage then
					if not no_usage[file_name] then
						no_usage[file_name] = {}
						table.insert(no_usage, file_name)
					end
					table.insert(no_usage[file_name], function_name)
					printError("Function '"..function_name.."' has no @usage definition")
					doc_report.lack_usage = doc_report.lack_usage + 1
				end
			end
		end
	end
	for i = 1, #no_usage do
		local file_name = no_usage[i]
		for j = 1, #no_usage[file_name] do
			local function_name = no_usage[file_name][j]
		end
	end
end

local function check_function_usage(files, doc_report)
	printNote("Checking calls to functions in @usage")
	for i = 1, #files do
		local file_name = files[i]
		if files[file_name].type ~= "example" then
			print("Checking "..makepath(files[file_name].short_path..file_name))
			local functions = files[file_name].functions
			for j = 1, #functions do
				local function_name = functions[j]
				local usage = functions[function_name].usage
				if type(usage) == "string" then
					if not string.match(usage, function_name) then
						local message = "%s: '%s' does not call itself in its @usage"
						printError(message:format(file_name, function_name))
						doc_report.no_call_itself_usage = doc_report.no_call_itself_usage + 1
					end
				end
			end
		end
	end
end

-- Check counting of columns on table of arguments
local function check_tab_cols(files)
	--for _, file_name in ipairs(files) do
		--local file = files[file_name]
		--for _, func_name in ipairs(file.functions) do
			--local func = file.functions[func_name]
			--if func.tab then
				--for _, tab_name in ipairs(func.tab) do
					--local tab = func.tab[tab_name]
					--for i = 1, (#tab - 1) do
						--if #tab[i] 	< #tab[i+1] then
							--print(file_name..":"..func_name.. " - inconsistent number of columns at table '".. tab_name.."'")
							--break
						--end
					--end
				--end
			--end
		--end
	--end
end

local function check_undoc_args(files, doc_report)
	printNote("Checking undocumented arguments")
	for i = 1, #files do
		local file_name = files[i]
		if files[file_name].type ~= "example" then
			print("Checking "..makepath(files[file_name].short_path..file_name))
			local functions = files[file_name].functions
			for j = 1, #functions do
				local function_name = functions[j]
				local args = functions[function_name].arg
				if type(args) == "table" and not args.named then
					doc_report.arguments = doc_report.arguments + #args
					for k = 1, #args do
						if not args[args[k]] then
							local warning = "Function '%s' has undocumented argument '%s'"
							printError(warning:format(function_name, args[k]))
							doc_report.undoc_arg = doc_report.undoc_arg + 1
						end
					end
				end
			end
		end
	end
end

-- Checks for a constructor (function with same name of file)
-- and changes the type of doc from "file" to "type"
local function check_constructor_file(doc)
	local files = doc.files
	for i = #files, 1, -1 do
		local file_name = files[i]
		local functions = files[file_name].functions
		for j = 1, #functions do
			if functions[j] == file_name:match("(.-)%.lua") then
				files[file_name].type = "type"
				doc.files[file_name].summary = functions[functions[j]].summary
				-- local file_doc = files[file_name]

				-- -- remove from doc.files
				-- files[file_name] = nil
				-- table.remove(files, i)

				-- -- insert into doc.types
				-- doc.types[file_name] = file_doc
				-- table.insert(doc.types, 1, file_name)
				-- doc.types[file_name].summary = functions[functions[j]].summary
				break
			end
		end
	end
end

function check_header(filepath)
	f = io.open(filepath, "r")

	if not f then
		collectgarbage()

		f = io.open(filepath, "r")

		if not f then
			printError("Could not load "..filepath)
			printError(traceback())
			exit()
		end
	end

	local line
	repeat
		line = f:read()
	until not line or line:match("^%s*%-%-%s*@header")

	local text = ""
	if line then
		text = line:match("@header(.*)")
		text = util.trim(text)
	else
		return text
	end

	if text == "" then
		printError("No description on @header")
		return text
	else
		line = f:read()
		while line and line:match("^%s*%-%-") do
			local next_text = line:match("%-%-(.*)")
			next_text = util.trim(next_text)
			text = text .. " " .. next_text
			line = f:read()
		end
	end
	io.close(f)
	return text
end

function check_example(filepath, doc, file_name, doc_report, silent)
	f = io.open(filepath)
	local line

	repeat
		line = f:read()
	until not line or line:match("^%s*%-%-%s*@example(.*)")

	local text = ""
	if line then
		text = line:match("@example(.*)")
		text = util.trim(text)
	else
		return text
	end

	local argnames = {}
	local argdescriptions = {}
	local readingArg = false
	local argName
	local argDescription = ""

	if text == "" then
		if not silent then
			printError("No description found in @example")
			doc_report.problem_examples = doc_report.problem_examples + 1
		end
		return text
	else
		line = f:read()
		while line and line:match("^%s*%-%-") do
			local next_text = line:match("%-%-(.*)")

			if line:match("%-%-(.*)@arg(.*)") then
				readingArg = true
			end

			next_text = util.trim(next_text)
			if readingArg then
				local r, _, tag, text = string.find(next_text, "@([_%w%.]+)%s*(.*)")
				if tag == nil then
					argDescription = argDescription.." "..next_text
				elseif tag == "arg" then
					if argDescription ~= "" then
						table.insert(argnames, argName)
						table.insert(argdescriptions, argDescription)
					end

					local _a, _b, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")

					if desc == nil or name == nil then
						if not silent then
							printError("Could not infer argument and description of @arg from '"..text.."'")
							doc_report.invalid_tags = doc_report.invalid_tags + 1	
						end
						argDescription = ""
					else
						argName = name
						argDescription = desc
					end
				else
					if not silent then
						printError("Invalid tag '@"..tag.."'. Examples can only have @arg.")
						doc_report.invalid_tags = doc_report.invalid_tags + 1
					end
					argDescription = ""
				end
			else
				text = text.." "..next_text
			end
			
			line = f:read()
		end
	end
	if argDescription ~= "" then
		table.insert(argnames, argName)
		table.insert(argdescriptions, argDescription)
	end
	io.close(f)
	return text, argnames, argdescriptions
end

-------------------------------------------------------------------------------
function start(files, examples, package_path, short_lua_path, doc_report, silent)
	local s = sessionInfo().separator
	assert(files, "file list not specified")
	local lua_path = package_path..s.."lua"..s
	local examples_path = package_path..s.."examples"..s
	local short_examples_path = "examples"..s
	
	-- Create an empty document, or use the given one
	local doc = {
		luapath = lua_path,
		files = {},
		modules = {},
		models = {},
		examples = examples
	}
	
	if not silent then
		printNote("Parsing lua files")
	end

	for _, file_ in ipairs(files) do
		local attr = attributes(lua_path..file_)
		assert(attr, string.format("error stating path '%s'", lua_path..file_))
		
		if attr.mode == "file" then
			doc = file(lua_path, file_, doc, short_lua_path, doc_report, silent)
		elseif attr.mode == "directory" then
			local dir_path = lua_path..file_..s
			local short_dir_path = short_lua_path..file_..s
			doc = directory(dir_path, file_, doc, short_dir_path, silent)
		end
	end

	if not silent then
		printNote("Parsing examples")
	end
	if #examples < 1 then
		if not silent then
			printWarning("No examples were found.")
		end
	else
		for _, file_ in ipairs(examples) do
			local mfile = file_..".lua"
			local attr = attributes(examples_path..mfile)
			assert(attr, string.format("error stating path '%s'", examples_path..file_))
			
			if attr.mode == "file" then
				doc = file(examples_path, mfile, doc, short_examples_path, doc_report, silent)
			elseif attr.mode == "directory" then
				local dir_path = examples_path..mfile..s
				local short_dir_path = short_examples_path..mfile..s
				doc = directory(dir_path, mfile, doc, short_dir_path, silent)
			end
		end
	end

	for i, j in ipairs(doc.examples) do
		if j == "invalid" then
			table.remove(doc.examples, i)
		end
	end
	
	if silent then return doc end

	-- exclude undocumented files
	exclude_undoc(doc.files, doc_report, doc)

	-- sort documentation
	sort_doc(doc.files)
	sort_doc(doc.modules)

	reserved_words(doc.files)

	-- Warnings
	check_usage(doc.files, doc_report)
	check_function_usage(doc.files, doc_report)
	check_undoc_args(doc.files, doc_report)
	check_tab_cols(doc.files)
	check_constructor_file(doc)
	return doc
end

