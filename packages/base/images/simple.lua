
cs = CellularSpace{
	database = filePath("simple.pgm", "base"),
	attrname = "simple"
}

m = Map{
	target = cs,
	select = "simple",
	min = 1,
	max = 3,
	slices = 3,
	color = "Blues"
}


m:save("simple.bmp")
clean()


