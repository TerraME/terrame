
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

