--[[ [previous](01-brazil-project.lua) | [contents](../00-contents.lua) | [next](03-brazil-color.lua)

After creating the project, we can now create an [Application](http://www.terrame.org/packages/doc/publish/doc/files/Application.html). It has three
mandatory arguments: project (the name of the project we have just created),
title (the title of the application), and description (a text shown in the
beginning of the application). It also can have a set of [Views](http://www.terrame.org/packages/doc/publish/doc/files/View.html). Each View has
a name that must match the name of the layer in the project. In the code below
we use the biomes and add a description to the layer, that will be shown in
the application.

After running the code below, the application will be created in the computer in
the same directory where this file is stored, in a directory called brazilWebMap.
Additionally, the application will be opened in your browser. If your default web
browser is not Firefox and the application is not shown correctly, please open it
in Firefox. Whenever the application is available online, it will be shown in
different browsers properly, but some browsers do not support opening such
applications locally.

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
	biomes = View{ -- biomes is the name of the layer above in the project
		description = "Brazilian Biomes, from IBGE.",
	}
}

