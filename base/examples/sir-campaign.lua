
-- @example A Susceptible-Infected-Recovered (SIR) model with a public campaign. The
-- campaign reduces the number of contacts by half whenever there are more than 1000
-- infected individuous in the population.

contacts = 6
infections = 0.25
duration = 2

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
		
		if world.infected >= 1000 then
			new_infected = world.infected * (contacts / 2) * infections * world.susceptible / 10000
		else
			new_infected = world.infected * contacts * infections * world.susceptible / 10000
		end

		if new_infected > world.susceptible then
			new_infected = world.susceptible
		end
		world.infected = world.infected - world.infected / duration + new_infected
		world.susceptible = 10000 - world.infected - world.recovered
		world:notify(e)
	end}
}

t:execute(30)

