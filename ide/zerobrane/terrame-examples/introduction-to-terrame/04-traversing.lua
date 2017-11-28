--[[ [previous](03-cellular-space-map.lua) | [contents](00-contents.lua) | [next](05-neighborhood.lua) ]]

cell = Cell{
    water = 0,
    rain = function(self)
        self.water = self.water + 1
    end
}

world = CellularSpace{
    xdim = 20,
    instance = cell
}

print(world:water())

world:rain()

print(world:water())
