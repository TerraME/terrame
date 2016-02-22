
return{
	Event = function(unitTest)
		local m = Model{
			finalTime = 10,
			value = 1,
			init = function(model)
				model.timer = Timer{
					Event{action = model}
				}

				model.step = function() end

				model.ch = Chart{
					target = model,
					select = "value"
				}
			end
		}

		local instance = m{}

		instance:run()

		unitTest:assertSnapshot(instance.ch, "model-chart.png")
	end
}

