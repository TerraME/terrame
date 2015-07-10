local cs = CellularSpace{xdim = 10}

local r = Random()

forEachCell(cs, function(cell)
    cell.value = r:number()
end)

local m = Map{
    target = cs,
    select = "value",
    min = 0,
    max = 1,
    slices = 10,
    color = "Blues"
}

cs:notify()

forEachCell(cs, function(cell)
    cell.value = r:integer(1, 3)
end)

m = Map{
    target = cs,
    select = "value",
    color = {"red", "green", "blue"},
    value = {1, 2, 3}
}

_Gtme.killAllObservers()

