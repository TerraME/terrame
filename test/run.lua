-- Script to test TerraME basic functionalities (-test, -doc, -build, and so on).
-- To use it, just run 'terrame run.lua' within this folder.
--
-- Pedro R. Andrade

initialTime = os.time(os.date("*t"))

commands = _Gtme.include("commands.lua")

local s = sessionInfo().separator
local baseDir = sessionInfo().path

_Gtme.printNote("Creating temporary folder")
tmpfolder = runCommand("mktemp -d .terramerun_XXXXX")[1]

_Gtme.printNote("Testing installed packages")

_Gtme.printNote("Copying packages")
forEachFile("packages", function(file)
	_Gtme.print("Copying "..file)
	os.execute("rm -rf "..baseDir..s.."packages"..s..file)
	os.execute("cp -pr packages"..s..file.." "..baseDir..s.."packages"..s..file)
end)

local report = {
	logerrors = 0,
	locallogerrors = 0,
	build = 0,
	builderrors = 0,
	localbuilderrors = 0,
	createdlogs = 0,
	commands = 0,
	commandserrors = 0
}

local function approximateLine(line)
	if string.match(line, "seconds")             then return 5  end
	if string.match(line, "MD5")                 then return 32 end
	if string.match(line, "configuration file")  then return 3  end
	if string.match(line, "or is empty or does") then return 50 end
	if string.match(line, "does not exist")      then return 50 end
	if string.match(line, "is unnecessary%.")    then return 50 end
	if string.match(line, "Error: ")             then return 50 end
	if string.match(line, "File ")               then return 60 end
	if string.match(line, "In ")                 then return 50 end
	if string.match(line, "Error in")            then return 50 end
	if string.match(line, "Wrong execution")     then return 50 end
	if string.match(line, "%.terrame")           then return 5  end

	return 0
end

forEachOrderedElement(commands, function(idx, group)
	_Gtme.printNote("Testing group '"..idx.."'")

	forEachOrderedElement(group, function(name, args)
		command = "terrame"

		if args.package then
			command = command.." -package "..args.package
		end

		if args.arg then
			command = command.." "..args.arg
		end

		if args.config then
			command = command.." config"..s..args.config
		end

		if args.script then
			command = command.." scripts"..s..args.script
		end

		_Gtme.print("Testing "..name)
		result, ok = runCommand(command)

		report.commands = report.commands + 1

		if not ok then
			_Gtme.printError("Command '"..command.."' stopped with an error.")
			report.commandserrors = report.commandserrors + 1
		end

		local lfilename = idx.."-"..name..".log"

		logfile = io.open("log"..s..lfilename, "r")
		if logfile == nil then
			_Gtme.printError("Creating log file '".."log"..s..lfilename.."'")
			report.createdlogs = report.createdlogs + 1

			logfile = io.open("log"..s..lfilename, "w")
			forEachElement(result, function(_, value)
				logfile:write(value.."\n")
			end)
		else
			local resultfile = io.open(tmpfolder..s..lfilename, "w")
			
			local line = 1
			local logerror = false
			forEachElement(result, function(_, value)
				local distance = 0
				if value then
					distance = approximateLine(value)
				end

				resultfile:write(value.."\n")

				local str = logfile:read()

				if not str then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: <end of file>")
					_Gtme.printError("Test: '"..value.."'.")

					logerror = true
					report.logerrors = report.logerrors + 1
					return false
				end

				local distance2 = approximateLine(str)

				if distance > distance2 then
					distance = distance2
				end

				if levenshtein(str, value) > distance then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					_Gtme.printError("Log file: '"..str.."'.")
					_Gtme.printError("Test: '"..value.."'.")

					if distance > 0 then
						_Gtme.printError("The distance ("..levenshtein(str, value)..") was greater than the maximum ("..distance..").")
					end

					logerror = true
					report.logerrors = report.logerrors + 1
					return false
				end
				line = line + 1
			end)

			if not logerror then
				local v = logfile:read()
				if v then
					_Gtme.printError("Test ends but the logfile has string '"..v.."' (line "..line..").")
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

		if not isFile(mfile) then
			_Gtme.printError("File does not exist")
			report.builderrors = report.builderrors + 1
		else
			os.execute("rm "..mfile)
		end
	end)
end

_Gtme.printNote("Removing packages")
forEachFile("packages", function(file)
	_Gtme.print("Removing "..file)
	os.execute("rm -rf "..baseDir..s.."packages"..s..file)
end)

_Gtme.printNote("Testing from local folders")

chDir("packages")

forEachOrderedElement(commands, function(idx, group)
	_Gtme.printNote("Testing group '"..idx.."'")

	forEachOrderedElement(group, function(name, args)
		command = "terrame"

		if args.package then
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

		_Gtme.print("Testing "..name)
		result, ok = runCommand(command)

		report.commands = report.commands + 1

		if not ok then
			_Gtme.printError("Command '"..command.."' stopped with an error.")
			report.commandserrors = report.commandserrors + 1
		end

		local lfilename = idx.."-"..name..".log"

		logfile = io.open(".."..s.."log"..s..lfilename, "r")
		if logfile == nil then
			_Gtme.printError("Creating log file '".."log"..s..lfilename.."'")
			report.createdlogs = report.createdlogs + 1

			logfile = io.open(".."..s.."log"..s..lfilename, "w")
			forEachElement(result, function(_, value)
				logfile:write(value.."\n")
			end)
		else
			local resultfile = io.open(".."..s..tmpfolder..s..lfilename, "w")
			
			local line = 1
			local logerror = false
			forEachElement(result, function(_, value)
				local distance = 0
				if value then
					distance = approximateLine(value)
				end

				resultfile:write(value.."\n")

				local str = logfile:read()
				local distance2 = approximateLine(str)

				if distance > distance2 then
					distance = distance2
				end

				if levenshtein(str, value) > distance then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					if str == nil then
						_Gtme.printError("Log file: <empty>")
					else
						_Gtme.printError("Log file: '"..str.."'.")
					end
					_Gtme.printError("Test: '"..value.."'.")

					if distance > 0 then
						_Gtme.printError("The distance ("..levenshtein(str, value)..") was greater than the maximum ("..distance..").")
					end

					logerror = true
					report.locallogerrors = report.locallogerrors + 1
					logerror = true
					return false
				end
				line = line + 1
			end)

			if not logerror then
				local v = logfile:read()
				if v then
					_Gtme.printError("Test ends but the logfile has string '"..v.."' (line "..line..").")
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

		if not isFile(mfile) then
			_Gtme.printError("File does not exist")
			report.localbuilderrors = report.localbuilderrors + 1
		else
			os.execute("rm "..mfile)
		end
	end)
end

finalTime = os.time(os.date("*t"))

print("\nTest report:")

_Gtme.printNote("Tests were executed in "..round(finalTime - initialTime, 2).." seconds.")
_Gtme.printNote("Results were saved in '"..tmpfolder.."'.")

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
	_Gtme.printNote("All logs for global packages are correct.")
elseif report.logerrors == 1 then
	_Gtme.printError("One log problem for global packages was found during the tests.")
else
	_Gtme.printError(report.logerrors.." log problems for global packages were found during the tests.")
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

