-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
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
-------------------------------------------------------------------------------------------

return {
	geometry = function(unitTest)
		local point = {
			x = 74,
			y = 23.5,
			srid = 4326
		}

		local pt = _Gtme.terralib_mod_binding_lua.te.gm.Point(point.x, point.y, point.srid)

		unitTest:assertEquals(point.x, pt:getX())
		unitTest:assertEquals(point.y, pt:getY())
		unitTest:assertEquals(0.0, pt:getDimension())
		unitTest:assertEquals(2, pt:getCoordinateDimension())
		unitTest:assertEquals("Point", pt:getGeometryType())
		unitTest:assertEquals(point.srid, pt:getSRID())
		unitTest:assertEquals(1, pt:getNPoints())
		unitTest:assertEquals("point(74 23.5)", pt:asText())
		unitTest:assertEquals("", pt:asBinary(0))
		unitTest:assertEquals(21, pt:getWkbSize())
		point.srid = 1234
		pt:setSRID(point.srid)
		point.x = 40
		pt:setX(point.x)
		point.y = 20
		pt:setY(point.y)
		unitTest:assertEquals(point.srid, pt:getSRID())
		unitTest:assertEquals(point.x, pt:getX())
		unitTest:assertEquals(point.y, pt:getY())
		unitTest:assertType(pt:getBoundary(), "userdata")
		unitTest:assertType(pt:getEnvelope(), "userdata")
		unitTest:assertType(pt:getMBR(), "userdata")
		unitTest:assert(not pt:isEmpty())
		unitTest:assert(not pt:overlaps(pt))
		unitTest:assert(not pt:relate(pt, "ttttttttt"))
		unitTest:assert(not pt:touches(pt))
		unitTest:assert(not pt:crosses(pt))
		unitTest:assert(not pt:is3D())
		unitTest:assert(not pt:isMeasured())
		unitTest:assert(not pt:disjoint(pt))
		unitTest:assert(pt:isSimple())
		unitTest:assert(pt:isValid())
		unitTest:assert(pt:equals(pt))
		unitTest:assert(pt:intersects(pt))
		unitTest:assert(pt:within(pt))
		unitTest:assert(pt:contains(pt))
		unitTest:assert(pt:covers(pt))
		unitTest:assert(pt:coveredBy(pt))
	end,
	point = function(unitTest)
		local cs = CellularSpace{
			file = filePath("itaituba-localities.shp", "terralib"),
			geometry = true
		}

		forEachCell(cs, function(cell)
			local geometry = TerraLib:castGeomToSubtype(cell.geom:getGeometryN(0))

			unitTest:assert(geometry:getX() > 0)
			unitTest:assert(geometry:getY() > 0)
			unitTest:assertEquals(1, cell.geom:getNPoints())
			unitTest:assertEquals("MultiPoint", cell.geom:getGeometryType())
			unitTest:assert(cell.geom:intersects(cell.geom))
			unitTest:assert(cell.geom:within(cell.geom))
			unitTest:assert(cell.geom:contains(cell.geom))
			unitTest:assert(cell.geom:isValid())
		end)
	end,
	line = function(unitTest)
		local cs = CellularSpace{
			file = filePath("emas-river.shp", "terralib"),
			geometry = true
		}

		forEachCell(cs, function(cell)
			local geometry = TerraLib:castGeomToSubtype(cell.geom:getGeometryN(0))
			local length = geometry:getLength()

			unitTest:assert(length ~= nil)
			unitTest:assertEquals("number", type(length))
			local nPoint = geometry:getNPoints()

			for i = 0, nPoint do
				unitTest:assert(geometry:getX(i) ~= nil)
				unitTest:assertType(geometry:getX(i), "number")
				unitTest:assert(geometry:getY(i) ~= nil)
				unitTest:assertType(geometry:getX(i), "number")
			end

			unitTest:assertEquals("MultiLineString", cell.geom:getGeometryType())
			local npoints = cell.geom:getNPoints()

			unitTest:assert(npoints > 0)
			unitTest:assert(cell.geom:intersects(cell.geom))
			unitTest:assert(cell.geom:within(cell.geom))
			unitTest:assert(cell.geom:contains(cell.geom))
			unitTest:assert(cell.geom:isValid())
		end)
	end,
	polygon = function(unitTest)
		local cs = CellularSpace{
			file = filePath("amazonia-limit.shp", "terralib"),
			geometry = true
		}

		forEachCell(cs, function(cell)
			local geometry = TerraLib:castGeomToSubtype(cell.geom:getGeometryN(0))
			local centroid = TerraLib:castGeomToSubtype(geometry:getCentroid())
			local ring = TerraLib:castGeomToSubtype(geometry:getExteriorRing())
			local nPoint = ring:getNPoints()

			for i = 0, nPoint do
				unitTest:assertNotNil(ring:getX(i))
				unitTest:assertType(ring:getX(i), "number")
				unitTest:assertNotNil(ring:getY(i))
				unitTest:assertType(ring:getX(i), "number")
			end

			unitTest:assert(centroid:getX() < 0)
			unitTest:assert(centroid:getY() < 0)
			unitTest:assertEquals("MultiPolygon", cell.geom:getGeometryType())
			local npoints = cell.geom:getNPoints()

			unitTest:assert(npoints > 0)
			unitTest:assert(cell.geom:intersects(cell.geom))
			unitTest:assert(cell.geom:within(cell.geom))
			unitTest:assert(cell.geom:contains(cell.geom))
			unitTest:assert(cell.geom:isValid())
		end)
	end
}
