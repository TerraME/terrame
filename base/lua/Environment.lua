-------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------

local createRandomPlacement = function(environment, cs, max, placement)
	if max == nil then
		forEachElement(environment, function(_, element)
			local t = type(element)
			if t == "Society" then
				element.placements[placement] = cs
				forEachAgent(element, function(agent)
					agent:enter(cs:sample(), placement)
				end)
			elseif t == "Agent" then
				element:enter(cs:sample(), placement)
			end 
		end)
	else -- max ~= nil
		forEachElement(environment, function(_, element)
			local t = type(element)
			if t == "Society" then
				element.placements[placement] = cs
				forEachAgent(element, function(agent)
					local cell = cs:sample()
					while #cell[placement] >= max do
						cell = cs:sample()
					end
					agent:enter(cell, placement)
				end)
			elseif t == "Agent" then
				local cell = cs:sample()
				while #cell[placement] >= max do
					cell = cs:sample()
				end 
				element:enter(cell, placement)
			end 
		end)
	end
end

local createUniformPlacement = function(environment, cs, placement)
	local counter = 1 
	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[placement] = cs
			forEachAgent(element, function(agent)
				agent:enter(cs.cells[counter], placement)
				counter = counter + 1 
				if counter > #cs then
					counter = 1 
				end 
			end)
		elseif mtype == "Agent" then
			agent:enter(cs.cells[counter], placement)
			counter = counter + 1 
			if counter > #cs then
				counter = 1 
			end 
		end 
	end)
end

local createVoidPlacement = function(environment, cs, placement)
	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[placement] = cs
		end
	end)
end

