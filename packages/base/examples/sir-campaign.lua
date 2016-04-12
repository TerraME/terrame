-- @example A Susceptible-Infected-Recovered (SIR) model with a public campaign. The
-- campaign asks the population to stop leaving home, which reduces the number of
-- contacts by half. It is activated whenever there are more than 1000
-- infected individuous in the population.
-- @image sir-campaign.bmp

contacts = 6
infections = 0.25
duration = 2

world = Cell{
	susceptible = 9998,
	infected = 2,
	recovered = 0,
	execute = function(world)
		world.recovered = world.recovered + world.infected / duration
		
		local new_infected

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
	end
}

chart = Chart{target = world}

t = Timer{
	Event{action = world},
	Event{action = chart}
}

t:run(30)

