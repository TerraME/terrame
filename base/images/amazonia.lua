config = getConfig()

amazonia = CellularSpace{
	dbType = config.dbType,
	host = config.host,
	user = config.user,
	password = config.password,
	database = "amazonia",
	theme = "dinamica",
	select = {"defor", "dist_urban_areas", "conn_markets_inv_p", "prot_all2"}
}

map = Map{
	target = amazonia,
	select = "defor",
	slices = 10,
	min = 0,
	max = 1,
	color = {"green", "red"}
}

map:save("amazonia.bmp")

clean()
