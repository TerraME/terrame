
-- @example A simple drainage model.

-- RAIN DRAINAGE MODELS
-- (C) 2010 INPE AND UFOP

-- model parameters
Q1 = 0
Q2 = 0

-- model execution
for t = 1, 100, 1 do
    -- Input
    E1 = 2
    -- Output
    S1 = 0.4 * Q1
    -- Simulation
    Q1 = Q1 + (E1 - S1)
    ----------------------
    -- Input
    E2 = S1
    -- Output
    S2 = 0.2 * Q2
    -- Simulation
    Q2 = Q2 + (E2 - S2)

    -- Report
--    print(Q1, Q2)
end


