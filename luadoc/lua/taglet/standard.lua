-------------------------------------------------------------------------------
-- @release $Id: standard.lua,v 1.39 2007/12/21 17:50:48 tomas Exp $
-------------------------------------------------------------------------------

local assert, pairs, tostring, type = assert, pairs, tostring, type
-- local util = require "luadoc.util"
-- local tags = require "luadoc.taglet.standard.tags"
local io = io
local table = table
local sessionInfo = sessionInfo
local attributes = attributes
local string = string
local print = print
local pairs = pairs
local ipairs = ipairs
local forEachElement = forEachElement
local print_yellow = print_yellow
local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."util.lua")
local tags = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."taglet"..s.."standard"..s.."tags.lua")
-- module 'luadoc.taglet.standard'

-------------------------------------------------------------------------------
-- Creates an iterator for an array base on a class type.
-- @param t array to iterate over
-- @param class name of the class to iterate over

function class_iterator (t, class)
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

-------------------------------------------------------------------------------
-- Checks if the line contains a function definition
-- @param line string with line text
-- @return function information or nil if no function definition found

local function check_function (line)
	line = util.trim(line)

	local info
	forEachElement(function_patterns, function (_, pattern)
		local r, _, l, id, param = string.find(line, pattern)
		if r ~= nil then
			-- remove self
			--~ table.foreachi(util.split("%s*,%s*", param), print)
			param = param:gsub("(self%s*,?%s*)", "")
			info = {
				name = id,
				private = (l == "local"),
				param = util.split("%s*,%s*", param),
			}
			return false
		end
	end)

	-- TODO: remove these assert's?
	if info ~= nil then
		assert(info.name, "function name undefined")
		assert(info.param, string.format("undefined parameter list for function `%s'", info.name))
	end

	return info
end

-------------------------------------------------------------------------------
-- Checks if the line contains a module definition.
-- @param line string with line text
-- @param currentmodule module already found, if any
-- @return the name of the defined module, or nil if there is no module 
-- definition

local function check_module (line, currentmodule)
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
		logger:debug(string.format("found module `%s'", modulename))
		return modulename
	end
	return currentmodule
end

-------------------------------------------------------------------------------
-- Extracts summary information from a description. The first sentence of each 
-- doc comment should be a summary sentence, containing a concise but complete 
-- description of the item. It is important to write crisp and informative 
-- initial sentences that can stand on their own
-- @param description text with item description
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
-- @param f file handle
-- @param line current line being parsed
-- @param modulename module already found, if any
-- @return current line
-- @return code block
-- @return modulename if found

local function parse_code (f, line, modulename)
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
-- @param block block with comment field
-- @return block parameter

