--[[ [previous](00-contents.lua) | [contents](00-contents.lua) | [next](02-clean.lua)

Project is a type to describe all the data to be used by a given model. Geospatial
data can be stored in different sources, with different formats and different
information to describe how to access data. For example, only a file name is needed
to open a shapefile, while PostGIS tables require a host, port, user, password, and
the name of the table. A project encapsulates how to access such data and organises
them, storing all the information related to each data source internally.

TerraME allows the modeler to create a Project from scratch or to load one already
created in another software of TerraLib family. The simplest way to create a
Project is shown below. The code creates a variable named proj to access a project
stored in file "myproject.tview", stored in the current directory. Note that it is
necessary to import gis package in order to use Project.

]]

import("gis")

proj = Project{
    file = "myproject.tview"
}

--[[

After running this script, the file "myproject.tview" was created in the same
directory of this script. Note that, if you run this script again, it will not
create "myproject.tview" again, as it already exists.

]]

