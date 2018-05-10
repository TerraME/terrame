--[[ [previous](08-arapiuns-icon.lua) | [contents](../00-contents.lua) | [next](10-arapiuns-report.lua)

The route on the Arapiuns river can be added as a View. When adding trajectories,
the final application shows a moving arrow in the trajectory. This View has
arguments to describe the color of the trajectory, its width, and the time
necessary for the moving arrow to run from the beginning to the end of
the trajectory.

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
	base = "roadmap",
	title = "Arapiuns settlements",
	villages = View{
		select = {"Nome", "UC"},
		value = {0, 1},
		icon = {"home.png", "forest.png"}, 
		label = {"PAE Lago Grande", "Conservation Unit"},
		download = true,
		description = "Riverine settlements."
	},
	trajectory = View{
		description = "Route on the Arapiuns River.",
		width = 2,
		border = "blue",
		icon = {
			time = 100
		}
	}
}

