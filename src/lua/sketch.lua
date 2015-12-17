
local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote
local print        = _Gtme.print

local function verifyTest(package, report)
	printNote("Verifying test files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local testDir = baseDir..s.."tests"
	local internalDirectory = false

	if not isDir(baseDir..s.."lua") then
		_Gtme.print("Package '"..package.."' does not have source code")
		return
	end

	if not isDir(testDir) then
		printWarning("Creating directory 'tests'")
		mkDir(testDir)
	end

	forEachFile(testDir, function(mfile)
		if isDir(testDir..s..mfile) then
			internalDirectory = true
		end
	end)

	if internalDirectory then
		_Gtme.printWarning("Ignoring tests because internal directories were found in the tests")
		return false
	end

	local pkgData = _G.getPackage(package)
	local testfunctions = _Gtme.buildCountTable(package)

	forEachOrderedElement(testfunctions, function(idx, value)
		if isFile(testDir..s..idx) then
			print("File '"..idx.."' already exists in the tests")
			return
		end

		local sub = string.sub(idx, 1, -5)

		if type(pkgData[sub]) == "Model" then
			local mandatory = false
			forEachElement(pkgData[sub](), function(_, _, mtype)
				if mtype == "Mandatory" then
					mandatory = true
				end
			end)

			if mandatory then
				printNote("Ignoring Model '"..sub.."' as it has a Mandatory argument")
				return
			end
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

				if countMap > 1 then
					str = str.."\n"
				end

				str = str.."\t\tmodel:execute()\n\n"

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
		_Gtme.print("Package '"..package.."' does not have a data directory")
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

		_Gtme.include(datadotlua)
		data = originaldata
	else
		_Gtme.print("Creating 'data.lua'")
	end

	local mfile = io.open(datadotlua, "a")

	forEachOrderedElement(datafiles, function(idx, value)
		if value then
			_Gtme.print("File '"..idx.."' is already documented in 'data.lua'")
		elseif isDir(dataDir..s..idx) then
			_Gtme.print("Directory '"..idx.."' will be ignored")
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

local function verifyFont(package, report)
	printNote("Verifying font files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local fontDir = baseDir..s.."font"

	if not isDir(fontDir) then
		_Gtme.print("Package '"..package.."' does not have a font directory")
		return
	end

	local fontfiles = {}
	local fontdotlua = baseDir..s.."font.lua"

	forEachFile(fontDir, function(file)
		fontfiles[file] = false
	end)

	if getn(fontfiles) == 0 then
		_Gtme.print("Package '"..package.."' has no fonts")
		return
	end

	if isFile(fontdotlua) then
		local originalfont = font
		font = function(mfont)
			if type(mfont.file) == "string" then
				fontfiles[mfont.file] = true
			end
		end

		_Gtme.include(fontdotlua)
		font = originalfont
	else
		_Gtme.print("Creating 'font.lua'")
	end

	local mfile = io.open(fontdotlua, "a")

	forEachOrderedElement(fontfiles, function(idx, value)
		if value then
			_Gtme.print("File '"..idx.."' is already documented in 'font.lua'")
		elseif string.endswith(idx, ".ttf") then
			_Gtme.printWarning("Adding sketch for font file '"..idx.."'")
			local str = "font{\n"
				.."\tfile = \""..idx.."\",\n"
    			.."\tname = \"\",    -- optional\n"
    			.."\tsummary = \"\",\n"
    			.."\tsource = \"\",\n"
    			.."\tsymbol = {}\n"
				.."}\n\n"
			mfile:write(str)

			report.created_font = report.created_font + 1
		else
			_Gtme.print("File '"..idx.."' will be ignored")
		end
	end)

	mfile:close()
end


function _Gtme.sketch(package)
	local report = {
		created_files = 0,
		created_data = 0,
		created_font = 0,
	}

	import("base")

	verifyTest(package, report)
	verifyData(package, report)
	verifyFont(package, report)

	print("\nSketch report:")

	if report.created_files == 0 then
		printNote("No new test file was necessary.")
	elseif report.created_files == 1 then
		printWarning("One test file was created.")
	else
		printWarning(report.created_files.." test files were created.")
	end

	if report.created_data == 0 then
		printNote("All data is already documented.")
	elseif report.created_data == 1 then
		printWarning("One data file was not documented.")
	else
		printWarning(report.created_data.." data files were not documented.")
	end

	if report.created_font == 0 then
		printNote("All font files are already documented.")
	elseif report.created_font == 1 then
		printWarning("One font file was not documented.")
	else
		printWarning(report.created_font.." font files were not documented.")
	end

	local errors = 0

	forEachElement(report, function(_, value)
		errors = errors + value
	end)

	if errors == 0 then
		printNote("Summing up, no sketch was created.")
	elseif errors == 1 then
		printError("Summing up, one sketch was created. Please fill it.")
	else
		printError("Summing up, "..errors.." sketches were created. Please fill them.")
	end

	os.exit()
end

