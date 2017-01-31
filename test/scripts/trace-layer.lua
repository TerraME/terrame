import("terralib")

project = Project{
	file = "trace-layer.tview",
	clean = true,
	firebreak = filePath("emas-firebreak.shp", "terralib"),
	river = filePath("emas-river.shp", "terralib"),
	limit = filePath("emas-limit.shp", "terralib")
}

forEachLayer(project, function(layer)
	layer.w = layer.w + 1
end)
