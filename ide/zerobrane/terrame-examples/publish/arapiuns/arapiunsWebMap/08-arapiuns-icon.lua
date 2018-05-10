--[[ [previous](07-arapiuns-villages.lua) | [contents](../00-contents.lua) | [next](09-arapiuns-trajectory.lua)

It is possible to select the icon for the points in the data. In this example,
there are two groups of communities. Some belong to a conservation unit and
the other ones belong to a settlement project called PAE Lago Grande.
We use the attribute "Nome" of the data to identify each object and "UC" to
map its values to icons, whose files are stored in this directory. As the
available values are 0 and 1, we set labels for this values to be shown in the
application.

Note that this application has 'display = false', and therefore it is necessary
to refresh the web browser content in order to see the updated version of the
application.

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
	display = false,
	description = "Small application about settlements in Arapiuns river.",
	title = "Arapiuns settlements",
	base = "roadmap",
	villages = View{
		select = {"Nome", "UC"},
		value = {0, 1},
		icon = {"home.png", "forest.png"}, 
		label = {"PAE Lago Grande", "Conservation Unit"},
		download = true,
		description = "Riverine settlements."
	}
}

