--[[ [previous](06-fill.lua) | [contents](00-contents.lua) | [next](08-document.lua)

To visualize the attributes created by Layer:fill(), it is necessary to create a
CellularSpace.

]]

import("gis")

itaituba = Project{
    file = "itaituba.tview",
    clean = true,
    localities = "itaituba-localities.shp",
    roads = "itaituba-roads.shp",
    census = "itaituba-census.shp"
}

Layer{
    project = itaituba,
    name = "deforestation",
    file = "itaituba-deforestation.tif",
    epsg = 29191
}

Layer{
    project = itaituba,
    name = "elevation",
    file = "itaituba-elevation.tif",
    epsg = 29191
}

itaitubaCells = Layer{
    project = itaituba,
    name = "cells",
    clean = true,
    file = "itaituba.shp",
    input = "census",
    resolution = 5000
}

itaitubaCells:fill{
    operation = "average",
    layer = "elevation",
    attribute = "elevation"
}

itaitubaCells:fill{
    operation = "coverage",
    layer = "deforestation",
    attribute = "defor"
}

itaitubaCells:fill{
    operation = "distance",
    layer = "roads",
    attribute = "distroad"
}

itaitubaCells:fill{
    operation = "sum",
    layer = "census",
    attribute = "population",
    select = "population",
    area = true
}

--[[

As we now have a Project, we can use it directly with the name of the Layer to be
read instead of describing where the data is stored. The code below reads layer
"cells" from the project "itaituba.tview". The attribute "population" will be
drawn using log scale, therefore we need to create a Cell to be used as instance
of the CellularSpace. It will have a function logpop that returns the log of
the "population".

]]

cell = Cell{
    logpop = function(self)
        return math.log(self.population)
    end
}

cs = CellularSpace{
    project = itaituba,
    layer = "cells",
    instance = cell
}

--[[

Now it is only necessary to create some Map objects to visualize the attributes.
For example, the code below creates three Maps. The first one draws attribute
"altim" using ten slices of blue. The second one draws "distl" using reds. The
last one draws with greens the attribute "defor_0", created from operation
"coverage" using pixels with value "10".

]]

Map{
    target = cs,
    select = "elevation",
    slices = 6,
    color = "Blues"
}

Map{
    target = cs,
    select = "defor_87",
    slices = 6,
    invert = true,
    color = "Greens"
}

Map{
    target = cs,
    select = "logpop",
    slices = 10,
    color = "Purples"
}

Map{
    target = cs,
    select = "distroad",
    slices = 10,
    color = "Reds"
}

