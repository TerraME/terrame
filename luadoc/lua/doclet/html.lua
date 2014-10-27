-------------------------------------------------------------------------------
-- Doclet that generates HTML output. This doclet generates a set of html files
-- based on a group of templates. The main templates are: 
-- <ul>
-- <li>index.lp: index of modules and files;</li>
-- <li>file.lp: documentation for a lua file;</li>
-- <li>module.lp: documentation for a lua module;</li>
-- <li>function.lp: documentation for a lua function. This is a 
-- sub-template used by the others.</li>
-- </ul>
--
-- @release $Id: html.lua,v 1.29 2007/12/21 17:50:48 tomas Exp $
-------------------------------------------------------------------------------

local assert, getfenv, ipairs, loadstring, setfenv, tostring, tonumber, type = assert, getfenv, ipairs, loadstring, setfenv, tostring, tonumber, type
local io, pairs, os = io, pairs, os
local package, string, mkdir = package, string, mkdir
local table = table
local print =  print
local printNote, printError, getn = printNote, printError, getn

local s = sessionInfo().separator
local lp = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."lp.lua")
local highlighting = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."doclet"..s.."highlighting.lua")
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."util.lua")

-------------------------------------------------------------------------------
-- Looks for a file `name' in given path. Removed from compat-5.1
-- @param path String with the path.
-- @param name String with the name to look for.
-- @return String with the complete path of the file found
--	or nil in case the file is not found.

local function search (path, name)
	for c in string.gmatch(path, "[^;]+") do
		c = string.gsub(c, "%?", name)
		local f = io.open(c)
		if f then   -- file exist?
			f:close()
			return c
		end
	end
	return nil    -- file not found
end

-------------------------------------------------------------------------------
-- Include the result of a lp template into the current stream.

function includeMod (template, env)
	-- template_dir is relative to package.path
	local templatepath = options.template_dir .. template
	
	-- search using package.path (modified to search .lp instead of .lua

	-- TODO: Verificar se compensa ter a possibilidade de se deixar os templates em outra pasta. 
	-- Assim o usuario poderia ter seu próprio template

	-- local search_path = string.gsub(package.path, "%.lua", "")
	-- local templatepath = search(search_path, templatepath)
	assert(templatepath, string.format("template `%s' not found", template))
	
	env = env or {}
	env.table = table
	env.io = io
	env.lp = lp
	env.ipairs = ipairs
	env.tonumber = tonumber
	env.tostring = tostring
	env.type = type
	env.luadoc = luadoc
	env.options = options
	env.print = print
	env.string = string
	env.util = util
	env.hl = highlighting
	-- Adding luadoc functions in the environment
	env.luadoc = {}
	env.luadoc.link = link
	env.luadoc.include = includeMod
	env.luadoc.file_link = file_link
	env.luadoc.symbol_link = symbol_link
	env.luadoc.link_description = link_description
	env.luadoc.module_link = module_link
	return lp.include(templatepath, env)
end

-------------------------------------------------------------------------------
-- Returns a link to a html file, appending "../" to the link to make it right.
-- @param html Name of the html file to link to
-- @return link to the html file

function link (html, from)
	local h = html
	from = from or ""
	string.gsub(from, "/", function () h = "../" .. h end)
	return h
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a module.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param modulename Name of the module to be processed, may be a .lua file or
-- a .luadoc file.
-- @return name of the generated html file for the module

function module_link (modulename, doc, from)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(modulename)
	assert(doc)
	from = from or ""

	if doc.modules[modulename] == nil and getn(doc.modules) > 0 then
		printError(string.format("unresolved reference to module `%s'", modulename))
		return
	end
	
	local href = "modules/" .. modulename .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function file_func_link (symbol, doc, file_doc, from)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(symbol)
	assert(doc)
	from = from or ""
	local _,_,filename, funcname = string.find(symbol, "^(.-)[%.%:]?([^%.%:]*)$")
	funcname = string.gsub(funcname, "(%(.-%))", "")
	funcname = string.gsub(funcname, "%s*$", "")
	if filename == "" then filename = funcname end
	if doc.files[filename .. ".lua"] == nil then
		printError(string.format("unresolved reference to module `%s'", modulename))
		-- print(file_doc.name .. ": unresolved reference to " .. filename)
		return
	end
	
	local functions = doc.files[filename..".lua"]["functions"]
	if filename ~= funcname and not functions[funcname] then
		--print(string.format("%s: unresolved reference to %s",	file_doc.name, symbol))
			return
	end
	
	local href = "files/" .. filename .. ".html"
	if filename ~= funcname then 
		href = href .. "#" .. funcname
	end
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a lua(doc) file.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param to Name of the file to be processed, may be a .lua file or
-- a .luadoc file.
-- @param from path of where am I, based on this we append ..'s to the
-- beginning of path
-- @return name of the generated html file

function file_link (to, from)
	assert(to)
	from = from or ""
	
	local href = to
	href = string.gsub(href, "lua$", "html")
	href = string.gsub(href, "luadoc$", "html")
	href = "files/" .. href
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns a link to a function or to a table
-- @param fname name of the function or table to link to.
-- @param doc documentation table
-- @param kind String specying the kinf of element to link ("functions" or "tables").

