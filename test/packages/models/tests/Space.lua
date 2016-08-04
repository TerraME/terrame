-- Test file for Space.lua
-- Author: Pedro R. Andrade

return{
	Space = function(unitTest)
		local model = Space{}

		unitTest:assertSnapshot(model.map, "Space-map-1-begin.bmp")
		unitTest:assertSnapshot(model.map2, "Space-map-2-begin.bmp")

		model:run()

		unitTest:assertSnapshot(model.map, "Space-map-1-end.bmp")
		unitTest:assertSnapshot(model.map2, "Space-map-2-end.bmp")
	end,
}

