-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

local function simplifyPath(value)
	value = _Gtme.makePathCompatibleToAllOS(value)

	if value:match("\n") then
		local tempstr = ""

		for line in value:gmatch("(.-)\n") do
			tempstr = tempstr..simplifyPath(line).."\n"
		end

		return tempstr
	end

	local first = string.find(value, "/")
	local last = string.find(value, "/[^/]*$")

	if not first then return value end

	if string.sub(value, first - 1, first - 1) == ":" then -- remove "C:", "D:", ...
		first = first - 2
	end

	if first == last then return value end

	return string.sub(value, 1, first - 1)..string.sub(value, last + 1)
end

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
		mandatoryArgument(1, "boolean", value)

		self.test = self.test + 1

		if value then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Test should be true, got false.") -- SKIP (to test this line, run execution tests, package 'unittest')
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
	-- @arg ignorePath A boolean to ignore path between /'s, when comparing two strings. It
	-- automatically converts a string such as "directory/sub1/sub2/file" into "directory/file".
	-- This argument is optional and can be used only with strings. The default value is false.
	-- @usage unitTest = UnitTest{}
	-- unitTest:assertEquals(3, 3)
	-- unitTest:assertEquals(2, 2.1, 0.2)
	-- unitTest:assertEquals("string [terralib/data/biomassa-manaus.asc]", "string [terralib/biomassa-manaus.asc]", 0, true)
	assertEquals = function(self, v1, v2, tol, ignorePath)
		if v1 == nil then
			mandatoryArgumentError(1)
		elseif v2 == nil then
			mandatoryArgumentError(2)
		end

		if type(v1) == type(v2) and belong(type(v1), {"File", "Directory"}) then
			v1 = tostring(v1)
			v2 = tostring(v2)
		end

		if tol ~= nil and type(v1) ~= "number" and type(v1) ~= "string" then
			customError("#3 should be used only when comparing numbers or strings (#1 is "..type(v1)..").")
		end

		if tol == nil then tol = 0 end
		mandatoryArgument(3, "number", tol)

		if ignorePath == nil then ignorePath = false end
		mandatoryArgument(4, "boolean", ignorePath)

		self.test = self.test + 1

		if type(v1) == "number" and type(v2) == "number" then
			local dist = math.abs(v1 - v2)
			if dist <= tol or v1 == v2 then
				self.success = self.success + 1
			else
				self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
				local msg = "Values should be equal, but got '"..v1.."' and '"..v2.."'. "..
					"The maximum difference is "..tol..", but got "..dist.."." -- SKIP (to test this line, run execution tests, package 'unittest')

				self:printError(msg)
			end
		elseif type(v1) == "string" and type(v2) == "string" then
			if ignorePath then
				v1 = simplifyPath(v1)
			end

			local dist = levenshtein(v1, v2)
			if dist <= tol then
				self.success = self.success + 1
			else
				self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
				local msg = "Values should be equal, but got \n'"..v1.."' and \n'"..v2.."'."
					.." The maximum tolerance is "..tol..", but got "..dist.."." -- SKIP (to test this line, run execution tests, package 'unittest')

				self:printError(msg)
			end
		elseif type(v1) ~= type(v2) then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Values should be equal, but they have different types ("..type(v1).." and "..type(v2)..").")
		elseif v1 ~= v2 then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Values have the same type ("..type(v1)..") but different values.")
		else
			self.success = self.success + 1
		end
	end,
	--- Verify if a function produces an error. If there is no error in the function or the
	-- error found is not the expected error then it generates an error.
	-- @arg my_function A function to be tested.
	-- @arg error_message A string describing the error message that the function should produce.
	-- This string should contain only the error message, without the description of the file name
	-- where the error was produced.
	-- @arg max_error A number indicating the maximum number of characters that can be different
	-- between the error produced by the error function and the expected error message.
	-- This argument might be necessary in error messages that include information that can change
	-- from machine to machine, such as an username. The default value is zero (no discrepancy).
	-- @arg ignorePath A boolean to ignore path between /'s, when comparing two strings. It
	-- automatically converts a string such as "directory/sub1/sub2/file" into "directory/file".
	-- The default value is false.
	-- @usage unitTest = UnitTest{}
	-- error_func = function() verify(2 > 3, "wrong operator") end
	-- unitTest:assertError(error_func, "wrong operator")
	assertError = function(self, my_function, error_message, max_error, ignorePath)
		mandatoryArgument(1, "function", my_function)
		mandatoryArgument(2, "string", error_message)
		optionalArgument(3, "number", max_error)

		if ignorePath == nil then ignorePath = false end
		mandatoryArgument(4, "boolean", ignorePath)

		local found_error = false
		local fail = false
		local stop_warning = false

		local originalStrictWarning = strictWarning
		local originalCustomWarning = customWarning

		customWarning = function(msg)
			if stop_warning then return end

			self:printError("Warning function called with argument '"..msg.."' within an UnitTest:assertError(). Please use UnitTest:assertWarning() instead.")
			found_error = true -- SKIP (to test this line, run execution tests, package 'unittest')
			stop_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
			fail = true -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		strictWarning = customWarning

		xpcall(my_function, function(err)
			found_error = true
			if self.current_file then
				local err2 = string.match(err, self.current_file)
				if err2 ~= self.current_file then
					_Gtme.printError("Error in wrong file (possibly wrong stack level). It should occur in '".._Gtme.makePathCompatibleToAllOS(self.current_file).."', got:")
					_Gtme.printError(_Gtme.traceback(err))
					self.wrong_file = self.wrong_file + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
					return
				end
			end

			local shortError = string.match(err, ":[0-9]*:.*")

			if shortError == nil then
				self.wrong_file = self.wrong_file + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
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

			if ignorePath then
				shortError = simplifyPath(shortError)
			end

			local distance = levenshtein(error_message, shortError)

			if distance == 0 or (max_error and distance <= max_error) then
				self.success = self.success + 1
			else
				fail = true -- SKIP (to test this line, run execution tests, package 'unittest')

				local error_msg = "Test expected:\n  \""..error_message.."\"\n  got:\n  \""..shortError.."\""

				if max_error then -- SKIP (to test this line, run execution tests, package 'unittest')
					error_msg = error_msg.."\nIt would accept an error of at most "..max_error.. -- SKIP (to test this line, run execution tests, package 'unittest')
						" character(s), but got "..distance.."." -- SKIP (to test this line, run execution tests, package 'unittest')
				end

				self:printError(error_msg)
				-- print(traceback())
			end
		end)

		strictWarning = originalStrictWarning
		customWarning = originalCustomWarning

		if fail then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
		elseif not found_error then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Test expected an error ('"..error_message.."'), but no error was found.")
		end

		self.test = self.test + 1
	end,
	--- Check if a given file exists and remove it. Repeating: The file is removed when calling
	-- this assert. If the file is a directory or does not exist then it shows an error.
	-- @arg fname A File or a string with the file name.
	-- @arg tol An optional number indicating a maximum number of characters that can be different.
	-- The tolerance is applied to each line of the files. The default tolerance is zero.
	-- @usage -- DONTRUN
	-- unitTest = UnitTest{}
	-- os.execute("touch file.txt") -- create a file (only works in Linux and Mac)
	-- unitTest:assertFile("file.txt")
	assertFile = function(self, fname, tol)
		if not tol then tol = 0 end

		if type(fname) == "string" then
			fname = File(fname)
		end

		mandatoryArgument(1, "File", fname)
		mandatoryArgument(2, "number", tol)

		fname = fname:name()

		self.test = self.test + 1
		if not File(fname):exists() then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError(resourceNotFoundMsg(1, fname))
			return
		end

		if not self.log then
			File(fname):deleteIfExists()
			customError("It is not possible to use assertFile without a 'log' directory.")
		end

		if not self.logs then self.logs = 0 end
		self.logs = self.logs + 1

		if not self.tlogs then
			self.tlogs = {}
		end

		if self.tlogs[fname] then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Log file '"..fname.."' is used in more than one assert.")
			File(fname):deleteIfExists() -- SKIP (to test this line, run execution tests, package 'unittest')
			return
		end

		self.tlogs[fname] = true

		if not self.tmpdir then
			self.tmpdir = Directory{tmp = true} -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		os.execute("cp \""..fname.."\" \""..self.tmpdir.."\"")
		File(fname):deleteIfExists()

		if File(fname):exists() then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Could not remove file '"..fname.."'.")
			return
		end

		local s = sessionInfo().separator
		local oldLog = self.log..s..fname

		if not File(oldLog):exists() then
			if not self.created_logs then -- SKIP (to test this line, run execution tests, package 'unittest')
				self.created_logs = 0 -- SKIP (to test this line, run execution tests, package 'unittest')
			end

			self.created_logs = self.created_logs + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			_Gtme.printError("Creating '".._Gtme.makePathCompatibleToAllOS("log"..s..sessionInfo().system..s..fname).."'.")
			os.execute("cp \""..self.tmpdir..s..fname.."\" \""..oldLog.."\"") -- SKIP (to test this line, run execution tests, package 'unittest')
			self.test = self.test + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self.success = self.success + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
		else
			oldLog = File(oldLog)
			local newLog = File(self.tmpdir..s..fname)

			local line = 1
			local removeCR = function(str)
				if not str then return nil end

				if string.byte(string.sub(str, string.len(str))) == 13 then
					return string.sub(str, 1, string.len(str) - 1)
				end

				return str
			end

			local oldStr = removeCR(oldLog:readLine())
			local newStr = removeCR(newLog:readLine())

			while oldStr and newStr do
				local dist = levenshtein(oldStr, newStr)

				if dist > tol then
					_Gtme.printError("Error: In file '"..fname.."', strings do not match (line "..line.."):")
					_Gtme.printError("Log file: '"..oldStr.."'")
					_Gtme.printError("Test: '"..newStr.."'")
					_Gtme.printError("There are "..dist.." characters different. The maximum tolerance is "..tol..".")

					self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
					return false
				end

				line = line + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
				oldStr = removeCR(oldLog:readLine())
				newStr = removeCR(newLog:readLine())
			end

			if oldStr or newStr then
				if not oldStr then oldStr = "<end of file>" end
				if not newStr then newStr = "<end of file>" end

				_Gtme.printError("Error: Strings do not match in file '"..fname.."' (line "..line.."):")
				_Gtme.printError("Log file: '"..oldStr.."'")
				_Gtme.printError("Test: '"..newStr.."'")

				self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
				return false
			end

			io.close(newLog.file)
			io.close(oldLog.file)
			self.success = self.success + 1
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
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
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
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
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
			File(file):deleteIfExists()
			customError("It is not possible to use assertSnapshot without a 'log' directory.")
		end

		if not self.logs then
			self.logs = 0 -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		self.logs = self.logs + 1

		if not self.tlogs then
			self.tlogs = {}
		end

		if self.tlogs[file] then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Log file '"..file.."' is used in more than one assert.")
			return
		end

		self.tlogs[file] = true

		if not self.tmpdir then
			self.tmpdir = Directory{tmp = true} -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		local newImage = self.tmpdir..file
		local oldImage = self.log..file

		if not File(oldImage):exists() then
			observer:save(oldImage) -- SKIP (to test this line, run execution tests, package 'unittest')

			if not self.created_logs then -- SKIP (to test this line, run execution tests, package 'unittest')
				self.created_logs = 0 -- SKIP (to test this line, run execution tests, package 'unittest')
			end

			self.created_logs = self.created_logs + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			_Gtme.printError("Creating '".._Gtme.makePathCompatibleToAllOS("log"..s..sessionInfo().system..s..file).."'.")
			self.test = self.test + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self.success = self.success + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
		else
			observer:save(newImage)

			self.test = self.test + 1
			local merror = cpp_imagecompare(newImage, oldImage)

			if merror <= tolerance then
				self.success = self.success + 1
			else
				local wnew, hnew = cpp_imagesize(newImage) -- SKIP (to test this line, run execution tests, package 'unittest')
				local wold, hold = cpp_imagesize(oldImage) -- SKIP (to test this line, run execution tests, package 'unittest')

				local message = "Files \n  '".._Gtme.makePathCompatibleToAllOS("log"..s..sessionInfo().system..s..file)
					.."'\nand\n  '"..newImage.."'\nare different." -- SKIP (to test this line, run execution tests, package 'unittest')

				if wnew ~= wold or hnew ~= hold then -- SKIP (to test this line, run execution tests, package 'unittest')
					message = message.." Image sizes are different: "..string.format("%.0fx%.0f", wnew, hnew).." (created) and "..string.format("%.0fx%.0f", wold, hold).." (log)." -- SKIP (to test this line, run execution tests, package 'unittest')
				else
					message = message.." The maximum tolerance is "..tolerance..", but got "..merror.."." -- SKIP (to test this line, run execution tests, package 'unittest')
				end

				self:printError(message)
				self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
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
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Test should be "..mtype.." got "..type(value)..".")
		end
	end,
	--- Verify if a function produces a warning. If there is no warning in the function or the
	-- warning found is not the expected value then it generates an error.
	-- @arg my_function A function to be tested.
	-- @arg warning_message A string describing the warning message that the function is expected to produce.
	-- This string should contain only the warning message, without the description of the file name
	-- where the warning was produced.
	-- @arg max_error A number indicating the maximum number of characters that can be different
	-- between the warning produced by the warning function and the expected warning.
	-- This argument might be necessary in warnings that include information that can change
	-- from machine to machine, such as an username. The default value is zero (no discrepancy).
	-- @arg ignorePath A boolean to ignore path between /'s, when comparing two strings. It
	-- automatically converts a string such as "c:/directory/sub1/sub2/file.txt" into "file.txt".
	-- The default value is false.
	-- @usage unitTest = UnitTest{}
	-- error_func = function() customWarning("Did you forget something?") end
	-- unitTest:assertWarning(error_func, "Did you forget something?")
	assertWarning = function(self, my_function, warning_message, max_error, ignorePath)
		mandatoryArgument(1, "function", my_function)
		mandatoryArgument(2, "string", warning_message)
		optionalArgument(3, "number", max_error)

		if ignorePath == nil then ignorePath = false end
		mandatoryArgument(4, "boolean", ignorePath)

		local found_warning = false
		local last_warning
		local stop_warning = false
		local error_warning = false

		local originalStrictWarning = strictWarning
		local originalCustomWarning = customWarning
		local originalCustomError = customError

		customError = function(msg)
			if stop_warning then return end

			self:printError("Error function called with argument '"..msg.."' within UnitTest:assertWarning(). Please use UnitTest:assertError() instead.")
			error_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
			stop_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		customWarning = function(msg)
			if stop_warning then return end

			if type(msg) ~= "string" then
				self:printError("#1 should be string, got "..type(msg)..".")
				stop_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
				error_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
				return
			end

			if found_warning then
				stop_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')
				error_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')

				if msg == last_warning then -- SKIP (to test this line, run execution tests, package 'unittest')
					self:printError("Test should produce only one warning, got '"..msg.."' at least twice.")
				else
					self:printError("Test should produce only one warning, got '"..last_warning.."' and '"..msg.."'.")
				end

				return
			end

			found_warning = true
			last_warning = msg

			if ignorePath then
				msg = simplifyPath(msg) -- SKIP (to test this line, run execution tests, package 'unittest')
			end

			local distance = levenshtein(warning_message, msg)

			if (not max_error and distance > 0) or (max_error and distance > max_error) then
				error_warning = true -- SKIP (to test this line, run execution tests, package 'unittest')

				local error_msg = "Test expected:\n  \""..warning_message.."\"\n  got:\n  \""..msg.."\""

				if max_error then -- SKIP (to test this line, run execution tests, package 'unittest')
					error_msg = error_msg.."\nIt would accept an error of at most "..max_error.. -- SKIP (to test this line, run execution tests, package 'unittest')
						" character(s), but got "..distance.."." -- SKIP (to test this line, run execution tests, package 'unittest')
				end

				self:printError(error_msg)
				-- print(traceback())
			end
		end

		strictWarning = customWarning

		pcall(my_function)

		strictWarning = originalStrictWarning
		customWarning = originalCustomWarning
		customError   = originalCustomError

		if error_warning then
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
		elseif found_warning then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			self:printError("Test expected a warning ('"..warning_message.."'), but no warning was found.")
		end

		self.test = self.test + 1
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
		while debug.getinfo(level + 1) and not string.match(infoSource, "/tests/") do
			level = level + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
			info = debug.getinfo(level) -- SKIP (to test this line, run execution tests, package 'unittest')
			infoSource = _Gtme.makePathCompatibleToAllOS(info.source) -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		msg = tostring(msg) -- SKIP (to test this line, run execution tests, package 'unittest')

		local str = info.short_src
		str = "Error in ".._Gtme.makePathCompatibleToAllOS(str)..":".. info.currentline ..": "..msg -- SKIP (to test this line, run execution tests, package 'unittest')
		if self.last_error == str then -- SKIP (to test this line, run execution tests, package 'unittest')
			self.count_last = self.count_last + 1 -- SKIP (to test this line, run execution tests, package 'unittest')
		elseif self.count_last > 0 then
			local count = self.count_last
			self.count_last = 0 -- SKIP (to test this line, run execution tests, package 'unittest')
			self.last_error = str -- SKIP (to test this line, run execution tests, package 'unittest')

			_Gtme.printError("[The error above occurs more "..count.." times.]")
		else
			self.last_error = str -- SKIP (to test this line, run execution tests, package 'unittest')
		end

		if self.count_last == 0 then -- SKIP (to test this line, run execution tests, package 'unittest')
			_Gtme.printError(str)
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

