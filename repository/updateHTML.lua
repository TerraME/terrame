-- Script to update the documentation of base and terralib
-- available at terrame.org.
-- 'terrame -color doc-base-terralib.lua'

-----------------------------------------------------------------------
local host = "ssh.dpi.inpe.br:"
local doc = "/home/www/terrame/packages/doc"
local repository = "/home/www/terrame/packages/"..sessionInfo().version
-----------------------------------------------------------------------

_Gtme.printNote("Updating documentation for version "..sessionInfo().version)

_Gtme.printNote("Creating documentation of packages")
local packages = _Gtme.downloadPackagesList()

local list = ""

forEachOrderedElement(packages, function(name, data)
	_Gtme.print("\027[00;37;43mCreating documentation of package '"..name.."'\027[00m")

	if data.version ~= packageInfo(name).version then
		customError("Version of package '"..name.."' ("..packageInfo(name).version..
		    ") is different from the repository ("..data.version.."). Please update it.")
	end

	list = list..name.." "
--	os.execute("terrame -color -package "..name.." -doc")
end)


list = list.."base terralib"

_Gtme.print("\027[00;37;43mCreating documentation of package 'base'\027[00m")
--os.execute("terrame -color -doc")

_Gtme.print("\027[00;37;43mCreating documentation of package 'terralib'\027[00m")
--os.execute("terrame -color -package terralib -doc")

_Gtme.printNote("Copying files to terrame.org")

scpDoc = "scp -r "..list.." "..host..doc

_Gtme.print("\027[00;37;43m"..scpDoc.."\027[00m")


pkgDir = Directory(sessionInfo().path.."packages")

pkgDir:setCurrentDir()

os.execute(scpDoc)
