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

return{
	 attributes = function(unitTest)
		local error_func = function()
			attributes(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		error_func = function()
			attributes("file", 1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 1))
	end,
	chDir = function(unitTest)
		local error_func = function()
			chDir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	dir = function(unitTest)
		local error_func = function()
			dir("abc123")
		end
		unitTest:assertError(error_func, "abc123 is not a directory or is empty or does not exist.")

		error_func = function()
			dir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	
		error_func = function()
			dir("path", 1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "boolean", 1))
	end,
    isDir = function(unitTest)
        local error_func = function()
            isDir(1)
        end
        unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
    end,
	isFile = function(unitTest)
		local error_func = function()
			isFile(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	linkAttributes = function(unitTest)
		local error_func = function()
			linkAttributes(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		error_func = function()
			linkAttributes("path", 1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 1))
	end,
	lock = function(unitTest)
		local error_func = function()
			lock(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "userdata", 1))

		local pathdata = packageInfo().data
		local f = io.open(pathdata.."test.txt", "w+")

		error_func = function()
			lock(f, 1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "string", 1))
		f:close()
		os.execute("rm \""..pathdata.."test.txt\"")
	end,
	lockDir = function(unitTest)
		local error_func = function()
			lockDir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	mkDir = function(unitTest)
		local error_func = function()
			mkDir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	rmDir = function(unitTest)
		local error_func = function()
			rmDir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		local error_func = function()
			rmDir("abc\"")
		end
		unitTest:assertError(error_func, "Argument #1 should not contain quotation marks.")

		local error_func = function()
			rmDir("abc123456")
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(1, "abc123456"))
	end,
	rmFile = function(unitTest)
		local error_func = function()
			rmFile(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		local error_func = function()
			rmFile("abc\"")
		end
		unitTest:assertError(error_func, "Argument #1 should not contain quotation marks.")

		local error_func = function()
			rmFile("abc123456")
		end
		unitTest:assertError(error_func, resourceNotFoundMsg(1, "abc123456"))
	end,
	runCommand = function(unitTest)
		local error_func = function()
			runCommand(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	tmpDir = function(unitTest)
		local error_func = function()
			tmpDir(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))
	end,
	touch = function(unitTest)
		local error_func = function()
			touch(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "string", 1))

		error_func = function()
			touch("path", "1")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(2, "number", "1"))
	
		error_func = function()
			touch("path", 1, "1")
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(3, "number", "1"))
	end,
	unlock = function(unitTest)
		local error_func = function()
			unlock(1)
		end
		unitTest:assertError(error_func, incompatibleTypeMsg(1, "userdata", 1))
	end
}

