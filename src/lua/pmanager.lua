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

function packageManager()
	require__("qtluae")

	local Dialog = qt.new_qobject(qt.meta.QDialog)
	Dialog.windowTitle = "TerraME"

	local ExternalLayout = qt.new_qobject(qt.meta.QGridLayout)
	ExternalLayout.spacing = 8

	qt.ui.layout_add(Dialog, ExternalLayout)

	-- packages list
	comboboxPackages = qt.new_qobject(qt.meta.QComboBox)

	local s = sessionInfo().separator

	local index
	local pos = 0
	forEachFile(sessionInfo().path..s.."packages", function(file)
		if file == "luadoc" then return end

		qt.combobox_add_item(comboboxPackages, file)

		if file == "base" then
			index = pos
		else
			pos = pos + 1
		end
	end)

	AboutButton = qt.new_qobject(qt.meta.QPushButton)
	AboutButton.text = "About"
	qt.connect(AboutButton, "clicked()", function()
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
	qt.ui.layout_add(ExternalLayout, label, 0, 0)
	qt.ui.layout_add(ExternalLayout, comboboxPackages, 0, 1)
	qt.ui.layout_add(ExternalLayout, AboutButton, 0, 2)
	qt.ui.layout_add(ExternalLayout, docButton, 0, 3)

	-- models list + execute button
	comboboxModels = qt.new_qobject(qt.meta.QComboBox)

	label = qt.new_qobject(qt.meta.QLabel)
	label.text = "Model:"

	BuildButton = qt.new_qobject(qt.meta.QPushButton)
	BuildButton.text = "Build"
	qt.connect(BuildButton, "clicked()", function()
		local msg = "terrame -package "..comboboxPackages.currentText..
		            " -model "..comboboxModels.currentText
		os.execute(msg)
	end)

	qt.ui.layout_add(ExternalLayout, label, 1, 0)
	qt.ui.layout_add(ExternalLayout, comboboxModels, 1, 1)
	qt.ui.layout_add(ExternalLayout, BuildButton, 1, 2)

	-- examples list + execute button
	comboboxExamples = qt.new_qobject(qt.meta.QComboBox)

	label = qt.new_qobject(qt.meta.QLabel)
	label.text = "Example:"

	RunButton = qt.new_qobject(qt.meta.QPushButton)
	RunButton.text = "Run"
	qt.connect(RunButton, "clicked()", function()
		local msg = "terrame -package "..comboboxPackages.currentText..
		            " -example "..comboboxExamples.currentText
		os.execute(msg)
	end)

	qt.ui.layout_add(ExternalLayout, label, 2, 0)
	qt.ui.layout_add(ExternalLayout, comboboxExamples, 2, 1)
	qt.ui.layout_add(ExternalLayout, RunButton, 2, 2)

	-- what to do when a new package is selected
	qt.connect(comboboxPackages, "activated(int)", function(_, value)
		comboboxExamples:clear()
		comboboxModels:clear()

		local models = findModels(comboboxPackages.currentText)

		comboboxModels.enabled = #models > 1
		BuildButton.enabled = #models > 0

		forEachElement(models, function(_, value)
			qt.combobox_add_item(comboboxModels, value)
		end)

		local ex = findExamples(comboboxPackages.currentText)

		comboboxExamples.enabled = #ex > 1
		RunButton.enabled = #ex > 0

		forEachElement(ex, function(_, value)
			qt.combobox_add_item(comboboxExamples, value)
		end)
	end)

	comboboxPackages:setCurrentIndex(index)

	-- quit button
	ButtonsLayout = qt.new_qobject(qt.meta.QHBoxLayout)
	QuitButton = qt.new_qobject(qt.meta.QPushButton)
	QuitButton.minimumSize = {100, 28}
	QuitButton.maximumSize = {110, 28}
	QuitButton.text = "Quit"
	qt.ui.layout_add(ButtonsLayout, QuitButton)

	local m2function = function() Dialog:done(0) end
	qt.connect(QuitButton, "clicked()", m2function)

	ListView = qt.new_qobject(qt.meta.QListView)

	--qt.ui.layout_add(ExternalLayout, ListView)
	qt.ui.layout_add(ExternalLayout, ButtonsLayout, 3, 0)

	Dialog:exec()
end

