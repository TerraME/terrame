-- Script to test TerraME basic functionalities (-test, -doc, -build, and so on).
-- To use it, just run 'terrame run.lua' within this directory.
--
-- Pedro R. Andrade

local profiler = Profiler()

removeIfExists = function(_, value)
	if isDirectory(value) then
		_Gtme.print("Removing '"..value.."'")
		Directory(value):delete()
	elseif isFile(value) then
		_Gtme.print("Removing '"..value.."'")
		File(value):delete()
	end
end

printTestOutput = function(result, line)
	_Gtme.printNote("Printing the test output")

	count = 1

	forEachElement(result, function(_, value)
		if count == line then
			_Gtme.printError(count.."\t"..value)
		else
			_Gtme.printWarning(count.."\t"..value)
		end

		count = count + 1
	end)

	_Gtme.printNote("End of the test output")
end

profiler:start("RUN_")
local s = sessionInfo().separator

initialDir = Directory(sessionInfo().currentFile)
initialDir:setCurrentDir()

commands = getLuaFile("commands.lua")

show = false
time = false

if commands.show then show = true end
if commands.time then time = true end

commands.show = nil
commands.time = nil

directories = {
	log = {},
	packages = {},
	scripts = {},
	config = {}
}

forEachElement(directories, function(idx, value)
	if idx == "packages" then return end

	forEachFile(idx, function(file)
		value[file:name()] = false
	end)
end)

local baseDir = sessionInfo().path

tmpdirectory = _Gtme.Directory{name = ".terramerun_XXXXX", tmp = true}
_Gtme.printNote("Temporary directory created in "..tmpdirectory)

_Gtme.printNote("Testing installed packages")

_Gtme.printNote("Cleaning packages")
forEachDirectory("packages", function(dir)
	_Gtme.print("Cleaning '"..dir:name().."'")

	local mdir = baseDir.."packages"..s..dir

	if Directory(mdir):exists() then
		Directory(mdir):delete()
	end
end)

_Gtme.printNote("Removing files")
initialRemove = getLuaFile("remove.lua")

forEachElement(initialRemove.files, removeIfExists)

_Gtme.printNote("Copying packages")
forEachDirectory("packages", function(dir)
	_Gtme.print("Copying '"..dir:name().."'")

	os.execute("cp -pr \"packages"..s..dir:name().."\" \""..baseDir.."packages"..s..dir:name().."\"")	
end)

local report = {
	logerrors = 0,
	locallogerrors = 0,
	build = 0,
	builderrors = 0,
	localbuilderrors = 0,
	createdlogs = 0,
	commands = 0,
	commandserrors = 0,
	observererrors = 0,
	forgottenfiles = 0,
}

local function approximateLine(line)
	if not line then return 0 end
	
	if string.match(line, "configuration file")  then return 120 end
	if string.match(line, "maximum tolerance")   then return  20 end
	if string.match(line, "Logs")                then return 120 end
	if string.match(line, "Temporary")           then return 120 end
	if string.match(line, "Directory")           then return 160 end
	if string.match(line, "hour")                then return  22 end
	if string.match(line, "minute")              then return  24 end
	if string.match(line, "second")              then return  17 end
	if string.match(line, "MD5")                 then return  70 end
	if string.match(line, "log")                 then return 120 end
	if string.match(line, "Cannot open")         then return 320 end
	if string.match(line, "configuration file")  then return   3 end
	if string.match(line, "or is empty or does") then return 100 end
	if string.match(line, "does not exist")      then return 200 end
	if string.match(line, "projection should ")  then return 200 end
	if string.match(line, "is unnecessary%.")    then return 130 end
	if string.match(line, "'%.lua' extension")   then return 130 end
	if string.match(line, "Error: ")             then return  90 end
	if string.match(line, "File ")               then return 150 end
	if string.match(line, "directory")           then return 160 end
	if string.match(line, "such file")           then return 200 end
	if string.match(line, "In ")                 then return  50 end
	if string.match(line, "Error in")            then return  50 end
	if string.match(line, "Wrong execution")     then return  50 end
	if string.match(line, "%.terrame")           then return 120 end
	if string.match(line, "TME_PATH")            then return 120 end
	if string.match(line, "Lua 5")               then return   3 end
	if string.match(line, "attempt to")          then return  50 end
	if string.match(line, "Qt 5")                then return   3 end
	if string.match(line, "Qwt 6")               then return   3 end
	if string.match(line, "beta")                then return   2 end
	if string.match(line, "Processing")          then return   3 end
	if string.match(line, "Parsing")             then return   1 end
	if string.match(line, "Checking")            then return   8 end
	if string.match(line, "Testing")             then return  34 end
	if string.match(line, "Skipping")            then return  34 end
	if string.match(line, "Creating")            then return 120 end
	if string.match(line, "Building")            then return   8 end
	if string.match(line, "should contain only") then return   1 end

	return 0
