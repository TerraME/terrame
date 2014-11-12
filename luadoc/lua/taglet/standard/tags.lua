-------------------------------------------------------------------------------
-- Handlers for several tags
-- @release $Id: tags.lua,v 1.8 2007/09/05 12:39:09 tomas Exp $
-------------------------------------------------------------------------------

local assert, type, tostring, ipairs = assert, type, tostring, ipairs
local string, table = string, table
local printError = printError

local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."util.lua")

-------------------------------------------------------------------------------

local function author (tag, block, text)
	block[tag] = block[tag] or {}
	if not text then
		printError("Warning: author 'name' not defined [["..text.."]]: skipping")
		return
	end
	table.insert (block[tag], text)
end

-------------------------------------------------------------------------------
-- Set the class of a comment block. Classes can be "module", "function", "table",
-- "variable". The first two classes are automatic, extracted from the source code

local function class (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function copyright (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function description (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function release (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function inherits (tag, block, text)
	block[tag] = text  
end

-------------------------------------------------------------------------------

local function field (tag, block, text)
	if block["class"] ~= "table" then
		printError("documenting 'field' for block that is not a 'table'")
	end
	block[tag] = block[tag] or {}

	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	assert(name, "field name not defined")
	
	table.insert(block[tag], name)
	block[tag][name] = desc
end

-------------------------------------------------------------------------------
-- Set the name of the comment block. If the block already has a name, issue
-- an error and do not change the previous value

local function name (tag, block, text, doc_report)
	local differentNameFunctions = {
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

	local func_name = block[tag]

	if differentNameFunctions[func_name] ~= nil then
		func_name = differentNameFunctions[block[tag]]
	end

	if func_name and func_name ~= text then
		printError(string.format("Block name conflict: '%s' -> '%s'", block[tag], text))
		doc_report.block_name_conflict = doc_report.block_name_conflict + 1
	end
	
	block[tag] = text
end

-------------------------------------------------------------------------------
-- Processes a parameter documentation.
-- @param tag String with the name of the tag (it must be "param" always).
-- @param block Table with previous information about the block.
-- @param text String with the current line beeing processed.
local print = print
local function param (tag, block, text, doc_report)
	block[tag] = block[tag] or {}
	-- TODO: make this pattern more flexible, accepting empty descriptions
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	if not name then
		printError("parameter 'name' not defined [["..text.."]]: skipping")
		return
	end
 
	-- match table(dot)parameter
	local param_tab, field = name:match("(.-)%.(.*)")
	if param_tab then
		name = field
		-- match documented parameter with declared parameter
		local i
		for idx, v in ipairs(block[tag]) do
			if v == param_tab then
				i = idx
				break
			end
		end

		-- excludes table from the list of parameters
		if i then
			table.remove(block[tag],i)
			block[tag][param_tab] = nil
		end
		-- set to print name of the parameters
		block[tag].named = true
	end
  
	-- match documented parameter with declared parameter
	local i 
	for idx, v in ipairs(block[tag]) do
		if v == name then
			i = idx
			break
		end
	end
	if i == nil then
		if not param_tab then
			printError(string.format("Documenting undefined parameter '%s' in function '%s'", name, block.name))
			doc_report.undefined_param = doc_report.undefined_param + 1
		end
		table.insert(block[tag], name)
	end
	block[tag][name] = desc
end

-------------------------------------------------------------------------------

local function release (tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------

local function ret (tag, block, text)
	tag = "ret"
	if type(block[tag]) == "string" then
		block[tag] = { block[tag], text }
	elseif type(block[tag]) == "table" then
		table.insert(block[tag], text)
	else
		block[tag] = text
	end
end

-------------------------------------------------------------------------------
-- @see ret

local function see (tag, block, text)
	-- see is always an array
	block[tag] = block[tag] or {}
	
	-- remove trailing "."
	text = string.gsub(text, "(.*)%.$", "%1")
	
	local str = util.split("%s*,%s*", text)			
	
	for _, v in ipairs(str) do
		table.insert(block[tag], v)
	end
end

-------------------------------------------------------------------------------
-- @see ret

local function usage (tag, block, text)
	if type(block[tag]) == "string" then
		block[tag] = { block[tag], text }
	elseif type(block[tag]) == "table" then
		table.insert(block[tag], text)
	else
		block[tag] = text
	end
end

-------------------------------------------------------------------------------

local function output (tag, block, text)
	block[tag] = block[tag] or {}
	-- TODO: make this pattern more flexible, accepting empty descriptions
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	if not name then
		printError("output 'name' not defined [["..text.."]]: skipping")
		return
	end

	table.insert(block[tag], name)
	block[tag][name] = desc
end

-------------------------------------------------------------------------------

local function tab(tag, block, text)
	block[tag] = block[tag] or {}
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	--desc = desc:gsub("%s*([&\\])%s*", "%1")
	local rows = {}
	for line in desc:gmatch("[^\\]+") do
		local row = {}
		for item in line:gmatch("[^&]+") do
			item = item:match("^%s*(.-)%s*$")
			table.insert(row, item)
		end
		table.insert(rows, row)
	end
	table.insert(block[tag], name)
	block[tag][name] = rows
end

-------------------------------------------------------------------------------

local function deprecated(tag, block, text)
	block[tag] = block[tag] or {}
	table.insert(block[tag], true)

	-- remove trailing "."
	text = string.gsub(text, "(.*)%.$", "%1")
	
	local str = util.split("%s*,%s*", text)			
	
	for _, v in ipairs(str) do
		table.insert(block[tag], v)
	end
end

-------------------------------------------------------------------------------

local handlers = {}
handlers["author"] = author
handlers["class"] = class
handlers["copyright"] = copyright
handlers["description"] = description
handlers["field"] = field
handlers["name"] = name
handlers["param"] = param
handlers["release"] = release
handlers["return"] = ret
handlers["see"] = see
handlers["usage"] = usage
handlers["output"] = output
handlers["tabular"] = tab
handlers["inherits"] = inherits
handlers["deprecated"] = deprecated

-------------------------------------------------------------------------------

function handle (tag, block, text, doc_report)
	if not handlers[tag] then
		printError(string.format("Tag '%s' is invalid", tag))
		doc_report.invalid_tags = doc_report.invalid_tags + 1
		return
	end
	return handlers[tag](tag, block, text, doc_report)
end
