globalEnvironmentIdCounter = 0

Environment_ = { 
	type_ = "Environment",
	--- Add an element to the Environment.
	-- @param object An Agent, Automaton, CellularSpace, Timer or Environment.
	-- @usage environment:add(agent)
	-- environment:add(cellularSpace)
	add = function (self, object)
		local t = type(object)
		--if t=="CellularSpace" or t=="Society" or t=="Agent" or t=="Automaton" then
    	if t=="nil" or t=="table" or t=="number" or t=="boolean" or t=="string" then
      		incompatibleTypesErrorMsg("#1","Agent, Automaton, Cell, CellularSpace, Society or Trajectory", t, 3)
    	end
		object.parent = self
		return self.cObj_:add(object.cObj_)
	end,
	--- Add an Agent to the Environment.
	-- @param agent An Agent.
	addAgent = function(self, agent)
		return self.cObj_:addGlobalAgent(agent.cObj_)
	end,
	--- Add an Automaton to the Environment.
	-- @param automaton An Automaton.
	addAutomaton = function(self, automaton)
		return self.cObj_:addLocalAgent(automaton.cObj_)
	end,
	--- Add a Cellular Space to the Environment.
	-- @param cellularSpace An CellularSpace.
	addCellularSpace = function(self, cellularSpace)
		return self.cObj_:addCellularSpace(cellularSpace.cObj_)
	end,
	--- Add a Timer to the Environment.
	-- @param time TODO
	-- @param timer A Timer.
	addTimer = function(self, time, timer) 
		return self.cObj_:addTimer(time, timer.cObj_)
	end,
	--- Create relations between behavioural entities (Agents) and spatial entities (Cells). The Environment must have only one CellularSpace. It is possible to have more than one behavioural entity in the Environment.
	-- @param data.strategy A string containing the strategy to be used for creating a placement between Agents and Cells. See the options below:
	-- @param data.name A string representing the name of the relation in TerraME objects. Default is "placement", which means that the modeler can use enter(), move(), and leave() directly. If the name is different from the default value, the modeler will have to use the last argument of these functions to indicate which relation they are changing or perform changes on these relations manually.
	-- @param data.max A number representing the maximum number of Agents that can enter in the same Cell when creating the placement. Default is having no limit. Using max is computationally efficient only when the number of Agents is considerably lower than the number of Cells times max. Otherwise, it is better to consider using the uniform strategy. Note that using this parameter does not force the simulation to have a maximum number of agents inside cells along the simulation - controlling the maximum is always up to the modeler.
	-- @tab strategy Strategy & Description & Parameters \
	-- "random"(default) & Create placements between Agents and Cells randomly, putting each Agent in a Cell randomly chosen. & name, max \
	-- "uniform" & Create placements uniformly. The first Agents enter in the first Cells. The last Cells will contain fewer Agents if the number of Agents is not proportional to the number of Cells. For example, placing a Society with four Agents in a CellularSpace of three Cells will put two Agents in the first Cell and one in each other Cell. & name \
	-- "void" & Create only the pointers for each object in each side, preparing the objects to be manipulated by the modeler. & name \
	-- @usage environment:createPlacement{
	--     strategy = "uniform"
	-- }
	createPlacement = function(self, data)
		if type(data) ~= "table" then
			incompatibleTypesErrorMsg("#1", "table", type(data), 3)
		end
		local mycs
		local foundsoc

		if data.strategy == nil then
			data.strategy = "random"      
			defaultValueWarningMsg("strategy", "string", data.strategy, 3)
		elseif type(data.strategy) ~= "string" then
			incompatibleTypesErrorMsg("strategy", "string", type(data.strategy), 3)
		else
			if data.strategy ~= "random" and data.strategy ~= "uniform" and data.strategy ~= "void" then
				incompatibleValuesErrorMsg("strategy","one of the strings from the set ['random','uniform','void']", data.strategy, 3)
			end
		end

		if type(data.name) ~= "string" then  
			if type(data.name) == "nil" then
				data.name = "placement"
				defaultValueWarningMsg("name", "string", data.name, 3)
			else
				incompatibleTypesErrorMsg("name", "string", type(data.name), 3)
			end
		end

		if type(data.max) ~= "number" then
			if type(data.max) == "nil" then
				-- verificar. doc não fala valor exato
				data.max = 10000
				defaultValueWarningMsg("max", "positive integer number", data.max, 3)
			else
				incompatibleTypesErrorMsg("max", "positive integer number", type(data.max), 3)
			end
		elseif data.max <= 0 then
			incompatibleValuesErrorMsg("max", "positive integer number", data.max, 3)
		end

		local qty_agents = 0

		for k, ud in pairs(self) do
			local t = type(ud)
			if t == "CellularSpace" then
				if mycs ~= nil then
					customErrorMsg("Error: Environment has more than one CellularSpace.", 3)
				end
				mycs = ud
			elseif t == "Society" then
				qty_agents = qty_agents + ud:size()
				forEachElement(ud.placements, function(_, value)
					if value == data.name then
						customErrorMsg("Error: There is a Society within this Environment that already has this placement.", 3)
					end
				end)

				--table.insert(ud.placements, data.name)
				foundsoc = true
			elseif t == "Agent" then
				qty_agents = qty_agents + 1
				foundsoc = true
			elseif t == "Group" then
				customErrorMsg("Error: Placements is still not implemented for groups.", 3)
			end
		end

		if mycs == nil then
			customErrorMsg("Error: The Environment does not contain a CellularSpace.", 3)
		elseif not foundsoc then
			customErrorMsg("Error: Could not find a behavioral entity (Society or Agent) within the Environment.", 3)
		end
		if data.strategy == "random" and data.max ~= nil and qty_agents > mycs:size() * data.max then
			customErrorMsg("Error: It is not possible to put that amount of agents in space.", 3)
		end

		local idCounter = 0
		forEachElement(self, function(_, element)
			local t = type(element)
			local placement = data.name
			if t == "CellularSpace" or t == "Trajectory" then
				forEachCell(element, function(cell)
					idCounter = idCounter + 1
					cell[placement] = Group{
						id = "grp".. idCounter,
						build = false,
						greater = function (ag1, ag2) return ag1.id > ag2.id end,
						select = function(ag) return true end
					}
					cell[placement].agents = {}
					cell.agents = cell[placement].agents
				end)
			elseif t == "Society" then
				forEachAgent(element, function(agent)
					agent[placement] = Trajectory{ build = false, target = mycs, select = function(cell) return true end, greater = function(cellA,cellB) return cellA.id > cellB.id end }
					agent[placement].cells = {}
					agent.cells = agent[placement].cells
				end)
			elseif t == "Agent" then
				element[placement] = Trajectory{build = false, target = mycs, select = function(cell) return true end, greater = function(cellA, cellB) return true end }
				element[placement].cells = {}
				element.cells = element[placement].cells
			end
		end)

		switch(data, "strategy"): caseof {
			["random"]  = function() createRandomPlacement(self, mycs, data.max, data.name) end,
			["uniform"] = function() createUniformPlacement(self, mycs, data.name) end,
			["void"]    = function() createVoidPlacement(self, mycs, data.name) end
		}
	end,

	--- Execute the Environment until a given time. It activates the Timers it contains, the Timers of the Environments it contains, and so on.
	-- @param finalTime A positve integer number representing the time to stop the simulation. Timers stop when there is no Event scheduled to a time less or equal to the final time.
	-- @usage environment:execute(1000)
	execute = function(self, finalTime) 
		if type(finalTime) ~= "number" then
			finalTime = 1
			defaultValueWarningMsg("#1", "positive integer number", finalTime, 3)
		elseif(finalTime < 0 or finalTime ~= math.floor(finalTime)) then
      incompatibleValuesErrorMsg("#1", "positive integer number", finalTime, 3)  
		end
		self.cObj_:config(finalTime)
		self.cObj_:execute()
	end,
	--- Load a Neighborhood between two different CellularSpaces.
	-- @params data.source A string representing the name of the file to be loaded.
	-- @params data.name A string representing the name of the relation to be created. Default is '1'.
	-- @params data.bidirect If 'true' then for each relation from Cell a to Cell b, create also a relation from b to a. Default is 'false'.
	-- @usage environment:loadNeighborhood{  
	--     source = "file.gpm",
	--     name = "newNeigh"
	-- }
	loadNeighborhood = function(self, data)
		if data == nil then 
				data = {}
        defaultValueWarningMsg("#1", "table", "{}", 3) 
		elseif(type(data) ~= "table")then
      incompatibleTypesErrorMsg("#1", "table", type(data), 3)
		end

		if(data.name == nil)then
				globalNeighborhoodIdCounter = globalNeighborhoodIdCounter + 1
				data.name = "neigh"..globalNeighborhoodIdCounter
			defaultValueWarningMsg("name", "string", data.name, 3)
		elseif type(data.name) ~= "string" then 
				incompatibleTypesErrorMsg("name", "string", type(data.name), 3)
		end

		if type(data.source) == "string" then
			local extension = string.match(data.source, "%w+$")		
			if extension ~= "gpm" then
				customErrorMsg("Error: The file extension '"..extension.."' is not supported.", 3)
			else
				local file = io.open(data.source, "r")
				if(not file) then
					resourceNotFoundErrorMsg("source", data.source, 3)
				end
			end
		elseif(data.source == nil)then
			mandatoryArgumentErrorMsg("source", 3)
		elseif(type(data.source ~= "string"))then
			incompatibleTypesErrorMsg("source", "string", type(data.source), 3)
		end

		local extension = string.match(data.source, "%w+$")
		if(TME_MODE ~= TME_EXECUTION_MODES.QUIET)then
			print("Loading neighborhood \""..data.name.."\" from a .gpm file.")
		end
    
    if data.bidirect == nil then
			data.bidirect = false
			defaultValueWarningMsg("bidirect", "boolean", data.bidirect, 3)      
		elseif (type(data.bidirect) ~= "boolean") then
      incompatibleTypesErrorMsg("bidirect","boolean",type(data.bidirect), 3)
		end

		local file = io.open(data.source, "r")
		if not file then
			resourceNotFoundErrorMsg("source", data.source, 3)
		end

		local header = file:read()
		
		local numAttribIdx = string.find(header, "%s", 1)
		local layer1Idx = string.find(header, "%s", (numAttribIdx + 1))
		local layer2Idx = string.find(header, "%s", (layer1Idx + 1))
		
		local numAttributes = tonumber(string.sub(header, 1, numAttribIdx))
		local layer1Id = string.sub(header, (numAttribIdx + 1), (layer1Idx - 1))
		local layer2Id = string.sub(header, (layer1Idx + 1), (layer2Idx - 1))

		--RAIAN: Adicionei esta verificacao de erro
		if(layer1Id == layer2Id)then 
			customErrorMsg("Error: This function does not load neighborhoods between cells from the same space. Use CellularSpace:loadNeighborhood() instead.", 3) 
		end
		--RAIAN: FIM

		if (numAttributes > 1) then
			customErrorMsg("Error: This function does not support GPM with more than one attribute.", 3)
		end

		local beginName = layer2Idx
		local attribNames = {}

		for i = 1, numAttributes do
			if (i ~= 1) then local beginName = string.find(header, "%s", (endName + 1)) end

			local endName = string.find(header, "%s", (beginName + 1))
			
			if (endName ~= nil) then
				attribNames[i] = string.sub(header, (beginName + 1), (endName - 1))
			else
				attribNames[i] = string.sub(header, (beginName + 1))
				break
			end
		end
		
		local cellSpaces = {}
		for i, element in pairs(self) do
			if (type(element) == "CellularSpace") then
				local cellSpaceLayer = element.layer
				
				if (cellSpaceLayer == layer1Id) then cellSpaces[1] = element
				elseif (cellSpaceLayer == layer2Id) then cellSpaces[2] = element end
			end
		end
		
		if (cellSpaces[1] == nil or cellSpaces[2] == nil) then
			customErrorMsg("Error: CellularSpaces were not found in the Environment.", 2)
		end

		repeat
			local line_cell = file:read()
			if (line_cell == nil) then break; end

			local cellIdIdx = string.find(line_cell, "%s", 1)
			local cellId = string.sub(line_cell, 1, (cellIdIdx - 1))
			local numNeighbors = tonumber(string.sub(line_cell, (cellIdIdx + 1)))

			local cell = cellSpaces[1]:getCellByID(cellId)

			local neighborhood = Neighborhood{id = data.name}
			cell:addNeighborhood(neighborhood, data.name)

			if (numNeighbors > 0) then
				line_neighbors = file:read()

				--RAIAN: Alterei aqui para corrigir problemas com peso
				local neighIdEndIdx = string.find(line_neighbors, "%s")
				local neighIdIdx = 1
				--RAIAN: FIM 

				for i = 1, numNeighbors do
					--RAIAN: Alterei aqui para corrigir problemas com peso
					if (i ~= 1) then 
						neighIdIdx = string.find(line_neighbors, "%s", neighIdEndIdx) + 1
						neighIdEndIdx = string.find(line_neighbors, "%s", neighIdIdx)
					end
					local neighId = string.sub(line_neighbors, neighIdIdx, (neighIdEndIdx - 1))
					local neighbor = cellSpaces[2]:getCellByID(neighId)

					-- Gets the weight
					--RAIAN: Alterei aqui para corrigir problema com peso
					if(numAttributes > 0)then
						local weightEndIdx = string.find(line_neighbors, "%s", (neighIdEndIdx + 1))

						if (weightEndIdx == nil) then 
							local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1))
							weight = tonumber(weightAux)

							if(weight == nil)then
								customErrorMsg("Error: The string \""..weightAux.."\" found as weight in the file \""..data.source..
								"\" could not be converted to a number.", 3)
							end
						else
							local weightAux = string.sub(line_neighbors, (neighIdEndIdx + 1), (weightEndIdx - 1))
							weight = tonumber(weightAux)

							if(weight == nil)then
								customErrorMsg("Error: The string \""..weightAux.."\" found as weight in the file \""..data.source..
								"\" could not be converted to a number.", 3)
							end
						end

						if(weightEndIdx)then neighIdEndIdx = weightEndIdx end
					else
						weight = 1
					end

					-- Adds the neighbor in the neighborhood
					neighborhood:addNeighbor(neighbor, weight)

					if (data.bidirect == true) then 
						local neighborhoodNeigh = neighbor:getNeighborhood(data.name)
						if (neighborhoodNeigh == nil) then
							neighborhoodNeigh = Neighborhood{id = data.name}
							neighbor:addNeighborhood(neighborhoodNeigh, data.name)
						end
						neighborhoodNeigh:addNeighbor(cell, weight)
					end
				end
			end
		until(line_cell == nil)

		-- RAIAN: Adicionei este trecho para nao ter celulas com vizinhanca nil, o que pode gerar problemas ao usuario
		if(data.bidirect == true)then
			for i, cell2 in ipairs(cellSpaces[2].cells)do
				neighborhoodNeigh = cell2:getNeighborhood(data.name)
				if(neighborhoodNeigh == nil) then
					neighborhoodNeigh = Neighborhood()
					cell2:addNeighborhood(neighborhoodNeigh, data.name)
				end
			end
		end
		--RAIAN: FIM

		if(TME_MODE ~= TME_EXECUTION_MODES.QUIET)then
			print("Neighborhood file successfully loaded!!!\n")
		end

		file:close()
	end,

	--- Notify every Observer connected to the Environment.
	-- @param modelTime An positive integer number representing time to be used by the Observer. Most of the strategies available ignore this value, therefore it can be left empty.
	-- @see Observer
	notify = function (self, modelTime)
		if modelTime == nil then
			modelTime = 1
			defaultValueWarningMsg("#1", "positive number", modelTime, 3)
    elseif type(modelTime) ~= "number" then
      incompatibleTypesErrorMsg("#1", "positive number", type(modelTime), 3) 
		elseif modelTime < 0 then
			incompatibleValuesErrorMsg("#1","positive number", modelTime, 3)   
		end
		self.cObj_:notify(modelTime)
	end
}

