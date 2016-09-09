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


Directory_ = {
	type_ = "Directory",
	--- Return a table with the file attributes corresponding to filepath (or nil followed by an error
	-- message in case of error). If the second optional argument is given, then only the value of the
	-- named attribute is returned (this use is equivalent to lfs.attributes(filepath).aname, but the
	-- table is not created and only one attribute is retrieved from the O.S.). The attributes are
	-- described as follows; attribute mode is a string, all the others are numbers, and the time
	-- related attributes use the same time reference of os.time.
	-- This function uses stat internally thus if the given filepath is a symbolic link, it is followed
	-- (if it points to another link the chain is followed recursively) and the information is about the
	-- file it refers to.
	-- @arg attributename A string with the name of the attribute to be read.
	-- @tabular attributename
	-- Attribute & Description \
	-- "dev" &
	-- on Unix systems, this represents the device that the inode resides on. On Windows
	-- systems, represents the drive number of the disk containing the file \
	-- "ino" &
	-- on Unix systems, this represents the inode number. On Windows systems this has no meaning \
	-- "mode" &
	-- string representing the associated protection mode (the values could be file, directory,
	-- link, socket, named pipe, char device, block device or other) \
	-- "nlink" &
	-- number of hard links to the file \
	-- "uid" &
	-- user-id of owner (Unix only, always 0 on Windows) \
	-- "gid" &
	-- group-id of owner (Unix only, always 0 on Windows) \
	-- "rdev" &
	-- on Unix systems, represents the device type, for special file inodes. On Windows systems
	-- represents the same as dev \
	-- "access" &
	-- time of last access \
	-- "modification" &
	-- time of last data modification \
	-- "change" &
	-- time of last file status change \
	-- "size" &
	-- file size, in bytes \
	-- "blocks" &
	-- block allocated for file; (Unix only) \
	-- "blksize" &
	-- optimal file system I/O blocksize; (Unix only)
	-- @usage Directory(packageInfo("base").path):attributes("mode")
	attributes = function(self, attributename)
		optionalArgument(1, "string", attributename)

		return lfs.attributes(self.name, attributename)
	end,
	--- Create a new directory. The argument is the name of the new directory.
	-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
	-- @usage -- DONTRUN
	-- Directory("mydirectory"):create()
	create = function(self)
		return lfs.mkdir(self.name)
	end,
	--- Remove an existing directory. It removes all internal files and directories
	-- recursively. If the directory does not exist or it cannot be removed,
	-- this function stops with an error. The function will automatically add
	-- quotation marks in the beginning and in the end of the directory name in order
	-- to avoid problems related to empty spaces in the string.
	-- @usage dir = Directory("mydirectory")
	-- dir:create()
	-- dir:delete()
	delete = function(self)
		if not self:exists() then
			resourceNotFoundError("directory", self.name)
		end

		local result = os.execute("rm -rf \""..self.name.."\"")

		return result == true or customError(result)
	end,
	--- Return whether a given string represents a directory stored in the computer.
	-- @usage if Directory("C:\\TerraME\\bin"):exists() then
	--     print("is dir")
	-- end
	exists = function(self)
		if lfs.attributes(self.name:gsub("\\$", ""), "mode") == "directory" then
			return true
		end

		return false
	end,
	--- Return the files in a given directory.
	-- @arg all A boolean value indicating whether hidden files should be returned. The default value is false.
	-- @usage files = Directory(packageInfo("base").data):list()
	--
	-- forEachFile(files, function(file)
	--     print(file)
	-- end)
	list = function(self, all)
		optionalArgument(1, "boolean", all)

		if all == nil then all = false end

		local command

		if all then
			command = "ls -a1 \""..self.name.."\""
		else
			command = "ls -1 \""..self.name.."\""
		end

		local result = runCommand(command)

		if not result or not result[1] then
			customError(self.name.." is not a directory or is empty or does not exist.")
		end

		return result
	end,
	--- Change the current working directory to the given path.
	-- Returns true in case of success or nil plus an error string.
	-- @usage -- DONTRUN
	-- Directory("c:\\tests"):setCurrentDir()
	setCurrentDir = function(self)
		return lfs.chdir(self.name)
	end
}

metaTableDirectory_ = {
	__index = Directory_,
	__tostring = function(self)
		return self.name
	end
}

--- An abstract representation of Directory. This type provide access to additional
-- directory operations and directory attributes.
-- @arg data.name A mandatory string with the directory name.
-- @usage dir = Directory("/my/path/my_dir")
function Directory(data)
	mandatoryArgument(1, "string", data)

	if data:find("\"") then
			customError("Argument #1 should not contain quotation marks.")
	end

	if not (data:match("\\") or data:match("/")) then
		data = currentDir()..sessionInfo().separator..data
	end

	data = _Gtme.makePathCompatibleToAllOS(data)

	if data:sub(-1) == "/" then
		data = data:sub(1, -2)
	end

	data = {name = data}

	setmetatable(data, metaTableDirectory_)

	return data
end
