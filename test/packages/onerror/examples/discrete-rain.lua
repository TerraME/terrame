-- @example A simple discrete rain model
-- @arg C The amount of rain per unit of time. The default value is 2.
-- @arg K The flow coefficient. The default value is 0.4.

local s = sessionInfo().separator

-- model parameters
C = 2
K = 0.4

-- GLOBAL VARIABLES
q = 0
input = 0
output = 0

-- RULES
t = Timer{
	Event{start = 0, action = function(event)
		-- rain
		input = C
		-- soil water
		q = q + input - output
		-- drainage
		output = K*q
		-- report
		print(event:getTime(), input, output, q)
	end}
}

t:run(100)

