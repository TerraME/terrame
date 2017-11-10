--[[ [previous](04-traversing.lua) | [contents](00-contents.lua) | [next](06-event-timer.lua) ]]

amazonia = CellularSpace{
    file = filePath("amazonia.shp", "base"),
	as = {defor = "prodes_10"}
}

amazonia:createNeighborhood{
	strategy = "vonneumann",
	self = true
}

cell = amazonia:sample()

neighDefor = 0

forEachNeighbor(cell, function(neigh)
	neighDefor = neighDefor + neigh.defor
end)

print(neighDefor)

