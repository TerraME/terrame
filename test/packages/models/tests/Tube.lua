-- Test file for Tube.lua
-- Author: Pedro R. Andrade

return{
	Tube = function(unitTest)
		local model = Tube{}

		model:run()

		unitTest:assertSnapshot(model.chart, "Tube-chart-1.bmp")
	end,
}

