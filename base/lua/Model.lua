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

--- Function to define options to be used by the modeler. It can get a set of
-- non-named values as arguments as well as named arguments as follows. This function
-- can be used stand alone without having to instantiate a Model.
-- @arg attrTab.min The minimum value.
-- @arg attrTab.max The maximum value.
-- @arg attrTab.step An optional argument with the possible steps from minimum to maximum.
-- @usage choice{1, 2, 3}
-- choice{"low", "medium", "high"}
function choice(attrTab)
	local result

	if type(attrTab) ~= "table" then
		customError(tableArgumentMsg())
	elseif #attrTab > 0 then
		if not belong(type(attrTab[1]), {"number", "string"}) then
			customError("The elements should be number or string, got "..type(attrTab[1])..".")
		end
		local type1 = type(attrTab[1])

		forEachElement(attrTab, function(_, _, mtype)
			if type1 ~= mtype then
				customError("All the elements of choice should have the same type.")
			end
		end)

		result = {values = attrTab}
	elseif getn(attrTab) > 0 then
		mandatoryTableArgument(attrTab, "min", "number")

		optionalTableArgument(attrTab, "max", "number")
		optionalTableArgument(attrTab, "step", "number")

		defaultTableValue(attrTab, "default", attrTab.min)

		if attrTab.max then
			verify(attrTab.max > attrTab.min, "Argument 'max' should be greater than 'min'.")
		end

		if attrTab.default then
			verify(attrTab.default >= attrTab.min, "Argument 'default' should be greater than or equal to 'min'.")
			if attrTab.max then
				verify(attrTab.default <= attrTab.max, "Argument 'default' should be less than or equal to 'max'.")
			end
		end

		if attrTab.step and not attrTab.max then
			customError("It is not possible to have 'step' and not 'max'.")
		end

		checkUnnecessaryArguments(attrTab, {"default", "min", "max", "step"})

		if attrTab.step then
			local k = (attrTab.max - attrTab.min) / attrTab.step

			local rest = k % 1
			if rest > 0.00001 then
				local max1 = attrTab.min + (k - rest) * attrTab.step
				local max2 = attrTab.min + (k - rest + 1) * attrTab.step
				customError("Invalid 'max' value ("..attrTab.max.."). It could be "..max1.." or "..max2..".")
			end

			if attrTab.default then
				local k = (attrTab.default - attrTab.min) / attrTab.step

				local rest = k % 1
				if rest > 0.00001 then
					local def1 = attrTab.min + (k - rest) * attrTab.step
					local def2 = attrTab.min + (k - rest + 1) * attrTab.step
					customError("Invalid 'default' value ("..attrTab.default.."). It could be "..def1.." or "..def2..".")
				end
			end
		end

		result = attrTab
	else
		customError("There are no options for the choice (table is empty).")
	end

	setmetatable(result, {__index = {type_ = "choice"}})
	return result
