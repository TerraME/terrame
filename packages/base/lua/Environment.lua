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

local function createRandomPlacement(environment, cs, max, placement)
	local nplacement = placement
	if nplacement == nil then
		nplacement = "placement"
	end

	local g = Group{}

	forEachOrderedElement(environment, function(_, element)
		local t = type(element)
		if t == "Society" then
			element.placements[nplacement] = cs
			forEachAgent(element, function(agent)
				g:add(agent)
			end)
		elseif t == "Agent" then
			g:add(element)
		end
	end)

	local traj = Trajectory{
		target = cs
	}

	traj:randomize()
	g:randomize()

	local countMax = 0
	local countCell = 1
	forEachAgent(g, function(agent)
		agent:enter(traj.cells[countCell], placement)

		countMax = countMax + 1

		if countMax >= max then
			countMax = 0
			countCell = countCell + 1
		end
	end)
end

local function createUniformPlacement(environment, cs, placement)
	local nplacement = placement
	if nplacement == nil then
		nplacement = "placement"
	end

	local counter = 1
	forEachOrderedElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[nplacement] = cs
			forEachAgent(element, function(agent)
				agent:enter(cs.cells[counter], placement)
				counter = counter + 1
				if counter > #cs then
					counter = 1
				end
			end)
		elseif mtype == "Agent" then
			element:enter(cs.cells[counter], placement)
			counter = counter + 1
			if counter > #cs then
				counter = 1
			end
		end
	end)
end

local function createVoidPlacement(environment, cs, data)
	local placement = data.name
	local nplacement = placement
	if nplacement == nil then
		nplacement = "placement"
	end

	forEachElement(environment, function(_, element)
		local t = type(element)
		if t == "CellularSpace" or t == "Trajectory" then
			local melement = element
			if t == "Trajectory" then melement = element.parent end -- use the CellularSpace

			forEachCell(melement, function(cell)
				cell[nplacement] = Group{}
				cell[nplacement].agents = {}
				cell.agents = cell[nplacement].agents
			end)
		elseif t == "Society" then
			element.placements[nplacement] = cs
			forEachAgent(element, function(agent)
				agent[nplacement] = Trajectory{build = false, target = cs}
				agent[nplacement].cells = {}
				agent.cells = agent[nplacement].cells
			end)
		elseif t == "Agent" then
			element[nplacement] = Trajectory{build = false, target = cs}
			element[nplacement].cells = {}
			element.cells = element[nplacement].cells
		end
	end)

	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[nplacement] = cs
		end
	end)
end

