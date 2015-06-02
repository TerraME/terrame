--@header Functions to handle files and directories.
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
-- @usage attributes(filepath, "mode")
function attributes(filepath, attributename)
	mandatoryArgument(1, "string", filepath)
	optionalArgument(2, "string", attributename)

	return lfs.attributes(filepath, attributename)
end

--- Change the current working directory to the given path.
-- Returns true in case of success or nil plus an error string.
-- @arg path A string with the path.
-- @usage chDir("c:\\tests")
function chDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.chdir(path)
end

--- Return a string with the current working directory or nil plus an error string.
-- @usage currentDir()
function currentDir()
	return lfs.currentdir()
end

--- Return the files in a given directory.
-- @arg folder A string describing a folder.
-- @arg all A boolean value indicating whether hidden files should be returned. The default value is false.
-- @usage dir("C:\\")
function dir(folder, all)
	mandatoryArgument(1, "string", folder)
	optionalArgument(2, "boolean", all)

	if all == nil then all = false end

	local s = sessionInfo().separator
	local command = "dir "..folder.." /b"

	if s == "/" then
		if all then
			command = "ls -a1 "..folder.." 2> /dev/null"
		else
			command = "ls -1 "..folder.." 2> /dev/null"
		end
	end

	local result = runCommand(command)

	if not result or not result[1] then
		customError(folder.." is not a folder or is empty or does not exist.")
	else
		if all and result[#result] == "zzzz999.txt" then
			table.remove(result, #result)
		end
		return result
	end
end	

--- Return whether a given string represents a file stored in the computer.
-- @arg file A string.
-- @usage isFile("C:\\file.txt")
function isFile(file)
	mandatoryArgument(1, "string", file)

	return os.rename(file, file)
end

--- Identical to FileSystem:attributes() except that it obtains information about the link itself
-- (not the file it refers to). On Windows this function does not yet support links, and is identical
-- to FileSystem:attributes().
-- @arg filepath A string with the file path.
-- @arg attributename A string with the name of the attribute to be read.
-- @usage linkAttributes(filepath, "size")
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
-- @usage filehandle = io.open("test.txt", "w+")
-- lock(filehandle, "r")
function lock(fh, mode)
	mandatoryArgument(1, "userdata", fh)
	mandatoryArgument(2, "string", mode)

	return lfs.lock(fh, mode)
end

--- Create a lockfile (called lockfile.lfs) in path if it does not exist and returns the lock. If the
-- lock already exists checks if it's stale, using the second argeter (default for the second
-- argeter is INT_MAX, which in practice means the lock will never be stale. To free the the lock call
-- lock:free().
-- In case of any errors it returns nil and the error message. In particular, if the lock exists and is
-- not stale it returns the "File exists" message.
-- @arg path A string with the path.
-- @usage lockDir(path)
function lockDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.lock_dir
end

--- Create a new directory. The argument is the name of the new directory.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg path A string with the path.
-- @usage mkDir(dirname)
function mkDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.mkdir(path)
end

--- Remove an existing directory. The argument is the name of the directory.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg path A string with the path.
-- @usage rmDir(dirname)
function rmDir(path)
	mandatoryArgument(1, "string", path)

	return lfs.rmdir(path)
end

--- Execute a system command and return its output. Each line of the output will be a position
-- in the returned table.
-- @arg command A command.
-- @arg number A number indicating the output to be captured. The default value is 1 (standard output).
-- It is also possible to use 2, to capture the error output.
-- @usage runCommand("dir")
function runCommand(command, number)
	mandatoryArgument(1, "string", command)
	optionalArgument(2, "number", number)

	if number == nil then number = 1 end
	
	command = command.." "..number.."> zzzz999.txt"
	
	os.execute(command)
	local file = io.open("zzzz999.txt", "r")
	local fileTable = {}
	for line in file:lines() do
		fileTable[#fileTable + 1] = line
	end

	io.close(file)
	os.execute("rm zzzz999.txt")
	return fileTable
end

--- Set the writing mode for a file. Returns true
-- followed the previous mode string for the file, or nil followed by an error string in case of errors.
-- On non-Windows platforms, where the two modes are identical, setting the mode has no effect, and the
-- mode is always returned as binary.
-- @arg filepath A file handle with the file to be locked.
-- @arg mode A string that can be either "binary" or "text".
-- @usage setMode(file, "text")
function setMode(filepath, mode)
	mandatoryArgument(1, "userdata", filepath)
	mandatoryArgument(2, "string", mode)

	return lfs.setmode(filepath, mode)
end

--- Set access and modification times of a file. This function is a bind to utime function.
-- Times are provided in seconds (which should be generated with Lua
-- standard function os.time). If the modification time is omitted, the access time provided is used;
-- if both times are omitted, the current time is used.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @arg filepath A string with the file name.
-- @arg atime The new access time (in seconds).
-- @arg mtime The new modification time (in seconds).
-- @usage touch(filepath)
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
-- @usage filehandle = io.open("test.txt", "w+")
-- unlock(filehandle)
function unlock(fh)
	mandatoryArgument(1, "userdata", fh)

	return lfs.unlock(fh)
end

