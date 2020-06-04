-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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
	export = function(unitTest)
		local projName = "layer_func_alt.tview"

		local proj = Project {
			file = projName,
			clean = true
		}

		local filePath1 = filePath("itaituba-census.shp", "gis")

		local layerName1 = "setores"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local invalidFile = function()
			layer1:export{file = "invalid.org"}
		end

		unitTest:assertError(invalidFile, invalidFileExtensionMsg("file", "org"))

		local selectNoExist = function()
			layer1:export{select = {"uf", "pop"}, source = "shp", file = "shape.shp"}
		end
		unitTest:assertError(selectNoExist, "There are no attributes 'uf' and 'pop' in 'setores'.")

		local selectWrongType = function()
			layer1:export{select = true, source = "shp", file = "shape.shp"}
		end

		unitTest:assertError(selectWrongType, incompatibleTypeMsg("select", "table", true))

		local vec2rasError = function()
			layer1:export{file = "shp2tif.tif"}
		end

		unitTest:assertError(vec2rasError, "Vector layer 'setores' cannot be exported as raster data.")

		proj.file:delete()
	end,
	check = function(unitTest)
		local proj = Project {
			file = "check_geom.qgs",
			clean = true
		}

		local defectFile = filePath("test/biomassa_unfixable.shp", "gis")
		File("biomassa_unfixable.shp"):deleteIfExists()
		defectFile:copy(currentDir())

		local l1 = Layer{
			project = proj,
			name = "DefectBio",
			file = "biomassa_unfixable.shp"
		}

		local customWarningBkp = customWarning
		customWarning = function(msg)
			if string.find(msg, "5502300.9611873") then
				unitTest:assertEquals(warnMsg, "The following problems were found in layer 'DefectBio' geometries:\n" --SKIP
											.."1. FID 404: Self-intersection (5502300.9611873, 8212207.8945397).\n"
											.."2. FID 448: Self-intersection (5499667.9683502, 8209876.5162455).\n"
											.."3. FID 607: Self-intersection (5495108.3147666, 8215278.0127216).\n"
											.."4. FID 640: Self-intersection (5494485.5853231, 8210317.9905857).\n"
											.."5. FID 763: Self-intersection (5488466.0305929, 8212219.2367292).")
			else
				unitTest:assertEquals(msg, "The following problems were found in layer 'DefectBio' geometries:\n" --SKIP
										.."1. FID 404: Self-intersection (5502436.5275601, 8211973.5861861).\n"
										.."2. FID 448: Self-intersection (5499667.9683502, 8209876.5162455).\n"
										.."3. FID 607: Self-intersection (5495108.3147666, 8215278.0127216).\n"
										.."4. FID 640: Self-intersection (5494485.5853231, 8210317.9905857).\n"
										.."5. FID 763: Self-intersection (5488466.0305929, 8212219.2367292).")
			end
		end

		local customErrorBkp = customError
		customError = function(msg)
			unitTest:assertEquals(msg, "The following problem was found in layer 'DefectBio' geometries:\n"
							.."1. FID 637: Self-intersection (5494485.5853231, 8210317.9905857).\n"
							.."The use of this data can produce inconsistent results.")
		end

		l1:check(true, false)

		customWarning = customWarningBkp
		customError = customErrorBkp

		l1:delete()
		proj.file:delete()
	end
}

