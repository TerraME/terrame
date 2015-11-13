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

CellLayer_ = {
	type_ = "CellLayer",
	--- Function to create a new attribute for a CellularSpace. It has different strategies
	-- for any geospatial data.
	-- @arg data.newatt Name of the new column.
	-- @arg data.target A raster or theme.
	-- @arg data.strategy The way to calculate the attribute of each cell. See the
	-- table below:
	-- @tabular strategy
	-- Strategy & Description & Mandatory arguments, Optional arguments \
	-- "area" & Total area of overlay between the cell and a layer of polygons. \
	-- "average" & Average of an attribute of the objects that have some intersection with the
	-- cell, without taking into account their geometric properties. \
	-- "averagewba" & Average weighted by area, based on the proportion of the intersection area.
	-- Useful when you want to distribute atributes that represent averages, such as per capita income. \
	-- "count" & Number of objects that have some overlay with the cell (requires argument geometry). \
	-- "distance" & Distance to the nearest object of a chosen geometry (requires argument geometry). \
	-- "length" & Total length of overlay between the cell and a layer of lines. \
	-- "minimum" & Minimum value of an attribute among the objects that have some intersection with
	-- the cell, without taking into account their geometric properties. \
	-- "maximum" & Maximum value of  an attribute among the objects that have some intersection with the
	-- cell, without taking into account their geometric properties. \
	-- "majority" & More common value in the objects that have some intersection with the cell, 
	-- without taking into account their geometric properties. \
	-- "percentage" & Percentages of each class of a raster data. It creates one attribute for each
	-- class of the raster. \
	-- "presence" & Boolean value pointing out whether some object has an overlay with the cell. \
	-- "stdev" & Standard deviation of an attribute of the objects that have some intersection with the
	-- cell, without taking into account their geometric properties. \
	-- "sum" & Sum of an attribute of the objects that have some intersection with the cell, without
	-- taking into account their geometric properties. \
	-- "sumwba" & Sum weighted by area, based on the proportion of the intersection area. Useful when
	-- one wants to preserve the total amount in both layers, such as population size. \
	-- @arg data.geometry The geometry to compute the attribute. One of "point", "polygon", "line", "raster".
	-- @arg data.att The atribute used to compute the new column. It is only required when the strategy uses an attribute (such as average, sum, etc.)
	-- @arg data.proportion Whether the calculation will be based on the intersection area, or the weights are equal for each object whth some overlap.
	-- @arg data.raster An object of class \code{aRTraster}, used only in the strategy \dQuote{weighbra}.}
	-- @arg data.validValues A set of valid raster values, used only in the strategy \dQuote{weighbra}. The other values are ignored.}
	-- @arg data.dummy A value that will ignored when computing the strategy, used only for raster strategies.
	-- @arg data.default A value that will be used to fill a cell whose attribute cannot be computed.
	-- Used only for raster strategies.
	-- @arg data.band An integer value representing the band of the raster to be used.
	fillCell = function(data)
	end
}

--- A Layer of cells build from a database.
function CellLayer(data)
end

