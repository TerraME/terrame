--[[ [previous](02-clean.lua) | [contents](00-contents.lua) | [next](04-directory.lua)

A Layer represents a geospatial dataset stored in a given data source, such as a
database table, a shapefile, or a web service. Each Layer belongs to a Project.

In the code below, a Project is created with three layers: localities, roads, and
census. Each layer represents a shapefile that is stored in the same directory of
this script.

]]

import("gis")

itaituba = Project{
    file = "itaituba.tview",
    clean = true,
    localities = "itaituba-localities.shp",
    roads = "itaituba-roads.shp",
    census = "itaituba-census.shp"
}

--[[

If data is not stored into a file, or if some additional arguments are required,
it is necessary to create a Layer explicitly after the Project. For example, when
the data to be addeed to the Project does not have enough information about its
projection, it is necessary to set argument epsg, which is an [EPSG](http://www.epsg.org) number. For
example, in the two Layers below, it is necessary to indicate that their epsg is
29191 to allow combining them with other geospatial data. A list with the
supported epsg numbers in the latest TerraME version is available [here](http://www.terrame.org/projections.html).

]]

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

print(itaituba)
