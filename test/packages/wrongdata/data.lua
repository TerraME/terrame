
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
	attributes = {"abc", "def"},
	types = {"string"},
	summary = "my summary",
	source = "my own",
	wrong = "should not exist"
}

data{
	file = "abc3.txt",
	attributes = {"abc", "def"},
	types = {"boolean", "string"},
	description = {"sss"},
	summary = "my summary",
	source = "my own"
}

