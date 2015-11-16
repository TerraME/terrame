--#########################################################################################
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP -- www.terrame.org
-- 
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
-- 
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
-- 
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
-- 
-- Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
--          Rodrigo Avancini
--#########################################################################################

Project_ = {
	type_ = "Project",
	--- Add a new layer to the project. This layer can be stored in a database, 
	-- a file, or even a web service.
	-- @arg data.source A string with the data source. See table below:
	-- @tabular source
	-- Source & Description & Mandatory arguments & Optional arguments \
	-- "postgis" & A connection to a PostGIS database. & password, layer & user, port, host \
	-- "shapefile" & A shapefile according to ESRI definition. & file, layer & \
	-- "webservice" & A web service & host, layer & \
	-- @arg data.layer Name of the layer to be created.
	-- @arg data.host String with the host where the database is stored.
	-- The default value is "localhost".
	-- @arg data.port Number with the port of the connection. The default value is the standard port
	-- of the DBMS. For example, MySQL uses 3306 as standard port.
	-- @arg data.user String with the username. The default value is "".
	-- @arg data.password A string with the password.
	-- @arg data.file A string with the location of the file to be loaded.
	-- @usage -- DONTRUN
	-- import("fillcell")
	--
	-- proj = Project{
	--     file = "myproject.tview"
	-- }
	--
	-- proj:addLayer{
	--     layer = "roads",
	--     user = "root",
	--     password = "abc123",
	--     table = "roads"
	-- }
	addLayer = function(self, data)	
	end,
	--- Add a new CellularLayer to the project.
	-- @arg data.layer Name of the layer to be created.
	-- @arg data.input A layer whose spatial coverage will be used to create the CellularLayer.
	-- @arg data.box A boolean value indicating whether the CellularLayer will fill the
	-- box from the input layer (true) or only the minimal set of cells that cover all the
	-- input data (false, default).
	-- @arg data.resolution A number with the x and y resolution. It will need to be
	-- measured in the same projection of the input layer.
	-- @usage -- DONTRUN
	-- proj:addCellularLayer{
	--     input = "amazonia-states",
	--     layer = "cells",
	--     resolution = 5e4 -- 50x50km
	-- }
	addCellularLayer = function(self, data)
	end
}

--- A TerraView project. It can handle data connections and create
-- layers.
-- @arg data.file A string with the file name to be used. If the
-- file does not exist then it will be created.
-- @usage -- DONTRUN
-- import("fillcell")
--
-- proj = Project{
--     file = "myproject.tview"
-- }
function Project(data)
end

