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

-- @header Functions to handle files and directories.
-- Most of the functions bellow are taken from LuaFileSystem 1.6.2.
-- Copyright Kepler Project 2003 (http://www.keplerproject.org/luafilesystem).

--- Return a table with the file attributes corresponding to filepath (or nil followed by an error
-- message in case of error). If the second optional argument is given, then only the value of the
-- named attribute is returned (this use is equivalent to lfs.attributes(filepath).aname, but the
-- table is not created and only one attribute is retrieved from the O.S.). The attributes are
-- described as follows; attribute mode is a string, all the others are numbers, and the time
-- related attributes use the same time reference of os.time.
-- This function uses stat internally thus if the given filepath is a symbolic link, it is followed
-- (if it points to another link the chain is followed recursively) and the information is about the
-- file it refers to. To obtain information about the link itself, see FileSystem:linkAttributes().
-- @arg filepath A string with the file path.
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
-- @usage attributes(packageInfo("base").path, "mode")
function attributes(filepath, attributename)
	mandatoryArgument(1, "string", filepath)
	optionalArgument(2, "string", attributename)

	return lfs.attributes(filepath, attributename)
end

--- Change the current working directory to the given path.
-- Returns true in case of success or nil plus an error string.
-- @arg path A string with the path.
-- @usage -- DONTRUN
-- chDir("c:\\tests")
function chDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.chdir(path)
end

--- Return a string with the current working directory or nil plus an error string.
-- @usage cdir = currentDir()
-- print(cdir)
function currentDir()
	return lfs.currentdir()
end

--- Returns true if the operating system is Windows, otherwise returns false.
-- @usage if isWindowsOS() then
--     print("is windows")
-- else
--     print("not windows")
-- end
function isWindowsOS()
	if sessionInfo().separator == "/" then
		return false
	end
	
	return true
end

--- Return the files in a given directory.
-- @arg directory A string describing a directory.
-- @arg all A boolean value indicating whether hidden files should be returned. The default value is false.
-- @usage files = dir(".")
--
-- forEachFile(files, function(file)
--     print(file)
-- end)
function dir(directory, all)
	mandatoryArgument(1, "string", directory)
	optionalArgument(2, "boolean", all)

	if all == nil then all = false end
	
	local command 

	if all then
		command = "ls -a1 \""..directory.."\""
	else
		command = "ls -1 \""..directory.."\""
	end

	local result = runCommand(command)

	if not result or not result[1] then
		customError(directory.." is not a directory or is empty or does not exist.")
	end

	return result
end	

--- Return whether a given string represents a directory stored in the computer.
-- @arg path A string.
-- @usage if isDir("C:\\TerraME\\bin") then
--     print("is dir")
-- end
function isDir(path)
	mandatoryArgument(1, "string", path)

	if string.sub(path, -1) == "/" then
		path = string.sub(path, 1, -2)
	end	

	if lfs.attributes(path:gsub("\\$", ""), "mode") == "directory" then
		return true
	end
	
	return false
end

--- Return whether a given string represents a file stored in the computer.
-- A directory is also considered a file.
-- @arg file A string.
-- @usage if isFile("C:\\file.txt") then
--     print("is file")
-- end
function isFile(file)
	mandatoryArgument(1, "string", file)

	local fopen = io.open(file, "r")
	
	if fopen then
		fopen:close()
		return true	
	end
	
	return false
end

--- Identical to FileSystem:attributes() except that it obtains information about the link itself
-- (not the file it refers to). On Windows this function does not yet support links, and is identical
-- to FileSystem:attributes().
-- @arg filepath A string with the file path.
-- @arg attributename A string with the name of the attribute to be read.
-- @usage -- DONTRUN
-- linkAttributes(filepath, "size")
function linkAttributes(filepath, attributename)
	mandatoryArgument(1, "string", filepath)
	optionalArgument(2, "string", attributename)

	return lfs.symlinkattributes(filepath, attributename)
end

--- Lock a file or a part of it. This function works on open files; the file handle should be
-- specified as the first argument. The optional arguments start and length can be used to specify a
-- starting point and its length; both should be numbers.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg fh A file handle with the file to be locked.
-- @arg mode A string representing the mode. It could be either r (for a read/shared lock) or w
-- (for a write/exclusive lock).
-- @usage filehandle = io.open(filePath("agents.csv", "base"), "r")
-- lock(filehandle, "r")
-- unlock(filehandle)
-- @see FileSystem:unlock
function lock(fh, mode)
	mandatoryArgument(1, "userdata", fh)
	mandatoryArgument(2, "string", mode)

	return lfs.lock(fh, mode)
end

--- Create a lockfile (called lockfile.lfs) in path if it does not exist and returns the lock. 
-- If the lock already exists checks if it's stale, using the second argeter (default for the 
-- second argeter is INT_MAX, which in practice means the lock will never be stale.
-- In case of any errors it returns nil and the error message. In particular, if the lock
-- exists and is not stale it returns the "File exists" message.
-- @arg path A string with the path.
-- @usage ld = lockDir(packageInfo("base").path)
function lockDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.lock_dir
end

--- Create a new directory. The argument is the name of the new directory.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg path A string with the path.
-- @usage -- DONTRUN
-- mkDir("mydirectory")
function mkDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.mkdir(path)
end

--- Remove an existing directory. It removes all internal files and directories
-- recursively. If the directory does not exist or it cannot be removed,
-- this function stops with an error.
-- @arg path A string with the path. The function will automatically add
-- quotation marks in the beginning and in the end of this argument in order
-- to avoid problems related to empty spaces in the string. Therefore,
-- this string must not contain quotation marks.
-- @usage mkDir("mydirectory")
--
-- rmDir("mydirectory")
function rmDir(path)
	mandatoryArgument(1, "string", path)

	if string.find(path, "\"") then
		customError("Argument #1 should not contain quotation marks.")
	elseif not isDir(path) then
		resourceNotFoundError(1, path)
	end

	local result = os.execute("rm -rf \""..path.."\"")

	if result ~= true then
		customError(result) -- SKIP
	end
end

--- Remove an existing file. If the file does not exist or it cannot be removed,
-- this function stops with an error. Directories cannot be removed using
-- this function. If the file to be removed is a shapefile, it also removes
-- the respective dbf, shx, and prj files if they exist.
-- @arg file A string with the file to be removed. It might contain a path if needed.
-- The function will automatically add
-- quotation marks in the beginning and in the end of this argument in order
-- to avoid problems related to empty spaces in the string. Therefore,
-- this string must not contain quotation marks.
-- @usage file = io.open("myfile.txt", "w")
-- file:close()
--
-- rmFile("myfile.txt")
function rmFile(file)
	mandatoryArgument(1, "string", file)

	if string.find(file, "\"") then
		customError("Argument #1 should not contain quotation marks.")
	elseif not isFile(file) then
		resourceNotFoundError(1, file)
	end

	local result = os.execute("rm -f \""..file.."\"")

	if result ~= true then
		if result == nil then -- SKIP
			result = "Could not remove file '"..file.."'." -- SKIP
		end

		customError(tostring(result)) -- SKIP
	end

	if string.endswith(file, ".shp") then
		local dbf = string.sub(file, 1, -4).."dbf"
		local shx = string.sub(file, 1, -4).."shx"
		local prj = string.sub(file, 1, -4).."prj"

		if isFile(dbf) then rmFile(dbf) end
		if isFile(shx) then rmFile(shx) end
		if isFile(prj) then rmFile(prj) end
	end
end

--- Execute a system command and return its output. It returns two tables. 
-- The first one contains each standard output line as a position.
-- The second one contains  each error output line as a position.
-- @arg command A command.
-- @usage result, error = runCommand("dir")
function runCommand(command)
	mandatoryArgument(1, "string", command)

	local result, err = cpp_runcommand(command)

	local function convertToTable(str)
		local t = {}
		local i = 0
		local v
		local oldv = 0
		while true do
			i, v = string.find(str, "\n", i + 1) -- find 'next' newline
			if i == nil then break end
			table.insert(t, string.sub(str, oldv + 1, v - 1))
			oldv = v
		end

		return t
	end

	result = convertToTable(result)
	err = convertToTable(err)

	return result, err
end

--- Create a temporary directory and return its name.
-- If this function is used without any argument, the directory will be deleted
-- in the end of the simulation. Otherwise, the modeler will need to remove the
-- directory manually if necessary.
-- If the directory was deleted between two calls of this function without any
-- argument then it is created again. 
-- @arg directory Name of the directory to be created. It might contain a path 
-- to a given directory
-- where the new one will be created. The end of the string might contain X's,
-- which are going to be replaced by random alphanumerica values in order to
-- guarantee that the created directory will not replace a previous one.
-- @usage tmpf = tmpDir("mytmpdir_XXX")
-- print(tmpf)
--
-- rmDir(tmpf)
function tmpDir(directory)
	if directory then
		optionalArgument(1, "string", directory)
		return runCommand("mktemp -d "..directory)[1]
	elseif not _Gtme.tmpdirectory__ then
		_Gtme.tmpdirectory__ = runCommand("mktemp -d .terrametmp_XXXXX")[1] -- SKIP
	elseif not isDir(_Gtme.tmpdirectory__) then
		os.execute("mkdir ".._Gtme.tmpdirectory__)
	end

	return _Gtme.tmpdirectory__
end

--- Set access and modification times of a file. This function is a bind to utime function.
-- Times are provided in seconds (which should be generated with Lua
-- standard function os.time). If the modification time is omitted, the access time provided is used;
-- if both times are omitted, the current time is used.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg filepath A string with the file name.
-- @arg atime The new access time (in seconds).
-- @arg mtime The new modification time (in seconds).
-- @usage touch(packageInfo("base").path, 0, 0)
function touch(filepath, atime, mtime)
	mandatoryArgument(1, "string", filepath)
	mandatoryArgument(2, "number", atime)
	mandatoryArgument(3, "number", mtime)

	return lfs.touch(filepath, atime, mtime)
end

--- Unlock a file or a part of it. This function works on open files; the file handle should be
-- specified as the first argument. The optional arguments start and length can be used to specify
-- a starting point and its length; both should be numbers. It returns true if the operation was
-- successful. In case of error, it returns nil plus an error string.
-- @arg fh A file handle with the file to be locked.
-- @usage filehandle = io.open(filePath("agents.csv", "base"), "r")
-- lock(filehandle, "r")
-- unlock(filehandle)
-- @see FileSystem:lock
function unlock(fh)
	mandatoryArgument(1, "userdata", fh)

	return lfs.unlock(fh)
end

