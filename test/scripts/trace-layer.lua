import("gis")

project = Project{
	file = "trace-layer.tview",
	clean = true,
	firebreak = filePath("emas-firebreak.shp", "gis"),
	river = filePath("emas-river.shp", "gis"),
	limit = filePath("emas-limit.shp", "gis")
}

forEachLayer(project, function(layer)
	layer.w = layer.w + 1
end)
