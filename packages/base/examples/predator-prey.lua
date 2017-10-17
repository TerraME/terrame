-- @example Implementation of a spatial predator-prey model.
-- This model has two Societies. One composed by preys that
-- feed grass and the other composed by predators that feed
-- preys. Agents move randomly in space and can reproduce.
-- The output is similar to Lotka-Volterra equations.
-- @image predator-prey.png

Random{seed = 500}

fifty = Random{p = 0.5}

predator = Agent{
	energy = 40,
	name = "predator",
	execute = function(self)
		forEachNeighborAgent(self, function(other)
			if other.name == "prey" and fifty:sample() then
				self.energy = self.energy + other.energy / 5
				other:die()
				return false -- found a prey, stop forEachAgent
			end
		end)

		self.energy = self.energy - 5
		self:walk()
		if self.energy >= 50 then
			self.energy = self.energy / 2
			self:reproduce()
		elseif self.energy <= 0 then
			self:die()
		end
	end
}

prey = Agent{
	energy = 40,
	name = "prey",
	execute = function(self)
		if self:getCell().cover == "pasture" then
			self:getCell().cover = "soil"
			self.energy = self.energy + 20
		end

		self.energy = self.energy - 1
		self:walk()

		if self.energy >= 30 then
			local neigh = self:emptyNeighbor() -- getCell():getNeighborhood():sample()

			self.energy = self.energy - 10

			if neigh then
				local child = self:reproduce()
				child:move(neigh)
			end
		elseif self.energy <= 0 then
			self:die()
		end
	end
}

predators = Society{
	instance = predator,
	quantity = 20
}

preys = Society{
	instance = prey,
	quantity = 20
}

cell = Cell{
	init = function(cell)
		cell.cover = "pasture"
		cell.count = 0
	end,
	execute = function(cell)
		if cell.cover == "soil" then
			cell.count = cell.count + 1
			if cell.count >= 4 then
				cell.cover = "pasture"
				cell.count = 0
			end
		end
	end,
	owner = function(cell)
		local agent = cell:getAgent()

		if not agent then return "empty" end

		return agent.name
	end
}

cs = CellularSpace{
	xdim = 30,
	instance = cell
}

cs:createNeighborhood()

env = Environment{
	cs,
	predators,
	preys
}

env:createPlacement{}

c = Cell{
	predators = function() return #predators end,
	preys = function() return #preys end
}

chart1 = Chart{
	target = c,
	select = {"predators", "preys"},
	color = {"red", "blue"}
}

chart2 = Chart{
	target = c,
	select = "predators",
	xAxis = "preys"
}

map1 = Map{
	target = cs,
	select = "cover",
	value = {"soil", "pasture"},
	color = {"brown", "green"}
}

map2 = Map{
	target = cs,
	select = "owner",
	value = {"empty", "predator", "prey"},
	color = {"white", "red", "blue"}
}

timer = Timer{
	Event{action = preys},
	Event{action = predators},
	Event{action = cs},
	Event{action = map1},
	Event{action = map2},
	Event{action = chart1},
	Event{action = chart2},
}

timer:run(500)

