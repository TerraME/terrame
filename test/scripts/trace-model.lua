MyTube = Model{
	water = 200,
	sun = Choice{min = 0, default = 10},
	init = function(model)
		model.finalTime = 100
		model.timer = Timer{
			Event{action = function() end}
		}
	end
}

e = Environment{
	scenario0 = MyTube{},
	scenario1 = MyTube{water = 100},
	scenario2 = MyTube{water = 100, sun = 5},
	scenario3 = MyTube{water = 100, sun = 10}
}

forEachModel(e, function(model, name)
	model.w = model.w + 1
end)
