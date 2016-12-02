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
			file = filePath("test/sampa.shp", "terralib")
		}

		local host
		local port
		local user = "postgres"
		local password = "postgres"
		local database = "postgis_22_sample"
		local encoding
		local tableName = "sampa"

		local data = {
			source = "postgis",
			user = user,
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
			user = user,
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
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(layerAlreadyExists, "Layer '"..layerName2.."' already exists in the Project.")
			
		TerraLib{}:dropPgTable(data)
		proj1.layers[layerName2] = nil

		local sourceMandatory = function()
			Layer{
				project = proj1,
				-- source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(sourceMandatory, mandatoryArgumentMsg("source"))

	if sessionInfo().system ~= "mac" then -- TODO(#1379)
		local nameMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				--name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(nameMandatory, mandatoryArgumentMsg("name")) -- SKIP
	end

		local userMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				--user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(userMandatory, mandatoryArgumentMsg("user"))

		local passMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
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
				user = user,
				password = password,
				--database = database,
				table = tableName
			}
		end
		unitTest:assertError(dbMandatory, mandatoryArgumentMsg("database"))

		local tableMandatory = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				--table = tableName
			}
		end
		unitTest:assertError(tableMandatory, mandatoryArgumentMsg("table"))

		local fileUnnecessary = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				port = port,
				user = user,
				password = password,
				database = database,
				table = tableName,
				file = filePath("test/sampa.shp", "terralib")
			}
		end
		unitTest:assertError(fileUnnecessary, unnecessaryArgumentMsg("file"))

		local sourceNotString = function()
			Layer{
				project = proj1,
				source = 123,
				name = layerName2,
				port = port,
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: "
								.."could not translate host name \""..wrongHost.."\" to address: Unknown host\n.", 38) -- #1303

		local wrongPort = 2345
		local portWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = wrongPort,
				user = user,
				password = password,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: could not connect to server: Connection refused (0x0000274D/10061)\n\tIs the server running on host \"localhost\" (::1) and accepting\n\tTCP/IP connections on port 2345?\ncould not connect to server: Connection refused (0x0000274D/10061)\n\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n\tTCP/IP connections on port 2345?\n.", 188) -- #1303

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
		unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..nonuser.."\"\n.", 64) -- #1303

		local wrongPass
		local passWrong
	if sessionInfo().system ~= "mac" then -- TODO(#1379)
		wrongPass = "passiswrong"
		passWrong = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = user,
				password = wrongPass,
				database = database,
				table = tableName
			}
		end
		unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: " -- SKIP 
							.."FATAL:  password authentication failed for user \""..user.."\"\n.", 59) -- #1303
	end

		local tableWrong = "thetablenotexists"
		local tableNotExists = function()
			Layer{
				project = proj1,
				source = "postgis",
				name = layerName2,
				host = host,
				port = port,
				user = user,
				password = getConfig().password,
				database = database,
				table = tableWrong
			}
		end
		unitTest:assertError(tableNotExists, "Is not possible add the Layer. The table '"..tableWrong.."' does not exist.")

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
			file = filePath("test/sampa.shp", "terralib")
		}

		local clName1 = "Sampa_Cells"
		local tName1 = "add_cellslayer_alternative"
		
		host = "localhost"
		port = "5432"
		user = "postgres"
		password = getConfig().password
		database = "postgis_22_sample"
		encoding = "CP1252"

		local inputMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				--input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
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
				user = user,
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
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(layerMandatory, mandatoryArgumentMsg("name"))

		userMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				--user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(userMandatory, mandatoryArgumentMsg("user"))

		passMandatory = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
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
				user = user,
				password = password,
				database = database,
				table = 123
			}
		end
		unitTest:assertError(tableNotString, incompatibleTypeMsg("table", "string", 123))

		local unnecessaryArgument = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1,
				file = filePath("test/sampa.shp", "terralib")
			}
		end
		unitTest:assertError(unnecessaryArgument, unnecessaryArgumentMsg("file"))

		local boxNonBoolean = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				box = 123,
				user = user,
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
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(hostNonExists, "It was not possible to create a connection to the given data source due to the following error: "
								.."could not translate host name \""..wrongHost.."\" to address: Unknown host\n.", 38) -- #1303

		wrongPort = 2345
		portWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				port = wrongPort,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(portWrong, "It was not possible to create a connection to the given data source due to the following error: could not connect to server: Connection refused (0x0000274D/10061)\n\tIs the server running on host \"localhost\" (::1) and accepting\n\tTCP/IP connections on port 2345?\ncould not connect to server: Connection refused (0x0000274D/10061)\n\tIs the server running on host \"localhost\" (127.0.0.1) and accepting\n\tTCP/IP connections on port 2345?\n.", 188) -- #1303
		
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
		unitTest:assertError(userNotExists, "It was not possible to create a connection to the given data source due to the following error: "
							.."FATAL:  password authentication failed for user \""..nonuser.."\"\n.", 64) -- #1303

	if sessionInfo().system ~= "mac" then -- TODO(#1379)
		wrongPass = "passiswrong"
		passWrong = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = wrongPass,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(passWrong, "It was not possible to create a connection to the given data source due to the following error: " -- SKIP
							.."FATAL:  password authentication failed for user \""..user.."\"\n.", 59) -- #1303
	end
		
		host = "localhost"
		port = "5432"
		
		local pgData = {
			type = "POSTGIS",
			host = host,
			port = port,
			user = user,
			password = password,
			database = database,
			table = tName1,
			encoding = encoding
		}
		
		TerraLib{}:dropPgTable(pgData)

		Layer{
			project = proj,
			source = "postgis",
			input = layerName1,
			name = clName1,
			resolution = 0.7,
			user = user,
			password = password,
			database = database,
			table = tName1
		}

		local clName2 = "Another_Setores_Cells"
		local tableAlreadyExists = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName2,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1
			}
		end
		unitTest:assertError(tableAlreadyExists, "The table '"..tName1.."' already exists.")

		TerraLib{}:dropPgTable(pgData)

		if File(projName):exists() then
			File(projName):deleteIfExists()
		end
		
		-- SPATIAL INDEX TEST
		proj = Project{
			file = projName,
			clean = true,
			author = "Avancini",
			title = "The Amazonia"
		}		
		
		Layer{
			project = proj,
			name = layerName1,
			file = filePath("test/sampa.shp", "terralib")
		}		
		
		local indexUnnecessary = function()
			Layer{
				project = proj,
				source = "postgis",
				input = layerName1,
				name = clName1,
				resolution = 0.7,
				user = user,
				password = password,
				database = database,
				table = tName1,
				index = true
			}
		end
		unitTest:assertError(indexUnnecessary, unnecessaryArgumentMsg("index"))
		
		proj.file:delete()
		-- // SPATIAL INDEX TEST
	end,
	export = function(unitTest)
		local projName = "layer_func_alt.tview"

		local proj = Project {
			file = projName,
			clean = true
		}
		
		local filePath1 = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
	
		local layerName1 = "setores"
		local layer1 = Layer{
			project = proj,
			name = layerName1,
			file = filePath1
		}
		
		local overwrite = true
		
		local user = "postgres"
		local password = getConfig().password
		local database = "postgis_22_sample"
		
		local pgData = {
			source = "postgi",
			user = user,
			password = password,
			database = database,
			overwrite = overwrite
		}		
		
		local pgSourceError = function()
			layer1:export(pgData)
		end
		unitTest:assertError(pgSourceError, "It only supports postgis database, use source = \"postgis\".")
		
		proj.file:deleteIfExists()
	end	
}

