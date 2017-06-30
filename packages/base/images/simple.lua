
cs = CellularSpace{
	file = filePath("simple.pgm", "base")
}

m = Map{
	target = cs,
	select = "simple",
	min = 1,
	max = 3,
	slices = 3,
	color = "Blues"
}


m:save("simple.png")
clean()