end

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
		customError("Function 'init' was not implemented by the Model.")
	end,
	--- Run the model. It checks the arguments, create the objects, and then simulate until numRuns.
	-- @arg finalTime A number with the final time of the simulation.
	-- @usage model:execute(20)
	execute = function(self, finalTime)
		if self.finalTime then
			if finalTime == nil then
				finalTime = self.finalTime
			else
				customError("execute() should not take any argument because the model already has a final time.")
			end
		end

		if finalTime == nil then
			mandatoryArgumentError(1, 3)	
		elseif type(finalTime) ~= "number" then 
			incompatibleTypeError(1, "number", finalTime)
		end

		forEachElement(self, function(name, value, mtype)
			if mtype == "Timer" then
				value:execute(finalTime)
				return false
			elseif mtype == "Environment" then
				local found = false
				forEachElement(value, function(mname, mvalue, mmtype)
					mvalue:execute(finalTime)
					found = true
					return false
				end)
				if found then return false end
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

local stringToLabel = function(mstring)
	if type(mstring) == "number" then
		return tostring(mstring)
	end

	local result = string.upper(string.sub(mstring, 1, 1))

	local nextsub = string.match(mstring, "%u")
	for i = 2, mstring:len() do
		local nextchar = string.sub(mstring, i, i)
		if nextchar == nextsub then
			result = result.." "..nextsub
			nextsub = string.match(string.sub(mstring, i + 1, mstring:len()), "%u")
		else
			result = result..nextchar
		end
	end
	return result
end

local create_ordering = function(self)
	local ordering = {}
	local current_ordering = {}
	local quantity = 0
	local count_string  = 0
	local count_number  = 0
	local count_boolean = 0
	local count_table   = 0
	local named = {}
	local max_buffer = 25
	local count_mandatory  = 0

	forEachElement(self, function(idx, element, mtype)
		if     mtype == "string"  then                 count_string  = count_string  + 1
		elseif mtype == "number"  then                 count_number  = count_number  + 1
		elseif mtype == "boolean" then                 count_boolean = count_boolean + 1
		elseif mtype == "table" and #element > 1 then  count_table   = count_table   + 1
		elseif mtype == "table" and #element == 0 then table.insert(named, idx)
		elseif mtype == "mandatory" then
			if element.value == "number" then
				count_mandatory = count_mandatory + 1
			else
				customError("Automatic graphical interface does not support '"..element.value.."' as mandatory argument.")
			end
		end
	end)

	if count_string > 0 then 
		table.insert(current_ordering, "string") 
		quantity = quantity + count_string
	end

	if count_mandatory > 0 then
		if quantity + count_mandatory > max_buffer then
			table.insert(ordering, current_ordering)
			quantity = 0
			current_ordering = {}
		end
		table.insert(current_ordering, "mandatory")
		quantity = quantity + count_mandatory
	end

	if count_table > 0 then 
		if quantity + count_table > max_buffer then
			table.insert(ordering, current_ordering)
			quantity = 0
			current_ordering = {}
		end
		table.insert(current_ordering, "table")
		quantity = quantity + count_table
	end

	if count_number > 0 then
		if quantity + count_number > max_buffer then
			table.insert(ordering, current_ordering)
			quantity = 0
			current_ordering = {}
		end
		table.insert(current_ordering, "number")
		quantity = quantity + count_number
	end

	if #named > 1 then
		table.sort(named)
	end

	forEachElement(named, function(_, idx)
		element = self[idx]
		mtype = type(element)
		if mtype == "table" and #element == 0 then
			local qelement = 0 -- we need to count the elements of a named table manually
			forEachElement(element, function()
				qelement = qelement + 1
			end)

			if quantity + qelement + 1 > max_buffer then
				table.insert(ordering, current_ordering)
				quantity = 0
				current_ordering = {}
			end
			table.insert(current_ordering, idx)
			quantity = quantity + qelement + 1 -- (+1 because of the title of the box)
		end
	end)
	
	if count_boolean > 0 then
		if quantity + count_boolean > max_buffer then
			table.insert(ordering, current_ordering)
			quantity = 0
			current_ordering = {}
		end
		table.insert(current_ordering, "boolean")
		quantity = quantity + count_boolean
	end

	if quantity > 0 then
		table.insert(ordering, current_ordering)
	end

	return ordering
end

local create_t

-- Create a table with the order of the elements to be drawn on the screen
create_t = function(mtable, ordering)
	local t = {}
	forEachElement(ordering, function(column, elements)
		forEachElement(elements, function(_, element)
			-- element \in {string, number, boolean, table, etc.}
			local mt = {}

			forEachElement(mtable, function(idx, melement, mtype)
					if element == "string"  and mtype == "string"  then table.insert(mt, idx)
				elseif element == "boolean" and mtype == "boolean" then table.insert(mt, idx)
				elseif element == "number"  and mtype == "number"  then table.insert(mt, idx)
				elseif element == "table"   and mtype == "table" and #melement > 0 then table.insert(mt, idx)
				elseif element == "mandatory" and mtype == "mandatory" then table.insert(mt, idx)
				elseif element == idx then -- named table
					local ordering = create_ordering(melement)
					table.insert(mt, create_t(melement, ordering))
				end
			end)

			table.sort(mt)

			-- Put every *max* after *min* (because alphabetically they come after)
			local idxmax = {}
			forEachElement(mt, function(idx, melement)
				if type(melement) == "string" and string.match(melement, "max") then
					table.insert(idxmax, idx)
				end
			end)

			forEachElement(idxmax, function(idx, maxelement)
				local mmin = string.gsub(mt[idxmax[idx]], "max", "min")

				local idx_min = -1

				forEachElement(mt, function(idx, melement)
					if melement == mmin then
						idx_min = idx
					end
				end)
				if idx_min ~= -1 then
					local tmp = mt[idxmax[idx]]
					mt[idxmax[idx]] = mt[idx_min]
					mt[idx_min] = tmp
				end
			end)

			t[element] = mt
		end)
	end)
	return t
end

interface = function(self, modelName, package)
	local quantity, count = 0, 0
	local pkgattrs, qtattrs, typeattrs, r = "", "", "", ""

	r = r.."-- This file was created automatically from a TerraME Model ("..os.date("%c")..")\n\n"
	r = r.."require__(\"qtluae\")\n"

	local ordering
	if type(self.interface) == "function" then
		ordering = self.interface()
	else
		ordering = create_ordering(self)
	end

	local t = create_t(self, ordering)

	r = r.."Dialog = qt.new_qobject(qt.meta.QDialog)\n"
	r = r.."Dialog.windowTitle = \""..modelName.."\"\n\n"

	-- the first layout will contain a layout with the arguments in the top 
	-- and another with the buttons in the bottom
	r = r.."ExternalLayout = qt.new_qobject(qt.meta.QVBoxLayout)\n"
	r = r.."qt.ui.layout_add(Dialog, ExternalLayout)\n"
	r = r.."ExternalLayout.spacing = 0\n\n"

	r = r.."HorizontalLayout = qt.new_qobject(qt.meta.QHBoxLayout)\n"
	r = r.."qt.ui.layout_add(ExternalLayout, HorizontalLayout)\n"

	local shorizontal = 0
	forEachElement(ordering, function(idx, mvector)
		r = r.."qt.ui.layout_spacer(HorizontalLayout, "..shorizontal..", 0)\n"
		shorizontal = 20
		r = r.."VerticalLayout"..idx.." = qt.new_qobject(qt.meta.QVBoxLayout)\n"
		r = r.."VerticalLayout"..idx..".spacing = 5\n\n"
		r = r.."qt.ui.layout_add(HorizontalLayout, VerticalLayout"..idx..")\n"
		forEachElement(mvector, function(_, melement)
			r = r.."VerticalLayout"..melement.." = qt.new_qobject(qt.meta.QVBoxLayout)\n"
			r = r.."VerticalLayout"..melement..".spacing = 5\n\n"
			r = r.."qt.ui.layout_add(VerticalLayout"..idx..", VerticalLayout"..melement..")\n"
			r = r.."qt.ui.layout_spacer(VerticalLayout"..idx..", 0, 5)\n"
		end)
	end)

	-- Create the visual elements
	forEachElement(t, function(idx, melement)
		local layout = "VerticalLayout"..idx
		if idx == "number" then
			r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpGridLayout)\n"
			count = 0

			forEachElement(melement, function(_, value)
				r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
				r = r.."label.text = \""..stringToLabel(value).."\"\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"
	
				r = r.."lineEdit"..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n"
				--r = r.."lineEdit"..value..".minimumSize = {120,28}\n"
				--r = r.."lineEdit"..value..".maximumSize = {150,28}\n"

				if self[value] ~= math.huge then
					r = r.."lineEdit"..value..":setText(\""..self[value].."\")\n\n"
				else
					r = r.."lineEdit"..value..":setText(\"inf\")\n\n"
				end
				count = count + 1
			end)
		elseif idx == "string" then
			r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpGridLayout)\n"
			count = 0

			forEachElement(melement, function(_, value)
				r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"

				r = r.."label.text = \""..stringToLabel(value).."\"\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"

				r = r.."lineEdit"..value.."= qt.new_qobject(qt.meta.QLineEdit)\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n"
				r = r.."lineEdit"..value..":setText(\""..self[value].."\")\n\n"

				r = r.."SelectButton = qt.new_qobject(qt.meta.QPushButton)\n"
				r = r.."SelectButton.text = \"...\"\n"
				r = r.."SelectButton:setStyleSheet('QPushButton {color: black;}')\n"
				r = r.."SelectButton.minimumSize = {16, 18}\n"
				r = r.."SelectButton.maximumSize = {16, 18}\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, SelectButton, "..count..", 2)\n\n"

				local svalue = stringToLabel(value)
				local ext = string.find(self[value], "%.")
				if ext then
					ext = "*"..string.sub(self[value], ext)
					r = r.."lineEdit"..value..".enabled = false\n"
					
					r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
						"fname = qt.dialog.get_open_filename(\"Select File\", \"\", \""..ext.."\")\n"..
						"if fname ~= \"\" then\n"..
						"\tlineEdit"..value..":setText(fname)\n"..
						"end\n"..
					"end)\n"
				else
					r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
						"fname = qt.dialog.get_existing_directory(\"Select Directory\", \"\")\n"..
						"if fname ~= \"\" then\n"..
						"\tlineEdit"..value..":setText(fname..\"/"..self[value].."\")\n"..
						"end\n"..
					"end)\n"
				end
				count = count + 1
			end)
		elseif idx == "boolean" then
			r = r.."TmpVBoxLayout = qt.new_qobject(qt.meta.QVBoxLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpVBoxLayout)\n"

			forEachElement(melement, function(_, value)
				r = r.."checkBox"..value.." = qt.new_qobject(qt.meta.QCheckBox)\n"
				r = r.."checkBox"..value..".text = \""..stringToLabel(value).."\"\n"
				r = r.."checkBox"..value..".checked = "..tostring(self[value]).."\n"
				r = r.."qt.ui.layout_add(TmpVBoxLayout, checkBox"..value..")\n\n"
			end)
		elseif idx == "mandatory" then
			r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpGridLayout)\n"
			count = 0

			forEachElement(melement, function(_, value)
				r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
				r = r.."label.text = \""..stringToLabel(value).."\"\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"
	
				r = r.."lineEdit"..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n"

				count = count + 1
			end)

				forEachElement(self[value], function(_, mstring)
					r = r.."qt.combobox_add_item(combobox"..value..", \""..stringToLabel(mstring).."\")\n"
					tvalue = tvalue.."\""..mstring.."\", "
				end)
				tvalue = tvalue.."}\n"
				r = r..tvalue

				r = r.."qt.ui.layout_add(TmpGridLayout, combobox"..value..", "..count..", 1)\n\n"
				count = count + 1
			end)
		else -- named table (idx is the name of the table)
			r = r.."groupbox"..idx.." = qt.new_qobject(qt.meta.QGroupBox)\n"
			r = r.."groupbox"..idx..".title = \""..stringToLabel(idx).."\"\n"
			r = r.."groupbox"..idx..".flat = false\n"
			r = r.."qt.ui.layout_add("..layout..", groupbox"..idx..")\n"	
			r = r.."TmpLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add(groupbox"..idx..", TmpLayout)\n"

			forEachElement(melement[1], function(midx, mvalue)
				if midx == "table" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 1, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
						r = r.."label.text = \""..stringToLabel(value).."\"\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"

						r = r.."combobox"..idx..value.." = qt.new_qobject(qt.meta.QComboBox)".."\n"

						local tvalue = "\ntvalue"..idx..value.." = {"
						forEachElement(self[idx][value], function(_, mstring)
							r = r.."qt.combobox_add_item(combobox"..idx..value..", \""..stringToLabel(mstring).."\")\n"
							tvalue = tvalue.."\""..mstring.."\", "
						end)
						tvalue = tvalue.."}\n"
						r = r..tvalue

						r = r.."qt.ui.layout_add(TmpGridLayout, combobox"..idx..value..", "..count..", 1)\n\n"
						count = count + 1
					end)
				elseif midx == "number" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 2, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
						r = r.."label.text = \""..stringToLabel(value).."\"\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"
	
						r = r.."lineEdit"..idx..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n"

						if self[value] ~= math.huge then
							r = r.."lineEdit"..idx..value..":setText(\""..self[idx][value].."\")\n\n"
						else
							r = r.."lineEdit"..idx..value..":setText(\"inf\")\n\n"
						end
						count = count + 1
					end)
				elseif midx == "boolean" then
					r = r.."TmpVBoxLayout = qt.new_qobject(qt.meta.QVBoxLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpVBoxLayout, 3, 0)\n"

					forEachElement(mvalue, function(_, value)
						if value == "active" then
							r = r.."groupbox"..idx..".checkable = true\n"
							r = r.."groupbox"..idx..".checked = "..tostring(self[idx][value]).."\n"
						else
							r = r.."checkBox"..idx..value.." = qt.new_qobject(qt.meta.QCheckBox)\n"
							r = r.."checkBox"..idx..value..".text = \""..stringToLabel(value).."\"\n"
							r = r.."checkBox"..idx..value..".checked = "..tostring(self[idx][value]).."\n"
							r = r.."qt.ui.layout_add(TmpVBoxLayout, checkBox"..idx..value..")\n\n"
						end
					end)
				elseif midx == "string" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 0, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"

						r = r.."label.text = \""..stringToLabel(value).."\"\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"

						r = r.."lineEdit"..idx..value.."= qt.new_qobject(qt.meta.QLineEdit)\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n"
						r = r.."lineEdit"..idx..value..":setText(\""..self[idx][value].."\")\n\n"

						r = r.."SelectButton = qt.new_qobject(qt.meta.QPushButton)\n"
						r = r.."SelectButton.text = \"...\"\n"
						r = r.."SelectButton:setStyleSheet('QPushButton {color: black;}')\n"
						r = r.."SelectButton.minimumSize = {16, 18}\n"
						r = r.."SelectButton.maximumSize = {16, 18}\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, SelectButton, "..count..", 2)\n\n"

						local ext = string.find(self[idx][value], "%.")
						if ext then
							ext = "*"..string.sub(self[idx][value], ext)
							r = r.."lineEdit"..idx..value..".enabled = false\n"
					
							r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
								"fname = qt.dialog.get_open_filename(\"Select File\", \"\", \""..ext.."\")\n"..
								"if fname ~= \"\" then\n"..
								"\tlineEdit"..idx..value..":setText(fname)\n"..
								"end\n"..
							"end)\n"
						else
							r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
								"fname = qt.dialog.get_existing_directory(\"Select Directory\", \"\")\n"..
								"if fname ~= \"\" then\n"..
								"\nlineEdit"..idx..value..":setText(fname..\"/"..self[idx][value].."\")\n"..
								"end\n"..
							"end)\n"
						end
						count = count + 1
					end)
				end
			end)
		end
	end)

	r = r.."qt.ui.layout_spacer(ExternalLayout, 0, 10)\n"
	r = r.."ButtonsLayout = qt.new_qobject(qt.meta.QHBoxLayout)\n"

	r = r.."RunButton = qt.new_qobject(qt.meta.QPushButton)\n"
	r = r.."RunButton.text = \"Run\"\n"
	r = r.."RunButton.minimumSize = {100, 28}\n"
	r = r.."RunButton.maximumSize = {110, 28}\n"
	r = r.."qt.ui.layout_add(ButtonsLayout, RunButton)\n\n"

	r = r.."QuitButton = qt.new_qobject(qt.meta.QPushButton)\n"
	r = r.."QuitButton.minimumSize = {100, 28}\n"
	r = r.."QuitButton.maximumSize = {110, 28}\n"
	r = r.."QuitButton.text = \"Quit\"\n"
	r = r.."qt.ui.layout_add(ButtonsLayout, QuitButton)\n"
	r = r.."qt.ui.layout_add(ExternalLayout, ButtonsLayout)\n"

	r = r.."m2function = function() Dialog:done(0) end\n"
	r = r.."qt.connect(QuitButton, \"clicked()\", m2function)\n"

	r = r.."\nmfunction = function()\n"
	r = r.."\tlocal merr\n"
	r = r.."\tresult = \"-- Model instance automatically built by TerraME (\"..os.date(\"%c\")..\")\"\n"
	r = r.."\tresult = result..\"\\n\\nrequire(\\\""..package.."\\\")\"\n"
	r = r.."\tresult = result..\"\\n\\ninstance = "..modelName.."{\"".."\n"

	-- create the function to be activated when the user pushes 'Run'
	forEachOrderedElement(t, function(idx, melement)
		if idx == "number" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tif lineEdit"..value..".text == \"inf\" then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = math.huge,\"\n"
				r = r.."\telseif not tonumber(lineEdit"..value..".text) then\n"
				r = r.."\t\tmerr = \"Error: "..stringToLabel(value).." (\"..lineEdit"..value..".text..\") is not a valid number.\"\n"
				r = r.."\telse\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..lineEdit"..value..".text..\",\"\n"
				r = r.."\tend\n"
			end)
		elseif idx == "string" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tresult = result..\"\\n\t"..value.." = \\\"\"..lineEdit"..value..".text..\"\\\",\"\n"
			end)
		elseif idx == "boolean" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tresult = result..\"\\n\t"..value.." = \"..tostring(checkBox"..value..".checked)..\",\"\n"
			end)
		elseif idx == "table" then
		elseif idx == "mandatory" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tif lineEdit"..value..".text == \"inf\" then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = math.huge,\"\n"
				r = r.."\telseif not tonumber(lineEdit"..value..".text) then\n"
				r = r.."\t\tmerr = \"Error: "..stringToLabel(value).." (\"..lineEdit"..value..".text..\") is not a valid number.\"\n"
				r = r.."\telse\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..lineEdit"..value..".text..\",\"\n"
				r = r.."\tend\n"
			end)
		else -- named table
			r = r.."\tresult = result..\"\\n\t"..idx.." = {\"\n"
			forEachOrderedElement(melement[1], function(midx, mvalue)
				if midx == "number" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tif lineEdit"..idx..value..".text == \"inf\" then\n"
						r = r.."\t\tresult = result..\"\\n\t\t"..value.." = math.huge,\"\n"
						r = r.."\telseif not tonumber(lineEdit"..idx..value..".text) then\n"
						r = r.."\t\tmerr = \"Error: "..stringToLabel(value).." (\"..lineEdit"..idx..value..".text..\") is not a valid number.\"\n"
						r = r.."\telse\n"
						r = r.."\t\tresult = result..\"\\n\t\t"..value.." = \"..lineEdit"..idx..value..".text..\",\"\n"
						r = r.."\tend"
					end)
				elseif midx == "boolean" then
					forEachOrderedElement(mvalue, function(_, value)
						if value == "active" then
							r = r.."\tresult = result..\"\\n\t\t"..value.." = \"..tostring(groupbox"..idx..".checked)..\",\"\n"
						else
							r = r.."\tresult = result..\"\\n\t\t"..value.." = \"..tostring(checkBox"..idx..value..".checked)..\",\"\n"
						end
					end)
				elseif midx == "string" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tresult = result..\"\\n\t\t"..value.." = \\\"\"..lineEdit"..idx..value..".text..\"\\\",\"\n"
					end)
				elseif midx == "table" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tresult = result..\"\\n\t\t"..value.." = \\\"\"..tvalue"..idx..value..
							"[combobox"..idx..value..".currentIndex + 1]..\"\\\",\"\n"
					end)
				end
			end)
			r = r.."\n\tresult = result..\"\\n\t},\"\n"
		end
	end)
	r = r.."\tresult = result..\"\\n}\\n\\n\"\n\n"

	r = r.."\texecute = \"instance:execute()\"\n"
	r = r.."\tfile = io.open(\""..modelName.."-instance.lua\", \"w\")\n"
	r = r.."\tfile:write(result..execute)\n"
	r = r.."\tfile:close()\n"
	r = r..[[
	if not merr then
		-- BUG**: http://lists.gnu.org/archive/html/libqtlua-list/2013-05/msg00004.html
		_, merr = pcall(function() load(result)() end)
		if merr then
			local merr2 = string.match(merr, ":[0-9]*:.*")
			if merr2 then
				local merr3 = string.gsub(merr,":[0-9]*: ", "")
				if merr3 then
					merr = merr3
				else
					merr = merr2
				end
			end	
		end
	end

	if merr then
		qt.dialog.msg_critical(merr)
	else
		_, merr = pcall(function() load(execute)() end)
		if merr then
			merr = string.match(merr, ":[0-9]*:.*")
			merr = string.gsub(merr,":[0-9]*: ", "")
			qt.dialog.msg_critical(merr)
		end
		Dialog:accept()
	end]]

	r = r.."\nend\n"
	r = r.."qt.connect(RunButton, \"clicked()\", mfunction)\n\n"

	r = r.."local result = Dialog:exec()\n\n"
	-- why not changing to Dialog:show()?
	-- http://stackoverflow.com/questions/12068317/calling-qapplicationexec-after-qdialogexec
	r = r.."print(result)"
	
	file = io.open(modelName.."-interface.lua", "w")
	file:write(r)
	file:close()
	-- TODO: replace the line below by load(r)(). There is a problem with qtlua that crashes
	-- the application when loading, but it works properly if we call terrame again.
	os.execute("terrame "..modelName.."-interface.lua")
	--load(r)()
