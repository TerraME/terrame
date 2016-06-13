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

local assert,  ipairs, tostring, tonumber, type = assert, ipairs, tostring, tonumber, type
local io, pairs, os = io, pairs, os
local string, mkDir = string, mkDir
local table = table
local print = print
local printNote, printError, getn, belong = _Gtme.printNote, _Gtme.printError, getn, belong
local forEachElement = forEachElement
local forEachOrderedElement = forEachOrderedElement
local include = _Gtme.include
local makepath = _Gtme.makePathCompatibleToAllOS

local s = sessionInfo().separator
local ppath = packageInfo("luadoc").path
local lp = include(ppath..s.."lua"..s.."main"..s.."lp.lua")
local highlighting = include(ppath..s.."lua"..s.."doclet"..s.."highlighting.lua")
local util = include(ppath..s.."lua"..s.."main"..s.."util.lua")

-------------------------------------------------------------------------------
-- Looks for a file 'name' in given path. Removed from compat-5.1
-- @arg path String with the path.
-- @arg name String with the name to look for.
-- @return String with the complete path of the file found
--	or nil in case the file is not found.
--[[
local function search(path, name)
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
--]]

local function httpLink(text)
	local result = string.gsub(text, "http://[%w%.%-]+[%/%w~%-_.]*", function(value)
		if value:sub(-1, -1) == "." then
			value = value:sub(1, -2)
			return "<a href=\""..value.."\" target=\"_blank\">"..value.."</a>."
		else
			return "<a href=\""..value.."\" target=\"_blank\">"..value.."</a>"
		end
	end)

	return result
end

