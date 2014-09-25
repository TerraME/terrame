
contacts = 6
infections = 0.25
duration = 8

world = Cell{
	susceptible = 9998,
	infected = 2,
	recovered = 0,
}

Chart{subject = world}

world:notify(0)

t = Timer{
	Event{action = function(e)
		world.recovered = world.recovered + world.infected / duration
		new_infected = world.infected * contacts * infections * world.susceptible / 10000
		if new_infected > world.susceptible then
			new_infected = world.susceptible
		end
		world.infected = world.infected - world.infected / duration + new_infected
		world.susceptible = 10000 - world.infected - world.recovered
		world:notify(e)
	end}
}

t:execute(30)

