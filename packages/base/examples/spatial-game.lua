-- @example Implementation of the model proposed by Nowak and Sigmund.
-- In this model, each Cell has a strategy and plays a non-cooperative
-- game with its neighbors. Then it updates its strategy with the
-- most successful one among its neighbors. This simple spatial game
-- produces a very complex spatial dynamics such as kaleidoscopes and
-- dynamic fractals. \
-- Reference: Nowak and Sigmund (2004) Evolutionary Dynamics of
-- Biological Games, Science 303(5659):793-799.
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
		forEachNeighbor(self, function(cell, neigh)
			g = Game(cell.strategy, neigh.strategy)
			cell.payoff  = cell.payoff  + g[1]
			neigh.payoff = neigh.payoff + g[2]
		end)
	end,
	chooseBest = function(self)
		self.max_payoff = self.payoff
		self.strat_max_payoff = self.strategy

		forEachNeighbor(self, function(cell, neigh)
			if neigh.payoff > cell.max_payoff then
				cell.max_payoff = neigh.payoff
				cell.strat_max_payoff = neigh.strategy
			elseif neigh.payoff == cell.max_payoff then
				if neigh.strategy ~= cell.strategy then
					cell.max_payoff = neigh.payoff
					cell.strat_max_payoff = neigh.strategy
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
	Event{action = function()
		csn:initTurn()
		csn:turn()
		csn:chooseBest()
		csn:update()
	end},
	Event{action = map}
}

t:run(TURNS)

