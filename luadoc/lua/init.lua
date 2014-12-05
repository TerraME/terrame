-------------------------------------------------------------------------------
-- LuaDoc main function.
-- @release $Id: init.lua,v 1.4 2008/02/17 06:42:51 jasonsantos Exp $
-------------------------------------------------------------------------------

local print, pairs, pcall, loadfile = print, pairs, pcall, loadfile
local belong = belong

local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."util.lua")

logger = {}

-------------------------------------------------------------------------------
-- LuaDoc version number.

_COPYRIGHT = "Copyright (c) 2003-2007 The Kepler Project"
_DESCRIPTION = "Documentation Generator Tool for the Lua language"
_VERSION = "LuaDoc 3.0.1"

local function ldescription(package_path, doc_report)
	printNote("Checking 'description.lua'")

	local defaultFields = {
		version = "Undefined version",
		date    = "Undefined date",
		package = "Undefined package",
		title = "",
		authors = "Undefined authors",
		contact = "Undefined contact",
		content = "Undefined content",
		url     = "",
		license = "Undefined license",
		logo = sessionInfo().path..s.."packages"..s.."luadoc"..s.."logo"..s.."terrame.png",
		destination_logo = package_path..s.."doc"..s.."img"..s
	}

	local script
	xpcall(function() script = include(package_path..s.."description.lua") end, function(err)
		printError("Error when executing file 'description.lua'.")
		printError(err)
		os.exit()
	end)

	if not script then
		printError("'description.lua' was not found in the package.")
		doc_report.wrong_description = doc_report.wrong_description + 1

		return defaultFields
	end

	local allowedFields = {"license", "version", "date", "package", "title", "authors", "contact", "content", "url"}
		
	for field, _ in pairs(script) do
		if not belong(field, allowedFields) then
			printError("Error: Field '"..field.."' of 'description.lua' is unnecessary.")
			doc_report.wrong_description = doc_report.wrong_description + 1
		end
	end

	local checkString = function(idx, optional)
		if script[idx] == nil then
			if not optional then
				printError("Error: 'description.lua' does not contain field '"..idx.."'.")
				doc_report.wrong_description = doc_report.wrong_description + 1
			end
		elseif type(script[idx]) ~= "string" then
			printError("Error: Incompatible types. Field '"..idx.."' in 'description.lua' expected 'string', got '"..type(script[idx]).."'.")
			doc_report.wrong_description = doc_report.wrong_description + 1
		end
	end

	checkString("version")
	checkString("date")
	checkString("package")
	checkString("title", true)
	checkString("authors")
	checkString("contact")
	checkString("content")
	checkString("url", true)
	checkString("license")

	setmetatable(script, {__index = defaultFields})
	return script
	-- script.logo = sessionInfo().path..s.."packages"..s.."luadoc"..s.."logo"..s.."terrame.png"
	-- script.destination_logo = package_path..s.."doc"..s.."img"..s
	-- return include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."description.lua").M
end

-------------------------------------------------------------------------------
-- Main function
-- @see luadoc.doclet.html, luadoc.doclet.formatter, luadoc.doclet.raw
-- @see luadoc.taglet.standard
function startDoc (files, examples, options, package_path, doc_report)
	-- logger = util.loadlogengine(options)

	-- load config file
	-- if options.config ~= nil then
		-- load specified config file
		-- dofile(options.config)
	-- else
		-- load default config file
		-- dofile(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."config.lua")
	-- end
	
	local taglet = include(options.taglet)
	
	local doclet = include(options.doclet)

	-- analyze input
	taglet.options = options
	description = ldescription(package_path, doc_report)
	-- taglet.logger = logger
	local doc = taglet.start(files, examples, package_path, options.short_lua_path, doc_report)
	
	doc.description = description	
	doclet.options = options
	-- doclet.logger = logger

	doclet.start(doc, doc_report)

	return doc_report
end

