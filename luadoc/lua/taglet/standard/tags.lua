-------------------------------------------------------------------------------
-- Handlers for several tags
-- @release $Id: tags.lua,v 1.8 2007/09/05 12:39:09 tomas Exp $
-------------------------------------------------------------------------------

-- local luadoc = require "luadoc"
-- local util = require "luadoc.util"
-- local string = require "string"
-- local table = require "table"
local assert, type, tostring = assert, type, tostring
local print = print
local pairs = pairs
local string = string
local table = table
local forEachElement = forEachElement
local s = sessionInfo().separator
local print_yellow = print_yellow
local print_red = print_red
local io = io
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."util.lua")
-- module "luadoc.taglet.standard.tags"

-------------------------------------------------------------------------------

local function author (tag, block, text)
	block[tag] = block[tag] or {}
	if not text then
		print_yellow("Warning: author `name' not defined [["..text.."]]: skipping")
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
		print_yellow("documenting `field' for block that is not a `table'")
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

local function name (tag, block, text)
	if block[tag] and block[tag] ~= text then
		print_red(string.format("block name conflict: `%s' -> `%s'", block[tag], text))
		io.exit()
	end
	
	block[tag] = text
end

-------------------------------------------------------------------------------
-- Processes a parameter documentation.
-- @param tag String with the name of the tag (it must be "param" always).
-- @param block Table with previous information about the block.
-- @param text String with the current line beeing processed.

local function param (tag, block, text)
	block[tag] = block[tag] or {}
	-- TODO: make this pattern more flexible, accepting empty descriptions
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	if not name then
		print_yellow("Warning: parameter `name' not defined [["..text.."]]: skipping")
		return
	end
 
	-- match table(dot)parameter
	local param_tab, field = name:match("(.-)%.(.*)")
	if param_tab then
		name = field
		-- match documented parameter with declared parameter
		local i
		forEachElement(block[tag], function (idx, v)
			if v == param_tab then
				i = idx
				return false
			end
		end)

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

	forEachElement(block[tag], function (idx, v)
		if v == name then
			i = idx
			return false
		end
	end)
	if i == nil then
		print_yellow(string.format("Warning: documenting undefined parameter `%s'", name))
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
	
	local s = util.split("%s*,%s*", text)			
	
	forEachElement(s, function (_, v)
		table.insert(block[tag], v)
	end)
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
		print_yellow("Warning: output `name' not defined [["..text.."]]: skipping")
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
handlers["tab"] = tab
handlers["inherits"] = inherits

-------------------------------------------------------------------------------

function handle (tag, block, text)
	if not handlers[tag] then
		print_red(string.format("Error: undefined handler for tag `%s'", tag))
		io.exit()
		return
	end
--	assert(handlers[tag], string.format("undefined handler for tag `%s'", tag))
	return handlers[tag](tag, block, text)
end
