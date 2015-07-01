globalStateIdCounter = 0

State_ = {
	type_ = "State",
	--- Return a string with the id of the State.
	getId = function(self) 
		id = self.cObj_:getID()
		return id
	end,
	--- Change the id of the State. It returns a boolean value indicating whether the operation was succesfully executed.
	-- @param idValue A string that will be set as the id of the State.
	setId = function(self, idValue)
		local idOld= self.cObj_:getID()

		if(type(idValue) ~= "string") then
			incompatibleTypesErrorMsg("#1", "string", type(idValue), 3)
		end	

		self.id= idValue
		self.cObj_:setid(idValue)
		return true
	end

}

local metaTableState_ = {__index = State_}
--- A container of Jumps and Flows. Every State aldo has an id to identify itself in the Jumps of other States within the same Agent or Automaton.
-- @param data A table that contains the State attributes.
-- @param data.id A string with the unique identifier of the State.
-- @usage State {
--     id = "working",
--     Jump{...},
--     Flow{...}
-- }
function State(data)
	local cObj = TeState()

	if data.id == nil then
		globalStateIdCounter = globalStateIdCounter + 1
		data.id = "st".. globalStateIdCounter
		defaultValueWarningMsg("#1", "string", data.id, 3)
	elseif type(data.id) ~= "string" then
		incompatibleTypesErrorMsg("id", "string", type(data.id), 3)
	end
	cObj:config(data.id)

	for i, ud in pairs(data) do
		if type(ud) == "table" then cObj:add(ud.cObj_) end
		if type(ud) == "userdata" then cObj:add(ud) end
	end
	--setmetatable(data, metaTableState_)

	return cObj
end
