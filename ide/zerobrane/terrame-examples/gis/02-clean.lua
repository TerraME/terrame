--[[ [previous](01-project.lua) | [contents](00-contents.lua) | [next](03-layer.lua)

As default, TerraME never overwrites a Project file. To allow the script to create
the project file again even if the file was already created by a previous
execution of the script, add clean = true as argument to Project, such as in the
code below. This is a common procedure to avoid getting some unwanted data
stored in a previous version of the project.

]]

import("gis")

proj = Project{
    file = "myproject.tview",
    clean = true
}

