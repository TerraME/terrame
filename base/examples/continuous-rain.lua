
-- @example A simple continuous rain model.

-- model parameters
C = 2 -- rain/t
K = 0.4 -- flow coefficient
dt = 0.01 -- time increment

-- GLOBAL VARIABLES
q = 0
input = 0
output = 0

-- RULES
for time = 0, 75, 1 do
    -- rain
    input = integrate{
		equation = function() return C end,
		initial = 0,
		a = 0,
		b = 1,
		step = dt
	}
    -- soil water
    q = integrate{
		equation = function() return input - output end,
		initial = q,
		a = 0,
		b = 1,
		step = dt
	}
    -- drainage
    output = integrate{
		equation = function() return K*q end,
		initial = 0,
		a = 0,
		b = 1,
		step = dt
	}
    -- report
    print(time.."\t"..input.."\t"..output.."\t"..q)
end


