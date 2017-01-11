-- @example Implementation of a simple runoff model. It uses a
-- cellular data created from a tiff file (cabecadeboi.shp).
-- The Neighborhood of a Cell is composed by its Moore neighbors that
-- have lower height.
-- There is an initial rain of 10mm in the highest cells.
-- Each cell then sends its water equally to its neighbors.

local init = function(model)
    model.cell = Cell{
        init = function(cell)
            if cell.height > 200 then
                cell.water = 10 * cell:area()
            else
                cell.water = 0
            end
        end,
        on_synchronize = function(cell)
            cell.water = 0
        end,
        execute = function(cell)
            local neighbors = #cell:getNeighborhood()

            if neighbors == 0 then
                cell.water = cell.water + cell.past.water
            else
                forEachNeighbor(cell, function(_, neigh)
                    neigh.water = neigh.water + cell.past.water / neighbors
                end)
            end
        end,
        water100000 = function(cell)
            if cell.water > 100000 then
                return 100000
            else
                return cell.water
            end
        end
    }

    model.cs = CellularSpace{
        file = filePath("cabecadeboi.shp", "terralib"),
        instance = model.cell,
		geometry = true
    }

    model.cs:createNeighborhood{
        strategy = "mxn",
        filter = function(cell, neigh)
            return cell.height >= neigh.height
        end
    }

    model.map1 = Map{
        target = model.cs,
        select = "height",
        min = 0,
        max = 255,
        slices = 8,
        invert = true,
        color = "Grays"
    }

    model.map2 = Map{
        target = model.cs,
        select = "water100000",
        min = 0,
        max = 100000,
        slices = 8,
        color = "Blues"
    }

    model.timer = Timer{
        Event{action = model.cs},
        Event{action = model.map1},
        Event{action = model.map2}
    }
end

Runoff = Model{
    finalTime = 50,
    init = init
}

Runoff:run()

