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

return{
	Agent = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local ag = Agent{
				id = "agent",
				class = "business",
				money = 1000
			}
			unitTest:assertNotNil(ag) -- SKIP

			local reg = debug.getregistry()
			local countAg = 0
			local countOutWT = 0 
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Agent" then
							countAg = countAg + 1
						end
					end
				elseif type(v) == "Agent" then
					countOutWT = countOutWT + 1
				end
			end
			unitTest:assertEquals(1, countAg) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countAg = 0
		local countOutWT = 0 
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Agent" then
						countAg = countAg + 1
					end
				end
			elseif type(v) == "Agent" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countAg) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Automaton = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local at = Automaton{id = "automaton"}

			unitTest:assertNotNil(at) -- SKIP

			local reg = debug.getregistry()
			local countAt = 0
			local countOutWT = 0 
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Automaton" then
							countAt = countAt + 1
						end
					end
				elseif type(v) == "Automaton" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(1, countAt) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countAt = 0
		local countOutWT = 0 
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Automaton" then
						countAt = countAt + 1
					end
				end
			elseif type(v) == "Automaton" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countAt) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Cell = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local cell = Cell{cover = "forest"}
			unitTest:assertNotNil(cell) -- SKIP

			local reg = debug.getregistry()
			local count = 0
			local countOutWT = 0
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Cell" then
							count = count + 1
						end
					end
				elseif type(v) == "Cell" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(1, count) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local count = 0
		local countOutWT = 0
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Cell" then
						count = count + 1
					end
				end
			elseif type(v) == "Cell" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, count) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	CellularSpace = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 200}
			unitTest:assertType(cs, "CellularSpace") -- SKIP

			local reg = debug.getregistry()
			local countCS = 0
			local countCell = 0
			local countOutWT = 0
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "CellularSpace" then
							countCS = countCS + 1
						elseif type(kk) == "userdata" and type(vv) == "Cell" then
							countCell = countCell + 1 
						end
					end
				elseif type(v) == "Cell" or type(v) == "CellularSpace" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(1, countCS) -- SKIP
			unitTest:assertEquals(40000, countCell) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countCS = 0
		local countCell = 0
		local countOutWT = 0
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "CellularSpace" then
						countCS = countCS + 1
					elseif type(kk) == "userdata" and type(vv) == "Cell" then
						countCell = countCell + 1
					end
				end
			elseif type(v) == "Cell" or type(v) == "CellularSpace" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countCS) -- SKIP
		unitTest:assertEquals(0, countCell) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Coord = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local coord1 = TeCoord{x = 10, y = 10}
			local coord2 = TeCoord{x = 12, y = 10}

			local reg = _G --debug.getregistry()
			local count = 0
			for _, v in pairs(reg) do
				if type(v) == "table" then
					for _, vv in pairs(v) do
						if type(vv) == "Coord" then
							count = count + 1
						end
					end
				elseif type(v) == "Coord" then
					count = count + 1
				end
			end

			unitTest:assertEquals(2, count) -- SKIP

			unitTest:assertNotNil(coord2) -- SKIP
			unitTest:assertNotNil(coord1) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local count = 0
		local countOutWT = 0
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Coord" then
						count = count + 1
					end
				end
			elseif type(v) == "Coord" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, count) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Environment = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local env = Environment{}

			unitTest:assertNotNil(env) -- SKIP

			local reg = debug.getregistry()
			local countEnv = 0
			local countOutWT = 0 
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Environment" then
							countEnv = countEnv + 1
						end
					end
				elseif type(v) == "Environment" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(1, countEnv) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countEnv = 0
		local countOutWT = 0 
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Environment" then
						countEnv = countEnv + 1
					end
				end
			elseif type(v) == "Environment" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countEnv) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Event = function(unitTest)
		debug.sethook()
		local evt
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			evt = Event{priority = 1, action = function(event)
				time = event:getTime()
			end}
			unitTest:assertNotNil(evt) -- SKIP
		end

		collectgarbage("collect")
	end,
	Flow = function(unitTest)
		debug.sethook()
		local flw
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			flw = Flow{function() end}

			unitTest:assertNotNil(flw) -- SKIP
		end

		collectgarbage("collect")
	end,
	Jump = function(unitTest)
		debug.sethook()
		local jmp
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			jmp = Jump{
				function() return true end,
				target = "wet"
			}
			unitTest:assertNotNil(jmp) -- SKIP
		end

		collectgarbage("collect")
	end,
	Neighborhood = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 50}

			unitTest:assertNotNil(cs) -- SKIP

			cs:createNeighborhood{name = "moore"}

			local reg = debug.getregistry()
			local countNeigh = 0
			local countCell = 0
			local countCS = 0
			local countOutWT = 0 
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Neighborhood" then
							countNeigh = countNeigh + 1
						elseif type(kk) == "userdata" and type(vv) == "CellularSpace" then 
							countCS = countCS + 1
						elseif type(kk) == "userdata" and type(vv) == "Cell" then
							countCell = countCell + 1
						end
					end
				elseif type(v) == "Cell" or type(v) == "CellularSpace" or type(v) == "Neighborhood" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(2500, countNeigh) -- SKIP
			unitTest:assertEquals(2500, countCell) -- SKIP
			unitTest:assertEquals(1, countCS) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countNeigh = 0
		local countCell = 0
		local countCS = 0
		local countOutWT = 0
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Neighborhood" then
						countNeigh = countNeigh + 1
					elseif type(kk) == "userdata" and type(vv) == "CellularSpace" then
						countCS = countCS + 1
					elseif type(kk) == "userdata" and type(vv) == "Cell" then
						countCell = countCell + 1
					end
				end
			elseif type(v) == "Cell" or type(v) == "CellularSpace" or type(v) == "Neighborhood" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countNeigh) -- SKIP
		unitTest:assertEquals(0, countCell) -- SKIP
		unitTest:assertEquals(0, countCS) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Timer = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local t = Timer{
				Event{priority = 1, action = function(event)
					time = event:getTime()
				end}
			}
			unitTest:assertNotNil(t) -- SKIP

			local reg = debug.getregistry()
			local countTimer = 0
			local countOutWT = 0 
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Timer" then
							countTimer = countTimer + 1
						end
					end
				elseif type(v) == "Timer" then
					countOutWT = countOutWT + 1
				end
			end

			if _Gtme.sessionInfo().system ~= "windows" then
				unitTest:assertEquals(1, countTimer) -- SKIP
			else
				unitTest:assert(true) -- SKIP (to make execution tests working properly)
			end

			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countTimer = 0
		local countOutWT = 0 
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Timer" then
						countTimer = countTimer + 1
					end
				end
			elseif type(v) == "Timer" then
				countOutWT = countOutWT + 1
			end
		end

		if _Gtme.sessionInfo().system ~= "windows" then
			unitTest:assertEquals(0, countTimer) -- SKIP
		else
			unitTest:assert(true) -- SKIP (to make execution tests working properly)
		end

		unitTest:assertEquals(0, countOutWT) -- SKIP
	end,
	Trajectory = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for _ = 1, 50 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 10}
			local traj = Trajectory{target = cs}

			unitTest:assertNotNil(cs) -- SKIP
			unitTest:assertNotNil(traj) -- SKIP

			local reg = debug.getregistry()
			local countTraj = 0
			local countCS = 0
			local countCell = 0
			local countOutWT = 0
			for k, v in pairs(reg) do
				if type(k) == "number" and type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(kk) == "userdata" and type(vv) == "Trajectory" then 
							countTraj = countTraj + 1
						elseif type(kk) == "userdata" and type(vv) == "CellularSpace" then
							countCS = countCS + 1
						elseif type(kk) == "userdata" and type(vv) == "Cell" then
							countCell = countCell + 1
						end
					end
				elseif type(v) == "Cell" or type(v) == "CellularSpace" or type(v) == "Trajectory" then
					countOutWT = countOutWT + 1
				end
			end

			unitTest:assertEquals(1, countTraj) -- SKIP
			unitTest:assertEquals(1, countCS) -- SKIP
			unitTest:assertEquals(100, countCell) -- SKIP
			unitTest:assertEquals(0, countOutWT) -- SKIP
		end

		collectgarbage("collect")

		local reg = debug.getregistry()
		local countTraj = 0
		local countCS = 0
		local countCell = 0
		local countOutWT = 0
		for k, v in pairs(reg) do
			if type(k) == "number" and type(v) == "table" then
				for kk, vv in pairs(v) do
					if type(kk) == "userdata" and type(vv) == "Trajectory" then
						countTraj = countTraj + 1
					elseif type(kk) == "userdata" and type(vv) == "CellularSpace" then
						countCS = countCS + 1
					elseif type(kk) == "userdata" and type(vv) == "Cell" then
						countCell = countCell + 1
					end
				end
			elseif type(v) == "Cell" or type(v) == "CellularSpace" or type(v) == "Trajectory" then
				countOutWT = countOutWT + 1
			end
		end

		unitTest:assertEquals(0, countTraj) -- SKIP
		unitTest:assertEquals(0, countCS) -- SKIP
		unitTest:assertEquals(0, countCell) -- SKIP
		unitTest:assertEquals(0, countOutWT) -- SKIP
	end
}

