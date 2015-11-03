-- @example Implementation of Schelling's segregation model.
-- Thomas Schelling, in 1971, showed that a small preference for one's neighbors to be of the same color could lead to total segregation. He used coins on graph paper to demonstrate his theory by placing pennies and nickels in different patterns on the "board" and then moving them one by one if they were in an "unhappy" situation. \ Here's the high-tech equivalent. The rule this model operates on is that for every colored cell, if greater than 33% of the adjacent cells are of a different color, the cell moves to another randomly selected cell.
-- Dynamic models of seggregation, Journal of Mathematical Sociology 1:143-186, 1971.
-- @arg NDIM Space dimensions in x and y axis.
-- @arg PREFERENCE Agent contentedness, indicating the minimum number of neighbors
-- of the same color to make the agent satisfied. It should be an integer
-- number between 3 and 5.
-- @arg NAGTS The proportion of agents in space.
-- @arg MAX_TURNS Maximum number of simulation steps.
-- @image schelling.bmp

NDIM = 30
NAGTS = 0.9
PREFERENCE = 3
MAX_TURNS = 5000

agent = Agent{
	init = function(self)
		if Random():number() < 0.5 then
			self.color = "red"
		else
			self.color = "black"
		end
	end,
	isUnhappy = function(agent)
		local mycell = agent:getCell()
		local likeme = 0

		forEachNeighbor(mycell, function(cell, neigh)
			local other = neigh:getAgent()
			if other and other.color == agent.color then
				likeme = likeme + 1
			end
		end)

		return likeme < PREFERENCE
	end
}

cell = Cell{
	color = function(self)
		if self:isEmpty() then return "empty" end
		return self:getAgent().color
	end
}

cells = CellularSpace{
	xdim = NDIM,
	instance = cell
}

cells:createNeighborhood{}

society = Society {
	instance = agent,
	quantity = NAGTS * NDIM * NDIM,
	unhappy_agents = function(self)
		if not self.ua then
			self.ua = Group { 
				target = self,
				select = function(agent)
					return agent:isUnhappy()
				end
			}
		end

		self.ua:filter()
		return self.ua
	end,
	unhappy = function(self) return #self:unhappy_agents() end
}

env = Environment{
	cells, society
}

env:createPlacement{
	max = 1
}

empty_cells = Trajectory{
	target = cells,
	select = function(cell)
		return cell:isEmpty()
	end
}

timer = Timer{
	Event{action = function()
		unhappy_agents = society:unhappy_agents()
		empty_cells:filter()

		if #unhappy_agents > 0 then
			local myagent = unhappy_agents:sample()
			local mycell  = empty_cells:sample()
			myagent:move(mycell)
			society:notify()
			cells:notify()
		else
			return false
		end 
	end}
}

map = Map{
	target = cells,
	select = "color",
	value = {"empty", "black", "red"},
	color = {"white", "black", "red"}
}

Chart{
	target = society,
	select = "unhappy"
}

society:notify()

timer:execute(MAX_TURNS)

