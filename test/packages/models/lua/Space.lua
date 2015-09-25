
Space = Model{
	initialWater    = Choice{min = 10, default = 200},
	finalTime       = Choice{min = 1, default = 10},
	init = function(model)
		model.timer = Timer{Event{action = function() end}}
		model.cs = CellularSpace{
			xdim = 10
		}

		forEachCell(model.cs, function(cell)
			cell.value = 10
		end)

		model.cs:get(2, 2).value = 20

		model.map = Map{
			target = model.cs,
			select = "value",
			value = {10, 20},
			color = {"blue", "green"}
		}

		model.map2 = Map{
			target = model.cs,
			select = "value",
			value = {10, 20},
			color = {"red", "green"}
		}

	end
}

