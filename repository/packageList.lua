-- Create the package list for TerraME. This script must run 
-- within a folder where all zip files for the available packages
-- are stored. The output file should be stored in 
-- www.terrame.org/packages together with the available packages.
-- To use it, just run 'terrame packageList.lua' within this directory.

result = {}

forEachFile(".", function(file)
	if string.endswith(file, ".zip") then
		os.execute("unzip -q "..file)
	end
end)

forEachFile(".", function(file)
	if isDir(file) then
		info = packageInfo(file)

		result[file] = info
	end
end)

file = io.open("packages.lua", "w")
file:write("return "..vardump(result))
file:close()

forEachFile(".", function(file)
	if isDir(file) then
		rmDir(file)
	end
end)
