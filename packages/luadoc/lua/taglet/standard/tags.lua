-------------------------------------------------------------------------------
-- Handlers for several tags
-- @release $Id: tags.lua,v 1.8 2007/09/05 12:39:09 tomas Exp $
-------------------------------------------------------------------------------

local assert, type, tostring, ipairs = assert, type, tostring, ipairs
local string, table = string, table
local printError, pairs = _Gtme.printError, pairs
local include = _Gtme.include

local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."util.lua")

-------------------------------------------------------------------------------
local function author(tag, block, text, silent)
	block[tag] = block[tag] or {}
	if not text and not silent then
		printError("Warning: author 'name' not defined [["..text.."]]: skipping")
		return
	end
	table.insert (block[tag], text)
end

-------------------------------------------------------------------------------
-- Set the class of a comment block. Classes can be "module", "function", "table",
-- "variable". The first two classes are automatic, extracted from the source code
local function class(tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------
local function copyright(tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------
local function description(tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------
local function release(tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------
local function image(tag, block, text, doc_report, silent)
	if text == "" and not silent then
		printError("In "..block.name.."(), @image should be folowed by a file name")
		doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
	end
		
	if block[tag] == nil then
		block[tag] = text
	elseif not silent then
		printError("In "..block.name.."(), @image is used more than once and will be ignored in '"..text.."'")
		doc_report.duplicated = doc_report.duplicated + 1
	end
end

local function inherits(tag, block, text, doc_report, silent)
	if text == "" and not silent then
		printError("In "..block.name.."(), @inherits should be folowed by a type")
		doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
	end
		
	if block[tag] == nil then
		block[tag] = text
	elseif not silent then
		printError("In "..block.name.."(), @inherits is used more than once and will be ignored in '"..text.."'")
		doc_report.duplicated = doc_report.duplicated + 1
	end
end

-------------------------------------------------------------------------------
local function field(tag, block, text, silent)
	if block["class"] ~= "table" and not silent then
		printError("documenting 'field' for block that is not a 'table'")
	end
	block[tag] = block[tag] or {}

	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")

	if not silent then
		assert(name, "field name not defined")
	end	

	table.insert(block[tag], name)
	block[tag][name] = desc
end

-------------------------------------------------------------------------------
-- Set the name of the comment block. If the block already has a name, issue
-- an error and do not change the previous value

-- local function name (tag, block, text, doc_report)
-- 	local differentNameFunctions = {
-- 		__add = "+",
-- 		__sub = "-",
-- 		__mul = "*",
-- 		__div = "/",
-- 		__mod = "%",
-- 		__pow = "^",
-- 		__unm = "-",
-- 		__concat = "..",
-- 		__len = "#",
-- 		__eq = "==",
-- 		-- __lt = "comparison operator",
-- 		-- __le = "comparison operator",
-- 		-- __index = "operator [] (index)"
-- 		-- __newindex = "operator [] (index)"
-- 		--__call = "call"
-- 	}

-- 	local func_name = block[tag]

-- 	if differentNameFunctions[func_name] ~= nil then
-- 		func_name = differentNameFunctions[block[tag]]
-- 	end

-- 	if func_name and func_name ~= text then
-- 		printError(string.format("Block name conflict: '%s' -> '%s'", block[tag], text))
-- 		doc_report.block_name_conflict = doc_report.block_name_conflict + 1
-- 	end
	
-- 	block[tag] = text
-- end

-------------------------------------------------------------------------------
-- Processes a argument documentation.
-- @arg tag String with the name of the tag (it must be "arg" always).
-- @arg block Table with previous information about the block.
-- @arg text String with the current line beeing processed.
local function arg(tag, block, text, doc_report, silent)
	block[tag] = block[tag] or {}
	if text == "" then
		if not silent then
			printError("In "..block.name.."(), @arg should be folowed by an argument name")
			doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
		end
		return
	end

	-- TODO: make this pattern more flexible, accepting empty descriptions
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	if not name and not silent then
		printError("In "..block.name.."(), could not infer argument and description of @arg from '"..text.."'")
		doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
		return
	end

	-- match table(dot)argument
	local arg_tab, field = name:match("(.-)%.(.*)")
	if arg_tab then
		name = field
		-- match documented argument with declared argument
		local i
		for idx, v in ipairs(block[tag]) do
			if v == arg_tab then
				i = idx
				break
			end
		end

		-- excludes table from the list of arguments
		if i then
			table.remove(block[tag], i)
			block[tag][arg_tab] = nil
		end
		-- set to print name of the arguments
		block[tag].named = true
	end
  
	-- match documented argument with declared argument
	local i 
	for idx, v in ipairs(block[tag]) do
		if v == name then
			i = idx
			break
		end
	end
	if i == nil then
		if not arg_tab and not silent then
			printError("In "..block.name.."(), undefined argument '"..name.."' is documented")
			doc_report.undefined_arg = doc_report.undefined_arg + 1
		end
		table.insert(block[tag], name)
	end
	if block[tag][name] and not silent then
		printError("In "..block.name.."(), @arg '"..name.."' is used more than once and will be ignored in '"..text.."'")
		doc_report.duplicated = doc_report.duplicated + 1
	else
		block[tag][name] = desc
	end
end

-------------------------------------------------------------------------------
local function release(tag, block, text)
	block[tag] = text
end

-------------------------------------------------------------------------------
local function ret(tag, block, text)
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
local function see(tag, block, text)
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
local function usage(tag, block, text, doc_report, silent)
	if block.class == "model" and not silent then
		printError("Models cannot have @usage")
		doc_report.invalid_tags = doc_report.invalid_tags + 1
	elseif type(block[tag]) == "string" and not silent then
		printError("In "..block.name.."(), @usage is used more than once and will be ignored in '"..text.."'")
		doc_report.duplicated = doc_report.duplicated + 1
	else
		block[tag] = text
	end
end

-------------------------------------------------------------------------------
local function output(tag, block, text, doc_report, silent)
	block[tag] = block[tag] or {}
	-- TODO: make this pattern more flexible, accepting empty descriptions
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
	if not name and not silent then
		printError("output 'name' not defined in [["..text.."]]: skipping")
		doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
		return
	end

	if name then
		if block[tag][name] and not silent then
			printError("In "..block.name.."(), @output '"..name.."' is used more than once and will be ignored in '"..text.."'")
			doc_report.duplicated = doc_report.duplicated + 1
			return
		end

		table.insert(block[tag], name)
		block[tag][name] = desc
	end
end

-------------------------------------------------------------------------------
local function tab(tag, block, text, doc_report, silent)
	block[tag] = block[tag] or {}
	local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")

	if not silent then
		if name == nil then
			printError("In "..block.name..", @tabular requires an argument name (or 'NONE').")
			doc_report.wrong_tabular = doc_report.wrong_tabular + 1
			return
		elseif name ~= "NONE" and not block["arg"][name] then
			printError("In "..block.name..", could not find argument '"..tostring(name).."' referred by @tabular.")
			doc_report.wrong_tabular = doc_report.wrong_tabular + 1
		end
	end

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

	if #rows < 2 and not silent then
		printError("In "..block.name..", @tabular has only one row.")
		doc_report.wrong_tabular = doc_report.wrong_tabular + 1
	else
		local size = #rows[1]
		for i = 2, #rows do
			if #rows[i] ~= size and not silent then
				printError("In "..block.name..", row "..i.." of @tabular has size ("..#rows[i]..") different from the first one ("..size..").")
				doc_report.wrong_tabular = doc_report.wrong_tabular + 1
			end
		end
	end

	block[tag][name] = rows
end

-------------------------------------------------------------------------------
local function deprecated(tag, block, text, doc_report, silent)
	if text == "" and not silent then
		printError("In "..block.name.."(), @deprecated should be folowed by a string with a description on what to do")
		doc_report.compulsory_arguments = doc_report.compulsory_arguments + 1
	end
	
	if block[tag] ~= nil and not silent then
		printError("In "..block.name.."(), @deprecated is used more than once and will be ignored in '"..text.."'")
		doc_report.duplicated = doc_report.duplicated + 1
	else
		block[tag] = {}
		table.insert(block[tag], true)

		-- remove trailing "."
		text = string.gsub(text, "(.*)%.$", "%1")
	
		local str = util.split("%s*,%s*", text)			
	
		for _, v in ipairs(str) do
			table.insert(block[tag], v)
		end
	end
end

-------------------------------------------------------------------------------
local handlers = {}
handlers["author"] = author
handlers["class"] = class
handlers["copyright"] = copyright
handlers["description"] = description
handlers["field"] = field
-- handlers["name"] = name
handlers["arg"] = arg
handlers["release"] = release
handlers["return"] = ret
handlers["see"] = see
handlers["usage"] = usage
handlers["output"] = output
handlers["tabular"] = tab
handlers["inherits"] = inherits
handlers["deprecated"] = deprecated
handlers["image"] = image

-------------------------------------------------------------------------------
function handle(tag, block, text, doc_report, silent)
	if not handlers[tag] then
		if not silent then
			printError("In "..block.name.."(), Tag '@"..tag.."' is invalid")
			doc_report.invalid_tags = doc_report.invalid_tags + 1
		end
		return
	end
	return handlers[tag](tag, block, text, doc_report, silent)
end

