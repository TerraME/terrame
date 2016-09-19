
data{
	file = "abc.txt",
	summary = "my summary"
}

data{
	summary = "my summary",
	source = "my own"
}

data{
	file = "abc.txt",
	source = "my own"
}

data{
	file = "abc2.txt",
	wrong = 2,
	types = "abc",
	attributes = {
		abc = "my attribute",
		def = 2
	},
	summary = "my summary",
	source = "my own",
	wrong = "should not exist"
}

data{
	file = "abc3.txt",
	attributes = {"abc", "def"},
	summary = "my summary",
	source = "my own"
}

