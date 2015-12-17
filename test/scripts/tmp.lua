file = io.open("mytmp.lua", "w")

file:write("print(tmpDir())")
file:close()

os.execute("terrame mytmp.lua > resp.txt")
rmFile("mytmp.lua")

file = io.open("resp.txt")
value = file:read()

-- check if the folder does not exist
if value == nil then
	print("Could not read the directory's name.")
elseif isDir(value) then
	print("Directory '"..value.."' should not exist!")
else
	print("Directory does not exist.")
end

file:close()
rmFile("resp.txt")

