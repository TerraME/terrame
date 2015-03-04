
return {
	getConfig = function(unitTest)
		local cf
		pcall(function() cf = getConfig() end)

		if not cf then
			print([[
===============================================================
Error: The environment was not correctly configured to execute
database tests. Please create file 'config.lua' in the current 
directory and set the database access variables. For example:

user = "root"
password = ""
host = "localhost"
port = 3306
dbType = "mysql"
===============================================================]])
			os.exit()
		else
			unitTest:assert_not_nil(cf.dbType)
			unitTest:assert_not_nil(cf.password)
		end
	end
}
