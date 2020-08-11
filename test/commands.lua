show = false -- show commands
time = true -- show execution time for each command

unnecessary  = {
	doc        = {arg = "-doc -color"},
	script     = {script = "basic.lua -strict"},
	sketch     = {arg = "-sketch -color"},
	version    = {arg = "-version -color"},
	showdoc    = {arg = "-showdoc -color"},
	help       = {arg = "-help -color"},
	configure  = {arg = "-configure model -color"},
	example    = {arg = "-example tube -color"},
	examples   = {arg = "-examples -color"},
	project    = {arg = "-project abc 200 -color"},
	projects   = {arg = "-projects -color"},
	build      = {arg = "-build -color"},
	buildclean = {arg = "-build -clean -color"},
	install    = {arg = "-install abc.zip -color"},
	build      = {arg = "-build -color"},
	check      = {arg = "-check -color"},
	uninstall  = {arg = "-uninstall -color"},
	build      = {arg = "-build t.lua -color", package = "gis"},
	buildclean = {arg = "-build -clean t.lua -color", package = "gis"},
	test       = {arg = "-test t.lua -color"}
}

test = {
	onerror        = {arg = "-test", config = "all.lua", package = "onerror"},
	twoerrors      = {arg = "-test", config = "all.lua", package = "twoerrors"},
	onefile        = {arg = "-test", config = "oneFile.lua"},
	onetest        = {arg = "-test", config = "oneTest.lua"},
	onedirectory   = {arg = "-test", config = "oneDirectory.lua"},
	twofiles       = {arg = "-test", config = "twoFiles.lua"},
	twotest        = {arg = "-test", config = "twoTests.lua"},
	twodirectories = {arg = "-test", config = "twoDirectories.lua"},
	pattern        = {arg = "-test", config = "pattern.lua"},
	memory         = {arg = "-test", package = "memory"},
	file           = {arg = "-test", package = "file"},
	noload         = {arg = "-test", package = "noload"},
	print          = {arg = "-test", package = "print"},
	tolerance      = {arg = "-test", package = "tolerance"},
	noexamples     = {arg = "-test", package = "noexamples" },
	examples       = {arg = "-test", package = "examples"},
	linedirectory  = {arg = "-test", config = "linesDirectory.lua"},
	testnotest     = {arg = "-test", config = "testNoTest.lua"},
	notest         = {arg = "-test", config = "noTest.lua"},
	unittest       = {arg = "-test", package = "unittest"},
	unittestall    = {arg = "-test", package = "unittest", config = "all.lua"},
	singlefile     = {arg = "-test", config = "single.lua", package = "gis"}, -- file that does not belong to the source code
}

package = {
	installnopackage  = {arg = "-install"},
	installpackage    = {package = "noexamples", arg = "-install"},
	filepath          = {package = "filepath", arg = "-example foo"},
	nodescription     = {package = "nodescription"},
	nolua             = {package = "nolua"},
	nopackage         = {package = ""},
	noexamples        = {package = "noexamples"},
	noexamplesexample = {package = "noexamples",     arg = "-example"},
	example           = {package = "onerror",        arg = "-example continuous-rain"},
	loadforgotten     = {package = "load-forgotten", arg = "-example ipd"},
	loadtwice         = {package = "load-twice",     arg = "-example ipd"},
	loadwrong         = {package = "load-wrong",     arg = "-example ipd"},
	check             = {package = "check",          arg = "-check"},
	install           = {script = "package.lua"},
	removebase        = {arg = "-uninstall"},
	removeterralib    = {package = "gis", arg = "-uninstall"},
	repository        = {arg = "-install abcd1234wef"}
}

project = {
	showprojects  = {package = "gis",  arg = "-project"},
	runprojects   = {package = "gis",  arg = "-quiet -projects"},
	errorprojects = {package = "project",   arg = "-projects"},
	nopackage1    = {package = "abcdef",    arg = "-project"},
	nopackage2    = {package = "abcdef",    arg = "-projects"},
	noproject     = {                       arg = "-project"},
	noprojects    = {                       arg = "-projects"},
	wrongdata     = {package = "wrongdata", arg = "-projects"},
	cabecadeboi   = {package = "project",  arg = "-project cabecadeboi"},
	badresolution = {package = "project",  arg = "-project cabecadeboi abc"},
	res2000       = {package = "project",  arg = "-project cabecadeboi 2000"}
}

doc = {
	noload          = {arg = "-doc", package = "noload"},
	onerror         = {arg = "-doc", package = "onerror"},
	twoerrors       = {arg = "-doc", package = "twoerrors"},
	images          = {arg = "-doc", package = "images"},
	tabular         = {arg = "-doc", package = "tabular"},
	nodescription   = {arg = "-doc", package = "nodescription"},
	nodata          = {arg = "-doc", package = "nodata"},
	nodatadotlua    = {arg = "-doc", package = "nodatadotlua"},
	wrongdata       = {arg = "-doc", package = "wrongdata"},
	nofont          = {arg = "-doc", package = "nofont"},
	nofontdotlua    = {arg = "-doc", package = "nofontdotlua"},
	wrongfont       = {arg = "-doc", package = "wrongfont"},
	withoutdatafont = {arg = "-doc", package = "withoutdatafont"}
}

