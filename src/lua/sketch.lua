
local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote
local print        = _Gtme.print

function _Gtme.sketch(package)
	local report = {
		created_files = 0,
	}

	printNote("Verifying test files")

	local baseDir = packageInfo(package).path
	local s = sessionInfo().separator
	local testDir = baseDir..s.."tests"

	if not isDir(testDir) then
		printWarning("Creating folder 'tests'")
		mkDir(testDir)
	end

	import("base")
	local pkgData = _G.getPackage(package)
	local testfunctions = _Gtme.buildCountTable(package)

	forEachOrderedElement(testfunctions, function(idx, value)
		if isFile(testDir..s..idx) then
			print(idx.." already exists")
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

	print("\nSketch report:")

	if report.created_files == 0 then
		printNote("No new test file was necessary.")
	elseif report.created_files == 1 then
		printWarning("One test file was created. Please fill it and run the tests again.")
	else
		printWarning(report.created_files.." test files were created. Please fill them and run the tests again.")
	end
	os.exit()
end

