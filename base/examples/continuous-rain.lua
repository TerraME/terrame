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
    input = d{ function() return C end, 0, 0, 1, dt }
    -- soil water
    q = d{ function( ) return input - output end, q, 0, 1, dt }
    -- drainage
    output = d{ function( ) return K*q end, 0, 0, 1, dt }
    -- report
--    print(time, input, output, q);
end


