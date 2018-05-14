--[[ [previous](../arapiuns/10-arapiuns-report.lua) | [contents](../00-contents.lua) | [next](12-wms-data.lua)

The last example uses data already stored into a WMS (Web Map Service).
This data is related to the Brazilian Amazonia. As the data is stored
in the Internet, it is necessary to import each Layer manually, using
the service host, its name, and the map name. It also uses two shapefiles
with the Amazon Biome and Legal Amazon.

]]

import("gis")
import("publish")

p = Project{
	file = "wms.tview",
	clean = true,
	amazon = "limiteAML.shp",
	biome = "BiomaAmazonia.shp"
}

service = "http://35.198.39.192/geoserver/wms"

Layer{project = p, service = service, name = "prodes_2000", map = "amazon:prodes_2000"}
Layer{project = p, service = service, name = "prodes_2005", map = "amazon:prodes_2005"}
Layer{project = p, service = service, name = "prodes_2010", map = "amazon:prodes_2010"}
Layer{project = p, service = service, name = "prodes_2015", map = "amazon:prodes_2015"}

Layer{project = p, service = service, name = "conservationUnits_2000", map = "amazon:conservationUnits_2000"}
Layer{project = p, service = service, name = "conservationUnits_2005", map = "amazon:conservationUnits_2005"}
Layer{project = p, service = service, name = "conservationUnits_2010", map = "amazon:conservationUnits_2010"}
Layer{project = p, service = service, name = "conservationUnits_2015", map = "amazon:conservationUnits_2015"}

