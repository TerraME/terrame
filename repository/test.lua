-- Script to test the package repository.
-- To use it, just run 'terrame test.lua' within this directory.

local initialTime = os.time(os.date("*t"))
local s = sessionInfo().separator
local baseDir = sessionInfo().path
local pkgDir = _Gtme.makePathCompatibleToAllOS(baseDir..s.."packages")

_Gtme.printNote("Creating temporary directory")
tmpdirectory = Directory{name = ".terramerepository_XXXXX", tmp = true}.name
Directory(tmpdirectory):setCurrentDir()

_Gtme.printNote("Copying currently installed packages")

local cpCmd = _Gtme.makePathCompatibleToAllOS("cp -R \""..pkgDir.."\" .")
os.execute(cpCmd)

local pkgs = _Gtme.downloadPackagesList()

local report = {
	packages = 0,
	errors = 0,
	createdlogs = 0,
	locallogerrors = 0
}

_Gtme.printNote("Downloading packages from www.terrame.org/packages")
forEachOrderedElement(pkgs, function(_, data)
	report.packages = report.packages + 1
	pkgfile = data.package.."_"..data.version..".zip"
	_Gtme.print("Downloading "..pkgfile)
	_Gtme.downloadPackage(pkgfile)
end)

_Gtme.printNote("Installing packages")
forEachOrderedElement(pkgs, function(_, data)
	pkgfile = data.package.."_"..data.version..".zip"
	local result = _Gtme.installPackage(pkgfile)
end)

local function approximateLine(line)
	if not line then return 0 end
	
	if string.match(line, "seconds")             then return   5 end
	if string.match(line, "MD5")                 then return  70 end
	if string.match(line, "configuration file")  then return   3 end
	if string.match(line, "or is empty or does") then return  50 end
	if string.match(line, "does not exist")      then return  50 end
	if string.match(line, "is unnecessary%.")    then return  50 end
	if string.match(line, "Error: ")             then return  50 end
	if string.match(line, "File ")               then return  60 end
	if string.match(line, "such file")           then return 120 end
	if string.match(line, "In ")                 then return  50 end
	if string.match(line, "Error in")            then return  50 end
	if string.match(line, "Wrong execution")     then return  50 end
	if string.match(line, "%.terrame")           then return   5 end
	if string.match(line, "TME_PATH")            then return 120 end
	if string.match(line, "Lua 5")               then return   3 end
	if string.match(line, "Qt 5")                then return   3 end
	if string.match(line, "Qwt 6")               then return   3 end

	return 0
end

local function execute(command, filename)
	result, err = runCommand(command)

	if err and #err > 0 then
		_Gtme.printError("Command '"..command.."' stopped with an error.")
		forEachElement(err, function(_, value)
			_Gtme.printError(value)
		end)

		report.errors = report.errors + 1
	end

	logfile = io.open(".."..s.."log"..s..filename, "r")
	if logfile == nil then
		_Gtme.printError("Creating log file '".._Gtme.makePathCompatibleToAllOS("log"..s..filename.."'"))
		report.createdlogs = report.createdlogs + 1

		logfile = io.open(".."..s.."log"..s..filename, "w")
		forEachElement(result, function(_, value)
			logfile:write(value.."\n")
		end)
	else
		local resultfile = io.open(".."..s..tmpdirectory..s..filename, "w")
			
		local line = 1
		local logerror = false
		forEachElement(result, function(_, value)
			local distance = 0
			if value then
				distance = approximateLine(value)
			end

			value = _Gtme.makePathCompatibleToAllOS(value)
			resultfile:write(value.."\n")

			local str = logfile:read()
			local distance2 = approximateLine(str)

			if distance > distance2 then
				distance = distance2
			end
				
			if not str then
				_Gtme.printError("Error: Strings do not match (line "..line.."):")
				_Gtme.printError("Log file: <end of file>")
				_Gtme.printError("Test: '"..value.."'.")

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

				if distance > 0 then
					_Gtme.printError("The distance ("..levenshtein(str, value)..") was greater than the maximum ("..distance..").")
				end

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
end

_Gtme.printNote("Executing documentation")
forEachOrderedElement(pkgs, function(package)
	_Gtme.print("Documenting package '"..package.."'")
	local command = "terrame -package "..package.." -doc"
	execute(command, "doc-"..package..".log")
end)

_Gtme.printNote("Executing tests")
forEachOrderedElement(pkgs, function(package)
	_Gtme.print("Testing package '"..package.."'")
	local command = "terrame -package "..package.." -test"
	execute(command, "test-"..package..".log")
end)

_Gtme.printNote("Rolling back to previously installed packages")

local rmCmd = _Gtme.makePathCompatibleToAllOS("rm -rf \""..pkgDir.."\"")
os.execute(rmCmd)
local cpCmd = _Gtme.makePathCompatibleToAllOS("cp -R \"packages\" \""..pkgDir.."\"")
os.execute(cpCmd)

local finalTime = os.time(os.date("*t"))

print("\nRepository test report:")

_Gtme.printNote("Tests were executed in "..round(finalTime - initialTime, 2).." seconds.")
_Gtme.printNote("The repository has "..report.packages.." packages.")
_Gtme.printNote("Results were saved in '"..tmpdirectory.."'.")

if report.createdlogs == 0 then
	_Gtme.printNote("No log file was created.")
elseif report.createdlogs == 1 then
	_Gtme.printError("One log file was created during the tests. Please run the tests again.")
else
	_Gtme.printError(report.createdlogs.." log files were created during the tests. Please run the tests again.")
end

if report.errors == 0 then
	_Gtme.printNote("All verifications were successfully executed.")
elseif report.errors == 1 then
	_Gtme.printError("One verification stopped with an error.")
else
	_Gtme.printError(report.errors.." verifications stopped with an error.")
end

if report.locallogerrors == 0 then
	_Gtme.printNote("Test and doc were successfully executed.")
elseif report.locallogerrors == 1 then
	_Gtme.printError("One log error was found.")
else
	_Gtme.printError(report.locallogerrors.." log errors were found.")
end

errors = 0

forEachElement(report, function(_, value)
	errors = errors + value
end)

errors = errors - report.packages

if errors == 0 then
	_Gtme.printNote("Summing up, all tests were successfully executed.")
elseif errors == 1 then
	_Gtme.printError("Summing up, one problem was found during the tests.")
else
	_Gtme.printError("Summing up, "..errors.." problems were found during the tests.")
end

os.exit(errors)