end

forEachOrderedElement(commands, function(idx, group)
	_Gtme.printNote("Testing group '"..idx.."'")

	forEachOrderedElement(group, function(name, args)
		command = "terrame"

		directories.log[idx.."-"..name..".log"] = true

		if sessionInfo().system == "mac" then
			if idx == "observer" then
				if belong(name, {"chart", "clock", "map", "textscreen", "visualtable"}) then
					directories.scripts[args.script] = true
					_Gtme.printWarning("Skipping "..name)
					return
				end
			elseif idx == "package" then
				if belong(name, {"install"}) then
					directories.scripts[args.script] = true
					_Gtme.printWarning("Skipping "..name)
					return
				end
			end
		end

		if args.package then
			directories.packages[args.package] = true
			command = command.." -package "..args.package
		end

		if args.arg then
			command = command.." "..args.arg
		end

		if args.config then
			directories.config[args.config] = true
			command = command.." config"..s..args.config
		end

		if args.script then
			directories.scripts[args.script] = true
			command = command.." scripts"..s..args.script
		end

		if args.clean then
			command = command.." -clean"
		end

		if args.arg == "-test" and args.config then
			command = command.." 2> abc.txt"
		end

		_Gtme.print("Testing "..name)

		if show then
			_Gtme.printWarning(command)
		end

		profiler:start("TEST_RUN_")

		result, err = runCommand(command)

		local testFinalTime, difference = profiler:stop("TEST_RUN_")
		if time then
			local text = "Test executed in "..testFinalTime

			if difference > 60 then
				_Gtme.print("\027[00;37;41m"..text.."\027[00m")
			elseif difference > 10 then
				_Gtme.print("\027[00;37;43m"..text.."\027[00m")
			end
		end

		report.commands = report.commands + 1

		if err and #err > 0 then
			_Gtme.printError("Command '"..command.."' stopped with an error.")
			forEachElement(err, function(_, value)
				_Gtme.printError(value)
			end)

			report.commandserrors = report.commandserrors + 1
		end

		local lfilename = idx.."-"..name..".log"

		local logfile = File("log"..s..lfilename)
		if not logfile:exists() then
			_Gtme.printError("Creating log file '".._Gtme.makePathCompatibleToAllOS( "log"..s..lfilename.."'"))
			report.createdlogs = report.createdlogs + 1

			forEachElement(result, function(_, value)
				logfile:writeLine(_Gtme.makePathCompatibleToAllOS(value))
			end)

			logfile:close()
		else
			logfile:open()
			local resultfile = File(tmpdirectory..lfilename)

			forEachElement(result, function(_, value)
				value = _Gtme.makePathCompatibleToAllOS(value)
				resultfile:writeLine(value)
			end)
			
			local line = 1
			local logerror = false
			forEachElement(result, function(_, value)
				local distance = 0
				if value then
					distance = approximateLine(value)
				end

				value = _Gtme.makePathCompatibleToAllOS(value)

				local str = logfile.file:read()

				if not str then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: <end of file>")
					_Gtme.printError("Test: '"..value.."'.")
					printTestOutput(result)

					logerror = true
					report.logerrors = report.logerrors + 1
					return false
				end

				local distance2 = approximateLine(str)

				if distance < distance2 then
					distance = distance2
				end

				if levenshtein(str, value) > distance then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: '"..str.."'.")
					_Gtme.printError("Test:     '"..value.."'.")
					_Gtme.printError("The distance ("..levenshtein(str, value)..") was greater than the maximum ("..distance..").")
					printTestOutput(result, line)

					logerror = true
					report.logerrors = report.logerrors + 1
					return false
				end
				line = line + 1
			end)

			if not logerror then
				local v = logfile.file:read()
				if v then
					_Gtme.printError("Test ends but the logfile has string '"..v.."' (line "..line..").")
					printTestOutput(result, line)
					report.logerrors = report.logerrors + 1
				end
			end
		end
	end)
end)

if commands.build then
	_Gtme.printNote("Checking builds")

	forEachElement(commands.build, function(package)
		local version = packageInfo(package).version

		local mfile = package.."_"..version..".zip"

		_Gtme.print("Checking "..mfile)
		report.build = report.build + 1

		if not File(mfile):exists() then
			_Gtme.printError("File does not exist")
			report.builderrors = report.builderrors + 1
		else
			File(mfile):delete()
		end
	end)
end

_Gtme.printNote("Removing packages")
forEachDirectory("packages", function(pkg)
	_Gtme.uninstall(pkg:name())
end)

_Gtme.printNote("Testing from local directories")

File("config.lua"):copy("packages")
Directory(initialDir.."packages"):setCurrentDir()

_Gtme.printNote("Removing files")
localRemove = getLuaFile(".."..s.."remove.lua")

