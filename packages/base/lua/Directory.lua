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
local function checkInvalidChars(fullpath)
	local invalidChars = string.gsub(fullpath, "[^\34\42\60\62\63\124]", "")
	if #invalidChars ~= 0 then
		customError("Directory path '"..fullpath.."' contains invalid character '"..invalidChars.."'.")
	end
end

Directory_ = {
	type_ = "Directory",
	--- Return a table with the file attributes corresponding to filepath (or nil followed by an error
	-- message in case of error). If the second optional argument is given, then only the value of the
	-- named attribute is returned. The attributes are
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
	-- @usage Directory(packageInfo("base").path.."data"):attributes("mode")
	attributes = function(self, attributename)
		optionalArgument(1, "string", attributename)

		return lfs.attributes(self.fullpath, attributename)
	end,
	--- Create the directory.
	-- Returns true if the operation was successful. In case of error, it returns nil plus an error string.
	-- @usage -- DONTRUN
	-- dir = Directory("mydirectory")
	-- dir:create()
	-- print(dir)
	--
	-- tmpDir = Directory{
	--    name = "mytmpdir_XXX",
	--    tmp = true
	-- }
	--
	-- print(tmpDir)
	--
	-- dir:delete()
	-- tmpDir:delete()
	create = function(self)
		return lfs.mkdir(self.fullpath)
	end,
	--- Remove an existing directory. It removes all internal files and directories
	-- recursively. If the directory does not exist or it cannot be removed,
	-- this function stops with an error.
	-- @usage dir = Directory("mydirectory")
	-- dir:create()
	-- dir:delete()
	delete = function(self)
		if not self:exists() then
			resourceNotFoundError("directory", self.fullpath)
		end

		local result = os.execute("rm -rf \""..self.fullpath.."\"")

		return result == true or customError(result)
	end,
	--- Return whether the directory is stored in the computer.
	-- @usage if Directory("C:\\TerraME\\bin"):exists() then
	--     print("is dir")
	-- end
	exists = function(self)
		return isDirectory(self.fullpath)
	end,
	--- Return a vector of strings with the content of the directory.
	-- @arg all A boolean value indicating whether hidden files should be returned. The default value is false.
	-- @usage files = packageInfo("base").data:list()
	--
	-- forEachElement(files, function(_, file)
	--     print(file)
	-- end)
	list = function(self, all)
		optionalArgument(1, "boolean", all)

		if not self:exists() then
			resourceNotFoundError("directory", self.fullpath)
		end

		if all == nil then all = false end

		local command

		if all then
			command = "ls -a1 \""..self.fullpath.."\""
		else
			command = "ls -1 \""..self.fullpath.."\""
		end

		local result = runCommand(command)

		return result
	end,
	--- Return the name of a given directory. It is the last directory name given a full path.
	-- @usage print(Directory("c:\\terrame\\bin\\"):name()) -- "bin"
	--
	-- print(Directory("/usr/local/bin"):name()) -- "bin"
	name = function(self)
		local _, name = string.match(self.fullpath, "(.-)([^\\/]-)$")
		return name
	end,
	--- Return the path of a given directory. In windows, it converts all backslashes into slashes.
	-- @usage print(Directory("c:\\terrame\\bin\\"):path()) -- "c:/terrame"
	--
	-- print(Directory("/usr/local/bin"):path()) -- "/usr/local"
	path = function(self)
		local path = string.match(self.fullpath, "(.-)([^\\/]-)$")
		return path
	end,
	--- Return a relative path given a small path.
	-- @arg path A Directory or a string with a shorter path.
	-- @usage d = Directory("/my/full/path")
	-- print(d:relativePath("/my")) -- "full/path"
	relativePath = function(self, path)
		if type(path) == "Directory" then
			path = tostring(path)
		end

		return string.sub(self.fullpath, string.len(path) + 2)
	end,
	--- Set the current working directory with the directory path.
	-- Returns true in case of success or nil plus an error string.
	-- @usage -- DONTRUN
	-- Directory("c:\\tests"):setCurrentDir()
	setCurrentDir = function(self)
		return lfs.chdir(self.fullpath)
	end
}

metaTableDirectory_ = {
	__index = Directory_,
	__tostring = function(self)
		return self.fullpath
	end,
	--- Concatenate the directory. It adds a path separator whenever needed.
	-- @arg value A string or an object that can be concatenated.
	-- @usage path = sessionInfo().path.."data"
	__concat = function(self, value)
		local s = sessionInfo().separator

		if type(self) == "Directory" then
			self = self.fullpath

			if not belong(string.sub(tostring(value), 1, 1), {s, "/"}) then
				value = "/"..value
			end
		elseif type(value) == "Directory" then
			value = value.fullpath
		end


		return self..value
	end
}

--- An abstract representation of a directory. When creating an instance of a Directory,
-- it does not mean that such directory will be created. It only verifies if the
-- directory has a valid name. Directory also converts backslashes into slashes to
-- make sure paths are represented in the same way in different operational systems.
-- This type provides a set of operations to handle directories,
-- such as to verify if it exists, create, and remove.
-- @arg data.name A mandatory string with the directory name. It can also be a File. In
-- this case, its value will be File:path(). This argument can be used
-- as a first argument in a call to Directory without named arguments, as
-- in the example below.
-- @arg data.tmp An optional boolean value indicating whether the directory should be
-- temporary. The default value is false.
-- When creating a temporary directory, the end of its name must contain X's,
-- which are going to be replaced by random alphanumerical values in order to
-- guarantee that the created directory will not replace a previous one.
-- @usage -- DONTRUN
-- dir = Directory("/my/path/my_dir")
--
-- tmpDir = Directory{
--    name = "mytmpdir_XXX",
--    tmp = true
-- }
--
-- print(tmpDir)
function Directory(data)
	if type(data) == "string" then
		data = {name = data}
	elseif type(data) == "File" then
		data = {name = data:path()}
	elseif data and type(data) ~= "table" then
		customError(incompatibleTypeMsg(1, "string", data))
	end

	verifyNamedTable(data)
	defaultTableValue(data, "tmp", false)
	verifyUnnecessaryArguments(data, {"name", "tmp"})

	if data.tmp then
		defaultTableValue(data, "name", ".terrametmp_XXXXX")
	end

	mandatoryTableArgument(data, "name", "string")

	data.fullpath = data.name
	data.name = nil

	checkInvalidChars(data.fullpath)

	if not (data.fullpath:match("\\") or data.fullpath:match("/")) then
		if data.fullpath == "." then data.fullpath = "" end

		data.fullpath = currentDir()..data.fullpath
	end

	data.fullpath = _Gtme.makePathCompatibleToAllOS(data.fullpath)

	if sessionInfo().system == "windows" then
		data.fullpath = replaceLatinCharacters(data.fullpath) --SKIP
	end

	if data.fullpath:sub(-1) == "/" then
		data.fullpath = data.fullpath:sub(1, -2)
	end

	setmetatable(data, metaTableDirectory_)

	if data.tmp == true then
		if not rawget(_Gtme, "tmpdirectory__") then
			_Gtme.tmpdirectory__ = {}
		end

		local cmd = runCommand("mktemp -d \""..data.fullpath.."\"")[1]
		table.insert(_Gtme.tmpdirectory__, data)

		if sessionInfo().system == "windows" then
			data.fullpath = replaceLatinCharacters(cmd) --SKIP
		else
			data.fullpath = cmd --SKIP
		end
	end

	if isFile(data.fullpath) then
		customError("'"..data.fullpath.."' is a file, and not a directory.")
	end

	return data
end

