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

function _Gtme.packageManager()
	require("qtluae")

	local dialog = qt.new_qobject(qt.meta.QDialog)
	dialog.windowTitle = "TerraME"

	local externalLayout = qt.new_qobject(qt.meta.QVBoxLayout)

	local internalLayout = qt.new_qobject(qt.meta.QGridLayout)
	internalLayout.spacing = 8

	qt.ui.layout_add(dialog, externalLayout)

	-- packages list
	comboboxPackages = qt.new_qobject(qt.meta.QComboBox)

	local s = sessionInfo().separator

	local function buildComboboxPackages(default)
		comboboxPackages:clear()
		local pos = 0
		local index = 0
		forEachFile(sessionInfo().path..s.."packages", function(file)
			if file == "luadoc" then return end
	
			qt.combobox_add_item(comboboxPackages, file)
	
			if file == default then
				index = pos
			else
				pos = pos + 1
			end
		end)
		return index
	end

	local index = buildComboboxPackages("base")

	aboutButton = qt.new_qobject(qt.meta.QPushButton)
	aboutButton.text = "About"
	qt.connect(aboutButton, "clicked()", function()
		local msg = "Package "..comboboxPackages.currentText
		local info = packageInfo(comboboxPackages.currentText)

		msg = msg.."\n\nVersion: "..info.version
		msg = msg.."\n\nDate: "..info.date
		msg = msg.."\n\nAuthors: "..info.authors
		msg = msg.."\n\nContact: "..info.contact

		if info.url then
			msg = msg.."\n\nURL: "..info.url
		end

		qt.dialog.msg_about(msg) -- _information ??
	end)

	docButton = qt.new_qobject(qt.meta.QPushButton)
	docButton.text = "Documentation"
	qt.connect(docButton, "clicked()", function()
		showDoc(comboboxPackages.currentText)
	end)

	label = qt.new_qobject(qt.meta.QLabel)
	label.text = "Package:"
	qt.ui.layout_add(internalLayout, label, 0, 0)
	qt.ui.layout_add(internalLayout, comboboxPackages, 0, 1)
	qt.ui.layout_add(internalLayout, aboutButton, 0, 2)
	qt.ui.layout_add(internalLayout, docButton, 0, 3)

	-- models list + execute button
	comboboxModels = qt.new_qobject(qt.meta.QComboBox)

	label = qt.new_qobject(qt.meta.QLabel)
	label.text = "Model:"

	buildButton = qt.new_qobject(qt.meta.QPushButton)
	buildButton.text = "Build"
	qt.connect(buildButton, "clicked()", function()
		local msg = "terrame -package "..comboboxPackages.currentText..
		            " -interface "..comboboxModels.currentText
		os.execute(msg)
	end)

	qt.ui.layout_add(internalLayout, label, 1, 0)
	qt.ui.layout_add(internalLayout, comboboxModels, 1, 1)
	qt.ui.layout_add(internalLayout, buildButton, 1, 2)

	-- examples list + execute button
	comboboxExamples = qt.new_qobject(qt.meta.QComboBox)

	label = qt.new_qobject(qt.meta.QLabel)
	label.text = "Example:"

	runButton = qt.new_qobject(qt.meta.QPushButton)
	runButton.text = "Run"
	qt.connect(runButton, "clicked()", function()
		local msg = "terrame -package "..comboboxPackages.currentText..
		            " -example "..comboboxExamples.currentText
		os.execute(msg)
	end)

	qt.ui.layout_add(internalLayout, label, 2, 0)
	qt.ui.layout_add(internalLayout, comboboxExamples, 2, 1)
	qt.ui.layout_add(internalLayout, runButton, 2, 2)

	-- what to do when a new package is selected
	local function selectPackage()
		comboboxExamples:clear()
		comboboxModels:clear()

		local models = _Gtme.findModels(comboboxPackages.currentText)

		comboboxModels.enabled = #models > 1
		buildButton.enabled = #models > 0

		forEachElement(models, function(_, value)
			qt.combobox_add_item(comboboxModels, value)
		end)

		local ex = _Gtme.findExamples(comboboxPackages.currentText)

		comboboxExamples.enabled = #ex > 1
		runButton.enabled = #ex > 0

		forEachElement(ex, function(_, value)
			qt.combobox_add_item(comboboxExamples, value)
		end)
	end

	comboboxPackages:setCurrentIndex(index)

	qt.connect(comboboxPackages, "activated(int)", selectPackage)
	-- bottom buttons
	buttonsLayout = qt.new_qobject(qt.meta.QHBoxLayout)

	installButton = qt.new_qobject(qt.meta.QPushButton)
	installButton.minimumSize = {150, 28}
	installButton.maximumSize = {160, 28}
	installButton.text = "Install new package"
	qt.ui.layout_add(buttonsLayout, installButton)

	local m2function = function()
		local fname = qt.dialog.get_open_filename("Select Package", "", "*.zip")
		if fname ~= "" then
			local pkg = installPackage(fname)

			if type(pkg) == "string" then
				qt.dialog.msg_information("Package '"..pkg.."' successfully installed.")
				local index = buildComboboxPackages(pkg)
				comboboxPackages:setCurrentIndex(index)
				selectPackage()
			else
				qt.dialog.msg_critical("File "..fname.." could not be installed.")
			end
		end
	end
	qt.connect(installButton, "clicked()", m2function)

	quitButton = qt.new_qobject(qt.meta.QPushButton)
	quitButton.minimumSize = {100, 28}
	quitButton.maximumSize = {110, 28}
	quitButton.text = "Quit"
	qt.ui.layout_add(buttonsLayout, quitButton)

	local m2function = function() dialog:done(0) end
	qt.connect(quitButton, "clicked()", m2function)

	qt.ui.layout_add(externalLayout, internalLayout)
	qt.ui.layout_add(externalLayout, buttonsLayout, 3, 0)

	selectPackage()
	local result = dialog:exec()
end

