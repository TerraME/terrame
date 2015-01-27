--#########################################################################################
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: 
--      Pedro R. Andrade
--      Raian Vargas Maretto
--      Antonio Gomes de Oliveira Junior
--#########################################################################################

local print_error = function(self, msg)
	local level = 1
    local info = debug.getinfo(level)
    while not string.match(info.source, "/tests/") do
		level = level + 1
    	info = debug.getinfo(level)
	end

	local str = info.short_src
	str = str..":".. info.currentline ..": "..msg
	if self.last_error == str then
		self.count_last = self.count_last + 1
	elseif self.count_last > 0 then
		printError("[The error above occurs more "..self.count_last.." times.]")
		self.count_last = 0
		self.last_error = str
	else
		self.last_error = str
	end

	if self.count_last == 0 then
		printError(str)
	end
end

UnitTest_ = {
	type_ = "UnitTest",
	success = 0,
	fail = 0,
	test = 0,
	wrong_file = 0,
	last_error = "",
	count_last = 0,
	delayed_time = 0,
	--- Check if a given value is true. In any other case (number, string, false, or nil) it generates an error
	-- @arg value Any value.
	-- @usage unitTest:assert(2 < 3)
	assert = function(self, value)
		self.test = self.test + 1

		mandatoryArgument(1, "boolean", value)

		if value == true then
			self.success = self.success + 1
		else
			local msg
			local mtype = type(value)
			if belong(mtype, {"number", "boolean", "string"}) then
				msg = tostring(value).." (a "..mtype..")."
			else
				msg = " a "..mtype.."."
			end

			print_error(self, "Test should be true got "..msg)
			self.fail = self.fail + 1
		end
	end,
	--- Check if a value belongs to a given type. If not, it generates an error.
	-- @arg value Any value.
	-- @arg mtype A string with the name of a type.
	-- @usage unitTest:assert_type(2, "number")
	assert_type = function (self, value, mtype)
		self.test = self.test + 1

		mandatoryArgument(2, "string", mtype)

		if type(value) == mtype then
			self.success = self.success + 1
		else
			print_error(self, "Test should be "..mtype.." got "..type(value)..".")
			self.fail = self.fail + 1
		end
	end,
	--- Check if a given value is nil. Otherwise it generates an error.
	-- @arg value Any value.
	-- @usage unitTest:assert_nil()
	assert_nil = function(self, value)
		self.test = self.test + 1
		if value == nil then
			self.success = self.success + 1
		else
			print_error(self, "Test should be nil, got "..type(value)..".")
			self.fail = self.fail + 1
		end
	end,
	--- Check if a given value is not nil. Otherwise it generates an error.
	-- @arg value Any value.
	-- @usage unitTest:assert_not_nil(2)
	assert_not_nil = function (self, value)
		self.test = self.test + 1
		if value ~= nil then
			self.success = self.success + 1
		else
			print_error(self, "Test should not be nil.")
			self.fail = self.fail + 1
		end
	end,
	--- Check if two values are equal. In this function, two tables are equal only when they are the
	-- same object (if not, they would not be equal even if they share the same internal content).
	-- @arg v1 Any value.
	-- @arg v2 Any value.
	-- @arg tol A number indicating a maximum error tolerance. This argument is optional and can
	-- be used only with numeric values. The default tolerance is zero.
	-- @usage unitTest:assert_equal(3, 3)
	-- unitTest:assert_equal(2, 2.1, 0.2)
	assert_equal = function (self, v1, v2, tol)
		self.test = self.test + 1

		if tol ~= nil and type(v1) ~= "number" then
			customError("#3 should be used only when comparing numbers (#1 is "..type(v1)..").")
		end

		if tol == nil then tol = 0 end
		mandatoryArgument(3, "number", tol)

		if type(v1) == "number" and type(v2) == "number" then
			if v1 <= v2 + tol and v1 >= v2 - tol then
				self.success = self.success + 1
			else 
				print_error(self, "Values should be equal, but got '"..v1.."' and '"..v2.."'.")
				self.fail = self.fail + 1
			end
		elseif type(v1) == "string" and type(v2) == "string" then
			if v1 == v2 then
				self.success = self.success + 1
			else 
				print_error(self, "Values should be equal, but got \n'"..v1.."' and \n'"..v2.."'.")
				self.fail = self.fail + 1
			end
		elseif type(v1) ~= type(v2) then
			self.fail = self.fail + 1
			print_error(self, "Values should be equal, but they have different types ("..type(v1).." and "..type(v2)..").")
		elseif v1 ~= v2 then
			self.fail = self.fail + 1
			print_error(self, "Values have the same type ("..type(v1)..") but different values.")
		else
			self.success = self.success + 1
		end
	end,
	--- Verify if a function produces an error.
	-- @arg my_function A function.
	-- @arg error_message A string describing the error message that the function should produce.
	-- This string should contain only the error message, without the description of the file name
	-- the error was produced.
	-- @arg max_error A number indicating the maximum discrepance between the generated error and the
	-- expected error. It is necessary in error messages that include information that can change
	-- from machine to machine, such as an username. The default value is zero (no discrepance).
	-- @usage error_func = function() verify(2 > 3, "wrong operator") end
	-- unitTest:assert_error(error_func, "wrong operator")
	assert_error = function(self, my_function, error_message, max_error)
		mandatoryArgument(1, "function", my_function)
		mandatoryArgument(2, "string", error_message)
		optionalArgument(3, "number", max_error)

		local found_error = false
		local _, err = xpcall(my_function, function(err)
			found_error = true
			if self.current_file then
				local err2 = string.match(err, self.current_file)
				if err2 ~= self.current_file then
					printError("Error in wrong file (possibly wrong stack level). It should occur in '"..self.current_file.."', got '"..err.."'.")
					printError(traceback())
					self.wrong_file = self.wrong_file + 1
					return
				end
			end
			local shortError = string.match(err, ":[0-9]*:.*")

			if shortError == nil then
				self.wrong_file = self.wrong_file + 1
				printError("Error should contain line number (possibly wrong stack level), got: '"..err.."'.")
				printError(traceback())
				return
			end

			shortError = string.gsub(shortError,":[0-9]*: ", "")
			local start = shortError:sub(1, 7)

			if start ~= "Error: " then
				print_error(self, "The error message does not start with \"Error:\": "..shortError)
			end

			shortError = shortError:sub(8, shortError:len())

			local distance = levenshtein(error_message, shortError)

			if (distance == 0) or (max_error and distance <= max_error) then
				self.success = self.success + 1
			else
				self.fail = self.fail + 1

				local error_msg = "Test expected:\n  '"..error_message.."'\n  got:\n  '"..shortError.."'"

				if max_error then
					error_msg = error_msg.."\nIt would accept an error of at most "..max_error..
						" character(s), but got "..distance.."."
				end

				print_error(self, error_msg)
				-- print(traceback())
			end
		end)

		if not found_error then
			print_error(self, "Test expected an error ('"..error_message.."'), but no error was found.", 2)
			self.fail = self.fail + 1
		end

		self.test = self.test + 1
	end,
	--- Verify whether a Chart or a Map has a plot similar to the one defined by snapshot folder.
	-- @arg observer A Chart or a Map.
	-- @arg file A string with the file name in the snapshot folder. If the file does not exist then 
	-- it will save the file in the snapshot folder.
	-- @usage c = Chart{...}
	-- unitTest:assert_snapshot(c, "test_chart.bmp")
	assert_snapshot = function(self, observer, file)
		self.snapshots = self.snapshots + 1
		local s = sessionInfo().separator
		if not self.imgFolder then
			self.imgFolder = sessionInfo().path..s.."packages"..s..self.package..s.."snapshots"
			if attributes(self.imgFolder, "mode") ~= "directory" then
				customError("Folder '"..self.imgFolder.."' does not exist. Please create such folder in order to use assert_snapshot().")
			end
			self.tsnapshots = {}
		end

		if self.tsnapshots[file] then
			print_error(self, "File '"..file.."' is used in more than one assert_shapshot().")
			self.fail = self.fail + 1
			return
		end

		self.tsnapshots[file] = true
		local newImage = self:tmpFolder()..s..file
		local oldImage = self.imgFolder..s..file

		if not isFile(oldImage) then
			observer:save(oldImage)
			self.snapshot_files = self.snapshot_files + 1
			printWarning("Creating 'snapshots"..s..file.."'.")
			self.test = self.test + 1
			self.success = self.success + 1
		else
			observer:save(newImage)

			if cpp_imagecompare(newImage, oldImage) then
				self.test = self.test + 1
				self.success = self.success + 1
			else
				print_error(self, "Files \n  'snapshots"..s..file.."'\nand\n  '"..newImage.."'\nare different.")
				self.fail = self.fail + 1
			end
		end
	end,
	--- Executes a delay in seconds during the test. Calling this function, the user can change the
	-- delay when the UnitTest is built.
	-- @usage unitTest:delay()
	delay = function()
	end,
	--- Create a temporary folder in the current directory and return its name. Every time this function
	-- is executed with the same instance of UnitTest it returns the same folder. This folder needs to
	-- be removed manually in the end of the tests or in the end of the simulation.
	-- @usage tmpfolder = unitTest:tmpFolder()
	tmpFolder = function(self)
		if not self.tmpfolder then
			self.tmpfolder = runCommand("mktemp -d .terrametmp_XXXXX")[1]
		end
		return self.tmpfolder
	end
}

local metaTableUnitTest_ = {
	__index = UnitTest_
}

--- Type for testing packages. All its arguments (but sleep) are necessary only when the tests
-- work with database access.
-- @arg data.dbType Name of the data source. See CellularSpace.
-- @arg data.host Name of the host. See CellularSpace.
-- @arg data.port Number of the port. See CellularSpace.
-- @arg data.password A password. See CellularSpace.
-- @arg data.user A user name. See CellularSpace.
-- @arg data.sleep A number indicating the amount of time to sleep every time there is a delay in
-- the tests.
-- @usage unitTest = UnitTest{}
function UnitTest(data)
	setmetatable(data, metaTableUnitTest_)

	if data.dbType ~= nil then
		data.dbType = string.lower(data.dbType)
	end

	if data.sleep then
		data.delay = function(self)
			delay(data.sleep)
			self.delayed_time = self.delayed_time + data.sleep
		end
	end

	return data
end

