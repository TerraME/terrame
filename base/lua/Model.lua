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

Model_ = {
	--- Run the Model instance. It requires that the Model instance has attribute finalTime.
	-- @usage Tube = Model{
	--     initialWater = 200,
	--     flow = 20,
	--     init = function(model)
	--         model.finalTime = 10
	--         model.timer = Timer{
	--             Event{action = function()
	--                 -- ...
	--             end}
	--         }
	--     end
	-- }
	--
	-- m = Tube{initialWater = 100, flow = 10}
	--
	-- m:execute()
	execute = function(self)
		forEachElement(self, function(name, value, mtype)
			if belong(mtype, {"Timer", "Environment"}) then
				value:execute(self.finalTime)
				return false
			end
		end)
	end,
	--- User-defined function to create the objects of the Model. It is recommended that
	-- all the created objects should be placed in the model instance itself, to guarantee
	-- the content of the Model into a single object. It is also possible to verify
	-- whether the model has correct arguments. The internal verification of Model ensures that
    -- the type of the arguments is valid, acording to the definition of the Model.
    -- See ErrorHandling:toLabel(), for using names of arguments
    -- in error messages when building a Model to work with graphical interfaces.
	-- This function is executed automaticall when one instantiates a given Model.
	-- @usage usage Tube = Model{
	--     initialWater = 200,
	--     flow = 20,
	--     init = function(model)
	--         verify(model.flow < model.initialWater, toLabel("flow").." should be less than "..toLabel("initialWater")..".")
	--         model.finalTime = 10
	--         model.timer = Timer{
	--             Event{action = function()
	--                 -- ...
	--             end}
	--         }
	--     end
	-- }
	--
	-- m = Tube{initialWater = 100, flow = 10}
	-- print(m.finalTime) -- 10
	-- @see ErrorHandling:verify
	-- @see ErrorHandling:customError
	init = function(self)
	end,
	--- User-defined function to define the distribution of components in the graphical
	-- interface. If this function is not
	-- implemented in the Model, the components will be distributed automatically. This function
	-- should return a table with tables composed by strings. Each position of the table describes
	-- a column of components in the interface.
	-- In the example below, the first column of the graphical interface will show the string
	-- argument in the top ("mapFile") and the three arguments of "agents" in the bottom of the
	-- first column. The second column will contain the arguments of "block" in the top and the
	-- boolean argument ("showGraphics") in the bottom. The elements that do not belong to the 
	-- table will not be shown in the graphical interface (in the example, "season").
	-- Note that all Compulsory arguments must belong to the graphical interface to allow
	-- instantiate Model instances properly.
	-- @usage Sugarscape = Model{
	--     mapFile        = "sugar-map.csv",
	--     showGraphics   = true,
	--     agents = {
	--         quantity   = 10,
	--         wealth     = Choice{min = 5, max = 25},
	--         metabolism = Choice{min = 1, max = 4}
	--     },
	--     block = {
	--         xmin       = 0,
	--         xmax       = math.huge,
	--         ymin       = 0,
	--         ymax       = math.huge
	--     },
	--     season = {
	--         summerGrowthRate = 1,
	--         winterGrowthRate = 0.125
	--     },
	--     interface = function()
	--         return {
	--             {"string", "agents"},
	--             {"block", "boolean"}
	--         }
	--     end,
	--     -- ...
	-- }
	interface = function(self)
	end,
	--- Notify the Observers of the Model instance.
	-- @arg modelTime A number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage Tube = Model{
	--     water = 200,
	--     init = function(model)
	--         model.finalTime = 100
	--         model.timer = Timer{
	--             Event{action = function()
	--                 model.water = model.water - 1
	--                 model:notify()
	--             end}
	--         }
	--     end
	-- }
	--
	-- m = Tube{water = 100}
	--
	-- Chart{
	--     subject = m,
	--     select = "water"
	-- }
	--
	-- m:execute()
	notify = function(self, modelTime)
	end
}

