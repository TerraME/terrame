-- @example SIR model implemented with agents. This model needs to have more
-- implementation decisions if compared to one implemented using system dynamics.
-- The social network of an agent is fixed? In a system dynamics model it supposes
-- that the network is not fixed as disease is propagated to the whole population
-- using probabilities. Another question: an agent that has got sick in a given
-- time step can infect other agents? This implementation supposes it can only
-- infect in the next time step.
-- @image sir-abm.png

local function compare(a, b)
	return tonumber(a.id) < tonumber(b.id)
end

Random{seed = 500}

local p25 = Random{p = 0.25}

ag = Agent{
	state = "susceptible",
	sick = function(self)
		self.state = "infected"
		self.counter = 0

		self.parent.infected = self.parent.infected + 1
		self.parent.susceptible = self.parent.susceptible - 1
	end,
	on_message = function(self)
		if self.state == "susceptible" and p25:sample() then
			self:sick()
		end
	end,
	execute = function(self)
		if self.state == "recovered" then return
		elseif self.state == "infected" then
			local conns = {}
			forEachConnection(self, function(conn)
				-- self:message{receiver = conn, delay = 1}
				-- delay = 1 means that the agents will got sick only in
				-- the end of the time step. It means that an agent that
				-- got sick in a given time step cannot infect others in
				-- the same time step.
				table.insert(conns, conn)
			end)

			table.sort(conns, compare)

			for i = 1, #conns do
				self:message{receiver = conns[i], delay = 1}
			end

			if self.counter > 2 then
				self.state = "recovered"
				self.parent.infected = self.parent.infected - 1
				self.parent.recovered = self.parent.recovered + 1
			end

			self.counter = self.counter + 1
		end
	end
}

soc = Society{
	instance = ag,
	quantity = 1000
}

soc.susceptible = #soc
soc.infected = 0
soc.recovered = 0

soc:sample():sick()

soc:createSocialNetwork{
	quantity = 6,
	inmemory = false -- the social network will be different (recomputed) each time it is required
}

chart = Chart{
	target = soc,
--	select = "state",
	select = {"susceptible", "infected", "recovered"}, -- it should be "value ="
	color = {"blue", "red", "green"}
}

t = Timer{
	Event{action = soc},
	Event{action = chart}
}

t:run(30)

