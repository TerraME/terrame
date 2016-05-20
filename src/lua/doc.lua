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
local printWarning = _Gtme.printWarning
local printNote    = _Gtme.printNote

_Gtme.ignoredFile = function(fname)
	local ignoredExtensions = {
		".dbf",
		".prj",
		".shx",
		".sbn",
		".sbx",
		".fbn",
		".fbx",
		".ain",
		".aih",
		".ixs",
		".mxs",
		".atx",
		".shp.xml",
		".cpg",
		".qix"
	}

	local ignore = false
	forEachElement(ignoredExtensions, function(_, ext)
		if string.endswith(fname, ext) then
			ignore = true
		end
	end)

	return ignore
end

local function imageFiles(package)
	local s = sessionInfo().separator
	local imagepath = packageInfo(package).path..s.."images"

	if not isDir(imagepath) then
		return {}
	end

	local files = dir(imagepath)
	local result = {}

	forEachElement(files, function(_, fname)
		if not string.endswith(fname, ".lua") then
			result[fname] = 0
		end
	end)
	return result
end

local function dataFiles(package)
	local s = sessionInfo().separator
	local datapath = packageInfo(package).data

	if not isDir(datapath) then
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

	if not isLoaded("luadoc") then
		import("luadoc")
	end

	if not isLoaded("base") then
		import("base")
	end

	printNote("Building documentation for package '"..package.."'")
	local s = sessionInfo().separator
	local package_path = _Gtme.packageInfo(package).path

	printNote("Loading package '"..package.."'")

	local pkg

	xpcall(function() pkg = _G.getPackage(package) end, function(err)
		printError("Package '"..package.."' could not be loaded.")
		printError(err)
		printError(_Gtme.traceback())
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
		usage_error = 0,
		wrong_links = 0,
		invalid_tags = 0,
		problem_examples = 0,
		duplicated = 0,
		compulsory_arguments = 0,
		undoc_functions = 0,
		error_data = 0,
		error_font = 0,
		wrong_line = 0,
		wrong_tabular = 0,
		wrong_image = 0,
		wrong_descriptions = 0
	}

	local mdata = {}
	local filesdocumented = {}
	local df = dataFiles(package)

	if isFile(package_path..s.."data.lua") and #df > 0 then
		printNote("Parsing 'data.lua'")
		data = function(tab)
			local count = verifyUnnecessaryArguments(tab, {"file", "image", "summary", "source", "attributes", "types", "description", "reference"})
			doc_report.error_data = doc_report.error_data + count

			if type(tab.file)        == "string" then tab.file = {tab.file} end
			if type(tab.attributes)  == "string" then tab.attributes = {tab.attributes} end
			if type(tab.types)       == "string" then tab.types = {tab.types} end
			if type(tab.description) == "string" then tab.description = {tab.description} end

			local mverify = {
				{"mandatoryTableArgument", "file",        "table"},
				{"mandatoryTableArgument", "summary",     "string"},
				{"mandatoryTableArgument", "source",      "string"},
				{"optionalTableArgument",  "file",        "table"},
				{"optionalTableArgument",  "image",       "string"},
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
					doc_report.error_data = doc_report.error_data + 1
					tab.attributes = {"_incompatible_"}
					printError(err)
				end)

			end

			-- it is necessary to implement this way in order to get the line number of the error
			for i = 1, #mverify do
				local func = "return function(tab) "..mverify[i][1].."(tab, \""..mverify[i][2].."\", \""..mverify[i][3].."\") end"

				xpcall(function() load(func)()(tab) end, function(err)
					doc_report.error_data = doc_report.error_data + 1
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
						doc_report.error_data = doc_report.error_data + 1
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

		printNote("Checking directory 'data'")

		table.sort(mdata, function(a, b)
			return a.file[1] < b.file[1]
		end)

		forEachOrderedElement(df, function(_, mvalue)	
			if _Gtme.ignoredFile(mvalue) then
				if filesdocumented[mvalue] == nil then
					filesdocumented[mvalue] = 1
				else
					printError("File '"..mvalue.."' should not be documented")
					doc_report.error_data = doc_report.error_data + 1
				end
			end
		end)

		forEachOrderedElement(df, function(_, mvalue)
			if isDir(package_path..s.."data"..s..mvalue) then
				return
			end

			if filesdocumented[mvalue] == nil then
				printError("File '"..mvalue.."' is not documented")
				doc_report.error_data = doc_report.error_data + 1
			else
				filesdocumented[mvalue] = filesdocumented[mvalue] + 1
			end
		end)

		forEachOrderedElement(filesdocumented, function(midx, mvalue)
			if mvalue == 0 then
				printError("File '"..midx.."' is documented but does not exist in directory 'data'")
				doc_report.error_data = doc_report.error_data + 1
			end
		end)
	elseif #df > 0 then
		printNote("Checking directory 'data'")
		printError("Package has data files but data.lua does not exist")
		forEachElement(df, function(_, mvalue)
			if isDir(package_path..s.."data"..s..mvalue) then
				return
			end

			printError("File '"..mvalue.."' is not documented")
			doc_report.error_data = doc_report.error_data + 1
		end)
	elseif isFile(package_path..s.."data.lua") then
		printError("Package '"..package.."' has data.lua but there is no data")
		doc_report.error_data = doc_report.error_data + 1
	else
		printNote("Package '"..package.."' has no data")
	end

	local mfont = {}
	local fontsdocumented = {}
	local df = _Gtme.fontFiles(package)

	if isFile(package_path..s.."font.lua") and #df > 0 then
		printNote("Parsing 'font.lua'")
		font = function(tab)
			local count = verifyUnnecessaryArguments(tab, {"name", "file", "summary", "source", "symbol"})
			doc_report.error_font = doc_report.error_font + count

			local mverify = {
				{"optionalTableArgument",  "name",    "string"},
				{"mandatoryTableArgument", "file",    "string"},
				{"mandatoryTableArgument", "source",  "string"},
				{"mandatoryTableArgument", "summary", "string"},
				{"mandatoryTableArgument", "symbol",  "table"},
			}

			-- it is necessary to implement this way in order to get the line number of the error
			for i = 1, #mverify do
				local func = "return function(tab) "..mverify[i][1].."(tab, \""..mverify[i][2].."\", \""..mverify[i][3].."\") end"

				xpcall(function() load(func)()(tab) end, function(err)
					doc_report.error_font = doc_report.error_font + 1
					tab.file = nil
					printError(err)
				end)
			end

			if tab.summary then
				tab.shortsummary = string.match(tab.summary, "(.-%.)")
			end

			if type(tab.symbol) ~= "table" then tab.symbol = {} end

			forEachElement(tab.symbol, function(idx, value, mtype)
				if type(idx) ~= "string" then
					printError("Font '"..tostring(tab.name).."' has a non-string symbol.")
					doc_report.error_font = doc_report.error_font + 1
					tab.file = nil
				elseif mtype ~= "number" then
					printError("Symbol '"..idx.."' has a non-numeric value.")
					tab.file = nil
					doc_report.error_font = doc_report.error_font + 1
				end
			end)

			if type(tab.file) == "string" then
				table.insert(mfont, tab)

				if fontsdocumented[tab.file] then
					printError("Font file '"..tab.file.."' is documented more than once.")
					doc_report.error_font = doc_report.error_font + 1
				end
				fontsdocumented[tab.file] = 0
			end
		end

		xpcall(function() dofile(package_path..s.."font.lua") end, function(err)
			printError("Could not load 'font.lua'")
			printError(err)
			os.exit()
		end)

		table.sort(mfont, function(a, b)
			return a.file < b.file
		end)

		printNote("Checking directory 'font'")
		forEachOrderedElement(df, function(_, mvalue)
			if isDir(package_path..s.."font"..s..mvalue) then
				return
			end

			if fontsdocumented[mvalue] == nil then
				printError("Font file '"..mvalue.."' is not documented")
				doc_report.error_font = doc_report.error_font + 1
			else
				fontsdocumented[mvalue] = fontsdocumented[mvalue] + 1
			end
		end)

		forEachOrderedElement(fontsdocumented, function(midx, mvalue)
			if mvalue == 0 then
				printError("Font file '"..midx.."' is documented but does not exist in directory 'font'")
				doc_report.error_font = doc_report.error_font + 1
			end
		end)

		printNote("Checking licenses of fonts")

		forEachElement(df, function(_, mvalue)
			local license = string.sub(mvalue, 0, -5)..".txt"

			if not isFile(package_path..s.."font"..s..license) then
				printError("License file '"..license.."' for font '"..mvalue.."' does not exist")
				doc_report.error_font = doc_report.error_font + 1
			end
		end)
	elseif #df > 0 then
		printNote("Checking directory 'font'")
		printError("Package has font files but font.lua does not exist")
		forEachElement(df, function(_, mvalue)
			printError("File '"..mvalue.."' is not documented")
			doc_report.error_font = doc_report.error_font + 1
		end)
	elseif isFile(package_path..s.."font.lua") then
		printError("Package '"..package.."' has font.lua but there are no fonts")
		doc_report.error_font = doc_report.error_font + 1
	else
		printNote("Package '"..package.."' has no fonts")
	end

	local result = luadocMain(package_path, lua_files, example_files, package, mdata, mfont, doc_report)

	if isDir(package_path..s.."font") then
		local cmd = "cp "..package_path..s.."font"..s.."* "..package_path..s.."doc"..s.."files"
		cmd = _Gtme.makePathCompatibleToAllOS(cmd)
		os.execute(cmd)
	end

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

	printNote("Checking images")
	local images = imageFiles(package)

	print("Checking data.lua")
	forEachOrderedElement(mdata, function(_, data)
		if data.image then
			if not images[data.image] then
				printError("Image file '"..data.image.."' does not exist in directory 'images'")
				doc_report.wrong_image = doc_report.wrong_image + 1
			else
				images[data.image] = images[data.image] + 1
			end
		end
	end)

	print("Checking models")

	forEachOrderedElement(result.files, function(idx, value)
		if type(idx) ~= "string" then return end
		if not string.endswith(idx, ".lua") then return end

		forEachElement(value.models, function(midx, value, mtype)
			if mtype == "table" and value.image then
				if not images[value.image] then
					printError("Image file '"..value.image.."' does not exist in directory 'images'")
					doc_report.wrong_image = doc_report.wrong_image + 1
				else
					images[value.image] = images[value.image] + 1
				end
			end
		end)
	end)

	print("Checking examples")

	forEachOrderedElement(result.files, function(idx, value)
		if type(idx) ~= "string" then return end
		if not string.endswith(idx, ".lua") then return end

		if value.image then
			if not images[value.image] then
				printError("Image file '"..value.image.."' does not exist in directory 'images'")
				doc_report.wrong_image = doc_report.wrong_image + 1
			else
				images[value.image] = images[value.image] + 1
			end
		end	
	end)


	print("Checking if all images are used")
	forEachOrderedElement(images, function(file, value)
		if value == 0 then
			printError("Image file '"..file.."' in directory 'images' is unnecessary")
			doc_report.wrong_image = doc_report.wrong_image + 1
		end
	end)

	printNote("Checking if all functions are documented")
	forEachOrderedElement(all_functions, function(idx, value)
		print("Checking "..idx)
		forEachOrderedElement(value, function(midx, mvalue)
			if midx == "__len" or midx == "__tostring" then return end -- TODO: think about this kind of function

			if not result.files[idx] or not result.files[idx].functions[midx] and 
			  (not result.files[idx].models or not result.files[idx].models[midx]) then
				printError("Function "..midx.." is not documented")
				doc_report.undoc_functions = doc_report.undoc_functions + 1
			end
		end)
	end)

	printNote("Checking if all Models are documented")
	forEachOrderedElement(result.files, function(idx, value)
		if type(idx) ~= "string" then return end
		if not string.endswith(idx, ".lua") then return end

		local documentedArguments = {}

		forEachOrderedElement(value.models, function(midx, value, mtype)
			if mtype == "table" then
				if type(value.arg) == "table" then -- if some argument is documented
					forEachOrderedElement(value.arg, function(mmidx, mvalue, mmtype)
						if type(mmidx) == "string" then
							documentedArguments[mmidx] = true
						end
					end)
				end
			end
		end)

		local modelName = string.sub(idx, 0, -5)
		if value.models and type(pkg[modelName]) == "Model" then
			local args = pkg[modelName]:getParameters()

			forEachOrderedElement(args, function(idx, _, mtype)
				if not documentedArguments[idx] then
					printError("Model '"..modelName.."' has undocumented argument '"..idx.."'")
					doc_report.model_error = doc_report.model_error + 1
				end
			end)

		end
	end)

	local finalTime = os.clock()

	print("\nDocumentation report for package '"..package.."':")
	printNote("Documentation was built in "..round(finalTime - initialTime, 2).." seconds.")

	if doc_report.html_files == 1 then
		printNote("One HTML file was created.")
	else
		printNote(doc_report.html_files.." HTML files were created.")
	end

	if doc_report.undoc_files == 1 then
		printError("One out of "..doc_report.lua_files.." files are not documented.")
	elseif doc_report.undoc_files > 1 then
		printError(doc_report.undoc_files.." out of "..doc_report.lua_files.." files are not documented.")
	else
		printNote("All files are documented.")
	end

	if doc_report.wrong_description == 1 then
		printError("One problem was found in 'description.lua'.")
	elseif doc_report.wrong_description > 1 then
		printError(doc_report.wrong_description.." problems were found in 'description.lua'.")
	else
		printNote("All fields of 'description.lua' are correct.")
	end

	if doc_report.error_data == 1 then
		printError("One problem was found in the documentation of data.")
	elseif doc_report.error_data > 1 then
		printError(doc_report.error_data.." problems were found in the documentation of data.")
	else
		printNote("No problems were found in the documentation of data.")
	end

	if doc_report.error_font == 1 then
		printError("One problem was found in the documentation of fonts.")
	elseif doc_report.error_font > 1 then
		printError(doc_report.error_font.." problems were found in the documentation of fonts.")
	else
		printNote("No problems were found in the documentation of fonts.")
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
		printError("One non-deprecated function does not have @usage.")
	elseif doc_report.lack_usage > 1 then
		printError(doc_report.lack_usage.." non-deprecated functions do not have @usage.")
	else
		printNote("All non-deprecated functions have @usage.")
	end

	if doc_report.no_call_itself_usage == 1 then
		printError("One out of "..doc_report.functions.." documented functions does not call itself in its @usage.")
	elseif doc_report.no_call_itself_usage > 1 then
		printError(doc_report.no_call_itself_usage.." out of "..doc_report.functions.." documented functions do not call themselves in their @usage.")
	else
		printNote("All "..doc_report.functions.." functions call themselves in their @usage.")
	end

	if doc_report.usage_error == 1 then
		printError("One out of "..doc_report.functions.." functions has error in its @usage.")
	elseif doc_report.usage_error > 1 then
		printError(doc_report.usage_error.." out of "..doc_report.functions.." functions have error in their @usage.")
	else
		printNote("All "..doc_report.functions.." functions do not have any error in their @usage.")
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

	if doc_report.wrong_image == 1 then
		printError("One problem with image files was found.")
	elseif doc_report.wrong_image > 1 then
		printError(doc_report.wrong_image.." problems with image files were found.")
	else
		printNote("All images are correctly used.")
	end

	if doc_report.wrong_links == 1 then
		printError("One out of "..doc_report.links.." links is invalid.")
	elseif doc_report.wrong_links > 1 then
		printError(doc_report.wrong_links.." out of "..doc_report.links.." links are invalid.")
	else
		printNote("All "..doc_report.links.." links were correctly built.")
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

