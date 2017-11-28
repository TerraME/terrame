--[[ [previous](Fire.lua) | [contents](00-contents.lua) | [next](00-contents.lua) ]]

GrowingSociety = Model{
    quantity = 10,
    dim = 100,
    finalTime = 80,
    init = function(model)
        model.agent = Agent{
            execute = function(self)
				local cell = self:emptyNeighbor()
                if cell and Random{p = 0.3}:sample() then
                    local child = self:reproduce()
                    child:move(cell)
                end

                cell = self:emptyNeighbor()
                if cell then
                    self:move(cell)
                end
            end
        }

        model.soc = Society{
            instance = model.agent,
            quantity = model.quantity
        }

		model.cell = Cell{
			state = function(self)
				if self:isEmpty() then
					return "empty"
				else
					return "full"
				end
			end
		}

        model.cs = CellularSpace{
            xdim = model.dim,
			instance = model.cell
        }

        model.cs:createNeighborhood()

        model.env = Environment{
            model.cs,
            model.soc
        }

        model.env:createPlacement()

        model.map = Map{
            target = model.cs,
			select = "state",
			value = {"full", "empty"},
			color = {"black", "white"}
        }

        model.chart = Chart{
            target = model.soc
        }

        model.timer = Timer{
            Event{action = model.soc},
            Event{action = model.map},
            Event{action = model.chart}
        }
    end
}

gs = GrowingSociety{}
gs:run()

