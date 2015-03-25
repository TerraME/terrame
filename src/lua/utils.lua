
function getDescription__(file)
	local result 
	xpcall(function() result = include(file) end, function(err)
		printError("Package "..package.." has a corrupted description.lua")
		printError(err)
		os.exit()
	end)

	if result == nil then
		customError("Could not read description.lua")
	end

	return result
end

function tmerequire__(package)
	mandatoryArgument(1, "string", package)

	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	if not isFile(package_path) then
		if isFile(package) then
			printWarning("Loading package '"..package.."' from a folder in the current directory")
			package_path = package
		else
			customError("Package '"..package.."' is not installed.")
		end
	end

	local load_file = package_path..s.."load.lua"
	local all_files = dir(package_path..s.."lua")
	local load_sequence

	if isFile(load_file) then
		xpcall(function() load_sequence = include(load_file) end, function(err)
			printError("Package '"..package.."' could not be loaded.")
			print(err)
		end)

		checkUnnecessaryArguments(load_sequence, {"files"})

		load_sequence = load_sequence.files
		if load_sequence == nil then
			printError("Package '"..package.."' could not be loaded.")
			printError("load.lua should declare table 'files', with the order of the files to be loaded.")
			os.exit()
		elseif type(load_sequence) ~= "table" then
			printError("Package '"..package.."' could not be loaded.")
			printError("In load.lua, 'files' should be table, got "..type(load_sequence)..".")
			os.exit()
		end
	else
		load_sequence = all_files
	end

	local count_files = {}
	for _, file in ipairs(all_files) do
		count_files[file] = 0
	end

	local i, file

	if load_sequence then
		for _, file in ipairs(load_sequence) do
			local mfile = package_path..s.."lua"..s..file
			if not isFile(mfile) then
				printError("Cannot open "..mfile..". No such file.")
				printError("Please check "..package_path..s.."load.lua")
				os.exit()
			end
			xpcall(function() dofile(mfile) end, function(err)
				printError("Package '"..package.."' could not be loaded.")
				printError(err)
				os.exit()
			end)
			count_files[file] = count_files[file] + 1
		end
	end

	for mfile, count in pairs(count_files) do
		local attr = attributes(package_path..s.."lua"..s..mfile)
		if count == 0 and attr.mode ~= "directory" then
			printWarning("File lua"..s..mfile.." is ignored by load.lua.")
		elseif count > 1 then
			printWarning("File lua"..s..mfile.." is loaded "..count.." times in load.lua.")
		end
	end
end

function assertError__(self, my_function, error_message, max_error)
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
			self:print_error("The error message does not start with \"Error:\": "..shortError)
		end

		shortError = shortError:sub(8, shortError:len())

		local distance = levenshtein(error_message, shortError)

		if (distance == 0) or (max_error and distance <= max_error) then
			self.success = self.success + 1
		else
			self.fail = self.fail + 1

			local error_msg = "Test expected:\n  \""..error_message.."\"\n  got:\n  \""..shortError.."\""

			if max_error then
				error_msg = error_msg.."\nIt would accept an error of at most "..max_error..
					" character(s), but got "..distance.."."
			end

			self:print_error(error_msg)
			-- print(traceback())
		end
	end)

	if not found_error then
		self:print_error("Test expected an error ('"..error_message.."'), but no error was found.", 2)
		self.fail = self.fail + 1
	end

	self.test = self.test + 1
end

function assertSnapshot__(self, observer, file)
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
		self:print_error("File '"..file.."' is used in more than one assert_shapshot().")
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
			self:print_error("Files \n  'snapshots"..s..file.."'\nand\n  '"..newImage.."'\nare different.")
			self.fail = self.fail + 1
		end
	end
end

