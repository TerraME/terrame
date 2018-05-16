--[[ [previous](05-cellularspace.lua) | [contents](00-contents.lua) | [next](07-visualize.lua)

After creating a cellular layer, now it is possible to add attributes using the
data available. Depending on the geometric representation and the semantics of the
input data attributes, different operations can be applied. Some operations use
geometry, some use only attributes of objects with some overlap, and some combine
geometry and attributes. It is also possible to fill any geospatial data that uses
a vector format, even if it is not composed by rectangular objects. This script
describes some examples of filling some attributes.

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

--[[

Using raster data as reference layer, it is possible to compute operations based
on pixels whose centroid belongs to the cell. For example, operation average
compute the average value of such pixels for each cell. Argument attribute defines
the name of the attribute to be created, as shown below. After executing this code,
the cellular space will have an additional attribute "altim" with a number value.

]]

itaitubaCells:fill{
    operation = "average",
    layer = "elevation",
    attribute = "elevation"
}

--[[

The main operation based on categorical raster data is coverage. It computes the
percentage of the cell's area covered by each of the available categories,
creating one attribute for each of them. It uses the attribute name plus _
followed by the attribute value as attribute names. For example, layer
"deforestation" has a tif data with two values, 0 and 254. The code below then
creates two attributes, defor_0 and defor_254, with values ranging from zero to
one for each attribute. Note that the layer might have a dummy value that will
be ignored by this operation.

]]

itaitubaCells:fill{
    operation = "coverage",
    layer = "deforestation",
    attribute = "defor"
}

--[[

Using vector data without attributes, it is possible to compute the distance to
the nearest object using operation distance. The code below shows an example
that creates attribute "distr".

--]]

itaitubaCells:fill{
    operation = "distance",
    layer = "roads",
    attribute = "distroad"
}

--[[

The most important operation using polygonal data with attributes is sum using
area = true. This operation distributes the values of a given select attribute
from the polygons to the cells given their intersection areas. It is particularly
useful for data such as population because it conserves the total sum of the
input in the output. See the code below.

]]

itaitubaCells:fill{
    operation = "sum",
    layer = "census",
    attribute = "population",
    select = "population",
    area = true
}

