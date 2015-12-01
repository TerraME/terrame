-------------------------------------------------------------------------------
-- Doclet to format source code according to LuaDoc standard tags. This doclet
-- (re)write .lua files adding missing standard tags. Texts are formatted to
-- 80 columns and function arguments are added based on code analysis.
--
-- @release $Id: formatter.lua,v 1.5 2007/04/18 14:28:39 tomas Exp $
-------------------------------------------------------------------------------

local sessionInfo = sessionInfo
local s = sessionInfo().separator
local util = include(sessionInfo().path..s.."packages"..s.."luadoc"..s.."lua"..s.."main"..s.."util.lua")
local assert, ipairs, type = assert, ipairs, type
local string, table, printNote = string, table, _Gtme.printNote

options = {
	output_dir = "./",
}

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file (filename)
	local h = filename
	h = options.output_dir..h
	return h
end

-------------------------------------------------------------------------------
-- Generate a new lua file for each input lua file. If the user does not 
-- specify a different output directory input files will be rewritten.
-- @arg doc documentation table

function start (doc)
	local todo = "<TODO>"
	
	-- Process files
	for i, file_doc in ipairs(doc.files) do
		-- assembly the filename
		local filename = out_file(file_doc.name)
		printNote(string.format("Generating file %s", filename))

		-- TODO: confirm file overwrite
		local f = openFile(filename, "w")
		assert(f, string.format("Could not open %s for writing", filename))

		for _, block in ipairs(file_doc.doc) do

			-- write reorganized comments
			f:write(string.rep("-", 80).."\n")
			
			-- description
			f:write(util.comment(util.wrap(block.description, 77)))
			f:write("\n")
			
			if block.class == "function" then
				-- arguments
				for _, arg_name in ipairs(block.arg) do
					f:write(util.comment(util.wrap(string.format("@arg %s %s", arg_name, block.arg[arg_name] or todo), 77)))
					f:write("\n")
				end
				
				-- return
				if type(block.ret) == "table" then
					for _, ret in ipairs(block.ret) do
						f:write(util.comment(util.wrap(string.format("@return %s", ret), 77)).."\n")
					end
				else
					f:write(util.comment(util.wrap(string.format("@return %s", block.ret or todo), 77)).."\n")
				end
			end
			
			-- TODO: usage
			-- TODO: see

			-- write code
			for _, line in ipairs(block.code) do
				f:write(line.."\n")
			end
		end
		
		f:close()
	end
end
