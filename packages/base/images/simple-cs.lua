
cs = CellularSpace{
	file = filePath("simple-cs.csv", "base"),
	sep = ";"
}

m = Map{
	target = cs,
	select = "maxSugar",
	min = 0,
	max = 4,
	slices = 5,
	color = "Reds"
}

m:save("simple-cs.bmp")

clean()

