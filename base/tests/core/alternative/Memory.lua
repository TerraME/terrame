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
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Raian Vargas Maretto (raian@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Coord = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local coord1 = TeCoord{x = 10, y = 10}
			local coord2 = TeCoord{x = 12, y = 10}

			local reg = _G --debug.getregistry()
			local count = 0
			for k, v in pairs(reg) do
				if type(v) == "table" then
					for kk, vv in pairs(v) do
						if type(vv) == "Coord" then
							count = count + 1
						end
					end
				elseif type(v) == "Coord" then
					count = count + 1
				end
			end
			unitTest:assert_equal(2, count)

			unitTest:assert_not_nil(coord2)
			unitTest:assert_not_nil(coord1)
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
		unitTest:assert_equal(0, count)
		unitTest:assert_equal(0, countOutWT)
	end,
	Cell = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local cell = Cell{cover = "forest"}
			unitTest:assert_not_nil(cell)

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
			unitTest:assert_equal(1, count) 
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, count)
		unitTest:assert_equal(0, countOutWT)
	end,
	CellularSpace = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 200}
			unitTest:assert_type(cs, "CellularSpace")

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
			unitTest:assert_equal(1, countCS) 
			unitTest:assert_equal(40000, countCell)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countCS)
		unitTest:assert_equal(0, countCell)
		unitTest:assert_equal(0, countOutWT)
	end,
	Trajectory = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 10}
			local traj = Trajectory{target = cs}

			unitTest:assert_not_nil(cs)
			unitTest:assert_not_nil(traj)

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
			unitTest:assert_equal(1, countTraj)
			unitTest:assert_equal(1, countCS)
			unitTest:assert_equal(100, countCell)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countTraj)
		unitTest:assert_equal(0, countCS)
		unitTest:assert_equal(0, countCell)
		unitTest:assert_equal(0, countOutWT)
	end,
	Neighborhood = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local cs = CellularSpace{xdim = 50}

			unitTest:assert_not_nil(cs)

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
			unitTest:assert_equal(2500, countNeigh)
			unitTest:assert_equal(2500, countCell)
			unitTest:assert_equal(1, countCS)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countNeigh)
		unitTest:assert_equal(0, countCell)
		unitTest:assert_equal(0, countCS)
		unitTest:assert_equal(0, countOutWT)
	end,
	Agent = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local ag = Agent{
				id = "agent",
				class = "business",
				money = 1000
			}
			unitTest:assert_not_nil(ag)

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
			unitTest:assert_equal(1, countAg)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countAg)
		unitTest:assert_equal(0, countOutWT)
	end,
	Automaton = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local at = Automaton{id = "automaton"}

			unitTest:assert_not_nil(at)

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
			unitTest:assert_equal(1, countAt)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countAt)
		unitTest:assert_equal(0, countOutWT)
	end,
	Environment = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local env = Environment{id = "environment"}

			unitTest:assert_not_nil(env)

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
			unitTest:assert_equal(1, countEnv)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countEnv)
		unitTest:assert_equal(0, countOutWT)
	end,
	Event = function(unitTest)
		debug.sethook()
		local evt
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			evt = Event{priority = 1, action = function(event)
				time = event:getTime()
			end}
			unitTest:assert_not_nil(evt)
		end

		collectgarbage("collect")
	end,
	Flow = function(unitTest)
		debug.sethook()
		local flw
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			flw = Flow{function(event, agent, cell) end}

			unitTest:assert_not_nil(flw)
		end

		collectgarbage("collect")
	end,
	Jump = function(unitTest)
		debug.sethook()
		local jmp
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			jmp = Jump{
				function(event, agent, c) return true end,
				target = "wet"
			}
			unitTest:assert_not_nil(jmp)
		end

		collectgarbage("collect")
	end,
	Timer = function(unitTest)
		debug.sethook()
		collectgarbage("collect")

		for i = 1, 100 do
			collectgarbage("collect")
			local t = Timer{
				Event{priority = 1, action = function(event)
					time = event:getTime()
				end}
			}
			unitTest:assert_not_nil(t)

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
			unitTest:assert_equal(1, countTimer)
			unitTest:assert_equal(0, countOutWT)
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
		unitTest:assert_equal(0, countTimer)
		unitTest:assert_equal(0, countOutWT)
	end
}

