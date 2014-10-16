-------------------------------------------------------------------------------
-- LuaDoc main function.
-- @release $Id: init.lua,v 1.4 2008/02/17 06:42:51 jasonsantos Exp $
-------------------------------------------------------------------------------

-- local require = require
local loadfile = loadfile
local print = print
-- local util = require "luadoc.util"
local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."util.lua")
local pcall = pcall
local setfenv = setfenv

logger = {}

-- module ("luadoc")

-------------------------------------------------------------------------------
-- LuaDoc version number.

_COPYRIGHT = "Copyright (c) 2003-2007 The Kepler Project"
_DESCRIPTION = "Documentation Generator Tool for the Lua language"
_VERSION = "LuaDoc 3.0.1"


local function ldescription()
	local script = loadfile("description.lua")
	if script then
		local _env = {}
		setfenv(script, _env)
		pcall(script)
		return _env		
	else
		print("Package description file 'description.lua' not found. Using default description.")
	end
	return require("luadoc.description")
end

-------------------------------------------------------------------------------
-- Main function -- RAIAN: Renamed to stardDoc instead of main
-- @see luadoc.doclet.html, luadoc.doclet.formatter, luadoc.doclet.raw
-- @see luadoc.taglet.standard
function startDoc (files, options, package_path)
	-- logger = util.loadlogengine(options)

	-- load config file
	if options.config ~= nil then
		-- load specified config file
		dofile(options.config)
	else
		-- load default config file
		-- require("luadoc.config")
		dofile(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."config.lua")
	end
	
	-- local taglet = require(options.taglet)
	local taglet = include(options.taglet)
	-- local doclet = require(options.doclet)
	local doclet = include(options.doclet)

	-- analyze input
	taglet.options = options
	taglet.logger = logger
	local doc = taglet.start(files, package_path)
	
	doc.description = ldescription()
	
	doclet.options = options
	doclet.logger = logger
	doclet.start(doc)
end
