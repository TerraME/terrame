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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Rodrigo Reis Pereira
--          Antonio Jose da Cunha Rodrigues
--          Raian Vargas Maretto
-------------------------------------------------------------------------------------------

--@header Some basic and useful functions to develop packages.

function switch(data, att)
	if type(data) == "number" then
		local swtbl = {
			casevar = data,
			caseof = function(self, code)
				local f
				if self.casevar then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end

				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						customError("Case "..tostring(self.casevar).." not a function.")
					end
				end
			end
		}
		return swtbl
	else
		local swtbl = {
			casevar = data[att],
			caseof = function(self, code)
				local f
				if self.casevar then
					f = code[self.casevar] or code.default
				else
					f = code.missing or code.default
				end
				if f then
					if type(f) == "function" then
						return f(self.casevar,self)
					else
						customError("Case "..tostring(self.casevar).." should be a function.")
					end
				else
					local distance = string.len(self.casevar)
					local word
					forEachElement(code, function(a)
						local d = levenshtein(a, self.casevar) 
						if d < distance then
							distance = d
							word = a
						end
					end)
					if distance < string.len(self.casevar) * 0.6 then
						word = "Do you mean '"..word.."'?"
					else
						word = "It must be a string from the set ["
						forEachOrderedElement(code, function(a)
							word = word.."'"..a.."', "
						end)
						word = string.sub(word, 0, string.len(word) - 2).."]."
					end
					customError("'"..self.casevar.."' is an invalid value for parameter '"..att.."'. "..word)
				end
			end
		}
		return swtbl
	end
end

-- Attribute name suggestion based on levenshtein string distance
function suggest(typedValues, possibleValues)
	local str = ""
	for k, v in pairs(typedValues) do
		local notCorrectParameters = {}
		local correctedSuggestions = {}
		if not belong(k, possibleValues) then
			table.insert(notCorrectParameters,k)
			local moreSimilar = "" 
			local moreSimilarDistance = 1000000
			for j = 1, #possibleValues do
				local distance = levenshtein(k, possibleValues[j])
				if distance <= moreSimilarDistance then
					moreSimilarDistance = distance
					moreSimilar = possibleValues[j]
				end
			end
			table.insert(correctedSuggestions, moreSimilar)
		end

		for i = 1, getn(notCorrectParameters) do
 			local dst = levenshtein(notCorrectParameters[i], correctedSuggestions[i])
 			if dst < math.floor(#notCorrectParameters[i] * 0.6) then
 				customWarning("Attribute '".. notCorrectParameters[i] .."' not found. Do you mean '".. correctedSuggestions[i].."'?", 4)
 			end
		end
	end
end

--- Verify a given condition, otherwise stops the simulation with an error.
verify = function(condition, msg)
	if not condition then
		customError(msg)
	end
end

verifyNamedTable = function(data)
	if type(data) ~= "table" then
		if data == nil then
			customError("Parameter must be a table.")
		else
			customError("Parameters must be named.")
		end
	elseif #data > 0 then
		customError("All elements of the argument must be named.")
	end
end

function checkUnnecessaryParameters(data, parameters)
	forEachElement(data, function(value)
		if not belong(value, parameters) then
			customWarning("Parameter '"..value.."' is unnecessary.")
		end
	end)
end

function customError(msg)
	if type(msg) ~= "string" then
		error("Error: #1 should be a string.", 2)
	end

	local level = getLevel()
	error("Error: "..msg, level)
end

-- TODO: move this from here
local begin_yellow = "\027[00;33m"
local end_color    = "\027[00m"

local function print_yellow(value)
    if sessionInfo().separator == "/" then
        print__(begin_yellow..value..end_color)
    else
        print__(value)
    end
end

function customWarning(msg)
	if type(msg) ~= "string" then
		error("Error: #1 should be a string.", 2)
	elseif sessionInfo().mode == "normal" then
		local level = getLevel()
		local info = debug.getinfo(level)
		local str = string.match(info.short_src, "[^/]*$")
		print_yellow(str..":".. info.currentline ..": Warning: "..msg)
	elseif sessionInfo().mode == "debug" then
		customError(msg)
	end
	io.flush()
end

defaultTableValue = function(data, idx, value)
	if data[idx] == nil then
		data[idx] = value
	elseif type(data[idx]) ~= type(value) then
		incompatibleTypeError(idx, type(value), data[idx])
	elseif data[idx] == value then
		defaultValueWarning(idx, value)
	end
end

function defaultValueWarning(parameter, value)
	if type(parameter) ~= "string" then
		error("Error: #1 should be a string.", 2)
	end

	customWarning("Parameter '"..parameter.."' could be removed as it is the default value ("..tostring(value)..").")
end

--- Generates
function deprecatedFunctionWarning(functionName, functionExpected)
	if type(functionName) ~= "string" then
		error("Error: #1 should be a string.", 2)
	end

	if type(functionExpected) ~= "string" then
		error("Error: #2 should be a string.", 2)
	end

	local text = "Function '"..functionName.."' is deprecated. Use '"..functionExpected.."' instead."
	customWarning(text)
end

function incompatibleTypeError(attr, expectedTypesString, gottenValue)
	if expectedTypesString == nil then expectedTypesString = "nil" end

	local text = "Incompatible types. Parameter '"..attr.."' expected "..
		expectedTypesString..", got "..type(gottenValue).."."

	customError(text)
end

function incompatibleValueError(attr, expectedValues, gottenValue)
	if expectedValues == nil then expectedValues = "nil" end

	local msg = "Incompatible values. Parameter '"..attr.."' expected ".. expectedValues ..", got "
	if type(gottenValue) == "string" then
		msg = msg.."'"..gottenValue.."'."
	elseif gottenValue == nil then
		msg = msg.."nil."
	else
		msg = msg..gottenValue.."."
	end
	customError(msg)
end

function incompatibleFileExtensionError(attr, ext)
	customError("Parameter '".. attr .."' does not support '"..ext.."'.")
end

function resourceNotFoundError(attr, path)
	customError("Resource '"..path.."' not found for parameter '"..attr.."'.")
end

function valueNotFoundError(attr, value)
	if type(value) == nil then value = "nil" end
	customError("Value '"..value.."' not found for parameter '"..attr.."'.")
end

function mandatoryArgumentError(attr)
	customError("Parameter '"..attr.."' is mandatory.")
end

-- TODO: verify the name of this function
function mandatoryTableArgument(table, attr, mtype)
	if table[attr] == nil then
		customError("Parameter '"..attr.."' is mandatory.")
	elseif type(table[attr]) ~= mtype then
		incompatibleTypeError(attr, mtype, table[attr])
	end
end

optionalTableArgument = function(table, attr, allowedType)
	local value = table[attr]
	local mtype = type(value)

	if value ~= nil and mtype ~= allowedType then
		incompatibleTypeError(attr, allowedType, value)
	end
end

