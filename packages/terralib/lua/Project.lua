-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

Project_ = {
	type_ = "Project"
}

metaTableProject_ = {
	__index = Project_, __tostring = _Gtme.tostring
}

--- Project is a concept to describe all the data to be used by a given model.
-- Data can be stored in different sources, with different formats and access.
-- A project organises the data into a set of layers, storing all the information
-- related to each data source internally. After that, the user can refer to the
-- data sets only using the respective layer name.
-- TerraME allows the modeler to create a Project from scratch or load one already
-- created in another software of TerraLib family.
-- @arg data.file A base::File or a string with the file name to be used. If the
-- file does not exist then it will be created. If it exists then it will be opened.
-- If this name does not ends with ".tview", this extension will be added to the name
-- of the file.
-- @arg data.author An optional string with the name of the Project's author.
-- @arg data.title An optional string with the title of the Project.
-- @arg data.clean An optional boolean value indicating whether the argument file should be cleaned
-- if it already exists.
-- The default value is false.
-- @arg data.... Names of layers to be created from files. Each argument that has a string as value
-- and does not belong to the arguments above will
-- be converted into a layer. The name of the attribute will be used as
-- layer name and its value as file name where data is stored. It can be a shapefile or a tiff.
-- @usage -- DONTRUN
-- import("terralib")
--
-- proj1 = Project{
--     file = "myproject.tview"
-- }
--
-- proj2 = Project{
--     file = "itaituba.tview",
--     clean = true,
--     deforestation = filePath("desmatamento_2000.tif", "terralib"),
--     altimetria = filePath("altimetria.tif", "terralib"),
--     localidades = filePath("Localidades_pt.shp", "terralib"),
--     roads = filePath("Rodovias_lin.shp", "terralib"),
--     setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
-- }
--
function Project(data)
	verifyNamedTable(data)

	if type(data.file) == "string" then
		data.file = File(data.file)
	end

	mandatoryTableArgument(data, "file", "File")

	if data.file:extension() ~= "tview" then
		data.file = File(data.file..".tview")
	end

	defaultTableValue(data, "clean", false)
	defaultTableValue(data, "title", "No title")
	defaultTableValue(data, "author", "No author")

	data.layers = {}

	if data.file:exists() and data.clean then
		local proj = Project{file = data.file}
		data.file:delete()

		if data.file:exists() then
			customError("File '"..data.file.."' could not be removed.") -- SKIP
		end

		if data.author == "No author" and proj.author ~= "No author" then
			data.author = proj.author
		end

		if data.title == "No title" and proj.title ~= "No title" then
			data.title = proj.title
		end
	end

	if data.file:exists() then
		TerraLib().openProject(data, data.file)
	else
		TerraLib().createProject(data, data.layers)
	end

	setmetatable(data, metaTableProject_)

	local layers = {}

	forEachElement(data, function(idx, value)
		if not belong(idx, {"clean", "file", "author", "title", "layers"}) then
			if type(value) == "string" then
				value = File(value)
			end

			if type(value) ~= "File" then
				data.file:deleteIfExists()

				incompatibleTypeError(idx, "File", value)
			end

			if value:exists() then
				layers[idx] = Layer{
					project = data,
					name = idx,
					file = value
				}
			else
				data.file:deleteIfExists()
				customError("Value of argument '"..idx.."' ('"..value.."') is not a valid file name.")
			end
		end
	end)

	forEachElement(layers, function(idx, layer)
		data[idx] = layer
	end)

	return data
end

