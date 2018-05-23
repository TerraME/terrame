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
	Layer = function(unitTest)
		local projName = "sampa_alternative.tview"

		local proj1 = Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "SAMPA"
		}

		local layerName1 = "Sampa"
		local layer1 = Layer{
			project = proj1,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local host
		local port
		local password = "postgres"
		local database = "postgis_22_sample"
		local tableName = "sampa"

		local data = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = true
		}

		layer1:export(data)

		local layerName2 = "SampaDB"
		Layer{
			project = proj1,
			source = "postgis",
			name = layerName2,
			password = password,
			database = database,
			table = tableName
		}

		local layerAlreadyExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName2.."' already exists in the Project.")

		local sourceMandatory = function()
			Layer{
				project = proj1,
				-- source = "postgis",
				name = layerName2,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(sourceMandatory, mandatoryArgumentMsg("source"))

		layerName2 = "SampaDB2"

		local nameMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				--name = layerName2,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(nameMandatory, mandatoryArgumentMsg("name"))

		local passMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				--password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(passMandatory, mandatoryArgumentMsg("password"))

		local dbMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				password = password,
				--database = database,
				table = tableName
			}
		end

		unitTest:assertError(dbMandatory, mandatoryArgumentMsg("database"))

		local sourceNotString = function()
			Layer{
				project = proj1,
				source = 123,
				name = layerName2,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(sourceNotString, incompatibleTypeMsg("source", "string", 123))

		local layerNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = 123,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(layerNotString, incompatibleTypeMsg("name", "string", 123))

		local hostNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = 123,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(hostNotString, incompatibleTypeMsg("host", "string", 123))

		local portNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = "123",
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(portNotString, incompatibleTypeMsg("port", "number", "123"))

		local userNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = 123,
				password = password,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(userNotString, incompatibleTypeMsg("user", "string", 123))

		local passNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				password = 123,
				database = database,
				table = tableName
			}
		end

		unitTest:assertError(passNotString, incompatibleTypeMsg("password", "string", 123))

		local dbNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				password = password,
				database = 123,
				table = tableName
			}
		end

		unitTest:assertError(dbNotString, incompatibleTypeMsg("database", "string", 123))

		local tableNotString = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				password = password,
				database = database,
				table = 123
			}
		end

		unitTest:assertError(tableNotString, incompatibleTypeMsg("table", "string", 123))

		local wrongHost = "inotexist"
		local hostNonExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = wrongHost,
				port = port,
				password = password,
				database = database,
				table = tableName
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: Name or service not known\n.", 16) -- the last paramerter is the difference related to system idiom
		elseif sessionInfo().system == "mac" then
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: nodename nor servname provided, or not known\n.")
		else
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: Unknown host\n.", 12)
				-- it can also be "Unknown server error"
		end

		local wrongPort = 2345
		local portWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = wrongPort,
				password = password,
				database = database,
				table = tableName
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.", 16) -- the last paramerter is the difference related to system idiom
		elseif sessionInfo().system == "mac" then
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (::1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n"..
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.")
		else
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused (0x0000274D/10061)\n"..
				"\tIs the server running on host \"localhost\" (::1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n"..
				"could not connect to server: Connection refused (0x0000274D/10061)\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.")
		end

		local nonuser = "usernotexists"
		local userNotExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = nonuser,
				password = password,
				database = database,
				table = tableName
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"usernotexists\"\n"..
				"FATAL:  password authentication failed for user \"usernotexists\"\n.")
		else
			unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"usernotexists\"\n.")
		end

		local wrongPass
		local passWrong
		wrongPass = "passiswrong"
		passWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				password = wrongPass,
				database = database,
				table = tableName
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n"..
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		else
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		end

		local tableWrong = "thetablenotexists"
		local tableNotExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				password = getConfig().password,
				database = database,
				table = tableWrong
			}
		end

		unitTest:assertError(tableNotExists, "Is not possible add the Layer. Table '"..tableWrong.."' does not exist.") -- SKIP

		File(projName):deleteIfExists()

		projName = "amazonia.tview"

		File(projName):deleteIfExists()

		local proj = Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}

		layerName1 = "Sampa"
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "gis")
		}

		local clName1 = "Sampa_Cells"
		local tName1 = "add_cellslayer_alternative"

		host = "localhost"
		port = "5432"
		password = getConfig().password
		database = "postgis_22_sample"

		local inputMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				--input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1,
				clean = true
			}
		end

		unitTest:assertError(inputMandatory, mandatoryArgumentMsg("input"))

		local missingArgument = function()
			Layer{
				project = proj,
				--source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				--database = database,
				table = tName1
			}
		end

		unitTest:assertError(missingArgument, "At least one of the following arguments must be used: 'file', 'source', or 'database'.")

		local layerMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				--name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("name"))

		passMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				--password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(passMandatory, mandatoryArgumentMsg("password"))

		dbMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				--database = database,
				table = tName1
			}
		end

		unitTest:assertError(dbMandatory, mandatoryArgumentMsg("database"))

		sourceNotString = function()
			Layer{
				project = proj,
				source = 123,
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(sourceNotString, incompatibleTypeMsg("source", "string", 123))

		local inputNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = 123,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(inputNotString, incompatibleTypeMsg("input", "string", 123))

		layerNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = 123,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(layerNotString, incompatibleTypeMsg("name", "string", 123))

		local resNotNumber = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = "10000",
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(resNotNumber, incompatibleTypeMsg("resolution", "number", "10000"))

		local resMustBePositive = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = -1,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(resMustBePositive, positiveArgumentMsg("resolution", -1))

		hostNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				host = 123,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(hostNotString, incompatibleTypeMsg("host", "string", 123))

		portNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				port = "123",
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(portNotString, incompatibleTypeMsg("port", "number", "123"))

		passNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = 123,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(passNotString, incompatibleTypeMsg("password", "string", 123))

		dbNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = 123,
				table = tName1
			}
		end

		unitTest:assertError(dbNotString, incompatibleTypeMsg("database", "string", 123))

		tableNotString = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = password,
				database = database,
				table = 123
			}
		end

		unitTest:assertError(tableNotString, incompatibleTypeMsg("table", "string", 123))

		data.table = tName1.."b"
		data.encoding = "LATIN1"
		TerraLib().dropPgTable(data)

		local boxNonBoolean = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				box = 123,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(boxNonBoolean, incompatibleTypeMsg("box", "boolean", 123))

		wrongHost = "inotexist"
		hostNonExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				host = wrongHost,
				password = password,
				database = database,
				table = tName1
			}
		end


		if sessionInfo().system == "linux" then
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: Name or service not known\n.", 16) -- the last paramerter is the difference related to system idiom
		elseif sessionInfo().system == "mac" then
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: nodename nor servname provided, or not known\n.")
		else
			unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not translate host name \"inotexist\" to address: Unknown host\n.", 12)
				-- it can also be "Unknown server error"
		end

		wrongPort = 2345
		portWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				port = wrongPort,
				password = password,
				database = database,
				table = tName1
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.", 8) -- the last paramerter is the difference related to system idiom
		elseif sessionInfo().system == "mac" then
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (::1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n"..
				"could not connect to server: Connection refused\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.")
		else
			unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"could not connect to server: Connection refused (0x0000274D/10061)\n"..
				"\tIs the server running on host \"localhost\" (::1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n"..
				"could not connect to server: Connection refused (0x0000274D/10061)\n"..
				"\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n"..
				"\tTCP/IP connections on port 2345?\n.")
		end

		nonuser = "usernotexists"
		userNotExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = nonuser,
				password = password,
				database = database,
				table = tName1
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"usernotexists\"\n"..
				"FATAL:  password authentication failed for user \"usernotexists\"\n.")
		else
			unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"usernotexists\"\n.")
		end

		wrongPass = "passiswrong"
		passWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				password = wrongPass,
				database = database,
				table = tName1
			}
		end

		if sessionInfo().system == "linux" then
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n"..
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		else
			unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: ".. -- SKIP
				"FATAL:  password authentication failed for user \"postgres\"\n.")
		end

		host = "localhost"
		port = "5432"

		local pgLayer = Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			password = password,
			database = database,
			table = tName1,
			clean = true
		}

		local clName2 = "Another_Setores_Cells"
		local tableAlreadyExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName2,
				resolution = 0.7,
				password = password,
				database = database,
				table = tName1
			}
		end

		unitTest:assertError(tableAlreadyExists, "Table '"..tName1.."' already exists.")

		pgLayer:delete()

		if File(projName):exists() then
			File(projName):deleteIfExists()
		end
	end,
	export = function(unitTest)
		local proj = Project {
			file = "export_postgis_alt.tview",
			clean = true
		}

		local filePath1 = filePath("itaituba-census.shp", "gis")

		local layerName1 = "setores"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}

		local overwrite = true
		local password = "postgres"
		local database = "postgis_22_sample"

		local pgSourceError = function()
			local pgData = {
				source = "postgi",
				password = password,
				database = database,
				overwrite = overwrite
			}

			layer1:export(pgData)
		end
		unitTest:assertError(pgSourceError, "The only supported database is 'postgis'. Please, set source = \"postgis\".")

		local selectNoExist = function()
			local pgData = {
				source = "postgis",
				password = password,
				database = database,
				overwrite = overwrite,
				select = {"uf"}
			}
			layer1:export(pgData)
		end
		unitTest:assertError(selectNoExist,  "There is no attribute 'uf' in 'setores'.")

		local layer2 = Layer{
			project = proj,
			name = "Prodes",
			file = filePath("test/prodes_polyc_10k.tif", "gis")
		}

		local ras2vecError = function()
			local pgData = {
				source = "postgis",
				password = password,
				database = database,
				overwrite = overwrite
			}
			layer2:export(pgData)
		end

		unitTest:assertError(ras2vecError, "Raster layer 'Prodes' cannot be exported as vector data. Please, use 'polygonize' function instead.")

		local pgData = {
			source = "postgis",
			password = password,
			database = database,
			overwrite = overwrite
		}

		layer1:export(pgData)

		local layer3 = Layer{
			project = proj,
			source = "postgis",
			name = "PgLayer",
			password = password,
			database = database,
			table = string.lower(layer1.name)
		}

		local vec2rasError = function()
			layer3:export{file = "pg2tif.tif"}
		end

		unitTest:assertError(vec2rasError, "Vector layer 'PgLayer' cannot be exported as raster data.")

		layer3:delete()
		proj.file:delete()
	end,
	drop = function(unitTest)
		local proj = Project {
			file = "drop_pg_alt.tview",
			clean = true
		}

		local l1 = Layer{
			project = proj,
			name = "Sampa",
			file = filePath("test/sampa.shp", "gis")
		}

		local dropError = function()
			l1:drop()
		end

		unitTest:assertError(dropError, "Function 'drop' only works with PostGIS database.")
		proj.file:delete()
	end
}

