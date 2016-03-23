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

a = fff + ert

