-- This code was adapted by Raian Vargas Maretto and Pedro R. Andrade
-- It was based on LuaDoc code (http://www.keplerproject.org/luadoc/index.html)
-------------------------------------------------------------------------------
-- LuaDoc launcher.
-- @release $Id: luadoc.lua.in,v 1.1 2008/02/17 06:42:51 jasonsantos Exp $
-- Adapted by Raian Vargas Maretto and Pedro Ribeiro de Andrade, october 2014
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Print version number.

local s = sessionInfo().separator
local getLuaFile = getLuaFile

--[[
local function print_version ()
	print (string.format("%s\n%s\n%s", 
		luadoc._VERSION, 
		luadoc._DESCRIPTION, 
		luadoc._COPYRIGHT))
end
--]]
-------------------------------------------------------------------------------
-- Print usage message.

--[[
local function print_help ()
	print ("Usage: "..arg[0]..[[ [options|files]
Build documentation from files. Available options are:
  -d path                      output directory path
  -t path                      template directory path
  -h, --help                   print this help and exit
      --noindexpage            do not generate global index page
      --nofiles                do not generate documentation for files
      --nomodules              do not generate documentation for modules
      --doclet doclet_module   doclet module to generate output
      --taglet taglet_module   taglet module to parse input code
  -q, --quiet                  suppress all normal output
--]]
--  -v, --version                print version information]])
--end

--[[
local function off_messages (_, _, options)
	options.verbose = nil
end
--]]

-------------------------------------------------------------------------------
-- Process options. TODO: use getopts.
-- @class table
-- @name OPTIONS
--[[
local OPTIONS = {
	d = function (arg, i, options)
		local dir = arg[i+1]
		if string.sub (dir, -2) ~= "/" then
			dir = dir..'/'
		end
		options.output_dir = dir
		return 1
	end,
	t = function (arg, i, options)
		local dir = arg[i+1]
		if string.sub (dir, -2) ~= "/" then
			dir = dir..'/'
		end
		options.template_dir = dir
		return 1
	end,
	h = print_help,
	help = print_help,
	q = off_messages,
	quiet = off_messages,
	v = print_version,
	version = print_version,
	doclet = function (arg, i, options)
		options.doclet = arg[i+1]
		return 1
	end,
	taglet = function (arg, i, options)
		options.taglet = arg[i+1]
		return 1
	end,
}
--]]
-------------------------------------------------------------------------------
-- local function process_options (arg)
	-- local files = {}
	-- local options = require "luadoc.config"
	-- local options = getLuaFile(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."config.lua").default_options
	-- local i = 1
	-- while i <= #arg do
	-- 	local argi = arg[i]
	-- 	if string.sub (argi, 1, 1) ~= '-' then
	-- 		table.insert (files, argi)
	-- 	else
	-- 		local opt = string.sub (argi, 2)
	-- 		if string.sub (opt, 1, 1) == '-' then
	-- 			opt = string.gsub (opt, "%-", "")
	-- 		end
	-- 		if OPTIONS[opt] then
	-- 			if OPTIONS[opt] (arg, i, options) then
	-- 				i = i + 1
	-- 			end
	-- 		else
	-- 			options[opt] = 1
	-- 		end
	-- 	end
	-- 	i = i+1
	-- end
	-- return --[[files,]] options
-- end 

-------------------------------------------------------------------------------
-- Main function. Process command-line arguments and call luadoc processor.
function luadocMain(package_path, lua_files, example_files, _, mdata, mfont, doc_report, silent)
	if not silent then silent = false end
	-- Process options
	-- local argc = #arg
	-- if argc < 1 then
	-- 	print_help ()
	-- 	return
	-- end

	-- local --[[lua_files,]] options = process_options (arg)

	local options = getLuaFile(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."config.lua").default_options
	options.output_dir = package_path..s.."doc"..s
	options.short_output_path = "doc"..s
	options.short_lua_path = "lua"..s

	return startDoc(lua_files, example_files, options, package_path, mdata, mfont, doc_report, silent)
end

