-- @example Implementation of the model proposed by Nowak and Sigmund.
-- Evolutionary Dynamics of Biological Games, Science 303(5659):793-799, 2004.
-- @arg N Space dimensions in x and y axis.
-- @arg TURNS Number of simulation steps.
-- @image spatial-game.bmp

N = 69
TURNS = 80

function Game(p1, p2)
	if p1 == "cooperate"     and p2 == "cooperate"     then return {1, 1} end
	if p1 == "cooperate"     and p2 == "not_cooperate" then return {0, 1.4} end
	if p1 == "not_cooperate" and p2 == "cooperate"     then return {1.4, 0} end
	if p1 == "not_cooperate" and p2 == "not_cooperate" then return {0, 0} end
end

cell = Cell{
	init = function(self)
		self.strategy = "cooperate"

		if self.x == 34 and self.y == 34 then
			self.strategy = "not_cooperate"
		end
	end,
	initTurn = function(self)
		if self.strategy == "just_cooperate"     then self.strategy = "cooperate"     end
		if self.strategy == "just_not_cooperate" then self.strategy = "not_cooperate" end
		self.payoff = 0
	end,
	turn = function(self)
		forEachNeighbor(self, function(self, neigh)
			g = Game(self.strategy, neigh.strategy)
			self.payoff  = self.payoff  + g[1]
			neigh.payoff = neigh.payoff + g[2]
		end)
	end,
	chooseBest = function(self)
		self.max_payoff = self.payoff
		self.strat_max_payoff = self.strategy
	
		forEachNeighbor(self, function(self, neigh)
			if neigh.payoff > self.max_payoff then
				self.max_payoff = neigh.payoff
				self.strat_max_payoff = neigh.strategy
			elseif neigh.payoff == self.max_payoff then
				if neigh.strategy ~= self.strategy then
					self.max_payoff = neigh.payoff
					self.strat_max_payoff = neigh.strategy
				end
			end
		end)
	end,
	update = function(self)
		if self.max_payoff >= self.payoff then
			if self.strat_max_payoff == "cooperate" and self.strategy ~= "cooperate" then
				self.strategy = "just_cooperate"
			end
			if self.strat_max_payoff == "not_cooperate" and self.strategy ~= "not_cooperate" then
				self.strategy = "just_not_cooperate"
			end
		end
	end
}

csn = CellularSpace{
	xdim = N,
	instance = cell
}

csn:createNeighborhood{strategy = "vonneumann"}

map = Map{
	target = csn,
	select = "strategy",
	value = {"cooperate", "not_cooperate", "just_cooperate", "just_not_cooperate"},
	color = {"blue", "red", "green", "yellow"}
}

t = Timer{
	Event{action = function(event)
		csn:initTurn()
		csn:turn()
		csn:chooseBest()
		csn:update()
		csn:notify()
	end}
}

t:execute(TURNS)

