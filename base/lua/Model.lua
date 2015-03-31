--#########################################################################################
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
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--#########################################################################################

--- Function to define a mandatory argument for a given Model. This function
-- can be used stand alone without having to instantiate a Model.
-- @arg value A string with the type of the argument. It cannot be boolean, string, nor userdata.
-- If it is table, then all its elements should have the same type.
-- @usage mandatory("number")
function mandatory(value)
	local result = {}

	mandatoryArgument(1, "string", value)

	if belong(value, {"boolean", "string", "userdata"}) then
		customError("Value '"..value.."' cannot be a mandatory argument.")
	end
	result.value = value

	setmetatable(result, {__index = {type_ = "mandatory"}})
	return result
end

Model_ = {
	--- Check whether the instance of the model has correct arguments. This function is optional
	-- and it is called before creating internal objects.
	-- @usage model:check()
	check = function(self)
	end,
	--- Creates the objects of the model. This function must be implemented by the derived type.
	-- @usage model:init()
	init = function(self)
	end,
	--- Run the model. It requires that the model has attribute finalTime.
	-- @usage model:execute()
	execute = function(self)
		forEachElement(self, function(name, value, mtype)
			if belong(mtype, {"Timer", "Environment"}) then
				value:execute(self.finalTime)
				return false
			end
		end)
	end,
	--- Defines the distribution of components in the graphical interface. If this function is not
	-- implemented in the Model, the components will be distributed automatically. This function
	-- should return a table with tables composed by strings. Each position of the table describes
	-- a column of components in the interface. Note that if this function returns a table, the
	-- elements that do not belong to the table will not be shown in the graphical interface.
	-- @usage model:interface()
	interface = function(self)
	end
}

