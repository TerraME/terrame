--[[ [previous](03-layer.lua) | [contents](00-contents.lua) | [next](05-cellularspace.lua)

A common procedure when one wants to create a Project is to store all files in the
same directory. The best way to create a Project with all the shapefiles of a
given directory is by using argument directory. In this case, it searches for all
shp and tif files within the given directory and adds them to the project. The
name of the layer will be the file name without extension.

]]

import("gis")

proj = Project{
	file = "myproject.tview",
	directory = ".", -- all files of the directory where this file is saved
	clean = true
}

print(proj)

--[[

Note that, as in the previous script we needed to set the epsg manually, if we use
the code above, the epsg of the layers will not be properly set. In this case, we
will continue with the previous code in the next scripts.

]]

