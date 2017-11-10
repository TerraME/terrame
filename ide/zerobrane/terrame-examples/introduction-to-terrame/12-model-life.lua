--[[ [previous](11-model-sir-environment.lua) | [contents](00-contents.lua) | [next](00-contents.lua) ]]

Life = Model{ 
    dim = 50,
    probability = 0.5,
    finalTime = 200,
    init = function(self)
        self.cell = Cell{
            state = Random{alive = self.probability, dead = 1 - self.probability},
            execute = function(cell)
                local alive = 0

                forEachNeighbor(cell, function(neigh)
                    if neigh.past.state == "alive" then
                        alive = alive + 1 
                    end 
                end)

                if alive < 2 then -- loneliness
                    cell.state = "dead"
                elseif alive > 3 then -- overpopulation
                    cell.state = "dead"
                elseif alive == 3 then -- reproduction
                    cell.state = "alive"
                end 
            end 
        }
        self.cs = CellularSpace{
            xdim = self.dim,
            instance = self.cell
        }

        self.cs:createNeighborhood{wrap = true}

        self.map = Map{
            target = self.cs,
            select = "state",
            value = {"dead", "alive"},
            color = {"black", "white"}
        }
        self.timer = Timer{
            Event{action = self.cs},
            Event{action = self.map}
        }
    end
}

Life:run()

