-- @example Implementation of Barros urban dynamics model.
-- Joana Barros "Simulating urban dynamics in Latin American cities." 
-- GeoDynamics (2005): 313-328.
-- @arg P_POOR Percentage of poor agents.
-- @arg P_MIDDLE Percentage of middle class agents.
-- @arg P_RICH Percentage of rich agents. Note that the sum of the three percentages
-- must be one.
-- @arg DIM The x and y dimensions of space.
-- @arg AGENTS The number of agents in the simulation.
-- @image barros.bmp

P_POOR   = 0.65
P_MIDDLE = 0.30
P_RICH   = 0.05
DIM      = 51
AGENTS   = 500

cell = Cell{
	state = function(self)
		if self:isEmpty() then
			return "empty"
		else
			return self:getAgent().class
		end
	end
}

cellspace = CellularSpace{
	xdim = DIM,
	instance = cell
}

cellspace:createNeighborhood{
	strategy = "vonneumann"
}

mid = (DIM - 1) / 2
centralCell = cellspace:get(mid, mid)

citizen = Agent{
	init = function(self)
		local value = Random():number()

		if value < P_POOR then
			self.class = "poor"
		elseif value < P_POOR + P_MIDDLE then
			self.class = "middle"
		else 
			self.class = "rich"
		end
	end,
	execute = function(self)
		self:findPlace(centralCell)
	end,
	higherClass = function(self, other)
		local classes = {
			rich = 3,
			middle = 2,
			poor = 1
		}
	
		return classes[self.class] > classes[other.class]
	end,
	-- a citizen tries to move to a cell he can stay
	findPlace = function(self, place)
		local occupant = place:getAgent()
		
		if not occupant then
			self:enter(place)
		elseif self:higherClass(occupant) then
			occupant:leave()
			self:enter(place)
			occupant:findPlace(place)
		else
			self:findPlace(place:getNeighborhood():sample())
		end
	end
}

society = Society{
	instance = citizen,
	quantity = AGENTS
}

env = Environment{cellspace, society}
env:createPlacement{strategy = "void"}

map = Map{
	target = cellspace,
	select = "state",
	value = {"empty", "poor", "middle", "rich"},
	color = {"black", "blue", "yellow", "red"}
}

forEachAgent(society, function(agent)
	agent:execute()
	cellspace:notify()
end)

