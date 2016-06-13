-------------------------------------------------------------------------------
-- General utilities.
-- @release $Id: util.lua,v 1.16 2008/02/17 06:42:51 jasonsantos Exp $
-------------------------------------------------------------------------------

-- local lfs = require "lfs"
local table, io, assert, setmetatable = table, io, assert, setmetatable
local string, ipairs, mkDir, printError = string, ipairs, mkDir, _Gtme.printError

-------------------------------------------------------------------------------
-- Module with several utilities that could not fit in a specific module

-- module "luadoc.util"

-------------------------------------------------------------------------------
-- Removes spaces from the begining and end of a given string
-- @arg s string to be trimmed
-- @return trimmed string
function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-------------------------------------------------------------------------------
-- Removes spaces from the begining and end of a given string, considering the
-- string is inside a lua comment.
-- @arg s string to be trimmed
-- @return trimmed string
-- @see trim
-- @see string.gsub
function trim_comment(s)
	s = string.gsub(s, "%-%-+(.*)$", "%1")
	return trim(s)
end

-------------------------------------------------------------------------------
-- Checks if a given line is empty
-- @arg line string with a line
-- @return true if line is empty, false otherwise
function line_empty(line)
	return (string.len(trim(line)) == 0)
end

-------------------------------------------------------------------------------
-- Appends two string, but if the first one is nil, use to second one
-- @arg str1 first string, can be nil
-- @arg str2 second string
-- @return str1 .. " " .. str2, or str2 if str1 is nil
function concat(str1, str2)
	if str1 == nil or string.len(str1) == 0 then
		return str2
	else
		return str1 .. " " .. str2
	end
end

-------------------------------------------------------------------------------
-- Split text into a list consisting of the strings in text,
-- separated by strings matching delim (which may be a pattern). 
-- @arg delim if delim is "" then action is the same as %s+ except that 
-- field 1 may be preceeded by leading whitespace
-- @usage split(",%s*", "Anna, Bob, Charlie,Dolores")
-- @usage split(""," x y") gives {"x","y"}
-- @usage split("%s+"," x y") gives {"", "x","y"}
-- @return array with strings
-- @see table.concat
function split(delim, text)
	local list = {}
	--if string.len(text) > 0 then
  if text and #text > 0 then
		delim = delim or ""
		local pos = 1
		-- if delim matches empty string then it would give an endless loop
		if string.find("", delim, 1) and delim ~= "" then 
			error("delim matches empty string!")
		end
		local first, last
		while 1 do
			if delim ~= "" then 
				first, last = string.find(text, delim, pos)
			else
				first, last = string.find(text, "%s+", pos)
				if first == 1 then
					pos = last+1
					first, last = string.find(text, "%s+", pos)
				end
			end
			if first then -- found?
				table.insert(list, string.sub(text, pos, first-1))
				pos = last+1
			else
				table.insert(list, string.sub(text, pos))
				break
			end
		end
	end
	return list
end

-------------------------------------------------------------------------------
-- Comments a paragraph.
-- @arg text text to comment with "--", may contain several lines
-- @return commented text
function comment(text)
	text = string.gsub(text, "\n", "\n-- ")
	return "-- " .. text
end

-------------------------------------------------------------------------------
-- Wrap a string into a paragraph.
-- @arg s string to wrap
-- @arg w width to wrap to [80]
-- @arg i1 indent of first line [0]
-- @arg i2 indent of subsequent lines [0]
-- @return wrapped paragraph
function wrap(s, w, i1, i2)
	w = w or 80
	i1 = i1 or 0
	i2 = i2 or 0
	assert(i1 < w and i2 < w, "the indents must be less than the line width")
	s = string.rep(" ", i1) .. s
	local lstart, len = 1, string.len(s)
	while len - lstart > w do
		local i = lstart + w
		while i > lstart and string.sub(s, i, i) ~= " " do i = i - 1 end
		local j = i
		while j > lstart and string.sub(s, j, j) == " " do j = j - 1 end
		s = string.sub(s, 1, j) .. "\n" .. string.rep(" ", i2) ..
			string.sub(s, i + 1, -1)
		local change = i2 + 1 - (i - j)
		lstart = j + change
		len = len + change
	end
	return s
end

-------------------------------------------------------------------------------
-- Opens a file, creating the directories if necessary
-- @arg filename full path of the file to open (or create)
-- @arg mode mode of opening
-- @return file handle

function openFile (filename, mode)
	local f = io.open(filename, mode)
	if f == nil then
		filename = string.gsub(filename, "\\", "/")
		local dir = ""
		for d in string.gmatch(filename, ".-/") do
			dir = dir .. d
			mkDir(dir)
		end
		f = io.open(filename, mode)
	end
	return f
end


----------------------------------------------------------------------------------
-- Creates a Logger with LuaLogging, if present. Otherwise, creates a mock logger.
-- @arg options a table with options for the logging mechanism
-- @return logger object that will implement log methods

function loadlogengine(options)
	-- TODO: Verify this block
	-- local logenabled = pcall(function()
	-- 	require "logging"
	-- 	require "logging.console"
	-- end)
	
	local logging = logenabled and logging
	
	if logenabled then
		if options.filelog then
			logger = logging.file("luadoc.log") -- use this to get a file log
		else
			logger = logging.console("[%level] %message\n")
		end
	
		if options.verbose then
			logger:setLevel(logging.INFO)
		else
			logger:setLevel(logging.WARN)
		end
		
	else
		noop = {__index=function()
			return function()
				-- noop
			end
		end}
		
		logger = {} 
		setmetatable(logger, noop)
	end
	
	return logger
end

local check_arguments
-- Sort a tab descriptor and check for declared arguments
function parse_tab(tab, func, filename, doc_report)
	local arguments = {}
	local header = tab[1]
	
	local is_strategy_table
	for k, title in ipairs(header) do
		local mtitle = title:lower()
		if mtitle:match("arguments")  then
			is_strategy_table = true
			local line = 2
			while (line <= #tab) do
				local arg_list = tab[line][k]
				local arg_tab = split(",%s*", arg_list)
				table.sort(arg_tab)

				if arg_tab[1] == "..." then
					table.remove(arg_tab, 1)
					table.insert(arg_tab, "...")
				end

				arg_list = table.concat(arg_tab, ", ")
				tab[line][k] = arg_list
				line = line + 1
				for _, v in ipairs(arg_tab) do
					v = v:match("%S+")
					if not arguments[v] then
						arguments[v] = v
						table.insert(arguments, v)
					end
				end
			end
		end
	end
	if is_strategy_table then
		check_arguments(arguments, func, filename, doc_report)
	end	
end

function check_arguments(parsed_args, func, _, doc_report)
	local unknown = {}
	local unused = {}
	
	for _, arg in ipairs(parsed_args) do
		if not func.arg[arg] and not unknown[arg] then
			unknown[arg] = arg
			table.insert(unknown, arg)
		end
	end
	for _, arg in ipairs(func.arg) do
		if not parsed_args[arg] and not func.tabular[arg] and not unused[arg] then
			unused[arg] = arg
			table.insert(unused, arg)
		end
	end
	for _, arg in ipairs(unknown) do
		local warning = "Unknown argument '%s' in '%s'"
		printError(warning:format(arg, func.name))
		doc_report.unknown_arg = doc_report.unknown_arg + 1
	end
	for _, arg in ipairs(unused) do
		local warning = "Argument '%s' in '%s' is not used in the HTML table"
		printError(warning:format(arg, func.name))
		doc_report.unused_arg = doc_report.unused_arg + 1
	end
end

