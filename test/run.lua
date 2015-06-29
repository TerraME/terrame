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

_Gtme.printNote("Copying packages")
forEachFile("packages", function(file)
	_Gtme.print("Copying "..file)
	os.execute("rm -rf "..baseDir..s.."packages"..s..file)
	os.execute("cp -pr packages"..s..file.." "..baseDir..s.."packages"..s..file)
end)

local report = {
	logerrors = 0,
	build = 0,
	builderrors = 0,
	createdlogs = 0
}

local function approximateLine(line)
	if string.match(line, "seconds")             then return 5  end
	if string.match(line, "%.terrame")           then return 5  end
	if string.match(line, "MD5")                 then return 32 end
	if string.match(line, "configuration file")  then return 3  end
	if string.match(line, "or is empty or does") then return 50 end

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
		result = runCommand(command)
	
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
			forEachElement(result, function(_, value)
				local distance = 0
				if value then
					distance = approximateLine(value)
				end

				resultfile:write(value.."\n")

				local str = logfile:read()
				if levenshtein(str, value) > distance then
					_Gtme.printError("Error: Strings do not match (line "..line.."):")
					if str == nil then
						_Gtme.printError("Log file: <empty>")
					else
						_Gtme.printError("Log file: '"..str.."'.")
					end
					_Gtme.printError("Test: '"..value.."'.")
					report.logerrors = report.logerrors + 1
					return false
				end
				line = line + 1
			end)

			local v = logfile:read()
			if v then
				_Gtme.printError("Test ends but the logfile has string '"..v.."' (line "..line..").")
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

finalTime = os.time(os.date("*t"))

print("\nTest report:")

_Gtme.printNote("Tests were executed in "..round(finalTime - initialTime, 2).." seconds.")
_Gtme.printNote("Results were saved in '"..tmpfolder.."'.")

if report.builderrors == 0 then
	_Gtme.printNote("All build commands were successfully executed.")
elseif report.builderrors == 1 then
	_Gtme.printError("One out of "..report.build.." build commands was not successfully executed.")
else					
	_Gtme.printError(report.builderrors.." out of "..report.build.." build commands were not successfully executed.")
end					 

if report.logerrors == 0 then
	_Gtme.printNote("All tests were successfully executed.")
elseif report.logerrors == 1 then
	_Gtme.printError("One problem was found during the tests.")
else					
	_Gtme.printError(report.logerrors.." problems were found during the tests.")
end					 

if report.createdlogs == 0 then
	_Gtme.printNote("No log file was created.")
elseif report.createdlogs == 1 then
	_Gtme.printError("One log file was created during the tests. Please run the tests again.")
else					
	_Gtme.printError(report.createdlogs.." log files were created during the tests. Please run the tests again.")
end					 

