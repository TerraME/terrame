-- if some error occurs in this script along execution tests,
-- possibly the version number has changed and it is necessary
-- to create the respective directory in the package repository
-- (www.terrame.org/packages).

sci = Directory(sessionInfo().path.."/packages/sci")

local packages = _Gtme.downloadPackagesList()

if not packages or #packages == 0 then
	print("Could not download package list for version "..sessionInfo().version)
end

local package = "sci_"..packages["sci"].version..".zip"

if isDirectory(tostring(sci)) or isFile(tostring(sci)) then
	os.execute("mv "..sci.." "..tostring(sci).."2")
	_Gtme.installRecursive(package)
	_Gtme.uninstall("sci")
	os.execute("mv "..tostring(sci).."2 "..sci)
else
	_Gtme.installRecursive(package)
	_Gtme.uninstall("sci")
end

