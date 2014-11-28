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
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	CellularSpace = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port
		local mdatabase

		if mdbType == "ado" then
			mdatabase = data("cabecaDeBoi.mdb", "base")
		else
			mdatabase = "cabeca"
		end

		local error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90"
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("database"))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = {}
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("database", "string", {}))

		if dbType == "ado" then
			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = muser,
					password = mpassword,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "terralab"
				}
			end
			unitTest:assert_error(error_func, "Parameter 'database' does not support 'terralab'.")
		else
			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = muser,
					password = mpassword,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "terralab"
				}
			end
			unitTest:assert_error(error_func, "Unknown database 'terralab'.")

			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = muser,
					password = mpassword,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = ""
				}
			end
			unitTest:assert_error(error_func, "Empty database name.")
		end

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = 3,
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("layer", "string", 3))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "terralab",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, "Can't open input layer 'terralab'.")

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				layer = "terralab",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("theme"))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = 2,
				layer = "terralab",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("theme", "string", 2))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "terralab",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, "Can't open input theme 'terralab'.")

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				select = 34,
				theme = "cells90x90",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("select", "table", 34))

		--#46  add this error
		--[[
		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				select = "dfgsae",
				theme = "cells90x90",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, "Invalid 'select'...")
		--]]

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				where = 34,
				theme = "terralab",
				layer = "terralab",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("where", "string", 34))

		-- #46 add the error below
		--[[
		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				where = "terralab !~2",
				theme = "cells90x90",
				layer = "cells90x90",
				database = mdatabase
			}
		end
		unitTest:assert_error(error_func, "bad SCL command.")
		--]]


		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = 2,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("user", "string", 2))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = 2,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("password", "string", 2))

		error_func = function()
			local cs = CellularSpace{
				dbType = 2,
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("dbType", "string", 2))

		error_func = function()
			local cs = CellularSpace{
				dbType = "post",
				host = mhost,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end

		local options = {
			csv = true,
			map = true,
			mdb = true,
			mysql = true,
			shp = true,
			virtual = true
		}

		unitTest:assert_error(error_func, switchInvalidParameterMsg("post", "dbType", options))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = 34,
				user = muser,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("host", "string", 34))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = {},
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("port", "number", {}))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				password = mpassword,
				port = 34.2,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleValueMsg("port", "positive integer number", 34.2))

		error_func = function()
			local cs = CellularSpace{
				dbType = mdbType,
				host = mhost,
				user = muser,
				autoload = 123,
				password = mpassword,
				port = mport,
				theme = "cells90x90",
				layer = "cells90x90",
				database = "terralab"
		}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("autoload", "boolean", 123))

		if mdbType ~= "ado" then
			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = "terra",
					password = mpassword,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "cabeca"
				}
			end
			unitTest:assert_error(error_func, "Access denied for user ''@'localhost' to database 'cabeca'.", 24)

			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = muser,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "terralab"
				}
			end
			unitTest:assert_error(error_func, mandatoryArgumentMsg("password"))

			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = mhost,
					user = muser,
					password = "aaaaaaaa",
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "terralab"
				}
			end
			unitTest:assert_error(error_func, "Access denied for user 'root'@'localhost' (using password: YES).")
		
			error_func = function()
				local cs = CellularSpace{
					dbType = mdbType,
					host = "321456",
					user = muser,
					password = mpassword,
					port = mport,
					theme = "cells90x90",
					layer = "cells90x90",
					database = "terralab"
				}
			end
			unitTest:assert_error(error_func, "Can't connect to MySQL server on '321456' (XX).", 2)
		end
	end,
	loadNeighborhood = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port

		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			theme = "cells90x90",
			layer = "cells90x90",
			database = "cabeca"
		}

		local error_func = function()
			cs:loadNeighborhood()
		end
		unitTest:assert_error(error_func, "Parameter for 'loadNeighborhood' must be a table.")
	
		error_func = function()
			cs:loadNeighborhood{}
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg("source"))
		
		error_func = function()
			cs:loadNeighborhood{source = 123}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("source", "string", 123))

		error_func = function()
			cs:loadNeighborhood{source = "neighCabecaDeBoi900x900.gpm"}
		end
		unitTest:assert_error(error_func, resourceNotFoundMsg("source", "neighCabecaDeBoi900x900.gpm"))
	
		error_func = function()
			cs:loadNeighborhood{source = "neighCabecaDeBoi900x900.gpm", name = 22}
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg("name", "string", 22))
	end,
	save = function(unitTest)
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port

		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			theme = "cells90x90",
			layer = "cells90x90",
			database = "cabeca"
		}

		local error_func = function()
			cs:save("terralab", "themeName", "height_")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(1, "positive integer number", "terralab"))
	
		error_func = function()
			cs:save(-18, "themeName", "height_")
		end
		unitTest:assert_error(error_func, incompatibleValueMsg(1, "positive integer number", -18))
	
		error_func = function()
			cs:save(3, nil, "height_")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
	
		error_func = function()
			cs:save(3, 2, "height_")
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(2, "string", 2))

		error_func = function()
			cs:save(18, "themeName")
		end
		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
	
		error_func = function()
			cs:save(18, "themeName", 3)
		end
		unitTest:assert_error(error_func, incompatibleTypeMsg(3, "table", 3))
		
		error_func = function()
			cs:save(18, "themeName", "terralab")
		end
		unitTest:assert_error(error_func, "Attribute 'terralab' does not exist in the CellularSpace.")
	end,
	loadNeighborhood = function(unitTest)	
		local config = getConfig()
		local mdbType = config.dbType
		local mhost = config.host
		local muser = config.user
		local mpassword = config.password
		local mport = config.port

		local cs = CellularSpace{
			dbType = mdbType,
			host = mhost,
			user = muser,
			password = mpassword,
			port = mport,
			theme = "cells90x90",
			layer = "cells90x90",
			database = "cabeca"
		}

		local cs2 = CellularSpace{xdim = 10}

		local error_func = function()
			cs:loadNeighborhood{source = "arquivo.gpm"}
		end
		unitTest:assert_error(error_func, resourceNotFoundMsg("source", "arquivo.gpm"))

		error_func = function()
			cs:loadNeighborhood{source = "gpmlinesDbEmas_invalid.teste"}
		end
		unitTest:assert_error(error_func, invalidFileExtensionMsg("source", "teste"))

		error_func = function()
			cs:loadNeighborhood{source = file("cabecadeboi-invalid-neigh.gpm", "base")}
		end
		unitTest:assert_error(error_func, "This function cannot load neighborhood between two layers. Use 'Environment:loadNeighborhood()' instead.")

		local mfile = file("cabecadeboi-neigh.gpm", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GPM file layer: 'cells900x900'.")

		mfile = file("cabecadeboi-neigh.gal", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GAL file layer: 'cells900x900'.")

		mfile = file("cabecadeboi-neigh.gwt", "base")

		error_func = function()
			cs2:loadNeighborhood{
				source = mfile,
				name = "my_neighborhood"
			}
		end
		unitTest:assert_error(error_func, "Neighborhood file '"..mfile.."' was not built for this CellularSpace. CellularSpace layer: '', GWT file layer: 'cells900x900'.")
	end
}

