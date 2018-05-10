--[[ [previous](../brazil/05-brazil-report.lua) | [contents](../00-contents.lua) | [next](07-arapiuns-villages.lua)

The second example of this tutorial creates an application that uses data collected
from a fieldwork that visited several settlements in Arapiuns river, in Para state,
Brazil. This application uses two datasets stored as shapefiles. One contains the
settlements, while the other stores the trajectory of the boat along the fieldwork.
The two layers are named villages and trajectory, respectively.

]]

import("gis")

Project{
	file = "arapiuns.tview",
	clean = true,
	trajectory = "arapiuns_traj.shp",
	villages = "AllCmmTab_210316OK.shp"
}

