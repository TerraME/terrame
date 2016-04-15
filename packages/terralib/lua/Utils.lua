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

