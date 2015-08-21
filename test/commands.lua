show = false

test = {
	--__test__ = "terrame -test config/all.lua",
	onerror    = {arg = "-test", config = "all.lua", package = "onerror"},
	twoerrors  = {arg = "-test", config = "all.lua", package = "twoerrors"},
	onefile    = {arg = "-test", config = "oneFile.lua"},
	onetest    = {arg = "-test", config = "oneTest.lua"},
	onefolder  = {arg = "-test", config = "oneFolder.lua"},
	twofiles   = {arg = "-test", config = "twoFiles.lua"},
	twotest    = {arg = "-test", config = "twoTests.lua"},
	twofolder  = {arg = "-test", config = "twoFolders.lua"},
	pattern    = {arg = "-test", config = "pattern.lua"},
	noexamples = {arg = "-test", package = "noexamples"}
}

package = {
	nodescription     = {package = "nodescription"},
	nolua             = {package = "nolua"},
	noexamples        = {package = "noexamples"},
	noexamplesexample = {package = "noexamples",     arg = "-example"},
	example           = {package = "onerror",        arg = "-example ipd"},
	loadforgotten     = {package = "load-forgotten", arg = "-example ipd"},
	loadtwice         = {package = "load-twice",     arg = "-example ipd"},
	loadwrong         = {package = "load-wrong",     arg = "-example ipd"}
}

doc = {
	doc             = {arg = "-doc"},
	onerror         = {arg = "-doc", package = "onerror"},
	twoerrors       = {arg = "-doc", package = "twoerrors"},
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
	build           = {arg = "-build",        package = "build"},
	onerrorbuild    = {arg = "-build -clean", package = "onerrorbuild"},
	twoerrorsbuild  = {arg = "-build",        package = "twoerrorsbuild"},
	buildunnecfiles = {arg = "-build",        package = "buildunnecfiles"},
	buildunneclean  = {arg = "-build -clean", package = "buildunneclean"},
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
}

observer = {
	observer    = {script = "observer.lua",    quantity = 1},
	chart       = {script = "chart.lua",       quantity = 3},
	map         = {script = "map.lua",         quantity = 2},
	clock       = {script = "clock.lua",       quantity = 1},
	textscreen  = {script = "textscreen.lua",  quantity = 8},
	visualtable = {script = "visualtable.lua", quantity = 8}
}

