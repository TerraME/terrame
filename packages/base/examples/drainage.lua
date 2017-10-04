-- @example A simple drainage model. It uses a Chart to
-- show the output of the simulation.
-- @image drainage.png

-- model parameters

c = Cell{
	Q1 = 0,
	Q2 = 0
}

chart = Chart{
	target = c
}

-- model execution
t = Timer{
	Event{action = function()
		-- Input
		local E1 = 2
		-- Output
		local S1 = 0.4 * c.Q1
		-- Simulation
		c.Q1 = c.Q1 + (E1 - S1)

		-- Input
		local E2 = S1
		-- Output
		local S2 = 0.2 * c.Q2
		-- Simulation
		c.Q2 = c.Q2 + (E2 - S2)

		-- Report
		print(c.Q1.." "..c.Q2)
	end},
	Event{action = chart}
}

t:run(100)