--- Type that defines a model. Its constructor returns a constructor for the new type.
-- The idea is to take only strings, numbers, booleans, and vectors of these three types as the
-- only possible arguments to any Model. Functions can be mapped to the strings and then be
-- solved internally. 
-- @arg attrTab A table with the description of the type. Each named argument of this table
-- will be considered as an argument of the constructor of the type. The values of each
-- named argument have an associated semantinc, which means that they are not necessarially the
-- default value. [Note that some of these features were not implemented yet.] See the table below:
-- @tabular attrTab
-- Attribute type & Description & Default value \
-- number or bool & The instance has to belong to that type. & The value itself. \
-- string & The instance has to belong to that type. If it is in the format "*.a;*.b;...", it 
-- describes a file extension. The modeler then has to use a filename as argument with one of the
-- extensions defined by this string. & The value itself. \
-- table & The instance has to have a value belonging to the table (the table must have a single
-- type). & The first position of the table.\ 
-- named table & It will verify each attribute according to the rules above. & The table itself.
-- It is possible to define only part of the table in the instance, keeping the other default values. \
-- empty table & It will verify whether the instance has a non-empty table as argument. It does not
-- check any table values. The only requirement is that all them must have the same type. & None (the
-- argument is mandatory).
-- @usage mymodel = Model{
--     par1 = 3,
--     par2 = {"low", "medium", "high"},
--     par3 = {min = 3, max = 5},
--     ...
-- }
--
-- scenario1 = mymodel() -- par1 = 3, par2 = "low", par3.min = 3, par3.max = 5
--
-- scenario2 = mymodel{par2 = "medium", par3 = {max = 6}} -- par1 = 3, par3.min = 3
--
-- scenario3 = mymodel{par2 = "equal"} -- error: there is no such option in par2
--
-- scenario4 = mymodel{par3 = {average = 2}} -- error: there is no such name in par3
function Model(attrTab)
	if type(attrTab.interface) == "function" then
		local minterface = attrTab.interface()
		local elements = {}

		if type(minterface) ~= "table" then
			customError("The returning value of interface() should be a table, got "..type(minterface)..".")
		end

		forEachElement(minterface, function(_, value, mtype)
			if mtype ~= "table" then
				customError("There is an element in the interface() that is not a table.")
			end

			forEachElement(value, function(_, mvalue, mmtype)
				if mmtype ~= "string" then
					customError("All the elements in each interface() vector should be string, got "..mmtype..".")
				end

				if elements[mvalue] then
					customError("Argument '"..mvalue.."' cannot be displayed twice in the interface().")
				else
					elements[mvalue] = true
				end

				if belong(mvalue, {"string", "number", "boolean", "Choice", "mandatory"}) then
					local found = false
					forEachElement(attrTab, function(_, _, attrtype)
						if attrtype == mvalue then
							found = true
							return false
						end
					end)

					if not found then
						customWarning("There is no argument '"..mvalue.."' in the Model, although it is described in the interface().")
					end
				else -- named table
					if attrTab[mvalue] == nil then
						customError("interface() element '"..mvalue.."' is not an argument of the Model.")
					elseif type(attrTab[mvalue]) ~= "table" then
						customError("interface() element '"..mvalue.."' is not a table in the Model.")
					elseif #attrTab[mvalue] > 0 then
						customError("interface() element '"..mvalue.."' is a non-named table in the Model.")
					elseif getn(attrTab[mvalue]) == 0 then
						customError("interface() element '"..mvalue.."' is empty in the Model.")
					end
				end
			end)
		end)
	end

	if attrTab.finalTime ~= nil then
		local t = type(attrTab.finalTime)
		if t == "Choice" then
			if type(attrTab.finalTime.default) ~= "number" then
				customError("finalTime can only be a Choice with 'number' values, got '"..type(attrTab.finalTime.default).."'.")
			end
		elseif t == "mandatory" then
			if attrTab.finalTime.value ~= "number" then
				customError("finalTime can only be mandatory('number'), got mandatory('"..attrTab.finalTime.value.."').")
			end
		else
			optionalTableArgument(attrTab, "finalTime", "number")
		end
	end

	if attrTab.seed ~= nil then
		local t = type(attrTab.seed)
		if t == "Choice" then
			if type(attrTab.seed.default) ~= "number" then
				customError("seed can only be a Choice with 'number' values, got '"..type(attrTab.seed.default).."'.")
			end
		elseif t == "mandatory" then
			if attrTab.seed.value ~= "number" then
				customError("seed can only be mandatory('number'), got mandatory('"..attrTab.seed.value.."').")
			end
		else
			optionalTableArgument(attrTab, "seed", "number")
			verify(attrTab.seed >= 0, "Argument 'seed' should be positive, got "..attrTab.seed..".")
		end
	end

	forEachElement(attrTab, function(name, value, mtype)
		if mtype == "table" and #value == 0 then
			forEachElement(value, function(iname, ivalue, itype)
				if not belong(itype, {"Choice", "mandatory", "number", "string", "function", "boolean"}) then
					customError("Type "..itype.." (parameter '"..name.."."..iname.."') is not supported as argument of Model.")
				end
			end)
		elseif mtype == "table" and #value > 0 then
			customError("It is not possible to use a non-named table in a Model (parameter '"..name.."').")
		elseif not belong(mtype, {"Choice", "mandatory", "number", "string", "function", "boolean"}) then
			customError("Type "..mtype.." (parameter '"..name.."') is not supported as argument of Model.")
		end
	end)

	mandatoryTableArgument(attrTab, "init", "function")
	optionalTableArgument(attrTab, "check", "function")

	local function model(argv, typename)
		-- set the default values
		optionalTableArgument(argv, "seed", "number")
		optionalTableArgument(argv, "finalTime", "number")

		if #argv > 0 then
			customError("All the arguments must be named.")
		end

		forEachElement(attrTab, function(name, value, mtype)
			if mtype == "Choice" then
				if argv[name] == nil then
					argv[name] = value.default
				end
			elseif mtype == "mandatory" then
				if argv[name] == nil then
					mandatoryArgumentError(name)
				end
			elseif mtype == "table" and #value == 0 then
				if argv[name] == nil then
					argv[name] = {}
				end

				local iargv = argv[name]
				forEachElement(value, function(iname, ivalue, itype)
					if itype == "Choice" and iargv[iname] == nil then
						iargv[iname] = ivalue.default
					elseif itype == "mandatory" and iargv[iname] == nil then
						mandatoryArgumentError(name.."."..iname)
					elseif iargv[iname] == nil then
						iargv[iname] = ivalue
					end
				end)
			elseif argv[name] == nil then
				argv[name] = value
			end
		end)

		-- check types and values
		forEachElement(attrTab, function(name, value, mtype)
			if mtype == "Choice" then
				if value.values then
					if type(argv[name]) ~= type(value.default) then
						incompatibleTypeError(name, type(value.default), argv[name])
					elseif not belong(argv[name], value.values) then
						local str = "one of {"
						forEachElement(value.values, function(_, v)
							str = str..v..", "
						end)
						str = string.sub(str, 1, str:len() - 2).."}"
						incompatibleValueError(name, str, argv[name])
					end
				else
					if type(argv[name]) ~= "number" then
						incompatibleTypeError(name, "number", argv[name])
					elseif argv[name] < value.min then
						customError("Argument '"..name.."' should be greater than or equal to "..value.min..".")
					elseif value.max and argv[name] > value.max then
						customError("Argument '"..name.."' should be less than or equal to "..value.max..".")
					elseif value.step and (((argv[name] - value.min)) * 1000) % (value.step * 1000) > 0.000001 then
						-- There is a small bug in Lua with operator % using numbers between 0 and 1
						-- For example, 0.7 % 0.1 == 0.1, but should be 0.0. That's why we need
						-- to multiplicate by 1000 above
						customError("Invalid value for argument '"..name.."' ("..argv[name]..").")
					end
				end
			elseif mtype == "mandatory" then
				if type(argv[name]) ~= value.value then
					incompatibleTypeError(name, value.value, argv[name])
				end
			elseif mtype == "table" and #value == 0 then
				local iargv = argv[name]
				forEachElement(value, function(iname, ivalue, itype)
					if itype == "Choice" then
						if ivalue.values then
							if type(iargv[iname]) ~= type(ivalue.default) then
								incompatibleTypeError(name.."."..iname, type(ivalue.default), iargv[iname])
							elseif not belong(iargv[iname], ivalue.values) then
								local str = "one of {"
								forEachElement(ivalue.values, function(_, v)
									str = str..v..", "
								end)
								str = string.sub(str, 1, str:len() - 2).."}"
								incompatibleValueError(name.."."..iname, str, iargv[iname])
							end
						else
							if type(iargv[iname]) ~= "number" then
								incompatibleTypeError(name.."."..iname, "number", iargv[iname])
							elseif iargv[iname] < ivalue.min then
								customError("Argument '"..name.."."..iname.."' should be greater than or equal to "..ivalue.min..".")
							elseif ivalue.max and iargv[iname] > ivalue.max then
								customError("Argument '"..name.."."..iname.."' should be less than or equal to "..ivalue.max..".")
							elseif ivalue.step and (iargv[iname] - ivalue.min) % ivalue.step > 0.000001 then
								customError("Invalid value for argument '"..name.."."..iname.."' ("..iargv[iname]..").")
							end
						end
					elseif itype == "mandatory" then
						if type(iargv[iname]) ~= ivalue.value then
							incompatibleTypeError(name.."."..iname, ivalue.value, iargv[iname])
						end
					elseif itype ~= type(iargv[iname]) then
						incompatibleTypeError(name.."."..iname, itype, iargv[iname])
					end
				end)
			elseif type(argv[name]) ~= mtype then
				incompatibleTypeError(name, mtype, argv[name])
			end
		end)

		-- verify whether there are some arguments in the instance that do not belong to the Model
		local names = {}
		forEachElement(attrTab, function(name)
			table.insert(names, name)
		end)
		checkUnnecessaryArguments(argv, names)

		forEachElement(argv, function(name, value, mtype)
			if mtype == "table" then
				local attrTabValue = attrTab[name]
				forEachElement(value, function(mname, mvalue, mtype)
					if attrTabValue[mname] == nil then
						
						local msg = "Argument '"..name.."."..mname.."' is unnecessary."
	
						local s = suggestion(mname, attrTabValue)
						if s then
							msg = msg.." Do you mean '"..name.."."..s.."'?"
						end

						customWarning(msg)
					end
				end)
			end
		end)

		argv.execute = attrTab.execute
		argv.type_ = typename
		attrTab.check(argv)

		attrTab.init(argv)

		if argv.seed ~= nil then
			verify(argv.seed >= 0, "Argument 'seed' should be positive, got "..argv.seed..".")
			Random{seed = argv.seed}
		end

		mandatoryTableArgument(argv, "finalTime", "number")

		-- check whether the model instance has a timer or an Environment with at least one Timer
		local text = ""
		local exec
		forEachOrderedElement(argv, function(name, value, mtype)
			if mtype == "Timer" then
				if text == "" then
					text = "'"..name.."' (Timer)"
					exec = value
				else
					customError("The object has two running objects: '"..name.."' (Timer) and "..text..".")
				end
			elseif mtype == "Environment" then
				forEachElement(value, function(mname, mvalue, mmtype)
					if mmtype == "Timer" then
						if text == "" then
							text = "'"..name.."' (Environment)"
							exec = value
							return false
						else
							customError("The object has two running objects: '"..name.."' (Environment) and "..text..".")
						end
					end
				end)
			end
		end)

		verify(exec, "The object does not have a Timer or an Environment with at least one Timer.")

		return argv
	end

	setmetatable(attrTab, {__index = Model_})

	local mmodel = {type_ = "Model"}
	setmetatable(mmodel, {__call = function(_, v)
		if v == nil then return attrTab end
 		return model(v, debug.getinfo(1).name)
	end})

	return mmodel
end

