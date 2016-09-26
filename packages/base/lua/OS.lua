-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

-- @header Functions to handle files and directories.
-- Most of the functions bellow are taken from LuaFileSystem 1.6.2.
-- Copyright Kepler Project 2003 (https://keplerproject.github.io/luafilesystem/).

--- Return a string with the current working directory.
-- @usage cdir = currentDir()
-- print(cdir)
function currentDir()
	return lfs.currentdir()
end

--- Execute a system command and return its output. It returns two tables. 
-- The first one contains each standard output line as a position.
-- The second one contains each error output line as a position.
-- @arg command A command.
-- @usage result, error = runCommand("dir")
function runCommand(command)
	mandatoryArgument(1, "string", command)

	local result, err = cpp_runcommand(command)

	local function convertToTable(str)
		local t = {}
		local i = 0
		local v
		local oldv = 0
		while true do
			i, v = string.find(str, "\n", i + 1) -- find 'next' newline
			if i == nil then break end
			table.insert(t, string.sub(str, oldv + 1, v - 1))
			oldv = v
		end

		return t
	end

	result = convertToTable(result)
	err = convertToTable(err)

	return result, err
end

--- Return information about the current execution. The result is a table
-- with the following values.
-- @tabular NONE
-- Attribute & Description \
-- dbVersion & A string with the current TerraLib version for databases. \
-- mode & A string with the current mode for warnings ("normal", "debug", "quiet", or "strict"). \
-- path & A string with the location of TerraME in the computer. \
-- separator & A string with the directory separator. \
-- silent & A boolean value indicating whether print() calls should not be shown in the
-- screen. This element is true when TerraME is executed with mode "silent". \
-- system & A string with the operating system.
-- @usage print(sessionInfo().mode)
function sessionInfo()
	return info_ -- this is a global variable created when TerraME is initialized
end

