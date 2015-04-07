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

local function dataFiles(package)
	local s = sessionInfo().separator
	local datapath = sessionInfo().path..s.."packages"..s..package..s.."data"

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

function executeDoc(package)
	local initialTime = os.clock()

	require("luadoc")
	require("base")

	printNote("Building documentation for package '"..package.."'")
	local s = sessionInfo().separator
	local package_path = sessionInfo().path..s.."packages"..s..package

	printNote("Loading package")
	xpcall(function() require(package) end, function(err)
		printError("Package "..package.." could not be loaded.")
		printError(err)
		os.exit()
	end)

	local lua_files = dir(package_path..s.."lua")

	local example_files = exampleFiles(package)

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
		wrong_descriptions = 0
	}

	local mdata = {}
	local filesdocumented = {}

	if isFile(package_path..s.."data.lua") then
		printNote("Parsing 'data.lua'")
		data = function(tab)
			local count = checkUnnecessaryArguments(tab, {"file", "summary", "source", "attributes", "types", "description", "reference"})
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
					if #tab.attributes ~= #tab.types then
						customError("Different sizes in the documentation: attributes ("..#tab.attributes..") and types ("..#tab.types..").")
					elseif #tab.attributes ~= #tab.description then
						customError("Different sizes in the documentation: attributes ("..#tab.attributes..") and description ("..#tab.description..").")
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

			table.insert(mdata, tab)

			forEachElement(tab.file, function(_, mvalue)
				if filesdocumented[mvalue] then
					printError("Data file '"..mvalue.."' is documented more than once")
					doc_report.wrong_data = doc_report.wrong_data + 1
				end
				filesdocumented[mvalue] = 0
			end)
		end

		xpcall(function() dofile(package_path..s.."data.lua") end, function(err)
			printError("Could not load 'data.lua'")
			printError(err)
			os.exit()
		end)

		printNote("Checking folder 'data'")
		local df = dataFiles(package)

		table.sort(mdata, function(a,b)
			return a.file[1] < b.file[1]
		end)

		forEachElement(df, function(_, mvalue)
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

		forEachElement(filesdocumented, function(midx, mvalue)
			if mvalue == 0 then
				printError("File '"..midx.."' is documented but does not exist in data folder")
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

	local all_functions = buildCountTable(package)

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
		forEachElement(value, function(midx, mvalue)
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

	print("\nReport:")
	printNote("Documentation was built in "..round(finalTime - initialTime, 2).." seconds.")

	if doc_report.undoc_files == 0 then
		printNote(doc_report.html_files.." HTML files were created.")
	else
		printError(doc_report.undoc_files.." out of "..doc_report.lua_files.." files are not documented.")
	end

	if doc_report.wrong_description == 0 then
		printNote("All fields of 'description.lua' are correct.")
	else
		printError(doc_report.wrong_description.." problems were found in 'description.lua'.")
	end

	if doc_report.wrong_data == 0 then
		printNote("All data files are correctly documented in 'data.lua'.")
	else
		printError(doc_report.wrong_data.." problems were found in 'data.lua'.")
	end

	if doc_report.undoc_data == 0 then
		printNote("No undocumented data files were found.")
	else
		printError(doc_report.undoc_data.." data files are not documented.")
	end

	if doc_report.wrong_line == 0 then
		printNote("All source code lines starting with --- are valid.")
	else
		printError(doc_report.wrong_line.." source code lines starting with --- are invalid.")
	end

	if doc_report.models > 0 then
		if doc_report.model_error == 0 then
			printNote("All "..doc_report.models.." Models are correctly documented.")
		else
			printError("There are "..doc_report.model_error.." errors in the documentation of Models.")
		end
	else
		printNote("There are no Models in the package.")
	end

	if doc_report.undoc_functions == 0 then
		printNote("All "..doc_report.functions.." global functions of the package are documented.")
	else
		printError(doc_report.undoc_functions.." global functions are not documented.")
	end

	if doc_report.duplicated_functions == 0 then
		printNote("All functions of each file are declared only once.")
	else
		printError("There are "..doc_report.duplicated_functions.." repeated functions in the source code.")
	end

	if doc_report.wrong_descriptions == 0 then
		printNote("All descriptions end with a correct character.")
	else
		printError("There are "..doc_report.wrong_descriptions.." descriptions ending with wrong characters.")
	end

	if doc_report.duplicated == 0 then
		printNote("All unique tags are not duplicated.")
	else
		printError(doc_report.duplicated.." tags should be unique and are duplicated.")
	end

	if doc_report.compulsory_arguments == 0 then
		printNote("All tags with compulsory arguments were correctly used.")
	else
		printError(doc_report.compulsory_arguments.." tags should use compulsory arguments.")
	end

	if doc_report.undoc_arg == 0 then
		printNote("All "..doc_report.arguments.." non-named arguments are documented.")
	else
		printError(doc_report.undoc_arg.." non-named arguments are not documented.")
	end

	if doc_report.undefined_arg == 0 then
		printNote("No undefined arguments were found.")
	else
		printError(doc_report.undefined_arg.." undefined arguments were found.")
	end

	if doc_report.unused_arg == 0 then
		printNote("All available arguments of functions are used in their HTML tables.")
	else
		printError(doc_report.unused_arg.." documented arguments are not used in the HTML tables.")
	end

	if doc_report.unknown_arg == 0 then
		printNote("All arguments used in the HTML tables are documented.")
	else
		printError(doc_report.unknown_arg.." arguments used in the HTML tables are not documented.")
	end

	if doc_report.lack_usage == 0 then
		printNote("All "..doc_report.functions.." functions have @usage.")
	else
		printError(doc_report.lack_usage.." out of "..doc_report.functions.." functions do not have @usage.")
	end

	if doc_report.no_call_itself_usage == 0 then
		printNote("All "..doc_report.functions.." functions call themselves in their @usage.")
	else
		printError(doc_report.no_call_itself_usage.." out of "..doc_report.functions.." documented functions do not call themselves in their @usage.")
	end

	if doc_report.invalid_tags == 0 then
		printNote("No invalid tags were found.")
	else
		printError(doc_report.invalid_tags.." invalid tags were found.")
	end

	if doc_report.wrong_links == 0 then
		printNote("All "..doc_report.links.." links were correctly built.")
	else
		printError(doc_report.wrong_links.." out of "..doc_report.links.." links are invalid.")
	end

	if doc_report.undoc_examples == 0 then
		printNote("All "..doc_report.examples.." examples are documented.")
	else
		printError(doc_report.undoc_examples.." out of "..doc_report.examples.." examples are not documented.")
	end

	if doc_report.problem_examples == 0 then
		printNote("All "..doc_report.examples.." examples are correctly documented.")
	else
		printError(doc_report.problem_examples.." problems were found in the documentation of examples.")
	end

	local errors = doc_report.undoc_arg + doc_report.unused_arg + doc_report.undoc_files +
				   doc_report.lack_usage + doc_report.no_call_itself_usage +
				   doc_report.undefined_arg + doc_report.wrong_description + 
				   doc_report.wrong_links + doc_report.problem_examples + doc_report.undoc_examples + 
				   doc_report.unknown_arg + doc_report.duplicated

	if errors == 0 then
		printNote("Summing up, all the documentation was successfully built.")
	elseif errors == 1 then
		printError("Summing up, one problem was found in the documentation.")
	else
		printError("Summing up, "..errors.." problems were found in the documentation.")
	end
	return errors, all_doc_functions
end

