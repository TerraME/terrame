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

local function create_ordering(self)
	local ordering         = {}
	local current_ordering = {}
	local quantity         = 0
	local count_string     = 0
	local count_number     = 0
	local count_boolean    = 0
	local count_mandatory  = 0
	local count_table      = 0
	local named            = {}
	local max_buffer       = 25

	forEachElement(self, function(idx, element, mtype)
		if     mtype == "string"  then                 count_string  = count_string  + 1
		elseif mtype == "number"  then                 count_number  = count_number  + 1
		elseif mtype == "boolean" then                 count_boolean = count_boolean + 1
		elseif mtype == "Choice"  then                 count_table   = count_table   + 1
		elseif mtype == "table" and #element == 0 then table.insert(named, idx)
		elseif mtype == "Mandatory" then
			if element.value == "number" then
				count_mandatory = count_mandatory + 1
			else
				customError("Automatic graphical interface does not support '"..element.value.."' as Mandatory argument.")
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
		table.insert(current_ordering, "Mandatory")
		quantity = quantity + count_mandatory
	end

	if count_table > 0 then 
		if quantity + count_table > max_buffer then
			table.insert(ordering, current_ordering)
			quantity = 0
			current_ordering = {}
		end
		table.insert(current_ordering, "Choice")
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
		local element = self[idx]
		local mtype = type(element)
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
	forEachElement(ordering, function(_, elements)
		forEachElement(elements, function(_, element)
			-- element \in {string, number, boolean, table, etc.}
			local mt = {}

			forEachElement(mtable, function(idx, melement, mtype)
					if element == "string"    and mtype == "string"    then table.insert(mt, idx)
				elseif element == "boolean"   and mtype == "boolean"   then table.insert(mt, idx)
				elseif element == "number"    and mtype == "number"    then table.insert(mt, idx)
				elseif element == "Choice"    and mtype == "Choice"    then table.insert(mt, idx)
				elseif element == "Mandatory" and mtype == "Mandatory" then table.insert(mt, idx)
				elseif element == idx then -- named table
					local mordering = create_ordering(melement)
					table.insert(mt, create_t(melement, mordering))
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

			forEachElement(idxmax, function(idx)
				local mmin = string.gsub(mt[idxmax[idx]], "max", "min")

				local idx_min = -1

				forEachElement(mt, function(midx, melement)
					if melement == mmin then
						idx_min = midx
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

function _Gtme.configure(self, modelName, package)
	local count = 0
	local r = ""

	r = r.."-- This file was created automatically from a TerraME Model ("..os.date("%c")..")\n\n"
	r = r.."require(\"qtluae\")\n"
	r = r.."sessionInfo().configure = true\n"

	if not package then
		rawset(_G, "__zzz", modelName)
		modelName = "__zzz"
	end

	local ordering

	if type(self.interface) == "function" then
		ordering = self.interface()
	end

	if type(ordering) ~= "table" then
		ordering = create_ordering(self)
	end

	local t = create_t(self, ordering)

	r = r.."Dialog = qt.new_qobject(qt.meta.QDialog)\n"

	if package then
		r = r.."Dialog.windowTitle = \""..modelName.."\"\n\n"
	else
		r = r.."Dialog.windowTitle = \"Configure Model\"\n\n"
	end


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
				r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
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

				r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
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

				local ext = string.find(self[value], "%.")
				if ext then
					ext = "*"..string.sub(self[value], ext)
					r = r.."lineEdit"..value..".enabled = false\n"
					
					r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
						"local fname = qt.dialog.get_open_filename(\"Select File\", \"\", \""..ext.."\")\n"..
						"if fname ~= \"\" then\n"..
						"\tlineEdit"..value..":setText(fname)\n"..
						"end\n"..
					"end)\n"
				else
					r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
						"local fname = qt.dialog.get_existing_directory(\"Select Directory\", \"\")\n"..
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
				r = r.."checkBox"..value..".text = \"".._Gtme.stringToLabel(value).."\"\n"
				r = r.."checkBox"..value..".checked = "..tostring(self[value]).."\n"
				r = r.."qt.ui.layout_add(TmpVBoxLayout, checkBox"..value..")\n\n"
			end)
		elseif idx == "Mandatory" then
			r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpGridLayout)\n"
			count = 0

			forEachElement(melement, function(_, value)
				r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
				r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"
	
				r = r.."lineEdit"..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n"

				count = count + 1
			end)
		elseif idx == "Choice" then
			r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add("..layout..", TmpGridLayout)\n"
			count = 0

			forEachElement(melement, function(_, value)
				r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
				r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
				r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"

				if self[value].values then
					r = r.."combobox"..value.." = qt.new_qobject(qt.meta.QComboBox)".."\n"

					local pos = 0
					local index
					table.sort(self[value].values)
					local tvalue = "\ntvalue"..value.." = {"
					forEachElement(self[value].values, function(_, mstring)
						r = r.."qt.combobox_add_item(combobox"..value..", \"".._Gtme.stringToLabel(mstring).."\")\n"
						tvalue = tvalue.."\""..mstring.."\", "

						if mstring == self[value].default then
							index = pos
						else
							pos = pos + 1
						end
					end)
					tvalue = tvalue.."}\n"
					r = r..tvalue

					r = r.."combobox"..value..":setCurrentIndex("..index..")\n"

					r = r.."qt.ui.layout_add(TmpGridLayout, combobox"..value..", "..count..", 1)\n\n"
				elseif self[value].step then
					r = r.."lineEdit"..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
					r = r.."lineEdit"..value..".enabled = false\n"
					r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n\n"

					count = count + 1

					local range = (self[value].max - self[value].min) / self[value].step

					r = r.."slider"..value.." = qt.new_qobject(qt.meta.QSlider)".."\n"
					r = r.."slider"..value..":setRange(0, "..range..")\n"
					r = r.."qt.config_qslider(slider"..value..", 1)\n"

					local default = (self[value].default - self[value].min) / self[value].step

					r = r.."slider"..value..".value = "..default.."\n"

					r = r.."qt.ui.layout_add(TmpGridLayout, slider"..value..", "..count..", 1)\n"
					r = r.."lineEdit"..value..":setText(tostring("..self[value].default.."))\n"

					r = r.."qt.connect(slider"..value..", \"valueChanged(int)\", function()\n"..
						"lineEdit"..value..":setText(tostring("..self[value].min.. "+ slider"..value..".value * "..self[value].step.."))\n"..
					"end)\n\n"
				else -- no step
					r = r.."lineEdit"..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
					r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..value..", "..count..", 1)\n\n"
					r = r.."lineEdit"..value..":setText("..self[value].default..")\n"

					count = count + 1
				end
				count = count + 1

			end)
		else -- named table (idx is the name of the table)
			r = r.."groupbox"..idx.." = qt.new_qobject(qt.meta.QGroupBox)\n"
			r = r.."groupbox"..idx..".title = \"".._Gtme.stringToLabel(idx).."\"\n"
			r = r.."groupbox"..idx..".flat = false\n"
			r = r.."qt.ui.layout_add("..layout..", groupbox"..idx..")\n"
			r = r.."TmpLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
			r = r.."qt.ui.layout_add(groupbox"..idx..", TmpLayout)\n"

			forEachElement(melement[1], function(midx, mvalue)
				if midx == "Choice" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 1, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
						r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"

						if self[idx][value].values then
							r = r.."combobox"..idx..value.." = qt.new_qobject(qt.meta.QComboBox)".."\n"

							local pos = 0
							local index
							local tvalue = "\ntvalue"..idx..value.." = {"
							table.sort(self[idx][value].values)
							forEachElement(self[idx][value].values, function(_, mstring)
								r = r.."qt.combobox_add_item(combobox"..idx..value..", \"".._Gtme.stringToLabel(mstring).."\")\n"
								tvalue = tvalue.."\""..mstring.."\", "

								if mstring == self[idx][value].default then
									index = pos
								else
									pos = pos + 1
								end
							end)
							tvalue = tvalue.."}\n"
							r = r..tvalue

							r = r.."combobox"..idx..value..":setCurrentIndex("..index..")\n"

							r = r.."qt.ui.layout_add(TmpGridLayout, combobox"..idx..value..", "..count..", 1)\n\n"
							count = count + 1
						elseif self[idx][value].step then
							r = r.."lineEdit"..idx..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
							r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n"
							r = r.."lineEdit"..idx..value..".enabled = false\n"
							r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n\n"

							count = count + 1

							local range = (self[idx][value].max - self[idx][value].min) / self[idx][value].step

							r = r.."slider"..idx..value.." = qt.new_qobject(qt.meta.QSlider)".."\n"
							r = r.."slider"..idx..value..":setRange(0, "..range..")\n"
							r = r.."qt.config_qslider(slider"..idx..value..", 1)\n"

							local default = (self[idx][value].default - self[idx][value].min) / self[idx][value].step

							r = r.."slider"..idx..value..".value = "..default.."\n"

							r = r.."qt.ui.layout_add(TmpGridLayout, slider"..idx..value..", "..count..", 1)\n"
							r = r.."lineEdit"..idx..value..":setText(tostring("..self[idx][value].default.."))\n"

							r = r.."qt.connect(slider"..idx..value..", \"valueChanged(int)\", function()\n"..
								"lineEdit"..idx..value..":setText(tostring("..self[idx][value].min.. "+ slider"..idx..value..".value * "..self[idx][value].step.."))\n"..
							"end)\n\n"
						else -- no step
							r = r.."lineEdit"..idx..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
							r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n"
							r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n\n"
							r = r.."lineEdit"..idx..value..":setText(tostring("..self[idx][value].default.."))\n"

							count = count + 1
						end
						count = count + 1
					end)
				elseif midx == "Mandatory" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 2, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
						r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, label, "..count..", 0)\n"
	
						r = r.."lineEdit"..idx..value.." = qt.new_qobject(qt.meta.QLineEdit)\n"
						r = r.."qt.ui.layout_add(TmpGridLayout, lineEdit"..idx..value..", "..count..", 1)\n"

						count = count + 1
					end)
				elseif midx == "number" then
					r = r.."TmpGridLayout = qt.new_qobject(qt.meta.QGridLayout)\n"
					r = r.."qt.ui.layout_add(TmpLayout, TmpGridLayout, 3, 0)\n"
					count = 0

					forEachElement(mvalue, function(_, value)
						r = r.."label = qt.new_qobject(qt.meta.QLabel)\n"
						r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
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
					r = r.."qt.ui.layout_add(TmpLayout, TmpVBoxLayout, 4, 0)\n"

					forEachElement(mvalue, function(_, value)
						if value == "active" then
							r = r.."groupbox"..idx..".checkable = true\n"
							r = r.."groupbox"..idx..".checked = "..tostring(self[idx][value]).."\n"
						else
							r = r.."checkBox"..idx..value.." = qt.new_qobject(qt.meta.QCheckBox)\n"
							r = r.."checkBox"..idx..value..".text = \"".._Gtme.stringToLabel(value).."\"\n"
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

						r = r.."label.text = \"".._Gtme.stringToLabel(value).."\"\n"
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
								"local fname = qt.dialog.get_open_filename(\"Select File\", \"\", \""..ext.."\")\n"..
								"if fname ~= \"\" then\n"..
								"\tlineEdit"..idx..value..":setText(fname)\n"..
								"end\n"..
							"end)\n"
						else
							r = r.."qt.connect(SelectButton, \"clicked()\", function()\n"..
								"local fname = qt.dialog.get_existing_directory(\"Select Directory\", \"\")\n"..
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
	r = r.."\tlocal result = \"\"\n"

	-- create the function to be activated when the user pushes 'Run'
	forEachOrderedElement(t, function(idx, melement)
		if idx == "number" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tif lineEdit"..value..".text == \"inf\" then\n"
				if self[value] ~= math.huge then
					r = r.."\t\t\tresult = result..\"\\n\t"..value.." = math.huge,\"\n"
				end
				r = r.."\telseif not tonumber(lineEdit"..value..".text) then\n"
				r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value).." (\"..lineEdit"..value..".text..\") is not a number.\"\n"
				r = r.."\telseif tonumber(lineEdit"..value..".text) ~= "..self[value].." then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..lineEdit"..value..".text..\",\"\n"
				r = r.."\tend\n"
			end)
		elseif idx == "string" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tif lineEdit"..value..".text ~= \""..self[value].."\" then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \\\"\"..lineEdit"..value..".text..\"\\\",\"\n"
				r = r.."\tend\n"
			end)
		elseif idx == "boolean" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tlocal mvalue = "..tostring(self[value]).."\n"
				r = r.."\tif checkBox"..value..".checked ~= mvalue then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..tostring(checkBox"..value..".checked)..\",\"\n"
				r = r.."\tend\n"
			end)
		elseif idx == "Choice" then
			forEachOrderedElement(melement, function(_, value)
				if self[value].values then
					r = r.."\tlocal mvalue = tvalue"..value.."[combobox"..value..".currentIndex + 1]\n"
					r = r.."\tif tonumber(mvalue) then\n"
					r = r.."\t\tmvalue = tonumber(mvalue)\n"
					r = r.."\t\tif mvalue ~= "..self[value].default.." then \n"
					r = r.."\t\t\tresult = result..\"\\n\t"..value.." = \"..mvalue..".."\",\"\n"
					r = r.."\t\tend\n"
					r = r.."\telseif mvalue ~= \""..self[value].default.."\" then \n"
					r = r.."\t\tresult = result..\"\\n\t"..value.." = \\\"\"..mvalue..".."\"\\\",\"\n"
					r = r.."\tend\n"
				elseif self[value].step then
					r = r.."\tlocal mvalue = tonumber(lineEdit"..value..".text)\n"
					r = r.."\tif mvalue ~= "..self[value].default.. " then \n"
					r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..mvalue..".."\",\"\n"
					r = r.."\tend\n"
				else
					r = r.."\tif lineEdit"..value..".text == \"inf\" then\n"
					if self[value] ~= math.huge then
						r = r.."\t\tresult = result..\"\\n\t"..value.." = math.huge,\"\n"
					end
					r = r.."\telseif not tonumber(lineEdit"..value..".text) then\n"
					r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value).." (\"..lineEdit"..value..".text..\") is not a number.\"\n"
					r = r.."\telseif tonumber(lineEdit"..value..".text) ~= "..self[value].default.. " then \n"
					r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..lineEdit"..value..".text..\",\"\n"
					r = r.."\tend\n"
				end
			end)
		elseif idx == "Mandatory" then
			forEachOrderedElement(melement, function(_, value)
				r = r.."\tif lineEdit"..value..".text == \"inf\" then\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = math.huge,\"\n"
				r = r.."\telseif lineEdit"..value..".text == \"\" then\n"
				r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value).." is a mandatory argument.\"\n"
				r = r.."\telseif not tonumber(lineEdit"..value..".text) then\n"
				r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value).." (\"..lineEdit"..value..".text..\") is not a number.\"\n"
				r = r.."\telse\n"
				r = r.."\t\tresult = result..\"\\n\t"..value.." = \"..lineEdit"..value..".text..\",\"\n"
				r = r.."\tend\n"
			end)
		else -- named table
			r = r.."\tlocal iresult = \"\"\n"
			forEachOrderedElement(melement[1], function(midx, mvalue)
				if midx == "number" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tif lineEdit"..idx..value..".text == \"inf\" then\n"
						if self[idx][value] ~= math.huge then
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = math.huge,\"\n"
						end
						r = r.."\telseif not tonumber(lineEdit"..idx..value..".text) then\n"
						r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value).." (\"..lineEdit"..idx..value..".text..\") is not a number.\"\n"
						r = r.."\telseif tonumber(lineEdit"..idx..value..".text) ~= "..self[idx][value].." then\n"
						r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..lineEdit"..idx..value..".text..\",\"\n"
						r = r.."\tend"
					end)
				elseif midx == "boolean" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tlocal mvalue = "..tostring(self[idx][value])
						if value == "active" then

							r = r.."\tif groupbox"..idx..".checked ~= mvalue then\n"
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..tostring(groupbox"..idx..".checked)..\",\"\n"
							r = r.."\tend\n"
						else
							r = r.."\tif checkBox"..idx..value..".checked ~= mvalue then\n"
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..tostring(checkBox"..idx..value..".checked)..\",\"\n"
							r = r.."\tend\n"
						end
					end)
				elseif midx == "string" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tif lineEdit"..idx..value..".text ~= \""..self[idx][value].."\" then\n"
						r = r.."\tiresult = iresult..\"\\n\t\t"..value.." = \\\"\"..lineEdit"..idx..value..".text..\"\\\",\"\n"
						r = r.."\tend\n"
					end)
				elseif midx == "Choice" then
					forEachOrderedElement(mvalue, function(_, value)
						if self[idx][value].values then
							r = r.."\tlocal mvalue = tvalue"..idx..value.."[combobox"..idx..value..".currentIndex + 1]\n"
							r = r.."\tif tonumber(mvalue) then\n"
							r = r.."\t\tmvalue = tonumber(mvalue)\n"
							r = r.."\t\tif mvalue ~= "..self[idx][value].default.." then \n"
							r = r.."\t\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..mvalue..".."\",\"\n"
							r = r.."\t\tend\n"
							r = r.."\telseif mvalue ~= \""..self[idx][value].default.."\" then \n"
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \\\"\"..mvalue..".."\"\\\",\"\n"
							r = r.."\tend\n"
						elseif self[idx][value].step then
							r = r.."\tlocal mvalue = tonumber(lineEdit"..idx..value..".text)\n"
							r = r.."\tif mvalue ~= "..self[idx][value].default.. " then \n"
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..mvalue..".."\",\"\n"
							r = r.."\tend\n"
						else
							r = r.."\tif lineEdit"..idx..value..".text == \"inf\" then\n"
							if self[idx][value] ~= math.huge then
								r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = math.huge,\"\n"
							end
							r = r.."\telseif not tonumber(lineEdit"..idx..value..".text) then\n"
							r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value, idx).." is not a number (\"..lineEdit"..idx..value..".text..\").\"\n"
							r = r.."\telseif tonumber(lineEdit"..idx..value..".text) ~= "..self[idx][value].default.. " then \n"
							r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..lineEdit"..idx..value..".text..\",\"\n"
							r = r.."\tend\n"
						end
					end)
				elseif midx == "Mandatory" then
					forEachOrderedElement(mvalue, function(_, value)
						r = r.."\tif lineEdit"..idx..value..".text == \"inf\" then\n"
						r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = math.huge,\"\n"
						r = r.."\telseif lineEdit"..idx..value..".text == \"\" then\n"
						r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value, idx).." is a mandatory argument.\"\n"
						r = r.."\telseif not tonumber(lineEdit"..idx..value..".text) then\n"
						r = r.."\t\tmerr = \"Error: ".._Gtme.stringToLabel(value, idx).." is not a number (\"..lineEdit"..idx..value..".text..\").\"\n"
						r = r.."\telse\n"
						r = r.."\t\tiresult = iresult..\"\\n\t\t"..value.." = \"..lineEdit"..idx..value..".text..\",\"\n"
						r = r.."\tend\n"
					end)
				end
			end)
			r = r.."\tif iresult ~= \"\" then\n"
			r = r.."\t\tiresult = string.sub(iresult, 0, string.len(iresult) - 1)\n"
			r = r.."\t\tresult = result..\"\\n\t"..idx.." = {\"\n"
			r = r.."\t\tresult = result..iresult\n"
			r = r.."\t\tresult = result..\"\\n\t},\"\n"
			r = r.."\tend\n"
		end
	end)
	r = r.."\tlocal header = \"-- Model instance automatically built by TerraME (\"..os.date(\"%c\")..\")\"\n"

	if package then
		r = r.."\theader = header..\"\\n\\nimport(\\\""..package.."\\\")\"\n"
	end

	r = r.."\tif result ~= \"\" then\n"
	r = r.."\t\tresult = \"\\n\\ninstance = "..modelName.."{\"..string.sub(result, 0, string.len(result) - 1)\n"
	r = r.."\t\tresult = result..\"\\n}\\n\\n\"\n\n"
	r = r.."\telse\n"
	r = r.."\t\tresult = \"\\n\\ninstance = "..modelName.."{}\\n\\n\"\n"
	r = r.."\tend\n"

	r = r.."\tlocal execute = \"instance:run()\"\n"
	r = r..[[
	local getFile = function(prefix)
		local fname = prefix.."-instance.lua"
		local count = 0
		while isFile(fname) do
			count = count + 1
			fname = prefix.."-instance-"..count..".lua"
		end
		return fname
	end]]
	r = r.."\n\n"

	if package then
		r = r.."\tlocal mfile = io.open(getFile(\""..modelName.."\"), \"w\")\n"
		r = r.."\tmfile:write(header..result..execute)\n"
		r = r.."\theader = \"\\n\\nif not isLoaded(\\\""..package.."\\\") then  import(\\\""..package.."\\\") end\"\n"
		r = r.."\tresult = header..result\n"
		r = r.."\tmfile:close()\n"
	end

	r = r..[[
	if not merr then
		-- BUG**: http://lists.gnu.org/archive/html/libqtlua-list/2013-05/msg00004.html
		local _
		_, merr = pcall(function() load(result)() end)
		if merr then
			local merr2 = string.match(merr, ":[0-9]*:.*")
			if merr2 then
				local merr3 = string.gsub(merr2, ":[0-9]*: ", "")
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
		local _, merr = pcall(function() load(execute)() end)
		if merr then
			qt.dialog.msg_critical("The simulation stopped with an internal error: "..merr)
		end
	end]]

	r = r.."\nend\n\n"
	r = r.."qt.connect(RunButton, \"clicked()\", mfunction)\n\n"
	
	r = r.."Dialog:show()\n"
	r = r.."local result = Dialog:exec()\n\n"
	-- why not changing to Dialog:show()?
	-- http://stackoverflow.com/questions/12068317/calling-qapplicationexec-after-qdialogexec
	r = r.."clean()"
	
	-- add the lines below for debug purposes...
	-- file = io.open(modelName.."-configure.lua", "w")
	-- file:write(r)
	-- file:close()
	-- os.execute("terrame "..modelName.."-configure.lua")

	-- ... and remove the line below
	load(r)()
end

