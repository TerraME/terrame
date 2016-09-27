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

UnitTest_ = {
	type_ = "UnitTest",
	success = 0,
	fail = 0,
	test = 0,
	wrong_file = 0,
	last_error = "",
	count_last = 0,
	--- Check if a given value is true. In any other case (number, string, false, or nil)
	-- it generates an error.
	-- @arg value Any value.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assert(2 < 3)
	assert = function(self, value)
		self.test = self.test + 1

		mandatoryArgument(1, "boolean", value)

		if value then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1
			self:printError("Test should be true, got false.")
		end
	end,
	--- Check if two values are equal. In this function, two tables are equal only when they are
	-- the same object (if not, they would not be equal even if they share the same internal
	-- content).
	-- @arg v1 Any value.
	-- @arg v2 Any value.
	-- @arg tol A number indicating a maximum error tolerance. This argument is optional and can
	-- be used with numbers or strings. When using string, the tolerance is measured according
	-- to the Utils:levenshtein() distance. The default tolerance is zero.
	-- @arg ignorePath A boolean to ignore path between /'s, when comparing two strings. This argument
	-- is optional and can be used only with strings. The default value is false.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assertEquals(3, 3)
	-- unitTest:assertEquals(2, 2.1, 0.2)
	-- unitTest:assertEquals("string [terralib/data/biomassa-manaus.asc]", "string [biomassa-manaus.asc]", 0, true)
	assertEquals = function (self, v1, v2, tol, ignorePath)
		self.test = self.test + 1

		if v1 == nil then
			mandatoryArgumentError(1)
		elseif v2 == nil then
			mandatoryArgumentError(2)
		end

		if tol ~= nil and type(v1) ~= "number" and type(v1) ~= "string" then
			customError("#3 should be used only when comparing numbers or strings (#1 is "..type(v1)..").")
		end

		if tol == nil then tol = 0 end
		mandatoryArgument(3, "number", tol)

		if ignorePath == nil then ignorePath = false end
		mandatoryArgument(4, "boolean", ignorePath)

		if type(v1) == "number" and type(v2) == "number" then
			local dist = math.abs(v1 - v2)
			if dist <= tol or v1 == v2 then
				self.success = self.success + 1
			else 
				self.fail = self.fail + 1
				local msg = "Values should be equal, but got '"..v1.."' and '"..v2.."'. "..
					"The maximum difference is "..tol..", but got "..dist.."."

				self:printError(msg)
			end
		elseif type(v1) == "string" and type(v2) == "string" then
			if ignorePath then
				local tempstr = ""

				if v1:match("\n") then
					for line in v1:gmatch("([^(.-)\r?\n]+)") do
						local path = line:match("%[(.*)%]")
						if path then
							local _, fileNameWithExtension,_ = path:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
							line = line:gsub("%[(.*)%]", "["..fileNameWithExtension.."]")
						end
						tempstr = tempstr..line.."\n"
					end
				else
					local path = v1:match("%[(.*)%]")
					if path then
						local _, fileNameWithExtension,_ = path:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
						tempstr = v1:gsub("%[(.*)%]", "["..fileNameWithExtension.."]")
					end
				end

				if tempstr ~= "" then v1 = tempstr end
			end

			local dist = levenshtein(v1, v2)
			if dist <= tol then
				self.success = self.success + 1
			else 
				self.fail = self.fail + 1
				local msg = "Values should be equal, but got \n'"..v1.."' and \n'"..v2.."'."

				if tol > 0 then
					msg = msg.."\nThe maximum tolerance is "..tol..", but got "..dist.."." -- SKIP
				end

				self:printError(msg)
			end
		elseif type(v1) ~= type(v2) then
			self.fail = self.fail + 1
			self:printError("Values should be equal, but they have different types ("..type(v1).." and "..type(v2)..").")
		elseif v1 ~= v2 then
			self.fail = self.fail + 1
			self:printError("Values have the same type ("..type(v1)..") but different values.")
		else
			self.success = self.success + 1
		end
	end,
	--- Verify if a function produces an error. If there is no error in the function or the
	-- error found is not the expected error then it generates an error.
	-- @arg my_function A function.
	-- @arg error_message A string describing the error message that the function should produce.
	-- This string should contain only the error message, without the description of the file name
	-- where the error was produced.
	-- @arg max_error A number indicating the maximum number of characters that can be different
	-- between the error produced by the error function and the expected error message.
	-- This argument might be necessary in error messages that include information that can change
	-- from machine to machine, such as an username. The default value is zero (no discrepance).
	-- @usage unitTest = UnitTest{}
	-- error_func = function() verify(2 > 3, "wrong operator") end
	-- unitTest:assertError(error_func, "wrong operator")
	assertError = function(self, my_function, error_message, max_error)
		mandatoryArgument(1, "function", my_function)
		mandatoryArgument(2, "string", error_message)
		optionalArgument(3, "number", max_error)

		local found_error = false
		xpcall(my_function, function(err)
			found_error = true
			if self.current_file then
				local err2 = string.match(err, self.current_file)
				if err2 ~= self.current_file then
					_Gtme.printError("Error in wrong file (possibly wrong stack level). It should occur in '".._Gtme.makePathCompatibleToAllOS(self.current_file).."', got:")
					_Gtme.printError(_Gtme.traceback(err))
					self.wrong_file = self.wrong_file + 1 -- SKIP
					return
				end
			end

			local shortError = string.match(err, ":[0-9]*:.*")

			if shortError == nil then
				self.wrong_file = self.wrong_file + 1 -- SKIP
				_Gtme.printError("Error should contain line number (possibly wrong stack level), got:")
				_Gtme.printError(_Gtme.traceback(err))
				return
			end

			shortError = string.gsub(shortError,":[0-9]*: ", "", 1)
			shortError = string.gsub(shortError,"%s+[0-9]+:", "", 1)

			local start = shortError:sub(1, 7)

			if start ~= "Error: " then
				self:printError("The error message does not start with \"Error:\": "..shortError)
			end

			shortError = shortError:sub(8, shortError:len())

			local distance = levenshtein(error_message, shortError)

			if (distance == 0) or (max_error and distance <= max_error) then
				self.success = self.success + 1
			else
				self.fail = self.fail + 1 -- SKIP

				local error_msg = "Test expected:\n  \""..error_message.."\"\n  got:\n  \""..shortError.."\""

				if max_error then -- SKIP
					error_msg = error_msg.."\nIt would accept an error of at most "..max_error.. -- SKIP
						" character(s), but got "..distance.."." -- SKIP
				end

				self:printError(error_msg)
				-- print(traceback())
			end
		end)

		if not found_error then
			self.fail = self.fail + 1 -- SKIP
			self:printError("Test expected an error ('"..error_message.."'), but no error was found.", 2)
		end

		self.test = self.test + 1
	end,
	--- Check if a given file exists and remove it. Repeating: The file is removed when calling
	-- this assert. If the file is a directory or does not exist then it shows an error.
	-- @arg fname A string with a file name.
	-- @usage -- DONTRUN
	-- unitTest = UnitTest{}
	-- os.execute("touch file.txt") -- create a file (only works in Linux and Mac)
	-- unitTest:assertFile("file.txt")
	assertFile = function(self, fname)
		self.test = self.test + 1

		mandatoryArgument(1, "string", fname)

		if Directory(fname):exists() then
			self.fail = self.fail + 1
			self:printError("It is not possible to use a directory as #1 for assertFile().")
			return
		elseif not File(fname):exists() then
			self.fail = self.fail + 1
			self:printError(resourceNotFoundMsg(1, fname))
			return
		end

		if not self.log then
			File(fname):delete()
			customError("It is not possible to use assertFile without a log directory location in a configuration file for the tests.")
		end

		if not self.logs then self.logs = 0 end
		self.logs = self.logs + 1

		if not self.tlogs then
			self.tlogs = {}
		end

		if self.tlogs[fname] then
			self.fail = self.fail + 1
			self:printError("Log file '"..fname.."' is used in more than one assert.")
			File(fname):delete()
			return
		end

		self.tlogs[fname] = true

		if not self.tmpdir then
			self.tmpdir = Directory{tmp = true}.name -- SKIP
		end

		os.execute("cp \""..fname.."\" \""..self.tmpdir.."\"")
		File(fname):delete()

		if File(fname):exists() then
			self.fail = self.fail + 1 -- SKIP
			self:printError("Could not remove file '"..fname.."'.")
			return
		end

		local s = sessionInfo().separator
		local pkg = sessionInfo().package
		local oldLog = packageInfo(pkg).path..s.."log"..s..self.log..s..fname

		if not File(oldLog):exists() then
			if not self.created_logs then -- SKIP
				self.created_logs = 0 -- SKIP
			end

			self.created_logs = self.created_logs + 1 -- SKIP
			_Gtme.printError("Creating '".._Gtme.makePathCompatibleToAllOS("log"..s..self.log..s..fname).."'.")
			os.execute("cp \""..self.tmpdir..s..fname.."\" \""..oldLog.."\"") -- SKIP
			self.test = self.test + 1 -- SKIP
			self.success = self.success + 1 -- SKIP
		else
			local result = runCommand("diff \""..self.tmpdir..s..fname.."\" \""..oldLog.."\"")

			if #result == 0 then
				self.success = self.success + 1
			else
				_Gtme.printError("Files \n  '".._Gtme.makePathCompatibleToAllOS(oldLog).."'\nand\n  '"..self.tmpdir..s..fname.."'\nare different.")
				forEachElement(result, function(_, value)
					_Gtme.printError(value)
				end)

				self.fail = self.fail + 1 -- SKIP
			end
		end
	end,
	--- Check if a given value is nil. Otherwise it generates an error.
	-- @arg value Any value.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assertNil()
	assertNil = function(self, value)
		self.test = self.test + 1
		if value == nil then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1
			self:printError("Test should be nil, got "..type(value)..".")
		end
	end,
	--- Check if a given value is not nil. Otherwise it generates an error.
	-- @arg value Any value.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assertNotNil(2)
	assertNotNil = function (self, value)
		self.test = self.test + 1
		if value ~= nil then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1
			self:printError("Test should not be nil.")
		end
	end,
	--- Verify whether a Chart or a Map has a plot similar to the one defined in the
	-- log directory. Note that this function cannot be used for the same file twice
	-- in the tests of a given package.
	-- @arg observer A Chart or a Map.
	-- @arg file A string with the file name in the snapshot directory. If the file does not exist
	-- then it will save the file in the snapshot directory.
	-- @arg tolerance A number between 0 and 1 with the maximum difference in percentage of pixels
	-- allowed. The default value is 0.
	-- @usage -- DONTRUN
	-- unitTest = UnitTest{}
	-- cell = Cell{value = 2}
	-- chart = Chart{target = cell}
	-- unitTest:assertSnapshot(chart, "test_chart.bmp")
	assertSnapshot = function(self, observer, file, tolerance)
		if not belong(type(observer), {"Chart", "Map", "TextScreen", "Clock", "VisualTable"}) then
			customError("Argument #1 should be Chart, Map, TextScreen, Clock or VisualTable, got "..type(observer)..".")
		end

		mandatoryArgument(2, "string", file)
		optionalArgument(3, "number", tolerance)

		if tolerance == nil then tolerance = 0 end

		verify(tolerance >= 0 and tolerance <= 1, "Argument #3 should be between 0 and 1, got "..tolerance..".")

		local s = sessionInfo().separator
		if not self.log then
			customError("It is not possible to use assertSnapshot without a log directory location in a configuration file for the tests.")
		end

		if not self.logs then
			self.logs = 0 -- SKIP
		end

		self.logs = self.logs + 1

		if not self.tlogs then
			self.tlogs = {}
		end

		if self.tlogs[file] then
			self.fail = self.fail + 1 -- SKIP
			self:printError("Log file '"..file.."' is used in more than one assert.")
			return
		end

		self.tlogs[file] = true

		if not self.tmpdir then
			self.tmpdir = Directory{tmp = true}.name -- SKIP
		end

		local newImage = self.tmpdir..s..file

		local pkg = sessionInfo().package
		local oldImage = packageInfo(pkg).path..s.."log"..s..self.log..s..file

		if not File(oldImage):exists() then
			observer:save(oldImage) -- SKIP

			if not self.created_logs then -- SKIP
				self.created_logs = 0 -- SKIP
			end

			self.created_logs = self.created_logs + 1 -- SKIP
			_Gtme.printError("Creating '".._Gtme.makePathCompatibleToAllOS("log"..s..self.log..s..file).."'.")
			self.test = self.test + 1 -- SKIP
			self.success = self.success + 1 -- SKIP
		else
			observer:save(newImage)

			self.test = self.test + 1
			local merror = cpp_imagecompare(newImage, oldImage)

			if merror <= tolerance then
				self.success = self.success + 1
			elseif tolerance > 0 then
				local message = "Files \n  '".._Gtme.makePathCompatibleToAllOS("log"..s..self.log..s..file)
					.."'\nand\n  '"..newImage.."'\nare different." -- SKIP
					.."\nThe maximum tolerance is "..tolerance..", but got "..merror.."." -- SKIP
				self:printError(message)
				self.fail = self.fail + 1 -- SKIP
			else
				self:printError("Files \n  '".._Gtme.makePathCompatibleToAllOS("log"..s..self.log..s..file).."'\nand\n  '"..newImage.."'\nare different.")
				self.fail = self.fail + 1 -- SKIP
			end
		end
	end,
	--- Check if a value belongs to a given type. If not, it generates an error.
	-- @arg value Any value.
	-- @arg mtype A string with the name of a type.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assertType(2, "number")
	assertType = function(self, value, mtype)
		if value == nil then
			mandatoryArgumentError(1)
		end

		mandatoryArgument(2, "string", mtype)

		self.test = self.test + 1

		if type(value) == mtype then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1
			self:printError("Test should be "..mtype.." got "..type(value)..".")
		end
	end,
	--- Clear the screen, removing all the visualization objects.
	-- This function is automatically called after executing each test and each example
	-- of the package.
	-- @usage unitTest = UnitTest{}
	-- unitTest:clear()
	clear = function(self)
		if #_Gtme.createdObservers > 0 then
			clean()
		end
	end,
	--- Internal function to print error messages along the tests.
	-- @arg msg A string with the error message.
	-- @usage -- DONTRUN
	-- unitTest = UnitTest{}
	-- unitTest:printError("msg")
	printError = function(self, msg)
		local level = 1
		local info = debug.getinfo(level)
		local infoSource = _Gtme.makePathCompatibleToAllOS(info.source)
		while not string.match(infoSource, "/tests/") do
			level = level + 1
			info = debug.getinfo(level)
			infoSource = _Gtme.makePathCompatibleToAllOS(info.source)
		end

		msg = tostring(msg)

		local str = info.short_src
		str = "Error in ".._Gtme.makePathCompatibleToAllOS(str)..":".. info.currentline ..": "..msg
		if self.last_error == str then
			self.count_last = self.count_last + 1
		elseif self.count_last > 0 then
			local count = self.count_last
			self.count_last = 0
			self.last_error = str
			local func = _Gtme.printError
			if self.unittest then
				func = customError
			end
			func("[The error above occurs more "..count.." times.]")
		else
			self.last_error = str
		end

		if self.count_last == 0 then
			local func = _Gtme.printError
			local arg = str
			if self.unittest then
				func = customError
				arg = msg
			end
			func(arg)
		end
	end
}

local metaTableUnitTest_ = {
	__index = UnitTest_
}

--- Type for testing packages. All its arguments are necessary only when the tests
-- work with database access.
-- @arg data.source Name of the data source. See CellularSpace.
-- @arg data.host Name of the host. See CellularSpace.
-- @arg data.port Number of the port. See CellularSpace.
-- @arg data.password A password. See CellularSpace.
-- @arg data.user A user name. See CellularSpace.
-- @usage unitTest = UnitTest{}
function UnitTest(data)
	setmetatable(data, metaTableUnitTest_)

	defaultTableValue(data, "unittest", false)

	if data.source ~= nil then
		data.source = string.lower(data.source)
	end

	return data
end

