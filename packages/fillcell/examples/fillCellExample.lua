
import("fillcell")

project = Project{
	file = "myproject2.tview",
	create = true
}

project:addLayer{
	name = "points",
	file = file("shppoints.shp", "fillcell")
	-- ... 
}


project:addLayer{
	name = "lines",
	file = file("shplines.shp", "fillcell")
}


project:addLayer{
	name = "polygons",
	file = file("shplines.shp", "fillcell")
}

proj:createCellularLayer{
    input = "polygons",
    layer = "cells",
	output = "cell.shp",
	-- ...
    resolution = 2e4 -- 50x50km
}


cl = CellularLayer{
	project = project,
	layer = "cells"
}

cl:fillCells{
	strategy = "distance",
	layer = "points",
	attribute = "distpoints"
}

cl:fillCells{
	strategy = "lenght",
	layer = "lines",
	attribute = "llenght"
}

cl:fillCells{
	layer = "polygons",
	strategy = "sum",
	attribute = "population",
	area = true
}

cl:fillCells{
	layer = "polygons",
	strategy = "average",
	attribute = "income",
	area = true
}


