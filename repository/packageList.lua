-- Create the package list for TerraME. This script must run 
-- within a folder where all zip files for the available packages
-- are stored. The output file should be stored in 
-- www.terrame.org/packages/version together with the available packages.
-- To use it, just run 'terrame packageList.lua' within this directory.

result = {}

_Gtme.printNote("Unzipping files")
forEachFile(".", function(file)
	if string.endswith(file, ".zip") then
		os.execute("unzip -q "..file)
	end
end)

_Gtme.printNote("Processing packages")
forEachFile(".", function(file)
	if isDir(file) then
		print("Processing "..file)
		info = packageInfo(file)

		info.data    = nil
		info.path    = nil
		info.contact = nil
		info.date    = nil
		info.license = nil

		result[file] = info
	end
end)

file = io.open("packages.lua", "w")
file:write("-- List of packages for TerraME "..packageInfo().version)
file:write("\n-- "..os.date("Created in %d %B %Y"))
file:write("\n\nreturn "..vardump(result))
file:close()

_Gtme.printNote("Cleaning folder")
forEachFile(".", function(file)
	if isDir(file) then
		rmDir(file)
	end
end)

_Gtme.printNote("packages.lua was successfully created")
