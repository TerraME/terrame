--[[ [previous](../data.lua) | [contents](../../00-contents.lua) | [next](../description.lua)

This is the script to create and fill a cellular space. Note that this file is not
documented in the previous script. TerraME will document it automatically from the
fill operations below.

The next script describes how to create an HTML documentation of this script as
well as the data documented in the previous script.

]]

import("gis")

itaituba = Project{
    file = "itaituba.tview",
    clean = true,
    localities = filePath("itaituba-localities.shp", "itaituba"),
    roads = filePath("itaituba-roads.shp", "itaituba"),
    census = filePath("itaituba-census.shp", "itaituba")
}

Layer{
    project = itaituba,
    name = "deforestation",
    file = filePath("itaituba-deforestation.tif", "itaituba"),
    epsg = 29191
}

Layer{
    project = itaituba,
    name = "elevation",
    file = filePath("itaituba-elevation.tif", "itaituba"),
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