Environment_ = {
	type_ = "Environment",
	--- Add an element to the Environment.
	-- @arg object An Agent, Automaton, Cell, CellularSpace, Society, Trajectory, Group, Event, Timer, Environment, or table.
	-- When adding a table, this function converts the table into an Event.
	-- When adding an Event, this function converts the Event into a Timer that contains the Event itself.
	-- @usage environment = Environment{}
	--
	-- cs1 = CellularSpace{xdim = 10}
	-- ag1 = Agent{}
	-- t1 = Timer{}
	--
	-- environment:add(cs1)
	-- environment:add(ag1)
	-- environment:add(t1)
	add = function(self, object)
		local t = type(object)
		if t == "table" then
			object = Event(object)
			t = type(object)
		end
		if belong(t, {"Cell", "CellularSpace", "Society", "Agent", "Automaton", "Timer", "Environment", "Trajectory", "Cell"}) then
			object.parent = self
			table.insert(self, object)

			if t == "Society" then return end
		elseif t == "Event" then
			object = Timer{object} -- create a Timer with the Event itself
			table.insert(self, object)
		else
			incompatibleTypeError(1, "Agent, Automaton, Cell, CellularSpace, Environment, Group, Society, Timer or Trajectory", object)
		end

		self.cObj_:add(object.cObj_)
	end,
	--- Create relations between behavioural entities (Agents) and spatial entities (Cells).
	-- It is possible to have more than one behavioural entity within the Environment, but it must
	-- have only one CellularSpace, Trajectory, or Cell.
	-- When distributing Agents over
	-- a Trajectory or a Cell, the Agents will be able to move over the whole CellularSpace.
	-- Note that this function uses rules that will be used only to build the placement. It is up to
	-- the modeler to implement such rules for the rest of the simulation if needed.
	-- For example, one can use argument max equals to one to indicate
	-- that the placement must have at most one Agent per Cell, but it works only to create the
	-- placement, having no effect along the simulation.
	-- @arg data.strategy A string containing the strategy to be used to create a placement
	-- between Agents and Cells. See the options below:
	-- @arg data.name A string with the name of the relation. The default value
	-- is "placement", which means that the modeler can use Agent:enter(), Agent:move(), and
	-- Agent:leave() without needing to refer to the name of the placement. If the name is
	-- different from the default value, the modeler will
	-- have to use the last argument of these functions with the name of the placement.
	-- @arg data.max A number representing the maximum number of Agents that can enter in the
	-- same Cell when creating the placement. As default it will add at most one Agent per Cell.
	-- Note that using this argument does not ensure a maximum number of
	-- agents inside Cells along the simulation - controlling the maximum is always up to
	-- the modeler.
	-- @tabular strategy Strategy & Description & Arguments \
	-- "random"(default) & Choose a Cell randomly and put max agents also chosen randomly.
	-- Repeat this process until allocate all Agents. The last Cell chosen might have less than
	-- max Agents. All the Cells that were not chosen in this process will remain empty. & name, max \
	-- "uniform" & Create placements uniformly. The first Agent enters in the first Cell, the second
	-- one in the second Cell, and so on. If it reaches the last Cell of the CellularSpace or Trajectory
	-- then it starts again in the first Cell. The
	-- last Cells will contain fewer Agents if the number of Agents is not proportional to the
	-- number of Cells. For example, placing a Society with four Agents into a CellularSpace of
	-- three Cells will put two Agents in the first Cell and one in the other two Cells. & name \
	-- "void" & This strategy creates an empty placement in each Cell and Agent. It is necessary to
	-- use this strategy if the modeler needs to establish the relations between Agents and Cells by
	-- himself/herself. In this case, Agents cannot use Agent:move() or Agent:walk()
	-- before calling Agent:enter() explicitly. & name \
	-- @usage ag = Agent{}
	--
	-- soc = Society{
	--     instance = ag,
	--     quantity = 20
	-- }
	--
	-- cs = CellularSpace{xdim = 10}
	-- env = Environment{soc, cs}
	-- env:createPlacement()
	createPlacement = function(self, data)
		if type(data) ~= "table" then
			if data == nil then
				data = {}
			else
				verifyNamedTable(data)
			end
		end

		local mycs
		local foundsoc

		defaultTableValue(data, "strategy", "random")
		defaultTableValue(data, "name", "placement")

		if data.name == "placement" then data.name = nil end -- to avoid warning messages

		if data.strategy == "random" then
			defaultTableValue(data, "max", 1)

			positiveTableArgument(data, "max")
		end

		local qty_agents = 0

		for _, ud in pairs(self) do
			local t = type(ud)
			if belong(t, {"CellularSpace", "Trajectory", "Cell"}) then
				if mycs ~= nil then
					customError("Environment should contain only one CellularSpace, Trajectory, or Cell.")
				end
				mycs = ud
			elseif t == "Society" then
				qty_agents = qty_agents + #ud
				forEachElement(ud.placements, function(name)
					if name == data.name or (data.name == nil and name == "placement") then
						customError("There is a Society within this Environment that already has this placement.")
					end
				end)

				foundsoc = true
			elseif t == "Agent" then
				qty_agents = qty_agents + 1
				foundsoc = true
			elseif t == "Group" then
				customError("Placements is still not implemented for groups.")
			end
		end

		verify(mycs, "The Environment does not contain a CellularSpace.")
		verify(foundsoc, "Could not find a behavioral entity (Society or Agent) within the Environment.")

		if type(mycs) == "Cell" then
			local t = Trajectory{target = mycs.parent, build = false}
			t:add(mycs)
			mycs = t
			table.insert(self, t)
		end

		switch(data, "strategy"):caseof{
			random = function()
				verifyUnnecessaryArguments(data, {"strategy", "name", "max"})

				if data.max ~= nil then
					if qty_agents > #mycs * data.max then
						customError("It is not possible to put such amount of agents in space.")
					end
				end

				createVoidPlacement(self, mycs, data)
				createRandomPlacement(self, mycs, data.max, data.name)
			end,
			uniform = function()
				verifyUnnecessaryArguments(data, {"strategy", "name"})
				createVoidPlacement(self, mycs, data)
				createUniformPlacement(self, mycs, data.name)
			end,
			void = function()
				verifyUnnecessaryArguments(data, {"strategy", "name"})
				createVoidPlacement(self, mycs, data)
			end
		}
	end,
	--- Run the Environment until a given time. It activates the Timers it contains, the Timers
	-- of the Environments it contains, and so on.
	-- @arg finalTime A number representing the final time. This funcion will stop when there is no
	-- Event scheduled to a time less or equal to the final time.
	-- When using instances of Models within the Environment (to simulate them at the same time),
	-- this argument is optional. In this case, the default value is the greater final time
	-- amongst all instances.
	-- @usage env = Environment{
	--     Timer{Event{action = function()
	--         print("execute 1")
	--     end}},
	--     Timer{Event{action = function()
	--         print("execute 2")
	--     end}}
	-- }
	-- env:run(10)
	run = function(self, finalTime)
		local timer = Timer{}
		local timers = {}

		local process
		local modelFinalTime

		process = function(env)
			forEachOrderedElement(env, function(idx, value, mtype)
				if mtype == "Environment" and idx ~= "parent" then
					process(value)
				elseif mtype == "Timer" then
					table.insert(timers, value)
					forEachElement(value.events, function(_, ev)
						timer:add(ev)
					end)
				elseif isModel(value) and idx ~= "parent" then
					local ft = value.finalTime
					if not modelFinalTime or ft > modelFinalTime then
						modelFinalTime = ft
					end

					process(value)
				end
			end)
		end

		process(self)

		if modelFinalTime and not finalTime then
			finalTime = modelFinalTime
		end

		mandatoryArgument(1, "number", finalTime)

		timer:run(finalTime)

		forEachElement(timers, function(_, value)
			value.time = finalTime
		end)
	end,
	--- Return the older simulation time of its Timers.
	-- @usage env = Environment{
	--     Timer{Event{action = function() end}}
	-- }
	--
	-- env:run(10)
	-- print(env:getTime())
	getTime = function(self)
		local oldTime = math.huge

		local process

		process = function(env)
			forEachElement(env, function(idx, value, mtype)
				if mtype == "Environment" and idx ~= "parent" then
					process(value)
				elseif mtype == "Timer" then
					if oldTime > value:getTime() then
						oldTime = value:getTime()
					end
				elseif type(_G[mtype]) == "Model" then
					process(value)
				end
			end)
		end

		process(self)

		return oldTime
	end,
	--- Load a Neighborhood between two different CellularSpaces.
	-- @arg data.file A File or a string with the name of the file to be loaded.
	-- @arg data.name A string with the name of the relation to be created.
	-- The default value is "1".
	-- @arg data.bidirect A boolean value. If true then, for each relation from Cell a
	-- to Cell b loaded from the file, it will also create
	-- a relation from b to a. The default value is false.
	-- @usage -- DONTRUN
	-- river = CellularSpace{
	--     file = filePath("river.shp")
	-- }
	--
	-- emas = CellularSpace{
	--     file = filePath("emas.shp")
	-- }
	--
	-- env = Environment{emas, river}
	-- env:loadNeighborhood{file = filePath("gpmlinesDbEmas.gpm", "base")}
	-- @see Package:filePath
	loadNeighborhood = function(self, data)
		verifyNamedTable(data)

		defaultTableValue(data, "name", "1")

		if type(data.file) == "string" then
			data.file = File(data.file)
		end

		mandatoryTableArgument(data, "file", "File")

		local extension = data.file:extension()

		if extension ~= "gpm" then
			invalidFileExtensionError("file", extension)
		end

		defaultTableValue(data, "bidirect", false)

		if not data.file:exists() then
			resourceNotFoundError("file", data.file)
		end

		local header = data.file:readLine()

		local numAttribIdx = string.find(header, "%s", 1)
		local layer1Idx = string.find(header, "%s", numAttribIdx + 1)
		local layer2Idx = string.find(header, "%s", layer1Idx + 1)

		local numAttributes = tonumber(string.sub(header, 1, numAttribIdx))
		local layer1Id = string.sub(header, numAttribIdx + 1, layer1Idx - 1)
		local layer2Id = string.sub(header, layer1Idx + 1, layer2Idx - 1)

		verify(layer1Id ~= layer2Id, "This function does not load neighborhoods between cells from the same "..
			"CellularSpace. Use CellularSpace:loadNeighborhood() instead.")

		verify(numAttributes < 2, "This function does not support GPM with more than one attribute.")

		local cellSpaces = {}
		for _, element in pairs(self) do
			if type(element) == "CellularSpace" then
				local cellSpaceLayer = element.layer

				if cellSpaceLayer == layer1Id then cellSpaces[1] = element
				elseif cellSpaceLayer == layer2Id then cellSpaces[2] = element end
			end
		end

		if cellSpaces[1] == nil and cellSpaces[2] == nil then
			customError("CellularSpaces with layers '"..layer1Id.."' and '"..layer2Id.."' were not found in the Environment.")
		elseif cellSpaces[1] == nil then
			customError("CellularSpace with layer '"..layer1Id.."' was not found in the Environment.")
		elseif cellSpaces[2] == nil then
			customError("CellularSpace with layer '"..layer2Id.."' was not found in the Environment.")
		end

		repeat
			local line_cell = data.file:readLine()
			if line_cell == nil then break; end

			local cellIdIdx = string.find(line_cell, "%s", 1)
			local cellId = string.sub(line_cell, 1, cellIdIdx - 1)
			local numNeighbors = tonumber(string.sub(line_cell, cellIdIdx + 1))

			local cell = cellSpaces[1]:get(cellId)

			local neighborhood = Neighborhood{id = data.name}
			cell:addNeighborhood(neighborhood, data.name)

			local weight

			if numNeighbors > 0 then
				local line_neighbors = data.file:readLine()

				local neighIdEndIdx = string.find(line_neighbors, "%s")

				if not neighIdEndIdx then
					customError("Could not read the file properly. It seems that it is corrupted.")
				end
				local neighIdIdx = 1

				for i = 1, numNeighbors do
					if i ~= 1 then
						neighIdIdx = string.find(line_neighbors, "%s", neighIdEndIdx) + 1
						neighIdEndIdx = string.find(line_neighbors, "%s", neighIdIdx)
					end
					local neighId = string.sub(line_neighbors, neighIdIdx, neighIdEndIdx - 1)
					local neighbor = cellSpaces[2]:get(neighId)

					-- Gets the weight
					if numAttributes > 0 then
						local weightEndIdx = string.find(line_neighbors, "%s", neighIdEndIdx + 1)

						if weightEndIdx == nil then
							local weightAux = string.sub(line_neighbors, neighIdEndIdx + 1)
							weight = tonumber(weightAux)

							if weight == nil then
								customError("The string '"..weightAux.."' found as weight in the file '"..data.file..
								"' could not be converted to a number.")
							end
						else
							local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1), (weightEndIdx - 1))
							weight = tonumber(weightAux)

							if weight == nil then
								customError("The string '"..weightAux.."' found as weight in the file '"..data.file..
								"' could not be converted to a number.")
							end
						end

						if weightEndIdx then neighIdEndIdx = weightEndIdx end
					else
						weight = 1
					end

					-- Adds the neighbor to the neighborhood
					neighborhood:add(neighbor, weight)

					if data.bidirect then
						local neighborhoodNeigh = neighbor:getNeighborhood(data.name)
						if neighborhoodNeigh == nil then
							neighborhoodNeigh = Neighborhood()
							neighbor:addNeighborhood(neighborhoodNeigh, data.name)
						end
						neighborhoodNeigh:add(cell, weight)
					end
				end
			end
		until(line_cell == nil)

		if data.bidirect then
			for _, cell2 in ipairs(cellSpaces[2].cells) do
				local neighborhoodNeigh = cell2:getNeighborhood(data.name)
				if neighborhoodNeigh == nil then
					neighborhoodNeigh = Neighborhood()
					cell2:addNeighborhood(neighborhoodNeigh, data.name)
				end
			end
		end

		data.file:close()
	end,
	--- Notify every Observer connected to the Environment.
	-- @arg modelTime A number representing the notification time. The default value is zero.
	-- It is also possible to use an Event as argument. In this case, it will use the result of
	-- Event:getTime().
	-- @usage env = Environment{}
	-- env:notify()
	notify = function(self, modelTime)
		if modelTime == nil then
			modelTime = 0
		elseif type(modelTime) == "Event" then
			modelTime = modelTime:getTime()
		else
			optionalArgument(1, "number", modelTime)
			positiveArgument(1, modelTime, true)
		end

		self.cObj_:notify(modelTime)
	end
}