local metaTableEnvironment_ = {__index = Environment_}

--- A container that encapsulates space, time, behavior, and other environments. Objects can be added directly when the Environment is declared or after it has been instantiated. It can control the simulation engine, synchronizing all the Timers within it. Calling forEachElement() traverses each object of an Environment.
-- @param data A table containing all the elements of the Environment to be created.
-- @usage environment = Environment {
--     cs1 = CellularSpace{...},
--     ag1 = Agent{...},
--     aut2 = Automaton{...},
--     t1 = Timer{...},
--     env1 = Environment{...}
-- }
function Environment(data)
	if data.id == nil then
		globalEnvironmentIdCounter = globalEnvironmentIdCounter + 1
		data.id = "env".. globalEnvironmentIdCounter
		defaultValueWarningMsg("id", "string", data.id, 3)
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("id","string",type(data.id), 3)
	end
	local cObj = TeScale(data.id)
	setmetatable(data, metaTableEnvironment_)
	cObj:setReference(data)
  local flagAutomatons = false
	for k, ud in pairs(data) do
		local t = type(ud)
		if t == "table" then cObj:add(ud.cObj_)
		elseif t == "userdata" then cObj:add(ud)
    elseif t == "CellularSpace" and flagAutomatons then
      customErrorMsg("Error: CellularSpace must be added before any Automaton.", 3)
    elseif t == "Automaton" then
      ud.parent = data
      cObj:add(ud.cObj_)    
      flagAutomatons = true  
		elseif t == "CellularSpace" or t == "Society" or t == "Agent" then 
      ud.parent = data
      --cObj:add(ud.cObj_)
    end
    
		if(t=="Timer") then
			cObj:add(ud.cObj_)
		end
	end
	data.cObj_ = cObj
	return data
end

--PEDRO: removi o 'local' 
createRandomPlacement = function(environment, cs, max, placement)
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
					while cell[placement]:size() >= max do
						cell = cs:sample()
					end
					agent:enter(cell, placement)
				end)
			elseif t == "Agent" then
				local cell = cs:sample()
				while cell[placement]:size() >= max do
					cell = cs:sample()
				end 
				element:enter(cell, placement)
			end 
		end)
	end
end

--PEDRO: removi o 'local' 
createUniformPlacement = function(environment, cs, placement)
	local counter = 1 
	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[placement] = cs
			forEachAgent(element, function(agent)
				agent:enter(cs.cells[counter], placement)
				counter = counter + 1 
				if counter > cs:size() then
					counter = 1 
				end 
			end)
		elseif mtype == "Agent" then
			agent:enter(cs.cells[counter], placement)
			counter = counter + 1 
			if counter > cs:size() then
				counter = 1 
			end 
		end 
	end)
end

createVoidPlacement = function(environment, cs, placement)
	forEachElement(environment, function(_, element, mtype)
		if mtype == "Society" then
			element.placements[placement] = cs
		end
	end)
end
