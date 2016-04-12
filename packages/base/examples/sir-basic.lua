-- @example A simple Susceptible-Infected-Recovered (SIR) model.
-- This model represents a given disease that propagates over a population.
-- It starts with a small number of infected that passes the disease to
-- the susceptible ones. After some time, infected become recovered,
-- which cannot be infected again. \
-- For mode details visit http://en.wikipedia.org/wiki/Epidemic_model.
-- @image sir-basic.bmp

world = Cell{
	susceptible = 9998,
	infected = 2,
	recovered = 0,
	execute = function(world)
		world.recovered = world.recovered + world.infected / 2
		local new_infected = world.infected * 6 * 0.25
		if new_infected > world.susceptible then
			new_infected = world.susceptible
		end
		world.infected = world.infected / 2 + new_infected
		world.susceptible = 10000 - world.infected - world.recovered
	end
}

chart = Chart{target = world}

t = Timer{
	Event{action = world},
	Event{action = chart}
}

t:run(30)

