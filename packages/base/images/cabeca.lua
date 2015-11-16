
local config = getConfig()
local mdbType = config.dbType
local mhost = config.host
local muser = config.user
local mpassword = config.password
local mport = config.port
local mdatabase = "cabecadeboi"

local cs = CellularSpace{
	dbType = mdbType,
	host = mhost,
	user = muser,
	password = mpassword,
	port = mport,
	database = mdatabase,
	theme = "cells90x90"
}

m = Map{
	target = cs,
	select = "height_",
	min = 0,
	max = 255,
	slices = 10,
	color = "Grays"
}

m:save("cabeca.bmp")

clean()

