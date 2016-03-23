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
--          Rodrigo Avancini
--#########################################################################################

function getFileNameWithExtension(path)
	local _, fileNameWithExtension, _ = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	
	return fileNameWithExtension
end

function removeFileExtension(fileNameWithExtension)
	local _, _, fileName = string.find(fileNameWithExtension, "^(.*)%.[^%.]*$")
	
	return fileName
end

function getFileName(path) 
	local fileNameWithExtension = getFileNameWithExtension(path)
	local fileName = removeFileExtension(fileNameWithExtension)
	
	return fileName
end	

function getFilePathAndNameAndExtension(path)
	local filePath, fileNameWithExtension, extension = string.match(path, "(.-)([^\\/]-%.?([^%.\\/]*))$")
	local fileName = removeFileExtension(fileNameWithExtension)
	
	return filePath, fileName, extension
end

function getFileExtension(path)
	local _, _, extension = getFilePathAndNameAndExtension(path)

	return extension
end

function getFileDir(path)
	local dir, _, _ = getFilePathAndNameAndExtension(path)
	
	return dir
end

function decodeUri(str)
	str = string.gsub(str, "+", " ")
	str = string.gsub(str, "%%(%x%x)",
			function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub(str, "\r\n", "\n")
	  
	return str	
end

function encodeUri(str)
	if (str) then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w %-%_%.%~])",
				function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	
	return str
end