-------------------------------------------------------------------------------
-- Include the result of a lp template into the current stream.
function includeMod(template, env)
	-- template_dir is relative to package.path
	local templatepath = options.template_dir .. template
	
	-- search using package.path (modified to search .lp instead of .lua

	-- TODO: Verificar se compensa ter a possibilidade de se deixar os templates em outra pasta. 
	-- Assim o usuario poderia ter seu próprio template

	-- local search_path = string.gsub(package.path, "%.lua", "")
	-- local templatepath = search(search_path, templatepath)
	assert(templatepath, string.format("template '%s' not found", template))
	
	env = env or {}
	env.table = table
	env.io = io
	env.lp = lp
	env.ipairs = ipairs
	env.pairs = pairs
	env.forEachOrderedElement = forEachOrderedElement
	env.tonumber = tonumber
	env.tostring = tostring
	env.type = type
	env.luadoc = luadoc
	env.options = options
	env.print = print
	env.string = string
	env.util = util
	env.hl = highlighting
	env.httpLink = httpLink
	-- Adding luadoc functions in the environment
	env.luadoc = {
		link = link,
		include = includeMod,
		file_link = file_link,
		symbol_link = symbol_link,
		link_description = link_description,
		module_link = module_link
	}

	return lp.include(templatepath, env)
end

-------------------------------------------------------------------------------
-- Returns a link to a html file, appending "../" to the link to make it right.
-- @arg html Name of the html file to link to
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
-- @arg modulename Name of the module to be processed, may be a .lua file or
-- a .luadoc file.
-- @return name of the generated html file for the module
function module_link (modulename, doc, from)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(modulename)
	assert(doc)
	from = from or ""

	if (doc.modules[modulename] == nil and getn(doc.modules) > 0) or getn(doc.modules) == 0 then
		-- printError(string.format("unresolved reference to module '%s'", modulename))
		return
	end
	
	local href = "modules/" .. modulename .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function file_func_link(symbol, doc, _, from, doc_report)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(symbol)
	assert(doc)
	from = from or ""
	local _, _, filename, funcname = string.find(symbol, "^(.-)[%.%:]?([^%:]*)$")
	funcname = string.gsub(funcname, "(%(.-%))", "")
	funcname = string.gsub(funcname, "%s*$", "")
	if filename == "" then filename = funcname end
	if doc.files[filename .. ".lua"] == nil then
		if not string.match(symbol, "%.") and not string.match(symbol, "%(")then
			printError(string.format("Invalid link to '%s'", filename))
			doc_report.wrong_links = doc_report.wrong_links + 1
		end
		return "unresolved"
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
-- @arg to Name of the file to be processed, may be a .lua file or
-- a .luadoc file.
-- @arg from path of where am I, based on this we append ..'s to the
-- beginning of path
-- @return name of the generated html file
function file_link(to, from)
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
-- @arg fname name of the function or table to link to.
-- @arg doc documentation table
-- @arg kind String specying the kinf of element to link ("functions" or "tables").
function link_to(fname, doc, module_doc, file_doc, from, kind)
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
	
	local _, _, modulename, mfname = string.find(fname, "^(.-)[%.%:]?([^%.%:]*)$")
	assert(mfname)
  
	-- if mfname does not specify a module, use the module_doc
	if string.len(modulename) == 0 and module_doc then
		modulename = module_doc.name
	end

	local mmodule_doc = doc.modules[modulename]
	if not mmodule_doc then
		-- printError(string.format("Reference not found to function '%s' of module '%s'", mfname, modulename))
		return
	end
	
	for _, func_name in pairs(mmodule_doc[kind]) do
		if func_name == mfname then
			return module_link(modulename, doc, from) .. "#" .. mfname
		end
	end
	
	-- printError(string.format("Reference not found to function '%s' of module '%s'", mfname, modulename))
end

-------------------------------------------------------------------------------
-- Make a link to a file, module or function
function symbol_link(symbol, doc, module_doc, file_doc, from, name, doc_report)
	assert(symbol)
	assert(doc)
	doc_report.links = doc_report.links + 1
	local href = 
		-- file_link(symbol, from) or
		module_link(symbol, doc, from) or 
		file_func_link(symbol, doc, file_doc, from, doc_report) or
		link_to(symbol, doc, module_doc, file_doc, from, "functions") or
		link_to(symbol, doc, module_doc, file_doc, from, "tables")

	if not href or (name == "inherits" and href == "unresolved") then
		-- it is necessary to check inherits because there can exist
		-- deprecated functions with unresolved links, which is ok
		printError(string.format("In '%s()', invalid link to '%s'", name, symbol))
		doc_report.wrong_links = doc_report.wrong_links + 1
	end

	return href or "unresolved"
end

function link_description(description, doc, module_doc, file_doc, from, new_tab, name, doc_report)
	if new_tab then
		types_linked = {}
	else
		types_linked = types_linked or {}
	end
	local word_table = {}
	local description_linked = description
	local fname = string.match(file_doc.name, "(.-)%.lua")
	
	--for word in string.gmatch(description, "[%a_][%w_]-[%.%:][%a_][%w_]-%(%s-%)") do
	for token, signature, te_type, func_name, braces in string.gmatch(description, "((([%u][%w_]-)[%.%:]([%a_][%w_]-))(%(.-%)))") do
		local href = symbol_link(signature, doc, module_doc, file_doc, from, name, doc_report)
		local anchor

		if doc.files[te_type..".lua"] and doc.files[te_type..".lua"].functions[te_type] then -- it is a type
			if te_type == name then
				local mtoken = string.sub(token, string.len(name) + 2, string.len(token))
				anchor = "<a href="..href..">"..mtoken.."</a>"
			else
				anchor = "<a href="..href..">"..token.."</a>"
			end
		else -- it is a file of functions
			anchor = "<a href="..href..">"..func_name..braces.."</a>"
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
		if doc.files.funcnames[type_name] or doc.files[file_name_link] and doc.files[file_name_link].type ~= "model" then
			if type_name == fname or word_table[type_name] or types_linked[type_name] then
				table.insert(word_table, token)
			else
				local href 
				if doc.files[file_name_link] then
					href = file_link(file_name_link, from)
				else
					href = symbol_link(type_name, doc, module_doc, file_doc, from, name, doc_report)
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
	
	description_linked = httpLink(description_linked)

	return description_linked
end

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file(filename)
	local h = filename
	h = string.gsub(h, "lua$", "html")
	h = string.gsub(h, "luadoc$", "html")
	h = "files/" .. h
--	h = options.output_dir .. string.gsub (h, "^.-([%w_]+%.html)$", "%1")
	local short_filepath = options.short_output_path..h
	h = options.output_dir..h
	return h, short_filepath
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_module(modulename)
	local h = modulename .. ".html"
	h = "modules/" .. h
	h = options.output_dir .. h
	return h
end

-----------------------------------------------------------------
-- Generate the output.
-- @arg doc Table with the structured documentation.
function start(doc, doc_report)
	-- Reserved words for parser
	if doc.files then

		if #doc.files.funcnames > 0 then
			highlighting.setWords(doc.files.funcnames)
		else
			local funcnames = {}
			forEachElement(doc.files, function(idx, value)
				if type(idx) == "number" or value.functions == nil then return end

				local func = idx:sub(1, -5)
				if belong(func, value.functions) then
					funcnames[func] = func
				end
			end)

			highlighting.setWords(funcnames)
		end
	end

	if doc.description.package == "base" then
		local base = highlighting.getBase()

		forEachElement(base, function(mtype)
			if type(mtype) == "number" then return end

			if not doc.files[mtype..".lua"] or doc.files[mtype..".lua"].type ~= "type" then
				printError("IMPORTANT: You have removed type '"..mtype.."' from package 'base'.")
				printError("Please update 'packages/luadoc/lua/doclet/highlighting.lua' and")
				printError("remove this type from a table called 'base'.")
				os.exit()
			end
		end)

		forEachElement(doc.files, function(idx, file)
			if type(idx) == "number" then return end

			if file.type == "type" then
				local mtype = string.sub(idx, 1, -5)
					if mtype ~= "funcn" and not base[mtype] then
					printError("IMPORTANT: You have added type '"..mtype.."' to package 'base'.")
					printError("Please update 'packages/luadoc/lua/doclet/highlighting.lua' and")
					printError("add this type to a table called 'base'.")
					os.exit()
				end
			end
		end)
	end

	printNote("Building and checking HTML files")

	-- Generate index file
	if (#doc.files > 0 or #doc.modules > 0) and (not options.noindexpage) then
		local filename = options.output_dir.."index.html"
		local short_fileName = options.short_output_path.."index.html"
		print(string.format("Building %s", makepath(short_fileName)))
		doc_report.html_files = doc_report.html_files + 1

		local f = util.openFile(filename, "w")
		assert(f, string.format("Could not open %s for writing", filename))
		io.output(f)
		includeMod("index.lp", { doc = doc, doc_report = doc_report })
		f:close()
	end
	
	-- Process modules
	if not options.nomodules then
		for _, modulename in ipairs(doc.modules) do
			local module_doc = doc.modules[modulename]
			-- assembly the filename
			local filename = out_module(modulename)
			print(string.format("Building %s", makepath(filename)))
			doc_report.html_files = doc_report.html_files + 1
			
			local f = util.openFile(filename, "w")
			assert(f, string.format("Could not open %s for writing", filename))
			io.output(f)
			includeMod("module.lp", { doc = doc, module_doc = module_doc, doc_report = doc_report })
			f:close()
		end
	end

	-- Process files
	if not options.nofiles then
		for _, filepath in ipairs(doc.files) do
			local file_doc = doc.files[filepath]

			if not belong(string.sub(filepath, 1, -5), doc.examples) and doc.files[filepath].type ~= "model" then
				-- assembly the filename
				local mfilepath, short_filepath = out_file(file_doc.name)
				print(string.format("Building %s", makepath(short_filepath)))

				doc_report.html_files = doc_report.html_files + 1
				
				local f = util.openFile(mfilepath, "w")
				assert(f, string.format("Could not open %s for writing", short_filepath))
				io.output(f)
				includeMod("file.lp", { doc = doc, file_doc = file_doc, doc_report = doc_report } )
				f:close()
			end
		end
	end

	-- Process examples
	if not options.nofiles and #doc.examples > 0 then
		local filename = options.output_dir..s.."files"..s.."examples.html"
		local short_fileName = options.short_output_path.."files"..s.."examples.html"
		print(string.format("Building %s", makepath(short_fileName)))
		doc_report.html_files = doc_report.html_files + 1

		local f = util.openFile(filename, "w")
		assert(f, string.format("Could not open %s for writing", filename))
		io.output(f)

		includeMod("examples.lp", { doc = doc })
		f:close()
	end

	if not options.nofiles and doc.mdata then
		local filename = options.output_dir..s.."files"..s.."data.html"
		local short_fileName = options.short_output_path.."files"..s.."data.html"
		print(string.format("Building %s", makepath(short_fileName)))
		doc_report.html_files = doc_report.html_files + 1

		local f = util.openFile(filename, "w")
		assert(f, string.format("Could not open %s for writing", filename))
		io.output(f)

		includeMod("data.lp", { doc = doc })
		f:close()
	end

	if not options.nofiles and doc.mfont then
		local filename = options.output_dir..s.."files"..s.."font.html"
		local short_fileName = options.short_output_path.."files"..s.."font.html"
		print(string.format("Building %s", makepath(short_fileName)))
		doc_report.html_files = doc_report.html_files + 1

		local f = util.openFile(filename, "w")
		assert(f, string.format("Could not open %s for writing", filename))
		io.output(f)

		includeMod("font.lp", { doc = doc })
		f:close()
	end

	-- Process models
	if not options.nofiles then
		local models = false
		for _, filepath in ipairs(doc.files) do
			if doc.files[filepath].type == "model" then
				models = true
			end
		end	

		if models then
			local filename = options.output_dir..s.."files"..s.."models.html"
			local short_fileName = options.short_output_path.."files"..s.."models.html"
			print(string.format("Building %s", makepath(short_fileName)))

			local f = util.openFile(filename, "w")
			assert(f, string.format("Could not open %s for writing", filename))
			io.output(f)

			file_doc = {name = "models"}
			includeMod("models.lp", { doc = doc, file_doc = file_doc })
			f:close()
		end
	end

	-- copy extra files
	files = {"Ubuntu-L.ttf", "UbuntuMono-R.ttf", "Ubuntu-license.txt"} 

	forEachElement(files, function(_, file)
		os.execute("cp '"..ppath.."/lua/doclet/html/"..file.."' '"..options.output_dir..file.."'")
	end)

	local f = util.openFile(options.output_dir.."luadoc.css", "w")
	io.output(f)
	includeMod("luadoc.css")
	f:close()

	-- Copy logo
	mkDir(makepath(doc.description.destination_logo))
	os.execute("cp \""..makepath(doc.description.logo.."\" \""..doc.description.destination_logo.."\""))
end

