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
-- Authors: 
--      Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--      Rodrigo Reis Pereira
--#########################################################################################

local function createRandomPlacement(environment, cs, max, placement)
	local nplacement = placement
	if nplacement == nil then
		nplacement = "placement"
	end

	forEachOrderedElement(environment, function(_, element)
		local t = type(element)
		if t == "Society" then
			element.placements[nplacement] = cs
			forEachAgent(element, function(agent)
				local cell = cs:sample()
				while #cell[nplacement] >= max do
					cell = cs:sample()
				end
				agent:enter(cell, placement)
			end)
		elseif t == "Agent" then
			local cell = cs:sample()
			while #cell[nplacement] >= max do
				cell = cs:sample()
			end 
			element:enter(cell, placement)
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
				cell[nplacement] = Group{build = false}
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
	-- @arg object An Agent, Automaton, CellularSpace, Timer or Environment.
	-- @usage environment:add(agent)
	-- environment:add(cellularSpace)
	add = function(self, object)
		local t = type(object)
		if belong(t, {"CellularSpace", "Society", "Agent", "Automaton", "Timer", "Trajectory", "Cell"}) then
			object.parent = self
			table.insert(self, object)

			if t == "Society" then return end
		else
      		incompatibleTypeError(1, "Agent, Automaton, Cell, CellularSpace, Society, Timer or Trajectory", object)
    	end
		self.cObj_:add(object.cObj_)
	end,
	--- Create relations between behavioural entities (Agents) and spatial entities (Cells). The
	-- Environment must have only one CellularSpace or Trajectory to place agents. It is possible
	-- to have more than one behavioural entity in the Environment. When distributing Agents over
	-- a Trajectory, the Agents will be able to move over the whole CellularSpace.
	-- @arg data.strategy A string containing the strategy to be used for creating a placement
	-- between Agents and Cells. See the options below:
	-- @arg data.name A string representing the name of the relation in TerraME objects. Default
	-- is "placement", which means that the modeler can use Agent:enter(), Agent:move(), and
	-- Agent:leave() directly. If the name is different from the default value, the modeler will
	-- have to use the last argument of these functions to indicate which relation they are
	-- changing or perform changes on these relations manually.
	-- @arg data.max A number representing the maximum number of Agents that can enter in the
	-- same Cell when creating the placement. Default is having no limit. Using max is
	-- computationally efficient only when the number of Agents is considerably lower than the
	-- number of Cells times max. Otherwise, it is better to consider using the uniform strategy.
	-- Note that using this argument does not force the simulation to have a maximum number of
	-- agents inside cells along the simulation - controlling the maximum is always up to
	-- the modeler.
	-- @tabular strategy Strategy & Description & Arguments \
	-- "random"(default) & Create placements between Agents and Cells randomly, putting each Agent
	-- in a Cell randomly chosen. & name, max \
	-- "uniform" & Create placements uniformly. The first Agents enter in the first Cells. The
	-- last Cells will contain fewer Agents if the number of Agents is not proportional to the
	-- number of Cells. For example, placing a Society with four Agents in a CellularSpace of
	-- three Cells will put two Agents in the first Cell and one in each other Cell. & name \
	-- "void" & Create only the pointers for each object in each side, preparing the objects to
	-- be manipulated by the modeler. In this case, the agents cannot use Agent:move() or Agent:walk() 
	-- before calling Agent:enter() explicitly. & name \
	-- @usage environment = Environment{
	--     society,
	--     cellularSpace
	-- }
	-- 
	-- environment:createPlacement{
	--     strategy = "uniform"
	-- }
	--
	-- society:sample():walk()
	createPlacement = function(self, data)
		if type(data) ~= "table" then
			if data == nil then
				data = {}
			else
				verifyNamedTable(data)
			end
		end

		local mycs
		local mysoc
		local foundsoc

		defaultTableValue(data, "strategy", "random")
		defaultTableValue(data, "name", "placement")

		if data.name == "placement" then data.name = nil end -- to avoid warning messages

		if data.strategy == "random" then
			defaultTableValue(data, "max", math.huge)

			positiveTableArgument(data, "max")
		end

		local qty_agents = 0

		for k, ud in pairs(self) do
			local t = type(ud)
			if belong(t, {"CellularSpace", "Trajectory", "Cell"}) then
				if mycs ~= nil then
					customError("Environment should contain only one CellularSpace, Trajectory, or Cell.")
				end
				mycs = ud
			elseif t == "Society" then
				qty_agents = qty_agents + #ud
				forEachElement(ud.placements, function(index)
					if index == data.name or (data.name == nil and index == "placement") then
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

		if data.strategy == "random" and data.max ~= nil and qty_agents > #mycs * data.max then
			customError("It is not possible to put such amount of agents in space.")
		end

		switch(data, "strategy"):caseof{
			random = function() 
				checkUnnecessaryArguments(data, {"strategy", "name", "max"})
				createVoidPlacement(self, mycs, data) 
				createRandomPlacement(self, mycs, data.max, data.name)
			end,
			uniform = function()
				checkUnnecessaryArguments(data, {"strategy", "name"})
				createVoidPlacement(self, mycs, data) 
				createUniformPlacement(self, mycs, data.name)
			end,
			void = function()
				checkUnnecessaryArguments(data, {"strategy", "name"})
				createVoidPlacement(self, mycs, data) 
			end
		}
	end,
	--- Execute the Environment until a given time. It activates the Timers it contains, the Timers
	-- of the Environments it contains, and so on.
	-- @arg finalTime A positve integer number representing the time to stop the simulation.
	-- Timers stop when there is no Event scheduled to a time less or equal to the final time.
	-- @usage environment:execute(1000)
	execute = function(self, finalTime) 
		mandatoryArgument(1, "number", finalTime)
		self.cObj_:config(finalTime)
		self.cObj_:execute()
	end,
	--- Load a Neighborhood between two different CellularSpaces.
	-- @arg data.source A string representing the name of the file to be loaded.
	-- @arg data.name A string representing the name of the relation to be created.
	-- Default is '1'.
	-- @arg data.bidirect If 'true' then for each relation from Cell a to Cell b, create
	-- also a relation from b to a. Default is 'false'.
	-- @usage environment:loadNeighborhood{  
	--     source = "file.gpm",
	--     name = "newNeigh"
	-- }
	loadNeighborhood = function(self, data)
		verifyNamedTable(data)

		defaultTableValue(data, "name", "1")
		mandatoryTableArgument(data, "source", "string")

		local extension = string.match(data.source, "%w+$")
		if extension ~= "gpm" then
			invalidFileExtensionError("source", extension)
		end
    
		defaultTableValue(data, "bidirect", false)

		local file = io.open(data.source, "r")
		if not file then
			resourceNotFoundError("source", data.source)
		end

		local header = file:read()
		
		local numAttribIdx = string.find(header, "%s", 1)
		local layer1Idx = string.find(header, "%s", (numAttribIdx + 1))
		local layer2Idx = string.find(header, "%s", (layer1Idx + 1))
		
		local numAttributes = tonumber(string.sub(header, 1, numAttribIdx))
		local layer1Id = string.sub(header, (numAttribIdx + 1), (layer1Idx - 1))
		local layer2Id = string.sub(header, (layer1Idx + 1), (layer2Idx - 1))

		verify(layer1Id ~= layer2Id, "This function does not load neighborhoods between cells from the same "..
			"CellularSpace. Use CellularSpace:loadNeighborhood() instead.") 

		verify(numAttributes < 2, "This function does not support GPM with more than one attribute.")

		local beginName = layer2Idx
		local attribNames = {}

		for i = 1, numAttributes do
			if i ~= 1 then local beginName = string.find(header, "%s", (endName + 1)) end

			local endName = string.find(header, "%s", (beginName + 1))
			
			attribNames[i] = string.sub(header, (beginName + 1))
			if endName ~= nil then
				attribNames[i] = string.sub(header, (beginName + 1), (endName - 1))
			else
				break
			end
		end
		
		local cellSpaces = {}
		for i, element in pairs(self) do
			if type(element) == "CellularSpace" then
				local cellSpaceLayer = element.layer
				
				if cellSpaceLayer == layer1Id then cellSpaces[1] = element
				elseif cellSpaceLayer == layer2Id then cellSpaces[2] = element end
			end
		end
		
		if cellSpaces[1] == nil or cellSpaces[2] == nil then
			customError("CellularSpaces with layers '"..layer1Id.."' and '"..layer2Id.."' were not found in the Environment.")
		end

		repeat
			local line_cell = file:read()
			if line_cell == nil then break; end

			local cellIdIdx = string.find(line_cell, "%s", 1)
			local cellId = string.sub(line_cell, 1, (cellIdIdx - 1))
			local numNeighbors = tonumber(string.sub(line_cell, (cellIdIdx + 1)))

			local cell = cellSpaces[1]:get(cellId)

			local neighborhood = Neighborhood{id = data.name}
			cell:addNeighborhood(neighborhood, data.name)

			local weight

			if numNeighbors > 0 then
				local line_neighbors = file:read()

				local neighIdEndIdx = string.find(line_neighbors, "%s")
				local neighIdIdx = 1

				for i = 1, numNeighbors do
					if i ~= 1 then 
						neighIdIdx = string.find(line_neighbors, "%s", neighIdEndIdx) + 1
						neighIdEndIdx = string.find(line_neighbors, "%s", neighIdIdx)
					end
					local neighId = string.sub(line_neighbors, neighIdIdx, (neighIdEndIdx - 1))
					local neighbor = cellSpaces[2]:get(neighId)

					-- Gets the weight
					if numAttributes > 0 then
						local weightEndIdx = string.find(line_neighbors, "%s", (neighIdEndIdx + 1))

						if weightEndIdx == nil then 
							local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1))
							weight = tonumber(weightAux)

							if weight == nil then
								customError("The string '"..weightAux.."' found as weight in the file '"..data.source..
								"' could not be converted to a number.")
							end
						else
							local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1), (weightEndIdx - 1))
							weight = tonumber(weightAux)

							if weight == nil then
								customError("The string '"..weightAux.."' found as weight in the file '"..data.source..
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
			for i, cell2 in ipairs(cellSpaces[2].cells)do
				local neighborhoodNeigh = cell2:getNeighborhood(data.name)
				if neighborhoodNeigh == nil then
					neighborhoodNeigh = Neighborhood()
					cell2:addNeighborhood(neighborhoodNeigh, data.name)
				end
			end
		end

		file:close()
	end,
	--- Notify every Observer connected to the Environment.
	-- @arg modelTime An integer number representing the notification time. Default is zero.
	-- @usage env:notify()
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

metaTableEnvironment_ = {__index = Environment_, __tostring = tostringTerraME}

--- A container that encapsulates space, time, behavior, and other environments. Objects can be
-- added directly when the Environment is declared or after it has been instantiated. It can
-- control the simulation engine, synchronizing all the Timers within it. Calling
-- Utils:forEachElement() traverses each object of an Environment.
-- @arg data A table containing all the elements of the Environment to be created.
-- @usage environment = Environment {
--     cs1 = CellularSpace{...},
--     ag1 = Agent{...},
--     aut2 = Automaton{...},
--     t1 = Timer{...},
--     env1 = Environment{...}
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
		end
	end)

	if flagAutomaton and not flagCellularSpace then
		customError("The Environment has an Automaton but not a CellularSpace.")
	end

	data.cObj_ = cObj
	return data
end

