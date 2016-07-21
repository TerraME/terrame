import("terralib")

project = Project{
	file = "trace-layer.tview",
	clean = true,
	firebreak = filePath("firebreak_lin.shp", "terralib"),
	cover = filePath("accumulation_Nov94May00.tif", "terralib"),
	river = filePath("River_lin.shp", "terralib"),
	limit = filePath("Limit_pol.shp", "terralib")
}

forEachLayer(project, function(layer)
	layer.w = layer.w + 1
end)