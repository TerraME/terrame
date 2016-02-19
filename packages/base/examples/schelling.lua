-- @example Implementation of Schelling's segregation model.
-- In this model, a Society is composed by two types of Agents, reds and
-- blacks, which live in Cells. Each Agent is happy if its neighborhood
-- has at least a given number of Agents sharing its type. Otherwise, it
-- will try to move to another place where it is satisfied.
-- Using this model, Thomas Schelling showed that a small preference for one's
-- neighbors to be of the same color could lead to total segregation. \
-- For more information, see Schelling, T. (1971) Dynamic models of seggregation,
-- Journal of Mathematical Sociology 1:143-186.
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

env:createPlacement{}

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
	color = {"lightGray", "black", "red"}
}

Chart{
	target = society,
	select = "unhappy"
}

society:notify()

timer:execute(MAX_TURNS)

