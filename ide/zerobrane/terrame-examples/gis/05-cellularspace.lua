--[[ [previous](04-directory.lua) | [contents](00-contents.lua) | [next](06-fill.lua)

A cellular space is composed by a set of squared cells. It is internally
represented as polygons and can be opened in any GIS. Every cells within a
cellular space has the same resolution, such as of 1m x 1m, 500m x 500m, or
100km x 100km. The best resolution for a given cellular space depends on the
resolution of the available data, on the computing resources, and on the scale of
the process under study. Finding the best resolution can even be part of the
modeling process.

A cellular space is created as a Layer. It requires another Layer as reference for
its coverage area. If the selected reference layer has a polygonal representation,
cells will be created in such a way to fill all the space of the polygons,
considering only cells that have some overlay with some polygon of the reference
Layer. This means that some cells might be partially outside the study area.

A cellular space will have the same geographic projection of its reference layer.
If the reference layer uses cartesian coordinates, each created cell will have the
same area, which makes a model that uses such data simpler as it is not necessary
to take into account differences between areas. Because of that, it is usually
recommended to use a projection that uses cartesian coordinates instead of
geographic coordinates (latitude and longitude).

It is possible to create a cellular space using Layer constructor as shown in the
code below. The cellular space has 5000m of resolution, as the unit of measurement
of the input Layer is meters. Each created cell will have three attributes: "col",
"row", and "id". Note the option clean = true to delete the shapefile if it already
exists.

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
    resolution = 5000 -- change this value to set the resolution
}

print("Number of cells: "..#itaitubaCells)

