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

local printError   = _Gtme.printError
local printNote    = _Gtme.printNote

function _Gtme.executeProject(package)
	local initialTime = os.clock()

	if not isLoaded("base") then
		import("base")
	end

	if not isLoaded("terralib") then
		import("terralib")
	end

	printNote("Creating projects for package '"..package.."'")
	local s = sessionInfo().separator
	local package_path = _Gtme.packageInfo(package).path

	local data_path = package_path..s.."data"

	chDir(data_path)

	local project_report = {
		projects = 0,
		errors_processing = 0,
		errors_output = 0,
		errors_invalid = 0
	}

	printNote("Removing output files")
	forEachFile(data_path, function(file)
		if string.endswith(file, ".lua") then
			local output = string.sub(file, 1, -5)..".tview"

			if File(output):exists() then
				print("Removing file '"..output.."'.")
				rmFile(output)
			end
		end
	end)

	printNote("Checking if data does not contain any .tview file")
	forEachFile(data_path, function(file)
		if string.endswith(file, ".tview") then
			printError("File '"..file.."' should not exist as there is no Lua script with this name.")
			project_report.errors_invalid = project_report.errors_invalid + 1
		end
	end)

	printNote("Creating .tview files")
	forEachFile(data_path, function(file)
		if string.endswith(file, ".lua") then
			print("Processing '"..file.."'")
			project_report.projects = project_report.projects + 1

			local filename = File(file):getName()
			local output = filename..".tview"

			local filesDir = {}
			forEachFile(dir(), function(oldFile)
				filesDir[oldFile] = true
			end)

			xpcall(function() dofile(data_path..s..file) end, function(err)
				printError(err)
				project_report.errors_processing = project_report.errors_processing + 1
			end)

			if File(output):exists() then
				print("File '"..output.."' was successfully created.")
			else
				printError("File '"..output.."' was not created.")
				project_report.errors_output = project_report.errors_output + 1
			end

			forEachFile(dir(), function(newFile)
				if filesDir[newFile] == nil then
					local fileInfo = File(newFile)
					if not fileInfo:getName() == filename then
						printError("File '"..fileInfo:getNameWithExtension().."' should be named '"..filename.."."..fileInfo:getExtension().."'.")
						project_report.errors_output = project_report.errors_output + 1
					end
				end
			end)
		end
	end)

	local finalTime = os.clock()

	print("\nProjects report for package '"..package.."':")
	printNote("Projects were created in "..round(finalTime - initialTime, 2).." seconds.")

	if project_report.projects == 0 then
		printNote("No project file was created.")
		os.exit(0)
	elseif project_report.projects == 1 then
		printNote("One project file was created.")
	else
		printNote(project_report.projects.." project files were created.")
	end

	local errors = project_report.errors_processing + project_report.errors_output + project_report.errors_invalid

	if project_report.errors_invalid == 0 then
		printNote("No invalid .tview file was found in the package.")
	elseif project_report.errors_invalid == 1 then
		printError("One invalid .tview file was found in the package.")
	else
		printError(project_report.errors_invalid.." invalid .tview file were found in the package.")
	end

	if project_report.errors_processing == 0 then
		printNote("No error was found while creating projects.")
	elseif project_report.errors_processing == 1 then
		printError("One error was found while creating projects.")
	else
		printError(project_report.errors_processing.." errors were found while creating projects.")
	end

	if errors == 0 then
		printNote("Summing up, all projects were successfully created.")
	elseif errors == 1 then
		printError("Summing up, one problem was found while creating projects.")
	else
		printError("Summing up, "..errors.." problems were found while creating projects.")
	end

	os.exit(errors)
end

