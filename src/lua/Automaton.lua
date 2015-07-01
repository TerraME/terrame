globalAutomatonIdCounter = 0

Automaton_ = {
	type_ = "Automaton",
	autoincrement = 1,
	---Add a new Trajectory or State to the Automaton. It returns a boolean value
  -- indicating whether the new element was successfully added.
	-- @param object A Trajectory or State.
	-- @usage automaton:add(state)
	-- automaton:add(trajectory)
	add = function(self, object)
		if(type(object) == "Trajectory" or type(object) == "State") then
			self.cObj_:add(object)
			return true
		else
			incompatibleTypesErrorMsg("#1","State or Trajectory", type(object), 3)  
			return false
		end
	end,

	--- Check if the state machine was correctly defined. It verifies whether the targets of Jump rules match the ids of the States.
	-- @usage automaton:build()
	build = function(self)
		self.cObj_:build()
	end,

	---Execute the state machine. First, it executes the Jump of the current State while it jumps from State to State. 
	---When the machine stops jumping, it executes all the Flows of the current State. Usually, this function is called within 
	---an Event, thus the time of the Event can be got from the Timer. It returns a boolean value indicating whether the Jumps were executed correctly.
	-- @param event An Event.
	-- @usage automaton:execute(event)
	execute = function(self, event)
		t = type(event)
		if(t == "userdata" or t == "Pair") then
			self.cObj_:execute(event)
			return true
		else
			incompatibleTypesErrorMsg("#1","Event", type(event), 3)  
		end
	end,

	--- Retrieves the time when the machine executed the transition to the current state. Before running, the latency is zero.
	-- @usage latency = automaton:getLatency()
	getLatency = function(self) 
		return self.cObj_:getLatency()
	end,

	--- Retrieves the name of the current State.
	-- @usage id = automaton:getStateName()
	getStateName = function(self)
		return "Where?"
	end,

	---Notify every Observer connected to the Automaton.
	-- @param modelTime The time to be used by the Observer.
	-- @usage automaton:notify()
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
	end,

	---Activate or not the Trajectories defined for the Automata. Returns whether the change  was successfully executed.
	-- @param status A boolean that indicates if the Trajectories will be activated.
	-- @usage automaton:setTrajectoryStatus(true)
	setTrajectoryStatus = function(self, status)
    if status == nil then
      status = false
      defaultValueWarningMsg("#1", "boolean", "false", 3)
		elseif(type(status) ~= "boolean") then
			incompatibleTypesErrorMsg("#1","boolean",type(status), 3)
		end
		self.cObj_:setActionRegionStatus(status)
		return true
	end,

	---Set the unique identifier of the Automaton. Return a boolean value indicating whether the id was changed correctly.
	-- @param id A string that names the Automaton.
	-- @usage automaton:setId("newid")
	setId = function(self,id)
    if id == nil then
      defaultValueWarningMsg("#1", "string", self.id, 3)
		elseif type(id) ~= "string" then
			incompatibleTypesErrorMsg("id","string", type(id), 3)
		end
		self.id = id
		return true
	end,

	--- Retrieves the unique identifier name of the Automaton.
	-- @usage automaton:getId()
	getId = function(self)
		return self.id
	end,

	---Get all the States inside the Automaton. It returns a vector indexed by numeric positions.
	-- @usage state = automaton:getStates()[1]
	getStates = function(self)
		local statesVector = {}
		for key, value in pairs(self) do
			if (type(value) == "State") then
				statesVector[key] = element
			end
		end
		return statesVector
	end,

	---Get a State of the Automaton according to a given position.
	-- @param index A number indicating the position of the State to be retrieved.
	-- @usage state = automaton:getState(1)
	getState = function(self, index)
    if index == nil then
      index = 1
      defaultValueWarningMsg("#1","positive integer number", index, 3)
    elseif type(index) ~= "number" then
			incompatibleTypesErrorMsg("#1","positive integer number", type(index), 3)
    elseif index < 0 then
      incompatibleValuesErrorMsg("#1","positive integer number", index, 3)
		end
		local statesVector = self:getStates()
		return statesVector[index]
	end
}

local metaTableAutomaton_ = {__index = Automaton_}

--- A hybrid state machine that needs to be located on a CellularSpace, and is replicated over 
-- each Cell of the space. It has independent States in each Cell.
-- @param data.id A string that names the Automanton.
-- @output parent The Environment it belongs.
-- @output type A string containing "Automaton".
-- @usage automaton = Automaton {
--     id = "MyAutomaton",
--     State {...},
--     -- ...
--     State {...}
-- }
function Automaton(data)
	local cObj = TeLocalAutomaton()

	if data.id == nil then
		globalAutomatonIdCounter = globalAutomatonIdCounter + 1
		data.id = "aut".. globalAutomatonIdCounter
		defaultValueWarningMsg("id", "string", data.id, 3)
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("id","string", type(data.id),3)    
	end

	setmetatable(data, metaTableAutomaton_)
	cObj:setReference(data)
	for i, ud in pairs(data) do 
		if type(ud) == "Trajectory" then cObj:add(ud.cObj_) end
		if type(ud) == "userdata" then cObj:add(ud) end
	end
	cObj:build()
	data.cObj_ = cObj
	return data
end
