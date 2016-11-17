sci = Directory(sessionInfo().path.."/packages/sci")

local packages = _Gtme.downloadPackagesList()
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