end

-- ** Both Qt and Lua provide functions which may not be appropriate depending on 
-- the situation. The os.exit Lua function is not appropriate here because it 
-- calls the libc exit function which doesn't unwind the stack. The cleanup of 
-- various C++ objects is not performed properly in this case. Use app:quit() 
-- instead. You may want to drop the os.exit function and other such lua 
-- functions to prevent their use if it's critical in your application.


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
Model = function(attrTab)
	-- check whether the elements of non-named vectors have the same type
	forEachElement(attrTab, function(name, value, mtype)
		if mtype == "table" and #value > 0 then
			local ttype = type(value[1])
			forEachElement(value, function(_, _, mttype)
				if mttype ~= ttype then
					customError("All the elements of table '"..name.."' should have the same type.")
				end
			end)
		elseif mtype == "table" and #value == 0 then
			forEachElement(value, function(mname, mvalue, mttype)
				if mttype == "table" and #mvalue > 0 then
					local ttype = type(mvalue[1])
					forEachElement(mvalue, function(_, _, ittype)
						if ittype ~= ttype then
							customError("All the elements of table '"..name.."."..mname.."' should have the same type.")
						end
					end)
				end
			end)
		end
	end)

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

				if belong(mvalue, {"string", "number", "boolean"}) then
					local found = false
					forEachElement(attrTab, function(_, _, attrtype)
						if attrtype == mvalue then
							found = true
							return false
						end
					end)

					if not found then
						customError("There is no argument '"..mvalue.."' in the Model, although it is described in the interface().")
					end
				elseif mvalue == "table" then
					local found = false
					forEachElement(attrTab, function(_, attrvalue, attrtype)
						if type(attrtype) == mvalue and #attrvalue > 0 then
							found = true
							return false
						end
					end)

					if not found then
						customError("There is no non-named table parameter in the Model, but it is described in the interface().")
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

	local function model(argv)
		if argv == nil then argv = {} end

		-- set the default values
		forEachElement(attrTab, function(name, value, mtype)
			if mtype == "choice" then
				if argv[name] == nil then
					if value.values then
						argv[name] = value.values[1]
					else
						argv[name] = value.default
					end
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
					if itype == "choice" and iargv[iname] == nil then
						if ivalue.values then
							iargv[iname] = ivalue.values[1]
						else
							iargv[iname] = ivalue.default
						end
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
			if mtype == "choice" then
				if value.values then
					if type(argv[name]) ~= type(value.values[1]) then
						incompatibleTypeError(name, type(value.values[1]), argv[name])
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
					elseif value.step and (argv[name] - value.min) % value.step > 0.000001 then
						customError("Invalid value for argument '"..name.."'.")
					end
				end
			elseif mtype == "mandatory" then
				if type(argv[name]) ~= value.value then
					incompatibleTypeError(name, value.value, argv[name])
				end
			elseif mtype == "table" and #value == 0 then
				local iargv = argv[name]
				forEachElement(value, function(iname, ivalue, itype)
					if itype == "choice" then
						if ivalue.values then
							if type(iargv[iname]) ~= type(ivalue.values[1]) then
								incompatibleTypeError(name, type(ivalue.values[1]), iargv[iname])
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
								customError("Invalid value for argument '"..name.."."..iname.."'.")
							end
						end
					elseif itype ~= type(iargv[iname]) then
						incompatibleTypeError(name.."."..iname, itype, iargv[iname])
					end
				end)
			elseif mtype == "mandatory" then
				if type(argv[name]) ~= value.value then
					incompatibletypeError(name, type(argv[name]), value.value)
				end
			elseif type(argv[name]) ~= mtype then
				incompatibleTypeError(name, mtype, argv[name])
			end
		end)

		-- verify whether there are some arguments in the instance that do not belong to the Model
		forEachElement(argv, function(name, value, mtype)
			if type(value) == "table" then
				local attrTabValue = attrTab[name]
				forEachElement(value, function(mname, mvalue, mtype)
					if attrTabValue[mname] == nil then
						customError("Attribute '"..name.."."..mname.."' does not exist in the Model.")
					end
				end)
			elseif attrTab[name] == nil then
				customError("Attribute '"..name.."' does not exist in the Model.")
			end
		end)

		setmetatable(argv, {__index = attrTab})
		setmetatable(attrTab, {__index = Model_})
		argv:check()
		argv:init()

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
	return model
end

