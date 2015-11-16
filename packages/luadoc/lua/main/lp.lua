----------------------------------------------------------------------------
-- Lua Pages Template Preprocessor.
--
-- @release $Id: lp.lua,v 1.7 2007/04/18 14:28:39 tomas Exp $
----------------------------------------------------------------------------

local assert, error, loadstring, select, string = assert, error, loadstring, select, string
local close = io.close
local find, format, gsub, strsub = string.find, string.format, string.gsub, string.sub
local concat, tinsert, open, print, debug, load = table.concat, table.insert, io.open, print, debug, load
local printError, xpcall, traceback = _Gtme.printError, xpcall, traceback

----------------------------------------------------------------------------
-- function to do output
local outfunc = "io.write"
-- accepts the old expression field: '$| <Lua expression> |$'
local compatmode = true

--
-- Builds a piece of Lua code which outputs the (part of the) given string.
-- @arg s String.
-- @arg i Number with the initial position in the string.
-- @arg f Number with the final position in the string (default == -1).
-- @return String with the correspondent Lua code which outputs the part of the string.
local function out(s, i, f)
	s = strsub(s, i, f or -1)
	if s == "" then return s end
	-- we could use '%q' here, but this way we have better control
	s = gsub(s, "([\\\n\'])", "\\%1")
	-- substitute '\r' by '\'+'r' and let 'loadstring' reconstruct it
	s = gsub(s, "\r", "\\r")
	return format(" %s('%s'); ", outfunc, s)
end

----------------------------------------------------------------------------
-- Translate the template to Lua code.
-- @arg s String to translate.
-- @return String with translated code.
----------------------------------------------------------------------------
function translate(s)
	if compatmode then
		s = gsub(s, "$|(.-)|%$", "<?lua = %1 ?>")
		s = gsub(s, "<!%-%-$$(.-)$$%-%->", "<?lua %1 ?>")
	end
	s = gsub(s, "<%%(.-)%%>", "<?lua %1 ?>")
	local res = {}
	local start = 1   -- start of untranslated part in 's'
	while true do
		local ip, fp, target, exp, code = find(s, "<%?(%w*)[ \t]*(=?)(.-)%?>", start)
		if not ip then break end
		tinsert(res, out(s, start, ip-1))
		if target ~= "" and target ~= "lua" then
			-- not for Lua; pass whole instruction to the output
			tinsert(res, out(s, ip, fp))
		else
			if exp == "=" then   -- expression?
				tinsert(res, format(" %s(%s);", outfunc, code))
			else  -- command
				tinsert(res, format(" %s ", code))
			end
		end
		start = fp + 1
	end
	tinsert(res, out(s, start))
	return concat(res)
end


----------------------------------------------------------------------------
-- Defines the name of the output function.
-- @arg f String with the name of the function which produces output.

function setoutfunc (f)
	outfunc = f
end

----------------------------------------------------------------------------
-- Turns on or off the compatibility with old CGILua 3.X behavior.
-- @arg c Boolean indicating if the compatibility mode should be used.

function setcompatmode (c)
	compatmode = c
end

----------------------------------------------------------------------------
-- Internal compilation cache.

local cache = {}

----------------------------------------------------------------------------
-- Translates a template into a Lua function.
-- Does NOT execute the resulting function.
-- Uses a cache of templates.
-- @arg string String with the template to be translated.
-- @arg chunkname String with the name of the chunk, for debugging purposes.
-- @return Function with the resulting translation.

function compile (string, chunkname)
	local f, err = cache[string]
	if f then return f end
	f, err = loadstring (translate (string), chunkname)
	if not f then error (err, 3) end
	cache[string] = f
	return f
end

----------------------------------------------------------------------------
-- Simulates the setenv function from lua 5.1
-- Based in: http://stackoverflow.com/questions/14290527/recreating-setfenv-in-lua-5-2
local function setfenv(f, env)
    local _, environment =  xpcall(function() return load(string.dump(f), nil, 'bt', env) end, function(err)
		printError(err)
		printError(traceback())
	end)

	return environment
    -- return load(string.dump(f), nil, "bt", env)
end

----------------------------------------------------------------------------
-- Simulates the getfenv function from lua 5.1
-- source: http://stackoverflow.com/questions/14290527/recreating-setfenv-in-lua-5-2
local function findenv(f)
	local level = 1
	repeat
		local name, value = debug.getupvalue(f, level)
		if name == '_ENV' then return level, value end
		level = level + 1
	until name == nil
	return nil 
end

local getfenv = function (f) 
	return select(2, findenv(f)) or _G
end

----------------------------------------------------------------------------
-- Translates and executes a template in a given file.
-- The translation creates a Lua function which will be executed in an
-- optionally given environment.
-- @arg filename String with the name of the file containing the template.
-- @arg env Table with the environment to run the resulting function.

--TODO: Maybe this function must be renamed
function include (filename, env)
	-- read the whole contents of the file
	local fh = assert (open (filename))
	local src = fh:read("*a")
	close(fh)
	-- translates the file into a function
	local prog = compile (src, '@'..filename)
	local _env
	if env then
		_env = getfenv (prog)
		setfenv (prog, env)()
	else
		prog ()
	end
end
