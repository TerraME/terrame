--[[ [previous](02-cell.lua) | [contents](00-contents.lua) | [next](04-traversing.lua) ]]

space = CellularSpace{
    xdim = 10
}

print(#space) -- 100 Cells
print(type(space:sample())) -- "Cell"

-- First Map

cell = Cell{
    state = Random{"alive", "dead"}
}

space = CellularSpace{
    instance = cell,
    xdim = 30
}

map = Map{
    target = space,
    select = "state",
    value = {"alive", "dead"},
    color = {"black", "gray"}
}

-- Second Map

cell = Cell{
    state = Random{min = 1, max = 3},
    value = function(self)
        return self.x * self.state
    end
}

space = CellularSpace{
    instance = cell,
    xdim = 30
}

map = Map{
    target = space,
    select = "value",
    min = 0,
    max = 90,
    slices = 5,
    color = "RdPu"
}

-- Third Map

amazonia = CellularSpace{
    file = filePath("amazonia.shp", "base"),
	as = {defor = "prodes_10"}
}

print(#amazonia) -- 590 Cells

Map{
    target = amazonia,
    select = "defor",
    min = 0,
    max = 100,
    slices = 8,
    color = "RdYlGn", 
    invert = true -- "GnYlRd"
}

