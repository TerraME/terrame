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
-- Copyright Kepler Project 2003 (https://keplerproject.github.io/luafilesystem).

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
-- with the values below. Some of them are read only, while others might
-- be changed accordingly.
-- @tabular NONE
-- Attribute & Description & Read only? \
-- autoclose & When a simulation creates graphical components (Chart, Map, etc.), 
-- TerraME waits for the modeler to close them to finish its execution. 
-- This attribute is a boolean value indicating whether TerraME should be
-- automatically closed after executing the simulation. & No \
-- color & A boolean value indicating whether text output might be colored. If colored,
-- errors are shown red, warnings are shown yellow, and some prints in executions
-- like -test and -doc might be green. This option can only be set from TerraME
-- command line (-color). & Yes \
-- currentFile & A string with the name of the file currently being executed. This
-- value only exists when the file is passed as argument to the command line. & Yes \
-- dbVersion & A string with the current TerraLib version for databases. & Yes \
-- fullTraceback & A boolean value indicating whether TerraME should show all the
-- stack when an error occurs. This means that the lines from base package and 
-- internal files are also going to be shown when an error occurs. As default, TerraME
-- does not show such lines. This value can be set from TerraME command line (-ft). & No \
-- interface & A boolean value indicating whether a graphical interface to configure
-- models is running. When this value is true, Utils:toLabel() converts errors to more
-- readable texts referring to graphical objects instead of Model arguments. & No \
-- mode & A string with the current mode for warnings ("normal", "debug", "quiet", or "strict"). 
-- Run terrame -help for a description of such modes. & No \
-- path & A string with the location of TerraME in the computer. & Yes \
-- round & A number used whenever it is possible to have rounding problems. For instance,
-- it works with Events that have period less than one by rounding the execution time of
-- an Event that is going to be scheduled to a future time if the difference between such
-- time and the closest integer number is less then the value of this argument. In this case,
-- if an Event that starts in time one and has period 0.1, it might execute in time 1.999999999,
-- as we are working with real number. This argument is then useful to make sure that such Event
-- will be executed in time exactly two. The default value is 1e-5. & No \
-- separator & A character with the directory separator. Each operational system has its
-- own separator. & Yes \
-- silent & A boolean value indicating whether print() calls should not be shown. This
-- value can only be set from TerraME command line (-silent). & Yes \
-- system & A string with the operating system. It is one of "windows", "linux", or "mac". & Yes \
-- version & A string with the current version of TerraME. & Yes
-- @usage print(sessionInfo().mode)
function sessionInfo()
	local info = info_ -- this is a global variable created when TerraME is initialized

	local sessionInfo_ = {}
	local metaTableSessionInfo_ = {
		__index = function(_, idx)
			return info[idx]
		end,
		__newindex = function(_, idx, value)
			local readOnly = false
			local args = {
				autoclose = "boolean",
				dbVersion = readOnly,
				color = readOnly,
				currentFile = readOnly,
				fullTraceback = "boolean",
				interface = "boolean",
				mode = {"default", "debug", "normal", "quiet", "strict"},
				path = readOnly,
				separator = readOnly,
				silent = readOnly,
				system = readOnly,
				version = readOnly,
				round = function(midx, mvalue)
					if type(mvalue) ~= "number" then
						incompatibleTypeError(midx, "number", mvalue)
					elseif not (mvalue >= 0 and mvalue < 1) then
						customError("Argument '"..idx.."' must be a number >= 0 and < 1, got '"..value.."'.")
					end
				end
			}

			local check = args[idx]

			if check == readOnly then
				customError("Argument '"..idx.."' is an important information about the current execution and cannot be changed.")
			elseif check == nil then
				customError("Argument '"..idx.."' is not an information about the current execution.")
			end

			local mtype = type(check)

			if mtype == "function" then
				check(idx, value)
			elseif mtype == "table" then
				if not belong(value, check) then
					customError("Argument '"..idx.."' cannot be replaced by '"..value.."'.")
				end
			elseif type(value) ~= check then
				incompatibleTypeError(idx, check, value)
			end

			info[idx] = value
		end
	}

	setmetatable(sessionInfo_, metaTableSessionInfo_)

	return sessionInfo_
end

