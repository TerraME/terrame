-- @example A simple Susceptible-Infected-Recovered (SIR) model. For a description
-- of such model visit http://en.wikipedia.org/wiki/Epidemic_model.
-- @image sir-basic.bmp

world = Cell{
	susceptible = 9998,
	infected = 2,
	recovered = 0
}

chart = Chart{target = world}

world:notify()

t = Timer{
	Event{action = function()
		world.recovered = world.recovered + world.infected / 2
		local new_infected = world.infected * 6 * 0.25
		if new_infected > world.susceptible then
			new_infected = world.susceptible
		end
		world.infected = world.infected / 2 + new_infected
		world.susceptible = 10000 - world.infected - world.recovered
		world:notify()
	end}
}

t:execute(30)

