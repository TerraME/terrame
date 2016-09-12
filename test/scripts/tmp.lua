file = io.open("mytmp.lua", "w")

file:write("print(Directory{tmp = true}:create())")
file:close()

os.execute("terrame mytmp.lua > resp.txt")
File("mytmp.lua"):delete()

file = io.open("resp.txt")
value = file:read()

-- check if the directory does not exist
if value == nil then
	print("Could not read the directory's name.")
elseif Directory(value):exists() then
	print("Directory '"..value.."' should not exist!")
else
	print("Directory does not exist.")
end

file:close()
File("resp.txt"):delete()