metaTableEnvironment_ = {__index = Environment_, __tostring = _Gtme.tostring}

--- A container that encapsulates space, time, behavior, and other Environments. Objects can be
-- added directly when the Environment is declared or after it has been instantiated. It can
-- control the simulation engine, synchronizing all the Timers within it, or instantiate
-- relations between sets of objects. Calling
-- Utils:forEachElement() traverses each object of an Environment.
-- If the Environment has a set of Model instances, it is possible to call Utils:forEachModel()
-- to traverse them.
-- @arg data.... Agents, Automatons, Cells, CellularSpaces, Societies, Trajectories, Groups,
-- Timers, Environments, or instances of Models.
-- @output cObj_ A pointer to a C++ representation of the Environment. Never use this object.
-- @usage environment = Environment{
--     cs1 = CellularSpace{xdim = 10},
--     ag1 = Agent{},
--     t1 = Timer{}
-- }
function Environment(data)
	if type(data) ~= "table" then
		if data == nil then
			customError(tableArgumentMsg())
		else
			customError(namedArgumentsMsg())
		end
	end

	defaultTableValue(data, "id", "1")

	local cObj = TeScale(data.id)
	setmetatable(data, metaTableEnvironment_)
	cObj:setReference(data)
	local flagAutomaton = false
	local flagCellularSpace = false
	forEachElement(data, function(k, ud, t)
		if t == "Automaton" then
			ud.parent = data
			cObj:add(ud.cObj_)
			flagAutomaton = true
		elseif t == "CellularSpace" then
			ud.parent = data
			flagCellularSpace = true
			cObj:add(ud.cObj_)
		elseif t == "Society" then
			ud.parent = data
		elseif t == "Timer" or t == "Agent" or t == "Environment" then
			ud.parent = data
			cObj:add(ud.cObj_)
		elseif isModel(ud) then
			forEachElement(ud, function(_, value, mtype)
				if mtype == "Timer" or mtype == "Environment" then
					cObj:add(value.cObj_)
				end
			end)
		elseif k ~= "id" and not belong(t, {"Cell", "Group", "Trajectory"}) then
			strictWarning("Argument '"..k.."' (a '"..t.."') is unnecessary for the Environment.")
		end
	end)

	if flagAutomaton and not flagCellularSpace then
		customError("The Environment has an Automaton but not a CellularSpace.")
	end

	data.cObj_ = cObj
	return data
end