function link_to (fname, doc, module_doc, file_doc, from, kind)
	assert(fname)
	assert(doc)
	from = from or ""
	kind = kind or "functions"
	
	if file_doc and file_doc[kind] then
		for _, func_name in pairs(file_doc[kind]) do
			if func_name == fname then
				return file_link(file_doc.name, from) .. "#" .. fname
			end
		end
	end
	
	local _, _, modulename, fname = string.find(fname, "^(.-)[%.%:]?([^%.%:]*)$")
	assert(fname)
  
	-- if fname does not specify a module, use the module_doc
	if string.len(modulename) == 0 and module_doc then
		modulename = module_doc.name
	end

	local module_doc = doc.modules[modulename]
	if not module_doc then
		printError(string.format("unresolved reference to function `%s': module `%s' not found", fname, modulename))
		return
	end
	
	for _, func_name in pairs(module_doc[kind]) do
		if func_name == fname then
			return module_link(modulename, doc, from) .. "#" .. fname
		end
	end
	
	printError(string.format("unresolved reference to function `%s' of module `%s'", fname, modulename))
end

-------------------------------------------------------------------------------
-- Make a link to a file, module or function

function symbol_link (symbol, doc, module_doc, file_doc, from)
	assert(symbol)
	assert(doc)
	local href = 
--		file_link(symbol, from) or
		module_link(symbol, doc, from) or 
	file_func_link(symbol, doc, file_doc, from) or
		link_to(symbol, doc, module_doc, file_doc, from, "functions") or
		link_to(symbol, doc, module_doc, file_doc, from, "tables")
  
	if not href then
		printError(string.format("unresolved reference to symbol `%s'", symbol))
		printError(string.format("%s: unresolved reference to symbol '%s'", file_doc.name, symbol))
	end
	
	return href or ""
end

function link_description(description, doc, module_doc, file_doc, from, new_tab)
	if new_tab then
		types_linked = {}
	else
		types_linked = types_linked or {}
	end
	local word_table = { }
	local description_linked = description
	local fname = string.match(file_doc.name, "(.-)%.lua")
	
	--for word in string.gmatch(description, "[%a_][%w_]-[%.%:][%a_][%w_]-%(%s-%)") do
	for token, signature, te_type, func_name, braces in string.gmatch(description, "((([%u][%w_]-)[%.%:]([%a_][%w_]-))(%(.-%)))") do
		local href = symbol_link(signature, doc, module_doc, file_doc, from)
		local anchor
		if te_type == "Utils" then
			anchor = "<a href="..href..">"..func_name..braces.."</a>"
		else
			anchor = "<a href="..href..">"..token.."</a>"
		end
		table.insert(word_table, anchor)
		token = string.gsub(token, "([%(%)])", "%%%1")
		word_table[token] = #word_table
		description_linked = string.gsub(description_linked, token, "$"..#word_table.."$", 1)
	end
	
	--find types
	for token in string.gmatch(description_linked, "%u[%a_]+") do
		local type_name = string.gsub(token, "ies$", "y")
		local file_name_link = type_name .. ".lua"
		type_name = string.gsub(type_name, "s$", "")
		if doc.files.funcnames[type_name] or doc.files[file_name_link] then
			if type_name == fname or word_table[type_name] or types_linked[type_name] then
				table.insert(word_table, token)
			else
				local href 
				if doc.files[file_name_link] then
					href = file_link(file_name_link, from)
				else
					href = symbol_link (type_name, doc, module_doc, file_doc, from)
				end
				local anchor = "<a href="..href..">"..token.."</a>"
				table.insert(word_table, anchor)
			end
			types_linked[type_name] = type_name
			word_table[token] = #word_table
			description_linked = string.gsub(description_linked, token, "$"..#word_table.."$", 1)
		end
	end
	description_linked = string.gsub(description_linked,"%$(%d-)%$", function(key)
		return word_table[tonumber(key)]
	end)
	
	return description_linked
end

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file (filename)
	local h = filename
	h = string.gsub(h, "lua$", "html")
	h = string.gsub(h, "luadoc$", "html")
	local short_filepath = h
	h = "files/" .. h
--	h = options.output_dir .. string.gsub (h, "^.-([%w_]+%.html)$", "%1")
	h = options.output_dir..h
	short_filepath = options.short_output_path..short_filepath
	return h, short_filepath
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_module (modulename)
	local h = modulename .. ".html"
	h = "modules/" .. h
	h = options.output_dir .. h
	return h
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
	-- Reserveds words for parser
	if doc.files then
		highlighting.setWords(doc.files.funcnames)
	end

	-- Generate index file
	if (#doc.files > 0 or #doc.modules > 0) and (not options.noindexpage) then
		local filename = options.output_dir.."index.html"
		local short_fileName = options.short_output_path.."index.html"
		printNote(string.format("generating file `%s'", short_fileName))
		local f = util.openFile(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		includeMod("index.lp", { doc = doc })
		f:close()
	end
	
	-- Process modules
	if not options.nomodules then
		for _, modulename in ipairs(doc.modules) do
			local module_doc = doc.modules[modulename]
			-- assembly the filename
			local filename = out_module(modulename)
			printNote(string.format("generating file `%s'", filename))
			
			local f = util.openFile(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			includeMod("module.lp", { doc = doc, module_doc = module_doc })
			f:close()
		end
	end

	-- Process files
	if not options.nofiles then
		for _, filepath in ipairs(doc.files) do
			local file_doc = doc.files[filepath]
			-- assembly the filename
			local filepath, short_filepath = out_file(file_doc.name)
			printNote(string.format("generating file `%s'", short_filepath))
			
			local f = util.openFile(filepath, "w")
			assert(f, string.format("could not open `%s' for writing", short_filepath))
			io.output(f)
			includeMod("file.lp", { doc = doc, file_doc = file_doc } )
			f:close()
		end
	end
	
	-- copy extra files
	local f = util.openFile(options.output_dir.."luadoc.css", "w")
	io.output(f)
	includeMod("luadoc.css")
	f:close()

	-- Copy logo
	mkdir(doc.description.destination_logo)
	os.execute("cp "..doc.description.logo.." "..doc.description.destination_logo)
end