forEachElement(localRemove.files, removeIfExists)

forEachOrderedElement(commands, function(idx, group)
	_Gtme.printNote("Testing group '"..idx.."'")

	forEachOrderedElement(group, function(name, args)
		command = "terrame"

		if sessionInfo().system == "mac" then
			if idx == "sketch" then
				if name == "gis" then
					_Gtme.printWarning("Skipping "..name)
					return
				end
			end
		end

		if args.package and not belong(args.package, {"gis", "memory"}) then
			command = command.." -package "..args.package
		else
			return
		end

		if args.arg then
			command = command.." "..args.arg
		end

		if args.config then
			command = command.." .."..s.."config"..s..args.config
		end

		if args.script then
			command = command.." .."..s.."scripts"..s..args.script
		end

		if args.clean then
			command = command.." -clean"
		end

		_Gtme.print("Testing "..name)

		if show then
			_Gtme.printWarning(command)
		end

		profiler:start("TEST_RUN_")

		result, err = runCommand(command)

		local testFinalTime, difference = profiler:stop("TEST_RUN_")
		if time then
			local text = "Test executed in "..testFinalTime

			if difference > 60 then
				_Gtme.print("\027[00;37;41m"..text.."\027[00m")
			elseif difference > 10 then
				_Gtme.print("\027[00;37;43m"..text.."\027[00m")
			end
		end

		report.commands = report.commands + 1

		if err and #err > 0 then
			_Gtme.printError("Command '"..command.."' stopped with an error.")
			forEachElement(err, function(_, value)
				_Gtme.printError(value)
			end)

			report.commandserrors = report.commandserrors + 1
		end

		local lfilename = idx.."-"..name..".log"

		logfile = File(".."..s.."log"..s..lfilename)
		if not logfile:exists() then
			_Gtme.printError("Creating log file '".._Gtme.makePathCompatibleToAllOS("log"..s..lfilename.."'"))
			report.createdlogs = report.createdlogs + 1

			forEachElement(result, function(_, value)
				logfile:writeLine(value)
			end)
		else
			logfile:open()
			local resultfile = File(tmpdirectory..lfilename)

			forEachElement(result, function(_, value)
				value = _Gtme.makePathCompatibleToAllOS(value)
				resultfile:writeLine(value)
			end)
			
			local line = 1
			local logerror = false
			forEachElement(result, function(_, value)
				local distance = 0
				if value then
					distance = approximateLine(value)
				end

				value = _Gtme.makePathCompatibleToAllOS(value)

				local str = logfile.file:read()
				local distance2 = approximateLine(str)

				if distance > distance2 then
					distance = distance2
				end
				
				if not str then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: <end of file>")
					_Gtme.printError("Test: '"..value.."'.")
					printTestOutput(result)

					logerror = true
					report.logerrors = report.logerrors + 1
					return false
				end		

				str = _Gtme.makePathCompatibleToAllOS(str)
				value = _Gtme.makePathCompatibleToAllOS(value)
				
				if levenshtein(str, value) > distance then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: '"..str.."'.")
					_Gtme.printError("Test:     '"..value.."'.")
					_Gtme.printError("The distance ("..levenshtein(str, value)..") was greater than the maximum ("..distance..").")
					printTestOutput(result, line)

					report.locallogerrors = report.locallogerrors + 1
					logerror = true
					return false
				end
				line = line + 1
			end)

			if not logerror then
				local v = logfile.file:read()
				if v then
					_Gtme.printError("Test ends but the logfile has string '"..v.."' (line "..line..").")
					printTestOutput(result, line)
					report.logerrors = report.logerrors + 1
				end
			end
		end
	end)
end)

if commands.build then
	_Gtme.printNote("Checking builds")

	local files = {}

	forEachElement(commands.build, function(package)
		local version = getLuaFile(sessionInfo().initialDir.."packages/"..package.."/description.lua").version

		local mfile = package.."_"..version..".zip"

		_Gtme.print("Checking "..mfile)

		if not File(mfile):exists() then
			_Gtme.printError("File does not exist")
			report.localbuilderrors = report.localbuilderrors + 1
		else
			files[package] = mfile
		end
	end)

	_Gtme.printNote("Installing packages")

	forEachElement(files, function(package, mfile)
		os.execute("terrame -install "..mfile)

		local pkgdir = Directory(baseDir.."packages"..s..package)

		if pkgdir:exists() then
			pkgdir:delete()
		else
			_Gtme.printError("Package could not be installed")
			report.localbuilderrors = report.localbuilderrors + 1
		end

		File(mfile):delete()
	end)
end

File("config.lua"):delete()
Directory(initialDir..".."):setCurrentDir()

