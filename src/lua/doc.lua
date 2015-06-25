-------------------------------------------------------------------------------------------
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
--       Pedro R. Andrade (pedro.andrade@inpe.br)
--       Raian V. Maretto
-------------------------------------------------------------------------------------------

local printError   = _Gtme.printError
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote

local function dataFiles(package)
	local s = sessionInfo().separator
	local datapath = packageInfo(package).data

	if attributes(datapath, "mode") ~= "directory" then
		return {}
	end

	local files = dir(datapath)
	local result = {}

	forEachElement(files, function(_, fname)
		table.insert(result, fname)
	end)
	return result
end

function _Gtme.executeDoc(package)
	local initialTime = os.clock()

	import("luadoc")
	import("base")

	printNote("Building documentation for package '"..package.."'")
	local s = sessionInfo().separator
	local package_path = _Gtme.packageInfo(package).path

	printNote("Loading package '"..package.."'")

	xpcall(function() _G.package(package) end, function(err)
		printError("Package "..package.." could not be loaded.")
		printError(err)
		os.exit()
	end)

	local lua_files = dir(package_path..s.."lua")

	local example_files = _Gtme.findExamples(package)

	local doc_report = {
		arguments = 0,
		lua_files = 0,
		html_files = 0,
		global_functions = 0,
		functions = 0,
		models = 0,
		model_error = 0,
		variables = 0,
		links = 0,
		examples = 0,
		wrong_description = 0,
		undoc_arg = 0,
		undefined_arg = 0,
		duplicated_functions = 0,
		unused_arg = 0,
		unknown_arg = 0,
		undoc_files = 0,
		lack_usage = 0,
		no_call_itself_usage = 0,
		wrong_links = 0,
		invalid_tags = 0,
		problem_examples = 0,
		duplicated = 0,
		compulsory_arguments = 0,
		undoc_functions = 0,
		undoc_examples = 0,
		undoc_data = 0,
		wrong_data = 0,
		wrong_line = 0,
		wrong_tabular = 0,
		wrong_descriptions = 0
	}

	local mdata = {}
	local filesdocumented = {}

	if isFile(package_path..s.."data.lua") then
		printNote("Parsing 'data.lua'")
		data = function(tab)
			local count = verifyUnnecessaryArguments(tab, {"file", "summary", "source", "attributes", "types", "description", "reference"})
			doc_report.wrong_data = doc_report.wrong_data + count

			if type(tab.file)        == "string" then tab.file = {tab.file} end
			if type(tab.attributes)  == "string" then tab.attributes = {tab.attributes} end
			if type(tab.types)       == "string" then tab.types = {tab.types} end
			if type(tab.description) == "string" then tab.description = {tab.description} end

			local mverify = {
				{"mandatoryTableArgument", "file",        "table"},
				{"mandatoryTableArgument", "summary",     "string"},
				{"mandatoryTableArgument", "source",      "string"},
				{"optionalTableArgument",  "file",        "table"},
				{"optionalTableArgument",  "attributes",  "table"},
				{"optionalTableArgument",  "types",       "table"},
				{"optionalTableArgument",  "description", "table"},
				{"optionalTableArgument",  "reference",   "string"}
			}

			if tab.attributes or tab.types or tab.description then
				if tab.attributes  == nil then tab.attributes  = {} end
				if tab.types       == nil then tab.types       = {} end
				if tab.description == nil then tab.description = {} end

				local verifySize = function()
					local ds = "Different sizes in the documentation: "
					if #tab.attributes ~= #tab.types then
						customError(ds.."'attributes' ("..#tab.attributes..") and 'types' ("..#tab.types..").")
					end

					if #tab.attributes ~= #tab.description then
						customError(ds.."'attributes' ("..#tab.attributes..") and 'description' ("..#tab.description..").")
					end
				end

				xpcall(verifySize, function(err)
					doc_report.wrong_data = doc_report.wrong_data + 1
					tab.attributes = {"_incompatible_"}
					printError(err)
				end)

			end

			-- it is necessary to implement this way in order to get the line number of the error
			for i = 1, #mverify do
				local func = "return function(tab) "..mverify[i][1].."(tab, \""..mverify[i][2].."\", \""..mverify[i][3].."\") end"

				xpcall(function() load(func)()(tab) end, function(err)
					doc_report.wrong_data = doc_report.wrong_data + 1
					printError(err)
				end)
			end

			if tab.summary then
				tab.shortsummary = string.match(tab.summary, "(.-%.)")
			end

			if tab.file then
				table.insert(mdata, tab)

				forEachElement(tab.file, function(_, mvalue)
					if filesdocumented[mvalue] then
						printError("Data file '"..mvalue.."' is documented more than once.")
						doc_report.wrong_data = doc_report.wrong_data + 1
					end
					filesdocumented[mvalue] = 0
				end)
			end
		end

		xpcall(function() dofile(package_path..s.."data.lua") end, function(err)
			printError("Could not load 'data.lua'")
			printError(err)
			os.exit()
		end)

		printNote("Checking folder 'data'")
		local df = dataFiles(package)

		table.sort(mdata, function(a, b)
			return a.file[1] < b.file[1]
		end)

		forEachOrderedElement(df, function(_, mvalue)
			if attributes(package_path..s.."data"..s..mvalue, "mode") == "directory" then
				return
			end

			if filesdocumented[mvalue] == nil then
				printError("File '"..mvalue.."' is not documented")
				doc_report.undoc_data = doc_report.undoc_data + 1
			else
				filesdocumented[mvalue] = filesdocumented[mvalue] + 1
			end
		end)

		forEachOrderedElement(filesdocumented, function(midx, mvalue)
			if mvalue == 0 then
				printError("File '"..midx.."' is documented but does not exist in folder 'data'")
				doc_report.wrong_data = doc_report.wrong_data + 1
			end
		end)
	else
		local df = dataFiles(package)
		if #df > 0 then
			printNote("Checking folder 'data'")
			printError("Package has data files but data.lua does not exist")
			forEachElement(df, function(_, mvalue)
				printError("File '"..mvalue.."' is not documented")
				doc_report.undoc_data = doc_report.undoc_data + 1
			end)
		end
	end

	local result = luadocMain(package_path, lua_files, example_files, package, mdata, doc_report)

	local all_functions = _Gtme.buildCountTable(package)

	local all_doc_functions = {}

	forEachElement(result.files, function(idx, value)
		if type(idx) ~= "string" then return end
		if not string.endswith(idx, ".lua") then return end

		all_doc_functions[idx] = {}
		forEachElement(value.functions, function(midx)
			if type(midx) ~= "string" then return end
			all_doc_functions[idx][midx] = 0
		end)
	end)

	printNote("Checking if all functions are documented")
	forEachOrderedElement(all_functions, function(idx, value)
		print("Checking "..idx)
		forEachOrderedElement(value, function(midx, mvalue)
			if midx == "__len" or midx == "__tostring" then return end -- TODO: think about this kind of function

			if not result.files[idx] then
				printWarning("File does not have any documentation")
			elseif not result.files[idx].functions[midx] and 
			  (not result.files[idx].models or not result.files[idx].models[midx]) then
				printError("Function "..midx.." is not documented")
				doc_report.undoc_functions = doc_report.undoc_functions + 1
			end
		end)
	end)

	local finalTime = os.clock()

	print("\nDocumentation report:")
	printNote("Documentation was built in "..round(finalTime - initialTime, 2).." seconds.")

	if doc_report.undoc_files == 0 then
		printNote(doc_report.html_files.." HTML files were created.")
	else
		printError(doc_report.undoc_files.." out of "..doc_report.lua_files.." files are not documented.")
	end

	if doc_report.wrong_description == 1 then
		printError("One problem was found in 'description.lua'.")
	elseif doc_report.wrong_description > 1 then
		printError(doc_report.wrong_description.." problems were found in 'description.lua'.")
	else
		printNote("All fields of 'description.lua' are correct.")
	end

	if doc_report.undoc_data == 1 then
		printError("One data file is not documented.")
	elseif doc_report.undoc_data > 1 then
		printError(doc_report.undoc_data.." data files are not documented.")
	else
		printNote("No undocumented data files were found.")
	end

	if doc_report.wrong_data == 1 then
		printError("One problem was found in 'data.lua'.")
	elseif doc_report.wrong_data > 1 then
		printError(doc_report.wrong_data.." problems were found in 'data.lua'.")
	else
		printNote("All data files are correctly documented in 'data.lua'.")
	end

	if doc_report.wrong_line == 1 then
		printError("One source code line starting with --- is invalid.")
	elseif doc_report.wrong_line > 1 then
		printError(doc_report.wrong_line.." source code lines starting with --- are invalid.")
	else
		printNote("All source code lines starting with --- are valid.")
	end

	if doc_report.models > 0 then
		if doc_report.model_error == 0 then
			if doc_report.models == 1 then
				printNote("The single Model is correctly documented.")
			else
				printNote("All "..doc_report.models.." Models are correctly documented.")
			end
		elseif doc_report.model_error == 1 then
			printError("One error was found in the documentation of Models.")
		else
			printError(doc_report.model_error.." errors were found in the documentation of Models.")
		end
	else
		printNote("There are no Models in the package.")
	end

	if doc_report.undoc_functions == 1 then
		printError("One global function is not documented.")
	elseif doc_report.undoc_functions > 1 then
		printError(doc_report.undoc_functions.." global functions are not documented.")
	else
		printNote("All "..doc_report.functions.." global functions of the package are documented.")
	end

	if doc_report.duplicated_functions == 1 then
		printError("One function is declared twice in the source code.")
	elseif doc_report.duplicated_functions > 1 then
		printError(doc_report.duplicated_functions.." functions are declared twice in the source code.")
	else
		printNote("All functions of each file are declared only once.")
	end

	if doc_report.wrong_descriptions == 1 then
		printError("One description ends with wrong character.")
	elseif doc_report.wrong_descriptions > 1 then
		printError(doc_report.wrong_descriptions.." descriptions end with wrong characters.")
	else
		printNote("All descriptions end with a correct character.")
	end

	if doc_report.duplicated == 1 then
		printError("One tag is duplicated in the documentation.")
	elseif doc_report.duplicated > 1 then
		printError(doc_report.duplicated.." tags are duplicated in the documentation.")
	else
		printNote("There is no duplicated tag in the documentation.")
	end

	if doc_report.compulsory_arguments == 1 then
		printError("One tag should have a compulsory argument.")
	elseif doc_report.compulsory_arguments > 1 then
		printError(doc_report.compulsory_arguments.." tags should have compulsory arguments.")
	else
		printNote("All tags with compulsory arguments were correctly used.")
	end

	if doc_report.undoc_arg == 1 then
		printError("One non-named argument is not documented.")
	elseif doc_report.undoc_arg > 1 then
		printError(doc_report.undoc_arg.." non-named arguments are not documented.")
	else
		printNote("All "..doc_report.arguments.." non-named arguments are documented.")
	end

	if doc_report.undefined_arg == 1 then
		printError("One undefined argument was found.")
	elseif doc_report.undefined_arg > 1 then
		printError(doc_report.undefined_arg.." undefined arguments were found.")
	else
		printNote("No undefined arguments were found.")
	end

	if doc_report.unused_arg == 1 then
		printError("One documented argument is not used in the HTML tables.")
	elseif doc_report.unused_arg > 1 then
		printError(doc_report.unused_arg.." documented arguments are not used in the HTML tables.")
	else
		printNote("All available arguments of functions are used in their HTML tables.")
	end

	if doc_report.unknown_arg == 1 then
		printError("One argument used in the HTML tables is not documented.")
	elseif doc_report.unknown_arg > 1 then
		printError(doc_report.unknown_arg.." arguments used in the HTML tables are not documented.")
	else
		printNote("All arguments used in the HTML tables are documented.")
	end

	if doc_report.lack_usage == 1 then
		printError("One out of "..doc_report.functions.." functions does not have @usage.")
	elseif doc_report.lack_usage > 1 then
		printError(doc_report.lack_usage.." out of "..doc_report.functions.." functions do not have @usage.")
	else
		printNote("All "..doc_report.functions.." functions have @usage.")
	end

	if doc_report.no_call_itself_usage == 1 then
		printError("One out of "..doc_report.functions.." documented functions does not call itself in its @usage.")
	elseif doc_report.no_call_itself_usage > 1 then
		printError(doc_report.no_call_itself_usage.." out of "..doc_report.functions.." documented functions do not call themselves in their @usage.")
	else
		printNote("All "..doc_report.functions.." functions call themselves in their @usage.")
	end

	if doc_report.wrong_tabular == 1 then
		printError("One problem was found in @tabular.")
	elseif doc_report.wrong_tabular > 1 then
		printError(doc_report.wrong_tabular.." problems were found in @tabular.")
	else
		printNote("All @tabular are correctly described.")
	end

	if doc_report.invalid_tags == 1 then
		printError("One invalid tag was found in the documentation.")
	elseif doc_report.invalid_tags > 1 then
		printError(doc_report.invalid_tags.." invalid tags were found in the documentation.")
	else
		printNote("No invalid tags were found in the documentation.")
	end

	if doc_report.wrong_links == 1 then
		printError("One out of "..doc_report.links.." links is invalid.")
	elseif doc_report.wrong_links > 1 then
		printError(doc_report.wrong_links.." out of "..doc_report.links.." links are invalid.")
	else
		printNote("All "..doc_report.links.." links were correctly built.")
	end

	if doc_report.undoc_examples == 1 then
		printError("One out of "..doc_report.examples.." examples is not documented.")
	elseif doc_report.undoc_examples > 1 then
		printError(doc_report.undoc_examples.." out of "..doc_report.examples.." examples are not documented.")
	else
		printNote("All "..doc_report.examples.." examples are documented.")
	end

	if doc_report.problem_examples == 1 then
		printError("One problem was found in the documentation of examples.")
	elseif doc_report.problem_examples > 1 then
		printError(doc_report.problem_examples.." problems were found in the documentation of examples.")
	else
		printNote("All "..doc_report.examples.." examples are correctly documented.")
	end

	local errors = -doc_report.examples -doc_report.arguments - doc_report.links -doc_report.functions -doc_report.models
	               -doc_report.html_files - doc_report.lua_files

	forEachElement(doc_report, function(_, value)
		errors = errors + value
	end)

	if errors == 0 then
		printNote("Summing up, all the documentation was successfully built.")
	elseif errors == 1 then
		printError("Summing up, one problem was found in the documentation.")
	else
		printError("Summing up, "..errors.." problems were found in the documentation.")
	end
	return errors, all_doc_functions
end

