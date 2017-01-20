-- Script to update the package's repository.
-- Copy the packages to be updated to this directory and run
-- 'terrame -color updatePackages.lua'

---------------------------------------------------------------
local host = "ssh.dpi.inpe.br:"
local doc = "/home/www/terrame/packages/doc"
local repository = "/home/www/terrame/packages/2.0.0-beta-5"
---------------------------------------------------------------

_Gtme.printNote("Finding packages to be uploaded")
local newPackages = {}

forEachFile(".", function(file)
	if file:extension() ~= "zip" then return end

	local package
	local name = file:name()

	xpcall(function() package = string.sub(name, 1, string.find(name, "_") - 1) end, function()
		_Gtme.printError(file.." is not a valid file name for a TerraME package.")
		os.exit(1)
	end)

	os.execute("unzip -q "..name)
	local version = getLuaFile(package.."/description.lua").version

	_Gtme.print("Package '"..package.."' version '"..version.."' will be added to the repository")

	newPackages[package] = version
end)

_Gtme.printNote("Running documentation and tests")

forEachDirectory(".", function(dir)
	if dir:name() == "log" then return end
	local package = dir:name()

	local pkgPath = sessionInfo().path.."/packages/"..package
	local rollback = false

	if isDirectory(pkgPath) then
		_Gtme.printWarning("Moving '"..package.."' as it is installed")
		os.execute("mv "..pkgPath.." "..pkgPath.."-bkp")
		rollback = true
	end

	_Gtme.print("Documenting '"..package.."'")
    local command = "terrame -package "..package.." -doc > log/doc-"..package..".log"
	os.execute(command)

	_Gtme.print("Testing '"..package.."'")

    command = "terrame -package "..package.." -test > log/test-"..package..".log"
	os.execute(command)

	if rollback then
		_Gtme.printWarning("Rolling back to installed version of '"..package.."'")
		os.execute("mv "..pkgPath.."-bkp "..pkgPath)
	end

	dir:delete()
end)

_Gtme.printNote("Downloading packages")
local packages = _Gtme.downloadPackagesList()

local downloaded = {}

forEachOrderedElement(packages, function(name, data)
	local pkgfile = name.."_"..data.version..".zip"

	if newPackages[name] then
		if _Gtme.verifyVersionDependency(data.version, ">=", newPackages[name]) then
			_Gtme.printError("Skipping '"..pkgfile.."' (updating repository with an older version?)")
		else
			_Gtme.print("Skipping '"..pkgfile.."' (new version available)")
		end
	else
		_Gtme.print("Downloading '"..pkgfile.."'")
		_Gtme.downloadPackage(pkgfile)
		downloaded[pkgfile] = true
	end
end)

_Gtme.printNote("Creating package list")
dofile("packageList.lua")

_Gtme.printNote("Removing downloaded packages")

forEachOrderedElement(downloaded, function(idx)
	_Gtme.print("Removing '"..idx.."'")
	File(idx):delete()
end)

_Gtme.printNote("Copying files to terrame.org")

scpPackages = "scp "

forEachFile(".", function(file)
	if file:extension() ~= "zip" then return end
	scpPackages = scpPackages..file:name().." "
end)

scpPackages = scpPackages.."packages.lua "..host..repository

_Gtme.print("\027[00;37;43m"..scpPackages.."\027[00m")
os.execute(scpPackages)

scpDoc = "scp -r "

forEachFile(".", function(file)
	if file:extension() ~= "zip" then return end

	local name = file:name()
	os.execute("unzip -q "..name)
end)

forEachDirectory(".", function(dir)
	if dir:name() == "log" then return end
	scpDoc = scpDoc..dir:name().." "
end)

scpDoc = scpDoc..host..doc
_Gtme.print("\027[00;37;43m"..scpDoc.."\027[00m")
os.execute(scpDoc)

forEachDirectory(".", function(dir)
	if dir:name() == "log" then return end
	dir:delete()
end)

_Gtme.printNote("Updloading process finished")