Environment_ = { 
	type_ = "Environment",
	--- Add an element to the Environment.
	-- @param object An Agent, Automaton, CellularSpace, Timer or Environment.
	-- @usage environment:add(agent)
	-- environment:add(cellularSpace)
	add = function (self, object)
		local t = type(object)
		if t == "CellularSpace" or t == "Society" or t == "Agent" or 
		   t == "Automaton" or t == "Timer" or t == "Trajectory" or t == "Cell" then
			object.parent = self
			table.insert(self, object)
		else
      		incompatibleTypeError(1, "Agent, Automaton, Cell, CellularSpace, Society, Timer or Trajectory", object)
    	end
		object.parent = self
		return self.cObj_:add(object.cObj_)
	end,
	--- Create relations between behavioural entities (Agents) and spatial entities (Cells). The
	-- Environment must have only one CellularSpace or Trajectory to place agents. It is possible
	-- to have more than one behavioural entity in the Environment. When distributing Agents over
	-- a Trajectory, the Agents will be able to move over the whole CellularSpace.
	-- @param data.strategy A string containing the strategy to be used for creating a placement
	-- between Agents and Cells. See the options below:
	-- @param data.name A string representing the name of the relation in TerraME objects. Default
	-- is "placement", which means that the modeler can use Agent:enter(), Agent:move(), and
	-- Agent:leave() directly. If the name is different from the default value, the modeler will
	-- have to use the last argument of these functions to indicate which relation they are
	-- changing or perform changes on these relations manually.
	-- @param data.max A number representing the maximum number of Agents that can enter in the
	-- same Cell when creating the placement. Default is having no limit. Using max is
	-- computationally efficient only when the number of Agents is considerably lower than the
	-- number of Cells times max. Otherwise, it is better to consider using the uniform strategy.
	-- Note that using this parameter does not force the simulation to have a maximum number of
	-- agents inside cells along the simulation - controlling the maximum is always up to
	-- the modeler.
	-- @tab strategy Strategy & Description & Parameters \
	-- "random"(default) & Create placements between Agents and Cells randomly, putting each Agent
	-- in a Cell randomly chosen. & name, max \
	-- "uniform" & Create placements uniformly. The first Agents enter in the first Cells. The
	-- last Cells will contain fewer Agents if the number of Agents is not proportional to the
	-- number of Cells. For example, placing a Society with four Agents in a CellularSpace of
	-- three Cells will put two Agents in the first Cell and one in each other Cell. & name \
	-- "void" & Create only the pointers for each object in each side, preparing the objects to
	-- be manipulated by the modeler. & name \
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
	 			namedParametersError("createPlacement")
			end
		end

		local mycs
		local mysoc
		local foundsoc

		if data.strategy == nil then
			data.strategy = "random"      
		elseif type(data.strategy) ~= "string" then
			incompatibleTypeError("strategy", "string", data.strategy)
		end

		if type(data.name) ~= "string" then  
			if type(data.name) == "nil" then
				data.name = "placement"
			else
				incompatibleTypeError("name", "string", data.name)
			end
		end

		if data.strategy == "random" then
			if type(data.max) ~= "number" then
				if type(data.max) == "nil" then
					data.max = math.huge
				else
					incompatibleTypeError("max", "positive integer number", data.max)
				end
			elseif data.max <= 0 then
				incompatibleValueError("max", "positive integer number", data.max)
			end
		end

		local qty_agents = 0

		for k, ud in pairs(self) do
			local t = type(ud)
			if t == "CellularSpace" or t == "Trajectory" then
				if mycs ~= nil then
					customError("Environment should contain only one CellularSpace or Trajectory.")
				end
				mycs = ud
			elseif t == "Society" then
				qty_agents = qty_agents + #ud
				forEachElement(ud.placements, function(index)
					if index == data.name then
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

		if mycs == nil then
			customError("The Environment does not contain a CellularSpace.")
		elseif not foundsoc then
			customError("Could not find a behavioral entity (Society or Agent) within the Environment.")
		end
		if data.strategy == "random" and data.max ~= nil and qty_agents > #mycs * data.max then
			customError("It is not possible to put that amount of agents in space.")
		end

		local idCounter = 0
		forEachElement(self, function(_, element)
			local t = type(element)
			local placement = data.name
			if t == "CellularSpace" or t == "Trajectory" then
				local melement = element
				if t == "Trajectory" then melement = element.parent end -- use the CellularSpace

				forEachCell(melement, function(cell)
					idCounter = idCounter + 1
					cell[placement] = Group{build = false}
					cell[placement].agents = {}
					cell.agents = cell[placement].agents
				end)
			elseif t == "Society" then
				element.placements[data.name] = mycs
				forEachAgent(element, function(agent)
					agent[placement] = Trajectory{build = false, target = mycs}
					agent[placement].cells = {}
					agent.cells = agent[placement].cells
				end)
			elseif t == "Agent" then
				element[placement] = Trajectory{build = false, target = mycs}
				element[placement].cells = {}
				element.cells = element[placement].cells
			end
		end)

		switch(data, "strategy"):caseof{
			random = function() 
				checkUnnecessaryParameters(data, {"strategy", "name", "max"})
				createRandomPlacement(self, mycs, data.max, data.name)
			end,
			uniform = function()
				checkUnnecessaryParameters(data, {"strategy", "name"})
				createUniformPlacement(self, mycs, data.name)
			end,
			void = function()
				checkUnnecessaryParameters(data, {"strategy", "name"})
				createVoidPlacement(self, mycs, data.name) 
			end
		}
	end,
	--- Execute the Environment until a given time. It activates the Timers it contains, the Timers
	-- of the Environments it contains, and so on.
	-- @param finalTime A positve integer number representing the time to stop the simulation.
	-- Timers stop when there is no Event scheduled to a time less or equal to the final time.
	-- @usage environment:execute(1000)
	execute = function(self, finalTime) 
		if type(finalTime) ~= "number" then
			incompatibleTypeError(1, "number", finalTime)
		end
		self.cObj_:config(finalTime)
		self.cObj_:execute()
	end,
	--- Load a Neighborhood between two different CellularSpaces.
	-- @param data.source A string representing the name of the file to be loaded.
	-- @param data.name A string representing the name of the relation to be created.
	-- Default is '1'.
	-- @param data.bidirect If 'true' then for each relation from Cell a to Cell b, create
	-- also a relation from b to a. Default is 'false'.
	-- @usage environment:loadNeighborhood{  
	--     source = "file.gpm",
	--     name = "newNeigh"
	-- }
	loadNeighborhood = function(self, data)
		if type(data) ~= "table" then
			if data == nil then
				tableParameterError("loadNeighborhood")
			else
	 			namedParametersError("loadNeighborhood")
			end
		end

		if data.name == nil then
			data.name = "1"
		elseif type(data.name) ~= "string" then 
			incompatibleTypeError("name", "string", data.name)
		end

		if type(data.source) == "string" then
			local extension = string.match(data.source, "%w+$")
			if extension ~= "gpm" then
				incompatibleFileExtensionError("source", extension)
			else
				local file = io.open(data.source, "r")
				if not file then
					resourceNotFoundError("source", data.source)
				end
			end
		elseif data.source == nil then
			mandatoryArgumentError("source")
		elseif type(data.source ~= "string") then
			incompatibleTypeError("source", "string", data.source)
		end

		local extension = string.match(data.source, "%w+$")
    
    	if data.bidirect == nil then
			data.bidirect = false
		elseif type(data.bidirect) ~= "boolean" then
			incompatibleTypeError("bidirect", "boolean", data.bidirect)
		end

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

		if layer1Id == layer2Id then 
			customError("This function does not load neighborhoods between cells from the same CellularSpace. Use CellularSpace:loadNeighborhood() instead.") 
		end

		if numAttributes > 1 then
			customError("This function does not support GPM with more than one attribute.")
		end

		local beginName = layer2Idx
		local attribNames = {}

		for i = 1, numAttributes do
			if i ~= 1 then local beginName = string.find(header, "%s", (endName + 1)) end

			local endName = string.find(header, "%s", (beginName + 1))
			
			if endName ~= nil then
				attribNames[i] = string.sub(header, (beginName + 1), (endName - 1))
			else
				attribNames[i] = string.sub(header, (beginName + 1))
				break
			end
		end
		
		local cellSpaces = {}
		for i, element in pairs(self) do
			if type(element) == "CellularSpace" then
				local cellSpaceLayer = element.layer
				
				if (cellSpaceLayer == layer1Id) then cellSpaces[1] = element
				elseif (cellSpaceLayer == layer2Id) then cellSpaces[2] = element end
			end
		end
		
		if cellSpaces[1] == nil or cellSpaces[2] == nil then
			customError("CellularSpaces were not found in the Environment.")
		end

		repeat
			local line_cell = file:read()
			if line_cell == nil then break; end

			local cellIdIdx = string.find(line_cell, "%s", 1)
			local cellId = string.sub(line_cell, 1, (cellIdIdx - 1))
			local numNeighbors = tonumber(string.sub(line_cell, (cellIdIdx + 1)))

			local cell = cellSpaces[1]:getCellByID(cellId)

			local neighborhood = Neighborhood{id = data.name}
			cell:addNeighborhood(neighborhood, data.name)

			local weight

			if numNeighbors > 0 then
				line_neighbors = file:read()

				local neighIdEndIdx = string.find(line_neighbors, "%s")
				local neighIdIdx = 1

				for i = 1, numNeighbors do
					if i ~= 1 then 
						neighIdIdx = string.find(line_neighbors, "%s", neighIdEndIdx) + 1
						neighIdEndIdx = string.find(line_neighbors, "%s", neighIdIdx)
					end
					local neighId = string.sub(line_neighbors, neighIdIdx, (neighIdEndIdx - 1))
					local neighbor = cellSpaces[2]:getCellByID(neighId)

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

					-- Adds the neighbor in the neighborhood
					neighborhood:addNeighbor(neighbor, weight)

					if data.bidirect then 
						local neighborhoodNeigh = neighbor:getNeighborhood(data.name)
						if neighborhoodNeigh == nil then
							neighborhoodNeigh = Neighborhood{id = data.name}
							neighbor:addNeighborhood(neighborhoodNeigh, data.name)
						end
						neighborhoodNeigh:addNeighbor(cell, weight)
					end
				end
			end
		until(line_cell == nil)

		if data.bidirect == true then
			for i, cell2 in ipairs(cellSpaces[2].cells)do
				neighborhoodNeigh = cell2:getNeighborhood(data.name)
				if neighborhoodNeigh == nil then
					neighborhoodNeigh = Neighborhood()
					cell2:addNeighborhood(neighborhoodNeigh, data.name)
				end
			end
		end

		file:close()
	end,
	--- Notify every Observer connected to the Environment.
	-- @param modelTime An positive integer number representing time to be used by the Observer.
	-- Most of the strategies available ignore this value, therefore it can be left empty.
	-- @usage env:notify()
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
		elseif type(modelTime) ~= "number" then
			if type(modelTime) == "Event" then
				modelTime = modelTime:getTime()
			else
				incompatibleTypeError(1, "Event or positive number", modelTime)
			end
		elseif modelTime < 0 then
			incompatibleValueError(1, "Event or positive number", modelTime)
		end
		self.cObj_:notify(modelTime)
	end
}

metaTableEnvironment_ = {__index = Environment_, __tostring = tostringTerraME}

--- A container that encapsulates space, time, behavior, and other environments. Objects can be
-- added directly when the Environment is declared or after it has been instantiated. It can
-- control the simulation engine, synchronizing all the Timers within it. Calling
-- Utils:forEachElement() traverses each object of an Environment.
-- @param data A table containing all the elements of the Environment to be created.
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
			tableParameterError("Environment")
		else
			namedParametersError("Environment")
		end
	end

	if data.id == nil then
		data.id = "1"
	elseif type(data.id) ~= "string" then
		incompatibleTypeError("id", "string", data.id)
	end
	local cObj = TeScale(data.id)
	setmetatable(data, metaTableEnvironment_)
	cObj:setReference(data)
  	local flagAutomatons = false
	for k, ud in pairs(data) do
		local t = type(ud)
		if t == "table" then
			cObj:add(ud.cObj_)
		elseif t == "userdata" then
			cObj:add(ud)
	    elseif t == "CellularSpace" and flagAutomatons then
			customError("CellularSpace must be added before any Automaton.")
	    elseif t == "Automaton" then
			ud.parent = data
			cObj:add(ud.cObj_)    
			flagAutomatons = true  
		elseif t == "CellularSpace" or t == "Society" or t == "Agent" then 
			ud.parent = data
			--cObj:add(ud.cObj_)
	    end
    
		if t=="Timer" then
			cObj:add(ud.cObj_)
		end
	end
	data.cObj_ = cObj
	return data
end