if commands.observer then
	_Gtme.printNote("Checking observers")

	forEachElement(commands.observer, function(_, mtable)
		local tmefile = string.gsub(mtable.script, "lua", "tme")
		_Gtme.print("Checking "..tmefile)

		directories.scripts[tmefile] = true

		tmefile = dofile(initialDir.."scripts"..s..tmefile)

		local names = {"x", "y", "width", "height"}

		forEachElement(tmefile, function(idx, value)
			if getn(value) > 4 then
				_Gtme.printError("Position "..idx.." has "..getn(value).." indexes. It should have only 4.")
				report.observererrors = report.observererrors + 1
			end

			forEachElement(names, function(_, mname)
				if not value[mname] then
					_Gtme.printError("Position "..idx.." does not have index "..mname..".")
					report.observererrors = report.observererrors + 1
				end
			end)
		end)

		local quantity = #tmefile

		if quantity ~= mtable.quantity then
			_Gtme.printError("Wrong quantity, got "..quantity..", expected "..mtable.quantity..".")
			report.observererrors = report.observererrors + 1
		end
	end)
end

_Gtme.printNote("Verifying directories")
forEachElement(directories, function(idx, value)
	_Gtme.print("Verifying "..idx)
	forEachElement(value, function(mvalue, occur)
		if not occur then
			report.forgottenfiles = report.forgottenfiles + 1
			_Gtme.printError(idx.."/"..mvalue.." is not used at least once in the tests.")
		end
	end)
end)

local finalTime = profiler:stop("RUN_")

_Gtme.printNote("Removing files")
forEachElement(initialRemove.files, removeIfExists)
forEachElement(localRemove.files, removeIfExists)

print("\nExecution test report:")

_Gtme.printNote("Tests were executed in "..finalTime..".")
_Gtme.printNote("Results were saved in '"..tmpdirectory.."'.")

if report.commandserrors == 0 then
	_Gtme.printNote("All "..report.commands.." commands were successfully executed.")
elseif report.commandserrors == 1 then
	_Gtme.printError("One out of "..report.commands.." commands was not successfully executed.")
else
	_Gtme.printError(report.commandserrors.." out of "..report.commands.." commands were not successfully executed.")
end

if report.builderrors == 0 then
	_Gtme.printNote("All "..report.build.." builds for installed packages were successfully executed.")
elseif report.builderrors == 1 then
	_Gtme.printError("One out of "..report.build.." builds for installed packages was not successfully executed.")
else
	_Gtme.printError(report.builderrors.." out of "..report.build.." builds for installed packages were not successfully executed.")
end

if report.localbuilderrors == 0 then
	_Gtme.printNote("All "..report.build.." builds for local packages were successfully executed.")
elseif report.localbuilderrors == 1 then
	_Gtme.printError("One out of "..report.build.." builds for local packages was not successfully executed.")
else
	_Gtme.printError(report.localbuilderrors.." out of "..report.build.." builds for local packages were not successfully executed.")
end

if report.logerrors == 0 then
	_Gtme.printNote("All logs for installed packages are correct.")
elseif report.logerrors == 1 then
	_Gtme.printError("One log problem for installed packages was found during the tests.")
else
	_Gtme.printError(report.logerrors.." log problems for installed packages were found during the tests.")
end

if report.locallogerrors == 0 then
	_Gtme.printNote("All logs for local packages are correct.")
elseif report.locallogerrors == 1 then
	_Gtme.printError("One log problem for local packages was found during the tests.")
else
	_Gtme.printError(report.locallogerrors.." log problems for local packages were found during the tests.")
end

if report.createdlogs == 0 then
	_Gtme.printNote("No log file was created.")
elseif report.createdlogs == 1 then
	_Gtme.printError("One log file was created during the tests. Please run the tests again.")
else
	_Gtme.printError(report.createdlogs.." log files were created during the tests. Please run the tests again.")
end

if report.observererrors == 0 then
	_Gtme.printNote("All observers are saved correctly.")
elseif report.observererrors == 1 then
	_Gtme.printError("One problem was found in the saved tme files.")
else
	_Gtme.printError(report.observererrors.." problems were found in the saved tme files.")
end

if report.forgottenfiles == 0 then
	_Gtme.printNote("All files and packages are used at least once in the tests.")
elseif report.forgottenfiles == 1 then
	_Gtme.printError("One file or package is not used at least once in the tests.")
else
	_Gtme.printError(report.forgottenfiles.." files and/or packages are not used at least once in the tests.")
end

errors = 0

forEachElement(report, function(_, value)
	errors = errors + value
end)

errors = errors - report.build - report.commands

if errors == 0 then
	_Gtme.printNote("Summing up, all tests were successfully executed.")
elseif errors == 1 then
	_Gtme.printError("Summing up, one problem was found during the tests.")
else
	_Gtme.printError("Summing up, "..errors.." problems were found during the tests.")
end

os.exit(errors)

