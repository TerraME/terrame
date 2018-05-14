--[[ [previous](04-brazil-states.lua) | [contents](../00-contents.lua) | [next](../arapiuns/06-arapiuns-project.lua)

Finally, we now add a [Report](http://www.terrame.org/packages/doc/publish/doc/files/Report.html) to each biome. When a View has a report, it creates
a report to each of its geometries using the attributes of the respective
geometry. A report is then activated when one clicks on a given object in the
application. The code below adds an image to the report and use other attributes
as text. Open the shapefile in your favorite GIS to see the data.

]]

import("gis")
import("publish")

Project{
	file = "brazil.tview",
	clean = true,
	biomes = "br_biomes.shp",
	states = "br_states.shp"
}

Application{
	project = "brazil.tview",
	title = "Brazil Application",
	description = "Small application with some data related to Brazil.",
	biomes = View{
		select = "name",
		color = "Set2",
		description = "Brazilian Biomes. Source:IBGE.",
		report = function(cell)
			local report = Report{
				title = cell.name,
				author = "IBGE"
			}

			report:addImage("biomes/"..cell.name..".jpg")
			report:addText(cell.name.." covers approximately "..cell.cover.."% of Brazil.")
			report:addText("For more information, please visit "..link(cell.link, "here")..".")

			return report
		end
	},
	states = View{
		color = "yellow",
		description = "Brazilian States.",
	}
}

