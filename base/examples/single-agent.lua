EMPTY = 0
FULL = 1

singleFooAgent = Agent {
	execute = function(self)
		cell = self:getCell():getNeighborhood():sample()
		if cell.state == EMPTY then
			self:getCell().state = EMPTY
			self:move(cell)
			cell.state = FULL
		end
	end
}

cs = CellularSpace {
	xdim = 30
}

cs:createNeighborhood()

e = Environment {
	cs,
	singleFooAgent
}

e:createPlacement{strategy = "random"}

t = Timer {
	Event{action = singleFooAgent},
	Event{action = cs}
}

forEachCell(cs, function(cell)
	cell.state = EMPTY
end)

--[[
leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = EMPTY, color = "white"},
		{value = FULL, color = "black"}
	}
}

Observer {
	subject = cs,
	attributes = {"state"},
	legends = {leg}
}
--]]

t:execute(1000)

