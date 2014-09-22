--- Control a discrete transition between States. If the method in the first argument returns true, the target becomes the new active State.
-- @param data.1st a function that returns a boolean value and takes as arguments an Event, an Agent or Automaton, and a Cell, respectively.
-- @param data.target a string with another State id.
-- @usage Jump {
--     function(ev, agent, c)
--         return c.water > c.capInf
--     end,
--     target = "wet"
-- }
function Jump(data)
	if type(data) ~= "table" then
		tableParameterErrorMsg("Jump", 3)
	end

	local cObj = TeJump()
	local metaAttr = {rule = cObj,
		setTarget = function(self, target)
			if type(target) ~= "string" then
				incompatibleTypesErrorMsg("#1", "string", type(target), 3)
				return false
			end
			self.target = target
			return true
		end,	

		getTarget = function(self)
			return self.target
		end
	}

	local metaTable = {__index = metaAttr, __tostring = tostringTerraME}

	if type(data[1]) ~= "function" then
		customErrorMsg("Jump constructor expected a function as first parameter.", 3)
	end

	if type(data.target) ~= "string" then 
		data.target = "st1"
	end  
	cObj:setTargetControlModeName(data.target) 
	setmetatable(data, metaTable)
	cObj:setReference(data)
	return cObj
end
