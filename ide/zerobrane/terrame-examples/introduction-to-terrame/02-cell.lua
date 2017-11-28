--[[ [previous](01-random.lua) | [contents](00-contents.lua) | [next](03-cellular-space-map.lua) ]]

mycell = Cell{
    cover = "forest",
    distRoad = 52,
    distUrban = 28,
    averageDist = function(self)
        return (self.distRoad + self.distUrban) / 2
    end,
    deforest = function(self)
        self.cover = "deforested"
    end
}

print(type(mycell)) -- "Cell"

print(mycell:averageDist()) -- 40.0
mycell.distRoad = mycell.distRoad / 2
print(mycell:averageDist()) -- 27.0

print(mycell.cover) -- "forest"
mycell:deforest()
print(mycell.cover) -- "deforested"
