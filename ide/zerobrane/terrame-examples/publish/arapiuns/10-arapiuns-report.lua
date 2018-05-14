--[[ [previous](09-arapiuns-trajectory.lua) | [contents](../00-contents.lua) | [next](../wms/11-wms-project.lua)

The final version of the arapiuns example uses attribute data and images
to create a report describing each settlement. The attributes 'IDDCM' 
(age of the village) and 'NPES' (population of the village) were normalized
values, and therefore they needed to be recomputed in order to be displayed.

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
		description = "Riverine settlements.",
		report = function(cell)
			local report = Report{
				title = cell.Nome,
				author = "Escada et. al (2013)"
			}

			report:addImage("images/"..cell.Nome..".jpg")

			local age = math.ceil(130 * cell.IDDCM / 0.77)
			local pop = math.ceil(350 * cell.NPES / 0.8)

			local text = "The community "..cell.Nome.." was founded "..age..
				" years ago and has around "..pop.." inhabitants."

			report:addText(text)

			return report
		end
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

