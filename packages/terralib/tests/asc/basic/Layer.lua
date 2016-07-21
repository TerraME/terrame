-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

return {
    Layer = function(unitTest)
        local projName = "asc_basic.tview"


        if isFile(projName) then
            rmFile(projName)
        end

        local proj = Project {
            file = projName,
            clean = true
        }

        local layerName1 = "Biomassa_layer"

        Layer {
            project = proj,
            name = layerName1,
            file = filePath("biomassa-manaus.asc", "terralib")
        }

        local filePath1 = "biomassa_cells_asc_basic.shp"

        if isFile(filePath1) then
            rmFile(filePath1)
        end

        local clName1 = "Biomassa_Cells"

        local cl1 = Layer {
            project = proj,
            source = "shp",
            input = layerName1,
            name = clName1,
            resolution = 60e3,
            file = filePath1
        }

        unitTest:assertEquals(clName1, cl1.name)
        unitTest:assertEquals(cl1.source, "shp")
        unitTest:assertEquals(cl1.file, _Gtme.makePathCompatibleToAllOS(currentDir() .. "/" .. filePath1))

        if isFile(filePath1) then
            rmFile(filePath1)
        end

        if isFile(projName) then
            rmFile(projName)
        end
    end,
    representation = function(unitTest)
        local projName = "cellular_layer_fill_asc_repr.tview"

        if isFile(projName) then
            rmFile(projName)
        end

        local proj = Project {
            file = projName,
            clean = true
        }

        local vegType = "Biomassa_layer"
        local l = Layer {
            project = proj,
            name = vegType,
            file = filePath("biomassa-manaus.asc", "terralib")
        }

        unitTest:assertEquals(l:representation(), "raster")

        if isFile(projName) then
            rmFile(projName)
        end
    end,
    bands = function(unitTest)
        local projName = "cellular_layer_fill_asc_repr.tview"

        if isFile(projName) then
            rmFile(projName)
        end

        local proj = Project {
            file = projName,
            clean = true
        }

        local vegType = "Biomassa_layer"
        local l = Layer {
            project = proj,
            name = vegType,
            file = filePath("biomassa-manaus.asc", "terralib")
        }

        unitTest:assertEquals(l:bands(), 1)

        if isFile(projName) then
            rmFile(projName)
        end
    end,
    __tostring = function(unitTest)
        local projName = "cellular_layer_print_asc.tview"

        if isFile(projName) then
            rmFile(projName)
        end

        local proj = Project {
            file = projName,
            clean = true
        }

        local layerName1 = "Biomassa_layer"

        local l = Layer {
            project = proj,
            name = layerName1,
            file = filePath("biomassa-manaus.asc", "terralib")
        }

        unitTest:assertEquals(tostring(l), [[file     string [C:\TerraME\bin\packages\terralib\data\biomassa-manaus.asc]
name     string [Biomassa_layer]
project  Project
rep      string [raster]
sid      string [8e9b98cc-a511-4b41-9faf-5d67001c7058]
source   string [asc]
]], 33)
        unitTest:assertFile(projName)

        if isFile(projName) then
            rmFile(projName)
        end
    end
}

