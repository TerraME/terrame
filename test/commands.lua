show = false

test = {
	--__test__     = "terrame -test config/all.lua",
	onerror        = {arg = "-test", config = "all.lua", package = "onerror"},
	twoerrors      = {arg = "-test", config = "all.lua", package = "twoerrors"},
	onefile        = {arg = "-test", config = "oneFile.lua"},
	onetest        = {arg = "-test", config = "oneTest.lua"},
	onedirectory   = {arg = "-test", config = "oneDirectory.lua"},
	twofiles       = {arg = "-test", config = "twoFiles.lua"},
	twotest        = {arg = "-test", config = "twoTests.lua"},
	twodirectories = {arg = "-test", config = "twoDirectories.lua"},
	pattern        = {arg = "-test", config = "pattern.lua"},
	nolog          = {arg = "-test", config = "log.lua"},
	noexamples     = {arg = "-test", package = "noexamples"}
}

package = {
	nodescription     = {package = "nodescription"},
	nolua             = {package = "nolua"},
	noexamples        = {package = "noexamples"},
	noexamplesexample = {package = "noexamples",     arg = "-example"},
	example           = {package = "onerror",        arg = "-example continuous-rain"},
	loadforgotten     = {package = "load-forgotten", arg = "-example ipd"},
	loadtwice         = {package = "load-twice",     arg = "-example ipd"},
	loadwrong         = {package = "load-wrong",     arg = "-example ipd"}
}

doc = {
	doc             = {arg = "-doc"},
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
	build           = {arg = "-build", package = "build"},
	onerrorbuild    = {arg = "-build", package = "onerrorbuild", clean = true},
	twoerrorsbuild  = {arg = "-build", package = "twoerrorsbuild"},
	buildunnecfiles = {arg = "-build", package = "buildunnecfiles"},
	buildunneclean  = {arg = "-build", package = "buildunneclean", clean = true},
	noexamples      = {arg = "-build", package = "noexamples"}
}

mode = {
	normal = {script = "basic.lua"},
	debug  = {script = "basic.lua", arg = "-mode=debug"},
	strict = {script = "basic.lua", arg = "-mode=strict"},
	quiet  = {script = "basic.lua", arg = "-mode=quiet"},
}

basic = {
	help        = {arg = "-help"},
	version     = {arg = "-version"},
	noexample   = {arg = "-example abc"},
	nodoc       = {arg = "-showdoc", package = "nodoc"},
	example     = {arg = "-example ipd"},
	noconfigure = {arg = "-configure abc"},
	uninstall   = {arg = "-package abcdef -uninstall"},
	doc         = {arg = "-package abcdef -doc"},
	test        = {arg = "-package abcdef -test"},
	build       = {arg = "-package abcdef -build"},
	trace       = {script = "trace.lua"},
	fulltrace   = {script = "trace.lua", arg = "-ft"},
	qwerty4321  = {package = "qwerty4321"},
	depend      = {arg = "-build", package = "depend"},
	depend2     = {arg = "-build", package = "depend2"},
	tmp         = {script = "tmp.lua"}
}

observer = {
	observer    = {script = "observer.lua",    quantity = 1},
	chart       = {script = "chart.lua",       quantity = 3},
	map         = {script = "map.lua",         quantity = 2},
	clock       = {script = "clock.lua",       quantity = 1},
	textscreen  = {script = "textscreen.lua",  quantity = 8},
	visualtable = {script = "visualtable.lua", quantity = 8}
}

sketch = {
	data = {arg = "-sketch", package = "nodatadotlua"},
	font = {arg = "-sketch", package = "nofontdotlua"},
	void = {arg = "-sketch", package = "nolua"},
	test = {arg = "-sketch", package = "models"},
	base = {arg = "-sketch"}
}