--- Type that defines a model. The user can use Model to describe the arguments of a model 
-- and how it can be built.
-- The returning value of a Model is an object that can be used to create instances of the model.
-- A tutorial about Models in TerraME is available at
--  http://github.com/pedro-andrade-inpe/terrame/wiki/Models.
-- @arg attrTab.finalTime A number with the final time of the simulation.
-- @arg attrTab.seed A number with the initial seed for Random.
-- @arg attrTab.init A mandatory function to describe how the model instance is created.
-- See Model:init(). If the Model does not have argument finalTime, this function should
-- create the attribute finalTime to allow the Model instance to be executed.
-- @arg attrTab.... Arguments of the Model. The values of each
-- argument have an associated semantic. See the table below:
-- @tabular ...
-- Attribute type & Description & Default value \
-- number or bool & The instance has to belong to such type. & The value itself. \
-- string & The instance has to be a string. If it is in the format "*.a;*.b;...", it 
-- describes a file extension. The modeler then has to use a filename as argument with one of the
-- extensions defined by this string. & The value itself. \
-- Choice & The instance must have a value that belongs to the Choice. & The default value of the Choice. \
-- Mandatory & A mandatory argument, which means that the use must use a value witht the type
-- defined in the Mandatory to build the model instance correctly. If Mandatory is "table", then
-- the model instance must have all its elements belonging to the same type. & No default value.\
-- named table & It will verify each attribute according to the rules above. & The table itself.
-- It is possible to define only part of the table in the instance, keeping the other default values. \
-- @usage mymodel = Model{
--     par1 = 3,
--     par2 = {"low", "medium", "high"},
--     par3 = {min = 3, max = 5},
--     ...
-- }
--
-- print(type(mymodel)) -- "Model"
--
-- scenario1 = mymodel() -- par1 = 3, par2 = "low", par3.min = 3, par3.max = 5
--
-- print(type(scenario1)) -- "mymodel"
--
-- scenario2 = mymodel{par2 = "medium", par3 = {max = 6}} -- par1 = 3, par3.min = 3
-- scenario3 = mymodel{par2 = "equal"} -- error: there is no such option in par2
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

				if belong(mvalue, {"string", "number", "boolean", "Choice", "Mandatory"}) then
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
		elseif t == "Mandatory" then
			if attrTab.finalTime.value ~= "number" then
				customError("finalTime can only be Mandatory('number'), got Mandatory('"..attrTab.finalTime.value.."').")
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
		elseif t == "Mandatory" then
			if attrTab.seed.value ~= "number" then
				customError("seed can only be Mandatory('number'), got Mandatory('"..attrTab.seed.value.."').")
			end
		else
			optionalTableArgument(attrTab, "seed", "number")
			positiveTableArgument(attrTab, "seed", true)
		end
	end

	forEachElement(attrTab, function(name, value, mtype)
		if mtype == "table" and #value == 0 then
			forEachElement(value, function(iname, ivalue, itype)
				if not belong(itype, {"Choice", "Mandatory", "number", "string", "function", "boolean"}) then
					customError("Type "..itype.." (parameter '"..name.."."..iname.."') is not supported as argument of Model.")
				end
			end)
		elseif mtype == "table" and #value > 0 then
			customError("It is not possible to use a non-named table in a Model (parameter '"..name.."').")
		elseif not belong(mtype, {"Choice", "Mandatory", "number", "string", "function", "boolean"}) then
			customError("Type "..mtype.." (parameter '"..name.."') is not supported as argument of Model.")
		end
	end)

	mandatoryTableArgument(attrTab, "init", "function")
	optionalTableArgument(attrTab, "check", "function")

	local function getExtensions(value)
		local extensions = {}
		local i = 1
		while i <= value:len() do
			if value:sub(i, i) == "." and value:sub(i - 1, i - 1) == "*" then
				local j = i + 1
				while value:sub(j, j) ~= ";" and j <= value:len() do
					j = j + 1
				end

				if value:sub(j, j) == ";" then
					table.insert(extensions, value:sub(i + 1, j - 1))
				else
					table.insert(extensions, value:sub(i + 1, j))
				end
			end
			i = i + 1
		end
		return extensions
	end

	local model

	local mmodel = {type_ = "Model"}
	setmetatable(mmodel, {__call = function(_, v)
		if v == nil then return attrTab end
		return model(v, debug.getinfo(1).name)
	end})

	model = function(argv, typename)
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
			elseif mtype == "Mandatory" then
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
					elseif itype == "Mandatory" and iargv[iname] == nil then
						mandatoryArgumentError(name.."."..iname)
					elseif iargv[iname] == nil and itype ~= "string" then
						iargv[iname] = ivalue
					end
				end)
			elseif argv[name] == nil and mtype ~= "string" then
				argv[name] = value
			end
		end)

		-- check types and values
		forEachOrderedElement(attrTab, function(name, value, mtype)
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
						customError("Argument "..toLabel(name).." should be greater than or equal to "..value.min..".")
					elseif value.max and argv[name] > value.max then
						customError("Argument "..toLabel(name).." should be less than or equal to "..value.max..".")
					elseif value.step and (((argv[name] - value.min)) * 1000) % (value.step * 1000) > 0.000001 then
						-- There is a small bug in Lua with operator % using numbers between 0 and 1
						-- For example, 0.7 % 0.1 == 0.1, but should be 0.0. That's why we need
						-- to multiplicate by 1000 above
						customError("Invalid value for argument "..toLabel(name).." ("..argv[name]..").")
					end
				end
			elseif mtype == "Mandatory" then
				if type(argv[name]) ~= value.value then
					incompatibleTypeError(name, value.value, argv[name])
				end
			elseif mtype == "string" then
				local e = getExtensions(value)

				if #e > 0 then
					mandatoryTableArgument(argv, name, "string")
					local ext = getExtension(argv[name])

					if ext == "" then
						customError("No file extension for parameter "..toLabel(name)..". It should be one of '"..value.."'.")
					elseif not belong(ext, e) then
						customError("Invalid file extension for parameter "..toLabel(name)..". It should be one of '"..value.."'.")
					elseif not isFile(argv[name]) then
						resourceNotFoundError(toLabel(name), argv[name])
					end
				elseif argv[name] == nil then
					argv[name] = attrTab[name]
				end
			elseif mtype == "table" and #value == 0 then
				local iargv = argv[name]
				forEachOrderedElement(value, function(iname, ivalue, itype)
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
								customError("Argument "..toLabel(iname, name).." should be greater than or equal to "..ivalue.min..".")
							elseif ivalue.max and iargv[iname] > ivalue.max then
								customError("Argument "..toLabel(iname, name).." should be less than or equal to "..ivalue.max..".")
							elseif ivalue.step and (iargv[iname] - ivalue.min) % ivalue.step > 0.000001 then
								customError("Invalid value for argument "..toLabel(iname, name).." ("..iargv[iname]..").")
							end
						end
					elseif itype == "Mandatory" then
						if type(iargv[iname]) ~= ivalue.value then
							incompatibleTypeError(name.."."..iname, ivalue.value, iargv[iname])
						end
					elseif itype == "string" then
						local e = getExtensions(ivalue)

						if #e > 0 then
							if type(iargv[iname]) ~= "string" then
								if iargv[iname] == nil then
									mandatoryArgumentError(toLabel(iname, name))
								else
									incompatibleTypeError(name.."."..iname, "string", iargv[iname])
								end
							end

							mandatoryTableArgument(iargv, iname, "string")
							local ext = getExtension(iargv[iname])

							if ext == "" then
								customError("No file extension for parameter "..toLabel(iname, name)..". It should be one of '"..ivalue.."'.")
							elseif not belong(ext, e) then
								customError("Invalid file extension for parameter "..toLabel(iname, name)..". It should be one of '"..ivalue.."'.")
							elseif not isFile(iargv[iname]) then
								resourceNotFoundError(toLabel(iname, name), iargv[iname])
							end
						elseif iargv[iname] == nil then
							iargv[iname] = attrTab[name][iname]
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
		verifyUnnecessaryArguments(argv, names)

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
		argv.parent = mmodel

		attrTab.init(argv)

		if argv.seed ~= nil then
			positiveTableArgument(argv, "seed", true)
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

		argv.cObj_ = TeCell()
		argv.cObj_:setReference(argv)

		argv.notify = function(self, modelTime)
			if modelTime == nil then
				modelTime = 0
			elseif type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				optionalArgument(1, "number", modelTime)
				positiveArgument(1, modelTime, true)
			end

			if self.obsattrs_ then
				forEachElement(self.obsattrs_, function(idx)
					self[idx.."_"] = self[idx](self)
				end)
			end

			self.cObj_:notify(modelTime)
		end

		return argv
	end

	setmetatable(attrTab, {__index = Model_})

	return mmodel
end

