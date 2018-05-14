--[[ [previous](06-arapiuns-project.lua) | [contents](../00-contents.lua) | [next](08-arapiuns-icon.lua)

The first version of this application includes only the villages. The application
is then saved in the directory arapiunsWebMap. Note that the application now
allows the original data to be saved by the user (download = true).

]]

import("gis")
import("publish")

Project{
	file = "arapiuns.tview",
	clean = true,
	trajectory = "arapiuns_traj.shp",
	villages = "AllCmmTab_210316OK.shp"
}

Application{
	project = "arapiuns.tview",
	description = "Small application about settlements in Arapiuns river.",
	title = "Arapiuns settlements",
	base = "roadmap",
	villages = View{
		download = true,
		description = "Riverine settlements."
	}
}