build = {
	build           = {arg = "-build", package = "build",        config = "all.lua"},
	onerrorbuild    = {arg = "-build", package = "onerrorbuild", config = "all.lua", clean = true},
	twoerrorsbuild  = {arg = "-build", package = "twoerrorsbuild", config = "all.lua"},
	buildunnecfiles = {arg = "-build", package = "buildunnecfiles", config = "all.lua"},
	buildunneclean  = {arg = "-build", package = "buildunneclean", config = "all.lua", clean = true},
	tolerance       = {arg = "-build", package = "tolerance"},
	noexamples      = {arg = "-build", package = "noexamples"}
}

mode = {
	normal = {script = "basic.lua"},
	debug  = {script = "basic.lua", arg = "-debug"},
	strict = {script = "basic.lua", arg = "-strict"},
	quiet  = {script = "basic.lua", arg = "-quiet"},
}

basic = {
	help                = {arg = "-help"},
	version             = {arg = "-version"},
	noexample           = {arg = "-example abc"},
	nodoc               = {arg = "-showdoc", package = "nodoc"},
	dofile              = {script = "dofile.lua"},
	example             = {arg = "-example ipd"},
	noconfigure         = {arg = "-configure abc"},
	uninstall           = {arg = "-package abcdef -uninstall"},
	doc                 = {arg = "-package abcdef -doc"},
	test                = {arg = "-package abcdef -test"},
	builderror1         = {arg = "-package abcdef -build"},
	builderror2         = {arg = "-build", package = "build", config = "etwdre.lua"},
	builderror3         = {arg = "-build", package = "build", arg = "-clea"},
	builderror4         = {arg = "-build", package = "build", config = "pattern.lua"},
	dir                 = {script = "dir.lua"},
	table               = {script = "table.lua"},
	basictrace          = {script = "trace-basic.lua"},
	tracecall           = {script = "trace-call.lua", arg = "-strict"},
	tmpdir              = {script = "tmpdir.lua", arg = "-strict"},
	tracepackage        = {script = "trace-package.lua"},
	tracesyntax         = {script = "trace-syntax.lua"},
	fulltrace           = {script = "trace-basic.lua", arg = "-ft"},
	traceagent          = {script = "trace-agent.lua"},
	tracecell           = {script = "trace-cell.lua"},
	tracecellpair       = {script = "trace-cell-pair.lua"},
	tracechart          = {script = "trace-chart.lua"},
	traceconnection     = {script = "trace-connection.lua"},
	traceelement        = {script = "trace-element.lua"},
	traceorderedelement = {script = "trace-ordered-element.lua"},
	tracedirectory      = {script = "trace-directory.lua"},
	tracefile           = {script = "trace-file.lua"},
	tracelayer          = {script = "trace-layer.lua", arg = "-quiet"},
	tracemodel          = {script = "trace-model.lua"},
	traceneighbor       = {script = "trace-neighbor.lua"},
	traceneighagent     = {script = "trace-neighagent.lua"},
	traceneighborhood   = {script = "trace-neighborhood.lua"},
	traceself           = {script = "trace-self.lua"},
	tracesocialnetwork  = {script = "trace-social-network.lua"},
	undeclared          = {script = "undeclared.lua", arg = "-strict"},
	qwerty4321          = {package = "qwerty4321"},
	depend              = {arg = "-build", package = "depend"},
	depend2             = {arg = "-build", package = "depend2"},
	scriptdir           = {arg = packageInfo().path},
	scriptnofile        = {arg = "abcd1234.lua"},
	scriptnoluafile     = {arg = filePath("agents.csv")},
	tmp                 = {script = "tmp.lua"},
	luacheck1           = {script = "luacheck.lua", arg = "-strict"},
	luacheck2           = {script = "luacheck.lua", arg = "-debug"},
	profiler            = {script = "profiler.lua", arg = "-strict"}
}

observer = {
	observer    = {script = "observer.lua",    quantity = 1},
	chart       = {script = "chart.lua",       arg = "-autoclose", quantity = 3},
	map         = {script = "map.lua",         arg = "-autoclose", quantity = 2},
	clock       = {script = "clock.lua",       quantity = 1},
	textscreen  = {script = "textscreen.lua",  quantity = 8},
	visualtable = {script = "visualtable.lua", quantity = 8}
}

sketch = {
	data     = {arg = "-sketch", package = "nodatadotlua"},
	font     = {arg = "-sketch", package = "nofontdotlua"},
	void     = {arg = "-sketch", package = "nolua"},
	test     = {arg = "-sketch", package = "models"},
	gis      = {arg = "-sketch", package = "gis"},
	base     = {arg = "-sketch"}
}

hpa = {
	basic = {script = "hpa-basic.lua", arg = "-hpa"}
}

