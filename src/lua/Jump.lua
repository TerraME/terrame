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
	local cObj = TeJump()
	local metaAttr = {rule = cObj,

		setTarget = function(self, target)
			if (type(target) ~= "string") then
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

	local metaTable = {__index = metaAttr}

	if type(data[1]) ~= "function" then
		customWarningMsg("Warning: Jump constructor expected a function as first parameter.", 3)
		data[1] = function() return true end
		customWarningMsg("Warning: using default function.", 3)
	end

	if type(data.target) ~= "string" then 
		data.target = "st1"
		defaultValueWarningMsg("target", "string", data.target, 3)
	end  
	cObj:setTargetControlModeName(data.target) 
	setmetatable(data, metaTable)
	cObj:setReference(data)
	return cObj
end