local function parse_comment (block, first_line)

	-- get the first non-empty line of code
	local code 
	forEachElement(block.code, function(_, line)
		if not util.line_empty(line) then
			-- `local' declarations are ignored in two cases:
			-- when the `nolocals' option is turned on; and
			-- when the first block of a file is parsed (this is
			--	necessary to avoid confusion between the top
			--	local declarations and the `module' definition.
			if (options.nolocals or first_line) and line:find"^%s*local" then
				return false
			end
			code = line
			return false
		end
	end)
	
	-- parse first line of code
	if code ~= nil then
		local func_info = check_function(code)
		local module_name = check_module(code)
		if func_info then
			block.class = "function"
			block.name = func_info.name
			block.param = func_info.param
			block.private = func_info.private
		elseif module_name then
			block.class = "module"
			block.name = module_name
			block.param = {}
		else
			block.param = {}
		end
	else
		-- TODO: comment without any code. Does this means we are dealing
		-- with a file comment?
	end

	-- parse @ tags
	local currenttag = "description"
	local currenttext
	
	forEachElement(block.comment, function (_, line)
		-- armazena linha completa
		local example_code = line:gsub("^%s*%-+%s?", "")
		line = util.trim_comment(line)
		
		local r, _, tag, text = string.find(line, "@([_%w%.]+)%s+(.*)")
		if r ~= nil then
			-- found new tag, add previous one, and start a new one
			-- TODO: what to do with invalid tags? issue an error? or log a warning?
			tags.handle(currenttag, block, currenttext)
			
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
			assert(string.sub(currenttext, 1, 1) ~= " ", string.format("`%s', `%s'", currenttext, line))
		end
	end)
	tags.handle(currenttag, block, currenttext)
  
	-- extracts summary information from the description
	block.summary = parse_summary(block.description)
	assert(string.sub(block.description, 1, 1) ~= " ", string.format("`%s'", block.description))
	
	-- sort 
	if block.see	then table.sort(block.see)	end	
	if block.param	and block.param.named then
		table.sort(block.param, function(a, b) 
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
-- @param f file handle
-- @param line being parsed
-- @param modulename module already found, if any
-- @return line
-- @return block parsed
-- @return modulename if found

local function parse_block (f, line, modulename, first)
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
			block = parse_comment(block, first)

			return line, block, modulename
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	
	-- parse information in block comment
	block = parse_comment(block, first)
	
	return line, block, modulename, header
end

-------------------------------------------------------------------------------
-- Parses a file documented following luadoc format.
-- @param filepath full path of file to parse
-- @param doc table with documentation
-- @return table with documentation

function parse_file (filepath, doc)
	local blocks = {}
	local modulename = nil
	
	-- read each line
	local f = io.open(filepath, "r")
	local i = 1
	local line = f:read()
	local first = true
	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-%-") then
			-- reached a luadoc block
			local block
			line, block, modulename = parse_block(f, line, modulename, first)
			table.insert(blocks, block)
		else
			-- look for a module definition
			modulename = check_module(line, modulename)
			
			-- TODO: keep beginning of file somewhere
			
			line = f:read()
		end
		first = false
		i = i + 1
	end
	f:close()
	-- store blocks in file hierarchy
	assert(doc.files[filepath] == nil, string.format("doc for file `%s' already defined", filepath))
	table.insert(doc.files, filepath)
	doc.files[filepath] = {
		type = "file",
		name = filepath,
		doc = blocks,
--		functions = class_iterator(blocks, "function"),
--		tables = class_iterator(blocks, "table"),
	}
--
	local first = doc.files[filepath].doc[1]
	if first and modulename then
		doc.files[filepath].author = first.author
		doc.files[filepath].copyright = first.copyright
		doc.files[filepath].description = first.description
		doc.files[filepath].release = first.release
		doc.files[filepath].summary = first.summary
	end

	-- if module definition is found, store in module hierarchy
	if modulename ~= nil then
		if modulename == "..." then
				modulename = string.gsub (filepath, "%.lua$", "")
				modulename = string.gsub (modulename, "/", ".")
		end
		if doc.modules[modulename] ~= nil then
			-- module is already defined, just add the blocks
			table.foreachi(blocks, function (_, v)
				table.insert(doc.modules[modulename].doc, v)
			end)
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
	doc.files[filepath].functions = {}
	for f in class_iterator(blocks, "function")() do
		table.insert(doc.files[filepath].functions, f.name)
		doc.files[filepath].functions[f.name] = f
	end
	
	-- make tables variables
	doc.files[filepath].variables = {}
	for t in class_iterator(blocks, "variable")() do
		table.insert(doc.files[filepath].variables, t.name)
		doc.files[filepath].variables[t.name] = t
	end
	-- -- make tables table
	-- doc.files[filepath].tables = {}
	for t in class_iterator(blocks, "table")() do
		table.insert(doc.files[filepath].variables, t.name)
		doc.files[filepath].variables[t.name] = t
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
-- @param filepath full path of the file to parse
-- @param doc table with documentation
-- @return table with documentation
-- @see parse_file

function file (filepath, doc)
	local patterns = { "%.lua$", "%.luadoc$" }
	local valid = false
	forEachElement(patterns, function(_, pattern)
		if string.find(filepath, pattern) ~= nil then
			valid = true
		end
		return valid
	end)
	
	if valid then
		-- logger:info(string.format("processing file `%s'", filepath))
		doc = parse_file(filepath, doc)
	end
	for _, filepath in ipairs(doc.files) do
		local description = check_header(filepath)
		doc.files[filepath].description = description
		doc.files[filepath].summary = parse_summary(description)
	end
	return doc
end

-------------------------------------------------------------------------------
-- Recursively iterates through a directory, parsing each file
-- @param path directory to search
-- @param doc table with documentation
-- @return table with documentation

function directory (path, doc)
	for f in dir(path) do
		local fullpath = path..s..f
		local attr = attributes(fullpath)
		assert(attr, string.format("error stating file `%s'", fullpath))
		
		if attr.mode == "file" then
			doc = file(fullpath, doc)
		elseif attr.mode == "directory" and f ~= "." and f ~= ".." then
			doc = directory(fullpath, doc)
		end
	end
	return doc
end

-- Sorts the documentation table
local function sort_doc (files)
	table.sort (files)
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

local function exclude_undoc(tab)
  for i = #tab, 1, -1 do
  	-- local doc_blocs = #tab[tab[i]].functions + #tab[tab[i]].tables + #tab[tab[i]].variables
  	local doc_blocs = #tab[tab[i]].functions + #tab[tab[i]].variables
    if doc_blocs == 0 then
      tab[tab[i]] = nil
      table.remove(tab, i)
    end
  end
end

-- report functions with no usage definition
local function check_usage(files)
	local no_usage = {}
	for i = 1, #files do
		local file_name = files[i]
		local functions = files[file_name].functions
		for j = 1, #functions do
			local function_name = functions[j]
			if not functions[function_name].usage then
				if not no_usage[file_name] then
					no_usage[file_name] = {}
					table.insert(no_usage, file_name)
				end
				table.insert(no_usage[file_name], function_name)
			end
		end
	end
	for i = 1, #no_usage do
		local file_name = no_usage[i]
		for j = 1, #no_usage[file_name] do
			local function_name = no_usage[file_name][j]
			print(file_name .. ": " .. "No @usage definition for '" .. function_name .. "'")
		end
	end
end

local function check_function_usage(files)
	for i = 1, #files do
		local file_name = files[i]
		local functions = files[file_name].functions
		for j = 1, #functions do
			local function_name = functions[j]
			local usage = functions[function_name].usage
			if type(usage) == "string" then
				if not string.match(usage, function_name) then
					local warning = "%s: '%s' does not call itself in its @usage"
					print_yellow(warning:format(file_name, function_name))
				end
			end
		end
	end
end

-- Check counting of columns on table of parameters
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

local function check_undoc_params(files)
	for i = 1, #files do
		local file_name = files[i]
		local functions = files[file_name].functions
		for j = 1, #functions do
			local function_name = functions[j]
			local params = functions[function_name].param
			if type(params) == "table" and not params.named then
				for k = 1, #params do
					if not params[params[k]] then
						local warning = "%s: '%s' has undocumented parameter '%s'"
						print_yellow(warning:format(file_name, function_name, params[k]))
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
	f = io.open(filepath)
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
		print "No description on @header"
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
	f:close()
	return text
end

-------------------------------------------------------------------------------
function start (files, package_path)
	local s = sessionInfo().separator
	assert(files, "file list not specified")
	
	-- Create an empty document, or use the given one
	-- doc = doc or {
	local doc = {
		files = {},
		modules = {},
	}
	assert(doc.files, "undefined `files' field")
	assert(doc.modules, "undefined `modules' field")
	
	--table.foreachi(files, function (_, path)
	for _, file_ in ipairs(files) do
		local file_path = package_path..s.."lua"..s..]]file_
		local attr = attributes(file_path)
		assert(attr, string.format("error stating path `%s'", file_path))
		
		if attr.mode == "file" then
			doc = file(file_path, doc)
		elseif attr.mode == "directory" then
			doc = directory(file_path, doc)
		end
	--end)
	end
	
	-- exclude undocumented files
	exclude_undoc(doc.files)

	-- sort documentation
	sort_doc(doc.files)
	sort_doc(doc.modules)


	reserved_words(doc.files)

	-- Warnings
	check_usage(doc.files)
	check_undoc_params(doc.files)
	check_function_usage(doc.files)
	check_tab_cols(doc.files)
	check_constructor_file(doc)
	return doc
end
