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

-- @header Some basic and useful functions to handle file names.

--- Second order function to transverse all the Layers of a given Project,
-- applying a given function to each of its Layer. If any of the function calls returns
-- false, forEachLayer() stops and returns false, otherwise it returns true.
-- @arg project A Project.
-- @arg _sof_ A user-defined function that takes a Layer as argument.
-- It can optionally have a second argument with a positive number representing the position of
-- the Layer in the vector of Cells. If it returns false when processing a given Layer,
-- forEachLayer() stops and does not process any other Cell.
-- @usage
-- import("terralib")
--
-- project = Project{
--     file = "emas-count.tview",
--     clean = true,
--     firebreak = filePath("firebreak_lin.shp", "terralib"),
--     cover = filePath("accumulation_Nov94May00.tif", "terralib"),
--     river = filePath("River_lin.shp", "terralib"),
--     limit = filePath("Limit_pol.shp", "terralib")
--}
--
-- forEachLayer(project, function(layer, index)
--     print(index.."\t"..layer.rep)
-- end)
function forEachLayer(project, _sof_)
	if type(project) ~= "Project" then
		incompatibleTypeError(1, "Project", project)
	elseif type(_sof_) ~= "function" then
		incompatibleTypeError(2, "function", _sof_)
	end

	for i, abstractLayer in pairs(project.layers) do
		local layer = Layer{project = project, name = abstractLayer:getTitle()}
		if _sof_(layer, i) == false then return false end
	end

	return true
end

--- Return the file name removing its path.
-- @arg path A string with the file with the path.
-- @usage import("terralib")
-- print(getFileNameWithExtension("/my/path/file.txt")) -- "file.txt"
function getFileNameWithExtension(path)
	local _, fileNameWithExtension, _ = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	
	return fileNameWithExtension
end

--- Return the file name removing its extension.
-- @arg fileNameWithExtension A string with the file with extension.
-- @usage import("terralib")
-- print(removeFileExtension("file.txt")) -- "file"
function removeFileExtension(fileNameWithExtension)
	local _, _, fileName = string.find(fileNameWithExtension, "^(.*)%.[^%.]*$")
	
	return fileName
end

--- Return the file name removing its path and extension.
-- @arg path A string with the file path.
-- @usage import("terralib")
-- print(getFileName("/my/path/file.txt")) -- "file"
function getFileName(path) 
	local fileNameWithExtension = getFileNameWithExtension(path)
	local fileName = removeFileExtension(fileNameWithExtension)
	
	return fileName
end	

--- Split the path, file name, and extension from a given string.
-- @arg path A string with the file path.
-- @usage import("terralib")
-- print(getFilePathAndNameAndExtension("/my/path/file.txt")) -- "/my/path/", "file", "txt"
function getFilePathAndNameAndExtension(path)
	local filePath, fileNameWithExtension, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	local fileName = removeFileExtension(fileNameWithExtension)
	
	return filePath, fileName, extension
end

--- Return the file extension from a fiven file path.
-- @arg path A string with the file with extension.
-- @usage import("terralib")
-- print(getFileExtension("/my/path/file.txt")) -- "txt"
function getFileExtension(path)
	local _, _, extension = getFilePathAndNameAndExtension(path)

	return extension
end

--- Return the directory of a file given its path.
-- @arg path A string with the file path.
-- @usage import("terralib")
-- print(getFileDir("/my/path/file.txt")) -- "/my/path"
function getFileDir(path)
	local dir, _, _ = getFilePathAndNameAndExtension(path)
	
	return dir
end

