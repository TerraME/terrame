
local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote
local print        = _Gtme.print

local function verifyTest(package, report)
	printNote("Verifying test files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local testDir = baseDir..s.."tests"
	local internalFolder = false

	forEachFile(testDir, function(mfile)
		if isDir(testDir..s..mfile) then
			internalFolder = true
		end
	end)

	if internalFolder then
		_Gtme.printWarning("Internal folders were found in the tests. Ignoring tests.")
		return false
	end

	if not isDir(testDir) then
		printWarning("Creating folder 'tests'")
		mkDir(testDir)
	end

	local pkgData = _G.getPackage(package)
	local testfunctions = _Gtme.buildCountTable(package)

	forEachOrderedElement(testfunctions, function(idx, value)
		if isFile(testDir..s..idx) then
			print("File '"..idx.."' already exists in the tests")
			return
		end

		printWarning("Creating "..idx)
		report.created_files = report.created_files + 1

		str = "-- Test file for "..idx.."\n"
		str = str.."-- Author: "..packageInfo(package).authors
		str = str.."\n\nreturn{\n"

		forEachOrderedElement(value, function(func)
			str = str.."\t"..func.." = function(unitTest)\n"

			if type(pkgData[func]) == "Model" then
				local model = pkgData[func]{}

				str = str.."\t\tlocal model = "..func.."{}\n\n"

				local countMap = 1

				forEachOrderedElement(model, function(idx, value, mtype)
					if mtype == "Map" then
						str = str.."\t\tunitTest:assertSnapshot(model."..idx..", \""..func.."-map-"..countMap.."-begin.bmp\")\n"
						countMap = countMap + 1
					end
				end)

				str = str.."\n\t\tmodel:execute()\n\n"

				local countChart = 1
				local countMap = 1

				forEachOrderedElement(model, function(idx, value, mtype)
					if mtype == "Chart" then
						str = str.."\t\tunitTest:assertSnapshot(model."..idx..", \""..func.."-chart-"..countChart..".bmp\")\n"
						countChart = countChart + 1
					elseif mtype == "Map" then
						str = str.."\t\tunitTest:assertSnapshot(model."..idx..", \""..func.."-map-"..countMap.."-end.bmp\")\n"
						countMap = countMap + 1
					end
				end)

				clean()

			else
				str = str.."\t\t-- add a test here \n"
			end

			str = str.."\tend,\n"
		end)

		str = str.."}\n\n"

		local file = io.open(testDir..s..idx, "w")
		io.output(file)
		io.write(str)
		io.close(file)
	end)
end

local function verifyData(package, report)
	printNote("Verifying data files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local dataDir = baseDir..s.."data"

	if not isDir(dataDir) then
		_Gtme.print("Package '"..package.."' does not have a data folder")
		return
	end

	local datafiles = {}
	local datadotlua = baseDir..s.."data.lua"

	forEachFile(dataDir, function(file)
		datafiles[file] = false
	end)

	if getn(datafiles) == 0 then
		_Gtme.print("Package '"..package.."' has no data")
		return
	end

	if isFile(datadotlua) then
		local originaldata = data
		data = function(mdata)
			if type(mdata.file) == "string" then
				datafiles[mdata.file] = true
			elseif type(mdata.file) == "table" then
				forEachElement(mdata.file, function(_, mfile)
					datafiles[mfile] = true
				end)
			end
		end

		_Gtme.include(baseDir..s.."data.lua")
		data = originaldata
	else
		_Gtme.print("Creating 'data.lua'")
	end

	local mfile = io.open(datadotlua, "a")

	forEachOrderedElement(datafiles, function(idx, value)
		if value then
			_Gtme.print("File '"..idx.."' is already documented in 'data.lua'")
		elseif isDir(dataDir..s..idx) then
			_Gtme.print("Folder '"..idx.."' will be ignored")
		else
			_Gtme.printWarning("Adding sketch for data file '"..idx.."'")
			local str = "data{\n"
				.."\tfile = \""..idx.."\",\n"
    			.."\tsummary = \"\",\n"
    			.."\tsource = \"\",\n"
    			.."\tattributes = {},  -- optional\n"
    			.."\ttypes = {},       -- optional\n"
    			.."\tdescription = {}, -- optional\n"
    			.."\treference = \"\"    -- optional\n"
				.."}\n\n"
			mfile:write(str)

			report.created_data = report.created_data + 1
		end
	end)

	mfile:close()
end

function _Gtme.sketch(package)
	local report = {
		created_files = 0,
		created_data = 0,
	}

	import("base")

	verifyTest(package, report)
	verifyData(package, report)

	print("\nSketch report:")

	if report.created_files == 0 then
		printNote("No new test file was necessary.")
	elseif report.created_files == 1 then
		printWarning("One test file was created. Please fill it and run the tests again.")
	else
		printWarning(report.created_files.." test files were created. Please fill them and run the tests again.")
	end

	if report.created_data == 0 then
		printNote("All data is already documented.")
	elseif report.created_data == 1 then
		printWarning("One data file was not documented. Please fill data.lua with its parameters.")
	else
		printWarning(report.created_data.." data files were not documented. Please fill data.lua with their parameters.")
	end

	os.exit()
end

