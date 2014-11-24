
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
-- file it refers to. To obtain information about the link itself, see FileSystem:symlinkattributes().
-- @param filepath A string with the file path.
-- @param attributename A string with the name of the attribute to be read.
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
attributes = function(filepath, attributename)
	return lfs.attributes(filepath, attributename)
end

--- Change the current working directory to the given path.
-- Returns true in case of success or nil plus an error string.
-- @param path A string with the path.
-- @usage chdir("c:\\tests")
chdir = function(path)
	return lfs.chdir(path)
end

--- Return a string with the current working directory or nil plus an error string.
-- @usage currentdir()
currentdir = function()
	return lfs.currentdir()
end

--- Return whether a given string represents a file stored in the computer.
-- @param file A string.
-- @usage isfile("C:\\file.txt")
isfile = function(file)
	return os.rename(file, file)
end

--- Return the files in a given directory.
-- @param folder A string describing a folder.
-- @usage dir("C:\\")
dir = function(folder)
	local s = sessionInfo().separator
	local command
	if s == "\\" then
		command = "dir "..folder.." /b > "..folder..s..".aux.txt"
	elseif s == "/" then
		command = "ls -1 "..folder.." 2> /dev/null".." > "..folder..s..".aux.txt"
	end
	
	if os.execute(command) ~= nil then 
		local file = io.open(folder..s..".aux.txt", "r")
		local fileTable = {}
		for line in file:lines() do
			if line ~= "README.txt" and line ~= ".svn" and line ~= ".aux.txt.swp" and line ~= "aux.txt" then 
				fileTable[#fileTable + 1] = line
			end
		end

		file:close()
		os.execute("rm "..folder..s..".aux.txt")
		return fileTable
	else
		customError(folder.." is not a folder or is empty or does not exist.")
	end
end	

--- Lua iterator over the entries of a given directory. Each time the iterator is called with dir_obj 
-- it returns a directory entry's name as a string, or nil if there are no more entries. You can 
-- also iterate by calling dir_obj:next(), and explicitly close the directory before the iteration 
-- finished with dir_obj:close(). Raises an error if path is not a directory.
-- @param path A string with the path.
-- @usage iter, dir_obj = lfsdir(path)
lfsdir = function(path)
	return lfs.dir(path)
end

--- Lock a file or a part of it. This function works on open files; the file handle should be 
-- specified as the first argument. The optional arguments start and length can be used to specify a 
-- starting point and its length; both should be numbers.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @param fh A string with the file path.
-- @param mode A string representing the mode. It could be either r (for a read/shared lock) or w 
-- (for a write/exclusive lock).
-- @usage lock(filehandle, "r")
lock = function(fh, mode)
	return lfs.lock(fh, mode)
end

--- Create a lockfile (called lockfile.lfs) in path if it does not exist and returns the lock. If the 
-- lock already exists checks if it's stale, using the second parameter (default for the second 
-- parameter is INT_MAX, which in practice means the lock will never be stale. To free the the lock call 
-- lock:free(). 
-- In case of any errors it returns nil and the error message. In particular, if the lock exists and is 
-- not stale it returns the "File exists" message.
-- @param path A string with the path.
-- @usage lock_dir(path)
lock_dir = function(path)
	return lfs.lock_dir
end

--- Create a new directory. The argument is the name of the new directory.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @param path A string with the path.
-- @usage mkdir(dirname)
mkdir = function(path)
	return lfs.mkdir(path)
end

--- Remove an existing directory. The argument is the name of the directory.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @param path A string with the path.
-- @usage rmdir(dirname)
rmdir = function(path)
	return lfs.rmdir(path)
end

--- Set the writing mode for a file. Returns true 
-- followed the previous mode string for the file, or nil followed by an error string in case of errors. 
-- On non-Windows platforms, where the two modes are identical, setting the mode has no effect, and the 
-- mode is always returned as binary.
-- @param filepath A string with the file path.
-- @param mode A string that can be either "binary" or "text". 
-- @usage setmode(file, "text")
setmode = function(filepath, mode)
	return lfs.setmode(filepath, mode)
end

--- Identical to FileSystem:attributes() except that it obtains information about the link itself (not the file it 
-- refers to). On Windows this function does not yet support links, and is identical to FileSystem:attributes().
-- @param filepath A string with the file path.
-- @param attributename A string with the name of the attribute to be read.
-- @usage symlinkattributes(filepath, "size")
symlinkattributes = function(filepath, attributename)
	return lfs.symlinkattributes(filepath, attributename)
end

--- Set access and modification times of a file. This function is a bind to utime function.
-- Times are provided in seconds (which should be generated with Lua 
-- standard function os.time). If the modification time is omitted, the access time provided is used; 
-- if both times are omitted, the current time is used.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @param filepath A string with the file name.
-- @param atime The new access time (in seconds).
-- @param mtime The new modification time (in seconds).
-- @usage touch(filepath)
touch = function(filepath, atime, mtime)
	return lfs.touch(filepath, atime, mtime)
end

--- Unlock a file or a part of it. This function works on open files; the file handle should be specified 
-- as the first argument. The optional arguments start and length can be used to specify a starting point 
-- and its length; both should be numbers.
-- Returns true if the operation was successful; in case of error, it returns nil plus an error string.
-- @param fh A string with the file path.
-- @usage unlock(filehandle)
unlock = function(fh)
	return lfs.unlock(fh)
end

