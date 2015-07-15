test = {
	--__test__ = "terrame -test config/all.lua",
	onerror   = {arg = "-test", config = "all.lua", package = "onerror"},
	twoerrors = {arg = "-test", config = "all.lua", package = "twoerrors"},
	onefile   = {arg = "-test", config = "oneFile.lua"},
	onetest   = {arg = "-test", config = "oneTest.lua"},
	onefolder = {arg = "-test", config = "oneFolder.lua"},
	twofiles  = {arg = "-test", config = "twoFiles.lua"},
	twotest   = {arg = "-test", config = "twoTests.lua"},
	twofolder = {arg = "-test", config = "twoFolders.lua"},
}

package = {
	nodescription     = {package = "nodescription"},
	nolua             = {package = "nolua"},
	noexamples        = {package = "noexamples"},
	noexamplesexample = {package = "noexamples", arg = "-example"},
	example           = {package = "onerror", arg = "-example ipd"},
}

doc = {
	doc           = {arg = "-doc"},
	onerror       = {arg = "-doc", package = "onerror"},
	twoerrors     = {arg = "-doc", package = "twoerrors"},
	nodescription = {arg = "-doc", package = "nodescription"},
	nodatadotlua  = {arg = "-doc", package = "nodatadotlua"},
	wrongdata     = {arg = "-doc", package = "wrongdata"},
	withoutdata   = {arg = "-doc", package = "wrongdata"}, -- withoutdata
}

build = {
	build           = {arg = "-build", package = "build"},
	onerrorbuild    = {arg = "-build", package = "onerrorbuild"},
	twoerrorsbuild  = {arg = "-build", package = "twoerrorsbuild"},
	buildunnecfiles = {arg = "-build", package = "buildunnecfiles"},
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
	example     = {arg = "-example ipd"},
	nointerface = {arg = "-interface abc"},
	trace       = {script = "trace.lua"},
	qwerty4321  = {package = "qwerty4321"},
}

observer = {
	chart = {script = "chart.lua", quantity = 3},
	map   = {script = "map.lua",   quantity = 2},
	clock   = {script = "clock.lua",   quantity = 1},
	textscreen   = {script = "textscreen.lua",   quantity = 8},
	visualtable	= {script = "visualtable.lua",   quantity = 8}
}

