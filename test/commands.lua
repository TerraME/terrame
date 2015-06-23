
test = {
	--__test__ = "terrame -test config/all.lua",
	onerror = "terrame -package onerror -test config/all.lua",
	twoerrors = "terrame -package twoerrors -test config/all.lua",
	onefile = "terrame -test config/oneFile.lua",
}

doc = {
	doc = "terrame -doc",
	onerror = "terrame -package onerror -doc",
	twoerrors = "terrame -package twoerrors -doc",
}

mode = {
	normal = "terrame scripts/basic.lua",
	--debug = "terrame -mode=debug scripts/basic.lua",
	strict = "terrame -mode=strict scripts/basic.lua",
	quiet = "terrame -mode=quiet scripts/basic.lua",
}

basic = {
	help = "terrame -help",
	version = "terrame -version",
	trace = "terrame scripts/trace.lua",
	noexample = "terrame -example abc",
	example = "terrame -example ipd",
	-- example inside another package
	nointerface = "terrame -interface abc",
	qwerty4321 = "terrame -package qwerty4321",
}

