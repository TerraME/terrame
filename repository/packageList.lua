-- Create the package list for TerraME. This script must run 
-- within a folder where all zip files for the available packages
-- are stored. The output file should be stored in 
-- www.terrame.org/packages/version together with the available packages.
-- To use it, just run 'terrame packageList.lua' within this directory.

result = {}

_Gtme.printNote("Unzipping files")
forEachFile(".", function(file)
	if file:extension() == "zip" then
		os.execute("unzip -q "..file:name())
	end
end)

_Gtme.printNote("Processing packages")
forEachDirectory(".", function(dir)
	print("Processing "..dir:name())
	info = packageInfo(dir:name())

	info.data    = nil
	info.path    = nil
	info.contact = nil
	info.date    = nil
	info.license = nil

	result[file] = info
end)

file = io.open("packages.lua", "w")
file:write("-- List of packages for TerraME "..packageInfo().version)
file:write("\n-- "..os.date("Created in %d %B %Y"))
file:write("\n\nreturn "..vardump(result))
file:close()

_Gtme.printNote("Cleaning folder")
forEachDirectory(".", function(dir)
	dir:delete()
end)

_Gtme.printNote("packages.lua was successfully created")

