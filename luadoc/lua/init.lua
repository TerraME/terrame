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
	local script = include(package_path..s.."description.lua")
	if script then
		local allowedFields = {"version", "date", "package", "authors", "contact", "content", "url"}
		
		for field, _ in pairs(script) do
			if not belong(field, allowedFields) then
				printError("Error: Field '"..field.."' of 'description.lua' is unnecessary.")
				doc_report.wrong_description = doc_report.wrong_description + 1
			end
		end

		print("Checking version")
		if script.version == nil then
			printError("Error: 'description.lua' does not contain field 'version'.")
			script.version = "Undefined Version"
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.version) ~= "string" then
			printError("Error: Incompatible types. Field 'version' in 'description.lua' expected 'string', got '"..type(script.version).."'.")
			script.version = "Undefined Version"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking date")
		if script.date == nil then
			printError("Error: 'description.lua' does not contain field 'date'.")
			script.date = "Undefined Date"
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.date) ~= "string" then
			printError("Error: Incompatible types. Field 'date' in 'description.lua' expected 'string', got '"..type(script.date).."'.")
			script.date = "Undefined Date"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking package")
		if script.package == nil then
			printError("Error: 'description.lua' does not contain field 'package'.")
			script.package = "Undefined Package"
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.package) ~= "string" then
			printError("Error: Incompatible types. Field 'package' in 'description.lua' expected 'string', got '"..type(script.package).."'.")
			script.package = "Undefined Package"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking authors")
		if script.authors == nil then
			printError("Error: 'description.lua' does not contain field 'authors'.")
			script.authors = "Undefined Author"
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.authors) ~= "string" then
			printError("Error: Incompatible types. Field 'authors' in 'description.lua' expected 'string', got '"..type(script.authors).."'.")
			script.authors = "Undefined Author"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking contact")
		if script.contact == nil then
			printError("Error: 'description.lua' does not contain field 'contact'.")
			script.contact = "Undefined Contact"
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.contact) ~= "string" then
			printError("Error: Incompatible types. Field 'contact' in 'description.lua' expected 'string', got '"..type(script.contact).."'.")
			script.contact = "Undefined Contact"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking content")
		if script.content == nil then
			printError("Error: 'description.lua' does not contain field 'content'.")
			script.content = [[Undefined Description]]
			doc_report.wrong_description = doc_report.wrong_description + 1
		elseif type(script.content) ~= "string" then
			printError("Error: Incompatible types. Field 'content' in 'description.lua' expected 'string', got '"..type(script.content).."'.")
			script.content = [[Undefined Description]]
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		print("Checking url")
		if script.url == nil then
			script.url = ""
		elseif type(script.url) ~= "string" then
			printError("Error: Incompatible types. Field 'url' in 'description.lua' expected 'string', got '"..type(script.url).."'.")
			script.url = "wrong url"
			doc_report.wrong_description = doc_report.wrong_description + 1
		end

		script.logo = sessionInfo().path..s.."packages"..s.."luadoc"..s.."logo"..s.."terrame.png"
		script.destination_logo = package_path..s.."doc"..s.."img"..s

		return script
	else
		printError("Package description file 'description.lua' was not found.")
	end
	-- script.logo = sessionInfo().path..s.."packages"..s.."luadoc"..s.."logo"..s.."terrame.png"
	-- script.destination_logo = package_path..s.."doc"..s.."img"..s
	-- return include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."description.lua").M
end

-------------------------------------------------------------------------------
-- Main function -- RAIAN: Renamed to stardDoc instead of main
-- @see luadoc.doclet.html, luadoc.doclet.formatter, luadoc.doclet.raw
-- @see luadoc.taglet.standard
function startDoc (files, options, package_path, doc_report)
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
	-- taglet.logger = logger
	local doc = taglet.start(files, package_path, options.short_lua_path, doc_report)
	
	doc.description = ldescription(package_path, doc_report)
	
	doclet.options = options
	-- doclet.logger = logger

	doclet.start(doc, doc_report)

	return doc_report
end
